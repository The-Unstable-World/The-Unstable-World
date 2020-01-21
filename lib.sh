echo "
    The-Unstable-World build script
    Copyright (C) 2019  ㄗㄠˋ ㄑㄧˊ

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
"
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
apply_cheat_patch(){
  # These clients are used to test anti-cheating mods

  sed -i 's|{ return checkPrivilege(priv); }|{ return true; }|' ./minetest/src/client/client.h # checkLocalPrivilege
  #sed -i 's|{ return (m_privileges.count(priv) != 0); }|{ return true; }|' ./minetest/src/client/client.h # checkPrivilege

  sed -i 's|void Client::sendDamage(u16 damage)|void Client::realSendDamage(u16 damage)|' ./minetest/src/client/client.cpp
  sed -i 's|void sendDamage(u16 damage);|void sendDamage(u16 damage) { };void realSendDamage(u16 damage);|' ./minetest/src/client/client.h

  #sed -i 's|getfloatfield(L, table, "full_punch_interval", toolcap.full_punch_interval);|toolcap.full_punch_interval = 0.5;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|getintfield(L, table, "max_drop_level", toolcap.max_drop_level);|toolcap.max_drop_level = 3;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|getintfield(L, table_groupcap, "uses", groupcap.uses);|groupcap.uses = 0;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|getintfield(L, table_groupcap, "maxlevel", groupcap.maxlevel);|groupcap.maxlevel = 256;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|groupcap.times\[rating\] = time;|groupcap.times[rating] = 42;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|def.range = getfloatfield_default(L, index, "range", def.range);|def.range = 256.0;|' ./minetest/src/script/common/c_content.cpp
  #sed -i 's|toolcap.damageGroups\[groupname\] = value;|toolcap.damageGroups["fleshy"] = 10;|' ./minetest/src/script/common/c_content.cpp

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
    https://github.com/minetest-mods/technic.git \
    https://github.com/stujones11/minetest-3d_armor.git \
    https://gitlab.com/VanessaE/plantlife_modpack.git \

}
CONFIG_MODS="$(mods_mod)"
CONFIG_MODPACKS="$(mods_modpack)"
# wmt_cfg = WORLD-MT-CONFIG
get_mods__and__gen_wmt_cfg(){
  for x in $CONFIG_MODS;do
    local x_base="${x##*/}"
    local x_name="${x_base%.git}"
    RETRY git clone "$x" || return 1
    rm -fr "$x_name"/.git
  done

  for x in $CONFIG_MODPACKS;do
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
  RETRY brew reinstall $(minetest_osx_builddeps)
}
install_osx_coreutils_and_set_PATH(){
  RETRY brew reinstall coreutils findutils gnu-sed &&
  export PATH="/usr/local/opt/findutils/libexec/gnubin:/usr/local/opt/gnu-sed/libexec/gnubin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
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
install_minetest_alpine_builddeps_nosudo(){
  RETRY apk add wget git build-base irrlicht-dev cmake bzip2-dev libpng-dev jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev gmp-dev jsoncpp-dev luajit-dev
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
get_appimage_and_linuxdeploy(){
  local LINUXDEP_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  local APPIMATOOL_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  [ "$LINUXDEP_ARCH" = i686 ] && LINUXDEP_ARCH=i386
  [ "$APPIMATOOL_ARCH" = i386 ] && APPIMATOOL_ARCH=i686
  rm -fr linuxdeploy.AppImage appimagetool.AppImage

  RETRY wget --continue -O linuxdeploy.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-"$LINUXDEP_ARCH".AppImage &&
  RETRY wget --continue -O appimagetool.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-"$APPIMATOOL_ARCH".AppImage &&
  chmod +x linuxdeploy.AppImage &&
  chmod +x appimagetool.AppImage
}
build_linuxdeploy_bundle_all_amd64_or_i386_docker_nosudo(){
  local LINUXDEP_ARCH="$CONFIG_APPIMAGE_TOOLS_ARCH"
  [ "$LINUXDEP_ARCH" = i686 ] && LINUXDEP_ARCH=i386
  RETRY git clone --single-branch --recursive https://github.com/linuxdeploy/linuxdeploy.git || exit 1
  echo '#!/bin/bash' > linuxdeploy/src/core/generate-excludelist.sh
cat << 'EOF' > linuxdeploy/src/core/excludelist.h
#include <string>
#include <vector>

static const std::vector<std::string> generatedExcludelist = {};
EOF
  rm -fr linuxdeploy.AppImage &&
  (cd linuxdeploy &&
    ./travis/build-centos6-docker.sh &&
    mv linuxdeploy-*.AppImage ../linuxdeploy.AppImage
    ) &&
  rm -fr linuxdeploy
}
install_linuxdeploy_alpine_deps_nosudo(){
  RETRY wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub &&
  RETRY wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk &&
  RETRY apk add glibc-2.30-r0.apk
}
build_appimage_install_builddeps_alpine_nosudo(){
  RETRY apk add bash wget git build-base gnupg zip subversion automake libtool patch zlib-dev cairo-dev openssl-dev cmake autoconf automake fuse-dev vim desktop-file-utils gtest-dev libxft-dev librsvg-dev curl ncurses-dev texinfo gdb xz libffi-dev gettext-dev argp-standalone &&
  RETRY sh -c 'wget http://zsync.moria.org.uk/download/zsync-0.6.2.tar.bz2 -O - | tar -xvj' &&
  (cd zsync-0.6.2 &&
    ./configure &&
    sed '1 i #include <sys/types.h>' -i ./libzsync/sha1.h &&
    make -j4 &&
    make install &&
    cd .. &&
    rm -fr zsync-0.6.2) &&
  git clone --single-branch --recursive https://github.com/AppImage/AppImageKit.git &&
  rm -fr appimagetool.AppImage &&
  (cd AppImageKit &&
    find -name '*.h' | xargs sed -i 's/__END_DECLS//g' && # workaround about https://github.com/AppImage/AppImageKit/pull/1019
    find -name '*.h' | xargs sed -i 's/__BEGIN_DECLS//g' &&
    bash -ex build.sh &&
    cd build/out &&
    ./appimagetool.AppDir/AppRun ./appimagetool.AppDir/ -v \
      ../../../appimagetool.AppImage) &&
  rm -fr AppImageKit
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
bundle_minetest_client_gnulinux_appdir_nolibs(){
  (cd ./minetest &&
  make install DESTDIR=minetest.AppDir)
}
bundle_minetest_client_gnulinux_appimage(){
  bundle_minetest_client_gnulinux_appdir_nolibs &&
  (cd ./minetest &&
  ../linuxdeploy.AppImage --appdir minetest.AppDir &&
  ../appimagetool.AppImage minetest.AppDir minetest.AppImage)
}
CONFIG_ALPINE_ROOTFS_ARCH=x86_64
build_alpine_rootfs(){
  local r="$1"
  local tmp="$(mktemp -d)"
  shift
  (wget -O - http://dl-cdn.alpinelinux.org/alpine/v3.11/releases/"$CONFIG_ALPINE_ROOTFS_ARCH"/alpine-minirootfs-3.11.2-x86_64.tar.gz | tar -xzC "$tmp") || return 1
  local builtinfiles="$(find "$tmp" -type f)"
  RETRY apk add --no-cache --root "$tmp" "$@" || return 1
  rm -fr $builtinfiles
  cp -r "$tmp"/* "$r"/
  rm -fr "$tmp"
  true
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
bundle_minetest_server_gnulinux_appdir_nolibs(){
  (cd ./minetest &&
  make install DESTDIR=minetestserver.AppDir &&
  rm ./minetestserver.AppDir/usr/share/applications/* &&
  echo '[Desktop Entry]
Name=MinetestServer
Icon=minetest
Type=Application
Categories=Game;Simulation;
Exec=minetestserver' > ./minetestserver.AppDir/usr/share/applications/minetestserver.desktop)
}
bundle_minetest_server_gnulinux_appimage(){
  bundle_minetest_server_gnulinux_appdir_nolibs &&
  (cd ./minetest &&
  ../linuxdeploy.AppImage --appdir minetestserver.AppDir &&
  ../appimagetool.AppImage minetestserver.AppDir minetestserver.AppImage)
}
job_mods(){
  CONFIG_MODS="$(mods_mod)"
  CONFIG_MODPACKS="$(mods_modpack)"
  (mkdir mods &&
  cd mods &&
  get_mods__and__gen_wmt_cfg &&
  mv WORLD-MT-CONFIG .. &&
  zip -r ../mods.zip . &&
  tar -czvf ../mods.tgz . &&
  cd .. &&
  rm -fr mods)
}
make_capturetheflag(){
  CONFIG_MODS="https://github.com/D00Med/vehicles.git https://github.com/minetest-mods/item_drop.git"
  CONFIG_MODPACKS=""
  (mkdir capturetheflag &&
  cd capturetheflag &&
  git clone --depth 1 https://github.com/minetest/minetest_game.git MTG &&
  git clone --recursive https://github.com/MT-CTF/capturetheflag.git CTF &&
  rm -fr MTG/mods/give_initial_stuff CTF/mods/mtg &&
  mv MTG/mods CTF/menu CTF/game.conf CTF/minetest.conf CTF/README.md ./ &&
  mv CTF/mods/* ./mods/ &&
    (mkdir mods/custom &&
    cd mods/custom &&
    get_mods__and__gen_wmt_cfg &&
    rm WORLD-MT-CONFIG &&
    echo 'name = custom' > modpack.conf) &&
  rm -fr MTG CTF) || return 1
cat << 'EOF' >> ./capturetheflag/mods/ctf/ctf_treasure/init.lua || return 1
do
local default_treasures = ctf_treasure.get_default_treasures()
for _, v in ipairs{
 { "default:cobble",              0.6, 5, { 78, 99 } },
 { "default:wood",                0.6, 5, { 45, 99 } },
 { "default:sword_steel",         0.6, 5, { 1, 10 } },
 { "default:shovel_steel",        0.6, 5, { 1, 10 } },
 { "default:shovel_steel",        0.6, 5, { 1, 10 } },
 { "shooter:shotgun",             0.3, 2, 1 },
 { "shooter:grenade",             0.3, 2, 1 },
 { "shooter:machine_gun",         0.3, 2, 1 },
 { "vehicles:missile_2_item",     0.3, 2, { 3, 32 } },
 { "vehicles:rc",                 0.3, 2, 1 },
 { "vehicles:apache_spawner",     0.2, 2, 1 },
 { "vehicles:plane_spawner",      0.2, 2, 1 },
 { "vehicles:backpack",           0.3, 2, 1 }
} do table.insert(default_treasures, v) end
function ctf_treasure.get_default_treasures() return default_treasures end
end
EOF
cat << 'EOF' >> ./capturetheflag/mods/other/random_messages/init.lua || return 1
do local function patch_delete_messages()
  for _, to_del in ipairs{
    "Like CTF? Give feedback using /report, and consider donating at rubenwardy.com/donate",
    "Want to submit your own map? Visit ctf.rubenwardy.com to get involved.",
    "To report misbehaving players to moderators, please use /report <name> <action>"
  } do for k, x in ipairs(random_messages.messages) do
  if to_del == x then table.remove(random_messages.messages, k) return patch_delete_messages() end
end end end patch_delete_messages() end
for _, v in ipairs{
  "Like CTF? Give feedback at https://github.com/The-Unstable-World/The-Unstable-World/issues, and consider donating",
  "Want to submit your own map? Visit ctf.rubenwardy.com (Upstream, Not this server's website) to get involved.",
  "To report misbehaving players to moderators, please use https://github.com/The-Unstable-World/The-Unstable-World/issues",

  "You need Rc to launch and control missiles",
  "Do not let vehicles enter the water"
} do table.insert(random_messages.messages, v) end
EOF

cat << 'EOF' > ./capturetheflag/mods/custom/vehicles/init.lua.new || return 1
local old_get_objects_inside_radius = minetest.get_objects_inside_radius
local function patched_get_objects_inside_radius(...) -- Fixed an issue where players could kill themselves with missiles
	local return_v = {}
	for _, obj in ipairs(old_get_objects_inside_radius(...)) do
		if not (obj:get_luaentity() ~= nil and obj:get_luaentity().name == "ctf_playertag:tag") then
			return_v[#return_v+1]=obj
		end
	end
	return return_v
end
EOF
sed 's|minetest.get_objects_inside_radius|patched_get_objects_inside_radius|' ./capturetheflag/mods/custom/vehicles/init.lua >> ./capturetheflag/mods/custom/vehicles/init.lua.new || return 1
mv ./capturetheflag/mods/custom/vehicles/init.lua.new ./capturetheflag/mods/custom/vehicles/init.lua || return 1
cat << 'EOF' >> ./capturetheflag/mods/custom/vehicles/init.lua || return 1
minetest.registered_entities["vehicles:apache"].hp_max = 1
minetest.registered_entities["vehicles:plane"].hp_max = 1
EOF

}
job_capturetheflag(){
  make_capturetheflag &&
  (cd capturetheflag &&
  zip -r ../capturetheflag.zip . &&
  tar -czvf ../capturetheflag.tgz .) &&
  rm -fr capturetheflag
}
