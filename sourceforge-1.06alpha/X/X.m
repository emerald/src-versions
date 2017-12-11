
const int <- Integer

%       THE EVENT OPERATIONS TYPE DEFINITIONS
%       POINTER DEVICE:
      const PointerType <- typeobject MouseEvent
	operation mouse[Window, int, int, int, Boolean, Boolean, Boolean]
      end MouseEvent 

      const KeyType <- typeobject TextEvent
	operation TextRead[Window, int, int, int, String]
      end TextEvent

      const ExposeType <- typeobject ExposeEvent
	operation Expose[Window, int]
      end ExposeEvent

      const MapType <- typeobject MapEvent
	operation Map[Window, int]
      end MapEvent

      const ConfigureType <- typeobject ConfigureEvent
	operation Configure[Window, int, int, int]
      end ConfigureEvent

export PointerType, KeyType, ExposeType, MapType, ConfigureType

%Event Mask Definition for X window
 const NoEventMask	       <- 0	
 const KeyPressMask	       <- 1
 const KeyReleaseMask	       <- 2
 const ButtonPressMask	       <- 4
 const ButtonReleaseMask	       <- 8
 const EnterWindowMask	       <- 16
 const LeaveWindowMask	       <- 32
 const PointerMotionMask	       <- 64
 const PointerMotionHintMask    <- 128
 const Button1MotionMask	       <- 256
 const Button2MotionMask	       <- 512
 const Button3MotionMask	       <- 1024
 const Button4MotionMask	       <- 2048
 const Button5MotionMask	       <- 4096
 const ButtonMotionMask	       <- 8192
 const KeymapStateMask	       <- 16384
 const ExposureMask	       <- 32768
 const VisibilityChangeMask     <- 65536
 const StructureNotifyMask      <- 131072
 const ResizeRedirectMask       <- 262144
 const SubstructureNotifyMask   <- 524288
 const SubstructureRedirectMask <- 1048576
 const FocusChangeMask	       <- 2097152
 const PropertyChangeMask       <- 4194304
 const ColormapChangeMask       <- 8388608
 const OwnerGrabButtonMask      <- 16777216

const Handlertype <- Any

const Window <- typeobject Window
  operation Flush
  operation SelectInput[Integer]
  function GetSelectedInput -> [Integer]
  operation SetHandler[HandlerType]
  function  GetHandler -> [HandlerType]
  operation Event [int,BitChunk]
  function me -> [Integer]
  operation Line [ int, int, int, int]
  operation Clear
  operation Clear[int, int, int, int]
  operation Text [String,int,int]
  operation TextWidth [String] -> [int]
  operation Setfont [String]
  operation Setwidth [int]
  operation Close
  operation Unmap
  operation Relocate[int, int]
  operation Resize[int, int]
  operation Configure[int, int, int, int]
  operation Set [String]
  operation Get [String] -> [String]
  operation Batch [b : Boolean]
end Window

const Display <- typeobject Display
  operation CreateWindow[int, int, int, int, string] 
    -> [Window]
  operation Flush
  operation creategc[Integer] -> [gc]
end Display

const Gc <- typeobject Gc
  operation setfont[string] 
  operation setwidth[int] 
  function me -> [Integer]
end gc


const aow <- Array.of[Window]
const X <- object theXObject 
  const allWindows <- aow.create[~10]

  initially
    primitive "XSYS" 18 0 [] <- []
  end initially

  export operation CreateWindow [x:int,y:int,w:int,h:int,name:string] -> [win : Window]
    win <- object anXWindow
      var me : Integer
      var graphcontext : gc 
      var inputMask : Integer
      var handler : HandlerType
      
%       THE CONSTANT DEFINITIONS OF X WINDOW EVENT
      const KeyPress          <- 2
      const KeyRelease        <- 3
      const ButtonPress       <- 4
      const ButtonRelease     <- 5
      const MotionNotify      <- 6
      const EnterNotify       <- 7
      const LeaveNotify       <- 8
      const FocusIn           <- 9
      const FocusOut          <- 10
      const KeymapNotify      <- 11
      const Expose            <- 12
      const GraphicExpose     <- 13
      const NoExpose          <- 14
      const VisiblityNotify   <- 15
      const CreateNotify      <- 16
      const DEstoryNotify     <- 17
      const UnmapNotify       <- 18
      const MapNotify         <- 19
      const MapRequest        <- 20 
      const ReparentNotify    <- 21
      const ConfigureNotify   <- 22
      const ConfigureRequest  <- 23
      const GravityNotify     <- 24
      const ResizeRequest     <- 25
      const CirculateNotify   <- 26
      const CirculateRequset  <- 27
      const PropertyNotify    <- 28
      const SelectionClear    <- 29
      const SelectionRequest  <- 30
      const SelectionNotify   <- 31
      const ColormapNotify    <- 32
      const ClintMessage      <- 33
      const MappingNotify     <- 34
      const LASTEvent         <- 35

