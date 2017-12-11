
/*
 * int
 * saveProcContext(struct savearea *savearea)
 *
 * Save enough of the current state in SAVEAREA so that
 * control can later be returned to the caller of the function calling
 * saveProcContext().  SaveProcContext() behaves like setjmp(3) in that 0 is
 * returned when the context is saved but a non-zero value is returned
 * when returnto() resumes execution of the saved context.
 *
 * void
 * returnToProc(struct savearea *savearea)
 *
 * Restore the state previously stored in SAVEAREA and continue execution
 * based on that saved state.  This resumes a suspended thread, making
 * it look like a call to savecontext() with F == 0 is now returning.
 *
 * bjb/mwg Dec/89 and Jul/90
 */
/********************************************


note: unless the predecrement addressing mode is used, the register mask can
be interpreted as follows:

------------------------------------------------------------------------------
Mask:  MostSigBit  15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0  LeastSigBit
Register:          a7 a6 a5 a4 a3 a2 a1 a0 d7 d6 d5 d4 d3 d2 d1 d0
------------------------------------------------------------------------------

 if the predecrement addressing mode is used, the mask becomes:
------------------------------------------------------------------------------
Mask:  MostSigBit  15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0  LeastSigBit
Register:          d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6 a7

*********************************************/

#if defined(sun3) || defined(__NeXT__)
.text
.globl _saveProcContext

_saveProcContext:
	movl	sp@(0x4), a0		/* get save area (1st param) */
        movl    sp@, a0@                /* save ret address, it gets trashed*/
	moveml	#0xfefe, a0@(4)		/* save regs to save area    */
					/* this includes a6 (frame pointer) */
					/* and a7 (stack pointer)    */
        moveq   #17, d0
	rts


.text
.globl _startNewProc

_startNewProc:
        movl    sp@(0x4), a0            /* get function addr from stack   */
        movl    sp@(0x8), sp            /* set stack pointer to new stack */
        jmp     a0@


.text
.globl _returnToProc

_returnToProc:
	movl	sp@(0x4), a0		/* get save area (only param) */
	moveml	a0@(4), #0xfefe    	/* this restores the regs     */
        movl    a0@, sp@
        moveq   #0, d0
        rts

#endif /* sun3 */




#if defined(sun4) || defined(sun4sol)
#ifdef sun4
#include    <sun4/asm_linkage.h>
#include    <sun4/trap.h>
#endif

#ifdef sun4sol
#define _ASM
#include <sys/trap.h>
#include <sys/stack.h>

#endif
	
topstack =  0
globals  = 12

.text
#ifdef sun4
.global _saveProcContext
_saveProcContext:
#else
.global saveProcContext
saveProcContext:
#endif
    st  %g1, [%o0 + globals +  0]        ! Save all globals just in case
    st  %g2, [%o0 + globals +  4]
    st  %g3, [%o0 + globals +  8]
    st  %g4, [%o0 + globals + 12]
    st  %g5, [%o0 + globals + 16]
    st  %g6, [%o0 + globals + 20]
    st  %g7, [%o0 + globals + 24]
    mov %y, %g1
    st  %g1, [%o0 + globals + 28]

    st  %sp, [%o0 + topstack + 0]
    st  %o7, [%o0 + topstack + 4]

    jmp  %o7 + 0x8
    add %g0, 17, %o0

.text
#ifdef sun4
.global _startNewProc
_startNewProc:
#else
.global startNewProc
startNewProc:
#endif
    ta  ST_FLUSH_WINDOWS                ! Flush all other active windows

    add  %o1, STACK_ALIGN - 1, %o1      ! SPARC requires stricter alignment
    and  %o1, ~(STACK_ALIGN - 1), %o1   ! than malloc gives so force alignment
    sub  %o1, SA(MINFRAME), %fp
    sub  %fp, SA(MINFRAME), %sp

    jmpl %o0, %g0
    nop

