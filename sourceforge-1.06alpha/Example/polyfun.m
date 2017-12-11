%From black@cse.ogi.edu Sun Aug  6 20:02:27 1995
%X-VM-Attributes: [nil nil nil t t]
%Status: RO
%Received: from red.cse.ogi.edu (red.cse.ogi.edu [129.95.46.7]) by grolsch.cs.ubc.ca (8.6.10/8.6.9) with SMTP id UAA13528 for <norm@cs.ubc.ca>; Sun, 6 Aug 1995 20:02:23 -0700
%Received: from [129.95.40.113] by red.cse.ogi.edu with smtp
%	(Smail3.1.29.1 #4) id m0sfI1a-00000dC; Sun, 6 Aug 95 19:34 PDT
%X-Sender: black@church.cse.ogi.edu
%Message-Id: <ac4b2812050210046820@[129.95.40.113]>
%Mime-Version: 1.0
%Content-Type: text/plain; charset="us-ascii"
%From: black@cse.ogi.edu (Andrew P. Black)
%To: Norm Hutchinson <norm@cs.ubc.ca>
%Subject: Explicit vs Implict instantiation of polymorphic operations
%Date: Sun, 6 Aug 1995 19:35:24 -0700
%
%At a recent meeting, someone wrote the expression
%
%polyFun = lambda f: forall a'. a' -> a' . if f(true) then 3 else f(4) fi
%
%polyId = lambda x: forall b'. b' -> b'
%
%polyFun polyId
%
%The idea is that polyFun applies its argument to true and to 4, and the
%reults of these two applications should be boolean and integer
%respectively.  polyId, the polymorphic identity, satisfies these
%constraimnts, so the application polyFun polyId should be legal.
%
%The quesiton was whether polyFun can be writte as above, or whether it
%needs to explicitly instantiate f, as in
%
%polyFun = lambda f: forall a'. a' -> a' .
%                if f[boolean](true) then 3 else f[integer](4) fi
%
%In Emerald we went to some lengths not to have to do explicit
%instantiation, so I tried to write this in Emerald.  I wonder if I got it
%right.  Do you have a compiler that could check this?
%
%Because Emerald has no functions, it is all rather vervose; we need sevaral
%auxuilary definitions to define the argument type of polyFun.


const polyFun <- object Pf
                        export op poly [f: t] -> [r : integer]
			  where t <- typeobject pfa
			    op apply [alpha] -> [alpha]
			      forall alpha
			  end pfa
                                if f.apply[true] then r <- 3 else r <- f.apply[4]
                                end if
                        end poly
                 end Pf
const polyId <- object pI
                        export op apply [a:t] -> [r:t]
                                forall t
                                r <- a
                        end apply
                end pI

const tpf <- object tpf
  initially
    const answer: integer <- polyFun.poly[polyId]
    stdout.putint[answer,0]
    stdout.putchar['\n']
  end initially
end tpf

%It would be nice if you could actually compile this!
%
%        Andrew
%
%
%
