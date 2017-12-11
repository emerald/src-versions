const FL_VERSION <- 0		export FL_VERSION
const FL_REVISION <- 81		export FL_REVISION
const FL_FIXLEVEL <- 0		export FL_FIXLEVEL
const FL_INCLUDE_VERSION <- 81	export FL_INCLUDE_VERSION

const FL_ON <- 1		export FL_ON
const FL_OK <- 1		export FL_OK
const FL_VALID <- 1		export FL_VALID
const FL_PREEMPT <- 1		export FL_PREEMPT
const FL_ALWAYS_ON <- 2		export FL_ALWAYS_ON

const FL_OFF <- 0		export FL_OFF
const FL_NONE <- 0		export FL_NONE
const FL_CANCEL <- 0		export FL_CANCEL
const FL_INVALID <- 0		export FL_INVALID

const FL_IGNORE <- -1		export FL_IGNORE


const FL_COLOR <- Integer	export FL_COLOR


const FL_COORD_PIXEL <- 0	export FL_COORD_PIXEL
const FL_COORD_MM <- 1		export FL_COORD_MM
const FL_COORD_POINT <- 2	export FL_COORD_POINT
const FL_COORD_centiMM <- 3	export FL_COORD_centiMM
const FL_COORD_centiPOINT <- 4	export FL_COORD_centiPOINT

const FL_INVALID_CLASS <- 1	export FL_INVALID_CLASS
const FL_BUTTON <- 2		export FL_BUTTON
const FL_LIGHTBUTTON <- 3	export FL_LIGHTBUTTON
const FL_ROUNDBUTTON <- 4	export FL_ROUNDBUTTON
const FL_CHECKBUTTON <- 5	export FL_CHECKBUTTON
const FL_BITMAPBUTTON <- 6	export FL_BITMAPBUTTON
const FL_PIXMAPBUTTON <- 7	export FL_PIXMAPBUTTON
const FL_BITMAP <- 8		export FL_BITMAP
const FL_PIXMAP <- 9		export FL_PIXMAP
const FL_BOX <- 10		export FL_BOX
const FL_TEXT <- 11		export FL_TEXT
const FL_MENU <- 12		export FL_MENU
const FL_CHART <- 13		export FL_CHART
const FL_CHOICE <- 14		export FL_CHOICE
const FL_COUNTER <- 15		export FL_COUNTER
const FL_SLIDER <- 16		export FL_SLIDER
const FL_VALSLIDER <- 17	export FL_VALSLIDER
const FL_INPUT <- 18		export FL_INPUT
const FL_BROWSER <- 19		export FL_BROWSER
const FL_DIAL <- 20		export FL_DIAL
const FL_TIMER <- 21		export FL_TIMER
const FL_CLOCK <- 22		export FL_CLOCK
const FL_POSITIONER <- 23	export FL_POSITIONER
const FL_FREE <- 24		export FL_FREE
const FL_XYPLOT <- 25		export FL_XYPLOT
const FL_FOLDERTAB <- 26		export FL_FOLDERTAB
const FL_CANVAS <- 27		export FL_CANVAS
const FL_FRAME <- 28		export FL_FRAME
const FL_GLCANVAS <- 29		export FL_GLCANVAS

const FL_PLACE_FREE <- 0	export FL_PLACE_FREE
const FL_PLACE_MOUSE <- 1	export FL_PLACE_MOUSE
const FL_PLACE_CENTER <- 2	export FL_PLACE_CENTER
const FL_PLACE_POSITION <- 4	export FL_PLACE_POSITION
const FL_PLACE_SIZE <- 8	export FL_PLACE_SIZE
const FL_PLACE_GEOMETRY <- 16	export FL_PLACE_GEOMETRY
const FL_PLACE_ASPECT <- 32	export FL_PLACE_ASPECT
const FL_PLACE_FULLSCREEN <- 64	export FL_PLACE_FULLSCREEN
const FL_PLACE_HOTSPOT <- 128	export FL_PLACE_HOTSPOT
const FL_PLACE_ICONIC <- 256	export FL_PLACE_ICONIC

const FL_FREE_SIZE <- 0x4000	export FL_FREE_SIZE
const FL_FIX_SIZE <- 0x8000	export FL_FIX_SIZE


const FL_PLACE_FREE_CENTER <- 0x4002	export FL_PLACE_FREE_CENTER
const FL_PLACE_CENTERFREE <-  0x4002	export FL_PLACE_CENTERFREE


const FL_TRANSIENT <- -1	export FL_TRANSIENT
const FL_NOBORDER <- 0		export FL_NOBORDER
const FL_FULLBORDER <- 1	export FL_FULLBORDER


% All box types
const FL_NO_BOX <- 0		export FL_NO_BOX
const FL_UP_BOX <- 1		export FL_UP_BOX
const FL_DOWN_BOX <- 2		export FL_DOWN_BOX
const FL_BORDER_BOX <- 3	export FL_BORDER_BOX
const FL_SHADOW_BOX <- 4	export FL_SHADOW_BOX
const FL_FRAME_BOX <- 5		export FL_FRAME_BOX
const FL_ROUNDED_BOX <- 6	export FL_ROUNDED_BOX
const FL_EMBOSSED_BOX <- 7	export FL_EMBOSSED_BOX
const FL_FLAT_BOX <- 8		export FL_FLAT_BOX
const FL_RFLAT_BOX <- 9		export FL_RFLAT_BOX
const FL_RSHADOW_BOX <- 10	export FL_RSHADOW_BOX
const FL_OVAL_BOX <- 11		export FL_OVAL_BOX
const FL_OSHADOW_BOX <- 12	export FL_OSHADOW_BOX

% How to place text relative to a box

const FL_ALIGN_CENTER <- 0	export FL_ALIGN_CENTER
const FL_ALIGN_TOP <- 1		export FL_ALIGN_TOP
const FL_ALIGN_BOTTOM <- 2	export FL_ALIGN_BOTTOM
const FL_ALIGN_LEFT <- 4	export FL_ALIGN_LEFT
const FL_ALIGN_RIGHT <- 8	export FL_ALIGN_RIGHT
const FL_ALIGN_TOP_LEFT <- 5	export FL_ALIGN_TOP_LEFT
const FL_ALIGN_TOP_RIGHT <- 9	export FL_ALIGN_TOP_RIGHT
const FL_ALIGN_BOTTOM_LEFT <- 6	export FL_ALIGN_BOTTOM_LEFT
const FL_ALIGN_BOTTOM_RIGHT <- 10	export FL_ALIGN_BOTTOM_RIGHT
const FL_ALIGN_INSIDE <- 0x2000	export FL_ALIGN_INSIDE
const FL_ALIGN_VERT <- 0x4000	export FL_ALIGN_VERT

const FL_ALIGN_LEFT_TOP <- FL_ALIGN_TOP_LEFT	export FL_ALIGN_LEFT_TOP
const FL_ALIGN_RIGHT_TOP <- FL_ALIGN_TOP_RIGHT	export FL_ALIGN_RIGHT_TOP
const FL_ALIGN_LEFT_BOTTOM <- FL_ALIGN_BOTTOM_LEFT	export FL_ALIGN_LEFT_BOTTOM
const FL_ALIGN_RIGHT_BOTTOM <- FL_ALIGN_BOTTOM_RIGHT	export FL_ALIGN_RIGHT_BOTTOM


% control when to return input, slider and dial object.

const FL_RETURN_END_CHANGED <- 0	export FL_RETURN_END_CHANGED
const FL_RETURN_CHANGED <- 1	export FL_RETURN_CHANGED
const FL_RETURN_END <- 2	export FL_RETURN_END
const FL_RETURN_ALWAYS <- 3	export FL_RETURN_ALWAYS
const FL_RETURN_DBLCLICK <- 4	export FL_RETURN_DBLCLICK

% Some special color indeces for FL private colormap. It does not matter
% what the value of each enum is, but it must start from 0 and be
% consecutive.

const FL_BLACK <- 0		export FL_BLACK
const FL_RED <- 1		export FL_RED
const FL_GREEN <- 2		export FL_GREEN
const FL_YELLOW <- 3		export FL_YELLOW
const FL_BLUE <- 4		export FL_BLUE
const FL_MAGENTA <- 5		export FL_MAGENTA
const FL_CYAN <- 6		export FL_CYAN
const FL_WHITE <- 7		export FL_WHITE

const FL_TOMATO <- 8		export FL_TOMATO
const FL_INDIANRED <- 9		export FL_INDIANRED
const FL_SLATEBLUE <- 10	export FL_SLATEBLUE

const FL_COL1 <- 11	export FL_COL1
const FL_RIGHT_BCOL <- 12	export FL_RIGHT_BCOL
const FL_BOTTOM_BCOL <- 13	export FL_BOTTOM_BCOL
const FL_TOP_BCOL <- 14		export FL_TOP_BCOL
const FL_LEFT_BCOL <- 15	export FL_LEFT_BCOL
const FL_MCOL <- 16		export FL_MCOL

const FL_INACTIVE <- 17		export FL_INACTIVE
const FL_PALEGREEN <- 18	export FL_PALEGREEN
const FL_DARKGOLD <- 19		export FL_DARKGOLD

const FL_ORCHID <- 20		export FL_ORCHID
const FL_DARKCYAN <- 21		export FL_DARKCYAN
const FL_DARKTOMATO <- 22	export FL_DARKTOMATO
const FL_WHEAT <- 23		export FL_WHEAT
const FL_DARKORANGE <- 24	export FL_DARKORANGE
const FL_DEEPPINK <- 25		export FL_DEEPPINK
const FL_CHARTREUSE <- 26	export FL_CHARTREUSE
const FL_DARKVIOLET <- 27	export FL_DARKVIOLET
const FL_SPRINGGREEN <- 28	export FL_SPRINGGREEN
const FL_DOGERBLUE <- 29	export FL_DOGERBLUE

const FL_FREE_COL1 <- 256	export FL_FREE_COL1
const FL_FREE_COL2 <- 257	export FL_FREE_COL2
const FL_FREE_COL3 <- 258	export FL_FREE_COL3
const FL_FREE_COL4 <- 259	export FL_FREE_COL4
const FL_FREE_COL5 <- 260	export FL_FREE_COL5
const FL_FREE_COL6 <- 261	export FL_FREE_COL6
const FL_FREE_COL7 <- 262	export FL_FREE_COL7
const FL_FREE_COL8 <- 263	export FL_FREE_COL8
const FL_FREE_COL9 <- 264	export FL_FREE_COL9
const FL_FREE_COL10 <- 265	export FL_FREE_COL10
const FL_FREE_COL11 <- 266	export FL_FREE_COL11
const FL_FREE_COL12 <- 267	export FL_FREE_COL12
const FL_FREE_COL13 <- 268	export FL_FREE_COL13
const FL_FREE_COL14 <- 269	export FL_FREE_COL14
const FL_FREE_COL15 <- 270	export FL_FREE_COL15
const FL_FREE_COL16 <- 271	export FL_FREE_COL16

const FL_BUILT_IN_COLS <-  30	export FL_BUILT_IN_COLS
const FL_INACTIVE_COL <-   FL_INACTIVE	export FL_INACTIVE_COL

% Some aliases for the color. This is actually backwards ...

const FL_GRAY16 <-           FL_RIGHT_BCOL	export FL_GRAY16
const FL_GRAY35 <-           FL_BOTTOM_BCOL	export FL_GRAY35
const FL_GRAY80 <-           FL_TOP_BCOL	export FL_GRAY80
const FL_GRAY90 <-           FL_LEFT_BCOL	export FL_GRAY90
const FL_GRAY63 <-           FL_COL1	export FL_GRAY63
const FL_GRAY75 <-           FL_MCOL	export FL_GRAY75

const  FL_LCOL <-            FL_BLACK	export  FL_LCOL

%  Pop-up menu item attributes. NOTE if more than 8, need to change
%  choice and menu class where mode is kept by a single byte

const FL_PUP_NONE <- 0	export FL_PUP_NONE
const FL_PUP_GREY <- 1	export FL_PUP_GREY
const FL_PUP_BOX <- 2	export FL_PUP_BOX
const FL_PUP_CHECK <- 4	export FL_PUP_CHECK
const FL_PUP_RADIO <- 8	export FL_PUP_RADIO

const FL_PUP_GRAY <-   FL_PUP_GREY	export FL_PUP_GRAY
const FL_PUP_TOGGLE <- FL_PUP_BOX	export FL_PUP_TOGGLE
const FL_PUP_INACTIVE <- FL_PUP_GREY	export FL_PUP_INACTIVE


% Events that a form reacts to.

