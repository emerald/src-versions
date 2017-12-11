const tmutveclit <- object tmutveclit
  initially
%    var a : Integer <- 5
%    var b : Integer <- 6
    var sa : String <- "This is a string\n"
    var sb : String <- "This is too\n"
%    const intfoo <- {a, b}
    const stringfoo <- { sa, sb : String }
%    const anyfoo <- {sa, a, sb, b}
    for i : Integer <- 0 while i <= stringfoo.upperbound by i <- i + 1
      stdout.putString[stringfoo[i]]
    end for
  end initially
end tmutveclit