.text
#ifdef sun4	
.globl _returnToProc
_returnToProc:
#else
.globl returnToProc
returnToProc:
#endif
    ta  ST_FLUSH_WINDOWS                ! Flush all other active windows

    ld  [%o0 + globals + 28], %g1       ! Restore global regs
    mov %g1, %y
    ld  [%o0 + globals +  0], %g1
    ld  [%o0 + globals +  4], %g2
    ld  [%o0 + globals +  8], %g3
    ld  [%o0 + globals + 12], %g4
    ld  [%o0 + globals + 16], %g5
    ld  [%o0 + globals + 20], %g6
    ld  [%o0 + globals + 24], %g7

    ld  [%o0 + topstack + 0], %fp
    sub %fp, SA(MINFRAME), %sp
    ld  [%o0 + topstack + 4], %o7

    clr  %o0
    retl
    restore %o0, 0x0, %o0

#endif /* sun4 */

#ifdef hp700

	.SPACE $PRIVATE$
	.SUBSPA $DATA$,QUAD=1,ALIGN=8,ACCESS=31
	.SUBSPA $BSS$,QUAD=1,ALIGN=8,ACCESS=31,ZERO,SORT=82
	.SPACE $TEXT$
	.SUBSPA $LIT$,QUAD=0,ALIGN=8,ACCESS=44
	.SUBSPA $CODE$,QUAD=0,ALIGN=8,ACCESS=44,CODE_ONLY
	.IMPORT $global$,DATA
	.IMPORT $$dyncall,MILLICODE
	.file	"context.c"
; gcc_compiled.:
	.SPACE $TEXT$
	.SUBSPA $CODE$
	.EXPORT saveProcContext,ENTRY,PRIV_LEV=3,ARGW0=GR,RTNVAL=GR
saveProcContext
	.PROC
	.CALLINFO FRAME=64,NO_CALLS,SAVE_SP,ENTRY_GR=3
	.ENTRY
	STWM    %rp, 4(%arg0)         /* store return address */
	STWM    3, 4(%arg0)           /* store general purpose registers */
	STWM    4, 4(%arg0)
	STWM    5, 4(%arg0)
	STWM    6, 4(%arg0)
	STWM    7, 4(%arg0)
	STWM    8, 4(%arg0)
	STWM    9, 4(%arg0)
	STWM    10, 4(%arg0)
	STWM    11, 4(%arg0)
	STWM    12, 4(%arg0)
	STWM    13, 4(%arg0)
	STWM    14, 4(%arg0)
	STWM    15, 4(%arg0)
	STWM    16, 4(%arg0)
	STWM    17, 4(%arg0)
	STWM    18, 4(%arg0)
	STWM    19, 4(%arg0)
	STWM    20, 4(%arg0)
	STWM    21, 4(%arg0)
	STWM    22, 4(%arg0)
	STWM    30, 4(%arg0)       /* store static link (necessray?) */
	STWM    %sp, 4(%arg0)       /* store stack pointer            */

	LDIL	17,%ret0            /* return the perfect number      */
 	bv,n	0(%r2)
	.EXIT
	.PROCEND
	.align 4


	.EXPORT startNewProc,ENTRY,PRIV_LEV=3,ARGW0=GR,ARGW1=GR
startNewProc  
	.PROC
	.CALLINFO FRAME=64,CALLS,SAVE_RP,SAVE_SP,ENTRY_GR=4
	.ENTRY
	copy %arg0, %r22	/* Set up argument to dyncall */
	.CALL	ARGW0=GR
	bl $$dyncall, %r31	/* Call through dyncall */
	COPY	%arg1,%sp	/* set stack pointer to new stack */
	.EXIT
	.PROCEND
	.align 4


	.EXPORT returnToProc,ENTRY,PRIV_LEV=3,ARGW0=GR