const FL_NOEVENT <- 0	export FL_NOEVENT
const FL_DRAW <- 1	export FL_DRAW
const FL_PUSH <- 2	export FL_PUSH
const FL_RELEASE <- 3	export FL_RELEASE
const FL_ENTER <- 4	export FL_ENTER
const FL_LEAVE <- 5	export FL_LEAVE
const FL_MOUSE <- 6	export FL_MOUSE
const FL_FOCUS <- 7	export FL_FOCUS
const FL_UNFOCUS <- 8	export FL_UNFOCUS
const FL_KEYBOARD <- 9	export FL_KEYBOARD
const FL_MOTION <- 10	export FL_MOTION
const FL_STEP <- 11	export FL_STEP
const FL_SHORTCUT <- 12	export FL_SHORTCUT
const FL_FREEMEM <- 13	export FL_FREEMEM
const FL_OTHER <- 14	export FL_OTHER
const FL_DRAWLABEL <- 15	export FL_DRAWLABEL
const FL_DBLCLICK <- 16	export FL_DBLCLICK
const FL_TRPLCLICK <- 17	export FL_TRPLCLICK
const FL_PS <- 18	export FL_PS


const FL_MOVE <-   FL_MOTION	% for compatibility	export FL_MOVE

const FL_RESIZE_NONE <- 0	export FL_RESIZE_NONE
const FL_RESIZE_X <- 1	export FL_RESIZE_X
const FL_RESIZE_Y <- 2	export FL_RESIZE_Y

const FL_RESIZE_ALL <-  3	export FL_RESIZE_ALL

% Keyboard focus control

const FL_KEY_NORMAL <- 1	export FL_KEY_NORMAL
const FL_KEY_TAB <- 2	export FL_KEY_TAB
const FL_KEY_SPECIAL <- 4	export FL_KEY_SPECIAL
const FL_KEY_ALL <- 7	export FL_KEY_ALL

const FL_ALT_VAL <-   0x20000	export FL_ALT_VAL

%*******************************************************************
%* FONTS
%******************************************************************/

const FL_MAXFONTS <-     32	% max number of fonts	export FL_MAXFONTS

const FL_INVALID_STYLE <- -1	export FL_INVALID_STYLE
const FL_NORMAL_STYLE <- 0	export FL_NORMAL_STYLE
const FL_BOLD_STYLE <- 1	export FL_BOLD_STYLE
const FL_ITALIC_STYLE <- 2	export FL_ITALIC_STYLE
const FL_BOLDITALIC_STYLE <- 3	export FL_BOLDITALIC_STYLE

const FL_FIXED_STYLE <- 4	export FL_FIXED_STYLE
const FL_FIXEDBOLD_STYLE <- 5	export FL_FIXEDBOLD_STYLE
const FL_FIXEDITALIC_STYLE <- 6	export FL_FIXEDITALIC_STYLE
const FL_FIXEDBOLDITALIC_STYLE <- 7	export FL_FIXEDBOLDITALIC_STYLE

const FL_TIMES_STYLE <- 8	export FL_TIMES_STYLE
const FL_TIMESBOLD_STYLE <- 9	export FL_TIMESBOLD_STYLE
const FL_TIMESITALIC_STYLE <- 10	export FL_TIMESITALIC_STYLE
const FL_TIMESBOLDITALIC_STYLE <- 11	export FL_TIMESBOLDITALIC_STYLE

const FL_SHADOW_STYLE <- 0x20000	export FL_SHADOW_STYLE
const FL_ENGRAVED_STYLE <- 0x40000	export FL_ENGRAVED_STYLE
const FL_EMBOSSED_STYLE <- 0x80000	export FL_EMBOSSED_STYLE


% Standard sizes in XForms */
const FL_TINY_SIZE <-       8	export FL_TINY_SIZE
const FL_SMALL_SIZE <-      10	export FL_SMALL_SIZE
const FL_NORMAL_SIZE <-     12	export FL_NORMAL_SIZE
const FL_MEDIUM_SIZE <-     14	export FL_MEDIUM_SIZE
const FL_LARGE_SIZE <-      18	export FL_LARGE_SIZE
const FL_HUGE_SIZE <-       24	export FL_HUGE_SIZE

const FL_DEFAULT_SIZE <-   FL_SMALL_SIZE	export FL_DEFAULT_SIZE

% Defines for compatibility */
const FL_TINY_FONT <-    FL_TINY_SIZE	export FL_TINY_FONT
const FL_SMALL_FONT <-   FL_SMALL_SIZE	export FL_SMALL_FONT
const FL_NORMAL_FONT <-  FL_NORMAL_SIZE	export FL_NORMAL_FONT
const FL_MEDIUM_FONT <-  FL_MEDIUM_SIZE	export FL_MEDIUM_FONT
const FL_LARGE_FONT <-   FL_LARGE_SIZE	export FL_LARGE_FONT
const FL_HUGE_FONT <-    FL_HUGE_SIZE	export FL_HUGE_FONT

const FL_NORMAL_FONT1 <-   FL_SMALL_FONT	export FL_NORMAL_FONT1
const FL_NORMAL_FONT2 <-   FL_NORMAL_FONT	export FL_NORMAL_FONT2
const FL_DEFAULT_FONT <-   FL_SMALL_FONT	export FL_DEFAULT_FONT


const FL_BOUND_WIDTH <-    3	export FL_BOUND_WIDTH


const FL_BEGIN_GROUP <-    10000	export FL_BEGIN_GROUP
const FL_END_GROUP <-      20000	export FL_END_GROUP


const  FL_CLICK_TIMEOUT <-  350	export  FL_CLICK_TIMEOUT

% callback function for an entire form 
%typedef void (*FL_FORMCALLBACKPTR) (struct flobjs_ *, void *);

% object callback function      
%typedef void (*FL_CALLBACKPTR) (FL_OBJECT *, long);

% preemptive callback function  
%typedef int (*FL_RAW_CALLBACK) (struct forms_ *, void *);

% at close (WM menu delete/close etc.) 
%typedef int (*FL_FORM_ATCLOSE) (struct forms_ *, void *);

% deactivate/activate callback 
%typedef void (*FL_FORM_ATDEACTIVATE) (struct forms_ *, void *);
%typedef void (*FL_FORM_ATACTIVATE) (struct forms_ *, void *);

%typedef int (*FL_HANDLEPTR) (FL_OBJECT *, int, FL_Coord, FL_Coord, int, void *);

const FL_READ <- 1	export FL_READ
const FL_WRITE <- 2	export FL_WRITE
const FL_EXCEPT <- 4	export FL_EXCEPT

% IO other than XEvent Q 
%typedef void (*FL_IO_CALLBACK) (int, void *);
%extern void fl_add_io_callback(int, unsigned, FL_IO_CALLBACK, void *);
%extern void fl_remove_io_callback(int, unsigned, FL_IO_CALLBACK);

% signals 

%typedef void (*FL_SIGNAL_HANDLER) (int, void *);
%extern void fl_add_signal_callback(int, FL_SIGNAL_HANDLER, void *);
%extern void fl_remove_signal_callback(int);
%extern void fl_signal_caught(int);
%extern void fl_app_signal_direct(int);

%
% *  Basic public routine prototypes
 

%extern int fl_library_version(int *, int *);

%* Generic routines that deal with FORMS *

%extern FL_FORM *fl_bgn_form(int, FL_Coord, FL_Coord);
%extern void fl_end_form(void);
%extern FL_OBJECT *fl_do_forms(void);
%extern FL_OBJECT *fl_check_forms(void);
%extern FL_OBJECT *fl_do_only_forms(void);
%extern FL_OBJECT *fl_check_only_forms(void);
%extern void fl_freeze_form(FL_FORM *);

%extern void fl_set_focus_object(FL_FORM *, FL_OBJECT *);
%#define fl_set_object_focus   fl_set_focus_object

%extern FL_FORM_ATCLOSE fl_set_form_atclose(FL_FORM *, FL_FORM_ATCLOSE, void *);
%extern FL_FORM_ATCLOSE fl_set_atclose(FL_FORM_ATCLOSE, void *);

%extern FL_FORM_ATACTIVATE fl_set_form_atactivate(FL_FORM *,
%						 FL_FORM_ATACTIVATE, void *);
%extern FL_FORM_ATDEACTIVATE fl_set_form_atdeactivate(FL_FORM *,
%					      FL_FORM_ATDEACTIVATE, void *);

%extern void fl_unfreeze_form(FL_FORM *);
%extern void fl_deactivate_form(FL_FORM *);
%extern void fl_activate_form(FL_FORM *);
%extern void fl_deactivate_all_forms(void);
%extern void fl_activate_all_forms(void);
%extern void fl_freeze_all_forms(void);
%extern void fl_unfreeze_all_forms(void);
%extern void fl_scale_form(FL_FORM *, double, double);
%extern void fl_set_form_position(FL_FORM *, FL_Coord, FL_Coord);
%extern void fl_set_form_title(FL_FORM *, const char *);

%extern void fl_set_form_property(FL_FORM *, unsigned);
%extern void fl_set_app_mainform(FL_FORM *);
%extern FL_FORM *fl_get_app_mainform(void);
%extern void fl_set_app_nomainform(int);

%extern void fl_set_form_callback(FL_FORM *, FL_FORMCALLBACKPTR, void *);
%#define  fl_set_form_call_back    fl_set_form_callback

%extern void fl_set_form_size(FL_FORM *, FL_Coord, FL_Coord);
%extern void fl_set_form_hotspot(FL_FORM *, FL_Coord, FL_Coord);
%extern void fl_set_form_hotobject(FL_FORM *, FL_OBJECT *);
%extern void fl_set_form_minsize(FL_FORM *, FL_Coord, FL_Coord);
%extern void fl_set_form_maxsize(FL_FORM *, FL_Coord, FL_Coord);
%extern void fl_set_form_event_cmask(FL_FORM *, unsigned long);
%extern unsigned long fl_get_form_event_cmask(FL_FORM *);

%extern void fl_set_form_geometry(FL_FORM *, FL_Coord, FL_Coord,
%				 FL_Coord, FL_Coord);

%#define fl_set_initial_placement fl_set_form_geometry

%extern long fl_show_form(FL_FORM *, int, int, const char *);
%extern void fl_hide_form(FL_FORM *);
%extern void fl_free_form(FL_FORM *);
%extern void fl_redraw_form(FL_FORM *);
%extern void fl_set_form_dblbuffer(FL_FORM *, int);
%extern long fl_prepare_form_window(FL_FORM *, int, int, const char *);
%extern long fl_show_form_window(FL_FORM *);

%extern FL_RAW_CALLBACK fl_register_raw_callback(FL_FORM *, unsigned long,
%						FL_RAW_CALLBACK);

%#define fl_register_call_back fl_register_raw_callback

%extern FL_OBJECT *fl_bgn_group(void);
%extern FL_OBJECT *fl_end_group(void);
%extern void fl_addto_group(FL_OBJECT *);

%***** Routines that deal with FL_OBJECTS *******

%extern void fl_set_object_boxtype(FL_OBJECT *, int);
%extern void fl_set_object_bw(FL_OBJECT *, int);
%extern void fl_set_object_resize(FL_OBJECT *, unsigned);
%extern void fl_set_object_gravity(FL_OBJECT *, unsigned, unsigned);
%extern void fl_set_object_lsize(FL_OBJECT *, int);
%extern void fl_set_object_lstyle(FL_OBJECT *, int);
%extern void fl_set_object_lcol(FL_OBJECT *, FL_COLOR);
%extern void fl_set_object_return(FL_OBJECT *, int);
%extern void fl_set_object_lalign(FL_OBJECT *, int);	% to be removed 
%extern void fl_set_object_shortcut(FL_OBJECT *, const char *, int);
%extern void fl_set_object_shortcutkey(FL_OBJECT *, unsigned int);
%extern void fl_set_object_dblbuffer(FL_OBJECT *, int);
%extern void fl_set_object_color(FL_OBJECT *, FL_COLOR, FL_COLOR);
%extern void fl_set_object_label(FL_OBJECT *, const char *);
%extern void fl_set_object_position(FL_OBJECT *, FL_Coord, FL_Coord);
%extern void fl_set_object_size(FL_OBJECT *, FL_Coord, FL_Coord);
%extern void fl_set_object_automatic(FL_OBJECT *, int);
%extern void fl_draw_object_label(FL_OBJECT *);
%#define  fl_set_object_dblclick(ob, timeout)  (ob)->click_timeout = (timeout);
%extern void fl_set_object_geometry(FL_OBJECT *, FL_Coord, FL_Coord,
%				   FL_Coord, FL_Coord);