%
      export operation SetHandler [h : HandlerType]
	handler <- h
      end SetHandler

      export function GetHandler -> [h : HandlerType]
	h <- handler
      end GetHandler

      export operation Event [EventType :Integer, EventInfo : BitChunk]
	var x, y : Integer
	var l, m, r : Boolean
	var button : Integer
        var InputCharacter : String
	const stdout <- (locate 1).getStdout
        % Constant defintion of Button combination
	const Button1 <- 1
	const Button2 <- 2
	const Button3 <- 3

%	stdout.putstring["IN Event, type "]
%	stdout.putint[EventType, 0]
%	stdout.putstring["\n"]

	if handler !== nil then
	   if EventType == ButtonPress or EventType == ButtonRelease or
	      EventType == MotionNotify then
		if typeof Handler *> PointerType  then
		  % GET THE X, Y COORDINATES OF MOUSE
		  x <- EventInfo.GetSigned[256,32]
		  y <- EventInfo.GetSigned[288,32]

                   % GET THE BUTTON OF MOUSE
		   button <- EventInfo.GetSigned[416,32]
                   l <- False
                   m <- False
                   r <- False

		   if button == button1 then       
		       l <- True
		   elseif button == button2 then
		       m <- True
		   elseif button == button3 then
		       r <- True
		   end if 
		  (view handler as PointerType)
		  .mouse[anXWindow, EventType, x, y, l, m, r]
		end if     
           elseif EventType == KeyRelease then
		if typeof Handler *> KeyType  then
		  % GET THE X, Y COORDINATES OF MOUSE
		  x <- EventInfo.GetSigned[256,32]
		  y <- EventInfo.GetSigned[288,32]


                   const t <- view handler as KeyType
                   primitive "XSYS" 16 1 [InputCharacter] <- [EventInfo]
