RETRY(){
  "$@" || "$@" || "$@" || "$@" || "$@" || "$@" || "$@" || "$@"
}
COMMENT(){
  :
}
get_minetest(){
  (RETRY git clone --depth=1 https://github.com/minetest/minetest.git ./minetest &&
  RETRY git clone --depth=1 https://github.com/minetest/minetest_game.git ./minetest/games/minetest_game &&
  rm -fr ./minetest/games/minetest_game/.git)
}
mods_mod(){
  echo \
    https://github.com/D00Med/vehicles.git \
    https://github.com/Gerold55/minetest-laptop.git \
    https://github.com/Uberi/Minetest-WorldEdit.git \
    https://github.com/minetest-mods/areas.git \
    https://github.com/minetest-mods/moreblocks.git \
    https://github.com/minetest-mods/nether.git \
    https://github.com/minetest-mods/quartz.git \
    https://github.com/minetest-mods/skinsdb.git \
    https://github.com/minetest-mods/stamina.git \
    https://github.com/minetest-mods/xban2.git \
    https://github.com/minetest-mods/xdecor.git \
    https://github.com/paramat/snowdrift.git \
    https://gitlab.com/rubenwardy/awards.git \
    https://gitlab.com/VanessaE/basic_materials.git \
    https://gitlab.com/VanessaE/biome_lib.git \
    https://gitlab.com/VanessaE/moretrees.git \
    https://gitlab.com/VanessaE/pipeworks.git \
    https://gitlab.com/VanessaE/signs_lib.git \
    https://gitlab.com/VanessaE/unifieddyes.git \
    https://notabug.org/TenPlus1/farming.git \
    https://notabug.org/TenPlus1/mob_horse.git \
    https://notabug.org/TenPlus1/mobs_animal.git \
    https://notabug.org/TenPlus1/mobs_monster.git \
    https://notabug.org/TenPlus1/mobs_npc.git \
    https://notabug.org/TenPlus1/mobs_redo.git \

}
mods_modpack(){
  echo \
    $(COMMENT http://git.bananach.space/advtrains.git "has some bug") \
    https://github.com/minetest-mods/mesecons.git \
    https://github.com/stujones11/minetest-3d_armor.git \
    https://gitlab.com/VanessaE/plantlife_modpack.git \

}
# wmt_cfg = WORLD-MT-CONFIG
get_mods__and__gen_wmt_cfg(){
  for x in $(mods_mod);do
    local x_base="${x##*/}"
    local x_name="${x_base%.git}"
    RETRY git clone "$x" || return 1
    rm -fr "$x_name"/.git
  done

  for x in $(mods_modpack);do
    rm -fr MODPACK-TMP
    RETRY git clone "$x" MODPACK-TMP || return 1
    for subdir in MODPACK-TMP/*;do
      if [ -f "$subdir/mod.conf" ] || [ -f "$subdir/init.lua" ];then
        mv "$subdir" ./
      fi
    done
    rm -fr MODPACK-TMP
  done

  > WORLD-MT-CONFIG
  for x in *;do
    if [ -f "$x/mod.conf" ];then
      local name=$(grep '^name[ \t]*=' "$x/mod.conf" | head -1 | sed 's/^.*=[ \t]*\([^ \t]*\)[ \t]*$/\1/')
      echo "load_mod_${name} = true" >> WORLD-MT-CONFIG
      if [ "$x" != "$name" ];then
        mv "$x" "$name"
      fi
    elif [ -f "$x/init.lua" ];then
      echo "load_mod_${x} = true" >> WORLD-MT-CONFIG
    elif [ "$x" = WORLD-MT-CONFIG ];then
      :
    else
      rm -fr "$x"
    fi
  done
}
minetest_osx_builddeps(){
  echo freetype gettext irrlicht libogg libvorbis luajit
}
install_minetest_osx_builddeps(){
  brew uninstall $(minetest_osx_builddeps) # in case already installed
  RETRY brew install $(minetest_osx_builddeps)
}
install_osx_coreutils_and_set_PATH(){
  brew uninstall coreutils # in case already installed
  RETRY brew install coreutils &&
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
}
minetest_debian_builddeps(){
  echo file wget git build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev
}
install_minetest_debian_builddeps(){
  RETRY sudo apt-get install -y $(minetest_debian_builddeps)
}
install_minetest_debian_builddeps_nosudo(){
  RETRY apt-get install -y $(minetest_debian_builddeps)
}
minetest_archlinux_builddeps(){
  echo wget git base-devel libcurl-gnutls cmake libxxf86vm irrlicht libpng sqlite libogg libvorbis openal freetype2 jsoncpp gmp luajit leveldb ncurses
}
install_minetest_archlinux_builddeps_nosudo(){
  RETRY pacman -Syu --noconfirm $(minetest_archlinux_builddeps)
}
install_minetest_centos7_builddeps_nosudo(){
  RETRY yum install -y centos-release-scl-rh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm &&
  RETRY yum install -y git file wget devtoolset-8-make automake devtoolset-8-gcc devtoolset-8-gcc-c++ kernel-devel llvm-toolset-7-cmake libcurl-devel openal-soft-devel libvorbis-devel libXxf86vm-devel libogg-devel freetype-devel mesa-libGL-devel zlib-devel jsoncpp-devel irrlicht-devel bzip2-libs gmp-devel sqlite-devel luajit-devel leveldb-devel ncurses-devel doxygen spatialindex-devel bzip2-devel &&
  ln -s /opt/rh/devtoolset-8/root/usr/bin/* /opt/rh/llvm-toolset-7/root/usr/bin/* /usr/local/bin
}
install_linuxdeploy_deps_alpine_nosudo(){
  rm -fr /etc/apk/keys/sgerrand.rsa.pub /tmp/glibc.apk
  RETRY wget -c -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub &&
  RETRY wget -c -q -O /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk &&
  apk add /tmp/glibc.apk zlib &&
  rm /tmp/glibc.apk
}
install_minetest_alpine_builddeps_nosudo(){
  RETRY apk add wget git build-base irrlicht-dev cmake bzip2-dev libpng-dev jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev gmp-dev jsoncpp-dev luajit-dev
}
install_appimage_tools_alpine_builddeps_nosudo(){
  RETRY apk add bash wget git build-base gnupg zip subversion automake libtool patch zlib-dev cairo-dev openssl-dev cmake autoconf automake fuse-dev vim desktop-file-utils gtest-dev libxft-dev librsvg-dev curl ncurses-dev texinfo gdb xz libffi-dev gettext-dev argp-standalone &&
  RETRY sh -c 'wget http://zsync.moria.org.uk/download/zsync-0.6.2.tar.bz2 -O - | tar -xvj' &&
  (cd zsync-0.6.2 &&
    ./configure &&
    sed '1 i #include <sys/types.h>' -i ./libzsync/sha1.h &&
    make -j4 &&
    make install &&
    cd .. &&
    rm -fr zsync-0.6.2)
}
# reference: https://github.com/minetest/minetest/blob/4b6bff46e14c6215828da5ca9ad2cb79aa517a6e/.gitlab-ci.yml
CONFIG_WIN_ARCH=x86_64
install_minetest_mingw_builddeps__and__build__ubuntu1604(){
  local WIN_ARCH
  local WIN_BITS
  if [ "$CONFIG_WIN_ARCH" = x86_64 ];then
    WIN_ARCH=x86_64
    WIN_BITS=64
  else
    WIN_ARCH=i686
    WIN_BITS=32
  fi
  (get_minetest &&
  RETRY sudo apt-get install -y p7zip-full wget unzip git cmake gettext &&
  RETRY wget --continue "http://minetest.kitsunemimi.pw/mingw-w64-${WIN_ARCH}_7.1.1_ubuntu14.04.7z" -O mingw.7z &&
  sed -e "s|%PREFIX%|${WIN_ARCH}-w64-mingw32|" -e "s|%ROOTPATH%|/usr/${WIN_ARCH}-w64-mingw32|" < ./minetest/util/travis/toolchain_mingw.cmake.in > ./minetest/util/buildbot/toolchain_mingw.cmake &&
  sudo 7z x -y -o/usr mingw.7z &&
  EXISTING_MINETEST_DIR="$PWD/minetest/" NO_MINETEST_GAME=1 "./minetest/util/buildbot/buildwin${WIN_BITS}.sh" build &&
  unzip ./minetest/_build/minetest-*-win*.zip -d . &&
  mv minetest-*-win* minetest-win &&
  cp /usr/"${WIN_ARCH}"-w64-mingw32/bin/libgcc*.dll \
    /usr/"${WIN_ARCH}"-w64-mingw32/bin/libstdc++*.dll \
    /usr/"${WIN_ARCH}"-w64-mingw32/bin/libwinpthread*.dll minetest-win/bin &&
  cd minetest-win &&
  7z a ../minetest/minetest.zip .)
}
build_minetest_client_osx(){
  (cd ./minetest &&
  cmake . \
    -DVERSION_EXTRA="dev-$(sw_vers -productVersion)" \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_FREETYPE=TRUE \
    -DENABLE_LEVELDB=FALSE \
    -DENABLE_GETTEXT=TRUE \
    -DENABLE_REDIS=FALSE \
    -DBUILD_CLIENT=TRUE \
    -DBUILD_SERVER=FALSE \
    -DCUSTOM_GETTEXT_PATH=/usr/local/opt/gettext \
    -DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/lib" &&
  make -j4 package)
}
CONFIG_APPIMAGE_TOOLS_ARCH=x86_64
get_appimage_tools_noretry(){
  local LINUXDEP_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  local APPIMATOOL_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  [ "$LINUXDEP_ARCH" = i686 ] && LINUXDEP_ARCH=i386
  [ "$APPIMATOOL_ARCH" = i386 ] && APPIMATOOL_ARCH=i686
  rm -fr linuxdeploy.AppImage appimagetool.AppImage

  wget -O linuxdeploy.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-"$LINUXDEP_ARCH".AppImage &&
  wget -O appimagetool.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-"$APPIMATOOL_ARCH".AppImage &&
  chmod +x linuxdeploy.AppImage &&
  chmod +x appimagetool.AppImage
}
get_build_appimage_tools_alpine(){
  local LINUXDEP_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  local APPIMATOOL_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  [ "$LINUXDEP_ARCH" = i686 ] && LINUXDEP_ARCH=i386
  [ "$APPIMATOOL_ARCH" = i386 ] && APPIMATOOL_ARCH=i686
  rm -fr linuxdeploy.AppImage appimagetool.AppImage

  wget -O linuxdeploy.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-"$LINUXDEP_ARCH".AppImage &&
  chmod +x linuxdeploy.AppImage &&
  git clone --single-branch --recursive https://github.com/AppImage/AppImageKit.git &&
  (cd AppImageKit &&
    find -name '*.h' | xargs sed -i 's/__END_DECLS//g' && # workaround about https://github.com/AppImage/AppImageKit/pull/1019
    find -name '*.h' | xargs sed -i 's/__BEGIN_DECLS//g' &&
    bash -ex build.sh &&
    cd build/out &&
    ./appimagetool.AppDir/AppRun ./appimagetool.AppDir/ -v \
      ../../../appimagetool.AppImage) &&
  rm -fr AppImageKit
}
get_appimage_tools(){
  RETRY get_appimage_tools_noretry
}
build_minetest_client_gnulinux(){
  (cd ./minetest &&
  cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CLIENT=TRUE \
    -DBUILD_SERVER=FALSE &&
  make -j4)
}
bundle_minetest_client_gnulinux_appimage(){
  (cd ./minetest &&
  make install DESTDIR=minetest.AppDir &&
  ../linuxdeploy.AppImage --appdir minetest.AppDir &&
  ../appimagetool.AppImage minetest.AppDir minetest.AppImage)
}
build_minetest_server_gnulinux(){
  (cd ./minetest &&
  cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SERVER=TRUE \
    -DBUILD_CLIENT=FALSE &&
  make -j4)
}
bundle_minetest_server_gnulinux_appimage(){
  (cd ./minetest &&
  make install DESTDIR=minetestserver.AppDir &&
  rm ./minetestserver.AppDir/usr/share/applications/* &&
  echo '[Desktop Entry]
Name=MinetestServer
Icon=minetest
Type=Application
Categories=Game;Simulation;
Exec=minetestserver' > ./minetestserver.AppDir/usr/share/applications/minetestserver.desktop &&
  get_appimage_tools &&
  ../linuxdeploy.AppImage --appdir minetestserver.AppDir &&
  ../appimagetool.AppImage minetestserver.AppDir minetestserver.AppImage)
}
job_mods(){
  (mkdir mods &&
  cd mods &&
  get_mods__and__gen_wmt_cfg &&
  mv WORLD-MT-CONFIG .. &&
  zip -r ../mods.zip . &&
  tar -czvf ../mods.tgz . &&
  cd .. &&
  rm -fr mods)
}