%extern void fl_fit_object_label(FL_OBJECT *, FL_Coord, FL_Coord);

% no much get (yet ?) 
%extern void fl_get_object_geometry(FL_OBJECT * ob, FL_Coord *, FL_Coord *,
%				   FL_Coord *, FL_Coord *);

%extern void fl_get_object_position(FL_OBJECT *, FL_Coord *, FL_Coord *);

% this one takes into account the label 
%extern void fl_compute_object_geometry(FL_OBJECT *, FL_Coord *, FL_Coord *,
%				       FL_Coord *, FL_Coord *);

%extern void fl_call_object_callback(FL_OBJECT *);
%extern FL_HANDLEPTR fl_set_object_prehandler(FL_OBJECT *, FL_HANDLEPTR);
%extern FL_HANDLEPTR fl_set_object_posthandler(FL_OBJECT *, FL_HANDLEPTR);
%extern FL_CALLBACKPTR fl_set_object_callback(FL_OBJECT *, FL_CALLBACKPTR, long);

%#define fl_set_object_align   fl_set_object_lalign
%#define fl_set_call_back      fl_set_object_callback

%extern void fl_redraw_object(FL_OBJECT *);
%extern void fl_scale_object(FL_OBJECT *, double, double);
%extern void fl_show_object(FL_OBJECT *);
%extern void fl_hide_object(FL_OBJECT *);
%extern void fl_free_object(FL_OBJECT *);
%extern void fl_delete_object(FL_OBJECT *);
%extern void fl_trigger_object(FL_OBJECT *);
%extern void fl_activate_object(FL_OBJECT *);
%extern void fl_deactivate_object(FL_OBJECT *);

%extern int fl_enumerate_fonts(void (*)(const char *s), int);
%extern void fl_set_font_name(int, const char *);
%extern void fl_set_font(int, int);

% routines that facilitate free object 

%extern int fl_get_char_height(int, int, int *, int *);
%extern int fl_get_char_width(int, int);
%extern int fl_get_string_height(int, int, const char *, int, int *, int *);
%extern int fl_get_string_width(int, int, const char *, int);
%extern int fl_get_string_widthTAB(int, int, const char *, int);
%extern void fl_get_string_dimension(int, int, const char *, int, int *, int *);

%#define fl_get_string_size  fl_get_string_dimension

%extern void fl_get_align_xy(int, int, int, int, int, int, int,
%			    int, int, int *, int *);

%extern void fl_drw_text(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			FL_COLOR, int, int, char *);

%extern void fl_drw_text_beside(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			       FL_COLOR, int, int, char *);

%#define fl_draw_text(a,x,y,w,h,c,st,sz,s)    \
%      (((a) & FL_ALIGN_INSIDE) ? fl_drw_text:fl_drw_text_beside)\
%      (a,x,y,w,h,c,st,sz,s)

%extern void fl_drw_text_cursor(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			       int, int, int, char *, int, int);

%extern void fl_drw_box(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%		       FL_COLOR, int);

%typedef void (*FL_DRAWPTR) (FL_Coord x, FL_Coord y, FL_Coord w, FL_Coord h,
%			    int, FL_COLOR);
%extern int fl_add_symbol(const char *, FL_DRAWPTR, int);
%extern int fl_draw_symbol(const char *, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			  FL_COLOR);

%extern unsigned long fl_mapcolor(FL_COLOR, int, int, int);
%extern long fl_mapcolorname(FL_COLOR, const char *);
%#define fl_mapcolor_name  fl_mapcolorname

%extern unsigned long fl_getmcolor(FL_COLOR, int *, int *, int *);
%extern void fl_free_colors(FL_COLOR *, int);
%extern void fl_free_pixels(unsigned long *, int);
%extern void fl_set_color_leak(int);
%extern unsigned long fl_get_pixel(FL_COLOR);
%#define fl_get_flcolor   fl_get_pixel

%extern void fl_get_icm_color(FL_COLOR, int *, int *, int *);
%extern void fl_set_icm_color(FL_COLOR, int, int, int);

%extern void fl_color(FL_COLOR);
%extern void fl_bk_color(FL_COLOR);
%extern void fl_textcolor(FL_COLOR);
%extern void fl_bk_textcolor(FL_COLOR);
%extern void fl_set_gamma(double, double, double);

%extern void fl_show_errors(int);

%typedef int (*FL_FSCB) (const char *, void *);
%
% utilities for new objects 
%extern FL_FORM *fl_current_form;
%extern void fl_add_object(FL_FORM *, FL_OBJECT *);
%extern void fl_addto_form(FL_FORM *);
%extern FL_OBJECT *fl_make_object(int, int, FL_Coord, FL_Coord,
%			    FL_Coord, FL_Coord, const char *, FL_HANDLEPTR);

%extern void fl_set_coordunit(int);
%extern int fl_get_coordunit(void);
%extern void fl_set_border_width(int);
%extern int fl_get_border_width(void);
%extern void fl_flip_yorigin(void);

% this gives more flexibility for future changes 

const FL_MINDEPTH <-  1	export FL_MINDEPTH

const FL_NoGravity <- 0	export FL_NoGravity
const FL_ForgetGravity <- 0	export FL_ForgetGravity
const FL_NorthWest <- 1	export FL_NorthWest
const FL_North <- 2	export FL_North
const FL_NorthEast <- 3	export FL_NorthEast
const FL_West <- 4	export FL_West
const FL_East <- 6	export FL_East
const FL_SouthWest <- 7	export FL_SouthWest
const FL_South <- 8	export FL_South
const FL_SouthEast <- 9	export FL_SouthEast

%#define FL_is_gray(v)  (v==GrayScale || v==StaticGray)
%#define FL_is_rgb(v)   (v==TrueColor || v==DirectColor)


const FL_MAX_COLS <-   1024	export FL_MAX_COLS

%**** Global variables *****

%extern Display *fl_display;
%extern int fl_screen;
%extern Window fl_root;		% root window                
%extern Window fl_vroot;		% virtual root window        
%extern int fl_scrh, fl_scrw;	% screen dimension in pixels 
%extern int fl_vmode;

% current version only runs in single visual mode 
%#define  fl_get_vclass()        fl_vmode
%#define  fl_get_form_vclass(a)  fl_vmode

%extern FL_State fl_state[];
%extern char *fl_ul_magic_char;
%extern int fl_mode_capable(int % mode  , int % warn  );

%#define fl_default_win()       (fl_state[fl_vmode].trailblazer)
%#define fl_default_window()    (fl_state[fl_vmode].trailblazer)

% fonts related 

% Some basic drawing routines
 

%typedef XPoint FL_POINT;

% rectangles 
%extern void fl_rectangle(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%extern void fl_rectbound(FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%#define fl_rectf(x,y,w,h,c)   fl_rectangle(1, x,y,w,h,c)
%#define fl_rect(x,y,w,h,c)    fl_rectangle(0, x,y,w,h,c)

% rectangle with rounded-corners 
%extern void fl_roundrectangle(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%#define fl_roundrectf(x,y,w,h,c) fl_roundrectangle(1,x,y,w,h,c)
%#define fl_roundrect(x,y,w,h,c) fl_roundrectangle(0,x,y,w,h,c)

% general polygon and polylines 
%extern void fl_polygon(int, FL_POINT *, int n, FL_COLOR);
%#define fl_polyf(p,n,c)  fl_polygon(1, p, n, c)
%#define fl_polyl(p,n,c)  fl_polygon(0, p, n, c)
%#define fl_polybound(p,n,c) do {fl_polyf(p,n,c);fl_polyl(p,n,FL_BLACK);}while(0)

%extern void fl_lines(FL_POINT *, int n, FL_COLOR);
%extern void fl_line(FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%#define fl_simple_line fl_line

%extern void fl_dashedlinestyle(const char *, int);
%extern void fl_drawmode(int);

%#define fl_diagline(x,y,w,h,c) fl_line(x,y,(x)+(w)-1,(y)+(h)-1,c)

% line attributes 
%extern void fl_linewidth(int);
%extern void fl_linestyle(int);

%* ellipses *
%extern void fl_oval(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%extern void fl_ovalbound(FL_Coord, FL_Coord, FL_Coord, FL_Coord, FL_COLOR);
%#define fl_ovalf(x,y,w,h,c)     fl_oval(1,x,y,w,h,c)
%#define fl_ovall(x,y,w,h,c)     fl_oval(0,x,y,w,h,c)
%#define fl_oval_bound           fl_ovalbound

%#define fl_circf(x,y,r,col)  fl_oval(1,(x)-(r),(y)-(r),2*(r),2*(r),col)
%#define fl_circ(x,y,r,col)   fl_oval(0,(x)-(r),(y)-(r),2*(r),2*(r),col)

% arcs 
%extern void fl_pieslice(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			int, int, FL_COLOR);

%#define fl_arcf(x,y,r,a1,a2,c)  fl_pieslice(1,(x)-(r),(y)-(r),\
%                                (2*(r)),(2*(r)), a1,a2,c)

%#define fl_arc(x,y,r,a1,a2,c)  fl_pieslice(0,(x)-(r),(y)-(r), \
%                               (2*(r)),(2*(r)), a1,a2,c)

% misc. stuff 
%extern void fl_add_vertex(FL_Coord, FL_Coord);
%extern void fl_add_float_vertex(float, float);
%extern void fl_reset_vertex(void);
%extern void fl_endline(void), fl_endpolygon(void), fl_endclosedline(void);

%#define fl_bgnline       fl_reset_vertex
%#define fl_bgnclosedline fl_reset_vertex
%#define fl_bgnpolygon    fl_reset_vertex
%#define fl_v2s(v)        fl_add_vertex(v[0], v[1])
%#define fl_v2i(v)        fl_add_vertex(v[0], v[1])
%#define fl_v2f(v)        fl_add_float_vertex(v[0], v[1])
%#define fl_v2d(v)        fl_add_float_vertex(v[0], v[1])

% high level drawing routines 
%extern void fl_drw_frame(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			 FL_COLOR, int);
%extern void fl_drw_checkbox(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			    FL_COLOR, int);

%
% * Interfaces
 
%extern XFontStruct *fl_get_fontstruct(int, int);
%#define fl_get_font_struct fl_get_fontstruct
%#define fl_get_fntstruct fl_get_font_struct

%extern Window fl_get_mouse(FL_Coord *, FL_Coord *, unsigned int *);
%extern void fl_set_mouse(FL_Coord, FL_Coord);
%extern Window fl_get_win_mouse(Window, FL_Coord *, FL_Coord *, unsigned *);
%extern Window fl_get_form_mouse(FL_FORM *, FL_Coord *, FL_Coord *, unsigned *);
%extern FL_FORM *fl_win_to_form(Window);
%extern void fl_set_form_icon(FL_FORM *, Pixmap, Pixmap);

%#define fl_raise_form(f) if(f->window) XRaiseWindow(fl_display,f->window)
%#define fl_lower_form(f) if(f->window) XLowerWindow(fl_display,f->window)

%#define fl_set_foreground(gc,c) XSetForeground(fl_display,gc,fl_get_pixel(c))
%#define fl_set_background(gc,c) XSetBackground(fl_display,gc,fl_get_pixel(c))

% General windowing support 

%extern Window fl_wincreate(const char *);
%extern Window fl_winshow(Window);
%extern Window fl_winopen(const char *);
%extern void fl_winhide(Window);
%extern void fl_winclose(Window);
%extern void fl_winset(Window);
%extern Window fl_winget(void);

%extern void fl_winresize(Window, FL_Coord, FL_Coord);
%extern void fl_winmove(Window, FL_Coord, FL_Coord);
%extern void fl_winreshape(Window, FL_Coord, FL_Coord, FL_Coord, FL_Coord);
%extern void fl_winicon(Window, Pixmap, Pixmap);
%extern void fl_winbackground(Window, unsigned long);
%extern void fl_winstepunit(Window, FL_Coord, FL_Coord);
%extern int fl_winisvalid(Window);
%extern void fl_wintitle(Window, const char *);
%extern void fl_winposition(FL_Coord, FL_Coord);

%#define fl_pref_winposition fl_winposition
%#define fl_win_background     fl_winbackground
%#define fl_set_winstepunit    fl_winstepunit


%extern void fl_winminsize(Window, FL_Coord, FL_Coord);
%extern void fl_winmaxsize(Window, FL_Coord, FL_Coord);
%extern void fl_winaspect(Window, FL_Coord, FL_Coord);
%extern void fl_reset_winconstraints(Window);

%extern void fl_winsize(FL_Coord, FL_Coord);
%extern void fl_initial_winsize(FL_Coord, FL_Coord);
%#define fl_pref_winsize  fl_winsize

%extern void fl_initial_winstate(int);

%extern Colormap fl_create_colormap(XVisualInfo *, int);


%extern void fl_wingeometry(FL_Coord, FL_Coord, FL_Coord, FL_Coord);
%#define fl_pref_wingeometry  fl_wingeometry
%extern void fl_initial_wingeometry(FL_Coord, FL_Coord, FL_Coord, FL_Coord);

%extern void fl_noborder(void);
%extern void fl_transient(void);

%extern void fl_get_winsize(Window, FL_Coord *, FL_Coord *);
%extern void fl_get_winorigin(Window, FL_Coord *, FL_Coord *);
%extern void fl_get_wingeometry(Window, FL_Coord *, FL_Coord *,
%			       FL_Coord *, FL_Coord *);

% for compatibility 
%#define fl_get_win_size          fl_get_winsize
%#define fl_get_win_origin        fl_get_winorigin
%#define fl_get_win_geometry      fl_get_wingeometry
%#define fl_initial_winposition   fl_pref_winposition

%#define fl_get_display()           fl_display
%#define FL_FormDisplay(form)       fl_display
%#define FL_ObjectDisplay(object)   fl_display

% the window an object belongs 
%#define FL_ObjWin(o)   (o->objclass != FL_CANVAS ? \
%                        o->form->window : fl_get_canvas_id(o))

%#define FL_OBJECT_WID  FL_ObjWin

%  all registerable events, including Client Message 
%#define FL_ALL_EVENT  (KeyPressMask|KeyReleaseMask|      \
%                      ButtonPressMask|ButtonReleaseMask|\
%                      EnterWindowMask|LeaveWindowMask|    \
%                      ButtonMotionMask|PointerMotionMask)

% Timer related 

%#define FL_TIMER_EVENT 0x40000000L


%extern int fl_XNextEvent(XEvent *);
%extern int fl_XPeekEvent(XEvent *);
%extern int fl_XEventsQueued(int);
%extern void fl_XPutBackEvent(XEvent *);
%extern const XEvent *fl_last_event(void);

%typedef int (*FL_APPEVENT_CB) (XEvent *, void *);
%extern FL_APPEVENT_CB fl_set_event_callback(FL_APPEVENT_CB, void *);
%extern FL_APPEVENT_CB fl_set_idle_callback(FL_APPEVENT_CB, void *);
%extern long fl_addto_selected_xevent(Window, long);
%extern long fl_remove_selected_xevent(Window, long);
%#define fl_add_selected_xevent  fl_addto_selected_xevent

% Group some WM stuff into a structure for easy maintainance

const FL_WM_SHIFT <- 1	export FL_WM_SHIFT
const FL_WM_NORMAL <- 2	export FL_WM_NORMAL


%extern FL_APPEVENT_CB fl_add_event_callback(Window, int,
%					    FL_APPEVENT_CB, void *);

%extern void fl_remove_event_callback(Window, int);
%extern void fl_activate_event_callbacks(Window);

%extern XEvent *fl_print_xevent_name(const char *, const XEvent *);


%#define metakey_down(mask)     ((mask) & Mod1Mask)
%#define shiftkey_down(mask)    ((mask) & ShiftMask)
%#define controlkey_down(mask)  ((mask) & ControlMask)
%#define button_down(mask)      (((mask) & Button1Mask) || \
%                               ((mask) & Button2Mask) || \
%			       ((mask) & Button3Mask))
%#define fl_keypressed          fl_keysym_pressed

