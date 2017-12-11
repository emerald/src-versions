/* comment me!
 */

#ifdef XWindows
#include "vm_exp.h"
#include "assert.h"
#include "misc.h"
#include "sisc.h"

#include <sys/file.h>
#include <sys/time.h>
#include <errno.h>


#undef True
#include <X11/Xlib.h>
#include <X11/Xutil.h>

static Display *display;

XWMHints xwmh={
    (InputHint|StateHint),
    True,
    NormalState,
    0,
    0,
    0,0,
    0,
    0
  };

static  unsigned long black,white;

/* Macro to convert a String to a char *. */
#define JTOCString(js, cs) { \
			       (cs) = malloc((js)->d.items + 1); \
			       bcopy((js)->d.data, (cs), \
				     (js)->d.items); \
			       (cs)[(js)->d.items] = '\0'; \
			   }

static XEvent *waitingEvent;
static State *waitingState;

void XCreateDisplay(String es)
{

  if (es == (String)JNIL) {
    display = XOpenDisplay("");
  } else {
    char *s;
    JTOCString(es, s);
    display = XOpenDisplay(s);
    free(s);
  }
  if (display == NULL) {
    TRACE(x, 0, ("Cannot initialize display"));
    exit(1);
  } 
  black = BlackPixel(display,DefaultScreen(display));
  white = WhitePixel(display,DefaultScreen(display));
}

static int tryRead(XEvent *ev)
{
  if (XPending(display) > 0) {
    TRACE(x, 5, ("XEvent: calling NextEvent"));
    XNextEvent(display, ev);
    TRACE(x, 5, ("XEvent: NextEvent returned"));
    TRACE(x, 5, ("event = (%d %d %d %d %d)", 
      *(0 + (int *)ev),
      *(1 + (int *)ev),
      *(2 + (int *)ev),
      *(3 + (int *)ev),
      *(4 + (int *)ev)));
    return 1;
  } else {
/*     XSync(display, False); */
    return 0;
  }
}

/**********************************************************************/
/*      EMXReadEvent                                                    */
/**********************************************************************/
/* Kernel Call */
int EMXReadEvent(int *sp)
{
  Bitchunk                      event;
  XEvent			* ev;

  TRACE(x, 3, ("EMXReadEvent"));

  event = *(Bitchunk *)sp;
  if (ISNIL(event)) {
    TRACE(x, 0,("Event is NIL in EMXReadEvent."));
    return 0;
  }

  /* Check the size of the Bitchunk */
  if (event->d.items < sizeof(XEvent)) {
    TRACE(x, 2, ("Read attempt with a too small Bitchunk: %d should be %d.",
      event->d.items, sizeof(XEvent)));
    return 0;
  }

  /* Check for a display */
  if (!display) {
    TRACE(x, 1, ("Read attempt with no display (= nil)."));
    return 0;
  }

  ev = (XEvent *)&event->d.data[0];
  if (tryRead(ev)) {
  } else {
    do {
      processEverythingOnce();
    } while (tryRead(ev) == 0);
  }
  return 0;
}

int EMXCreateWindow(int *sp)
{
  int x = sp[0], y = sp[1], w = sp[2], h = sp[3];
  String name = (String) sp[4];
  Window window;
  XSizeHints xsh;
  char *cname;

  sp[0] = (long) JNIL;

  if (display == NULL) {
    TRACE(x, 1, ("Create window called with no display"));
    return 1;
  }

  JTOCString(name, cname);
  TRACE(x, 3, ("Create window named %s", cname));

  xsh.x = x;
  xsh.y = y;
  xsh.width = w;
  xsh.height = h;
  xsh.flags = (USPosition|USSize); 

  TRACE(x, 3, ("Create window at (%d, %d) size (%d, %d)",
    xsh.x, xsh.y, xsh.width, xsh.height));
  window = XCreateSimpleWindow(display, DefaultRootWindow(display), xsh.x,
			       xsh.y, xsh.width, xsh.height, 1, black, white);
  TRACE(x, 3, ("XCreateWindow returns %d", window));
  XSetStandardProperties(display,window,cname,cname,None,NULL,0,&xsh);
/*  XSetWMHints(display,window,&xwmh); */
  XMapWindow(display,window);
#if 0
  XSelectInput(display, window, ExposureMask);
  XWindowEvent(display, window, ExposureMask, &event);
#endif
  sp[0] = (long) window;
  free(cname);
  return 1;
}

/*-----------------------------------------------------------------------
 * FUCTION : EMXSelectInput
 *           To requests X server report the events associated with the event
 *           Mask
 * Jyhlin Chang Jul 15,1988
 *-----------------------------------------------------------------------*/

int EMXSelectInput(int *sp)
{
  Window w = sp[0];
  unsigned long event_mask = sp[1];
  
  XSelectInput(display, w, event_mask);
  return 0;

}