%                   stdout.putstring["Ready to call TextRead\n"]
                   t.TextRead[anXWindow, EventType, x, y, InputCharacter]

                end if 
	  elseif EventType == Expose then
		if typeof handler *> ExposeType  then
                   const t <- view handler as ExposeType
                   t.Expose[anXWindow, EventType]
                end if 
	  elseif EventType == ConfigureNotify then
		if typeof handler *> ConfigureType  then
                   const t <- view handler as ConfigureType
		   const width <- EventInfo.getSigned[256, 32]
		   const height<- EventInfo.getSigned[288, 32]
                   t.Configure[anXWindow, EventType, width, height]
                end if 
	  elseif EventType == MapNotify then
		stdout.putstring["Map\n"]
		if typeof handler *> MapType  then
                   const t <- view handler as MapType
                   t.Map[anXWindow, EventType]
                end if 
          end if 
	end if

      end Event

	initially 
	  primitive "XSYS" 5 5 [me] <- [x, y, w, h, name]
	  assert me > 0
	  graphcontext <- thexobject.creategc[me]
	end initially

      export function me -> [x : Integer]
	x <- me
      end me    

      export operation SelectInput [x : Integer]
	inputMask <- x
	primitive "XSYS" 17 2 [] <- [me, x]
      end SelectInput

      export function GetSelectedInput -> [x : Integer]
	x <- inputMask
      end GetSelectedInput

      export operation Setwidth  [ w : int ]
	graphcontext.setwidth[w]
      end setwidth

      export operation Setfont [s : string]
	graphcontext.setfont[s]
      end setfont

      export operation Line [x1 : int, y1 : int, x2 : int, y2 : int]
	var mgc : integer
	mgc <- graphcontext.me
	primitive "XSYS" 3 6 [] <- [me, x1, y1, x2, y2, mgc]
      end Line

      export operation Text[s : String , x:int, y:int ] 
	var mgc : integer
	mgc <- graphcontext.me

	primitive "XSYS" 4 5 [] <- [me, s, x, y, mgc] 
      end Text

      export operation TextWidth [s : String] -> [width : Integer]
	var mgc : integer
	mgc <- graphcontext.me
	primitive "XSYS" 24 3 [width] <- [me, s, mgc]
      end TextWidth

      export operation Flush 
	primitive "XSYS" 19 1 [] <- [me]
      end Flush
      
      export operation Unmap 
	primitive "XSYS" 6 1 [] <- [me]
      end Unmap

      export operation Clear 
	primitive "XSYS" 7 1 [] <- [me]
      end Clear

      export operation Clear[tlx : Integer, tly : Integer, width : Integer, height : Integer] 
	primitive "XSYS" 25 5 [] <- [me, tlx, tly, width, height]
      end Clear

      export operation Close 
	primitive "XSYS" 8 1 [] <- [me]
      end Close
      
      export operation Relocate [x : int, y : int]
	primitive "XSYS" 9 3[] <- [me, x, y]
      end Relocate
      
      export operation Resize [x : int, y : int]
	primitive "XSYS" 10 3 [] <- [me, x, y]
      end Resize
      
      export operation Configure [x : int, y : int, w : int, h : int]
	primitive "XSYS" 11 5 [] <- [me, x, y, w, h]
      end Configure
      
      export operation Set [s : String]
	primitive "XSYS" 23 2 [] <- [me, s]
      end Set
      
      export operation Get [s : String] -> [r : String]
	primitive "XSYS" 22 2 [r] <- [me, s]
      end Get
      
      export operation Batch [b : Boolean]
	primitive "XSYS" 20 2 [] <- [me, b]
      end Batch

    end anXWindow
  allWindows.addUpper[win]

  end CreateWindow



  export operation creategc[winid : Integer] -> [g_c : gc] 
    g_c <- monitor object agc
    
	var me : integer
        var wid : integer 
    
 	export operation setfont[ str : string ] 
    	  primitive "XSYS" 1 3 [] <- [me,wid,str]
  	end setfont

 	export operation setwidth[width : integer ] 
    	   primitive "XSYS" 2 3 [] <- [me,wid,width]
  	end setwidth

	export function me -> [x : Integer]
	  x <- me
	end me

        initially
	   wid <- winid
    	   primitive "XSYS" 0 1 [me] <- [winid]
	   assert me  > 0
        end initially
	   
    end agc
  end creategc


  export operation Flush 
    primitive "XSYS" 14 0 [] <- []
  end Flush

  process
    var bc : BitChunk <- BitChunk.create[96]
    var i : Integer
    var wn : Integer
    var EventType : Integer
    var w : Window
%   const stdout <- (locate 1).getStdout
    
    
%    stdout.putstring["\n"]
%    stdout.putstring["Alive\n"]
    loop
%   magic number call "EMXReadEvent" 
      primitive "XSYS" 15 1 [] <- [bc]

      % set wn to the window in the event x
%     stdout.putstring["after Read Event \n"]
      EventType <- bc.getSigned[0,32] 
%     for i : Integer <- 0 while  i <= 128 by i <- i + 32
%	wn <- bc.getSigned[i, 32]
%	stdout.putstring["event("]
%	stdout.putint[i,0]
%	stdout.putstring[") = "]
%	stdout.putint[wn, 0]
%	stdout.putstring["\n"]
%     end for
      i <- allWindows.lowerbound
      wn <- bc.getSigned[128,32]
%     stdout.putstring["window id = "]
%     stdout.putint[wn, 0]
%     stdout.putstring["\n"]
      loop
	exit when i > allWindows.upperbound
	w <- allWindows[i]
%	stdout.putstring["w["]
%	stdout.putint[i,0]
%	stdout.putstring["].me = "]
%	stdout.putint[w.me, 0]
%	stdout.putstring["\n"]
	if wn = w.me then
	  w.Event[EventType,bc]
	  exit
	end if
	i <- i + 1
      end loop
    end loop
  end process
end theXObject

export X, Window, Display, Gc
export NoEventMask, KeyPressMask, KeyReleaseMask, ButtonPressMask,
ButtonReleaseMask, EnterWindowMask, LeaveWindowMask, PointerMotionMask,
PointerMotionHintMask, Button1MotionMask, Button2MotionMask,
Button3MotionMask, Button4MotionMask, Button5MotionMask, ButtonMotionMask,
KeymapStateMask, ExposureMask, VisibilityChangeMask, StructureNotifyMask,
ResizeRedirectMask, SubstructureNotifyMask, SubstructureRedirectMask,
FocusChangeMask, PropertyChangeMask, ColormapChangeMask,
OwnerGrabButtonMask