%***************** Resources **************
% bool is int. FL_NONE is defined elsewhere 

const FL_SHORT <- 10	export FL_SHORT
const FL_BOOL <- 11	export FL_BOOL
const FL_INT <- 12	export FL_INT
const FL_LONG <- 13	export FL_LONG
const FL_FLOAT <- 14	export FL_FLOAT
const FL_STRING <- 15	export FL_STRING

%extern Display *fl_initialize(int *, char *[], const char *,
%			      FL_CMD_OPT *, int);
%extern void fl_finish(void);

%extern const char *fl_get_resource(const char *, const char *,
%				   FL_RTYPE, const char *, void *, int);
%extern void fl_set_resource(const char *str, const char *val);

%extern void fl_get_app_resources(FL_resource *, int n);
%extern void fl_set_graphics_mode(int, int);
%extern void fl_set_visualID(long);
%extern int fl_keysym_pressed(KeySym);

const FL_PDButtonLabelSize <- FL_PDButtonFontSize	export FL_PDButtonLabelSize
const FL_PDSliderLabelSize <- FL_PDSliderFontSize	export FL_PDSliderLabelSize
const FL_PDInputLabelSize <-  FL_PDInputFontSize	export FL_PDInputLabelSize

% program default masks 

const FL_PDDepth <- 0x2	export FL_PDDepth
const FL_PDClass <- 0x4	export FL_PDClass
const FL_PDDouble <- 0x8	export FL_PDDouble
const FL_PDSync <- 0x10	export FL_PDSync
const FL_PDPrivateMap <- 0x20	export FL_PDPrivateMap
const FL_PDLeftScrollBar <- 0x40	export FL_PDLeftScrollBar
const FL_PDPupFontSize <- 0x80	export FL_PDPupFontSize
const FL_PDButtonFontSize <- 0x100	export FL_PDButtonFontSize
const FL_PDInputFontSize <- 0x200	export FL_PDInputFontSize
const FL_PDSliderFontSize <- 0x400	export FL_PDSliderFontSize
const FL_PDVisual <- 0x800	export FL_PDVisual
const FL_PDULThickness <- 0x1000	export FL_PDULThickness
const FL_PDULPropWidth <- 0x2000	export FL_PDULPropWidth
const FL_PDBS <- 0x4000	export FL_PDBS
const FL_PDCoordUnit <- 0x8000	export FL_PDCoordUnit
const FL_PDDebug <- 0x10000	export FL_PDDebug
const FL_PDSharedMap <- 0x20000	export FL_PDSharedMap
const FL_PDStandardMap <- 0x40000	export FL_PDStandardMap
const FL_PDBorderWidth <- 0x80000	export FL_PDBorderWidth
const FL_PDSafe <- 0x100000	export FL_PDSafe
const FL_PDMenuFontSize <- 0x200000	export FL_PDMenuFontSize
const FL_PDBrowserFontSize <- 0x400000	export FL_PDBrowserFontSize
const FL_PDChoiceFontSize <- 0x800000	export FL_PDChoiceFontSize
const FL_PDLabelFontSize <- 0x1000000	export FL_PDLabelFontSize


const FL_PDButtonLabel <-   FL_PDButtonLabelSize	export FL_PDButtonLabel

%extern void fl_set_defaults(unsigned long, FL_IOPT *);
%extern void fl_set_tabstop(const char *s);
%extern void fl_get_defaults(FL_IOPT *);
%extern int fl_get_visual_depth(void);
%extern const char *fl_vclass_name(int);
%extern int fl_vclass_val(const char *);
%extern void fl_set_ul_property(int, int);
%extern void fl_set_clipping(FL_Coord, FL_Coord, FL_Coord, FL_Coord);
%extern void fl_set_gc_clipping(GC, FL_Coord, FL_Coord, FL_Coord, FL_Coord);
%extern void fl_unset_gc_clipping(GC);
%extern void fl_set_clippings(XRectangle *, int);
%extern void fl_unset_clipping(void);

%extern GC fl_textgc;
%#define fl_set_text_clipping(a,b,c,d)   fl_set_gc_clipping(fl_textgc,a,b,c,d)
%#define fl_unset_text_clipping() fl_unset_gc_clipping(fl_textgc)


const    FL_NORMAL_BITMAP <-      0	export    FL_NORMAL_BITMAP

%**** Defaults ****

const FL_BITMAP_BOXTYPE <-	FL_NO_BOX	export FL_BITMAP_BOXTYPE
const FL_BITMAP_COL1 <-		FL_COL1	% background of bitmap 	export FL_BITMAP_COL1
const FL_BITMAP_COL2 <-		FL_COL1	% not used currently   	export FL_BITMAP_COL2
const FL_BITMAP_LCOL <-		FL_LCOL	% foreground of bitmap 	export FL_BITMAP_LCOL
const FL_BITMAP_ALIGN <-		FL_ALIGN_BOTTOM	export FL_BITMAP_ALIGN

%**** Others   ****

const FL_BITMAP_MAXSIZE <-	16384	export FL_BITMAP_MAXSIZE

%**** Routines ****
%extern FL_OBJECT *fl_create_bitmap(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);
%extern FL_OBJECT *fl_add_bitmap(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, const char *);
%extern void fl_set_bitmap_data(FL_OBJECT *, int, int, unsigned char *);
%extern void fl_set_bitmap_file(FL_OBJECT *, const char *);
%extern Pixmap fl_read_bitmapfile(Window, const char *,
%				 unsigned *, unsigned *, int *, int *);

%#define fl_create_from_bitmapdata(win, data, w, h)\
%                   XCreateBitmapFromData(fl_get_display(), win, \
%                   (char *)data, w, h)

% for compatibility 
%#define fl_set_bitmap_datafile fl_set_bitmap_file


% PIXMAP stuff 

const FL_NORMAL_PIXMAP <-   0	export FL_NORMAL_PIXMAP

%extern FL_OBJECT *fl_create_pixmap(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);
%extern FL_OBJECT *fl_add_pixmap(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				const char *);

%extern void fl_set_pixmap_data(FL_OBJECT *, char **);
%extern void fl_set_pixmap_file(FL_OBJECT *, const char *);
%extern void fl_set_pixmap_align(FL_OBJECT *, int, int, int);
%extern void fl_set_pixmap_pixmap(FL_OBJECT *, Pixmap, Pixmap);
%extern void fl_set_pixmap_colorcloseness(int, int, int);
%extern void fl_free_pixmap_pixmap(FL_OBJECT *);
%extern Pixmap fl_get_pixmap_pixmap(FL_OBJECT *, Pixmap *, Pixmap *);

%extern Pixmap fl_read_pixmapfile(Window, const char *,
%				 unsigned int *, unsigned int *,
%				 Pixmap *, int *, int *, FL_COLOR);
%extern Pixmap fl_create_from_pixmapdata(Window, char **,
%					unsigned int *, unsigned int *,
%					Pixmap *, int *, int *, FL_COLOR);
%#define fl_free_pixmap(id)  if(id != None) XFreePixmap(fl_display, id);

%extern FL_OBJECT *fl_create_box(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				const char *);

%extern FL_OBJECT *fl_add_box(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			     const char *);

%***** Types    ****

const FL_NORMAL_BROWSER <- 0	export FL_NORMAL_BROWSER
const FL_SELECT_BROWSER <- 1	export FL_SELECT_BROWSER
const FL_HOLD_BROWSER <- 2	export FL_HOLD_BROWSER
const FL_MULTI_BROWSER <- 3	export FL_MULTI_BROWSER

%***** Defaults ****

const FL_BROWSER_BOXTYPE <-	FL_DOWN_BOX	export FL_BROWSER_BOXTYPE
const FL_BROWSER_COL1 <-		FL_COL1	export FL_BROWSER_COL1
const FL_BROWSER_COL2 <-		FL_YELLOW	export FL_BROWSER_COL2
const FL_BROWSER_LCOL <-		FL_LCOL	export FL_BROWSER_LCOL
const FL_BROWSER_ALIGN <-	FL_ALIGN_BOTTOM	export FL_BROWSER_ALIGN

%***** Others   ****

const FL_BROWSER_SLCOL <-	FL_COL1	export FL_BROWSER_SLCOL
const FL_BROWSER_LINELENGTH <-	1024	export FL_BROWSER_LINELENGTH
const FL_BROWSER_FONTSIZE <-     FL_SMALL_FONT	export FL_BROWSER_FONTSIZE

const FL_SCROLLBAR_OFF <- 0	export FL_SCROLLBAR_OFF
const FL_SCROLLBAR_ON <- 1	export FL_SCROLLBAR_ON
const FL_SCROLLBAR_ALWAYS_ON <- 2	export FL_SCROLLBAR_ALWAYS_ON

%**** Routines ****

%extern FL_OBJECT *fl_create_browser(int, FL_Coord, FL_Coord, FL_Coord,
%				    FL_Coord, const char *);
%extern FL_OBJECT *fl_add_browser(int, FL_Coord, FL_Coord, FL_Coord,
%				 FL_Coord, const char *);
%extern void fl_clear_browser(FL_OBJECT *);
%extern void fl_add_browser_line(FL_OBJECT *, const char *);
%extern void fl_addto_browser(FL_OBJECT *, const char *);
%extern void fl_insert_browser_line(FL_OBJECT *, int, const char *);
%extern void fl_delete_browser_line(FL_OBJECT *, int);
%extern void fl_replace_browser_line(FL_OBJECT *, int, const char *);
%extern const char *fl_get_browser_line(FL_OBJECT *, int);
%extern int fl_load_browser(FL_OBJECT *, const char *);

