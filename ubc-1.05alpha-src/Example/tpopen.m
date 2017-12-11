const tpopen <- object tpopen
  process
    const foo : InStream <- InStream.fromUnix["|df", "r"]
    loop
      exit when foo.eos
      const s <- foo.getString
      stdout.putstring[s]
    end loop
    foo.close
  end process
end tpopen
