const Person <- class Person[name:String]
  export function getName[] -> [myName: String]
    myName <- name
  end getName
end Person

const Teacher <- class Teacher (Person) [title:String]
  export function getTitle[] -> [myTitle: String]
    myTitle <- title
  end getTitle
end Teacher



const main <-
  object mainProgram
   var p: Person <- Person.create["Joe"]
   var t: Teacher <- Teacher.create["Susan", "Professor"]
   process
     stdout.putstring[p.getName]
     stdout.putstring[t.getName]
     stdout.putstring[t.getTitle]
   end process
  end mainProgram
