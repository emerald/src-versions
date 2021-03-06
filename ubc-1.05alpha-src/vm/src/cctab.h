/*
 * cctab.h
 *
 * THIS FILE IS AUTOMATICALLY GENERATED.  DO NOT EDIT.
 */

#ifndef _EMERALD_CCALLTAB_H
#define _EMERALD_CCALLTAB_H 1

typedef int (*ccallFunction)(void);

typedef struct CCallDescriptor {
  ccallFunction ccFunction;
  char* ccName;
  char* ccArgTemplate;
} CCallDescriptor;

extern CCallDescriptor *ccalltable[];
#define EMSTREAM 0
extern int streamOpen(void);
#define EMS_OPEN 0
extern int streamClose(void);
#define EMS_CLOSE 1
extern int streamEos(void);
#define EMS_EOS 2
extern int streamIsAtty(void);
#define EMS_ISATTY 3
extern int streamGetChar(void);
#define EMS_GETC 4
extern int streamUngetChar(void);
#define EMS_UNGETC 5
extern int streamGetString(void);
#define EMS_GETS 6
extern int streamFillVector(void);
#define EMS_FILLV 7
extern int streamPutChar(void);
#define EMS_PUTC 8
extern int streamPutInt(void);
#define EMS_PUTI 9
extern int streamWriteInt(void);
#define EMS_WRITEI 10
extern int streamPutReal(void);
#define EMS_PUTF 11
extern int streamPutString(void);
#define EMS_PUTS 12
extern int streamFlush(void);
#define EMS_FLUSH 13
extern int streamBind(void);
#define EMS_BIND 14
extern int streamAccept(void);
#define EMS_ACCEPT 15
#define STRING 1
extern int charIsAlpha(void);
#define EMCH_ISALPHA 0
extern int charIsUpper(void);
#define EMCH_ISUPPER 1
extern int charIsLower(void);
#define EMCH_ISLOWER 2
extern int charIsDigit(void);
#define EMCH_ISDIGIT 3
extern int charIsXdigit(void);
#define EMCH_ISXDIGIT 4
extern int charIsAlnum(void);
#define EMCH_ISALNUM 5
extern int charIsSpace(void);
#define EMCH_ISSPACE 6
extern int charIsPunct(void);
#define EMCH_ISPUNCT 7
extern int charIsPrint(void);
#define EMCH_ISPRINT 8
extern int charIsGraph(void);
#define EMCH_ISGRAPH 9
extern int charIsCntrl(void);
#define EMCH_ISCNTRL 10
extern int charToUpper(void);
#define EMCH_TOUPPER 11
extern int charToLower(void);
#define EMCH_TOLOWER 12
extern int stringIndex(void);
#define EMST_INDEX 13
extern int stringRIndex(void);
#define EMST_RINDEX 14
extern int stringSpan(void);
#define EMST_SPAN 15
extern int stringCSpan(void);
#define EMST_CSPAN 16
extern int stringStr(void);
#define EMST_STR 17
#define RAND 2
extern int random(void);
#define RANDOM 0
extern int srandom(void);
#define SRANDOM 1
#define MISK 3
extern int die(void);
#define UEXIT 0
extern int mgetenv(void);
#define UGETENV 1
#define REGEXP 4
#define REG_EXEC 0
#define REG_SUB 1
#define REG_COMP 2
#define XFORMS 5
#define FL_INITIALIZE 0
#define FL_BGN_FORM 1
#define FL_END_FORM 2
#define FL_SHOW_FORM 3
#define FL_DO_FORMS 4
#define FL_HIDE_FORM 5
#define FL_GET_DISPLAY 6
#define FL_CREATE_BOX 7
#define FL_CREATE_FRAME 8
#define FL_CREATE_TEXT 9
#define FL_CREATE_BITMAP 10
#define FL_SET_BITMAP_DATA 11
#define FL_SET_BITMAP_FILE 12
#define FL_CREATE_CLOCK 13
#define FL_CREATE_CHART 14
#define FL_SET_CHART_MAXNUMB 15
#define FL_CLEAR_CHART 16
#define FL_ADD_CHART_VALUE 17
#define FL_INSERT_CHART_VALUE 18
#define FL_REPLACE_CHART_VALUE 19
#define FL_SET_CHART_BOUNDS 20
#define FL_SET_CHART_AUTOSIZE 21
#define FL_CREATE_BUTTON 22
#define FL_CREATE_LIGHTBUTTON 23
#define FL_CREATE_ROUNDBUTTON 24
#define FL_CREATE_CHECKBUTTON 25
#define FL_CREATE_BITMAPBUTTON 26
#define FL_SET_BUTTON 27
#define FL_GET_BUTTON 28
#define FL_GET_BUTTON_NUMB 29
#define FL_SET_BITMAPBUTTON_DATA 30
#define FL_SET_BITMAPBUTTON_FILE 31
#define FL_CREATE_SLIDER 32
#define FL_CREATE_VALSLIDER 33
#define FL_SET_SLIDER_VALUE 34
#define FL_GET_SLIDER_VALUE 35
#define FL_SET_SLIDER_BOUNDS 36
#define FL_SET_SLIDER_STEP 37
#define FL_SET_SLIDER_SIZE 38
#define FL_SET_SLIDER_PRECISION 39
#define FL_CREATE_DIAL 40
#define FL_SET_DIAL_VALUE 41
#define FL_GET_DIAL_VALUE 42
#define FL_SET_DIAL_BOUNDS 43
#define FL_SET_DIAL_ANGLES 44
#define FL_SET_DIAL_CROSS 45
#define FL_SET_DIAL_STEP 46
#define FL_CREATE_COUNTER 47
#define FL_SET_COUNTER_VALUE 48
#define FL_GET_COUNTER_VALUE 49
#define FL_SET_COUNTER_BOUNDS 50
#define FL_SET_COUNTER_STEP 51
#define FL_SET_COUNTER_PRECISION 52
#define FL_CREATE_INPUT 53
#define FL_GET_INPUT 54
#define FL_SET_INPUT 55
#define FL_SET_INPUT_SELECTED 56
#define FL_SET_INPUT_SELECTED_RANGE 57
#define FL_SET_INPUT_CURSORPOS 58
#define FL_GET_INPUT_CURSORXPOS 59
#define FL_SET_INPUT_MAXCHARS 60
#define FL_SET_INPUT_SCROLL 61
#define FL_SETPUP_FONTSIZE 62
#define FL_SETPUP_FONTSTYLE 63
#define FL_CREATE_MENU 64
#define FL_GET_MENU 65
#define FL_GET_MENU_TEXT 66
#define FL_GET_MENU_ITEM_TEXT 67
#define FL_GET_MENU_MAXITEMS 68
#define FL_SET_MENU 69
#define FL_CLEAR_MENU 70
#define FL_ADDTO_MENU 71
#define FL_REPLACE_MENU_ITEM 72
#define FL_DELETE_MENU_ITEM 73
#define FL_SET_MENU_ITEM_MODE 74
#define FL_GET_MENU_ITEM_MODE 75
#define FL_SHOW_MENU_SYMBOL 76
#define FL_SET_MENU_POPUP 77
#define FL_CREATE_CHOICE 78
#define FL_CLEAR_CHOICE 79
#define FL_ADDTO_CHOICE 80
#define FL_DELETE_CHOICE 81
#define FL_REPLACE_CHOICE 82
#define FL_GET_CHOICE 83
#define FL_GET_CHOICE_TEXT 84
#define FL_GET_CHOICE_ITEM_TEXT 85
#define FL_GET_CHOICE_MAXITEMS 86
#define FL_SET_CHOICE 87
#define FL_SET_CHOICE_TEXT 88
#define FL_SET_CHOICE_ITEM_MODE 89
#define FL_SET_CHOICE_ALIGN 90
#define FL_SET_CHOICE_FONTSIZE 91
#define FL_SET_CHOICE_FONTSTYLE 92
#define FL_CREATE_BROWSER 93
#define FL_CLEAR_BROWSER 94
#define FL_ADDTO_BROWSER 95
#define FL_ADD_BROWSER_LINE 96
#define FL_INSERT_BROWSER_LINE 97
#define FL_DELETE_BROWSER_LINE 98
#define FL_REPLACE_BROWSER_LINE 99
#define FL_GET_BROWSER_LINE 100
#define FL_SELECT_BROWSER_LINE 101
#define FL_DESELECT_BROWSER_LINE 102
#define FL_DESELECT_BROWSER 103
#define FL_ISSELECTED_BROWSER_LINE 104
#define FL_GET_BROWSER 105
#define FL_GET_BROWSER_MAXLINE 106
#define FL_GET_BROWSER_SCREENLINES 107
#define FL_GET_BROWSER_TOPLINE 108
#define FL_SET_BROWSER_TOPLINE 109
#define FL_SET_BROWSER_XOFFSET 110
#define FL_SET_BROWSER_FONTSIZE 111
#define FL_SET_BROWSER_FONTSTYLE 112
#define FL_CREATE_TIMER 113
#define FL_SET_TIMER 114
#define FL_GET_TIMER 115
#define FL_CREATE_XYPLOT 116
#define FL_SET_OBJECT_LSIZE 117
#define FL_SET_FONT 118
#define FL_SET_OBJECT_RETURN 119
#define FL_ADD_OBJECT 120
#define FL_SET_OBJECT_SHORTCUT 121
#define FL_REDRAW_OBJECT 122
#define FL_FLUSH 123
#define FL_GET_STRING_WIDTH 124
#define FL_SET_OBJECT_BOXTYPE 125
#define FL_SET_OBJECT_LALIGN 126
#define FL_CREATE_PIXMAP 127
#define FL_SET_PIXMAP_FILE 128
#define FL_SET_PIXMAP_PIXMAP 129
#define FL_FREE_PIXMAP_PIXMAP 130
#define FL_DELETE_OBJECT 131
#define FL_SET_OBJECT_LABEL 132
#define FL_HIDE_OBJECT 133
#define FL_SHOW_OBJECT 134
#define FL_FREEZE_FORM 135
#define FL_UNFREEZE_FORM 136
#define FL_SET_OBJECT_POSITION 137
#define FL_SET_FORM_POSITION 138
#define FL_REDRAW_FORM 139
#define FL_RINGBELL 140
#define FL_CREATE_FREE 141
#define FL_FREE_FETCH 142
#define FL_FREE_WAIT 143
#define FL_DRAWMODE 144
#define FL_LINE 145
#define FL_RECTANGLE 146
#define FL_SET_OBJECT_COLOR 147
#define FL_SET_CLIPPING 148
#define FL_UNSET_CLIPPING 149
#define FL_SET_TEXT_CLIPPING 150
#define FL_UNSET_TEXT_CLIPPING 151
#define FL_ROUNDRECTANGLE 152
#define FL_OVAL 153
#define FL_PIESLICE 154
#define FL_ACTIVATE_OBJECT 155
#define FL_DEACTIVATE_OBJECT 156
#define FL_FREE_OBJECT 157
#define FL_FREE_FORM 158
#define FL_DRAW_TEXT 159
#define FL_SET_OBJECT_LSTYLE 160
#define XLIBA 6
#define XOPENDISPLAY 0
#define XCONNECTIONNUMBER 1
#define MTREGISTERFD 2
#define XTA 7
#define XTTOOLKITINITIALIZE 0
#define XTCREATEAPPLICATIONCONTEXT 1
#define XTOPENDISPLAY 2
#define XTAPPCREATESHELL 3
#define XTMANAGECHILD 4
#define XTREALIZEWIDGET 5
#define XTAPPMAINLOOP 6
#define XTSETLANGUAGEPROC 7
#define XTVAAPPINITIALIZE 8
#define XTVACREATEMANAGEDWIDGET 9
#define XTADDCALLBACK 10
#define XTRETRIEVECALLBACK 11
#define MXTSETARGINT 12
#define MXTSETARGSTRING 13
#define MXTCLEARARG 14
#define MXTVACREATEMANAGEDWIDGET 15
#define XMA 8
#define BANI 9
#define STARTSERVER 0
#define STARTCLIENT 1
#define CALLSERVER 2
#define INITCLIENT 3
#define INITSERVER 4
#define CALLSERVER2 5
#define CHECKWITHSERVER 6
#define SERVERGETSTATUS 7
#define SGETNUMPARAMS 8
#define SGETPARAM 9
#define RUNCLIENT 10
#define CGETNUMPARAMS 11
#define CGETPARAM 12
#define ASKING 13
#define TESTER 14
#define MYRISTREAM 10
#define EMS_OPEN 0
#define EMS_CLOSE 1
#define EMS_EOS 2
#define EMS_ISATTY 3
#define EMS_GETC 4
#define EMS_UNGETC 5
#define EMS_GETS 6
#define EMS_FILLV 7
#define EMS_PUTC 8
#define EMS_PUTI 9
#define EMS_WRITEI 10
#define EMS_PUTF 11
#define EMS_PUTS 12
#define EMS_FLUSH 13
#define EMS_BIND 14
#define EMS_ACCEPT 15
#endif
