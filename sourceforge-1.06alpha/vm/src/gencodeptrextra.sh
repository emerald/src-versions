#!/bin/sh
#errornumber=`./emx |egrep old_start\|new_start |sed s/"^.*old_start = "//|sed s/"^.*new_start = "//`

echo \#undef CODEPTREXTRA > codeptrextra.h;
echo \#define CODEPTREXTRA `./codeptrextra` >> codeptrextra.h;
