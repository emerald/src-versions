/*
 * This file is automatically created from the files
 *
 *      xta.va and xma.va
 *
 * respectively.
 *
 * DO NOT EXPECT CHANGES TO BE SEEN IF NOT MADE IN THE .va FILES
 */

/*
 * The xsed program in the ccalls directory has been used to
 * compile the .va files into .c files.
 * See the xsed.c source file for more information.
 */

#include "xta.h"
#include "threads.h"


#define XTARGSSIZE 100
#define EMSTRINGARGTYPE 0
#define EMINTARGTYPE 1

Display *mXtOpenDisplay(XtAppContext appContext, String n, String o)
{
  int one = 1;
  char *arg = "foo";
  return XtOpenDisplay(appContext, "", n, o, NULL, 0, &one, &arg);
}

Widget mXtAppCreateShell(String n, String m, int x, Display *d, Arg *args, int nargs)
{
  return XtAppCreateShell(n, m, applicationShellWidgetClass, d, args, nargs);
}

Widget mXtVaAppInitialize(char *name)
{
  static XtAppContext app;
  int zero = 0;
  static int which = 0;
  if (which == 0) {
    which = 1;
    return XtVaAppInitialize(&app, name, NULL, 0, &zero, NULL, NULL, NULL);
  } else {
    which = 0;
    return (Widget)app;
  }
}

static semaphore up, down;
static Widget cb_widget;
static XtPointer cb_client_data, cb_call_data;

int mXtRetrieveCallback(void)
{
  static int which = 0;
  switch(which) {
  case 0:
    MTSemP(&up);
    which = 1;
    return (int)cb_widget;
  case 1:
    which = 2;
    return (int)cb_client_data;
  case 2:
    which = 3;
    return (int)cb_call_data;
  case 3:
    which = 0;
    MTSemV(&down);
    return 0;
  }
}
  
void mXtCallbackHelper(Widget widget, XtPointer client_d, XtPointer call_d)
{
  cb_widget = widget;
  cb_client_data = client_d;
  cb_call_data = call_d;
  MTSemV(&up);
  MTSemP(&down);
}

void mXtAddCallback(Widget w, String name, XtPointer client_d)
{
  XtAddCallback(w, name, mXtCallbackHelper, client_d);
}

struct {
  int argtype;
  char *thearg;
} _mxtlocal[XTARGSSIZE];

char* _mxtargs[XTARGSSIZE];

void mXtSetArgInt(int i,int value)
{
  if ((i>=0) || (i<=(XTARGSSIZE-1))) {
    _mxtlocal[i].argtype= EMINTARGTYPE;
    _mxtlocal[i].thearg= (char*) value;
  }
  else
    exit(1001); /* Out of index bound in function call. */
}

void mXtSetArgString(int i,char * value)
{
  if ((i>=0) || (i<=(XTARGSSIZE-1))) {
    _mxtlocal[i].argtype= EMSTRINGARGTYPE;
    _mxtlocal[i].thearg = value;
  }
  else
    exit(1002); /* Out of index bound in function call. */
}

void mXtClearArg(int i)
{
  /* Not needed in the current implementation, but it might be needed
     later. */
  int j=0;

  while (j<i) {
    if (_mxtlocal[j].argtype == EMSTRINGARGTYPE)
      vmFree(_mxtlocal[j].thearg);
    j++;
  }
}

