#!/usr/bin/env bash

set -exv
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
mkdir -p $WORKDIR/rom/$name_rom
cd $WORKDIR/rom/$name_rom
command=$(head $CIRRUS_WORKING_DIR/build.sh -n $(expr $(grep '# build rom' $CIRRUS_WORKING_DIR/build.sh -n | cut -f1 -d:) - 1))
only_sync=$(grep 'repo sync' $CIRRUS_WORKING_DIR/build.sh)
bash -c "$command" || true
curl -sO https://api.cirrus-ci.com/v1/task/$CIRRUS_TASK_ID/logs/Sync-rom.log
a=$(grep 'Cannot remove project' Sync-rom.log -m1|| true)
b=$(grep "^fatal: remove-project element specifies non-existent project" Sync-rom.log -m1 || true)
c=$(grep 'repo sync has finished' Sync-rom.log -m1 || true)
d=$(grep 'Failing repos:' Sync-rom.log -n -m1 || true)
e=$(grep 'fatal: Unable' Sync-rom.log || true)
f=$(grep 'error.GitError' Sync-rom.log || true)
g=$(grep 'error: Cannot checkout' Sync-rom.log || true)
if [[ $a == *'Cannot remove project'* ]]
then
a=$(echo $a | cut -d ':' -f2 | tr -d ' ')
rm -rf $a
fi
if [[ $b == *'remove-project element specifies non-existent'* ]]
then exit 1
fi
if [[ $d == *'Failing repos:'* ]]
then
d=$(expr $(grep 'Failing repos:' Sync-rom.log -n -m 1| cut -d ':' -f1) + 1)
d2=$(expr $(grep 'Try re-running' Sync-rom.log -n -m1 | cut -d ':' -f1) - 1 )
fail_paths=$(head -n $d2 Sync-rom.log | tail -n +$d)
for path in $fail_paths
do
rm -rf $path
aa=$(echo $path|awk -F '/' '{print $NF}')
rm -rf .repo/project-objects/*$aa.git
rm -rf .repo/projects/$path.git
done
fi
if [[ $e == *'fatal: Unable'* ]]
then
fail_paths=$(grep 'fatal: Unable' Sync-rom.log | cut -d ':' -f2 | cut -d "'" -f2)
for path in $fail_paths
do
rm -rf $path
aa=$(echo $path|awk -F '/' '{print $NF}')
rm -rf .repo/project-objects/*$aa.git
rm -rf .repo/project-objects/$path.git
rm -rf .repo/projects/$path.git
done
fi
if [[ $f == *'error.GitError'* ]]
then
rm -rf $(grep 'error.GitError' Sync-rom.log | cut -d ' ' -f2)
fi
if [[ $g == *'error: Cannot checkout'* ]]
then
coerr=$(grep 'error: Cannot checkout' Sync-rom.log | cut -d ' ' -f 4| tr -d ':')
for i in $coerr
do
rm -rf .repo/project-objects/$i.git
done
fi
#- (repo forall -c 'git checkout .' && bash -c "$only_sync") || (find -name shallow.lock -delete && find -name index.lock -delete && bash -c "$only_sync")
if [[ $c == *'repo sync has finished'* ]]
then true
else
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
fi
rm -rf Sync-rom.log
