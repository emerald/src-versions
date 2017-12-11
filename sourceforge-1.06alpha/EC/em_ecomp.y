%{
%  imports go here
%} 
%{

const MYENVT <- typeobject MYENVT
  operation done [yystype]
  operation error [String]
  operation SemanticError [Integer, String, RISA]
  operation errorf [String, RISA]
  operation warningf [String, RISA]
  operation printf [String, RISA]
  function getln -> [Integer]
  operation checknames[yystype, yystype]
  operation checknamesbyid[Ident, Ident]
  function getFileName -> [Tree]
  operation distribute [TreeMaker, Tree, Tree, Tree] -> [Tree]
  operation getITable -> [IdentTable]
end MYENVT
const env <- view environment as MYENVT

%} 
%start compilation 
%token  TEOF 0 /*  "end of file" */
%token  TIDENTIFIER /* "identifier" */
%token  TOPERATOR /* "operator"  */
%token  TLPAREN /* "(" */
%token  TRPAREN /* ")" */
%token  TLSQUARE /* "[" */
%token  TRSQUARE /* "]" */
%token  TLCURLY /*  "{" */
%token  TRCURLY /*  "}" */
%token  TDOLLAR /*  "$" */
%token  TDOT /*  "." */
%token  TDOTSTAR /*  ".*" */
%token  TDOTQUESTION /*  ".?" */
%token  TCOMMA /*  "," */
%token  TCOLON /*  ":" */
%token	TSEMI  /*  ";" */
%token  TINTEGERLITERAL /*  "integer" */
%token  TREALLITERAL /*  "real" */
%token  TCHARACTERLITERAL /*  "character" */
%token  TSTRINGLITERAL /*  "string" */
%token  OAND /*  "&" */
%token  OASSIGN /*  "<-" */
%token  OCONFORMSTO /*  "*>" */
%token  ODIVIDE /*  "/" */
%token  OEQUAL /*  "=" */
%token  OGREATER /*  ">" */
%token  OGREATEREQUAL /*  ">=" */
%token  OIDENTITY /*  "==" */
%token  OLESS /*  "<" */
%token  OLESSEQUAL /*  "<=" */
%token  OMINUS /*  "-" */
%token  OMOD /*  "#" */
%token  ONEGATE /*  "~" */
%token  ONOT /*  "!" */
%token  ONOTEQUAL /*  "!=" */
%token  ONOTIDENTITY /*  "!==" */
%token  OOR /*  "|" */
%token  OPLUS /*  "+" */
%token  ORETURNS /*  "->" */
%token  OTIMES /*  "*" */
%token  KAND /*  "and" */
%token  KAS /*  "as" */
%token  KASSERT /*  "assert" */
%token  KAT /*  "at" */
%token  KAWAITING /*  "awaiting" */
%token  KATTACHED /*  "attached" */
%token  KBEGIN /*  "begin" */
%token	KBUILTIN /*  "builtin" */
%token  KBY /*  "by" */
%token  KCHECKPOINT /* "checkpoint" */
%token	KCLOSURE /* "closure" */
%token	KCODEOF /*  "codeof" */
%token  KCLASS /*  "class" */
%token  KCONST /*  "const" */
%token  KELSE /*  "else" */
%token  KELSEIF /*  "elseif" */
%token  KEND /*  "end" */
%token  KENUMERATION /*  "enumeration" */
%token  KEXIT /*  "exit" */
%token  KEXPORT /*  "export" */
%token  KEXTERNAL /*  "external" */
%token  KFAILURE /*  "failure" */
%token  KFALSE /*  "false" */
%token  KFIELD /*  "field"  */
%token	KFIX /* "fix" */
%token  KFOR /*  "for" */
%token	KFORALL /*  "forall" */
%token  KFROM /*  "from" */
%token  KFUNCTION /*  "function" */
%token  KIF /*  "if" */
%token  KIMMUTABLE /*  "immutable" */
%token  KINITIALLY /*  "initially" */
%token  KISFIXED /*  "isfixed" */
%token  KISLOCAL /*  "islocal" */
%token  KLOCATE /*  "locate" */
%token  KLOOP /*  "loop" */
%token  KMONITOR /*  "monitor" */
%token  KMOVE /*  "move" */
%token	KNAMEOF /*  "nameof" */
%token	KNEW /*  "new" */
%token  KNIL /*  "nil" */
%token  KOBJECT /*  "object" */
%token  KOP /*  "op" */
%token  KOPERATION /*  "operation" */
%token  KOR /*  "or" */
%token  KPRIMITIVE /*  "primitive" */
%token  KPROCESS /*  "process" */
%token  KRECORD /*  "record" */
%token  KRECOVERY /*  "recovery" */
%token  KREFIX /*  "refix" */
%token  KRESTRICT /*  "restrict" */
%token  KRETURN /*  "return" */
%token  KRETURNANDFAIL /*  "returnandfail" */
%token  KSELF /*  "self" */
%token  KSIGNAL /*  "signal" */
%token	KSUCHTHAT /*  "suchthat" */
%token	KSYNTACTICTYPEOF /*  "syntactictypeof" */
%token  KTHEN /*  "then" */
%token  KTO /*  "to" */
%token  KTRUE /*  "true" */
%token  KTYPEOBJECT /*  "typeobject" */
%token	KTYPEOF /*  "typeof" */
%token  KUNFIX /*  "unfix" */
%token  KUNAVAILABLE /*  "unavailable" */
%token  KVAR /*  "var" */
%token  KVIEW /*  "view" */
%token  KVISIT /*  "visit" */
%token  KWAIT /*  "wait" */
%token  KWHEN /*  "when" */
%token  KWHILE /*  "while" */
%token  KWHERE /*  "where" */
%right  KAS KTO  /* precedence, lowest first */
%left  OOR KOR 
%left  OAND KAND 
%left  ONOT 
%left  OIDENTITY ONOTIDENTITY OEQUAL ONOTEQUAL OGREATER OLESS OGREATEREQUAL OLESSEQUAL OCONFORMSTO 
%left  OPLUS OMINUS 
%left  OTIMES ODIVIDE OMOD TOPERATOR 
%left  ONEGATE KISLOCAL KISFIXED KLOCATE KAWAITING KCODEOF KNAMEOF KTYPEOF KSYNTACTICTYPEOF
%%
compilation :
		constantDeclarationS TEOF
		{ $$ <- comp.create[env$ln - 1, env$fileName, nil, nil, $1] env.done[$$] }
	;
