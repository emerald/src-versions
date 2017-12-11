const debug <- object debug
  const cmdtab <- Array.of[string].create[20]
  var ncmds : integer
  const fout <- FormattedOutput.tostream[stdout]

  const MyTemplate <- class MyTemplate[tmpl:String]
    const names <- array.of[string].empty
    const places <- array.of[string].empty
    const types <- array.of[character].empty

    const stdout <- (locate self).getstdout
    const fout <- FormattedOutput.tostream[stdout]

    export function lowerbound[] -> [i : integer]
      i <- names.lowerbound
    end lowerbound

    export function upperbound[] -> [i : integer]
      i <- names.upperbound
    end upperbound

    export function getname[i : integer] -> [s : string]
      s <- names.getelement[i]
    end getname

    export function getplace[i : integer] -> [s : string]
      s <- places.getelement[i]
    end getplace

    export function gettype[i : integer] -> [c : character]
      c <- types.getelement[i]
    end gettype

    operation parsetemplate [tmp : string]
      var ch : character
      var offset : integer
      var strn : string
      var strp : string
      var num : integer
      var type : character

      offset <- 0
    
      loop
        exit when offset >= tmp.upperbound
    
        ch <- tmp.getelement[offset]
        exit when ch = '\0'
    
        strn,strp,offset <- self.gettmplitem[tmp, offset]
    
        names.addupper[strn]
        places.addupper[strp]
      end loop
    
      for off : integer <- 0
          while off <= (names.getelement[0]).upperbound
          by off <- off + 1

        ch <- (names.getelement[0]).getelement[off]
    
        if ch = '%' then
          type <- '0'
          num <- 0
        elseif ( ch.ord >= '0'.ord ) &
               ( ch.ord <= '9'.ord ) then
          num <- num * 10
          num <- num + ch.ord - '0'.ord
        else
          if num = 0 then
            num <- 1
          end if
    
          loop
            exit when num = 0
     
            types.addupper[ch]
            num <- num - 1
          end loop
        end if
      end for
    
      offset <- 0
    end parsetemplate

    operation gettmplitem[tmp : string, offset : integer] ->
                         [itemn : string, itemp : string, off : integer]
      var ch : character
      var offp : integer

      off <- offset

      loop
        ch <- tmp.getelement[off]

        exit when ch = '\0'
        exit when ch = '@'

        off <- off + 1
      end loop

      itemn <- tmp.getslice[offset, off - offset]

      if ch != '\0' then
        off <- off + 1
        offp <- off

        loop
          exit when off > tmp.upperbound

          ch <- tmp.getelement[off]

          exit when ch = '\0'

          off <- off + 1
        end loop

        itemp <- tmp.getslice[offp, off - offp]
      else
        itemp <- ""
      end if

      off <- off + 1
    end gettmplitem

    initially
      self.parsetemplate[tmpl]
    end initially
  end MyTemplate

  operation printIState [is : InterpreterState]
    stdout.putstring["PC = "]
    stdout.putint[is$pc, 0]
    stdout.putchar['\n']

    stdout.putstring["SP = "]
    stdout.putint[is$sp, 0]
    stdout.putchar['\n']

    stdout.putstring["FP = "]
    stdout.putint[is$fp, 0]
    stdout.putchar['\n']

    stdout.putstring["SB = "]
    stdout.putint[is$sb, 0]
    stdout.putchar['\n']

    stdout.putstring["O is a(n) "]
    stdout.putstring[nameof is$o]
    stdout.putchar['\n']

    if is$e !== nil then
      stdout.putstring["E is an "]
      stdout.putstring[nameof is$e]
      stdout.putchar['\n']
    end if
  end printIState

  % These ones assume that the thing you want is stored in 4 bytes, and
  % do the type cast to types that you might expect
  operation IndirInt [x : Integer] -> [r : Integer]
    primitive "INDIR" [r] <- [x]
  end IndirInt
  operation IndirReal [x : Integer] -> [r : Real]
    primitive "INDIR" [r] <- [x]
  end IndirReal
  operation IndirChar [x : Integer] -> [r : Character]
    primitive "INDIR" [r] <- [x]
  end IndirChar
  operation IndirBool [x : Integer] -> [r : Boolean]
    primitive "INDIR" [r] <- [x]
  end IndirBool

  % This one assumes that the thing that you want is stored in 4 bytes, but 
  % that you don't know what it is.
  operation IndirAny [x : Integer] -> [r : Any]
    primitive var "POOP" "INDIR" "PUSHCT" [r] <- [x]
  end IndirAny
  
  % This one assumes that the thing that you want is stored in 8 bytes,
  % starting at the given address
  operation IndirV [x : Integer] -> [r : Any]
    primitive var "INDIRV" [r] <- [x]
  end IndirV

  operation AnyToInt [s : Any] -> [r : Integer]
    primitive [r] <- [s]
  end AnyToInt

  operation AnyToString [s : Any] -> [r : String]
    primitive [r] <- [s]
  end AnyToString

  operation IntToString [s : Integer] -> [r : String]
    primitive [r] <- [s]
  end IntToString

  operation IntToConcreteType [s : Integer] -> [r : ConcreteType]
    primitive [r] <- [s]
  end IntToConcreteType

  operation display_var [v : Any]
    stdout.putstring[nameof v]
    stdout.putchar[':']

    if typeof v *> Integer then
      stdout.putint[self.AnyToInt[v], 0]
    elseif typeof v *> String then
      stdout.putstring[self.AnyToString[v]]
    else
      stdout.putstring["unknown"]
    end if

    stdout.putchar['\n']
  end display_var

  operation StringToInt[ s : string ] -> [i : Integer]
    var n : integer
    var ch : character

    i <- 0
    n <- s.lowerbound

    loop
      exit when n > s.upperbound

      ch <- s.getelement[n]
      exit when ch > '9'
      exit when ch < '0'

      i <- i * 10
      i <- i + ( ch.ord - '0'.ord )

      n <- n + 1
    end loop
  end StringToInt

  initially
    const msg <- "Emerald Debugger v1.0\n"
    var i : integer

    fout.printf["%s\n",{msg}]

    i <- 0

    cmdtab.setelement[i, "version"]
    i <- i + 1

    cmdtab.setelement[i, "display"]
    i <- i + 1

    % this entry (quit) must be the last one in the table !!
    cmdtab.setelement[i, "quit"]
    i <- i + 1

    ncmds <- i
  end initially

  operation getoffset[base : any, str : string] -> [addr : integer]
    var off : integer
    var ct : concretetype

    if str.getelement[str.lowerbound] = 'O' then
      off <- self.StringToInt[str.getslice[1,str.upperbound]]

      addr <- self.AnyToInt[base] + off
    else
      fout.printf["gettoffset: unknown offset type: %c\n",{str.getelement[str.lowerbound]}]
    end if
  end getoffset

  operation display_at_addr [addr : integer]
    const ivalue <- self.InDirInt[addr]
    self.display_var[ivalue]
  end display_at_addr

  operation display_compound[t : interpreterstate, ivalue : any]
    var ct : concretetype
    var addr : integer

    ct <- codeof(ivalue)

    fout.printf["name:%s\n",{ct.getname}]

    var t2 : MyTemplate <- MyTemplate.create[ct.gettemplate]

    for off : integer <- t2.lowerbound + 1
        while off <= t2.upperbound
        by off <- off + 1
      fout.printf["  %s",{t2.getname[off]}]

      if t2.gettype[off-1] = 'd' then
        addr <- self.getoffset[ ivalue, t2.getplace[off]]

        self.display_at_addr[addr]
      else
        stdout.putchar['\n']
      end if
    end for
  end display_compound

  operation findvariable [t : interpreterstate, find : string] -> [found : boolean]
    var tt : interpreterstate
    var o : integer
    var ct : concretetype
    var addr : integer
    var mytype : character

