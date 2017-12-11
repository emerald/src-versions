
Emerald CCALL Support Mechanism
==============================

(You are in a maze of twisty little subdirectories, all alike.)
   > cd ccalls
You are in a room full of directories containing source code for C 
functions that are callable from within Emerald code.  Small bits of
C live in the misk directory (as opposed to having their own directory.)

Usage
====

After adding or deleting a directory of C code, or changing any entry in any
of those directories: 

   emmake export

Adding CCALLS
============

1.  Create a subdirectory of $EMERALDROOT/ccalls.  Placing in it all of the
    C source necessary for your extension.  The C source must consist of
    precisely one file, named the same as the module, and that name must not
    conflict with any source file name in $EMERALDROOT/vm/src (otherwise
    liker havoc results).

2.  Create a Makefile in that directory.
    
    The Makefile that lives here manufactures ../lib/ccdef, a list of all
    defined ccalls module indicies and function indicies by invoking 

       emmake export
    
    on each subdirectory in the list SUBDIRS, to do most of the work.
    Hence, each  subdirectory's Makefile is responsible for providing an
    export target, which needs to produce a file ../<directory>.h describing
    the exported functions.
    
    A typical export rule for a subdirectory Makefile:
    
      export : ../<directory>.h
    
    The Makefile that lives here may also invoke
    
      emmake clean
    
    in each subdirectory, and hence, each subdirectory Makefile must 
    provide a clean target as well. 
    
    Note the use of emmake.  emmake is a mechanism to allow relatively
    clean support for multiple architectures, and basically invokes make
    after including (in an architecture independent way) a number of
    common macro definitions, whose values vary widely from architecture
    to architecture.  The subdirectory Makefiles should all make use
    of any applicable macros, found in
    
      $EMERALDROOT/lib/$EMERALDARCH/macroMakefile
    
    rather than attempt to define them themselves.

3.  Add the name of the subdirectory to the END of the list of SUBDIRS and
    add the name of the .h file to the END of the list of DOTHS in
    $EMERALDROOT/ccalls/Makefile

4.  Edit $EMERALDROOT/lib/ccallsMf to include:

    1.  Your new source file in CCALLS_SRC
    2.  Rules for making the object file from the source file.  Yes, it is
	imaginable that these could be figured out, but they need to include
	-I the ccalls source directory, and I don't know how to get make to
	do that.
    3.  Do NOT (repeat NOT NOT NOT) add your new object files to the
	CCALLS_OBJ, unless every interpreter must use them.  Each
	configuration of the interpreter chooses which ccalls to include by
	having its own CCALLS_OBJ.  If it doesn't define one of its own it
	gets the default from $EMERALDROOT/lib/ccallsMf.  That list should
	contain just the basics:  emstream, string, misk.

The Description File
-------------------

We need the following pieces of information for each function to be
able to call it from Emerald:

   the C function name (to know which C function to call)
   a description of the arguments and return type of the C function (to 
       know how to convert arguments from Emerald to C types and back) 
   a CCALL subcode name (the name by which the C function's subcode 
       will be referred to in Emerald source code) 

As well, the C compiler requires the C function declarations to
generate tables of the C functions.

Typically, then, the exported description file will be a slightly 
modified version of the package's usual .h file, and will simply be 
copied to ..  The modifications consist of adding 'pseudo-prototypes' 
for the exported functions to the file, and adding some 'glue' to 
ensure that the modified header file is still palatable to the C 
compiler.  The same file can (and should!) then be used by the C 
compiler as a header for the package, and by numerous tools to produce 
various files for use by Emerald. 

To export the header file:

  ../<directory>.h : <directory>.h
      cp <directory>.h $@

Because the .h file is copied around, it should not #include any files 
using relative paths.  (Ideally, it should not #include any files other 
than standard ones, delimited by <>s.) 

The pseudo-prototypes provide the information we need to know, listed 
above, and are simply invocations of a macro CCALL. 

   /* a function prototype */
   extern void funcname(int, void*, char*);
   /* a pseudo-prototype for it */
   CCALL(funcname, FUNCNAME, "vips")

The arguments are the real, C, name of a function to be exported, the 
Emerald CCALL subcode name by which you wish the C function to be known 
(typically, the C name uppercased, although you might wish to name it 
differently if this introduces a name conflict with any existing 
Emerald subcode name) and an argstring, which reflects the types of the 
return value (first character) and the arguments (remaining characters) 
of the function in question.  Each return/argument type is represented
by one of the following characters: 

   v   void       (only valid as a return type)
   b   boolean    (an integer, but knowing the intended use is helpful)
   i   integer 
   p   pointer    (left uninterpreted, consider it a magic cookie)
   s   string     (i.e. char*)

In order to make the modified header file remain palatable to the C 
compiler, add the following lines before the pseudo-prototypes.  

   #if !defined(CCALL)
   #define CCALL(func, subcode, argstring) 
   #endif /* CCALL */

For a complete example, check the string directory Makefile and string.[ch]
files.


Internal Machinations
====================

The .h files are combined and massaged to produce the list of module and
function indicies, which is exported to the ../lib/ccdef file so that the
compiler is aware of these names.  Each architecture specific macroMf
chooses the ccalls that it wants to include, and a shell script (gencctab)
produces cctab.[ch] files in the interpreter build directory as part of the
regular build process.  In order to prevent complete chaos, stubs indicating
that a requested ccall is not implemented in this version of the interpreter
are inserted into the lookup tables for non selected modules.

To understand this fully, watch the messages produced when constructing
cctab.[ch], and then take a look at the produced cctab.h.

Some C call support code is always part of the interpreter.  It's 
contained in the routine doNCCall() in misc.c in the interpreter directory.