constantDeclarationS :
		empty 
		{ $$ <- sseq.create[env$ln] }
	|	constantDeclarationS environmentExport 
		{ $$ <- $1 $$.rcons[$2] }
	|	constantDeclarationS constantDeclaration 
		{ $$ <- $1 $$.rcons[$2] }
	;
empty :
		{ $$ <- nil }
	;
environmentExport :
		KEXPORT symbolReferenceS KTO TSTRINGLITERAL
		{ $$ <- xexport.create[env$ln, $2, $4] }
	|
		KEXPORT symbolReferenceS
		{ $$ <- xexport.create[env$ln, $2, nil] }
	;
typeClauseOpt :
		empty { $$ <- $1 }
	|	typeClause { $$ <- $1 }
	;
typeClause :
		TCOLON typeDefinition 
		{ $$ <- $2 }
	;
typeDefinition :
		expression { $$ <- $1 }
	;
abstractType :
		KTYPEOBJECT symbolDefinition builtin operationSignatureS KEND symbolReference
		{ const a : ATLit <- atlit.create[env$ln, env$fileName, $2, $4 ]
		  env.checkNames[$2, $6]
		  $$ <- a
		  if $3 !== nil then
		    a.setBuiltinID[$3]
		  end if }
	;
record :
		KRECORD symbolDefinition recordFieldS KEND symbolReference 
		{ env.checkNames[$2, $5]
	      $$ <- recordlit.create[env$ln, env$fileName, $2, $3] }
	;
recordFieldS :
		recordField 
		{ $$ <- seq.create[env$ln] $$.rappend[$1] }
	|	recordFieldS recordField 
		{ $$ <- $1 $$.rappend[$2] }
	;
recordField :
		attached ovar symbolDefinitionS typeClause
	      {
		const s <- env.distribute[vardecl, $3, $4, nil]
		if $1 !== nil then
		  if s$isseq then
		    const limit <- s.upperbound
		    for i : Integer <- s.lowerbound while i <= limit by i<-i+1
		      const x <- s[i]
% If doing move/visit
		      const y <- view x as Attachable
		      y$isAttached <- TRUE
		    end for
		  else
% If doing move/visit
		    const y <- view s as Attachable
		    y$isAttached <- TRUE
		  end if
		end if
		$$ <- s
	      }
	;
enumeration :
		KENUMERATION symbolDefinition symbolDefinitionS KEND symbolReference 
		{
		  env.checkNames[$2, $5]
		  $$ <- enumlit.create[env$ln, $2, $3]
		}
	;
symbolDefinitionS :
		symbolDefinition 
		{ $$ <- seq.singleton[$1] }
	|	symbolDefinitionS TCOMMA symbolDefinition 
		{ $$ <- $1 $$.rcons[$3] }
	;
