export InputHandler, Input

const InputHandler <- typeobject InputHandler
  operation text[String]
end InputHandler

const InternalIH <- class InternalIH[who : Integer, handler : InputHandler]
  export operation CallBack[whoagain : Integer]
    var str : String
    assert who = whoagain
    primitive "NCCALL" "XFORMS" "FL_GET_INPUT" [str] <- [who]
    primitive "NCCALL" "XFORMS" "FL_SET_INPUT" [] <- [who, ""]
    handler.text[str]
  end CallBack
end InternalIH

const Input <- class Input[myxf : XForms, kind : Integer, 
    x : Integer, y : Integer, width : Integer, height : Integer,
    label : String, handler : Any]
  var id : Integer

  export function getFormId -> [r : Integer]
    r <- id
  end getFormId

  export operation callbackAlways
    primitive "NCCALL" "XFORMS" "FL_SET_OBJECT_RETURN" [] <- [id, FL_RETURN_ALWAYS]
  end callbackAlways
  
  export operation callbackChanged
    primitive "NCCALL" "XFORMS" "FL_SET_OBJECT_RETURN" [] <- [id, FL_RETURN_CHANGED]
  end callbackChanged
  
  export operation setScroll [value : Boolean]
    const ord <- value.ord
    primitive "NCCALL" "XFORMS" "FL_SET_INPUT_SCROLL" [] <- [id, ord]
  end setScroll

  export operation setFontsize [size : Integer]
    primitive "NCCALL" "XFORMS" "FL_SET_OBJECT_LSIZE" [] <- [id, size]
  end setFontsize

  initially
    primitive "NCCALL" "XFORMS" "FL_CREATE_INPUT" [id] <- [kind, x, y, width, height, label]
    if handler !== nil then
      if typeof handler *> InputHandler then
	myxf.register[id, InternalIH.create[id, view handler as InputHandler]]
      elseif typeof handler *> InternalIH then
	myxf.register[id, view handler as InternalIH]
      end if
    end if
  end initially
end Input