Widget mXtVaCreateManagedWidget(char * name, int widget_class,
                                int parent, int index)
{
  ARGSSETUP(index);
  switch (widget_class) {
  case 0 :
    return XtVaCreateManagedWidget(name, (WidgetClass) xmPushButtonWidgetClass, (Widget) parent, 
	_mxtargs[0],
	_mxtargs[1],
	_mxtargs[2],
	_mxtargs[3],
	_mxtargs[4],
	_mxtargs[5],
	_mxtargs[6],
	_mxtargs[7],
	_mxtargs[8],
	_mxtargs[9],
	_mxtargs[10],
	_mxtargs[11],
	_mxtargs[12],
	_mxtargs[13],
	_mxtargs[14],
	_mxtargs[15],
	_mxtargs[16],
	_mxtargs[17],
	_mxtargs[18],
	_mxtargs[19],
	_mxtargs[20],
	_mxtargs[21],
	_mxtargs[22],
	_mxtargs[23],
	_mxtargs[24],
	_mxtargs[25],
	_mxtargs[26],
	_mxtargs[27],
	_mxtargs[28],
	_mxtargs[29],
	_mxtargs[30],
	_mxtargs[31],
	_mxtargs[32],
	_mxtargs[33],
	_mxtargs[34],
	_mxtargs[35],
	_mxtargs[36],
	_mxtargs[37],
	_mxtargs[38],
	_mxtargs[39],
	_mxtargs[40],
	_mxtargs[41],
	_mxtargs[42],
	_mxtargs[43],
	_mxtargs[44],
	_mxtargs[45],
	_mxtargs[46],
	_mxtargs[47],
	_mxtargs[48],
	_mxtargs[49],
	_mxtargs[50],
	_mxtargs[51],
	_mxtargs[52],
	_mxtargs[53],
	_mxtargs[54],
	_mxtargs[55],
	_mxtargs[56],
	_mxtargs[57],
	_mxtargs[58],
	_mxtargs[59],
	_mxtargs[60],
	_mxtargs[61],
	_mxtargs[62],
	_mxtargs[63],
	_mxtargs[64],
	_mxtargs[65],
	_mxtargs[66],
	_mxtargs[67],
	_mxtargs[68],
	_mxtargs[69],
	_mxtargs[70],
	_mxtargs[71],
	_mxtargs[72],
	_mxtargs[73],
	_mxtargs[74],
	_mxtargs[75],
	_mxtargs[76],
	_mxtargs[77],
	_mxtargs[78],
	_mxtargs[79],
	_mxtargs[80],
	_mxtargs[81],
	_mxtargs[82],
	_mxtargs[83],
	_mxtargs[84],
	_mxtargs[85],
	_mxtargs[86],
	_mxtargs[87],
	_mxtargs[88],
	_mxtargs[89],
	_mxtargs[90],
	_mxtargs[91],
	_mxtargs[92],
	_mxtargs[93],
	_mxtargs[94],
	_mxtargs[95],
	_mxtargs[96],
	_mxtargs[97],
	_mxtargs[98],
	_mxtargs[99]);
    break;
  case 1 : 
    return XtVaCreateManagedWidget(name, (WidgetClass) xmMainWindowWidgetClass, (Widget) parent, 
	_mxtargs[0],
	_mxtargs[1],
	_mxtargs[2],
	_mxtargs[3],
	_mxtargs[4],
	_mxtargs[5],
	_mxtargs[6],
	_mxtargs[7],
	_mxtargs[8],
	_mxtargs[9],
	_mxtargs[10],
	_mxtargs[11],
	_mxtargs[12],
	_mxtargs[13],
	_mxtargs[14],
	_mxtargs[15],
	_mxtargs[16],
	_mxtargs[17],
	_mxtargs[18],
	_mxtargs[19],
	_mxtargs[20],
	_mxtargs[21],
	_mxtargs[22],
	_mxtargs[23],
	_mxtargs[24],
	_mxtargs[25],
	_mxtargs[26],
	_mxtargs[27],
	_mxtargs[28],
	_mxtargs[29],
	_mxtargs[30],
	_mxtargs[31],
	_mxtargs[32],
	_mxtargs[33],
	_mxtargs[34],
	_mxtargs[35],
	_mxtargs[36],
	_mxtargs[37],
	_mxtargs[38],
	_mxtargs[39],
	_mxtargs[40],
	_mxtargs[41],
	_mxtargs[42],
	_mxtargs[43],
	_mxtargs[44],
	_mxtargs[45],
	_mxtargs[46],
	_mxtargs[47],
	_mxtargs[48],
	_mxtargs[49],
	_mxtargs[50],
	_mxtargs[51],
	_mxtargs[52],
	_mxtargs[53],
	_mxtargs[54],
	_mxtargs[55],
	_mxtargs[56],
	_mxtargs[57],
	_mxtargs[58],
	_mxtargs[59],
	_mxtargs[60],
	_mxtargs[61],
	_mxtargs[62],
	_mxtargs[63],
	_mxtargs[64],
	_mxtargs[65],
	_mxtargs[66],
	_mxtargs[67],
	_mxtargs[68],
	_mxtargs[69],
	_mxtargs[70],
	_mxtargs[71],
	_mxtargs[72],
	_mxtargs[73],
	_mxtargs[74],
	_mxtargs[75],
	_mxtargs[76],
	_mxtargs[77],
	_mxtargs[78],
	_mxtargs[79],
	_mxtargs[80],
	_mxtargs[81],
	_mxtargs[82],
	_mxtargs[83],
	_mxtargs[84],
	_mxtargs[85],
	_mxtargs[86],
	_mxtargs[87],
	_mxtargs[88],
	_mxtargs[89],
	_mxtargs[90],
	_mxtargs[91],
	_mxtargs[92],
	_mxtargs[93],
	_mxtargs[94],
	_mxtargs[95],
	_mxtargs[96],
	_mxtargs[97],
	_mxtargs[98],
	_mxtargs[99]);
    break;
  }
}
