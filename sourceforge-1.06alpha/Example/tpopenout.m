const tpopen <- object tpopen
  process
    const foo : OutStream <- OutStream.toUnix["|cat > /tmp/foobar", "w"]
    loop
      exit when stdin.eos
      const s <- stdin.getString
      exit when s = "quit\n"
      foo.putstring[s]
    end loop
    foo.close
  end process
end tpopen
