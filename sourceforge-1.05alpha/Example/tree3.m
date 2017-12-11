const Tree <- class Tree[value : Integer]
  var left, right: Tree
  export op inorder[stdout : OutStream]
    if left !== nil then
      left.inorder[stdout]
    end if
    stdout.putint[value, 0]
    stdout.putchar['\n']
    if right !== nil then
      right.inorder[stdout]
    end if
  end inorder
  export op insert[n : Integer]
    if n = value then
      % do nothing
    elseif n < value then
      if left == nil then
	left <- Tree.create[n]
      else
	left.insert[n]
      end if
    else
      if right == nil then
	right <- Tree.create[n]
      else
	right.insert[n]
      end if
    end if
  end insert
end Tree

const program <- object main
  process
     var t1, t2: Tree
     t1 <- Tree.create[45]
     t1.insert[23]
     t1.insert[66]
     t1.insert[1]
     t1.insert[2]
     t1.inorder[stdout]
  end process
end main
