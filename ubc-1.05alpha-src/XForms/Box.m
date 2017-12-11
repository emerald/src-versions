const Box <- class Box[myxf : XForms, kind : Integer,
    x : Integer, y : Integer, w : Integer, h : Integer, l : String]
  var id : Integer
  export function getFormId -> [r : Integer]
    r <- id
  end getFormId
  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_BOX" [id] <- [kind, x, y, w, h, l]
  end initially
end Box

const Frame <- class Frame[myxf : XForms, kind : Integer,
    x : Integer, y : Integer, w : Integer, h : Integer, l : String]
  var id : Integer
  export function getFormId -> [r : Integer]
    r <- id
  end getFormId
  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_FRAME" [id] <- [kind, x, y, w, h, l]
  end initially
end Frame

export Box, Frame