symbolReferenceS :
		symbolReference 
		{ $$ <- seq.singleton[$1] }
	|	symbolReferenceS TCOMMA symbolReference 
		{ $$ <- $1 $$.rcons[$3] }
	;
symbolReferenceOrLiteral:
		symbolReference
		{ $$ <- $1 }
	|	TINTEGERLITERAL
		{ $$ <- $1 }
	|	TCHARACTERLITERAL
		{ $$ <- $1 }
	|	TSTRINGLITERAL
		{ $$ <- $1 }
	;
symbolReferenceOrLiteralS :
		symbolReferenceOrLiteral
		{ $$ <- seq.singleton[$1] }
	|	symbolReferenceOrLiteralS TCOMMA symbolReferenceOrLiteral
		{ $$ <- $1 $$.rcons[$3] }
	;
operationSignatureS :
		empty 
		{ $$ <- seq.create[env$ln] }
	|	operationSignatureS operationSignature 
		{ $$ <- $1 $$.rcons[$2] newid.reset }
	;
operationSignature :
		KFUNCTION operationNameDefinition parameterClause returnClause whereClause 
		{ const x : OpSig <- opsig.create[env$ln, (view $2 as hasIdent)$id, $3, $4, $5]
		  x$isFunction <- true
		  $$ <- x
		}
	|	
		operationWord operationNameDefinition parameterClause returnClause whereClause 
		{ $$ <- opsig.create[env$ln, (view $2 as hasIdent)$id, $3, $4, $5] }
	;
operationWord :
		KOPERATION 
	|	KOP 
	;
parameterClause :
		empty { $$ <- $1 }
	|	TLSQUARE TRSQUARE 
		{ $$ <- nil }
	|	TLSQUARE parameterS TRSQUARE 
		{ $$ <- $2 }
	;
parameterS :
		parameter 
		{ $$ <- seq.singleton[$1] }
	|	parameterS TCOMMA parameter 
		{ $$ <- $1 $$.rcons[$3] }
	;
omove:
		KMOVE
	|
	;
oattached:
		KATTACHED
	|
	;
parameter :
		omove oattached symbolDefinition TCOLON expression
		{
		  const p : Param <- param.create[env$ln, $3, $5]
% If doing move/visit
%		  p$isMove <- $1 !== nil
		  if $2 !== nil then p$isAttached <- true end if
		  $$ <- p
		}
	|	omove oattached expression
		{
  		  const id <- newid.newid
		  const asym : Sym <- sym.create[env$ln, id]
		  const p : Param <- param.create[env$ln, asym, $3]
% If doing move/visit
%		  p$isMove <- $1 !== nil
		  if $2 !== nil then p$isAttached <- true end if
		  $$ <- p
		}
	;
returnClause :
		empty { $$ <- nil }
	|	ORETURNS TLSQUARE TRSQUARE 
		{ $$ <- nil }
	|	ORETURNS TLSQUARE parameterS TRSQUARE 
		{ $$ <- $3 }
	;
whereClause :
		empty { $$ <- nil }
	|	whereWidgitS
		{ $$ <- $1 }
	;
whereWidgitS :
		whereWidgit 
		{ $$ <- seq.singleton[$1] }
	|	whereWidgitS whereWidgit 
		{ $$ <- $1 $$.rcons[$2] }
	;
whereWidgit :
		KWHERE TIDENTIFIER OASSIGN expression
		{ $$ <- wherewidgit.create[env$ln, $2, 1, $4] }
	|	KSUCHTHAT TIDENTIFIER OCONFORMSTO typeObject
		{ $$ <- wherewidgit.create[env$ln, $2, 2, $4] }
	|	KFORALL TIDENTIFIER
		{ $$ <- wherewidgit.create[env$ln, $2, 3, nil] }
	;
builtin:
		{ $$ <- nil }
	|	KBUILTIN TINTEGERLITERAL
		{ $$ <- $2 }
	;
object :
		KOBJECT symbolDefinition builtin declarationS operationDefinitionS KEND symbolReference 
		{ const x : Oblit <- oblit.create[env$ln, env$fileName, $2, $4, $5]
		  env.checkNames[$2, $7]
		  if $3 !== nil then
		    x.setBuiltinID[$3]
		  end if 
		  $$ <- x }
	;
