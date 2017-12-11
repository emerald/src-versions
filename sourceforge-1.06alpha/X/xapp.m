const xapp <- object xapp

  const pause : Time <- Time.create[0, 0]
  const here : Node<- locate self
  operation pause 
    stdout.putstring["Pausing\n"]
    here.delay[pause]
  end pause

  process
    var w : Window
    const exitStatus <- 0

    for i : Integer <- 0 while i < 2 by i <- i + 1
      w <- X.CreateWindow[50+25*i, 50+25*i, 500, 500,"test"]
      w.setfont["6x10"]
      w.text["Hi there", 230, 10]
      w.batch[true]
      for j : Integer <- 10 while j < 500 by j <- j + 10
	w.line[0, j, 499, j]
	w.line[j, 0, j, 499]
      end for
      w.flush
      self.pause

      w.Relocate[200, 0]
      w.flush
      self.pause

      w.batch[false]

      w.set["height=400"]
      w.flush
      self.pause

      w.Text["some more stuff", 180, 300]
      w.flush
      self.pause

      stdout.putstring[w.get["height"]] stdout.putchar['\n']
      stdout.putstring[w.get["width"]] stdout.putchar['\n']
      w.unmap
      w.Close
      X.Flush
      primitive "CCALL" "EXIT" [] <- [exitStatus]
    end for
  end process
end xapp