%    primitive "GETISTATE" [tt] <- []
    tt <- t
 
    ct <- codeof(tt$o)

    var tmp : MyTemplate <- MyTemplate.create[ct.gettemplate[]]

    for off : integer <- tmp.lowerbound
        while off <= tmp.upperbound
        by off <- off + 1
      o <- off
      exit when tmp.getname[off] = find
    end for

    if o <= tmp.upperbound then
      found <- true

      addr <- self.getoffset[ tt$o, tmp.getplace[o]]

      mytype <- tmp.gettype[o-1]

      if mytype = 'd' then
        self.display_at_addr[addr]
      elseif mytype = 'x' then
        const ivalue <- self.IndirAny[addr]

        self.display_compound[t, ivalue]
      elseif mytype = 'v' then
        const ivalue <- self.IndirV[addr]

        self.display_compound[t, ivalue]
      else
        fout.printf["unknown type <%c>\n",{mytype}]
      end if
    else
      found <- false
    end if
  end findvariable

  operation display [tt : interpreterstate, p1 : string, p2 : string]
    var found : boolean
    var t : InterpreterState <- tt
    fout.printf["Display %s %s\n",{p1,p2}]
%    primitive "GETISTATE" [t] <- []
    found <- self.findvariable[t, p1]

    if ! found then
      fout.printf["Unknown variable <%s>\n",{p1}]
    end if
  end display

  operation version []
    stdout.putstring["Version 0.1\n"]
  end version

  operation gettoken [line : string, start : integer] ->
                     [token : string, offset : integer]
    var ch : character

    offset <- start

    loop
      exit when offset >= line.upperbound

      ch <- line.getelement[offset]

      exit when ch = ' '
      exit when ch = '\n'

      offset <- offset + 1
    end loop

    token <- line.getslice[start, offset-start]

    loop
      exit when offset >= line.upperbound

      ch <- line.getelement[offset]

      exit when ch != ' '

      offset <- offset + 1
    end loop
  end gettoken

  operation getcmd [line : string] -> [cmd:string, p1:string, p2:string]
    var str : string
    var found : integer
    var offset : integer

    cmd,offset <- self.gettoken[line,line.lowerbound]
    p1,offset <- self.gettoken[line,offset]
    p2,offset <- self.gettoken[line,offset]

    found <- 0

    for n : integer <- 0 while n < ncmds by n <- n + 1
      if cmd.length <= cmdtab.getelement[n].length then
        str <- cmdtab.getelement[n].getslice[0,cmd.length]

        if str = cmd then
          cmd <- cmdtab.getelement[n]
          found <- 1
        end if
      end if
    end for

    if found = 0 then
      cmd <- "unknown"
    end if
  end getcmd

  process
    var t : interpreterstate
    var line : string
    var cmd : string
    var p1 : string
    var p2 : string
    const prompt <- "Debug: "

    loop
      stdout.putstring[prompt]
      stdout.flush
      line <- stdin.getstring[]

      cmd,p1,p2 <- self.getcmd[line]

      exit when cmd = cmdtab.getelement[ncmds - 1]

      primitive "GETISTATE" [t] <- []

      if cmd = "display" then
        self.display[t, p1, p2]
      elseif cmd = "version" then
        self.version[]
      end if
    end loop
  end process
end debug