closure :
		KCLOSURE symbolDefinition builtin parameterClause declarationS operationDefinitionS KEND symbolReference 
		{ const x : Oblit <- oblit.create[env$ln,env$fileName, $2, $5, $6]

		  % solve the setq problem.  Each of the symbols in the
		  % parameter clause needs to be turned into a setq with an 
		  % undefined outer.  Hmmmm.....
		  % Nope.  We need another thing for explicit parameters,
		  % cause they need types.

		  x$xparam <- $4

		  x$generateOnlyCT <- true
		  env.checkNames[$2, $8]
		  if $3 !== nil then
		    x.setBuiltinID[$3]
		  end if 
		  $$ <- x }
	;
creators :
		empty 
		{ $$ <- nil }
	|	creators KCLASS constantDeclaration 
		{ if $1 == nil then $$ <- seq.pair[seq.singleton[$3], seq.create[env$ln]] else $$ <- $1 $$[0].rcons[$3] end if }
	;
	|	creators KCLASS operationDefinition 
		{ if $1 == nil then $$ <- seq.pair[seq.create[env$ln], seq.singleton[$3]] else $$ <- $1 $$[1].rcons[$3] end if }
	;
obase :
		empty { $$ <- nil }
	|	TLPAREN symbolReference TRPAREN 
		{ $$ <- $2 }
	;
class :
		KCLASS symbolDefinition obase parameterClause builtin creators declarationS operationDefinitionS KEND symbolReference 
		{ 
		  env.checkNames[$2, $10]
		  const c <- xclass.create[env$ln, env$fileName, $2, $3, $4, $6, $7, $8]
		  if $5 !== nil then c.setbuiltinid[$5] end if
		  $$ <- c
		}
	;
declarationS :
		empty 
		{ $$ <- nil }
	|	declarationS declaration 
		{ if $1 == nil then $$ <- sseq.singleton[$2] else $$ <- $1 $$.rcons[$2] end if }
	;
attached :
		KATTACHED 
		{ $$ <- sseq.create[env$ln] }
	|	empty { $$ <- nil }
	;
declaration :
		attached declarationprime 
	      {
		if $1 !== nil then
		  const s : Tree <- $2
		  if s$isseq then
		    const limit <- s.upperbound
		    for i : Integer <- s.lowerbound while i <= limit by i <- i+1
		      const x : Tree <- s[i]
% If doing move/visit
		      const t <- view x as Attachable
		      t$isattached <- true
		    end for
		  else
% If doing move/visit
		    const t <- view s as Attachable
		    t$isAttached <- true
		  end if
		end if
		$$ <- $2
	      }
	;
declarationprime :
		constantDeclaration { $$ <- $1 }
	|	variableDeclaration { $$ <- $1 }
	|	fieldDeclaration { $$ <- $1 }
	|	externalDeclaration { $$ <- $1 }
	;
constantDefOp :
		OASSIGN 
	;
fieldDeclaration :
		KFIELD symbolDefinition typeClause initializerOpt 
		{ $$ <- fielddecl.create[env$ln, $2, $3, $4] }
	|	KCONST KFIELD symbolDefinition typeClause initializerOpt 
		{ const f : FieldDecl <- fielddecl.create[env$ln, $3, $4, $5]
		  f$isConst <- true
		  $$ <- f }
	;
constantDeclaration :
		KCONST symbolDefinition typeClauseOpt constantDefOp expression 
		{ $$ <- constdecl.create[env$ln, $2, $3, $5] }
	;
externalDeclaration :
		KEXTERNAL symbolDefinition typeClause
		{ $$ <- extdecl.create[env$ln, $2, $3] }
	;
initializerOpt :
		empty { $$ <- $1 }
	|	OASSIGN expression 
		{ $$ <- $2 }
	;
initializer :
		OASSIGN expression 
		{ $$ <- $2 }
	;
variableDeclaration :
		KVAR symbolDefinitionS typeClause initializerOpt 
		{ $$ <- env.distribute[vardecl, $2, $3, $4] }
	;
operationDefinitionS :
		empty 
		{ $$ <- seq.create[env$ln]
		  $$.rcons[nil] $$.rcons[nil] $$.rcons[nil] }
	|	operationDefinitionS operationDefinition 
		{ $$ <- $1 $$.rcons[$2] }
	|	operationDefinitionS initiallyDefinition
		{ $$ <- $1 
		  if $$.getElement[0] !== nil then
		    env.SemanticError[$2$ln, "Only one initially definition is allowed", nil]
		  else
		    $$.setElement[0, $2] 
		  end if
		}
	|	operationDefinitionS recoveryDefinition
		{ $$ <- $1
		  if $$.getElement[1] !== nil then
		    env.SemanticError[$2$ln, "Only one recovery definition is allowed", nil]
		  else
		    $$.setElement[1, $2] 
		  end if
		}
	|	operationDefinitionS processDefinition
		{ $$ <- $1
		  if $$.getElement[2] !== nil then
		    env.SemanticError[$2$ln, "Only one process definition is allowed", nil]
		  else
		    $$.setElement[2, $2] 
		  end if
		}
	;
