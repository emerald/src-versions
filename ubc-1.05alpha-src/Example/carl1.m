const foo <-
  object bar
    const R <-
      immutable object R
        const RType <-
	  immutable typeobject RType

	  end RType
	export function getSignature [] -> [s : Signature]
	  s <- Integer.getSignature
	end getSignature
	export operation create [xi : Integer] -> [e : R]
	  e <-
	    object aR
	      var i : Integer <- xi
	    end aR
	end create
      end R
    var baz : R <- R.create[3]
  end bar


