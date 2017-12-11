/*
 * Xlib.h
 */

#pragma pointer_size long
#include <stdlib.h>
#include <forms.h>
#pragma pointer_size short

extern void mfl_initialize(char *progname);
extern Display *mfl_get_display(void);

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

CCALL(mfl_initialize, FL_INITIALIZE, "vS")
CCALL(fl_bgn_form, FL_BGN_FORM, "iiii")
CCALL(fl_addto_form, FL_ADDTO_FORM, "vi")
CCALL(fl_end_form, FL_END_FORM, "v")
CCALL(fl_show_form, FL_SHOW_FORM, "viiiS")
CCALL(mfl_do_forms, FL_DO_FORMS, "i")
CCALL(fl_hide_form, FL_HIDE_FORM, "vi")
CCALL(mfl_get_display, FL_GET_DISPLAY, "i")

CCALL(fl_add_box, FL_CREATE_BOX, "iiiiiiS")
CCALL(fl_add_frame, FL_CREATE_FRAME, "iiiiiiS")

CCALL(fl_add_text, FL_CREATE_TEXT, "iiiiiiS")

CCALL(fl_add_bitmap, FL_CREATE_BITMAP, "iiiiiiS")
CCALL(fl_set_bitmap_data, FL_SET_BITMAP_DATA, "viiiS")
CCALL(fl_set_bitmap_file, FL_SET_BITMAP_FILE, "viS")

CCALL(fl_add_clock, FL_CREATE_CLOCK, "iiiiiiS")

CCALL(fl_add_chart, FL_CREATE_CHART, "iiiiiiS")
CCALL(fl_set_chart_maxnumb, FL_SET_CHART_MAXNUMB, "vii")
CCALL(fl_clear_chart, FL_CLEAR_CHART, "vi")
CCALL(mfl_add_chart_value, FL_ADD_CHART_VALUE, "vifSi")
CCALL(mfl_insert_chart_value, FL_INSERT_CHART_VALUE, "viifSi")
CCALL(mfl_replace_chart_value, FL_REPLACE_CHART_VALUE, "viifSi")
CCALL(mfl_set_chart_bounds, FL_SET_CHART_BOUNDS, "viff")
CCALL(fl_set_chart_autosize, FL_SET_CHART_AUTOSIZE, "vii")

CCALL(fl_add_button, FL_CREATE_BUTTON, "iiiiiiS")
CCALL(fl_add_lightbutton, FL_CREATE_LIGHTBUTTON, "iiiiiiS")
CCALL(fl_add_pixmapbutton, FL_CREATE_PIXMAPBUTTON, "iiiiiiS")
CCALL(fl_add_roundbutton, FL_CREATE_ROUNDBUTTON, "iiiiiiS")
CCALL(fl_add_checkbutton, FL_CREATE_CHECKBUTTON, "iiiiiiS")
CCALL(fl_add_bitmapbutton, FL_CREATE_BITMAPBUTTON, "iiiiiiS")
CCALL(fl_set_button, FL_SET_BUTTON, "vii")
CCALL(fl_get_button, FL_GET_BUTTON, "ii")
CCALL(fl_get_button_numb, FL_GET_BUTTON_NUMB, "ii")
CCALL(fl_set_bitmapbutton_data, FL_SET_BITMAPBUTTON_DATA, "viiiS")
CCALL(fl_set_bitmapbutton_file, FL_SET_BITMAPBUTTON_FILE, "viS")
/* CCALL(fl_set_pixmapbutton_file, FL_SET_PIXMAPBUTTON_FILE, "viS")*/
/* CCALL(fl_set_pixmapbutton_pixmap, FL_SET_PIXMAPBUTTON_PIXMAP, "viii")*/
/* CCALL(fl_free_pixmapbutton_pixmap, FL_FREE_PIXMAPBUTTON_PIXMAP, "vi")*/

CCALL(fl_add_slider, FL_CREATE_SLIDER, "iiiiiiS")
CCALL(fl_add_valslider, FL_CREATE_VALSLIDER, "iiiiiiS")
CCALL(mfl_set_slider_value, FL_SET_SLIDER_VALUE, "vif")
CCALL(mfl_get_slider_value, FL_GET_SLIDER_VALUE, "fi")
CCALL(mfl_set_slider_bounds, FL_SET_SLIDER_BOUNDS, "viff")
CCALL(mfl_set_slider_step, FL_SET_SLIDER_STEP, "vif")
CCALL(mfl_set_slider_size, FL_SET_SLIDER_SIZE, "vif")
CCALL(fl_set_slider_precision, FL_SET_SLIDER_PRECISION, "vii")

