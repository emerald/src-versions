#include "xforms.h"
#include "iisc.h"
#include "assert.h"
#include "dist.h"
#include "trace.h"

IISc freeobjtoextra;

Display *mfl_get_display(void)
{
  return fl_get_display();
}

int mfl_errorhandler(Display *display, XErrorEvent *ev)
{
  TRACE(x, 0, ("mfl_errorhandler was called"));
  printf("An X error happened\n");
  die();
  return 0;
}

void mfl_initialize(char *progname)
{
  int argc = 1;
  static int alreadyInitialized = 0;
#if defined(alpha)
#  pragma pointer_size long
#endif
  char *arg = "junk";
#if defined(alpha)
#  pragma pointer_size short
#endif

  if (!alreadyInitialized) {
    alreadyInitialized = 1;
    freeobjtoextra = IIScCreate();
    TRACE(x, 3, ("mfl_initialize %s", progname));
    fl_initialize(&argc, &arg, progname, 0, 0);
    XSetErrorHandler(mfl_errorhandler);
  }
}

void mfl_add_chart_value(FL_OBJECT * obj, float val, char *text, int col)
{
  TRACE(x, 3, ("mfl_add_chart_value %#x %g %s %d", obj, val, text, col));
  fl_add_chart_value(obj, (double)val, text, col);
}

void mfl_insert_chart_value(FL_OBJECT * obj, int index, float val, char *text, int col)
{
  fl_insert_chart_value(obj, index, (double)val, text, col);
}

void mfl_replace_chart_value(FL_OBJECT * obj, int index, float val, char *text, int col)
{
  fl_replace_chart_value(obj, index, (double)val, text, col);
}

void mfl_set_chart_bounds(FL_OBJECT * obj, float xmin, float xmax)
{
  fl_set_chart_bounds(obj, (double)xmin, (double)xmax);
}

void mfl_set_slider_value(FL_OBJECT * obj, float val)
{
  fl_set_slider_value(obj, (double)val);
}

int mfl_get_slider_value(FL_OBJECT * obj)
{
  float r = fl_get_slider_value(obj);
  return *(int *)&r;
}

void mfl_set_slider_step(FL_OBJECT * obj, float val)
{
  fl_set_slider_step(obj, (double)val);
}

void mfl_set_slider_size(FL_OBJECT * obj, float val)
{
  fl_set_slider_size(obj, (double)val);
}

void mfl_set_slider_bounds(FL_OBJECT * obj, float xmin, float xmax)
{
  fl_set_slider_bounds(obj, (double)xmin, (double)xmax);
}

void mfl_set_dial_value(FL_OBJECT * obj, float val)
{
  fl_set_dial_value(obj, (double)val);
}

int mfl_get_dial_value(FL_OBJECT * obj)
{
  float r = fl_get_dial_value(obj);
  return *(int *)&r;
}

void mfl_set_dial_step(FL_OBJECT * obj, float val)
{
  fl_set_dial_step(obj, (double)val);
}

void mfl_set_dial_bounds(FL_OBJECT * obj, float xmin, float xmax)
{
  fl_set_dial_bounds(obj, (double)xmin, (double)xmax);
}

void mfl_set_dial_angles(FL_OBJECT * obj, float xmin, float xmax)
{
  fl_set_dial_angles(obj, (double)xmin, (double)xmax);
}

void mfl_set_counter_value(FL_OBJECT * obj, float val)
{
  fl_set_counter_value(obj, (double)val);
}

int mfl_get_counter_value(FL_OBJECT * obj)
{
  float r = fl_get_counter_value(obj);
  return *(int *)&r;
}

void mfl_set_counter_step(FL_OBJECT * obj, float small, float large)
{
  fl_set_counter_step(obj, (double)small, (double)large);
}

void mfl_set_counter_bounds(FL_OBJECT * obj, float xmin, float xmax)
{
  fl_set_counter_bounds(obj, (double)xmin, (double)xmax);
}

int mfl_get_input_cursorxpos(FL_OBJECT *obj)
{
  int x, y;
  fl_get_input_cursorpos(obj, &x, &y);
  return x;
}

void mfl_set_timer(FL_OBJECT * obj, float val)
{
  fl_set_timer(obj, (double)val);
}

int mfl_get_timer(FL_OBJECT * obj)
{
  float r = fl_get_timer(obj);
  return *(int *)&r;
}

