#!/bin/sh
set -e
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
;do
  git clone --depth 1 "$x"
  for subdir in "$x"/*;do
    if [ -d "$subdir" ];then
      mv "$subdir" ./
    fi
  done
  rm -fr "$x"
done