CCALL(fl_add_dial, FL_CREATE_DIAL, "iiiiiiS")
CCALL(mfl_set_dial_value, FL_SET_DIAL_VALUE, "vif")
CCALL(mfl_get_dial_value, FL_GET_DIAL_VALUE, "fi")
CCALL(mfl_set_dial_bounds, FL_SET_DIAL_BOUNDS, "viff")
CCALL(mfl_set_dial_angles, FL_SET_DIAL_ANGLES, "viff")
CCALL(fl_set_dial_cross, FL_SET_DIAL_CROSS, "vii")
CCALL(mfl_set_dial_step, FL_SET_DIAL_STEP, "vif")

/* CCALL(fl_add_positioner, FL_CREATE_POSITIONER, "iiiiiiS")*/
/* CCALL(mfl_set_positioner_xvalue, FL_SET_POSITIONER_XVALUE, "vif")*/
/* CCALL(mfl_get_positioner_xvalue, FL_GET_POSITIONER_XVALUE, "fi")*/
/* CCALL(mfl_set_positioner_xbounds, FL_SET_POSITIONER_XBOUNDS, "viff")*/
/* CCALL(mfl_set_positioner_yvalue, FL_SET_POSITIONER_YVALUE, "vif")*/
/* CCALL(mfl_get_positioner_yvalue, FL_GET_POSITIONER_YVALUE, "fi")*/
/* CCALL(mfl_set_positioner_ybounds, FL_SET_POSITIONER_YBOUNDS, "viff")*/
/* CCALL(mfl_set_positioner_xstep, FL_SET_POSITIONER_XSTEP, "vif")*/
/* CCALL(mfl_set_positioner_ystep, FL_SET_POSITIONER_YSTEP, "vif")*/

CCALL(fl_add_counter, FL_CREATE_COUNTER, "iiiiiiS")
CCALL(mfl_set_counter_value, FL_SET_COUNTER_VALUE, "vif")
CCALL(mfl_get_counter_value, FL_GET_COUNTER_VALUE, "fi")
CCALL(mfl_set_counter_bounds, FL_SET_COUNTER_BOUNDS, "viff")
CCALL(mfl_set_counter_step, FL_SET_COUNTER_STEP, "viff")
CCALL(fl_set_counter_precision, FL_SET_COUNTER_PRECISION, "vii")

CCALL(fl_add_input, FL_CREATE_INPUT, "iiiiiiS")
CCALL(fl_get_input, FL_GET_INPUT, "si")
CCALL(fl_set_input, FL_SET_INPUT, "viS")
CCALL(fl_set_input_selected, FL_SET_INPUT_SELECTED, "vii")
CCALL(fl_set_input_selected_range, FL_SET_INPUT_SELECTED_RANGE, "viii")
CCALL(fl_set_input_cursorpos, FL_SET_INPUT_CURSORPOS, "viii")
CCALL(mfl_get_input_cursorxpos, FL_GET_INPUT_CURSORXPOS, "ii")
CCALL(fl_set_input_maxchars, FL_SET_INPUT_MAXCHARS, "vii")
CCALL(fl_set_input_scroll, FL_SET_INPUT_SCROLL, "vii")

CCALL(fl_setpup_fontsize, FL_SETPUP_FONTSIZE, "vi")
CCALL(fl_setpup_fontstyle, FL_SETPUP_FONTSTYLE, "vi")