%extern void fl_select_browser_line(FL_OBJECT *, int);
%extern void fl_deselect_browser_line(FL_OBJECT *, int);
%extern void fl_deselect_browser(FL_OBJECT *);
%extern int fl_isselected_browser_line(FL_OBJECT *, int);

%extern int fl_get_browser_topline(FL_OBJECT *);
%extern int fl_get_browser(FL_OBJECT *);
%extern int fl_get_browser_maxline(FL_OBJECT *);
%extern int fl_get_browser_screenlines(FL_OBJECT *);

%extern void fl_set_browser_topline(FL_OBJECT *, int);
%extern void fl_set_browser_fontsize(FL_OBJECT *, int);
%extern void fl_set_browser_fontstyle(FL_OBJECT *, int);
%extern void fl_set_browser_specialkey(FL_OBJECT *, int);
%extern void fl_set_browser_vscrollbar(FL_OBJECT *, int);
%extern void fl_set_browser_leftslider(FL_OBJECT *, int);
%extern void fl_set_browser_line_selectable(FL_OBJECT *, int, int);
%extern void fl_get_browser_dimension(FL_OBJECT *, FL_Coord *, FL_Coord *,
%				     FL_Coord *, FL_Coord *);
%extern void fl_set_browser_dblclick_callback(FL_OBJECT *,
%					     FL_CALLBACKPTR, long);

%#define fl_set_browser_leftscrollbar fl_set_browser_leftslider
%extern void fl_set_browser_xoffset(FL_OBJECT *, FL_Coord);

const FL_NORMAL_BUTTON <- 0	export FL_NORMAL_BUTTON
const FL_PUSH_BUTTON <- 1	export FL_PUSH_BUTTON
const FL_RADIO_BUTTON <- 2	export FL_RADIO_BUTTON
const FL_HIDDEN_BUTTON <- 3	export FL_HIDDEN_BUTTON
const FL_TOUCH_BUTTON <- 4	export FL_TOUCH_BUTTON
const FL_INOUT_BUTTON <- 5	export FL_INOUT_BUTTON
const FL_RETURN_BUTTON <- 6	export FL_RETURN_BUTTON
const FL_HIDDEN_RET_BUTTON <- 7	export FL_HIDDEN_RET_BUTTON
const FL_MENU_BUTTON <- 8	export FL_MENU_BUTTON

%typedef void (*FL_DrawButton) (FL_OBJECT *);
%typedef void (*FL_CleanupButton) (FL_BUTTON_STRUCT *);

%
% *  normal button default
 
const FL_BUTTON_BOXTYPE <-	FL_UP_BOX	export FL_BUTTON_BOXTYPE
const FL_BUTTON_COL1 <-		FL_COL1	export FL_BUTTON_COL1
const FL_BUTTON_COL2 <-		FL_COL1	export FL_BUTTON_COL2
const FL_BUTTON_LCOL <-		FL_LCOL	export FL_BUTTON_LCOL
const FL_BUTTON_ALIGN <-		FL_ALIGN_CENTER	export FL_BUTTON_ALIGN

const FL_BUTTON_MCOL1 <-		FL_MCOL	export FL_BUTTON_MCOL1
const FL_BUTTON_MCOL2 <-		FL_MCOL	export FL_BUTTON_MCOL2
const FL_BUTTON_BW <-		FL_BOUND_WIDTH	export FL_BUTTON_BW

%
% *  light button defaults
 
const FL_LIGHTBUTTON_BOXTYPE <-	FL_UP_BOX	export FL_LIGHTBUTTON_BOXTYPE
const FL_LIGHTBUTTON_COL1 <-	FL_COL1	export FL_LIGHTBUTTON_COL1
const FL_LIGHTBUTTON_COL2 <-	FL_YELLOW	export FL_LIGHTBUTTON_COL2
const FL_LIGHTBUTTON_LCOL <-	FL_LCOL	export FL_LIGHTBUTTON_LCOL
const FL_LIGHTBUTTON_ALIGN <-	FL_ALIGN_CENTER	export FL_LIGHTBUTTON_ALIGN

%**** Others   ****

const FL_LIGHTBUTTON_TOPCOL <-	FL_COL1	export FL_LIGHTBUTTON_TOPCOL
const FL_LIGHTBUTTON_MCOL <-	FL_MCOL	export FL_LIGHTBUTTON_MCOL
const FL_LIGHTBUTTON_MINSIZE <-	12	export FL_LIGHTBUTTON_MINSIZE

%* round button defaults **

const FL_ROUNDBUTTON_BOXTYPE <-	FL_NO_BOX	export FL_ROUNDBUTTON_BOXTYPE
const FL_ROUNDBUTTON_COL1 <-	FL_MCOL	export FL_ROUNDBUTTON_COL1
const FL_ROUNDBUTTON_COL2 <-	FL_YELLOW	export FL_ROUNDBUTTON_COL2
const FL_ROUNDBUTTON_LCOL <-	FL_LCOL	export FL_ROUNDBUTTON_LCOL
const FL_ROUNDBUTTON_ALIGN <-	FL_ALIGN_CENTER	export FL_ROUNDBUTTON_ALIGN

const FL_ROUNDBUTTON_TOPCOL <-	FL_COL1	export FL_ROUNDBUTTON_TOPCOL
const FL_ROUNDBUTTON_MCOL <-	FL_MCOL	export FL_ROUNDBUTTON_MCOL

%* check button defaults **

const FL_CHECKBUTTON_BOXTYPE <-	FL_NO_BOX	export FL_CHECKBUTTON_BOXTYPE
const FL_CHECKBUTTON_COL1 <-	FL_COL1	export FL_CHECKBUTTON_COL1
const FL_CHECKBUTTON_COL2 <-	FL_YELLOW	export FL_CHECKBUTTON_COL2
const FL_CHECKBUTTON_LCOL <-	FL_LCOL	export FL_CHECKBUTTON_LCOL
const FL_CHECKBUTTON_ALIGN <-	FL_ALIGN_CENTER	export FL_CHECKBUTTON_ALIGN

const FL_CHECKBUTTON_TOPCOL <-	FL_COL1	export FL_CHECKBUTTON_TOPCOL
const FL_CHECKBUTTON_MCOL <-	FL_MCOL	export FL_CHECKBUTTON_MCOL

%* bitmap button defaults *
const FL_BITMAPBUTTON_BOXTYPE <-	FL_UP_BOX	export FL_BITMAPBUTTON_BOXTYPE
const FL_BITMAPBUTTON_COL1 <-	FL_COL1	% bitmap background  	export FL_BITMAPBUTTON_COL1
const FL_BITMAPBUTTON_COL2 <-	FL_BLUE	% "focus" color       	export FL_BITMAPBUTTON_COL2
const FL_BITMAPBUTTON_LCOL <-	FL_LCOL	% bitmap foreground   	export FL_BITMAPBUTTON_LCOL
const FL_BITMAPBUTTON_ALIGN <-	FL_ALIGN_BOTTOM	export FL_BITMAPBUTTON_ALIGN

%* bitmap button defaults *
const FL_PIXMAPBUTTON_BOXTYPE <-	FL_UP_BOX	export FL_PIXMAPBUTTON_BOXTYPE
const FL_PIXMAPBUTTON_COL1 <-	FL_COL1	% box col    	export FL_PIXMAPBUTTON_COL1
const FL_PIXMAPBUTTON_COL2 <-	FL_YELLOW	% bound rect 	export FL_PIXMAPBUTTON_COL2
const FL_PIXMAPBUTTON_LCOL <-	FL_LCOL	export FL_PIXMAPBUTTON_LCOL
const FL_PIXMAPBUTTON_ALIGN <-	FL_ALIGN_BOTTOM	export FL_PIXMAPBUTTON_ALIGN

%**** Routines ****

%extern FL_OBJECT *fl_create_button(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);
%extern FL_OBJECT *fl_create_roundbutton(int, FL_Coord, FL_Coord, FL_Coord,
%					FL_Coord, const char *);
%extern FL_OBJECT *fl_create_lightbutton(int, FL_Coord, FL_Coord, FL_Coord,
%					FL_Coord, const char *);
%extern FL_OBJECT *fl_create_checkbutton(int, FL_Coord, FL_Coord, FL_Coord,
%					FL_Coord, const char *);
%extern FL_OBJECT *fl_create_bitmapbutton(int, FL_Coord, FL_Coord, FL_Coord,
%					 FL_Coord, const char *);
%extern FL_OBJECT *fl_create_pixmapbutton(int, FL_Coord, FL_Coord, FL_Coord,
%					 FL_Coord, const char *);

%extern FL_OBJECT *fl_add_roundbutton(int, FL_Coord, FL_Coord,
%				     FL_Coord, FL_Coord, const char *);
%extern FL_OBJECT *fl_add_lightbutton(int, FL_Coord, FL_Coord,
%				     FL_Coord, FL_Coord, const char *);
%extern FL_OBJECT *fl_add_checkbutton(int, FL_Coord, FL_Coord,
%				     FL_Coord, FL_Coord, const char *);
%extern FL_OBJECT *fl_add_button(int, FL_Coord, FL_Coord, FL_Coord,
%				FL_Coord, const char *);

%extern FL_OBJECT *fl_add_bitmapbutton(int, FL_Coord, FL_Coord, FL_Coord,
%				      FL_Coord, const char *);

%extern void fl_set_bitmapbutton_file(FL_OBJECT *, const char *);
%extern void fl_set_bitmapbutton_data(FL_OBJECT *, int, int, unsigned char *);

%#define fl_set_bitmapbutton_datafile  fl_set_bitmapbutton_file

%extern FL_OBJECT *fl_add_pixmapbutton(int, FL_Coord, FL_Coord, FL_Coord,
%				      FL_Coord, const char *);

%#define fl_set_pixmapbutton_data      fl_set_pixmap_data
%#define fl_set_pixmapbutton_file      fl_set_pixmap_file
%#define fl_set_pixmapbutton_pixmap    fl_set_pixmap_pixmap
%#define fl_get_pixmapbutton_pixmap    fl_get_pixmap_pixmap
%#define fl_set_pixmapbutton_datafile  fl_set_pixmapbutton_file
%#define fl_set_pixmapbutton_align     fl_set_pixmapbutton_align
%#define fl_free_pixmapbutton_pixmap   fl_free_pixmap_pixmap

%extern int fl_get_button(FL_OBJECT *);
%extern void fl_set_button(FL_OBJECT *, int);
%extern int fl_get_button_numb(FL_OBJECT *);

%#define fl_set_button_shortcut  fl_set_object_shortcut

%extern FL_OBJECT *fl_create_generic_button(int, int, FL_Coord, FL_Coord,
%					   FL_Coord, FL_Coord, const char *);
%extern void fl_add_button_class(int, FL_DRAWBUTTON, FL_CLEANUPBUTTON);

const FL_NORMAL_CANVAS <- 0	export FL_NORMAL_CANVAS
const FL_SCROLLED_CANVAS <- 1	export FL_SCROLLED_CANVAS


%typedef int (*FL_HANDLE_CANVAS) (FL_OBJECT * ob,
%				 Window,
%				 int, int,
%				 XEvent *, void *);

%typedef int (*FL_MODIFY_CANVAS_PROP) (FL_OBJECT *);

%******************* Default ********************

const FL_CANVAS_BOXTYPE <-   FL_NO_BOX	export FL_CANVAS_BOXTYPE
const FL_CANVAS_ALIGN <-     FL_ALIGN_TOP	export FL_CANVAS_ALIGN


%*********** Interfaces    ***********************


%extern FL_OBJECT *fl_create_generic_canvas(int, int, FL_Coord, FL_Coord,
%					   FL_Coord, FL_Coord, const char *);

%extern FL_OBJECT *fl_add_canvas(int, FL_Coord, FL_Coord, FL_Coord,
%				FL_Coord, const char *);

%extern FL_OBJECT *fl_create_canvas(int, FL_Coord, FL_Coord, FL_Coord,
%				   FL_Coord, const char *);

%extern FL_OBJECT *fl_create_mesacanvas(int, FL_Coord, FL_Coord, FL_Coord,
%				       FL_Coord, const char *);

%extern FL_OBJECT *fl_add_mesacanvas(int, FL_Coord, FL_Coord, FL_Coord,
%				    FL_Coord, const char *);



