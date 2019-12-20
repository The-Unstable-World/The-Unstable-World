FROM alpine

RUN apk add --no-cache git build-base irrlicht-dev cmake bzip2-dev libpng-dev jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev gmp-dev jsoncpp-dev && \
  cd /root && \
  git clone --depth=1 https://github.com/minetest/minetest.git ./minetest && \
  git clone --depth=1 https://github.com/minetest/minetest_game.git ./minetest/games/minetest_game && \
  rm -fr ./minetest/games/minetest_game/.git && \
  cd ./minetest && \
  cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SERVER=TRUE \
    -DBUILD_CLIENT=FALSE && \
  make -j4 && \
  make install DESTDIR=/root/out

FROM alpine

COPY --from=0 /root/out/usr/local/share/minetest /usr/local/share/minetest
COPY --from=0 /root/out/usr/local/bin/minetestserver /usr/local/bin/minetestserver
COPY --from=0 /root/out/usr/local/share/doc/minetest/minetest.conf.example /etc/minetest/minetest.conf

RUN apk add --no-cache sqlite-libs curl gmp libstdc++ libgcc && adduser -D minetest

USER minetest

EXPOSE 30000/udp

CMD ["/usr/local/bin/minetestserver", "--config", "/etc/minetest/minetest.conf"]
