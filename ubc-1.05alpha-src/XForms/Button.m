const Button <- class Button[myxf : XForms, kind : Integer,
    x : Integer, y : Integer, w : Integer, h : Integer, l : String,
    handler : CallBackHandler]
  var id : Integer
  export function getFormId -> [r : Integer]
    r <- id
  end getFormId
  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_BUTTON" [id] <- [kind, x, y, w, h, l]
    myxf.register[id, handler]
  end initially
end Button

const LightButton <- class LightButton[myxf : XForms, kind : Integer,
    x : Integer, y : Integer, w : Integer, h : Integer, l : String,
    handler : CallBackHandler]
  var id : Integer
  export function getFormId -> [r : Integer]
    r <- id
  end getFormId
  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_LIGHTBUTTON" [id] <- [kind, x, y, w, h, l]
    myxf.register[id, handler]
  end initially
end LightButton

export Button, LightButton