returnToProc
	.PROC
	.CALLINFO FRAME=64,NO_CALLS,SAVE_SP,ENTRY_GR=3
	.ENTRY
	LDWM    4(%arg0), %rp         /* load return address */
	LDWM    4(%arg0), 3           /* load general purpose registers */
	LDWM    4(%arg0), 4
	LDWM    4(%arg0), 5
	LDWM    4(%arg0), 6
	LDWM    4(%arg0), 7
	LDWM    4(%arg0), 8
	LDWM    4(%arg0), 9
	LDWM    4(%arg0), 10
	LDWM    4(%arg0), 11
	LDWM    4(%arg0), 12
	LDWM    4(%arg0), 13
	LDWM    4(%arg0), 14
	LDWM    4(%arg0), 15
	LDWM    4(%arg0), 16
	LDWM    4(%arg0), 17
	LDWM    4(%arg0), 18
	LDWM    4(%arg0), 19
	LDWM    4(%arg0), 20
	LDWM    4(%arg0), 21
	LDWM    4(%arg0), 22
	LDWM    4(%arg0), 30       /* load static link (necessray?) */
	LDWM    4(%arg0), %sp       /* load stack pointer            */
	LDIL	0, %ret0            /* return zero */
 	bv,n	0(%r2)
	.EXIT
	.PROCEND
	.align 4
        .END
#endif /* hp700 */


#ifdef mips
/* mips stuff has yet to be tested */

.text
.globl saveProcContext
.ent saveProcContext

saveProcContext:
	.set	noreorder
        sw      $16,  0($4)             /* save regs to save area */
        sw      $17,  4($4)
        sw      $18,  8($4)
        sw      $19, 12($4)
        sw      $20, 16($4)
        sw      $21, 20($4)
        sw      $22, 24($4)
        sw      $23, 28($4)
        sw      $fp, 32($4)
        sw      $sp, 36($4)
        sw      $31, 40($4)
        /* Don't know if gp needs to be saved... */

        li      $2, 17
        j       $31
	nop
.end saveProcContext

.text
.globl startNewProc
.ent startNewProc
startNewProc:
	.set	noreorder
	.cpload	$25
        addu    $sp, $0, $5             /* set stack pointer to new stack */
	move	$25,$4
        j       $25
	nop
.end startNewProc


.text
.globl returnToProc
.ent returnToProc

returnToProc:
	.set	noreorder
        lw      $16,  0($4)
        lw      $17,  4($4)
        lw      $18,  8($4)
        lw      $19, 12($4)
        lw      $20, 16($4)
        lw      $21, 20($4)
        lw      $22, 24($4)
        lw      $23, 28($4)
        lw      $fp, 32($4)
        lw      $sp, 36($4)

        lw      $31, 40($4)
        li      $2, 0
        j       $31
	nop
.end returnToProc

#endif /* mips */


#ifdef ibm

/* RS6000 */
.align 2
.toc
.csect .text[PR]
gcc2_compiled.:
__gnu_compiled_c:
	.align 2
	.globl startNewProc
	.globl .startNewProc
.csect startNewProc[DS]
startNewProc:
	.long .startNewProc, TOC[tc0], 0
.csect .text[PR]
.startNewProc:
/*
  We need to create a link area for this procedure.  This is because
  the function we call is allowed to write into our link area to save
  the CR and LR.  The link area also includes space reserved for the
  compiler and for saving the TOC.  It's currently 6 words (24 bytes)
  long; this code will need to be changed if the value changes.

  The POWER architecture specifies that the stack pointer must be
  quad-word aligned (16 bytes), so we take the next multiple up from
  24 as the space we need to reserve.  This assumes that the sp passed
  in is already quad-word aligned.
*/

	.set	linkarea, 32
	ai	1, 4, -linkarea
	l	0, 0(3)
	mtlr	0
	brl

