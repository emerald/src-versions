const tfs <- object tfs
  process
    const root : Map <- Map.create
    root.insert[".", root]
    root.insert["..", root]
    const junk : Shell <- Shell.create[root]
  end process
end tfs
