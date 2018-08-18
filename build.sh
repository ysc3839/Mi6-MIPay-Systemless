#!/bin/bash

. rom_urls.txt

wget $MIUI_CN_DEV_ZIP
unzip $(basename $MIUI_CN_DEV_ZIP) system.transfer.list system.new.dat
#rm $(basename $MIUI_CN_DEV_ZIP)
python3 sdat2img.py system.transfer.list system.new.dat
rm system.transfer.list system.new.dat
7z x -osystem system.img lib64/libuptsmaddonmi.so app/Mipay app/NextPay app/TSMClient app/UPTsmService
rm system.img

pushd system/app/TSMClient/lib/arm64
rm libuptsmaddonmi.so
ln -s /system/lib64/libuptsmaddonmi.so
popd

find -exec touch -d @1230739200 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -x *.git* build.sh *.txt *.py *.zip -y -9 Mi6-MIPay-Systemless-$version.zip .
