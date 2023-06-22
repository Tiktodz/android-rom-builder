#!/usr/bin/env bash

set -e
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(grep lunch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
command=$(tail $CIRRUS_WORKING_DIR/build.sh -n +$(expr $(grep '# build rom' $CIRRUS_WORKING_DIR/build.sh -n | cut -f1 -d:) - 1)| head -n -1 | grep -v '# end')
cd $WORKDIR/rom/$name_rom
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR=$WORKDIR/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
export CCACHE_COMPRESS=true
which ccache
ccache -M 100G -F 0
ccache -z
bash -c "$command" || true
bash $CIRRUS_WORKING_DIR/script/check_build.sh