%extern void fl_set_canvas_decoration(FL_OBJECT *, int);
%extern void fl_set_canvas_colormap(FL_OBJECT *, Colormap);
%extern void fl_set_canvas_visual(FL_OBJECT *, Visual *);
%extern void fl_set_canvas_depth(FL_OBJECT *, int);
%extern void fl_set_canvas_attributes(FL_OBJECT *, unsigned,
%				     XSetWindowAttributes *);

%extern FL_HANDLE_CANVAS fl_add_canvas_handler(FL_OBJECT *, int,
%					      FL_HANDLE_CANVAS, void *);

%extern Window fl_get_canvas_id(FL_OBJECT *);
%extern Colormap fl_get_canvas_colormap(FL_OBJECT *);
%extern int fl_get_canvas_depth(FL_OBJECT *);
%extern void fl_remove_canvas_handler(FL_OBJECT *, int, FL_HANDLE_CANVAS);
%extern void fl_hide_canvas(FL_OBJECT *);	% internal use only 
%extern void fl_canvas_yield_to_shortcut(FL_OBJECT *, int);
%extern void fl_modify_canvas_prop(FL_OBJECT *,
%				  FL_MODIFY_CANVAS_PROP,
%				  FL_MODIFY_CANVAS_PROP,
%				  FL_MODIFY_CANVAS_PROP);

% OpenGL canvases 
%extern FL_OBJECT *fl_create_glcanvas(int, FL_Coord, FL_Coord, FL_Coord,
%				     FL_Coord, const char *);

%extern FL_OBJECT *fl_add_glcanvas(int, FL_Coord, FL_Coord, FL_Coord,
%				  FL_Coord, const char *);

%extern void fl_set_glcanvas_defaults(const int *);
%extern void fl_get_glcanvas_defaults(int *);
%extern void fl_set_glcanvas_attributes(FL_OBJECT *, const int *);
%extern void fl_get_glcanvas_attributes(FL_OBJECT *, int *);
%extern void fl_set_glcanvas_direct(FL_OBJECT *, int);
%extern XVisualInfo *fl_get_glcanvas_xvisualinfo(FL_OBJECT *);

%#if defined(__GLX_glx_h__) || defined(GLX_H)
%extern GLXContext fl_get_glcanvas_context(FL_OBJECT * ob);
%extern Window fl_glwincreate(int *, GLXContext *, int, int);
%extern Window fl_glwinopen(int *, GLXContext *, int, int);
%#endif

const FL_BAR_CHART <- 0	export FL_BAR_CHART
const FL_HORBAR_CHART <- 1	export FL_HORBAR_CHART
const FL_LINE_CHART <- 2	export FL_LINE_CHART
const FL_FILLED_CHART <- 3	export FL_FILLED_CHART
const FL_SPIKE_CHART <- 4	export FL_SPIKE_CHART
const FL_PIE_CHART <- 5	export FL_PIE_CHART
const FL_SPECIALPIE_CHART <- 6	export FL_SPECIALPIE_CHART

%**** Defaults ****

const FL_CHART_BOXTYPE <-	FL_BORDER_BOX	export FL_CHART_BOXTYPE
const FL_CHART_COL1 <-		FL_COL1	export FL_CHART_COL1
const FL_CHART_LCOL <-		FL_LCOL	export FL_CHART_LCOL
const FL_CHART_ALIGN <-		FL_ALIGN_BOTTOM	export FL_CHART_ALIGN

%**** Others   ****

const FL_CHART_MAX <-		256	export FL_CHART_MAX

%**** Routines ****

%extern FL_OBJECT *fl_create_chart(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				  const char *);
%extern FL_OBJECT *fl_add_chart(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			       const char *);

%extern void fl_clear_chart(FL_OBJECT *);
%extern void fl_add_chart_value(FL_OBJECT *, double, const char *, int);
%extern void fl_insert_chart_value(FL_OBJECT *, int, double, const char *, int);
%extern void fl_replace_chart_value(FL_OBJECT *, int, double, const char *, int);
%extern void fl_set_chart_bounds(FL_OBJECT *, double, double);
%extern void fl_set_chart_maxnumb(FL_OBJECT *, int);
%extern void fl_set_chart_autosize(FL_OBJECT *, int);

const FL_NORMAL_CHOICE <- 0	export FL_NORMAL_CHOICE
const FL_DROPLIST_CHOICE <- 1	export FL_DROPLIST_CHOICE

const  FL_SIMPLE_CHOICE <-  FL_NORMAL_CHOICE	export  FL_SIMPLE_CHOICE

%**** Defaults ****

const FL_CHOICE_BOXTYPE <-	FL_ROUNDED_BOX	export FL_CHOICE_BOXTYPE
const FL_CHOICE_COL1 <-		FL_COL1	export FL_CHOICE_COL1
const FL_CHOICE_COL2 <-		FL_LCOL	export FL_CHOICE_COL2
const FL_CHOICE_LCOL <-		FL_LCOL	export FL_CHOICE_LCOL
const FL_CHOICE_ALIGN <-		FL_ALIGN_LEFT	export FL_CHOICE_ALIGN

%**** Others   ****

const FL_CHOICE_MCOL <-		FL_MCOL	export FL_CHOICE_MCOL
const FL_CHOICE_MAXITEMS <-	63	export FL_CHOICE_MAXITEMS

%**** Routines ****

%extern FL_OBJECT *fl_create_choice(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);

%extern FL_OBJECT *fl_add_choice(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, const char *);
%extern void fl_clear_choice(FL_OBJECT *);
%extern void fl_addto_choice(FL_OBJECT *, const char *);
%extern void fl_replace_choice(FL_OBJECT *, int, const char *);
%extern void fl_delete_choice(FL_OBJECT *, int);
%extern void fl_set_choice(FL_OBJECT *, int);
%extern void fl_set_choice_text(FL_OBJECT *, const char *);
%extern int fl_get_choice(FL_OBJECT *);
%extern const char *fl_get_choice_item_text(FL_OBJECT *, int);
%extern int fl_get_choice_maxitems(FL_OBJECT *);
%extern const char *fl_get_choice_text(FL_OBJECT *);
%extern void fl_set_choice_fontsize(FL_OBJECT *, int);
%extern void fl_set_choice_fontstyle(FL_OBJECT *, int);
%extern void fl_set_choice_align(FL_OBJECT *, int);
%extern void fl_set_choice_item_mode(FL_OBJECT *, int, unsigned);
%extern void fl_set_choice_item_shortcut(FL_OBJECT *, int, const char *);


const FL_ANALOG_CLOCK <- 0	export FL_ANALOG_CLOCK
const FL_DIGITAL_CLOCK <- 1	export FL_DIGITAL_CLOCK

const FL_CLOCK_BOXTYPE <-   FL_UP_BOX	export FL_CLOCK_BOXTYPE
const FL_CLOCK_COL1 <-      FL_INACTIVE_COL	export FL_CLOCK_COL1
const FL_CLOCK_COL2 <-      FL_BOTTOM_BCOL	export FL_CLOCK_COL2
const FL_CLOCK_LCOL <-      FL_BLACK	export FL_CLOCK_LCOL
const FL_CLOCK_ALIGN <-     FL_ALIGN_BOTTOM	export FL_CLOCK_ALIGN

const FL_CLOCK_TOPCOL <-  FL_COL1	export FL_CLOCK_TOPCOL

%extern FL_OBJECT *fl_create_clock(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				  const char *);

%extern FL_OBJECT *fl_add_clock(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, const char *);
%extern void fl_get_clock(FL_OBJECT *, int *, int *, int *);

const FL_NORMAL_COUNTER <- 0	export FL_NORMAL_COUNTER
const FL_SIMPLE_COUNTER <- 1	export FL_SIMPLE_COUNTER

%**** Defaults ****

const FL_COUNTER_BOXTYPE <-	FL_UP_BOX	export FL_COUNTER_BOXTYPE
const FL_COUNTER_COL1 <-		FL_COL1	export FL_COUNTER_COL1
const FL_COUNTER_COL2 <-		FL_BLUE	% ct label     	export FL_COUNTER_COL2
const FL_COUNTER_LCOL <-		FL_LCOL	% ct reporting 	export FL_COUNTER_LCOL
const FL_COUNTER_ALIGN <-	FL_ALIGN_BOTTOM	export FL_COUNTER_ALIGN

%**** Others   ****

const FL_COUNTER_BW <- 2	export FL_COUNTER_BW

%**** Routines ****
%extern FL_OBJECT *fl_create_counter(int, FL_Coord, FL_Coord, FL_Coord,
%				    FL_Coord, const char *);

%extern FL_OBJECT *fl_add_counter(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				 const char *);

%extern void fl_set_counter_value(FL_OBJECT *, double);
%extern void fl_set_counter_bounds(FL_OBJECT *, double, double);
%extern void fl_set_counter_step(FL_OBJECT *, double, double);
%extern void fl_set_counter_precision(FL_OBJECT *, int);
%extern double fl_get_counter_value(FL_OBJECT *);
%extern void fl_set_counter_return(FL_OBJECT *, int);
%extern void fl_set_counter_filter(FL_OBJECT *,
%				  const char *(*)(FL_OBJECT *, double, int));


%extern void fl_set_cursor(Window, int);
%extern void fl_set_cursor_color(int, FL_COLOR, FL_COLOR);
%extern int fl_create_bitmap_cursor(const char *, const char *,
%				   int, int, int, int);
%extern Cursor fl_get_cursor_byname(int);
%#define fl_reset_cursor(win) fl_set_cursor(win, -1);

const FL_NORMAL_DIAL <- 0	export FL_NORMAL_DIAL
const FL_LINE_DIAL <- 1	export FL_LINE_DIAL

%**** Defaults ****

const FL_DIAL_BOXTYPE <-		FL_FLAT_BOX	export FL_DIAL_BOXTYPE
const FL_DIAL_COL1 <-		FL_COL1	export FL_DIAL_COL1
const FL_DIAL_COL2 <-		FL_RIGHT_BCOL	export FL_DIAL_COL2
const FL_DIAL_LCOL <-		FL_LCOL	export FL_DIAL_LCOL
const FL_DIAL_ALIGN <-		FL_ALIGN_BOTTOM	export FL_DIAL_ALIGN

%**** Others   ****

const FL_DIAL_TOPCOL <-		FL_COL1	export FL_DIAL_TOPCOL

%**** Routines ****

%extern FL_OBJECT *fl_create_dial(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				 const char *);
%extern FL_OBJECT *fl_add_dial(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			      const char *);

%extern void fl_set_dial_value(FL_OBJECT *, double);
%extern double fl_get_dial_value(FL_OBJECT *);
%extern void fl_set_dial_bounds(FL_OBJECT *, double, double);
%extern void fl_get_dial_bounds(FL_OBJECT *, double *, double *);

%extern void fl_set_dial_step(FL_OBJECT *, double);
%extern void fl_set_dial_return(FL_OBJECT *, int);
%extern void fl_set_dial_angles(FL_OBJECT *, double, double);
%extern void fl_set_dial_cross(FL_OBJECT *, int);

%  File types
const FT_FILE <- 0	export FT_FILE
const FT_DIR <- 1	export FT_DIR
const FT_LINK <- 2	export FT_LINK
const FT_SOCK <- 3	export FT_SOCK
const FT_FIFO <- 4	export FT_FIFO
const FT_BLK <- 5	export FT_BLK
const FT_CHR <- 6	export FT_CHR
const FT_OTHER <- 7	export FT_OTHER

%typedef struct
%{
%    char *name;			% entry name 
%    int type;			% FILE_TYPE  
%} FL_Dirlist;

%typedef int (*FL_DIRLIST_FILTER) (const char *, int);

% read dir with pattern filtering. All dirs read might be cached.
% * must not change dirlist in anyway.
 
%extern const FL_Dirlist *fl_get_dirlist(const char *,	% dir 
%					const char *,	% pat 
%					int *,	% nfiles 
%					int);	% rescan 

%extern FL_DIRLIST_FILTER fl_set_dirlist_filter(FL_DIRLIST_FILTER);

%extern void fl_free_dirlist(FL_Dirlist *);

% Free all directory caches 
%extern void fl_free_all_dirlist(void);

%extern int fl_is_valid_dir(const char *);
%extern unsigned long fl_fmtime(const char *);
%extern char *fl_fix_dirname(char *);

% types of frames

