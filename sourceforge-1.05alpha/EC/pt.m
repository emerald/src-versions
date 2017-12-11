

const Compiler <- immutable object Compiler
  const CType <- typeobject CType
    operation compile[fileName : String]
    operation eval[code : String]
    operation load[filename : String]
    operation option[name : String, value : Boolean]
    operation setup [OutStream]
    function getenv -> [r : Environment]
  end CType
  export function getSignature -> [r : Signature]
    r <- CType
  end getSignature
  export operation create -> [r : CType]
    r <- object aCompiler
      const it <- IdentTable.create
      var stdout : OutStream
      var fstdout : FormattedOutput
      var scan : Scanner

      const myenv <- object myenv
	  field externalDirectory : Directory
	  field fileName : Tree
	  field itable : IdentTable
	  field nextnumber : Integer
	  field nErrors : Integer <- 0
	  field root : Tree
	  field verbose : Boolean <- false
	  field tracegenerate : Boolean <- false
	  field executenow : Boolean <- false
	  field generatebuiltin : Boolean <- false
	  field tracegeneratedbuiltin : Boolean <- false
	  field traceparse : Boolean <- false
	  field dumpremovesugar : Boolean <- false
	  field dumpassigntypes : Boolean <- false
	  field traceassigntypes : Boolean <- false
	  field dumpevaluatemanifests : Boolean <- false
	  field traceevaluatemanifests : Boolean <- false
	  field optimizeinvocexecute : Boolean <- false
	  field dumpsymbols : Boolean <- false
	  field tracesymbols : Boolean <- false
	  field tracepasses : Boolean <- false
	  field compilingbuiltins : Boolean <- false
	  field compilingcompiler : Boolean <- false
	  field generateviewchecking : Boolean <- true
	  field tracetoplevel : Boolean <- true
	  field tracetypecheck : Boolean <- false
	  field traceallocation : Boolean <- false
	  field traceinline : Boolean <- false
	  field tracesizes : Boolean <- false
	  field dotypecheck : Boolean <- true
	  field warnShadows : Boolean <- true
	  field why : Boolean <- true
	  field fn : String <- "no file name"
	  field scan : Scanner
	  field rootst : SymbolTable
	  field exportTree : Boolean <- true
	  field explainNonManifests : Boolean <- false
	  field perFile : Boolean <- true
	  field nameSpaceFile : String <- nil
	  field traceCode : Boolean <- false
	  field doCompilation : Boolean <- true
	  field doGeneration : Boolean <- true
	  field generateConcurrent : Boolean <- false
	  field generateDebugInfo : Boolean <- true
	  field generateATs : Boolean <- true
	  field padByteCodes : Boolean <- true
	  field useAbCons : Boolean <- false
	  field needMoreEvaluateManifest : Boolean <- true
	  field implicitlyDefineExternals : Boolean <- false
	  field thisObject : Tree <- nil
	  field conformtable : IIBTable <- IIBTable.create[128]
	  field fstdout : FormattedOutput
	  field stdout : OutStream
	  field doingIdsEarly : Boolean <- false
	  const defer <- record defer
	    var p : Invoc
	    var aparam : Any
	    var apsym : Any
	    var avalue : Any
	    var i : Integer
	  end defer
	  const alldefers <- Array.of[defer].empty
  
	  export function getInvoc -> [r : InvocType]
	    r <- Invoc
	  end getInvoc

	  export function getAtlit -> [r : AtlitType]
	    r <- Atlit
	  end getAtlit

	  export function getAny -> [r : Tree]
	    r <- BuiltinLit.create[0, 1]$instAT
	  end getAny

	  export operation newid -> [r : Integer]
	    r <- nextnumber nextnumber <- nextnumber + 1
	  end newid

	  export operation error [s : String]
	    const line : String <- scan.line
	    nErrors <- nErrors + 1
	    fstdout.printf["\"%s\", line %d: syntax error\n", { fn, scan.lineNumber }]
	    if s != "syntax error" then
	      fstdout.printf[s, nil]
	      stdout.putchar['\n']
	    end if
	    if line.length = 0 or line[0] == Character.literal[0] then
	      stdout.putstring["<EOF>\n"]
	    else
	      if line[line.upperbound] = '\0' then
		fstdout.printf["%s\n", {line[0, line.upperbound]}]
	      elseif line[line.upperbound] != '\n' then
		fstdout.printf["%s\n", {line}]
	      else
		fstdout.printf["%s", {line}]
	      end if
	    end if
	    for i : Integer <- 0 while i < scan.position and i < line.length by i <- i + 1
	      if line[i] == '\t' then
		stdout.putchar['\t']
	      else
		stdout.putchar[' ']
	      end if
	    end for
	    stdout.putstring["^\n"]
	  end error

	  export operation errorf [s : String, v : RISA]
	    const line : String <- scan.line
	    nErrors <- nErrors + 1
	    fstdout.printf["Syntax Error \"%s\", line %d\n", { fn, scan.lineNumber }]
	    if s != "syntax error" then
	      fstdout.printf[s, v]
	      stdout.putchar['\n']
	    end if
	    if line[0] == Character.literal[255] then
	      stdout.putstring["<EOF>\n"]
	    else
	      fstdout.printf["%s", {line}]
	    end if
	    for i : Integer <- 0 while i < scan.position by i <- i + 1
	      if line[i] == '\t' then
		stdout.putchar['\t']
	      else
		stdout.putchar[' ']
	      end if
	    end for
	    stdout.putstring["^\n"]
	  end errorf

	  export operation warningf [s : String, v : RISA]
	    const line : String <- scan.line
	    fstdout.printf["\"%s\", line %d Warning: ", { fn, scan.lineNumber }]
	    if s != "syntax error" then
	      fstdout.printf[s, v]
	    end if
	    stdout.putchar['\n']
	    if line[0] == Character.literal[255] then
	      stdout.putstring["<EOF>\n"]
	    else
	      fstdout.printf["%s", {line}]
	    end if
	    for i : Integer <- 0 while i < scan.position by i <- i + 1
	      if line[i] == '\t' then
		stdout.putchar['\t']
	      else
		stdout.putchar[' ']
	      end if
	    end for
	    stdout.putstring["^\n"]
	  end warningf

	  export operation SemanticError [ln : Integer, s : String, v : RISA]
	    nErrors <- nErrors + 1
	    fstdout.printf["\"%s\", line %d: ", { fn, ln }]
	    fstdout.printf[s, v]
	    stdout.putchar['\n']
	  end SemanticError

	  export operation Warning [ln : Integer, s : String, v : RISA]
	    fstdout.printf["\"%s\", line %d Warning: ", { fn, ln }]
	    fstdout.printf[s, v]
	    stdout.putchar['\n']
	  end Warning

	  export operation Info [ln : Integer, s : String, v : RISA]
	    fstdout.printf["\"%s\", line %d: ", { fn, ln }]
	    fstdout.printf[s, v]
	    stdout.putchar['\n']
	  end Info
	  
	export operation pass [s : String, v : RISA]
	  if self$tracepasses then
	    self$fstdout.printf[s, v]
	  end if
	end pass

	export operation tassignTypes [s : String, v : RISA]
	  if self$traceassigntypes then
	    self$fstdout.printf[s, v]
	  end if
	end tassignTypes

	export operation tinline [s : String, v : RISA]
	  if self$traceinline then
	    self$fstdout.printf[s, v]
	  end if
	end tinline

	export operation ttypeCheck [s : String, v : RISA]
	  if self$tracetypecheck then
	    self$fstdout.printf[s, v]
	  end if
	end ttypeCheck

	export operation tgenerate [s : String, v : RISA]
	  if self$tracegenerate then
	    self$fstdout.printf[s, v]
	  end if
	end tgenerate

	export operation tAllocation [s : String, v : RISA]
	  if self$traceAllocation then
	    self$fstdout.printf[s, v]
	  end if
	end tAllocation

	export operation printf [s : String, v : RISA]
	  self$fstdout.printf[s, v]
	end printf

	export operation done[theWholeParseTree : Tree]
	  const q : AoT <- AoT.create[~10]
	  const VofCT <- Vector.of[ConcreteType]
	  var   vct : VofCT
	  const VofCO <- Vector.of[CreateOne]
	  var   vco : VofCO
	  var ctct : CTCode
	  var ct : typeobject T
	    function  fetchIndex -> [Integer]
	    operation getIndex[Integer, CPQueue]
	    operation cpoint [OutStream]
	    function  asString -> [String]
	    operation generateBuiltin -> [Any]
	  end T
	  const hasDoAllocation <- typeobject hasDoAllocation
	    operation doAllocation
	  end hasDoAllocation
	  var da : hasDoAllocation
	  var evalPasses : Integer
	  var findManifestPasses : Integer <- 0
	  var myCP : CP
  
	  self$root <- theWholeParseTree
	  % Parsing
  
	  if verbose then self.pass["Done parsing\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  if self$traceparse then
	    self$root.print[self$stdout, 0]
	  end if
  
	  % Remove Sugar
  
	  self.pass["Removing sugar ...\n", nil]
	  self$root <- self$root.removeSugar[nil]
	  if verbose then self.pass["Done removing sugar\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  if self$dumpremovesugar then
	    self$root.print[self$stdout, 0]
	  end if
  
	  % Define Symbols
  
	  if self$rootst == nil then
	    self$rootst <- builtinlit.init
	  else
	    self$rootst.reInitialize
	  end if
  
	  self.pass["Defining symbols ...\n", nil]
	  self$root.defineSymbols[self$rootst]
	  if verbose then self.pass["Done defining symbols\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  invoccache.resetForSourceFile[(view filename as Literal)$str]

	  % Resolve Symbols
  
	  self.pass["Resolving symbols ...\n", nil]
	  self$root.resolveSymbols[self$rootst, 0]
	  if verbose then self.pass["Done resolving symbols\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  if self$tracesymbols then
	    self$root.print[self$stdout, 0]
	  end if
  
	  % Assign ids (the first time)
	  doingIdsEarly <- true

	  self.pass["Assigning ids ...\n", nil]
	  self$root.assignIds[self$rootst]
	  if verbose then self.pass["Done assigning ids\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
	  doingIdsEarly <- false
  
	  % Do manifest objects
  
	  self.pass["Finding manifest objects ...\n", nil]
	  findManifestPasses <- 1
	  loop
	    self.pass["  Pass %d\n", {findManifestPasses}]
	    exit when !self$root.findManifests
	    findManifestPasses <- findManifestPasses + 1
	  end loop
	  if verbose then self.pass["Done finding manifest objects\n", nil] end if
	  
	  self.pass["Evaluating manifest objects ...\n", nil]
	  if self$dumpevaluatemanifests then
	    self$root.print[self$stdout, 0]
	  end if
  
	  evalPasses <- 1
	  self$needMoreEvaluateManifest <- true
	  loop
	    exit when ! self$needMoreEvaluateManifest
	    exit when evalPasses > findManifestPasses + 10
	    if evalPasses = findManifestPasses + 10 then
	      self$tracepasses <- true
	      self$traceevaluatemanifests <- true
	    end if
	    self.pass["  Pass %d\n", {evalPasses}]
	    self$needMoreEvaluateManifest <- false
	    self$root.evaluateManifests
	    evalPasses <- evalPasses + 1
	    exit when self.getnErrors[] > 0
	  end loop
	  if evalPasses > findManifestPasses + 10 then
	    self.SemanticError[1, "Something is surely wrong, probably a circular definition\nof a symbol.  Look for a declaration like const sconst <- SConst and\nfix it.  Remember that Emerald is not case sensitive", nil]
	  end if
	  if verbose then self.pass["Done manifest objects\n", nil] end if
  
	  if self$dumpevaluatemanifests then
	    self$root.print[self$stdout, 0]
	  end if
  
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
	  
	  % Type Assignment
  
	  self.pass["Assigning types ...\n", nil]
	  if self$dumpassigntypes then
	    self$root.print[self$stdout, 0]
	  end if
	  self$root.assignTypes
	  if verbose then self.pass["Done assigning types\n", nil] end if
%	  if self.getnErrors[] > 0 then
%	    if self$verbose then
%	      self$root.print[self$stdout, 0]
%	    end if
%	    return
%	  end if
  
	  % Type Checking
  
	  self.pass["Doing type checking ...\n", nil]
	  if self$dotypecheck or self$useAbCons then
	    self$root.typeCheck
	    loop
	      exit when alldefers.empty
	      const t : defer <- alldefers.removeUpper
	      t$p.doDeferredTypeCheck[t$aparam, t$apsym, t$avalue, t$i]
	    end loop
	  end if
	  if verbose then self.pass["Done type checking\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  % Assign Ids again (just in case)
  
	  self.pass["Assigning ids ...\n", nil]
	  self$root.assignIds[self$rootst]
	  if verbose then self.pass["Done assigning ids\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  self.pass["Finding things to generate ...\n", nil]
	  self$root.findThingsToGenerate[q]
	  if verbose then self.pass["Done finding things to generate\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  if ! self$executeNow and ! self$doCompilation then
	    const t <- q.removeLower
	  end if
	  if self$doGeneration and ! self$executeNow then
	    myCP <- CP.create[self$fn, self$perfile]
	  end if
  
	  if self$generateBuiltin then
	    vct <- VofCT.create[q.upperbound + 1]
	    vco <- VofCO.create[q.upperbound + 1]
	  end if

	  % Do allocation

	  for i : Integer <- q.lowerbound while i <= q.upperbound by i<-i+1
	    const qq <- q[i]
	    const qqname <- nameof qq
  
	    self.pass["Allocating object #%d %s...\n", {i, qqname : Any}]
  
	    if qqname = "anoblit" or qqname = "acomp" then
	      if self$tracepasses then
		if qqname = "acomp" then
		  stdout.putstring["A compilation\n"]
		else
		  (view qq as Oblit).printsummary
		end if
	      end if
	      % Allocation
    
	      da <- view qq as hasDoAllocation
	      da.doAllocation
	      if verbose then self.tallocation["Done allocation\n", nil] end if
	      if self.getnErrors[] > 0 then
		if self$verbose then
		  qq.print[self$stdout, 0]
		end if
		return
	      end if
	    end if
	  end for

	  for oindex : Integer <- q.lowerbound while oindex <= q.upperbound by oindex <- oindex + 1
	    const qq <- q[oindex]
	    const qqname <- nameof qq
	    var theCT : ConcreteType
	    var theAT : Signature
	    var o : ObLit
	    ct <- nil
  
	    self.pass["Generating object #%d %s...\n", {oindex, qqname : Any}]
  
	    if qqname = "anoblit" or qqname = "acomp" then
	      if self$tracepasses then
		if qqname = "acomp" then
		  stdout.putstring["A compilation\n"]
		else
		  (view qq as Oblit).printsummary
		end if
	      end if

	      if qqname = "anoblit" then
		o <- view qq as oblit
	      end if

	      % Code Generation

	      if self$doGeneration and (qqname = "acomp" or !o$alreadyGenerated) then

		if qqname = "anoblit" then
		  self.tgenerate["  Name = %s Id = %#x codeOID = %#x\n",
		    { o$name.asString, o$id, o$codeOID : Any}]
		  if o$id !== nil then
		    const c <- CreateOne.create[o$codeOID, o$id]
		    if self$executeNow then
		      vco[oindex] <- c
		    else
		      myCP.CP[c]
		    end if
		  end if
		end if
    
		ctct <- CTCode.create
		ct <- ctct
		self.pass["Doing code generation ...\n", nil]
		if self$tracegenerate then qq.print[self$stdout, 0] end if
		self$thisObject <- qq
		qq.generate[ctct]
		if self$generateBuiltin then
		  theCT <- ctct.generateBuiltin
		  vct[oindex] <- theCT
		end if
		if self$tracegeneratedBuiltin then
		  if !self$generateBuiltin then
		    theCT <- ctct.generateBuiltin
		  end if
		  self.printf["Generated code named %s, file %s, template %s\n",
		    {theCT.getName, theCT.getFileName, theCT.getTemplate}]
		  for i : Integer <- 0 while i <= theCT.getOps.upperbound by i<-i+1
		    const xx <- theCT.getOps[][i]
		    if xx !== nil then
		      self.printf["  Op %d is %s[%d]->[%d]\n",
			{ i, xx.getName, xx.getNArgs, xx.getNRess}]
		    end if
		  end for
		end if
		if verbose then self.tgenerate["Done code generation\n", nil] end if
	      end if
	    else
	      if self$doGeneration and self$generateATs then
		const a <- view qq as atlit
		self.tgenerate["  Name = %s Id = %#x\n",
		  { a$name.asString, a$id : Any}]

		ct <- ATCode.create
		self.tgenerate["Doing abstracttype generation ...\n", nil]
		  if self$tracegenerate then qq.print[self$stdout, 0] end if
		self$thisObject <- qq
		qq.generate[ct]

		if self$generateBuiltin then
		  theAT <- view ct.generateBuiltin as Signature
		end if
		if self$tracegeneratedBuiltin then
		  if !self$generateBuiltin then
		    theAT <- view ct.generateBuiltin as Signature
		  end if
		  self.printf["Generated signature named %s, file %s\n",
		    { theAT.getName, theAT.getFileName }]
		  for i : Integer <- 0 while i <= theAT.getOps.upperbound by i<-i+1
		    const xx <- theAT.getOps[][i]
		    if xx !== nil then
		      self.printf["  Op %d is %s[%d]->[%d]\n",
			{ i, xx.getName, xx.getNArgs, xx.getNRess}]
		    end if
		  end for
		end if

		if verbose then self.tgenerate["Done abstracttype generation\n", nil] end if
	      else
		ct <- nil
	      end if
	    end if
  
	    if self.getnErrors[] > 0 then
	      if self$verbose then
		qq.print[self$stdout, 0]
	      end if
	      return
	    end if
	    if !self$executeNow and ct !== nil then
	      myCP.CP[ct]
	    end if
	  end for
	  if self$generateBuiltin then
	    for i : Integer <- 0 while i <= vct.upperbound by i <- i + 1
	      const theCT <- vct[i]
	      if theCT !== nil then
		% Fix its literals
		const ops <- theCT.getOps
		primitive "DOCTLITERALS" [] <- [theCT]
		for j : Integer <- 0 while j <= ops.upperbound by j <- j + 1
		  const anop <- ops[j]
		  if anop !== nil then
		    const code <- anop.getCode
		    primitive "DOLITERALS" [] <- [code]
		  end if
		end for
	      end if
	    end for
	    for i : Integer <- 0 while i <= vco.upperbound by i <- i + 1
	      const theCO : CreateOne <- vco[i]
	      if theCO !== nil then
		% We need to create one
		var theObject : Any
		const theCT <- vct[i]
		const theID <- theCO$id
		assert theCT !== nil
		primitive "XCREATE" [theObject] <- [theCT, theObject]
		primitive "INSTALLINOID" [] <- [theID, theObject]
	      end if
	    end for
	  end if
	  if self$doGeneration then
	    if self$executeNow then
	      % build the thing
	      const theCompilationCT <- vct[0]
	      var result : Any
	      if self$tracetoplevel then
		self.printf["Executing %s\n", {self$fn}]
	      end if
	      primitive "XCREATE" [result] <- [theCompilationCT, result]
	    else
	      myCP.finish
	    end if
	  end if
	  self$thisObject <- nil

	  % Environment Exports
  
	  self.pass["Doing environment exports ...\n", nil]
	  self$root.doEnvExports[nil]
	  if verbose then self.pass["Done environment exports\n", nil] end if
	  if self.getnErrors[] > 0 then
	    if self$verbose then
	      self$root.print[self$stdout, 0]
	    end if
	    return
	  end if
  
	  if verbose then self.pass["Trashing symbol tables ...\n", nil] end if
	  self$rootst.discard
	  if verbose then self.pass["Done trashing symbol tables\n", nil] end if
	  self$root <- nil
	  myenv$root <- nil
	  myenv$thisObject <- nil

	  if self$tracesizes then
	    var xxx : Any <- self$rootst
	    primitive var "CALCSIZE" [] <- [xxx]
	    xxx <- InvocCache
	    primitive var "CALCSIZE" [] <- [xxx]
	    xxx <- aCompiler
	    primitive var "CALCSIZE" [] <- [xxx]
	  end if

	end done
  
	export function getln -> [r : Integer]
	  r <- self$scan.lineNumber
	end getln
  
	export operation checkNames [a : Tree, b : Tree]
	  const la <- view a as hasIdent
	  const lb <- view b as hasIdent
	  if la$id !== lb$id then
	    self.warningf["Name %s should be %s", { lb$id$name, la$id$name} ]
	  end if
	end checkNames
  
	export operation checkNamesbyid [a : Ident, b : Ident]
	  if a !== b then
	    self.warningf["Name %s should be %s", { b$name, a$name} ]
	  end if
	end checkNamesbyid
  
	export operation distribute
		[tm: TreeMaker, l : Tree, t : Tree, v :Tree] -> [r : Tree]
	  if l.upperbound > 0 then
	    r <- sseq.create[l$ln]
	  end if
	  for i : Integer <- l.lowerbound while i <= l.upperbound by i <- i + 1
	    begin
	      const elem <- l[i]
	      const temp <- tm.create[elem$ln, elem, t, v]
	      if l.upperbound > 0 then
		r.rcons[temp]
	      else
		r <- temp
	      end if
	    end
	  end for
	end distribute
	export operation scheduleDeferredTypeCheck [t : Tree, aparam : Any, apsym : Any, avalue : Any, i : Integer]
	  const adefer : defer <- defer.create[
	    view t as Invoc, aparam, apsym, avalue, i]
	  alldefers.addupper[adefer]
	end scheduleDeferredTypeCheck
      end myenv

      export function getenv -> [r : Environment]
	r <- myenv
      end getenv
      export operation setup [xstdout : OutStream]
	stdout <- xstdout
	fstdout <- FormattedOutput.toStream[stdout]

	% Set the environment
	myenv$itable <- it
	myenv$nextNumber <- 1
	myenv$nErrors <- 0
	myenv$stdout <- stdout
	myenv$fstdout <- fstdout

	% Set my process environment
	primitive var "SETENV" [] <- [myenv]
      end setup

      export operation option[name : String, value : Boolean]
	if name = "verbose" then
	  myenv$verbose <- value
	elseif name = "exporttree" then
	  myenv$exportTree <- value
	elseif name = "explainNonManifests" then
	  myenv$explainNonManifests <- value
	elseif name = "perfile" then
	  myenv$perfile <- value
	elseif name = "tracecode" then
	  myenv$tracecode <- value
	elseif name = "docompilation" then
	  myenv$docompilation <- value
	elseif name = "dogeneration" then
	  myenv$dogeneration <- value
	elseif name = "generatebuiltin" then
	  myenv$generatebuiltin <- value
	elseif name = "executenow" then
	  myenv$generatebuiltin <- value
	  myenv$executenow <- value
	elseif name = "generateconcurrent" then
	  myenv$generateConcurrent <- value
	elseif name = "generatedebuginfo" then
	  myenv$generateDebugInfo <- value
	elseif name = "generateats" then
	  myenv$generateAts <- value
	elseif name = "padbytecodes" then
	  myenv$padByteCodes <- value
	elseif name = "useabcons" then
	  myenv$useAbCons <- value
	elseif name = "implicitlydefineexternals" then
	  myenv$implicitlyDefineExternals <- value
	elseif name = "tracegenerate" then
	  myenv$tracegenerate <- value
	elseif name = "tracegeneratedbuiltin" then
	  myenv$tracegeneratedbuiltin <- value
	elseif name = "traceparse" then
	  myenv$traceparse <- value
	elseif name = "dumpremovesugar" then
	  myenv$dumpremovesugar <- value
	elseif name = "traceassigntypes" then
	  myenv$traceassigntypes <- value
	elseif name = "optimizeinvocexecute" then
	  myenv$optimizeinvocexecute <- value
	elseif name = "tracetypecheck" then
	  myenv$tracetypecheck <- value
	elseif name = "traceallocation" then
	  myenv$traceallocation <- value
	elseif name = "tracetoplevel" then
	  myenv$tracetoplevel <- value
	elseif name = "traceinline" then
	  myenv$traceinline <- value
	elseif name = "tracesizes" then
	  myenv$tracesizes <- value
	elseif name = "dotypecheck" then
	  myenv$dotypecheck <- value
	elseif name = "warnshadows" then
	  myenv$warnshadows <- value
	elseif name = "why" then
	  myenv$why <- value
	elseif name = "dumpassigntypes" then
	  myenv$dumpassigntypes <- value
	elseif name = "tracesymbols" then
	  myenv$tracesymbols <- value
	elseif name = "dumpsymbols" then
	  myenv$dumpsymbols <- value
	elseif name = "traceevaluatemanifests" then
	  myenv$traceevaluatemanifests <- value
	elseif name = "dumpevaluatemanifests" then
	  myenv$dumpevaluatemanifests <- value
	elseif name = "tracepasses" then
	  myenv$tracepasses <- value
	elseif name = "compilingbuiltins" then
	  myenv$compilingbuiltins <- value
	elseif name = "compilingcompiler" then
	  myenv$compilingcompiler <- value
	elseif name = "generateviewchecking" then
	  myenv$generateviewchecking <- value
	else
	  fstdout.printf["Undefined variable \"%s\"\n", {name}]
	end if
      end option

      export operation load[filename : String]
	myenv$namespacefile <- filename
	if myenv$rootst == nil then
	  myenv$rootst <- builtinlit.init
	end if
	xexport.load[filename]
	invoccache.load[filename]
	nextoid.load[filename]
	OpNameToOID.load[filename]
      end load

      export operation eval[code : String]
	const f <- StringStream.create[code]
	var myparser : ParserCreator
	var parseResult : Integer
	const oldexecutenow <- myenv$executeNow
	const oldgeneratebuiltin <- myenv$generateBuiltin
	myenv$executeNow <- true
	myenv$generateBuiltin <- true

	if myenv$tracetoplevel then
	  fstdout.printf["Evaluating \"%s\"\n", {code}]
	end if

	if scan == nil then
	  scan <- scanner.create[f, it]
	else
	  scan.reset[f]
	end if

	% Reset the environment
	myenv$fileName <- Literal.StringL[0, "stdin"]
	myenv$nextNumber <- 1
	myenv$nErrors <- 0
	myenv$fn <- "stdin"
	myenv$scan <- scan

	myparser <- parsercreator.create[myenv]

	myenv.pass["Parsing ...\n", nil]
	parseresult <- myparser.parse[scan]
	myenv$executeNow <- oldExecuteNow
	myenv$generateBuiltin <- oldgenerateBuiltin
      end eval
      
      export operation compile[fileName : String]
	var f : InStream
	begin
	  f <- InStream.fromUnix[fileName, "r"]
	  failure f <- nil end failure
	end

	if f == nil then
	  fstdout.printf["Can't open \"%s\"\n", { fileName }]
	else
	  var myparser : ParserCreator
	  var parseResult : Integer
  
	  if scan == nil then
	    scan <- scanner.create[f, it]
	  else
	    scan.reset[f]
	  end if
  
	  if myenv$tracetoplevel then
	    fstdout.printf["Compiling %s\n", {fileName}]
	    fstdout.flush
	  end if
	  % Reset the environment
	  myenv$fileName <- Literal.StringL[0, fileName]
	  myenv$nextNumber <- 1
	  myenv$nErrors <- 0
	  myenv$fn <- fileName
	  myenv$scan <- scan
  
	  myparser <- parsercreator.create[myenv]
  
	  myenv.pass["Parsing ...\n", nil]
	  parseresult <- myparser.parse[scan]
	  f.close
	end if
      end compile

    end aCompiler
  end create
end Compiler
export Compiler