operationDefinition :
		operationDefinitionRest
		{ $$ <- $1 }
	|	KEXPORT operationDefinitionRest
		{ (view $2 as OpDef)$isExported <- true $$ <- $2 }
	;
operationDefinitionRest :
		operationSignature blockBody KEND operationNameReference 
		{ const sig <- view $1 as OpSig
		  env.checkNamesByID[sig$name, (view $4 as hasIdent)$id]
		  sig.isInDefinition
		  $$ <- opdef.create[env$ln, $1, $2] }
	;
blockBody :
		declarationsAndStatements unavailableHandler failureHandler 
		{ $$ <- block.create[env$ln, $1, $2, $3] }
	;
initiallyDefinition :
		KINITIALLY blockBody KEND KINITIALLY 
		{ $$ <- initdef.create[env$ln, $2] }
	;
recoveryDefinition :
		KRECOVERY blockBody KEND KRECOVERY 
		{ $$ <- recoverydef.create[env$ln, $2] }
	;
processDefinition :
		KPROCESS blockBody KEND KPROCESS 
		{ $$ <- processdef.create[env$ln, $2] }
	;
declarationsAndStatements :
		empty
		{ $$ <- sseq.create[env$ln] }
	|	declarationsAndStatements declaration
		{ $$ <- $1 $$.rcons[$2] }
	|	declarationsAndStatements statement
		{ $$ <- $1 $$.rcons[$2] }
	;
statement :
		ifStatement { $$ <- $1 }
	|	loopStatement { $$ <- $1 }
	|	forStatement { $$ <- $1 }
	|	exitStatement { $$ <- $1 }
	|	assignmentOrInvocationStatement { $$ <- $1 }
	|	assertStatement { $$ <- $1 }
	|	moveStatement { $$ <- $1 }
	|	compoundStatement { $$ <- $1 }
	|	primitiveStatement { $$ <- $1 }
	|	waitStatement { $$ <- $1 }
	|	signalStatement { $$ <- $1 }
	|	returnStatement { $$ <- $1 }
	|	returnAndFailStatement { $$ <- $1 }
	|	error 
	;
optDeclaration :
		empty { $$ <- $1 }
	|	TLSQUARE symbolDefinition TRSQUARE 
		{ $$ <- vardecl.create[env$ln, $2, sym.create[env$ln, env$itable.Lookup["any", 999]], nil] }
	;
unavailableHandler :
		empty { $$ <- $1 }
	|	KUNAVAILABLE optDeclaration blockBody KEND KUNAVAILABLE 
		{ $$ <- xunavail.create[env$ln, $2, $3] }
	;
failureHandler :
		empty { $$ <- $1 }
	|	KFAILURE blockBody KEND KFAILURE 
		{ $$ <- xfailure.create[env$ln, $2] }
	;
ifClauseS :
		ifClause 
		{ $$ <- seq.singleton[$1] }
	|	ifClauseS KELSEIF ifClause 
		{ $$ <- $1 $$.rcons[$3] }
	;
ifClause :
		expression KTHEN declarationsAndStatements 
		{ $$ <- ifclause.create[env$ln, $1, $3] }
	;
elseClause :
		empty { $$ <- $1 }
	|	KELSE declarationsAndStatements 
		{ $$ <- elseclause.create[env$ln, $2] }
	;
ifStatement :
		KIF ifClauseS elseClause KEND KIF 
		{ $$ <- ifstat.create[env$ln, $2, $3] }
	;
forStatement :
		KFOR TLPAREN assignmentOrInvocationStatement TCOLON expression TCOLON assignmentOrInvocationStatement TRPAREN declarationsAndStatements KEND KFOR 
		{ const inv : Invoc <- invoc.create[env$ln, $5, opname.literal["!"], nil]
		  const ex : ExitStat <- exitstat.create[env$ln, inv]
		  var s : Tree <- sseq.create[env$ln]
		  var l : Tree
		  s.rcons[ex]
		  s.rcons[block.create[env$ln, $9, nil, nil]]
		  s.rcons[$7]
		  l <- loopstat.create[env$ln, s]
		  s <- sseq.create[env$ln]
		  s.rcons[$3]
		  s.rcons[l]
		  $$ <- block.create[env$ln, s, nil, nil] }
	|	KFOR symbolDefinition typeClause initializer KWHILE expression KBY assignmentOrInvocationStatement declarationsAndStatements KEND KFOR 
		{ const inv : Invoc <- invoc.create[env$ln, $6, opname.literal["!"], nil]
		  const ex : ExitStat <- exitstat.create[env$ln, inv]
		  var s : Tree <- sseq.create[env$ln]
		  var l : Tree
		  s.rcons[ex]
		  s.rcons[block.create[env$ln, $9, nil, nil]]
		  s.rcons[$8]
		  l <- loopstat.create[env$ln, s]
		  s <- sseq.create[env$ln]
		  s.rcons[vardecl.create[env$ln, $2, $3, $4]]
		  s.rcons[l]
		  $$ <- block.create[env$ln, s, nil, nil] }
	;