CCALL(fl_add_menu, FL_CREATE_MENU, "iiiiiiS")
CCALL(fl_get_menu, FL_GET_MENU, "ii")
CCALL(fl_get_menu_text, FL_GET_MENU_TEXT, "si")
CCALL(fl_get_menu_item_text, FL_GET_MENU_ITEM_TEXT, "sii")
CCALL(fl_get_menu_maxitems, FL_GET_MENU_MAXITEMS, "ii")
CCALL(fl_set_menu, FL_SET_MENU, "viS")
CCALL(fl_clear_menu, FL_CLEAR_MENU, "vi")
CCALL(fl_addto_menu, FL_ADDTO_MENU, "viS")
CCALL(fl_replace_menu_item, FL_REPLACE_MENU_ITEM, "viiS")
CCALL(fl_delete_menu_item, FL_DELETE_MENU_ITEM, "vii")
CCALL(fl_set_menu_item_mode, FL_SET_MENU_ITEM_MODE, "viii")
CCALL(fl_get_menu_item_mode, FL_GET_MENU_ITEM_MODE, "iii")
CCALL(fl_show_menu_symbol, FL_SHOW_MENU_SYMBOL, "vii")
CCALL(fl_set_menu_popup, FL_SET_MENU_POPUP, "vii")


CCALL(fl_add_choice, FL_CREATE_CHOICE, "iiiiiiS")
CCALL(fl_clear_choice, FL_CLEAR_CHOICE, "vi")
CCALL(fl_addto_choice, FL_ADDTO_CHOICE, "viS")
CCALL(fl_delete_choice, FL_DELETE_CHOICE, "vii")
CCALL(fl_replace_choice, FL_REPLACE_CHOICE, "viiS")
CCALL(fl_get_choice, FL_GET_CHOICE, "ii")
CCALL(fl_get_choice_text, FL_GET_CHOICE_TEXT, "si")
CCALL(fl_get_choice_item_text, FL_GET_CHOICE_ITEM_TEXT, "sii")
CCALL(fl_get_choice_maxitems, FL_GET_CHOICE_MAXITEMS, "ii")
CCALL(fl_set_choice, FL_SET_CHOICE, "vii")
CCALL(fl_set_choice_text, FL_SET_CHOICE_TEXT, "viS")
CCALL(fl_set_choice_item_mode, FL_SET_CHOICE_ITEM_MODE, "viii")
CCALL(fl_set_choice_align, FL_SET_CHOICE_ALIGN, "vii")
CCALL(fl_set_choice_fontsize, FL_SET_CHOICE_FONTSIZE, "vii")
CCALL(fl_set_choice_fontstyle, FL_SET_CHOICE_FONTSTYLE, "vii")

CCALL(fl_add_browser, FL_CREATE_BROWSER, "iiiiiiS")
CCALL(fl_clear_browser, FL_CLEAR_BROWSER, "vi")
CCALL(fl_addto_browser, FL_ADDTO_BROWSER, "viS")
CCALL(fl_add_browser_line, FL_ADD_BROWSER_LINE, "viS")
CCALL(fl_insert_browser_line, FL_INSERT_BROWSER_LINE, "viiS")
CCALL(fl_delete_browser_line, FL_DELETE_BROWSER_LINE, "vii")
CCALL(fl_replace_browser_line, FL_REPLACE_BROWSER_LINE, "viiS")
CCALL(fl_get_browser_line, FL_GET_BROWSER_LINE, "sii")
CCALL(fl_select_browser_line, FL_SELECT_BROWSER_LINE, "vii")
CCALL(fl_deselect_browser_line, FL_DESELECT_BROWSER_LINE, "vii")
CCALL(fl_deselect_browser, FL_DESELECT_BROWSER, "vi")
CCALL(fl_isselected_browser_line, FL_ISSELECTED_BROWSER_LINE, "iii")
CCALL(fl_get_browser, FL_GET_BROWSER, "ii")
CCALL(fl_get_browser_maxline, FL_GET_BROWSER_MAXLINE, "ii")
CCALL(fl_get_browser_screenlines, FL_GET_BROWSER_SCREENLINES, "ii")
CCALL(fl_get_browser_topline, FL_GET_BROWSER_TOPLINE, "ii")
CCALL(fl_set_browser_topline, FL_SET_BROWSER_TOPLINE, "vii")
CCALL(fl_set_browser_xoffset, FL_SET_BROWSER_XOFFSET, "vii")
CCALL(fl_set_browser_fontsize, FL_SET_BROWSER_FONTSIZE, "vii")
CCALL(fl_set_browser_fontstyle, FL_SET_BROWSER_FONTSTYLE, "vii")

CCALL(fl_add_timer, FL_CREATE_TIMER, "iiiiiiS")
CCALL(mfl_set_timer, FL_SET_TIMER, "vif")
CCALL(mfl_get_timer, FL_GET_TIMER, "fi")