const FL_NO_FRAME <- 0	export FL_NO_FRAME
const FL_UP_FRAME <- 1	export FL_UP_FRAME
const FL_DOWN_FRAME <- 2	export FL_DOWN_FRAME
const FL_BORDER_FRAME <- 3	export FL_BORDER_FRAME
const FL_SHADOW_FRAME <- 4	export FL_SHADOW_FRAME
const FL_ENGRAVED_FRAME <- 5	export FL_ENGRAVED_FRAME
const FL_ROUNDED_FRAME <- 6	export FL_ROUNDED_FRAME
const FL_EMBOSSED_FRAME <- 7	export FL_EMBOSSED_FRAME
const FL_OVAL_FRAME <- 8	export FL_OVAL_FRAME

%extern FL_OBJECT *fl_create_frame(int, FL_Coord, FL_Coord, 
%                                  FL_Coord, FL_Coord, const char *);

%extern FL_OBJECT *fl_add_frame(int,FL_Coord,FL_Coord,
%                             FL_Coord,FL_Coord, const char *);

const FL_NORMAL_FREE <- 0	export FL_NORMAL_FREE
const FL_INACTIVE_FREE <- 1	export FL_INACTIVE_FREE
const FL_INPUT_FREE <- 2	export FL_INPUT_FREE
const FL_CONTINUOUS_FREE <- 3	export FL_CONTINUOUS_FREE
const FL_ALL_FREE <- 4	export FL_ALL_FREE

const FL_SLEEPING_FREE <- FL_INACTIVE_FREE	export FL_SLEEPING_FREE

%extern FL_OBJECT *fl_create_free(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				 const char *, FL_HANDLEPTR);
%extern FL_OBJECT *fl_add_free(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			      const char *, FL_HANDLEPTR);

%#define FLAlertDismissLabel     "flAlert.dismiss.label"
%#define FLQuestionYesLabel      "flQuestion.yes.label"
%#define FLQuestionNoLabel       "flQuestion.no.label"
%#define FLOKLabel               "*.ok.label"

% from goodies.c 
%extern void fl_set_goodies_font(int, int);
%extern void fl_show_message(const char *, const char *, const char *);
%extern void fl_show_alert(const char *, const char *, const char *, int);
%extern int fl_show_question(const char *, const char *, const char *);
%extern const char *fl_show_input(const char *, const char *);
%extern int fl_show_colormap(int);
%extern int fl_show_choice(const char *, const char *, const char *, int,
%			  const char *, const char *, const char *);
%extern void fl_set_choices_shortcut(const char *, const char *, const char *);

%extern void fl_show_oneliner(const char *, FL_Coord, FL_Coord);
%extern void fl_hide_oneliner(void);
%extern void fl_set_oneliner_font(int, int);
%extern void fl_set_oneliner_color(FL_COLOR, FL_COLOR);

%****** from file selector ****************

%typedef struct
%{
%    FL_FORM *fselect;
%    FL_OBJECT *browser, *input, *prompt, *resbutt;
%    FL_OBJECT *patbutt, *dirbutt, *cancel, *ready;
%} FD_FSELECTOR;

%extern int fl_use_fselector(int);
%extern const char *fl_show_fselector(const char *, const char *,
%				     const char *, const char *);
%extern void fl_set_fselector_placement(int);
%extern void fl_set_fselector_border(int);

%#define fl_set_fselector_transient(b)   \
%                     fl_set_fselector_border((b)?FL_TRANSIENT:FL_FULLBORDER)

%extern void fl_set_fselector_callback(int (*)(const char *, void *), void *);
%extern const char *fl_get_filename(void);
%extern const char *fl_get_directory(void);
%extern const char *fl_get_pattern(void);
%extern int fl_set_directory(const char *);
%extern void fl_set_pattern(const char *);
%extern void fl_refresh_fselector(void);
%extern void fl_add_fselector_appbutton(const char *, void (*)(void *), void *);
%extern void fl_remove_fselector_appbutton(const char *);
%extern void fl_disable_fselector_cache(int);
%extern void fl_invalidate_fselector_cache(void);
%extern FL_FORM *fl_get_fselector_form(void);
%extern FD_FSELECTOR *fl_get_fselector_fdstruct(void);
%extern void fl_hide_fselector(void);

%extern void fl_set_fselector_filetype_marker(int dir,
%					     int fifo,
%					     int sock,
%					     int cdev,
%					     int bdev);

%#define fl_show_file_selector     fl_show_fselector
%#define fl_set_fselector_cb       fl_set_fselector_callback
%#define fl_set_fselector_title(s) fl_set_form_title(fl_get_fselector_form(),s)

%***** Types    *****

const FL_NORMAL_INPUT <- 0	export FL_NORMAL_INPUT
const FL_FLOAT_INPUT <- 1	export FL_FLOAT_INPUT
const FL_INT_INPUT <- 2	export FL_INT_INPUT
const FL_HIDDEN_INPUT <- 3	export FL_HIDDEN_INPUT
const FL_MULTILINE_INPUT <- 4	export FL_MULTILINE_INPUT
const FL_SECRET_INPUT <- 5	export FL_SECRET_INPUT

%**** Defaults ****

const FL_INPUT_BOXTYPE <-	FL_DOWN_BOX	export FL_INPUT_BOXTYPE
const FL_INPUT_COL1 <-		FL_COL1	export FL_INPUT_COL1
const FL_INPUT_COL2 <-		FL_MCOL	export FL_INPUT_COL2
const FL_INPUT_LCOL <-		FL_LCOL	export FL_INPUT_LCOL
const FL_INPUT_ALIGN <-		FL_ALIGN_LEFT	export FL_INPUT_ALIGN

%**** Others   ****

const FL_INPUT_TCOL <-		FL_LCOL	export FL_INPUT_TCOL
const FL_INPUT_CCOL <-		FL_BLUE	export FL_INPUT_CCOL

const FL_RINGBELL <-             0x10	export FL_RINGBELL

%**** Routines ****

%extern FL_OBJECT *fl_create_input(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				  const char *);

%extern FL_OBJECT *fl_add_input(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, const char *);

%extern void fl_set_input(FL_OBJECT *, const char *);
%extern void fl_set_input_color(FL_OBJECT *, int, int);
%extern const char *fl_get_input(FL_OBJECT *);
%extern void fl_set_input_return(FL_OBJECT *, int);
%extern void fl_set_input_scroll(FL_OBJECT *, int);
%extern void fl_set_input_cursorpos(FL_OBJECT *, int, int);
%extern int fl_get_input_cursorpos(FL_OBJECT *, int *, int *);
%extern void fl_set_input_selected(FL_OBJECT *, int);
%extern void fl_set_input_selected_range(FL_OBJECT *, int, int);
%extern void fl_set_input_maxchars(FL_OBJECT *, int);

%typedef int (*FL_INPUTVALIDATOR) (FL_OBJECT *, const char *, const char *, int);

%extern FL_INPUTVALIDATOR fl_set_input_filter(FL_OBJECT *, FL_INPUTVALIDATOR);

%#define fl_set_input_shortcut fl_set_object_shortcut

%#define ringbell()  XBell(fl_display, 0)

%************   Object Class: Menu         ************

const FL_TOUCH_MENU <- 0	export FL_TOUCH_MENU
const FL_PUSH_MENU <- 1	export FL_PUSH_MENU
const FL_PULLDOWN_MENU <- 2	export FL_PULLDOWN_MENU

%***** Defaults *****

const FL_MENU_BOXTYPE <-		FL_BORDER_BOX	export FL_MENU_BOXTYPE
const FL_MENU_COL1 <-		FL_COL1	export FL_MENU_COL1
const FL_MENU_COL2 <-		FL_MCOL	export FL_MENU_COL2
const FL_MENU_LCOL <-		FL_LCOL	export FL_MENU_LCOL
const FL_MENU_ALIGN <-		FL_ALIGN_CENTER	export FL_MENU_ALIGN

%***** Others   *****

const FL_MENU_MAXITEMS <-	128	export FL_MENU_MAXITEMS
const FL_MENU_MAXSTR <-		64	export FL_MENU_MAXSTR

%**** Routines ****

%extern FL_OBJECT *fl_create_menu(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				 const char *);

%extern FL_OBJECT *fl_add_menu(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			      const char *);

%extern void fl_clear_menu(FL_OBJECT *);
%extern void fl_set_menu(FL_OBJECT *, const char *);
%extern void fl_addto_menu(FL_OBJECT *, const char *);
%extern void fl_replace_menu_item(FL_OBJECT *, int, const char *);
%extern void fl_delete_menu_item(FL_OBJECT *, int);

%extern void fl_set_menu_item_shortcut(FL_OBJECT *, int, const char *);
%extern void fl_set_menu_item_mode(FL_OBJECT *, int, unsigned);
%extern void fl_show_menu_symbol(FL_OBJECT *, int);
%extern void fl_set_menu_popup(FL_OBJECT *, int);

%extern int fl_get_menu(FL_OBJECT *);
%extern const char *fl_get_menu_item_text(FL_OBJECT *, int);
%extern int fl_get_menu_maxitems(FL_OBJECT *);
%extern unsigned fl_get_menu_item_mode(FL_OBJECT *, int);
%extern const char *fl_get_menu_text(FL_OBJECT *);

const FL_MAXPUPI <-    64      	export FL_MAXPUPI
const FL_PUP_PADH <-    4 	export FL_PUP_PADH

%extern int fl_newpup(Window);
%extern int fl_defpup(Window, const char *,...);
%extern int fl_addtopup(int, const char *,...);
%extern int fl_setpup_mode(int, int, unsigned);
%extern void fl_freepup(int);
%extern int fl_dopup(int);

%extern void fl_setpup_shortcut(int, int, const char *);
%extern void fl_setpup_position(int, int);
%extern void fl_setpup_selection(int, int);
%extern void fl_setpup_fontsize(int);
%extern void fl_setpup_fontstyle(int);
%extern void fl_setpup_shadow(int, int);
%extern void fl_setpup_softedge(int, int);
%extern void fl_setpup_color(FL_COLOR, FL_COLOR);
%extern void fl_setpup_checkcolor(FL_COLOR);
%extern void fl_setpup_title(int, const char *);
%extern void fl_setpup_bw(int, int);
%extern void fl_setpup_pad(int, int, int);
%extern Cursor fl_setpup_cursor(int, int);
%extern Cursor fl_setpup_default_cursor(int);
%extern int fl_setpup_maxpup(int);
%extern unsigned fl_getpup_mode(int, int);
%extern const char *fl_getpup_text(int, int);
%extern void fl_showpup(int);
%extern void fl_hidepup(int);

%#define fl_setpup_hotkey    fl_setpup_shortcut

%extern FL_PUP_CB fl_setpup_itemcb(int, int, FL_PUP_CB);
%extern FL_PUP_CB fl_setpup_menucb(int, FL_PUP_CB);
%extern void fl_setpup_submenu(int, int, int);

%#define fl_setpup    fl_setpup_mode


const FL_NORMAL_POSITIONER <- 0		export FL_NORMAL_POSITIONER

%**** Defaults ****

const FL_POSITIONER_BOXTYPE <-	FL_DOWN_BOX	export FL_POSITIONER_BOXTYPE
const FL_POSITIONER_COL1 <-	FL_COL1	export FL_POSITIONER_COL1
const FL_POSITIONER_COL2 <-	FL_RED	export FL_POSITIONER_COL2
const FL_POSITIONER_LCOL <-	FL_LCOL	export FL_POSITIONER_LCOL
const FL_POSITIONER_ALIGN <-	FL_ALIGN_BOTTOM	export FL_POSITIONER_ALIGN

%**** Others   ****


%**** Routines ****

%extern FL_OBJECT *fl_create_positioner(int, FL_Coord, FL_Coord, FL_Coord,
%				       FL_Coord, const char *);

%extern FL_OBJECT *fl_add_positioner(int, FL_Coord, FL_Coord, FL_Coord,
%				    FL_Coord, const char *);

%extern void fl_set_positioner_xvalue(FL_OBJECT *, double);
%extern double fl_get_positioner_xvalue(FL_OBJECT *);
%extern void fl_set_positioner_xbounds(FL_OBJECT *, double, double);
%extern void fl_get_positioner_xbounds(FL_OBJECT *, double *, double *);
%extern void fl_set_positioner_yvalue(FL_OBJECT *, double);
%extern double fl_get_positioner_yvalue(FL_OBJECT *);
%extern void fl_set_positioner_ybounds(FL_OBJECT *, double, double);
%extern void fl_get_positioner_ybounds(FL_OBJECT *, double *, double *);
%extern void fl_set_positioner_xstep(FL_OBJECT *, double);
%extern void fl_set_positioner_ystep(FL_OBJECT *, double);
%extern void fl_set_positioner_return(FL_OBJECT *, int);