loopStatement :
		KLOOP declarationsAndStatements KEND KLOOP 
		{ $$ <- loopstat.create[env$ln, $2] }
	;
exitStatement :
		KEXIT whenClause 
		{ $$ <- exitstat.create[env$ln, $2] }
	;
whenClause :
		empty { $$ <- $1 }
	|	KWHEN expression 
		{ $$ <- $2 }
	;
alphaS :
		alpha
		{ $$ <- seq.singleton[$1] }
	|	alphaS TCOMMA alpha 
		{ $$ <- $1 $$.rcons[$3] }
	;
assignmentOrInvocationStatement :
		alpha
		{ $$ <- $1 }
	|	alphaS OASSIGN expressionS 
		{ $$ <- assignstat.create[env$ln, $1, $3] }
	;
assertStatement :
		KASSERT expression 
		{ $$ <- assertstat.create[env$ln, $2] }
	;
moveStatement :
		KMOVE expression KTO expression 
		{ $$ <- movestat.create[env$ln, $2, $4, opname.literal["move"]] }
	|	KFIX expression KAT expression 
		{ $$ <- movestat.create[env$ln, $2, $4, opname.literal["fix"]] }
	|	KREFIX expression KAT expression 
		{ $$ <- movestat.create[env$ln, $2, $4, opname.literal["refix"]] }
	|	KUNFIX expression
		{ $$ <- movestat.create[env$ln, $2, nil, opname.literal["unfix"]] }
	;
compoundStatement :
		KBEGIN blockBody KEND 
		{ $$ <- $2 }
	;
returnStatement :
		KRETURN 
		{ $$ <- returnstat.create[env$ln] }
	;
returnAndFailStatement :
		KRETURNANDFAIL 
		{ $$ <- returnandfailstat.create[env$ln] }
	;
primitiveImplementation :
		empty { $$ <- seq.create[env$ln] }
	|	primitiveImplementation TINTEGERLITERAL
		{ $$ <- $1 $$.rcons[$2] }
	|	primitiveImplementation TSTRINGLITERAL
		{ $$ <- $1 $$.rcons[$2] }
	;
oself :
		empty { $$ <- $1 }
	|	KSELF { $$ <- selflit.create[env$ln] }
	;
ovar :
		empty { $$ <- $1 }
	|	KVAR { $$ <- selflit.create[env$ln] }
	;
primitiveStatement :
		KPRIMITIVE oself ovar primitiveImplementation TLSQUARE symbolReferenceSopt TRSQUARE OASSIGN TLSQUARE symbolReferenceOrLiteralSopt TRSQUARE 
		{ $$ <- primstat.create[env$ln, $2, $3, $4, $6, $10] }
	;
symbolReferenceSopt :
		empty { $$ <- $1 }
	|	symbolReferenceS { $$ <- $1 }
	;
symbolReferenceOrLiteralSopt :
		empty { $$ <- $1 }
	|	symbolReferenceOrLiteralS { $$ <- $1 }
	;
waitStatement :
		KWAIT expression 
		{ $$ <- waitstat.create[env$ln, $2] }
	;
signalStatement :
		KSIGNAL expression 
		{ $$ <- signalstat.create[env$ln, $2] }
	;
expressionS :
		expression 
		{ $$ <- seq.singleton[$1] }
	|	expressionS TCOMMA expression 
		{ $$ <- $1 $$.rcons[$3] }
	;
negate :
		ONEGATE { $$ <- $1 }
	|	OMINUS  { $$ <- $1 }
	;
