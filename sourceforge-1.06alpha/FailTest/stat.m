const test <- object test
  process
    begin
      3			% not a statement
    end
    if 45 = 56 then
      "abc"		% not a statement
    elseif 88 = 90 then
      0.1		% not a statement
    else
      true		% not a statement
    end if
    loop
      true		% not a statement
      exit when 4	% not boolean
      exit when 4.5	% not boolean
    end loop
    exit
    exit when true
    if 56 = 89 or 56 then end if	% 56 not boolean
    if 56 and 56 == 89 then end if	% 56 not boolean
    if Integer *> 45 then end if	% 45 not type
    if 45 *> Integer then end if	% 45 not type
  end process
end test
