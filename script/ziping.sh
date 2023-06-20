#!/usr/bin/env bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

telegram_message() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
    -d chat_id="$TG_CHAT_ID" \
    -d parse_mode="HTML" \
    -d text="$1"
}

function enviroment() {
device=$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
file_name=$(cd $WORKDIR/rom/$name_rom/out/target/product/$device && ls *.zip)
branch_name=$(grep init $CIRRUS_WORKING_DIR/build.sh | awk -F "-b " '{print $2}' | awk '{print $1}')
rel_date=$(date "+%Y%m%d")
DATE_L=$(date +%d\ %B\ %Y)
DATE_S=$(date +"%T")
}

function upload_rom() {
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload rom..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
cd $WORKDIR/rom/$name_rom
engzip=$(ls out/target/product/$device/*-eng*.zip | grep -v "retrofit" || true)
otazip=$(ls out/target/product/$device/*-ota-*.zip | grep -v "hentai" | grep -v "evolution" || true)
awaken=$(ls out/target/product/$device/Project-Awaken*.zip || true)
octavi=$(ls out/target/product/$device/OctaviOS-R*.zip || true)
p404=$(ls out/target/product/$device/?.*zip || true)
cipher=$(ls out/target/product/$device/CipherOS-*-OTA-*.zip || true)
rm -rf $engzip $otazip $awaken $octavi $p404 $cipher
file_name=$(basename out/target/product/$device/*.zip)
DL_LINK=https://royal-snowflake.regenerate.workers.dev/0:/$name_rom/$device/$file_name
rclone copy out/target/product/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)/*.zip build:$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)/$(grep unch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1) -P
cd $WORKDIR/rom/$name_rom/out/target/product/$device
echo -e \
"
<b>✅ Build Completed Successfully ✅</b>

━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
<b>🚀 Rom Name :- ${name_rom}</b>
<b>📁 File Name :-</b> <code>"${file_name}"</code>
<b>⏰ Timer Build :- "$(grep "#### build completed successfully" $WORKDIR/rom/$name_rom/build.log -m 1 | cut -d '(' -f 2)"</b>
<b>📱 Device :- "${device}"</b>
<b>📂 Size :- "$(ls -lh *zip | cut -d ' ' -f5)"</b>
<b>🖥 Branch Build :- "${branch_name}"</b>
<b>📥 Download Link :-</b> <a href=\"${DL_LINK}\">Here</a>
<b>📅 Date :- "$(date +%d\ %B\ %Y)"</b>
<b>🕔 Time Zone :- "$(date +%T)"</b>
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
<b>📕 MD5 :-</b> <code>"$(md5sum *zip | cut -d' ' -f1)"</code>
<b>📘 SHA1 :-</b> <code>"$(sha1sum *zip | cut -d' ' -f1)"</code>
━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
<b>🙇 Maintainer: "$CIRRUS_REPO_OWNER"</b>
" > tg.html
TG_TEXT=$(< tg.html)
telegram_message "$TG_TEXT"
echo
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload rom succes..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
echo
echo Download Link: ${DL_LINK}
echo
echo
}

function upload_ccache() {
cd $WORKDIR
com ()
{
  tar --use-compress-program="pigz -k -$2 " -cf $1.tar.gz $1
}
time com ccache 1
rclone copy --drive-chunk-size 256M --stats 1s ccache.tar.gz build:ccache/$name_rom/$device -P
rm -rf ccache.tar.gz
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
msg Upload ccache succes..
echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
}

function upload() {
enviroment
a=$(grep '#### build completed successfully' $WORKDIR/rom/$name_rom/build.log -m1 || true)
if [[ $a == *'#### build completed successfully'* ]]
  then
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ✅ Build completed 100% success ✅
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  echo
  echo
  upload_rom
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg Upload ccache..
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  upload_ccache
else
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ❌ Build not completed, Upload ccache only ❌
  msg Upload ccache..
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  upload_ccache
fi
}

upload
