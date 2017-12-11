/*
 * The Emerald Distributed Programming Language
 * 
 * Copyright (C) 2004 Emerald Authors & Contributors
 * 
 * This file is part of the Emerald Distributed Programming Language.
 *
 * The Emerald Distributed Programming Language is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 *  The Emerald Distributed Programming Language is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the Emerald Distributed Programming Language; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */
#include "xforms.h"
#include "iisc.h"
#include "assert.h"
#include "dist.h"

IISc freeobjtoextra;

Display *mfl_get_display(void)
{
  return fl_get_display();
}

int mfl_errorhandler(Display *display, XErrorEvent *ev)
{
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
    fl_initialize(&argc, &arg, progname, 0, 0);
    XSetErrorHandler(mfl_errorhandler);
  }
}

void mfl_add_chart_value(FL_OBJECT * obj, float val, char *text, int col)
{
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
  assert (!IIScIsNIL(fe));
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

FL_OBJECT *mfl_create_free(int type, FL_Coord x, FL_Coord y, FL_Coord w,
			  FL_Coord h, const char *label)
{
  FL_OBJECT *o;
  freeextra *fe;
  o = fl_create_free(type, x, y, w, h, label, mfl_free_handler);
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
