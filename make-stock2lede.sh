#!/bin/sh

echo "This script will create stock2lede.trx firmware."
echo "Please run this script after building standard firmwares."
read -p "Continue (y/n)?" choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "no"; exit 1;;
  * ) echo "invalid"; exit 1;;
esac
echo "Checking prerequisites...."
if [ -f ./version ]
then
    echo "File ./version already exists. Please check your setup!"
    exit 1
fi
if [ -d ./files ]
then
    echo "Directory ./files already exists. Please check your setup!"
    exit 1
fi
nfiles=$(ls ./bin/targets/ipq806x/generic/*sysupgrade.tar 2>/dev/null| wc -l)
if [ $nfiles = 0 ]; then
    echo "No *sysupgrade.tar file found, exiting!"
    exit 1
fi
if [ $nfiles != 1 ]; then
    echo "More then one *sysupgrade.tar file found, please leave only one. Exiting!"
    exit 1
fi
echo "Creating files..."
echo "stock2lede" > ./version
mkdir -p ./files/etc/rc.d
mkdir -p ./files/etc/init.d
ln -s ../init.d/zupgrade ./files/etc/rc.d/S99zupgrade
cp ./bin/targets/ipq806x/generic/*sysupgrade*.tar ./files/sysupgrade.tar
cat <<EOT >> ./files/etc/init.d/zupgrade
#!/bin/sh /etc/rc.common

START=99
boot() {
cp -f /sysupgrade.tar /tmp/
sleep 5
/usr/sbin/ubirmvol /dev/ubi0 -N jffs2
sleep 5
/sbin/sysupgrade /tmp/sysupgrade.tar
}

EOT
chmod +x ./files/etc/init.d/zupgrade

echo "Building firmware!"
make
echo "Removing files!"
rm -f ./version
rm -rf ./files
echo "If there were no errors, your *stock2lede*.trx firmware is in bin/targets/ipq806x/generic/ folder."
