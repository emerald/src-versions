const RIS <- immutable object RIS
  export function of [t : Type] -> [r : Signature]
    forall t
    r <- typeobject RT
      function lowerbound -> [Integer]
      function upperbound -> [Integer]
      function getelement[Integer] -> [t]
    end RT
  end of
end RIS

export RIS
