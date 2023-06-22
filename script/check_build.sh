#!/usr/bin/env bash

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

name_rom=$(grep init $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d / -f 4)
device=$(grep lunch $CIRRUS_WORKING_DIR/build.sh -m 1 | cut -d ' ' -f 2 | cut -d _ -f 2 | cut -d - -f 1)
a=$(grep 'FAILED:' $WORKDIR/rom/$name_rom/build.log -m1 || true)
if [[ $a == *'FAILED:'* ]]then
cd $WORKDIR/rom/$name_rom
echo ━━━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━━━
msg ⛔ .....Building Failed..... ⛔
echo ━━━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━━━
curl -F document=@build.log "https://api.telegram.org/bot${TG_TOKEN}/sendDocument" \
    -F chat_id="${TG_CHAT_ID}" \
    -F "disable_web_page_preview=true" \
    -F "parse_mode=html" \
    -F caption="⛔${device} Build $name_rom Error⛔
fi

b=$(grep '#### build completed successfully' $WORKDIR/rom/$name_rom/build.log -m1 || true)
if [[ $b == *'#### build completed successfully'* ]]
  then
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ✅ Build is completed 100% ✅
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
else
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  msg ❌ ...Build not completed... ❌
  echo ━━━━━━━━━ஜ۩۞۩ஜ━━━━━━━━
  echo lanjut upload ccache aja 😅
fi
