x ./stacktest.m, 662 bytes, 2 tape blocks
% This program first creates a stack named myStack by invoking Stack.create.
% It pushes 4 integers into myStack, and then pops and prints them.

const Tester <- object Tester
  process
    const myStack: Stack <- Stack.create

    for i : Integer <- 0 while i < 4 by i <- i + 1
      stdout.PutString["Pushing " || i.asString || " on my stack.\n"]
      myStack.Push[i]
    end for

    stdout.PutString["Printing in reverse order.\n"]
    loop
      var x: Integer
      exit when myStack.Empty
      x <- myStack.Pop
      stdout.PutString["Popped " || x.asString || " from my stack.\n"]
    end loop
    stdout.close
    stdin.close
  end process
end Tester
