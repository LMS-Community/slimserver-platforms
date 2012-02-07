error() {
  echo "ERROR!"
  exit 1;
}

name="LogitechMediaServer"
vers=$(awk -F'!!' '{ print $3 }' $name/addons.conf)
time=$(date +%s)

cd $name/files || error 
tar cfz ../files.tgz ./* || error
cd ..
tar cf ${name}_${vers}.tar install.sh remove.sh addons.conf files.tgz || error

size=`stat -t ${name}_${vers}.tar | awk '{ print $2 }'`
md5=`md5sum ${name}_${vers}.tar | awk '{ print $1 }'`
echo "addon::name=${name},version=${vers},time=${time},size=${size},md5sum=${md5},arch=x86,unencrypted=1,skipreboot=1" | dd bs=16384 conv=sync >index 2>/dev/null || error
cat index ${name}_${vers}.tar >../${name}_${vers}.bin || error
rm -f index ${name}_${vers}.tar files.tgz
echo "Successfully built addon \"$name\" addon package as \"${name}_${vers}.bin\"."
