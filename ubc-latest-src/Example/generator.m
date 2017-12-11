% ---------- class mapclass -----------

const mapclass <- class mapclass
  const vec <- vector.of[integer]
  const vecvec <- vector.of[vector.of[integer]]
  attached  var private_map : vector.of [vector.of [integer]]
  
  export operation getprivate_map ->[e:vector.of[vector.of[Integer]]]
    e<-private_map
  end getprivate_map

  export operation init [xdim : integer, ydim:integer] 
  private_map <- vecvec.create[xdim]
  for i: integer <-0 while i< xdim by i <- i+1
    private_map[i] <- vec.create[ydim]
    end for
   end init
 
   export operation set[x:integer,y:integer,val:integer]
    %if x, y within bounds
    private_map[x][y]<-val
    end set
  
  export operation get[x:integer,y:integer]->[val:integer]
    %if x,y within bounds
    val<-private_map[x][y]
  end get
  
  export operation overlay[x:integer, y:integer,xp:integer,yp:integer,in_map:vector.of[vector.of[integer]]]
    %check bounds
    for i:integer<-x while i<(x+xp) by i<-i+1
      for j:integer<-y while j<(y+yp) by j<-j+1
        self.set[i,j,in_map[i-x][j-y]]
      end for
    (locate self)$stdout.putstring[i.AsString||"\n"] (locate self)$stdout.flush
    end for
  end overlay
end mapclass

% ---------- class complex --------------

const complex <- class Complex[r:Real, i:Real]
  export function +[other: Complex]->[e: Complex]
    e<-Complex.create[other.GetReal+r, other.GetImag+i]
   end +
  export function *[other: Complex]->[e:Complex]
    e<-Complex.create[other.GetReal*r-other.GetImag*i,r*other.GetImag+i*other.GetReal]
  end *
  export function GetReal->[e: Real]
    e<-r
  end GetReal
  export function GetImag->[e:Real]
    e<-i
  end GetImag
  export function sqrange->[e:Real]
    e<-(r*r+i*i)
  end sqrange
  export operation set[e:Real,f:Real]
    r<-e
    i<-f
  end set
  export operation get ->[e:Real,f:Real]
    e <- r
    f <- i
  end get      
end Complex


%---------------------------------------------------------------------
const mastermap <- mapclass.create

const home <- locate mastermap


const global <- object global
  var zonewidth:Integer
  var xsize:Integer
  var ysize:Integer
  var NoOfNodes:Integer
  var mapcount:Integer<-0 
  var starttime:Time

  export operation getzonewidth ->[e:Integer]
    e<-zonewidth
  end getzonewidth
  export operation setzonewidth [e:Integer]
    zonewidth<-e
  end setzonewidth
  export operation getxsize ->[e:Integer]
    e<-xsize
  end getxsize
  export operation setxsize[e:Integer]
    xsize<-e
  end setxsize
  export operation getysize ->[e:Integer]
    e<-ysize
  end getysize
  export operation setysize[e:Integer]
    ysize<-e
  end setysize
  export operation getnoofnodes->[e:integer]
    e<-NoOfNodes
  end getnoofnodes
  export operation setnoofnodes[e:Integer]
    NoOfNodes<-e
  end setnoofnodes
  export operation setmapcount[e:Integer]
    mapcount<-e
  end setmapcount
  export operation getmapcount ->[e:Integer]
    e<-mapcount
  end getmapcount
  export operation getstarttime ->[e:Time]
   e<-starttime
  end getstarttime
  export operation setstarttime [e:Time]
    starttime<-e
  end setstarttime
end global

%---------------------------------------------------------------------

%-------------- colector --------------------

const colector <- monitor object colector
  export operation scoop[zone:Integer,map:mapclass]
    var xoffset:Integer

    stdout.putstring["scoping on "||global$mapcount.asString||" at "]
    stdout.putstring[(home.getTimeOfDay-global$starttime).asString||"\n"]
    stdout.flush

    xoffset <- zone*global$zonewidth
    stdout.putstring["overlay from:"||xoffset.AsString||"\n"] stdout.flush
    mastermap.overlay[xoffset,0,global$zonewidth,global$ysize,map$private_map]
    global$mapcount<-(global$mapcount+1)
    stdout.putstring["(scoped) on "||global$mapcount.asString||" at "]
    stdout.putstring[(home.getTimeOfDay-global$starttime).asString||"\n"]
    stdout.flush
    if global$mapcount=global$NoOfNodes then
      begin
        stdout.putstring["saving file...\n"] stdout.flush       
        stdout.putstring["total time:"||(home.getTimeOfDay-global$starttime).asString||"\n"]
        const fp <-OutStream.toUnix["mandel.pgm","wb"]
        fp.putstring["P1\n"]
        fp.putstring[global$xsize.asstring||" "||global$ysize.asstring||"\n"]

        for y:integer<-0 while y<global$ysize by y<-y+1
          for x:integer<-0 while x<global$xsize by x<-x+1  
            fp.putint[mastermap.get[x,y],1]
          end for
        end for
        fp.close
      end
    end if
  end scoop
end colector

%---------------- generator -------------------

