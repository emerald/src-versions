const tview <- object tview
  initially
    var x : String
    begin
      x <- view 37 as String
      stdout.putstring["view 37 as String suceeded\n"]
      failure
	stdout.putstring["view 37 as String failed\n"]
      end failure
    end
    begin
      x <- view "abc" as String
      stdout.putstring["view \"abc\" as String suceeded\n"]
      failure
	stdout.putstring["view \"abc\" as String failed\n"]
      end failure
    end
    begin
      x <- view nil as String
      stdout.putstring["view nil as String suceeded\n"]
      failure
	stdout.putstring["view nil as String failed\n"]
      end failure
    end
    begin
      x <- view nil as None
      stdout.putstring["view nil as None suceeded\n"]
      failure
	stdout.putstring["view nil as None failed\n"]
      end failure
    end
    x <- nil
    begin
      x <- view x as None
      stdout.putstring["view x as None suceeded\n"]
      failure
	stdout.putstring["view x as None failed\n"]
      end failure
    end
    begin
      x <- view x as String
      stdout.putstring["view x as String suceeded\n"]
      failure
	stdout.putstring["view x as String failed\n"]
      end failure
    end
  end initially
end tview
