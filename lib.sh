#!/bin/sh

get_minetest(){
  git clone --depth 1 https://github.com/minetest/minetest.git ./minetest
  git clone --depth=1 https://github.com/minetest/minetest_game.git ./minetest/games/minetest_game
  rm -fr ./minetest/games/minetest_game/.git
}

get_mods(){
  for x in \
    https://github.com/D00Med/vehicles.git \
    https://gitlab.com/rubenwardy/awards.git \
    https://github.com/minetest-mods/craftguide.git \
    https://notabug.org/TenPlus1/farming.git \
    https://notabug.org/TenPlus1/mobs_redo.git \
    https://notabug.org/TenPlus1/mobs_animal.git \
    https://notabug.org/TenPlus1/mobs_monster.git \
    https://notabug.org/TenPlus1/mobs_npc.git \
    https://notabug.org/TenPlus1/mob_horse.git \
    https://github.com/minetest-mods/moreblocks.git \
  ;do
    git clone --depth 1 "$x"
    rm -fr "$x"/.git
  done

  for x in \
    https://gitlab.com/VanessaE/homedecor_modpack.git \
    https://github.com/stujones11/minetest-3d_armor.git \
  ;do
    git clone --depth 1 "$x"
    for subdir in "$x"/*;do
      if [ -d "$subdir" ];then
        mv "$subdir" ./
      fi
    done
    rm -fr "$x"
  done
}

install_minetest_osx_builddeps(){
  brew install freetype gettext irrlicht libogg libvorbis luajit
}

install_minetest_debian_builddeps(){
  sudo apt install -y build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev
}

install_minetest_debian_builddeps_nosudo(){
  apt install -y build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev
}

install_minetest_windows_vcpkg_and_builddeps(){
  git clone https://github.com/Microsoft/vcpkg.git ~/vcpkg
  cd ~/vcpkg
  ./bootstrap-vcpkg.bat
  cd -
  ~/vcpkg/vcpkg install irrlicht zlib curl[winssl] openal-soft libvorbis libogg sqlite3 freetype luajit --triplet x64-windows
}

build_minetest_client_windows(){
  cd ./minetest
  cmake . \
    -G"Visual Studio 15 2017 Win64" \
    -DCMAKE_TOOLCHAIN_FILE=~/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_GETTEXT=FALSE \
    -DENABLE_CURSES=FALSE \
    -DBUILD_CLIENT=TRUE \
    -DBUILD_SERVER=FALSE
  cmake --build . --config Release --target PACKAGE
  ls -R
  cd ..
}

build_minetest_client_osx(){
  cd ./minetest
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
    -DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/lib"
  make -j2 package
  cd ..
}

build_minetest_client_gnulinux_amd64(){
  cd ./minetest
  cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CLIENT=TRUE \
    -DBUILD_SERVER=FALSE
  make -j2
  make install DESTDIR=minetest.AppDir
  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
  chmod +x linuxdeploy-x86_64.AppImage
  ./linuxdeploy-x86_64.AppImage --appdir minetest.AppDir
  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x appimagetool-x86_64.AppImage
  ./appimagetool-x86_64.AppImage minetest.AppDir minetest.AppImage
  cd ..
}

build_minetest_server_gnulinux_amd64(){
  cd ./minetest
  cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SERVER=TRUE \
    -DBUILD_CLIENT=FALSE
  make -j2
  make install DESTDIR=minetestserver.AppDir
  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
  chmod +x linuxdeploy-x86_64.AppImage
  sed -i 's/^Exec=minetest$/Exec=minetestserver/' ./minetestserver.AppDir/usr/share/applications/net.minetest.minetest.desktop
  ./linuxdeploy-x86_64.AppImage --appdir minetestserver.AppDir
  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
  chmod +x appimagetool-x86_64.AppImage
  ./appimagetool-x86_64.AppImage minetestserver.AppDir minetestserver.AppImage
  cd ..
}