expression :
		expressionZero { $$ <- $1 }
	|	expression OOR expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression KOR expression 
		{ $$ <- exp.create[env$ln, $1, opname.literal["or"], $3]}
	|	expression OAND expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression KAND expression 
		{ $$ <- exp.create[env$ln, $1, opname.literal["and"], $3]}
	|	ONOT expression 
		{ $$ <- invoc.create[env$ln, $2, (view $1 as hasIdent)$id, nil] }
	|	expression OIDENTITY expression 
		{ $$ <- exp.create[env$ln, $1, (view $2 as hasIdent)$id, $3] }
	|	expression ONOTIDENTITY expression 
		{ $$ <- exp.create[env$ln, $1, (view $2 as hasIdent)$id, $3] }
	|	expression OEQUAL expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression ONOTEQUAL expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OGREATER expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OLESS expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OGREATEREQUAL expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OLESSEQUAL expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OCONFORMSTO expression 
		{ $$ <- exp.create[env$ln, $1, (view $2 as hasIdent)$id, $3] }
	|	KVIEW expression KAS expression 
		{ $$ <- xview.create[env$ln, $2, $4] }
	|	KRESTRICT expression KTO expression 
		{ $$ <- xview.create[env$ln, $2, $4] }
	|	expression OPLUS expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OMINUS expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OTIMES expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression ODIVIDE expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression OMOD expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	expression TOPERATOR expression 
		{ $$ <- invoc.create[env$ln, $1, (view $2 as hasIdent)$id, seq.singleton[$3]] }
	|	negate expression %prec ONEGATE
		{
		  const x : Tree <- $2
		  const s <- nameof x
		  
		  if s = "aliteral" and (view x as Literal)$index = IntegerIndex then
		    const il : Literal <- view x as Literal
		    const old : String <- il$str
		    if old[0] = '-' then
		      il$str <- old[1, old.length - 1]
		    else
		      il$str <- "-" || old
		    end if
		    $$ <- x
		  else
		    $$ <- invoc.create[env$ln, $2, (view $1 as hasIdent)$id, nil]
		  end if
		}
	|	KLOCATE expression 
		{ $$ <- unaryexp.create[env$ln, opname.literal["locate"],$2]}
	|	KAWAITING expression 
		{ $$ <- unaryexp.create[env$ln, opname.literal["awaiting"],$2]}
	|	KCODEOF expression 
		{ $$ <- unaryexp.create[env$ln,opname.literal["codeof"],$2]}
	|	KNAMEOF expression 
		{ $$ <- unaryexp.create[env$ln,opname.literal["nameof"],$2]}
	|	KTYPEOF expression 
		{ $$ <- unaryexp.create[env$ln,opname.literal["typeof"],$2]}
	|	KSYNTACTICTYPEOF expression 
		{ $$ <- unaryexp.create[env$ln,opname.literal["syntactictypeof"],$2]}
        |       KISLOCAL expression
                { $$ <- unaryexp.create[env$ln,opname.literal["islocal"],$2]}
        |       KISFIXED expression
                { $$ <- unaryexp.create[env$ln,opname.literal["isfixed"],$2]}
	;
expressionZero :
		alpha { $$ <- $1 }
	;
/* alphas are any invocation expression */
alpha :
		beta { $$ <- $1 }
	|	KNEW primary 
		{ $$ <- newExp.create[env$ln, $2, nil] }
	|	alpha TDOT operationNameReference
		{ $$ <- invoc.create[env$ln, $1, (view $3 as hasIdent)$id, nil] }
	|	alpha TDOTSTAR primary
		{ $$ <- starinvoc.create[env$ln, $1, $3, nil] }
	|	alpha TDOTQUESTION operationNameReference 
		{ $$ <- questinvoc.create[env$ln, $1, (view $3 as hasIdent)$id, nil] }
	;
/* betas are subscriptable */
beta:
		primary { $$ <- $1 }
	|	KNEW primary neArgumentClause
		{ $$ <- newExp.create[env$ln, $2, $3] }
	|	beta TLSQUARE argumentS TRSQUARE 
		{ $$ <- subscript.create[env$ln, $1, $3] }
	|	alpha TDOLLAR TIDENTIFIER 
		{ $$ <- fieldsel.create[env$ln, $1, $3] }
	|	alpha TDOT operationNameReference neArgumentClause 
		{ $$ <- invoc.create[env$ln, $1, (view $3 as hasIdent)$id, $4] }
	|	alpha TDOTSTAR primary neArgumentClause 
		{ $$ <- starinvoc.create[env$ln, $1, $3, $4] }
	|	alpha TDOTQUESTION operationNameReference neArgumentClause 
		{ $$ <- questinvoc.create[env$ln, $1, (view $3 as hasIdent)$id, $4] }
	;
		
primary :
		literal { $$ <- $1 }
	|	symbolReference { $$ <- $1 }
	|	TLPAREN expression TRPAREN 
		{ $$ <- $2 }
	;