const FL_VERT_SLIDER <- 0	export FL_VERT_SLIDER
const FL_HOR_SLIDER <- 1	export FL_HOR_SLIDER
const FL_VERT_FILL_SLIDER <- 2	export FL_VERT_FILL_SLIDER
const FL_HOR_FILL_SLIDER <- 3	export FL_HOR_FILL_SLIDER
const FL_VERT_NICE_SLIDER <- 4	export FL_VERT_NICE_SLIDER
const FL_HOR_NICE_SLIDER <- 5	export FL_HOR_NICE_SLIDER
const FL_BROWSER_SLIDER <- 6	export FL_BROWSER_SLIDER
const FL_BROWSER_SLIDER2 <- 7	export FL_BROWSER_SLIDER2


%**** Defaults ****

const FL_SLIDER_BW1 <-           FL_BOUND_WIDTH	export FL_SLIDER_BW1
const FL_SLIDER_BW2 <-          2	export FL_SLIDER_BW2
const FL_SLIDER_BOXTYPE <-	FL_DOWN_BOX	export FL_SLIDER_BOXTYPE
const FL_SLIDER_COL1 <-		FL_COL1	export FL_SLIDER_COL1
const FL_SLIDER_COL2 <-		FL_COL1	export FL_SLIDER_COL2
const FL_SLIDER_LCOL <-		FL_LCOL	export FL_SLIDER_LCOL
const FL_SLIDER_ALIGN <-		FL_ALIGN_BOTTOM	export FL_SLIDER_ALIGN

%**** Others   ****

%const FL_SLIDER_FINE <-		0.05	
%const FL_SLIDER_WIDTH <-		0.08	


%**** Routines ****

%extern FL_OBJECT *fl_create_slider(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);
%extern FL_OBJECT *fl_add_slider(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				const char *);

%extern FL_OBJECT *fl_create_valslider(int, FL_Coord, FL_Coord, FL_Coord,
%				      FL_Coord, const char *);
%extern FL_OBJECT *fl_add_valslider(int, FL_Coord, FL_Coord, FL_Coord,
%				   FL_Coord, const char *);

%extern void fl_set_slider_value(FL_OBJECT *, double);
%extern double fl_get_slider_value(FL_OBJECT *);
%extern void fl_set_slider_bounds(FL_OBJECT *, double, double);
%extern void fl_get_slider_bounds(FL_OBJECT *, double *, double *);

%extern void fl_set_slider_return(FL_OBJECT *, int);

%extern void fl_set_slider_step(FL_OBJECT *, double);
%extern void fl_set_slider_size(FL_OBJECT *, double);
%extern void fl_set_slider_precision(FL_OBJECT *, int);
%extern void fl_set_slider_filter(FL_OBJECT *,
%				 const char *(*)(FL_OBJECT *, double, int));


const FL_NORMAL_TEXT <- 0	export FL_NORMAL_TEXT

const FL_TEXT_BOXTYPE <-    FL_FLAT_BOX	export FL_TEXT_BOXTYPE
const FL_TEXT_COL1 <-       FL_COL1	export FL_TEXT_COL1
const FL_TEXT_COL2 <-       FL_MCOL	export FL_TEXT_COL2
const FL_TEXT_LCOL <-       FL_LCOL	export FL_TEXT_LCOL
const FL_TEXT_ALIGN <-      FL_ALIGN_LEFT	export FL_TEXT_ALIGN

%extern FL_OBJECT *fl_create_text(int, FL_Coord, FL_Coord, FL_Coord,
%                  FL_Coord, const char *);

%extern FL_OBJECT *fl_add_text(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, 
%                  const char *);

const FL_NORMAL_TIMER <- 0	export FL_NORMAL_TIMER
const FL_VALUE_TIMER <- 1	export FL_VALUE_TIMER
const FL_HIDDEN_TIMER <- 2	export FL_HIDDEN_TIMER

%**** Defaults ****

const FL_TIMER_BOXTYPE <-	FL_DOWN_BOX	export FL_TIMER_BOXTYPE
const FL_TIMER_COL1 <-		FL_COL1	export FL_TIMER_COL1
const FL_TIMER_COL2 <-		FL_RED	export FL_TIMER_COL2
const FL_TIMER_LCOL <-		FL_LCOL	export FL_TIMER_LCOL
const FL_TIMER_ALIGN <-		FL_ALIGN_CENTER	export FL_TIMER_ALIGN

%**** Others   ****

%const FL_TIMER_BLINKRATE <-	0.2	export FL_TIMER_BLINKRATE

%**** Routines ****

%extern FL_OBJECT *fl_create_timer(int, FL_Coord, FL_Coord, FL_Coord,
%				  FL_Coord, const char *);

%extern FL_OBJECT *fl_add_timer(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%			       const char *);

%extern void fl_set_timer(FL_OBJECT *, double);
%extern double fl_get_timer(FL_OBJECT *);


const FL_NORMAL_XYPLOT <- 0	export FL_NORMAL_XYPLOT
const FL_SQUARE_XYPLOT <- 1	export FL_SQUARE_XYPLOT
const FL_CIRCLE_XYPLOT <- 2	export FL_CIRCLE_XYPLOT
const FL_FILL_XYPLOT <- 3	export FL_FILL_XYPLOT
const FL_POINTS_XYPLOT <- 4	export FL_POINTS_XYPLOT
const FL_DASHED_XYPLOT <- 5	export FL_DASHED_XYPLOT
const FL_IMPULSE_XYPLOT <- 6	export FL_IMPULSE_XYPLOT
const FL_ACTIVE_XYPLOT <- 7	export FL_ACTIVE_XYPLOT
const FL_EMPTY_XYPLOT <- 8	export FL_EMPTY_XYPLOT

const FL_LINEAR <- 0	export FL_LINEAR
const FL_LOG <- 1	export FL_LOG

%**** Defaults ****

const FL_XYPLOT_BOXTYPE <-       FL_FLAT_BOX	export FL_XYPLOT_BOXTYPE
const FL_XYPLOT_COL1 <-          FL_COL1	export FL_XYPLOT_COL1
const FL_XYPLOT_LCOL <-          FL_LCOL	export FL_XYPLOT_LCOL
const FL_XYPLOT_ALIGN <-         FL_ALIGN_BOTTOM	export FL_XYPLOT_ALIGN
const FL_MAX_XYPLOTOVERLAY <-    32	export FL_MAX_XYPLOTOVERLAY

%**** Others   ****

%extern void fl_set_xyplot_return(FL_OBJECT *, int);
%extern void fl_set_xyplot_xtics(FL_OBJECT *, int, int);
%extern void fl_set_xyplot_ytics(FL_OBJECT *, int, int);
%extern void fl_set_xyplot_xbounds(FL_OBJECT *, double, double);
%extern void fl_set_xyplot_ybounds(FL_OBJECT *, double, double);
%extern void fl_get_xyplot_xbounds(FL_OBJECT *, float *, float *);
%extern void fl_get_xyplot_ybounds(FL_OBJECT *, float *, float *);
%extern void fl_get_xyplot(FL_OBJECT *, float *, float *, int *);
%extern void fl_get_xyplot_data(FL_OBJECT *, float *, float *, int *);

%extern FL_OBJECT *fl_create_xyplot(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord,
%				   const char *);

%extern FL_OBJECT *fl_add_xyplot(int, FL_Coord, FL_Coord, FL_Coord, FL_Coord, const char *);

%extern void fl_set_xyplot_data(FL_OBJECT *, float *, float *, int,
%			       const char *, const char *, const char *);
%extern void fl_set_xyplot_file(FL_OBJECT *, const char *, const char *,
%			       const char *, const char *);
%#define fl_set_xyplot_datafile fl_set_xyplot_file

%extern void fl_add_xyplot_text(FL_OBJECT *, double, double, const char *,
%			       int, FL_COLOR);

%extern void fl_delete_xyplot_text(FL_OBJECT *, const char *);

%extern int fl_set_xyplot_maxoverlays(FL_OBJECT *, int);
%extern void fl_add_xyplot_overlay(FL_OBJECT *, int, float *, float *, int,
%				  FL_COLOR);
%extern void fl_set_xyplot_overlay_type(FL_OBJECT *, int, int);
%extern void fl_delete_xyplot_overlay(FL_OBJECT *, int);
%extern void fl_set_xyplot_interpolate(FL_OBJECT *, int, int, double);
%extern void fl_set_xyplot_fontsize(FL_OBJECT *, int);
%extern void fl_set_xyplot_fontstyle(FL_OBJECT *, int);
%extern void fl_set_xyplot_inspect(FL_OBJECT *, int);
%extern void fl_set_xyplot_symbolsize(FL_OBJECT *, int);
%extern void fl_replace_xyplot_point(FL_OBJECT *, int, double, double);
%extern void fl_get_xyplot_xmapping(FL_OBJECT *, float *, float *);
%extern void fl_get_xyplot_ymapping(FL_OBJECT *, float *, float *);
%extern int fl_interpolate(const float *, const float *, int,
%			  float *, float *, double, int);

%extern void fl_xyplot_s2w(FL_OBJECT *, double, double, float *, float *);
%extern void fl_xyplot_w2s(FL_OBJECT *, double, double, float *, float *);
%extern void fl_set_xyplot_xscale(FL_OBJECT *, int, double);
%extern void fl_set_xyplot_yscale(FL_OBJECT *, int, double);

const XFButton <- Integer	export XFButton

const Form <- class Form[kind : Integer, width : Integer, height : Integer]	
  var me : Integer

  export operation addBox [kind : Integer, width : Integer, height : Integer,
    x : Integer, y : Integer, label : String]
    primitive "NCCALL" "XFORMS" "FL_ADD_BOX" [] <- [kind, width, height, x, y, label]
  end addBox

  export operation AddButton [kind : Integer, x : Integer, y : Integer, w : Integer, h : Integer, l : String] -> [butt : XFButton]
    primitive "NCCALL" "XFORMS" "FL_ADD_BUTTON" [butt] <- [kind, x, y, w, h, l]
  end AddButton

  export operation AddLightButton [kind : Integer, x : Integer, y : Integer, w : Integer, h : Integer, l : String] -> [butt : XFButton]
    primitive "NCCALL" "XFORMS" "FL_ADD_LIGHTBUTTON" [butt] <- [kind, x, y, w, h, l]
  end AddLightButton

  export operation Show [w : Integer, how : Integer, label : String]
    primitive "NCCALL" "XFORMS" "FL_END_FORM" [] <- []
    primitive "NCCALL" "XFORMS" "FL_SHOW_FORM" [] <- [me, w, how, label]
  end Show

  export operation Hide 
    primitive "NCCALL" "XFORMS" "FL_HIDE_FORM" [] <- [me]
  end Hide

  initially
    XForms.start
    assert XForms$display != 0
    primitive "NCCALL" "XFORMS" "FL_BGN_FORM" [me] <- [kind, width, height]
  end initially
end Form

const Browser <- class Browser[kind : Integer, x : Integer, y : Integer, width : Integer, height : Integer, label : String]
  var id : Integer
  var nlines : Integer <- 0
  export operation addLine [content : String]
    primitive "NCCALL" "XFORMS" "FL_ADDTO_BROWSER" [] <- [id, content]    
    nlines <- nlines + 1
  end addLine
  
  export operation append [content : String]
    var old : String
    if nlines = 0 then
      self.addLine[""]
    end if
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_LINE" [old] <- [id, nlines]
    old <- old || content
    primitive "NCCALL" "XFORMS" "FL_REPLACE_BROWSER_LINE" [] <- [id, nlines, old]
  end append

  initially
    primitive "NCCALL" "XFORMS" "FL_ADD_BROWSER" [id] <- [kind, x, y, width, height, label]
  end initially
end Browser

const InputHandler <- typeobject InputHandler
  operation text[String]
end InputHandler

const Input <- class Input[kind : Integer, x : Integer, y : Integer, width : Integer, height : Integer, label : String, handler : InputHandler]
  var id : Integer

  
  
  initially
    primitive "NCCALL" "XFORMS" "FL_ADD_INPUT" [id] <- [kind, x, y, width, height, label]
  end initially
  
end Input
const XForms <- immutable object XForms	
  export operation start
  end start
  export function getDisplay -> [display : Integer]
    primitive "NCCALL" "XFORMS" "FL_GET_DISPLAY" [display] <- []
  end getDisplay
  export operation do -> [whochanged : Integer]
    primitive "NCCALL" "XFORMS" "FL_DO_FORMS" [whochanged] <- []
  end do
  initially
    primitive "NCCALL" "XFORMS" "FL_INITIALIZE" [] <- ["Who cares"]
  end initially
end XForms

export Form
export XForms
