const target <- object target
  export operation dofix 
    fix self at locate self
  end dofix
end target

const main <- object main
  const here <- locate self
  const there <- here$activeNodes[1]$theNode
  operation tryrefix 
    refix target at there
    unavailable
      (locate self)$stdout.putstring["Refix of target raised unavailable\n"]
    end unavailable
    failure
      (locate self)$stdout.putstring["Refix of target raised failure\n"]
    end failure
  end tryrefix
  operation tryisfixed 
    (locate self)$stdout.putstring["isfixed target == " || (isfixed target).asString || "\n"]
    unavailable
      (locate self)$stdout.putstring["Isfixed of target raised unavailable\n"]
    end unavailable
    failure
      (locate self)$stdout.putstring["Isfixed of target raised failure\n"]
    end failure
  end tryisfixed
  operation tryunfix 
    unfix target
    unavailable
      (locate self)$stdout.putstring["Unfix of target raised unavailable\n"]
    end unavailable
    failure
      (locate self)$stdout.putstring["Unfix of target raised failure\n"]
    end failure
  end tryunfix
  operation trymove [towhere : Node]
    move target to towhere
    unavailable
      (locate self)$stdout.putstring["Move of target raised unavailable\n"]
    end unavailable
    failure
      (locate self)$stdout.putstring["Move of target raised failure\n"]
    end failure
  end trymove
  process
    stdout.putstring["Moving fixed\n"]
    fix target at self
    self.tryisfixed
    self.trymove[there]
    stdout.putstring["Unfixing\n"]
    self.tryunfix
    self.tryisfixed
    stdout.putstring["Moving unfixed\n"]
    self.trymove[there]
    self.tryisfixed
    stdout.putstring["Refixing\n"]
    self.tryrefix
    self.tryisfixed
    stdout.putstring["Moving home\n"]
    self.trymove[here]
    self.tryisfixed
    stdout.putstring["Unfixing\n"]
    self.tryunfix
    self.tryisfixed
    stdout.putstring["Moving home\n"]
    self.trymove[here]
    self.tryisfixed
    stdout.putstring["Done\n"]
  end process
end main
