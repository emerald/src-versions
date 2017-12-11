#!/usr/bin/env gitc-shell.sh

dir=$(dirname $(readlink -f "$0"))
log="${dir}/history.log"

echo -e "CHANGE ME\n\n" > "${log}"
echo -e "AND ME!\n" >> "${log}"
echo -e "\nTo reproduce, run the following commands:\n" \
  >> "${log}"

while read -p "> " line
do
  echo "\$ ${line}" >> "${log}"
  eval "${line}"
done

echo -e "\n" >> "${log}"

git add -A
git commit -F "${log}" -e