const generator <- class genclass
  attached var map :mapclass 
  attached var zone:Integer
  attached var xmin:Real <- 0.0
  attached var dx:Real <- 0.0
  attached var ymin:Real <- 0.0
  attached var dy:Real <- 0.0
  attached var xpixels:Integer <- 0
  attached var ypixels:Integer <- 0
  attached var it:Integer <- 0
  attached var trap:Boolean <- true
  attached var ry:Real <- 0.0
  attached var rx:Real <- 0.0
  attached var a :complex <- complex.create[0.0,0.0]
  attached var z :complex <- complex.create[0.0,0.0]

  initially
    map <- mapclass.create  
  end initially 

  process
    loop
      exit when !trap
    end loop

    (locate self)$stdout.putstring["GoGen! "||(locate self)$name] stdout.flush
    (locate self)$stdout.putstring[" "||xmin.AsString||" "||xpixels.AsString||"\n"]
    rx<-xmin
    for x:Integer<-0 while x<xpixels by x<-x+1
      ry<-ymin
      for y:Integer<-0 while y<ypixels by y<-y+1
        a.set[rx,ry]
        z.set[rx,ry]
        for j:integer<-1 while j<it and z.sqrange<4.0 by j<-j+1
          z<-(z*z)+a
        end for
        if z.sqrange>=4.0 then
          map.set[x,y,1]
        else
          map.set[x,y,0]
        end if
        ry<-ry+dy
      end for
      rx<-rx+dx
      (locate self)$stdout.putstring["+"] (locate self)$stdout.flush
    end for

    (locate self)$stdout.putstring["gendone, moving home\n"] (locate self)$stdout.flush
  (locate self)$stdout.putstring["done at"||(home.getTimeOfDay-global$starttime).asString||"\n"] (locate self)$stdout.flush


    % original solution, works with 1.04 alpha
    % refix self at mastermap
    % colector.scoop[zone, map]
   
    % alternative solution, do not move generator but call scoop with
    % 'move' parameters 
    %  unfix self
    %  colector.scoop[move zone,move map]

    % optimized alternative solution, do not move 'home generator'
      unfix self
      if ((locate self)==(locate mastermap)) then
        colector.scoop[zone, map]
      else
        colector.scoop[move zone, move map]
      end if

    (locate self)$stdout.putstring["scoped\n"] (locate self)$stdout.flush
  end process

  export operation setwindow[x1:Real,x2:Real,y1:Real,y2:Real,itt:Integer,xp:Integer,yp:Integer,zon:Integer]
    zone<-zon
    xmin<-x1
    dx<-(x2-x1)/xp.AsReal
    xpixels<-xp
    ymin<-y1
    dy<-(y2-y1)/yp.AsReal
    ypixels<-yp
    it<-itt
    map.init[xp,yp]
    trap<-false
  end setwindow

  export operation pinpoint[e:Node]
    fix self at e
  end pinpoint

end genclass

const generatortype <- typeobject generatortype
  operation setwindow[Real,Real,Real,Real,Integer,Integer,Integer,Integer]
  operation pinpoint[Node]
end generatortype

%------------- master ----------------------------

const master <- object masterobject
  var mapcount:Integer <- 0
  var NList: NodeList
  var maxNodes: Integer
  var NoOfNodes:Integer
  var GenList : vector.of[generatortype]
  var xmin:Real
  var xmax:Real
  var ymin:Real
  var ymax:Real
  var xsize:Integer
  var ysize:Integer
  var it:Integer
  var dx:Real

  initially
    NList <- (locate self).getActiveNodes
    maxNodes <- NList.upperbound +1
  end initially

  export operation params[p1:Integer,p2:Integer,p3:Integer]
    xsize<-p1
    ysize<-p2
    global$xsize<-p1
    global$ysize<-p2
    mastermap.init[p1,p2]
    it<-p3
  end params

  export operation setwindow[p1:Real,p2:Real,p3:Real,p4:Real]
    xmin<-p1
    xmax<-p2
    ymin<-p3
    ymax<-p4
  end setwindow

  export operation mandelbroot[nodes:Integer]
    stdout.putstring["mandelbroot ready\n"] stdout.flush
    if nodes>MaxNodes then
      stdout.putstring["warning cannot split to "||nodes.asString||" on "||MaxNodes.AsString||"\n"]
    end if
    stdout.putstring["creating dx  by / with "||  Nodes.AsReal.AsString ||"\n"] stdout.flush 
    dx<-(xmax-xmin)/(Nodes.AsReal) 

    NoOfNodes<-nodes
    global$noofnodes<-nodes
    global$zonewidth<-global$xsize/nodes

    GenList<-vector.of[generatortype].create[Nodes]
    stdout.putstring["generating "||Nodes.AsString||" generators\n"]
    stdout.flush
    for i:Integer <-0 while i<Nodes by i<-i+1
      GenList[i]<-Generator.create
      stdout.putstring["1 done\n"] stdout.flush
      %move GenList[i] to NList[i]$theNode
      GenList[i].pinpoint[Nlist[i]$theNode]
      % GenList[i].pinpoint[home]
      GenList[i].setwindow[xmin+dx*(i.AsReal),xmin+dx*(i+1).AsReal,ymin,ymax,it,xsize/Nodes,ysize,i]
    end for

   for i:Integer <-0 while i<Nodes by i<-i+1
     stdout.putstring["generator at:"||(locate GenList[i])$name||"\n"]
   end for
  end mandelbroot 
end masterobject

const runner <- object runner
  initially
    stdout.putString["running...\n"] stdout.flush
    master.params[400,200,50]
    stdout.PutString["params done...\n"] stdout.flush
    master.setwindow[-2.5,1.0,-1.0,1.0]
    stdout.putstring["setwindow done...\n"] stdout.flush
    master.mandelbroot[4]
    stdout.putstring["mandelbroot called\n"] stdout.flush
    global$starttime<-home.getTimeOfDay
    stdout.putstring["time:"||global$starttime.asString||"\n"] stdout.flush
  end initially
end runner
