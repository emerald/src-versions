const tch <- object tch
  initially
    assert "".length = 0
    assert "abc".index['a'] = 0
    assert "abc".index['b'] = 1
    assert "abc".index['d'] == nil
    assert "abc".index['c'] = 2
    assert "abca".index['a'] = 0
    assert "abca".rindex['a'] = 3
    assert "abcabcad".span["abc"] = 7
    assert "abcabcad".cspan["abc"] = 0
    assert "abcabcad".span["abcd"] = 8
    assert "abcabcad".cspan[""] = 8
    assert "abcabc".str["abc"] = 0
    assert "abdabc".str["abc"] = 3
    assert "abdabc".str["abe"] == nil
    var a, b : String
    a, b <- "  \tabc\t \tdef".token[" \t"]
    assert a = "abc"
    assert b = "\t \tdef"
    a, b <- b.token[" \t"]
    assert a = "def"
    assert b == nil
  end initially
end tch
