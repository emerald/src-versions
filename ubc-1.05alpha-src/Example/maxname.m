const int <- immutable object int
  export function largest[x : Integer, y : Integer] -> [r : Integer]
    if x > y then
      r <- x
    else
      r <- y
    end if
  end largest
end int

const valueint <- typeobject valueint
  operation value -> [Integer]
end valueint

  const xx <- immutable object xx
    export operation create [x : Integer, y : Integer] -> [r : ValueInt]
      r <- object whocares
        export operation value -> [r : Integer]
          r <- int.largest[x, y]
	end value
      end whocares
    end create
  end xx

  const comObj <- typeobject comType
    operation get -> [x1 : Integer]
    operation put[x : ValueInt]
  end comType

  const inputonlyObj <- immutable object inputonlyObj
    export operation create ->[result : comObj]
      result <-
        object ainputonlyObj
           export operation get -> [r : Integer]
             r <- (locate 1).getstdin.getChar.ord
           end get
           export operation put[r  : valueint]
             assert false
           end put
         end ainputonlyObj
     end create
   end inputonlyObj

  const outputonlyObj <- immutable object outputonlyObj
    export operation create ->[result : comObj]
      result <-
        object aoutputonlyObj
           export operation get -> [r : Integer]
             assert false
           end get
           export operation put[r  : valueInt]
	     const xx <- (locate 1).getstdout
             xx.putInt[r.value, 0]
	     xx.putchar['\n']
           end put
         end aoutputonlyObj
     end create
   end outputonlyObj

  const sharedObj <- immutable object sharedObj
    export operation create ->[result : comObj]
      result <- monitor object asharedObj
       var x : valueInt
       const c : Condition <- Condition.create
       var howmanywaiting : Integer <- 0

       export operation get -> [r : Integer]
	 howmanywaiting <- howmanywaiting + 1
	 if howmanywaiting < 2 then
	   wait c
	 else
	   signal c
	 end if
	 r <- x.value
       end get
       export operation put[r  : valueInt]
	 x <- r
	 howmanywaiting <- howmanywaiting + 1
	 if howmanywaiting < 2 then
	   wait c
	 else
	   signal c
	 end if
       end put
     end asharedObj
   end create
 end sharedObj

const maximumObject <- object maximumObject

const rin1 <- inputonlyobj.create
const rin2 <- inputonlyobj.create
const rin3 <- inputonlyobj.create
const rout <- outputonlyobj.create

    const max2Obj <- object max2Obj
     export operation max2[val1 : comObj, val2 : comObj, out : comObj]
          var o1 : Integer
          var o2 : Integer
          var result : Integer

  	  o1 <- val1.get
	  o2 <- val2.get
          out.put[xx.create[o1, o2]]
    end max2
  end max2Obj

  const rmid : comObj <- sharedObj.create

  const promax21 <- object promax21

     process 
		max2Obj.max2[rin1, rin2, rmid]
     end process
  end promax21
  
   const promax22 <- object promax22
      process 
		max2Obj.max2[rmid, rin3, rout]
      end process
   end promax22
    
end maximumObject


