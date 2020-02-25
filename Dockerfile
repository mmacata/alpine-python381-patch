FROM alpine:edge

RUN apk add abuild
RUN apk add build-base expat-dev openssl-dev zlib-dev ncurses-dev bzip2-dev xz-dev sqlite-dev libffi-dev tcl-dev linux-headers gdbm-dev readline-dev bluez-dev

# collect build sources
RUN curl https://gitlab.alpinelinux.org/alpine/aports/-/archive/master/aports-master.tar.gz?path=main%2Fpython3 > aports-master-main-python3.tar.gz
RUN tar -xzf aports-master-main-python3.tar.gz && mv aports-master-main-python3 aports

WORKDIR /aports/main/python3/
COPY APKBUILD APKBUILD
COPY ctypes.patch ctypes.patch

# add user for build
RUN adduser -S abuild -G abuild sudo
RUN chown -R abuild /aports/main/python3
USER abuild

# build
RUN abuild-keygen -a -n
RUN abuild -r

# test
USER root
RUN apk add --allow-untrusted /home/abuild/packages/main/x86_64/python3-3.8.1-r3.apk