LT..startNewProc:
	.long 0
	.byte 0,0,32,64,0,0,0,0
	.long LT..startNewProc-.startNewProc
	.short 12
	.byte "startNewProc"
	.align 2
	.globl returnToProc
	.globl .returnToProc
.csect returnToProc[DS]
returnToProc:
	.long .returnToProc, TOC[tc0], 0
.csect .text[PR]
.returnToProc:
	lm	13, 8(3)
	l	1, 4(3)
	l	0, 0(3)
	mtlr	0
	lil	3, 0

	br
LT..returnToProc:
	.long 0
	.byte 0,0,32,64,0,0,0,0
	.long LT..returnToProc-.returnToProc
	.short 12
	.byte "returnToProc"
	.align 2
	.globl saveProcContext
	.globl .saveProcContext
.csect saveProcContext[DS]
saveProcContext:
	.long .saveProcContext, TOC[tc0], 0
.csect .text[PR]
.saveProcContext:
	mflr	0
	st	0, 0(3)		/* save link */
	st	1, 4(3)		/* save sp */
	stm	13, 8(3)	/* save regs to save area */

	lil	3, 17
	br
LT..saveProcContext:
	.long 0
	.byte 0,0,32,64,0,0,0,0
	.long LT..saveProcContext-.saveProcContext
	.short 15
	.byte "saveProcContext"
_section_.text:
.csect .data[RW]
	.long _section_.text

#endif

#if defined(i386) || defined(i486)
#if defined(__FreeBSD__) || defined(__NetBSD__)
#define L(X) _##X
#endif
#if defined(__linux__) || defined(i86pc)
#define L(X) X
#endif

.globl L(saveProcContext)
.align 4

L(saveProcContext):
	mov %ebx, %eax      /* first thing we do is save EBX into EAX       */
	mov 4(%esp), %ebx   /* now we get the save area into EBX            */	
	mov %eax, 32(%ebx)  /* get old value of EBX from EAX into save area */
	mov (%esp), %eax    /* now we get the return address into save area */
	mov %eax, (%ebx)
	mov %edi, 4(%ebx)   /* save registers in save area */
	mov %esi, 8(%ebx)
	mov %edx, 16(%ebx)
	mov %ecx, 20(%ebx)
	mov %ebp, 24(%ebx)
	mov %esp, 28(%ebx)
	mov %eax, %ebx      /* restore EBX */
	mov $11, %eax       /* return value of 17 (decimal) :) */
	ret

.globl L(startNewProc)
.align 4

L(startNewProc):
	mov 4(%esp),%eax    /* we get the function pointer from the stack */
	mov 8(%esp),%esp    /* restore the stack pointer for the new thread */
	jmp %eax
	
.globl L(returnToProc)
.align 4

L(returnToProc):
	mov 4(%esp), %ebx    /* get the save area pointer into EBX */
	mov 4(%ebx), %edi   /* restore registers from save area */
	mov 8(%ebx), %esi
	mov 16(%ebx), %edx
	mov 20(%ebx), %ecx
	mov 24(%ebx), %ebp
	mov 28(%ebx), %esp
	mov (%ebx), %eax   /* restore the return address */
	mov %eax,(%esp)
	mov 32(%ebx), %eax  /* get old value of EBX from EAX into save area */
	mov %eax, %ebx      /* restore EBX */
	mov $0, %eax        /* return value of zero */
        ret

#endif /* i386 || i486 */

#ifdef alpha
	.ugen	
	.verstamp	3 11
	.text	
	.align	4
	.file	2 "fakecontext.c"
	.globl	startNewProc
	.ent	startNewProc 2