typedef struct {
  XFontStruct *f;
  int rc;
} FontInfo, *FontInfoPtr;

IISc GCToFontInfo;
SISc nameToFont;

void setUpFont(GC gc, char *fontname)
{
  Font font;
  FontInfoPtr fi;
  XGCValues gcvalues;

  font = (Font) SIScLookup(nameToFont, fontname);
  if (SIScIsNIL(font)) {
    font = XLoadFont(display , fontname);
    SIScInsert(nameToFont, fontname, (int)font);
    fi = (FontInfoPtr) malloc(sizeof(FontInfo));
    fi->f = XQueryFont(display, font);
    fi->rc = 0;
    TRACE(x, 3, ("Inserting %s %#x -> %#x in gctofontinfo", fontname, (int)font, (int)fi));
    IIScInsert(GCToFontInfo, (int)font, (int)fi);
  } else {
    fi = (FontInfoPtr)IIScLookup(GCToFontInfo, (int)font);
    assert(!IIScIsNIL(fi));
  }
  fi->rc++;
  gcvalues.font = font;
  XChangeGC(display, gc, GCFont, &gcvalues);
  TRACE(x, 3, ("Inserting %#x -> %#x in gctofontinfo", (int)gc, (int)fi));
  IIScInsert(GCToFontInfo, (int)gc, (int)fi);  
}
    
int EMXInitGc(int *sp)
{
  Window win = sp[0];
  XGCValues gcvalues;
  GC gc;
  int flags;

  TRACE(x, 3, ("XInitGC"));
  gcvalues.foreground = black; 
  gcvalues.background = white; 
  gcvalues.line_width =  0;
  flags = GCLineWidth | GCForeground | GCBackground;

  gc = XCreateGC(display,win,flags,&gcvalues);
  setUpFont(gc, "9x15");
  sp[0] = (long) gc;
  TRACE(x, 3, ("XInitGC returns %x", gc));
  return 1;
}

int EMXSetWidth(int *sp)
{
  GC gc = (GC) sp[0];
  Window  win = (Window) sp[1];
  int width = sp[2];
  XGCValues gcvalues;

  gcvalues.line_width =  width;
  XChangeGC(display,gc,GCLineWidth,&gcvalues);
  return 0;
} 

int EMXSetFont(int *sp)
{
  GC gc = (GC) sp[0];
  Window win = (Window)sp[1];
  String  fontname = (String)sp[2];   
  char *cfontname;

  JTOCString(fontname, cfontname);
  setUpFont(gc, cfontname);
  free(cfontname);
  return 0;
}

int EMXLine(int *sp)
{
  Window win = (Window)sp[0];
  int  x1 = sp[1], y1 = sp[2];
  int  x2 = sp[3], y2 = sp[4];
  GC gc = (GC)sp[5];

  TRACE(x, 3, ("X Line on window %d from (%d, %d) to (%d, %d)",
    win, x1, y1, x2, y2));
  XDrawLine(display,win,gc,x1, y1, x2, y2);
  TRACE(x, 3, ("XLine done"));
  return 0;
}

int EMXTextWidth(int *sp)
{
  Window win = (Window)sp[0];
  String string = (String)sp[1]; 
  GC gc = (GC)sp[2];
  FontInfoPtr fi;
  
  TRACE(x, 3, ("XTextWidth begin %.*s", string->d.items, string->d.data));
  fi = (FontInfoPtr)IIScLookup(GCToFontInfo, (int)gc);
  assert(!IIScIsNIL(fi));
  sp[0] = XTextWidth(fi->f, (char *)string->d.data, string->d.items);
  TRACE(x, 3, ("XTextWidth done"));
  return 1;
}
  
int EMXString(int *sp)
{
  Window win = (Window)sp[0];
  String string = (String)sp[1]; 
  int x = sp[2], y = sp[3];
  GC gc = (GC)sp[4];

  TRACE(x, 3, ("XString begin %.*s", string->d.items, string->d.data));
  XDrawString(display, win, gc, x, y, (char *)string->d.data, string->d.items);
  TRACE(x, 3, ("XString done"));
  return 0;
}

int EMXConfigureWindow(int *sp)
{
  Window win = (Window)sp[0];
  int x = sp[1], y = sp[2], w = sp[3], h = sp[4];
  XWindowChanges values;

  TRACE(x, 3, ("X ConfigureWindow on window %d (%d, %d) (%d, %d)",
    win, x, y, w, h));
  values.x = x;
  values.y = y;
  values.width = w;
  values.height = h;
  XConfigureWindow(display, win, CWX|CWY|CWWidth|CWHeight, &values);
  TRACE(x, 3, ("XConfigureWindow done"));
  return 0;
}

int EMXFlush(int *sp)
{
  TRACE(x, 3, ("X Flush called"));
  XFlush(display);
  TRACE(x, 3, ("X Flush done"));
  return 0;
}

