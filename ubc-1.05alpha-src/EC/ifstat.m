export Ifstat

const voi <- Vector.of[Integer]

const ifstat <- class Ifstat (Tree) [xxifclauses : Tree, xxelseclause : Tree]
    field ifclauses : Tree <- xxifclauses
    field elseclause : Tree <- xxelseclause

    export function upperbound -> [r : Integer]
      r <- 1
    end upperbound
    export function getElement [i : Integer] -> [r : Tree]
      if i = 0 then
	r <- ifclauses
      elseif i = 1 then
	r <- elseclause
      end if
    end getElement
    export operation setElement [i : Integer, r : Tree]
      if i = 0 then
	ifclauses <- r
      elseif i = 1 then
	elseclause <- r
      end if
    end setElement
    export operation copy [i : Integer] -> [r : Tree]
      var nifclauses, nelseclause : Tree
      if ifclauses !== nil then nifclauses <- ifclauses.copy[i] end if
      if elseclause !== nil then nelseclause <- elseclause.copy[i] end if
      r <- ifstat.create[ln, nifclauses, nelseclause]
    end copy
    operation useCaseStatement [xct : Printable] -> [result : Boolean]
      const it <- Environment$env$ITable
      var min, max : Integer
      var xsym : Symbol
      var s : Sym
      const nArms <- ifclauses.upperbound + 1
      var values : voi
      var val : Integer
      result <- false
      if nArms <= 3 then return end if
      values <- voi.create[nArms]
      for i : Integer <- 0 while i < nArms by i <- i + 1
	const x <- view ifclauses[i] as ifclause
	result, xsym, s, min, max, val <- x.shouldUseCase[xsym, min, max]
	values[i] <- val
%	Environment$env.printf["Should %d use case = %s\n", {i, result.asString}]
	exit when !result
      end for
%     Environment$env.printf["Should use case = %s\n", {result.asString}]
      if result then
	const a <- view xsym$ATinfo as hasID
	if a == nil then
	  Environment$env.printf["ifstat.case: AT is nil\n", nil]
	  result <- false
	else
	  Environment$env.pass["ifstat.case: AT is %S %x\n", {a, a$id}]
	  result <-
	    (a$id = 0x1606 or a$id = 0x1604) and
	    (nArms > 2) and
	    (nArms > 10 or (nArms * 4) > (max - min + 1)) and
	    (max - min + 1) <= 512 and
	    (-32768 <= min and max <= 32767)
	end if
      end if
%     Environment$env.printf["Should use case 2 = %s\n", {result.asString}]
      if result then
	const bc <- view xct as ByteCode
	var elseLabel : Integer
	const endLabel : Integer <- bc.declareLabel
	const range <- max - min + 1
	const labels <- voi.create[nArms]
	const map <- voi.create[range]

	if elseClause !== nil then elseLabel <- bc.declareLabel end if
	for i : Integer <- 0 while i < range by i <- i + 1
	  map[i] <- ~1
	end for
	for i : Integer <- 0 while i < nArms by i <- i + 1
	  map[values[i] - min] <- i
	end for
%	Environment$env.printf["S is %s\n", { s.asString} ]
	bc.pushSize[4]
	s.generate[bc]
%	Environment$env.printf["Done generating S\n", nil]
	bc.popSize
	bc.addCode["CASE"]
	bc.addValue[min, 2]
	bc.addValue[max, 2]
	for i : Integer <- 0 while i < range by i <- i + 1
	  const which <- map[i]
	  if which < 0 then
	    if elseClause == nil then
	      bc.addLabelReference[endLabel, 2]
	    else
	      bc.addLabelReference[elseLabel, 2]
	    end if
	  else
	    const l : Integer <- bc.declareLabel
	    labels[which] <- l
	    bc.addLabelReference[l, 2]
	  end if
	end for
	if elseclause == nil then
	  bc.addLabelReference[endLabel, 2]
	else
	  bc.addLabelReference[elseLabel, 2]
	end if
	for i : Integer <- 0 while i < nArms by i <- i + 1
	  const e <- ifclauses[i][1]
	  bc.defineLabel[labels[i]]
	  e.generate[xct]
	  if i != nArms - 1 or elseclause !== nil then
	    bc.addCode["BR"]
	    bc.addLabelReference[endLabel, 2]
	  end if
	end for
	if elseclause !== nil then
	  bc.defineLabel[elseLabel]
	  elseclause.generate[xct]
	end if
	bc.defineLabel[endLabel]
      end if
    end useCaseStatement

    export operation generate [xct : Printable]
      const bc <- view xct as ByteCode
      if ! self.useCaseStatement[xct] then
	const endLabel : Integer <- bc.declareLabel
	for i : Integer <- 0 while i <= ifclauses.upperbound by i <- i + 1
	  const aclause <- ifclauses[i]
	  const exp <- aclause[0]
	  const stats <- aclause[1]
	  const falseLabel : Integer <- bc.declareLabel
	  bc.lineNumber[exp$ln]
	  bc.pushSize[4]
	  exp.generate[xct]
	  bc.popSize
	  if stats == nil then
	    bc.addCode["BRT"]
	    bc.addLabelReference[endLabel, 2]
	  else
	    bc.addCode["BRF"]
	    bc.addLabelReference[falseLabel, 2]
	    stats.generate[xct]
	    if i != ifclauses.upperbound or elseclause !== nil then
	      bc.addCode["BR"]
	      bc.addLabelReference[endLabel, 2]
	    end if
	    bc.defineLabel[falseLabel]
	  end if
	end for
	if elseclause !== nil then 
	  elseclause.generate[xct]
	end if
	bc.defineLabel[endLabel]
      end if
    end generate

  export function asString -> [r : String]
    r <- "ifstat"
  end asString
end Ifstat