startNewProc:
	ldgp	$gp, 0($27)
	lda	$sp, -32($sp)
	stq	$26, 0($sp)
	.mask	0x04000000, -32
	.frame	$sp, 32, $26, 0
	.prologue	1
	and	$16, 4294967295, $16
	and	$17, 4294967295, $17

	addl	$17, 0, $sp
 #    9	  f();
	.livereg	0x00010002,0x00000000
	bis	$16, $16, $27
	jsr	$26, ($16), 0
	ldgp	$gp, 0($26)
 #   11	}
	.livereg	0x007F0002,0x3FC00000
	ldq	$26, 0($sp)
	lda	$sp, 32($sp)
	ret	$31, ($26), 1
	.end	startNewProc
	.text	
	.align	4
	.file	2 "fakecontext.c"
	.globl	returnToProc
	.loc	2 14
 #   12	
 #   13	void returnToProc(struct savearea *ts)
 #   14	{
	.ent	returnToProc 2
returnToProc:
	ldgp	$gp, 0($27)
	lda	$sp, -32($sp)
	stq	$26, 0($sp)
	.mask	0x04000000, -32
	.frame	$sp, 32, $26, 0
	.prologue	1
	and	$16, 4294967295, $1
	ldq	$0, 0($1)
	ldq	$2, 8($1)
	ldq	$3, 16($1)
	ldq	$4, 24($1)
	ldq	$5, 32($1)
	ldq	$6, 40($1)
	ldq	$7, 48($1)
	ldq	$8, 56($1)
	ldq	$9, 640($1)
	ldq	$10, 72($1)
	ldq	$11, 80($1)
	ldq	$12, 88($1)
	ldq	$13, 96($1)
	ldq	$14, 104($1)
	ldq	$15, 112($1)
	ldq	$16, 120($1)
	ldq	$17, 128($1)
	ldq	$18, 136($1)
	ldq	$19, 144($1)
	ldq	$20, 152($1)
	ldq	$21, 160($1)
	ldq	$22, 168($1)
	ldq	$23, 176($1)
	ldq	$24, 184($1)
	ldq	$25, 192($1)
	ldq	$26, 200($1)
	ldq	$27, 208($1)
 /*	ldq	$28, 216($1) */
	ldq	$29, 224($1)
	ldq	$30, 232($1)
	ldq	$sp, 240($1)
	ldq	$31, 248($1)
	.livereg	0x0001FC02,0x00000000

	lda	$sp, 32($sp)
	ldil	$0, 0
	ret	$31, ($26), 1
	.end	returnToProc
	.text	
	.align	4
	.file	2 "fakecontext.c"
	.globl	saveProcContext
	.loc	2 47
 #   45	
 #   46	int saveProcContext(struct savearea *ts)
 #   47	{
	.ent	saveProcContext 2
saveProcContext:
	ldgp	$gp, 0($27)
	lda	$sp, -32($sp)
	.frame	$sp, 32, $26, 0
	.prologue	1
	and	$16, 4294967295, $1
	stq	$0, 0($1)
	stq	$2, 8($1)
	stq	$3, 16($1)
	stq	$4, 24($1)
	stq	$5, 32($1)
	stq	$6, 40($1)
	stq	$7, 48($1)
	stq	$8, 56($1)
	stq	$9, 640($1)
	stq	$10, 72($1)
	stq	$11, 80($1)
	stq	$12, 88($1)
	stq	$13, 96($1)
	stq	$14, 104($1)
	stq	$15, 112($1)
	stq	$16, 120($1)
	stq	$17, 128($1)
	stq	$18, 136($1)
	stq	$19, 144($1)
	stq	$20, 152($1)
	stq	$21, 160($1)
	stq	$22, 168($1)
	stq	$23, 176($1)
	stq	$24, 184($1)
	stq	$25, 192($1)
	stq	$26, 200($1)
	stq	$27, 208($1)
 /*	stq	$28, 216($1) */
	stq	$29, 224($1)
	stq	$30, 232($1)
	stq	$sp, 240($1)
	stq	$31, 248($1)

	.livereg	0xFC7F0002,0x3FC00000
	lda	$sp, 32($sp)
	ldil	$0, 17
	ret	$31, ($26), 1
	.end	saveProcContext
#endif
