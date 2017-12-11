const t <- object t
  process
%    var d : SequenceOfAny
    var d : Directory
    const x <- d.lookup["ho"]
%    const x <- d.upperbound
  end process
end t
