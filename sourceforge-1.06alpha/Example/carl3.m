%const foo <-
%  object bar
    const R <-
      immutable object R
        const RType <-
	  immutable typeobject RType

	  end RType
        var baz : R
	export function getSignature [] -> [s : Signature]
	  s <- RType
	end getSignature
      end R
%  end bar
