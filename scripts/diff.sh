#!/bin/sh

set -eu

lhs="$1"
rhs="$2"

prefix=""
if [ $# -gt 2 ]; then
  prefix="$3"
fi

lhsb="${lhs%/*}"
rhsb="${rhs%/*}"

mkdir -p diffs

diff \
  -x Makefile.in \
  -x COPYING \
  -x CVS \
  -x configure \
  -x '*.ps' \
  -x 'vmclex.c' \
  -x 'vmcpar.c' \
  -x 'vmcpar.h' \
  -x 'parse.m' \
  -x 'emx.exe' \
  -x 'emx.ncb' \
  -x 'emx.opt' \
  -x 'emx.dsp' \
  -x 'emx.dsw' \
  -x 'emx.mak' \
  -x 'emx.plg' \
  -I '^\([ /]\*.*\)\?$' \
  --ignore-space-change \
  --ignore-blank-lines \
  -ruN "${lhs}/" "${rhs}/" > "diffs/${prefix}${lhsb}__${rhsb}.patch"
