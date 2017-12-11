const tch <- object tch
  initially
    assert 'a'.isalpha
    assert 'a'.islower
    assert !'a'.isupper
    assert !'a'.isspace
    assert 'A'.isupper
    assert !'a'.isupper
    assert !'0'.isupper
    assert '0'.isdigit
    assert !'A'.isdigit
    assert 'a'.isxdigit
    assert 'f'.isxdigit
    assert 'A'.isxdigit
    assert 'F'.isxdigit
    assert !'G'.isxdigit
    assert 'a'.isalnum
    assert '9'.isalnum
    assert !'-'.isalnum
    assert !'a'.ispunct
    assert '.'.ispunct
    assert 'a'.isprint
    assert !'\0'.isprint
    assert !'a'.iscntrl
    assert '\0'.iscntrl
    assert '\037'.iscntrl
    assert !'\377'.iscntrl
    assert 'a'.toupper = 'A'
    assert 'A'.tolower = 'a'
    assert '0'.toupper = '0'
    assert '-'.toupper = '-'
  end initially
end tch
