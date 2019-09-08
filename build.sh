#!/bin/bash

. rom_urls.txt
wget $MIUI_CN_DEV_ZIP || exit 1

unzip $(basename $MIUI_CN_DEV_ZIP) system.new.dat
unzip $(basename $MIUI_CN_DEV_ZIP) system.new.dat.br
unzip $(basename $MIUI_CN_DEV_ZIP) system.transfer.list || exit 1
rm $(basename $MIUI_CN_DEV_ZIP)

[ -f system.new.dat -o -f system.new.dat.br ] || exit 1
[ -f system.new.dat.br ] && {
  brotli -djv system.new.dat.br || exit 1
}

python3 sdat2img.py system.transfer.list system.new.dat || exit 1
rm system.transfer.list system.new.dat
7z x -omagisk/system system.img lib64/libentryexpro.so lib64/libuptsmaddonmi.so app/Mipay app/NextPay app/TSMClient app/UPTsmService || exit 1
rm system.img

pushd magisk
pushd system/app/NextPay/lib/arm64
rm libentryexpro.so
rm libuptsmaddonmi.so
ln -s /system/lib64/libentryexpro.so
ln -s /system/lib64/libuptsmaddonmi.so
popd

pushd system/app/TSMClient/lib/arm64
rm libentryexpro.so
rm libuptsmaddonmi.so
ln -s /system/lib64/libentryexpro.so
ln -s /system/lib64/libuptsmaddonmi.so
popd

find -exec touch -d @0 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -y -9 ../Mi6-MIPay-Systemless-$version.zip . || exit 1
popd
