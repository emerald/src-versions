const tudir <- object tudir
  process
    var dir : Integer
    var name : String
    primitive "NCCALL" "MISK" "UOPENDIR" [dir] <- ["."]
    loop
      primitive "NCCALL" "MISK" "UREADDIR" [name] <- [dir]
      exit when name == nil
      stdout.putstring[name] stdout.putchar['\n']
    end loop
    primitive "NCCALL" "MISK" "UCLOSEDIR" [] <- [dir]
  end process
end tudir
