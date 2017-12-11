%rom: colas@bagheera.inria.fr (Colas Nahaboo)
%Subject: Small interpreters Benchmark: Fibo Festival
%Date: 26 Mar 92 10:19:35 GMT
%Organization: Koala Project, Bull Research France
%Lines: 317
%
%
%	The small interpreters naive benchmark: Fibo Festival!
%	======================================================
%
%		Sony News, 68030 25Mhz   SparcStation2
%		(compiled with gcc -O).  (comp. with cc -O)
%
%    		(fib 20)(fibobj (fibobj  (fib 20)(fibobj (fibobj
%			 15)	 20)		  15)     20)
%
%C		 0.07s			0.014s
%wool 2.1p	 3.82s	1.71s	19s	2.44s	0.95s	10.56s
%xscheme 0.22 [1] 4s	3s	30s	2s	2s	13s
%lucid CL [*]	 			3.60s		
%siod 2.4 [4]	 6.07s			1.13s
%fools 1.3.2	 9s
%elk 1.5 [3]	10s	87s		5s
%emacs-lisp [5]	11s			4s
%franz lisp [*]  14s
%xlisp 2.1d	16.83s	21.13s 235s 	6.08s	8.47s 	94.50s
%perl 4.019 [6]  20.52s			7.35s
%tcl 6.2		34.5s			21s
%ksh           9m24s		
%
%NOTES:
%[*] Commercial full-scale traditional lisp systems (may have assembly code)
%[1] XScheme is byte-coded, this explains its efficiency
%    to have a better comparison with wool, (fib 25) on a sony is done in
%    44.62s in wool, and in 46s in xscheme and in 27.50s and 19s on a 
%    sparcstation2
%[3] version with stack handler in 68000 assembly code (faster)
%[4] with the mark&sweep gc (faster than stop&copy)
%    (cfib 20) on sony: 0.90s
%[5] 9s if byte-compiled on sony, but still 4s compiled on sparc2
%[6] fib0 is fastest on sony and sun4
%
%These are NAIVE tests, to give just a rough indication of a the speed 
%of a language. Times are best of at least 5 runs on an otherwise idle machine.
%Times given with hundredth of seconds are timed by system primitives, 
%otherwise (seconds only) by a hand-held stopwatch.
%
%The goal of these tests is to test the object layer of the small interpreters,
%as this is not often tested speed-wise. It is also the most difficult to test,
%since they all have a different programming model!
%
%Note the interesting differences between a CISC CPU (sony) and a RICS one 
%(sparc), some languages are speeded more than 5 times, other only 50% more!
%
%Please add to this list:
% - new languages (Implementations of fib & fibobj in a straightforward way)
% - new timings on other machines
% - timing primitives in languages that I didn't find
% - better implementations of benchmarks, making use of language knowledge to
%   optimize it
%
%Please send all remarks and additions to:
%
%Colas Nahaboo, colas@sa.inria.fr, Bull Research, Koala Project, GWM X11 WM
%Pho:(33) 93.65.77.70(.66 Fax), INRIA, B.P.93 - 06902 Sophia Antipolis, FRANCE.
%
%/*****************************************************************************\
%* 			     Fibonnacci code used                             *
%\*****************************************************************************/
%
%/************************************************************** COMMMON LISP */
%; generic common lisp code (wool, Common Lisps, xlisp...) and emacs lisp
%
%(defun fib (n)
%  (if (< n 2) n
%    (+ (fib (- n 1)) (fib (- n 2)))))
%
%/******************************************************************** SCHEME */
%; generic scheme code (elk, fools, siod, xscheme...)
%; code provided in elk distribution
%
%(define (fib  n)
%  (if (< n 2) n
%    (+ (fib (- n 1)) (fib (- n 2)))
%))
%
%/*********************************************************************** TCL */
%# may be not optimal!
%proc fib {n} {
%  if {$n < 2} then {return $n} else {
%  return [expr {[fib [expr {$n - 1}]] + [fib [expr {$n - 2}]]}]}
%}
%
%/*********************************************************************** ksh */
%# totally unreasonable, just for fun...
%fib(){
% if let "$1<2"
% then echo $1
% else
%     let N1=$1-1
%     let N2=$1-2
%     let "N=`fib $N1`+`fib $N2`"
%     echo $N
% fi
%}
%
%/********************************************************************** perl */
%
%#perl code, contributed by Kresten Krab Thorup <krab@iesd.auc.dk>
%
%sub fib0 {
%	local($n)=@_;
%	($n < 2
%	   ? $n 
%	   : &fib($n-1)+&fib($n-2));
%}
%
%sub fib1 {
%	local($n)=@_;
%	if($n < 2) {
%	   return $n;
%	} else { 
%	   return (&fib1($n-1)+&fib1($n-2));
%	}
%}
%
%
%sub fib2 {
%	local($n)=@_;
%	($n-- < 2
%	   ? ++$n
%	   : &fib2($n--)+&fib2($n));
%}
%
%$start = (times)[0];
%&fib0(20);
%$end = (times)[0];
%printf "fib0(20) took %.2f CPU seconds\n", $end - $start;
%
%$start = (times)[0];
%&fib1(20);
%$end = (times)[0];
%printf "fib1(20) took %.2f CPU seconds\n", $end - $start;
%
%$start = (times)[0];
%&fib2(20);
%$end = (times)[0];
%printf "fib2(20) took %.2f CPU seconds\n", $end - $start;
%
%
%/************************************************************************* C */
%
%/* timing functions are BSD */
%#include <stdio.h>
%#include <sys/types.h>
%#include <sys/times.h>
%#include <sys/timeb.h>
%#include <sys/time.h>
%#include <sys/resource.h>
%
%main(argc, argv)
%    int argc;
%    char **argv;
%{
%    int n = 20;
%    int milliseconds;
%    int result;
%
%    if (argc > 1) {
%	n = atoi(argv[1]);
%    }
%    milliseconds = current_time();
%    result = fib(n);
%    milliseconds = current_time() - milliseconds;
%    printf("fib(%d) = %d in %d milliseconds\n", n, result, milliseconds);    
%}
%    
%int current_time()
%{
%    struct timeb time_bsd;
%
%    ftime(&time_bsd);
%    return 1000 * time_bsd.time + time_bsd.millitm;
%}
%    
%int fib(n)
%    int n;
%{
%    if (n < 2)
%	return n;
%    else
%	return fib(n-1) + fib(n-2);
%}
%
%
%/*****************************************************************************\
%* 			       Fib-object code                                *
%\*****************************************************************************/
%
%/********************************************************************** WOOL */
%
%
%(defclass Num () ((n :initform 0 :accessor Num.n)))
% 
%(setq Num1 (make-instance Num 'n 1))
%(setq Num2 (make-instance Num 'n 2))
%
%(defmethod add ((n1 Num) n2)
%  (make-instance Num 'n (+ (get n1 'n) (get n2 'n)))
%)
%(defmethod minus ((n1 Num) n2)
%  (make-instance Num 'n (- (get n1 'n) (get n2 'n)))
%)
%(defmethod less ((n1 Num) n2)
%  (< (get n1 'n) (get n2 'n))
%)
%
%(defun fibobj (n)
%  (setq t0 (get-internal-run-time))
%  (setq fibobj:result (dofibobj (make-instance Num 'n n)))
%  (? (- (get-internal-run-time) t0) "ms\n")
%  fibobj:result
%)
%
%(defun dofibobj (n)
%  (if (less n Num2) n
%    (add (dofibobj (minus n Num1)) (dofibobj (minus n Num2)))
%  )
%)
%
%/********************************************************************* XLISP */
%
%(load "init.lsp")
%(load "classes.lsp")
%
%(defclass Num ((n 0)))
% 
%(setq Num1 (send Num :new :n  1))
%(setq Num2 (send Num :new :n  2))
%
%(defmethod Num :add (n2)
%  (send Num :new :n (+ n (send n2 :n)))
%)
%(defmethod Num :minus (n2)
%  (send Num :new :n (- n (send n2 :n)))
%)
%(defmethod Num :less (n2)
%  (< n (send n2 :n))
%)
%
%(defun fibobj (n)
%  (setq fibobj:result (time (dofibobj (send Num :new :n n))))
%  (send fibobj:result :n)
%)
%
%(defun dofibobj (n)
%  (if (send n :less Num2) n
%    (send (dofibobj (send n :minus Num1))
%    :add (dofibobj (send n :minus Num2)))))
%
%/*********************************************************************** elk */
%
%(require 'oops)
%
%(define-class Num (instance-vars (n 0)))
%
%(define Num1 (make-instance Num (n 1)))
%(define Num2 (make-instance Num (n 2)))
%
%(define-method Num (add n2)
%  (make-instance Num (n (+ n (with-instance n2 n)))))
%
%(define-method Num (minus n2)
%  (make-instance Num (n (- n (with-instance n2 n)))))
%
%(define-method Num (less n2)
%  (< n (with-instance n2 n)))
%
%(define (fibobj N)
%  (with-instance (dofibobj (make-instance Num (n N))) n)
%)
%
%(define (dofibobj n)
%  (if (send n 'less Num2) n
%    (send (dofibobj (send n 'minus Num1))
%    'add (dofibobj (send n 'minus Num2)))
%))
%    
%/******************************************************************* XScheme */
%
%;; fibobj
%;; coded from what I could guess from the docs (colas)
%
%(set! Num (class 'new '(n)))
%
%(Num 'answer 'set '(x) '((set! n x) self))
%(Num 'answer 'get '() '(n))
%
%(Num 'answer 'add '(n2) '(
%    ((num 'new) 'set (+ n (n2 'get)))))
%
%(Num 'answer 'minus '(n2) '(
%    ((num 'new) 'set (- n (n2 'get)))))
%
%(Num 'answer 'less '(n2) '(
%    (< n (n2 'get))))
%
%((set! num1 (num 'new)) 'set 1)
%((set! num2 (num 'new)) 'set 2)
%
%(define (fibobj x)
%    (system "date")
%    (set! res ((dofibobj ((num 'new) 'set x)) 'get))
%    (system "date")
%    res
%)
%
%(define (dofibobj x)
%  (if (x 'less num2) x
%      ((dofibobj (x 'minus num1)) 'add (dofibobj (x 'minus num2)))))
%-- 
%Colas Nahaboo, colas@sa.inria.fr, Bull Research, Koala Project, GWM X11 WM
%Pho:(33) 93.65.77.70(.66 Fax), INRIA, B.P.93 - 06902 Sophia Antipolis, FRANCE.
%
const Num <- class Num[xn : Integer]
  
  const field n : Integer <- xn

  export function + [o : Num] -> [r : Num]
    r <- Num.create[n + o$n]
  end +

  export function < [o : Num] -> [r : Boolean]
    r <- n < o$n
  end <

  export function - [o : Num] -> [r : Num]
    r <- Num.create[n - o$n]
  end -
end Num

const Num1 <- Num.create[1]
const Num2 <- Num.create[2]

const test <- object test
  export operation dofib [n : Integer] -> [r : Integer]
    if n < 2 then
      r <- 1
    else
      r <- self.dofib[n - 1] + self.dofib[n - 2]
    end if
  end dofib

  initially
    const here <- locate 1
    var starttime, endtime : Time
    var answer : Integer

%    for i : Integer <- 0 while i < 10 by i <- i + 1
%      stdout.putstring["fib("] stdout.putint[i, 0]
%      stdout.putstring[") = "] stdout.putint[dofib[i], 0]
%      stdout.putchar['\n']
%    end for

    starttime <- here.getTimeOfDay
    answer <- self.dofib[15]
    endtime <- here.getTimeOfDay
    self.print["fib(15)", answer, starttime, endtime]
    
    starttime <- here.getTimeOfDay
    answer <- self.dofib[20]
    endtime <- here.getTimeOfDay
    self.print["fib(20)", answer, starttime, endtime]
    
    starttime <- here.getTimeOfDay
    answer <- self.dofibobj[Num.create[15]]$n
    endtime <- here.getTimeOfDay
    self.print["fibobj(15)", answer, starttime, endtime]
    
    starttime <- here.getTimeOfDay
    answer <- self.dofibobj[Num.create[20]]$n
    endtime <- here.getTimeOfDay
    self.print["fibobj(20)", answer, starttime, endtime]
    
  end initially

  export operation print [s : String, a : Integer, starttime: Time, endtime : Time]
    stdout.putstring[s]
    stdout.putstring[" = "]
    stdout.putint[a, 0]
    stdout.putstring[" in "]
    stdout.putstring[(endtime - starttime).asString]
    stdout.putstring[" seconds.\n"]
  end print

  export operation dofibobj [n : Num] -> [r : Num]
    if n < Num2 then
      r <- Num1
    else
      r <- self.dofibobj[n - Num1] + self.dofibobj[n - Num2]
    end if
  end dofibobj

end test
