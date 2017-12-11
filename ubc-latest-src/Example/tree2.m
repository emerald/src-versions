const Tree <- immutable object Tree
  export function of [keytype : Type, valuetype : Type] -> [r : Y]
    suchthat keytype *> immutable typeobject T
	function = [T] -> [Boolean]
	function < [T] -> [Boolean]
      end T
    forall 
      valuetype
    where
      TreeType <- typeobject TreeType
	operation insert[key : keytype, value : valuetype]
	function  lookup[key : keytype] -> [value : valuetype]
      end TreeType
    where 
      Y <- immutable typeobject Y
	operation create -> [r : TreeType]
      end Y
    r <- immutable object treeCreator
      export operation create -> [r : TreeType]
	r <- monitor object aTree
	  var key : keytype
	  var value : valuetype
	  var left, right : TreeType

	  export operation Insert[pkey : keytype, pvalue : valuetype]
	    if key == nil then
	      assert left == nil and right == nil
	      key <- pkey
	      value <- pvalue
	    elseif pkey < key then
	      if left == nil then
		left <- treeCreator.create
	      end if
	      left.Insert[pkey, pvalue]
	    else
	      if right == nil then
		right <- treeCreator.create
	      end if
	      right.Insert[pkey, pvalue]
	    end if
	  end Insert

	  export operation Lookup [pkey : keytype] -> [pvalue : valuetype]
	    if pkey = key then
	      pvalue <- value
	    elseif pkey < key then
	      if left !== nil then
		pvalue <- left.Lookup[pkey]
	      end if
	    else
	      if right !== nil then
		pvalue <- right.Lookup[pkey]
	      end if
	    end if
	  end Lookup
	end aTree
      end create
    end treeCreator
  end of
end Tree

const tester <- object tester
  const myTreeType <- Tree.of[String, Any]
  const myTree <- myTreeType.create
  initially
    myTree.insert["Hi", 45]
    var x : Any <- myTree.lookup["Hi"]
  end initially
end tester
