const Tree <- immutable object Tree
  export function of [keytype : Type] -> [r : Y]
    suchthat
      keytype *> immutable typeobject T
	function = [T] -> [Boolean]
	function < [T] -> [Boolean]
      end T
    where
      TreeType <- typeobject TreeType
	operation insert[key : keytype]
	function  lookup[key : keytype] -> [found : Boolean]
      end TreeType
    where 
      Y <- immutable typeobject Y
	operation create -> [r : TreeType]
      end Y
    r <- immutable object treeCreator
      export operation create -> [r : TreeType]
	r <- monitor object aTree
	  var key : keytype
	  var left, right : TreeType

	  export operation Insert[pkey : keytype]
	    if key == nil then
	      assert left == nil and right == nil
	      key <- pkey
	    elseif pkey < key then
	      if left == nil then
		left <- treeCreator.create
	      end if
	      left.Insert[pkey]
	    else
	      if right == nil then
		right <- treeCreator.create
	      end if
	      right.Insert[pkey]
	    end if
	  end Insert

	  export operation Lookup [pkey : keytype] -> [found : Boolean]
	    if pkey = key then
	      found <- true
	    elseif pkey < key then
	      if left !== nil then
		found <- left.Lookup[pkey]
	      else
		found <- false
	      end if
	    else
	      if right !== nil then
		found <- right.Lookup[pkey]
	      else
		found <- false
	      end if
	    end if
	  end Lookup
	end aTree
      end create
    end treeCreator
  end of
end Tree

const tester <- object tester
  const myTree <- Tree.of[String].create
  initially
    myTree.insert["Hi"]
    myTree.insert["Hi y"]
    myTree.insert["Hh"]
    myTree.insert["Hi x"]
    if myTree.lookup["Hi x"] then
      stdout.putstring["Found it!\n"]
    end if
  end initially
end tester
