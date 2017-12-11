const int <- Integer
    const b <- typeobject b
                operation anythingyoulike[int] -> [int]
              end b
 
%    const S <- object s
%                operation selfApp[x:a] -> [r:b]
%                    where a <- typeobject fun
%                                  operation apply[a] -> [b]
%                              end fun
%                    r <- x.apply[x]
%                end selfApp
%              end s
 
% Since b is arbitrary, we should be able to make it a parameter:
 
    const SC <- immutable object sc
      export function xnew[b:type] -> [r:rtype] % ... we should be able to infer this!
	forall b
	where rtype <- immutable typeobject rtype
	  op selfApp[a] -> [b]
	    where a <- typeobject fun
	      operation apply[a] -> [b]
	    end fun
	end rtype

        r <- immutable object s
          export operation selfApp[x:a] -> [r:b]
            where a <- typeobject fun
              operation apply[a] -> [b]
            end fun

            r <- x.apply[x]
          end selfApp
        end s
      end xnew
    end sc
 
% and now we can define
 
    const homFuntype <- typeobject h
      operation apply[d] -> [d] forall d
    end h
 
    const id <- object i
      export operation apply[a:d] -> [r:d] forall d
        r <- a
      end apply
    end i
 
    const homSelfApp <- SC.xnew[homFuntype]
    const answer <- homSelfApp.selfapp[id]
    const tester <- object tester
      initially
	assert (answer == id)
      end initially
    end tester