int EMXWFlush(int *sp)
{
  Window w = (Window) sp[0];
  XFlush(display);
  return 0;
}

int EMXRaiseWindow(int *sp)
{
  Window w = (Window)sp[0];
  XRaiseWindow(display, w);
  return 0;
}

int EMXLowerWindow(int *sp)
{
  Window w = (Window)sp[0];
  XLowerWindow(display, w);
  return 0;
}

int EMXUnmapWindow(int *sp)
{
  Window w = (Window)sp[0];
  XUnmapWindow(display, w);
  return 0;
}

int EMXResizeWindow(int *sp)
{
  Window w =(Window)sp[0];
  int x = sp[1],y = sp[2];
  XResizeWindow(display,w,x,y);
  return 0;
}

int EMXMoveWindow(int *sp)
{
  Window w =(Window)sp[0];
  int x = sp[1],y = sp[2];
  XMoveWindow(display,w,x,y);
  return 0;
}

int EMXClearWindow(int *sp)
{
  Window w = (Window)sp[0];
  XClearWindow(display, w);
  return 0;
}

int EMXClearArea(int *sp)
{
  Window w = (Window)sp[0];
  int tlx = sp[1], tly = sp[2], width = sp[3], height = sp[4];
  XClearArea(display, w, tlx, tly, width, height, False);
  return 0;
}

int EMXCloseWindow(int *sp)
{
  Window w = (Window)sp[0];
  XDestroyWindow(display,w);
  return 0;
}

int EMXBatch(int *sp)
{
  int value = sp[0];
  if (value) {
  }
  return 0;
}

int EMXGet(int *sp)
{
  Window win = (Window)sp[0];
  String string = (String)sp[1]; 
  sp[0] = (long)string;
  return 1;
}

int EMXSet(int *sp)
{
  Window win = (Window)sp[0];
  String string = (String)sp[1]; 

  return 0;
}

/*----------------------------------------------------------------------
 *
 * Translate KeyBoard Event's input keycode to ASCII String 
 *----------------------------------------------------------------------*/
#define BUFFERSIZE 255
static char CInputBuffer[BUFFERSIZE];

int EMXGetCharacter(int *sp)
{
  Bitchunk                      event = (Bitchunk)sp[0];
  int                             length;
  String                          s;
  XEvent                          *ev;

  sp[0] = (long)JNIL;

  if (event == (Bitchunk) JNIL) {
    TRACE(x, 2, ("Event is NIL in EMXGetCharacter."));
    return 1;
  }

  ev = (XEvent *)event->d.data; 
  TRACE(x, 5, ("event = (%d %d %d %d %d)", 
    *(0 + (int *)ev),
    *(1 + (int *)ev),
    *(2 + (int *)ev),
    *(3 + (int *)ev),
    *(4 + (int *)ev)));

  TRACE(x, 5, ("Before XLookupString"));
  CInputBuffer[0] = '\0';
  length = XLookupString((XKeyEvent *)ev, CInputBuffer, BUFFERSIZE,
			 (KeySym *)NULL, (XComposeStatus *)NULL);
  TRACE(x, 5, ("After XLookupString, len=%d, str=%s, end=%d", length,
	 CInputBuffer, *(CInputBuffer+length)));

  s = (String)CreateString(CInputBuffer);
  TRACE(x, 5, ("After BuildString, s = %x", s));
  sp[0] = (long) s;
  return 1;
} 

int EMXInit(int *sp)
{
  TRACE(x, 1, ("XInit"));
  XCreateDisplay((String)JNIL);
  GCToFontInfo = IIScCreate();
  nameToFont = SIScCreate();
#if 0
  MTRegisterFD(ConnectionNumber(display));
#endif
  return 0;
}
#endif

int (*xfuncs[])(int *) = {
#ifdef XWindows
  EMXInitGc,		/* 0 */
  EMXSetFont,		/* 1 */
  EMXSetWidth,		/* 2 */
  EMXLine,		/* 3 */
  EMXString,		/* 4 */
  EMXCreateWindow,	/* 5 */
  EMXUnmapWindow,	/* 6 */
  EMXClearWindow,	/* 7 */
  EMXCloseWindow,	/* 8 */
  EMXMoveWindow,	/* 9 */
  EMXResizeWindow,	/* 10 */
  EMXConfigureWindow,	/* 11 */
  EMXRaiseWindow,	/* 12 */
  EMXLowerWindow,	/* 13 */
  EMXFlush,		/* 14 */
  EMXReadEvent,		/* 15 */
  EMXGetCharacter,	/* 16 */
  EMXSelectInput,	/* 17 */
  EMXInit,		/* 18 */
  EMXWFlush,		/* 19 */
  EMXBatch,		/* 20 */
  0,			/* 21 */
  EMXGet,		/* 22 */
  EMXSet,		/* 23 */
  EMXTextWidth,		/* 24 */
  EMXClearArea,		/* 25 */
#endif
};
