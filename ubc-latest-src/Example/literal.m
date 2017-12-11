% Fil: literal.m
% Af : Jens Frank Hansen, d. 3/4-98
%
% Kort demonstration af operationen Array[Type].literal

const program <-
  object main
    % array of string
    var aos: array.of[String] <- array.of[String].literal[{"en","to"}] 

    % array of char
    var aoc: array.of[Character] <- array.of[Character].literal[{'a','b','c'}] 

    % array of integer
    var aoi: array.of[Integer] <- array.of[Integer].literal[{1, 2, 3, 4}]

    var i: integer <- aos.lowerbound

    process
      loop
      exit when i>aos.upperbound
        stdout.putstring[aos[i] || "\n"]
        i <- i+1
      end loop

      stdout.putstring[(aos.upperbound - aos.lowerbound + 1).asstring || "\n"]
      stdout.putstring[(aoc.upperbound - aoc.lowerbound + 1).asstring || "\n"]
      stdout.putstring[(aoi.upperbound - aoi.lowerbound + 1).asstring || "\n"]
    end process
  end main
