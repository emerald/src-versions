% I should test the union syntax.

const tunion <- object tunion
  process
    const rec <- union rec
      var i : Integer
      var c : Character
    end rec
    var r : rec
    r <- rec.createI[5]
    stdout.PutString["After the creation (should be 5) "]
    stdout.PutInt[r.geti]
    stdout.PutString["\^JAfter the assignment (should be 99) "]
    r.setI[99]
    stdout.PutInt[r.getI]
    stdout.PutString["\^J"]
  end process
end tunion
