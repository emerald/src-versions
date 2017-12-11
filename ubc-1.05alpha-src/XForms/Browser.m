export Browser

const Browser <- class Browser[myxf : XForms, kind : Integer,
    x : Integer, y : Integer, width : Integer, height : Integer, label : String]

  var id : Integer
  var nlines : Integer <- 0

  export function getFormId -> [r : Integer]
    r <- id
  end getFormId

  export operation clear
    primitive "NCCALL" "XFORMS" "FL_CLEAR_BROWSER" [] <- [id]
    nlines <- 0
  end clear

  export operation addLine [content : String]
    primitive "NCCALL" "XFORMS" "FL_ADDTO_BROWSER" [] <- [id, content]
    nlines <- nlines + 1
  end addLine

  export operation addLineNoScroll [content : String]
    primitive "NCCALL" "XFORMS" "FL_ADD_BROWSER_LINE" [] <- [id, content]
    nlines <- nlines + 1
  end addLineNoScroll

  export operation insertLine [after : Integer, content : String]
    primitive "NCCALL" "XFORMS" "FL_INSERT_BROWSER_LINE" [] <- [id, after, content]
    nlines <- nlines + 1
  end insertLine

  export operation deleteLine [number : Integer]
    primitive "NCCALL" "XFORMS" "FL_DELETE_BROWSER_LINE" [] <- [id, number]
    nlines <- nlines - 1
  end deleteLine

  export operation replaceLine [number : Integer, content : String]
    primitive "NCCALL" "XFORMS" "FL_REPLACE_BROWSER_LINE" [] <- [id, number, content]
  end replaceLine

  export function getLine [number : Integer] -> [content : String]
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_LINE" [content] <- [id, number]
  end getLine

  export operation selectLine [number : Integer]
    primitive "NCCALL" "XFORMS" "FL_SELECT_BROWSER_LINE" [] <- [id, number]
  end selectLine

  export operation deselectLine [number : Integer]
    primitive "NCCALL" "XFORMS" "FL_DESELECT_BROWSER_LINE" [] <- [id, number]
  end deselectLine

  export operation deselect [number : Integer]
    primitive "NCCALL" "XFORMS" "FL_DESELECT_BROWSER" [] <- [id]
  end deselect

  export function isselectedLine [number : Integer] -> [r : Boolean]
    primitive "NCCALL" "XFORMS" "FL_ISSELECTED_BROWSER_LINE" [r] <- [id, number]
  end isselectedLine

  export function getSelection -> [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER" [r] <- [id]
  end getSelection

  export function getscreenlines -> [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_SCREENLINES" [r] <- [id]
  end getscreenlines

  export function getnlines -> [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_MAXLINE" [r] <- [id]
  end getnlines

  export function gettopline -> [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_TOPLINE" [r] <- [id]
  end gettopline

  export operation setxoffset -> [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_SET_BROWSER_XOFFSET" [r] <- [id]
  end setxoffset

  export operation settopline [r : Integer]
    primitive "NCCALL" "XFORMS" "FL_SET_BROWSER_TOPLINE" [] <- [id, r]
  end settopline

  export operation setFontSize [size : Integer]
    primitive "NCCALL" "XFORMS" "FL_SET_BROWSER_FONTSIZE" [] <- [id, size]
  end setFontSize

  export operation setFontStyle [style : Integer]
    primitive "NCCALL" "XFORMS" "FL_SET_BROWSER_FONTSTYLE" [] <- [id, style]
  end setFontStyle

  export operation append [content : String]
    var old : String
    if nlines = 0 then
      self.addLine[""]
    end if
    primitive "NCCALL" "XFORMS" "FL_GET_BROWSER_LINE" [old] <- [id, nlines]
    if old == nil then
      old <- content
    else
      old <- old || content
    end if
    primitive "NCCALL" "XFORMS" "FL_REPLACE_BROWSER_LINE" [] <- [id, nlines, old]
  end append

  export operation redraw 
    primitive "NCCALL" "XFORMS" "FL_REDRAW_OBJECT" [] <- [id]
  end redraw
  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_BROWSER" [id] <- [kind, x, y, width, height, label]
  end initially
end Browser

