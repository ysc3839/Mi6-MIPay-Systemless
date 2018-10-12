#!/bin/bash

. rom_urls.txt

wget $MIUI_CN_DEV_ZIP || exit 1
unzip $(basename $MIUI_CN_DEV_ZIP) system.transfer.list system.new.dat || exit 1
rm $(basename $MIUI_CN_DEV_ZIP)
python3 sdat2img.py system.transfer.list system.new.dat || exit 1
rm system.transfer.list system.new.dat
7z x -osystem system.img lib64/libentryexpro.so lib64/libuptsmaddonmi.so app/Mipay app/NextPay app/TSMClient app/UPTsmService || exit 1
rm system.img

pushd system/app/TSMClient/lib/arm64
rm libentryexpro.so
rm libuptsmaddonmi.so
ln -s /system/lib64/libentryexpro.so
ln -s /system/lib64/libuptsmaddonmi.so
popd

find -exec touch -d @1230739200 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -x *.git* build.sh *.txt *.py *.zip *.yml -y -9 Mi6-MIPay-Systemless-$version.zip . || exit 1
