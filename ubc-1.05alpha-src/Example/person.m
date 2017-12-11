export Person

const Person <- class Person[name:String]
  export function getName[] -> [myName: String]
    myName <- name
  end getName
end Person