CCALL(fl_add_xyplot, FL_CREATE_XYPLOT, "iiiiiiS")

CCALL(fl_set_object_lsize, FL_SET_OBJECT_LSIZE, "vii")
CCALL(fl_set_font, FL_SET_FONT, "vii")
CCALL(fl_set_object_return, FL_SET_OBJECT_RETURN, "vii")
CCALL(fl_add_object, FL_ADD_OBJECT, "vii")
CCALL(fl_set_object_shortcut, FL_SET_OBJECT_SHORTCUT, "viSi")
CCALL(fl_redraw_object, FL_REDRAW_OBJECT, "vi")
CCALL(mfl_flush, FL_FLUSH, "v")
CCALL(fl_get_string_width, FL_GET_STRING_WIDTH, "iiiSi")
CCALL(fl_set_object_boxtype, FL_SET_OBJECT_BOXTYPE, "vii")
CCALL(fl_set_object_lalign, FL_SET_OBJECT_LALIGN, "vii")

CCALL(fl_add_pixmap, FL_CREATE_PIXMAP, "iiiiiiS")
CCALL(fl_set_pixmap_file, FL_SET_PIXMAP_FILE, "viS")
CCALL(fl_set_pixmap_pixmap, FL_SET_PIXMAP_PIXMAP, "viii")
CCALL(fl_free_pixmap_pixmap, FL_FREE_PIXMAP_PIXMAP, "vi")
CCALL(fl_delete_object, FL_DELETE_OBJECT, "vi")
CCALL(fl_set_object_label, FL_SET_OBJECT_LABEL, "viS")
CCALL(fl_hide_object, FL_HIDE_OBJECT, "vi")
CCALL(fl_show_object, FL_SHOW_OBJECT, "vi")
CCALL(fl_freeze_form, FL_FREEZE_FORM, "vi")
CCALL(fl_unfreeze_form, FL_UNFREEZE_FORM, "vi")
CCALL(fl_set_object_position, FL_SET_OBJECT_POSITION, "viii")
CCALL(fl_set_form_position, FL_SET_FORM_POSITION, "viii")
CCALL(fl_redraw_form, FL_REDRAW_FORM, "vi")
CCALL(mfl_ringbell, FL_RINGBELL, "v")

CCALL(mfl_add_free, FL_CREATE_FREE, "iiiiiiS")
CCALL(mfl_free_fetch, FL_FREE_FETCH, "iii")
CCALL(mfl_free_wait, FL_FREE_WAIT, "viX")
CCALL(fl_drawmode, FL_DRAWMODE, "vi")
CCALL(fl_line, FL_LINE, "viiiii")
CCALL(fl_rectangle, FL_RECTANGLE, "viiiiii")
CCALL(fl_set_object_color, FL_SET_OBJECT_COLOR, "viii")
CCALL(fl_set_clipping, FL_SET_CLIPPING, "viiii")
CCALL(fl_unset_clipping, FL_UNSET_CLIPPING, "v")
CCALL(mfl_set_text_clipping, FL_SET_TEXT_CLIPPING, "viiii")
CCALL(mfl_unset_text_clipping, FL_UNSET_TEXT_CLIPPING, "v")
CCALL(fl_roundrectangle, FL_ROUNDRECTANGLE, "viiiiii")
CCALL(fl_oval, FL_OVAL, "viiiiii")
CCALL(fl_pieslice, FL_PIESLICE, "viiiiiiii")
CCALL(fl_activate_object, FL_ACTIVATE_OBJECT, "vi")
CCALL(fl_deactivate_object, FL_DEACTIVATE_OBJECT, "vi")
CCALL(fl_free_object, FL_FREE_OBJECT, "vi")
CCALL(fl_free_form, FL_FREE_FORM, "vi")
CCALL(fl_drw_text, FL_DRAW_TEXT, "viiiiiiiiS")
CCALL(fl_set_object_lstyle, FL_SET_OBJECT_LSTYLE, "vii")
CCALL(fl_set_form_size, FL_SET_FORM_SIZE, "viii")
CCALL(fl_trigger_object, FL_TRIGGER_OBJECT, "vi")
CCALL(mfl_get_width, FL_GET_OBJECT_WIDTH, "ii")