operationNameDefinition :
		operationName { $$ <- $1 }
	|	operatorName { $$ <- $1 }
	|	definableOperatorName { $$ <- $1 }
	;
operatorName :
		TOPERATOR { $$ <- $1 }
	;
operationName :
		TIDENTIFIER 
		{ $$ <- $1 }
	;
definableOperatorName :
		OOR { $$ <- $1 }
	|	OAND { $$ <- $1 }
	|	OEQUAL { $$ <- $1 }
	|	ONOTEQUAL { $$ <- $1 }
	|	OGREATER { $$ <- $1 }
	|	OLESS { $$ <- $1 }
	|	OGREATEREQUAL { $$ <- $1 }
	|	OLESSEQUAL { $$ <- $1 }
	|	ONEGATE { $$ <- $1 }
	|	ONOT { $$ <- $1 }
	|	OPLUS { $$ <- $1 }
	|	OMINUS { $$ <- $1 }
	|	OTIMES { $$ <- $1 }
	|	ODIVIDE { $$ <- $1 }
	|	OMOD { $$ <- $1 }
	;
nondefinableOperatorName :
		OIDENTITY { $$ <- $1 }
	|	ONOTIDENTITY { $$ <- $1 }
	|	OCONFORMSTO { $$ <- $1 }
	;
operationNameReference :
		operatorName { $$ <- $1 }
	|	definableOperatorName { $$ <- $1 }
	|	nondefinableOperatorName { $$ <- $1 }
	|	operationName { $$ <- $1 }
	;
neArgumentClause :
		TLSQUARE TRSQUARE 
		{ $$ <- nil }
	|	TLSQUARE argumentS TRSQUARE 
		{ $$ <- $2 }
	;
argumentS :
		argument 
		{ $$ <- seq.singleton[$1] }
	|	argumentS TCOMMA argument 
		{ $$ <- $1 $$.rcons[$3] }
	;
argument :
		expression 
		{ $$ <- $1 }
	|	KMOVE expression 
		{ const t <- arg.create[env$ln, $2]
% If doing move/visit
%		  t$ismove <- true
		  $$ <- t }  
	|	KVISIT expression 
		{ const t : Arg <- arg.create[env$ln, $2]
% If doing move/visit
%		  t$isvisit <- true
		  $$ <- t }
	;
literal :
		TSTRINGLITERAL { $$ <- $1 }
	|	TCHARACTERLITERAL { $$ <- $1 }
	|	TINTEGERLITERAL { $$ <- $1 }
	|	TREALLITERAL { $$ <- $1 }
	|	KTRUE 
		{ const t <- Literal.BooleanL[env$ln, true] 
		  $$ <- t }
	|	KFALSE 
		{ const t <- Literal.BooleanL[env$ln, false]
		  $$ <- t }
	|	KSELF 
		{ $$ <- selflit.create[env$ln] }
	|	KNIL 
		{ $$ <- Literal.NilL[env$ln] }
	|	typeLiteral { $$ <- $1 }
	|	vectorLiteral { $$ <- $1 }
	;
vectorLiteral :
		TLCURLY expressionSOpt typeClauseOpt TRCURLY 
		{ $$ <- vectorlit.create[env$ln, $3, $2, nil] }
	;
expressionSOpt :
		empty { $$ <- $1 }
	|	expressionS { $$ <- $1 }
	|	expressionS TCOMMA { $$ <- $1 }
	;
typeObject :
		abstractType { $$ <- $1 }
	|	KIMMUTABLE abstractType
		{ const x <- $2
		  const y <- view x as OTree
		  y$isImmutable <- true
		  $$ <- $2 }
	;
typeLiteral :
		typeRest 
		{ $$ <- $1 }
	|	KIMMUTABLE typeRest 
		{ const x <- $2
		  const y <- view x as OTree
		  y$isImmutable <- true
		  $$ <- $2 }
	|	KMONITOR typeRest 
		{ 
		  const y <- view $2 as Monitorable
		  if nameof $2 = "anatlit" then
		    env.SemanticError[$2$ln, "Monitored typeobjects don't make sense", nil]
		  end if
		  y$isMonitored <- true
		  $$ <- $2 
		}
	;
typeRest :
		abstractType { $$ <- $1 }
	|	object { $$ <- $1 }
	|	closure { $$ <- $1 }
	|	record { $$ <- $1 }
	|	enumeration { $$ <- $1 }
	|	class { $$ <- $1 }
	;
symbolReference :
		TIDENTIFIER 
		{ $$ <- $1 }
	;
symbolDefinition :
		TIDENTIFIER 
		{ $$ <- $1 }
	;
%%
