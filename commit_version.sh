#!/bin/bash
set -e # enable stop on error

MIX_FILE=mix.exs
CHANGELOG_FILE=Changelog

touch ${CHANGELOG_FILE}
DATE=$(date +"%F %H:%M")
gsed -i "1s/^/${1} - ${DATE}\n\t\n\n/" ${CHANGELOG_FILE}
vim ${CHANGELOG_FILE} +2 +startinsert  < `tty` > `tty`
gsed -i "s/@version .*/@version \"$1\"/g" ${MIX_FILE}
git reset
git add ${MIX_FILE}
git add ${CHANGELOG_FILE}
git commit -m "Release $1"
git tag -f "$1"
git show --color
set +e # disable stop on error (default behaviour)
