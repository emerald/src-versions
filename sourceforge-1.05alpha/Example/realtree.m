const Tree <- immutable object Tree
  export function of [keytype : Type] -> [r : X]
    suchthat keytype *> immutable typeobject T
	function = [T] -> [Boolean]
	function < [T] -> [Boolean]
      end T
    where
      X <- immutable typeobject X
	function of [valuetype : Type] -> [r : Y]
	  forall valuetype
	  where TreeType <- typeobject TreeType
	    operation insert[key : keytype, value : valuetype]
	    function  lookup[key : keytype] -> [value : valuetype]
	  end TreeType
	  where Y <- immutable typeobject Y
	    function create -> [r : TreeType]
	  end Y
      end X
    r <- immutable object iTree
      export function of [valuetype : Type] -> [r : Y]
	forall valuetype
	where TreeType <- typeobject TreeType
	  operation insert[key : keytype, value : valuetype]
	  function  lookup[key : keytype] -> [value : valuetype]
	end TreeType
	where Y <- immutable typeobject Y
	  operation create -> [r : TreeType]
	end Y
	r <- immutable object treeCreator
	  export operation create -> [r : TreeType]
	    r <- monitor object aTree
	      var key : keytype
	      var value : valuetype
	      export operation Insert[pkey : keytype, pvalue : valuetype]
		value <- pvalue
		key <- pkey
	      end Insert
	      export operation Lookup [pkey : keytype] -> [pvalue : valuetype]
		if pkey = key then
		  
		end if
	      end Lookup
	    end aTree
	  end create
	end treeCreator
      end of
    end iTree
  end of
end Tree

const tester <- object tester
  const myTreei <- Tree.of[String]
  const myTreec <- myTreei.of[Any]
  const myTree <- myTreec.create
  initially
    myTree.insert["Hi", 45]
    var x : Any <- myTree.lookup["Hi"]
  end initially
end tester