void mfl_flush(void)
{
  XFlush(fl_get_display());
}

void mfl_ringbell(void)
{
  XBell(fl_display, 0);
}

FL_OBJECT *mfl_do_forms(void)
{
  FL_OBJECT *changed;
  TRACE(x, 4, ("mfl_do_forms"));
  changed = fl_do_forms();
  TRACE(x, 5, ("mfl_do_forms returns %#x", changed));
  return changed;
}
  
typedef struct {
  unsigned int state;
  int first, full, processed;
  int changed;
  int event;
  FL_Coord mx, my;
  int key;
  void *xev;
} freeextra;

#define MFL_EVENT 1
#define MFL_MX 2
#define MFL_MY 3
#define MFL_KEY 4
#define MFL_CHANGED 5
#define MFL_X 6
#define MFL_Y 7
#define MFL_W 8
#define MFL_H 9

int mfl_free_fetch(FL_OBJECT *obj, int which)
{
  freeextra *fe = (freeextra *)IIScLookup(freeobjtoextra, (int)obj);
  assert(!IIScIsNIL(fe));

  TRACE(x, 5, ("mfl_free_fetch %#x %d", obj, which));
  
  switch(which) {
  case MFL_EVENT:
    return fe->event;
    break;
  case MFL_MX:
    return fe->mx;
    break;
  case MFL_MY:
    return fe->my;
    break;
  case MFL_KEY:
    return fe->key;
    break;
  case MFL_CHANGED:
    fe->changed = 1;
    return 0;
  case MFL_X:
    return obj->x;
    break;
  case MFL_Y:
    return obj->y;
    break;
  case MFL_W:
    return obj->w;
    break;
  case MFL_H:
    return obj->h;
    break;
  default:
    return -1;
    break;
  }
}

void mfl_free_wait(FL_OBJECT *obj, unsigned int *block)
{
  freeextra *fe = (freeextra *)IIScLookup(freeobjtoextra, (int)obj);
  assert(!IIScIsNIL(fe));
  TRACE(x, 5, ("mfl_free_wait %#x", obj));
  if (!fe->first) {
    fe->processed = 1;
  } else {
    fe->first = 0;
  }
  if (fe->full) {
    fe->full = 0;
    *block = 0;
  } else {
    fe->state = *block;
    *block = 1;
  }
}

int mfl_free_handler(FL_OBJECT *obj, int event, FL_Coord mx, FL_Coord my,
		     int key, void *xev)
{
  freeextra *fe = (freeextra *)IIScLookup(freeobjtoextra, (int)obj);
  if (IIScIsNIL(fe)) return 0;
  TRACE(x, 5, ("mfl_free_handler %#x %d %d %d %d", obj, event, mx, my, key));
  if (event == FL_MOTION && fe->mx == mx && fe->my == my) return 0;
  fe->changed = 0;
  fe->event = event;
  fe->mx = mx;
  fe->my = my;
  fe->key = key;
  fe->xev = xev;
  fe->processed = 0;
  if (fe->state) {
    fe->full = 0;
    makeReady(fe->state);
    fe->state = 0;
  } else {
    fe->full = 1;
  }
  while (!fe->processed) {
    processEverythingOnce();
  }
  fe->full = 0;
  return fe->changed;
}

FL_OBJECT *mfl_add_free(int type, FL_Coord x, FL_Coord y, FL_Coord w,
			  FL_Coord h, const char *label)
{
  FL_OBJECT *o;
  freeextra *fe;
  o = fl_add_free(type, x, y, w, h, label, mfl_free_handler);
  fe = (freeextra *)malloc(sizeof(freeextra));
  memset(fe, 0, sizeof *fe);
  fe->first = 1;
  IIScInsert(freeobjtoextra, (int)o, (int)fe);
  o->wantkey = FL_KEY_ALL;
  return o;
}

void mfl_set_text_clipping(FL_Coord x, FL_Coord y, FL_Coord w, FL_Coord h)
{
  fl_set_text_clipping(x, y, w, h);
}

void mfl_unset_text_clipping()
{
  fl_unset_text_clipping();
}

int mfl_get_width(FL_OBJECT *obj)
{
  FL_Coord w, h, x, y;
  fl_get_object_geometry(obj, &x, &y, &w, &h);
  return w;
}
