#!/bin/bash

tar -xf intltool-0.51.0.tar.gz

cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make 

make check

make install

install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ..
rm -rf intltool-0.51.0

# install autoconf

tar -xf autoconf-2.69.tar.xz

cd autoconf-2.69

sed '361 s/{/\\{/' -i bin/autoscan.in
./configure --prefix=/usr
make
make install

cd ..
rm -rf autoconf-2.69

#install auto make

tar -xf automake-1.16.1.tar.xz

cd automake-1.16.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.1

make

make -j4 check

make install

cd ..

rm -rf automake-1.16.1

# install kmod

tar -xf kmod-26.tar.xz

cd kmod-26

./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib

make

make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod

cd ..

rm -rf kmod-26

# install gettext

tar -xf gettext-0.20.1.tar.xz

cd gettext-0.20.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.20.1

make

make check

make install

chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ..

rm -rf gettext-0.20.1

#install libelf

tar -xf elfutils-0.178.tar.bz2

cd elfutils-0.178

./configure --prefix=/usr --disable-debuginfod

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd ..

rm -rf elfutils-0.178

#installing libffi

tar -xf libffi-3.3.tar.gz

cd libffi-3.3

./configure --prefix=/usr --disable-static --with-gcc-arch=native

make

make check

make install

cd ..

rm -rf libffi-3.3

# install openssl

tar -xf openssl-1.1.1d.tar.gz

cd openssl-1.1.1d

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1d
cp -vfr doc/* /usr/share/doc/openssl-1.1.1d


cd ..

rm -rf openssl-1.1.1d

#install python

tar -xf Python-3.8.1.tar.xz

cd Python-3.8.1

./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes

make

make install
chmod -v 755 /usr/lib/libpython3.8.so
chmod -v 755 /usr/lib/libpython3.so
ln -sfv pip3.8 /usr/bin/pip3

install -v -dm755 /usr/share/doc/python-3.8.1/html 

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.8.1/html \
    -xvf ../python-3.8.1-docs-html.tar.bz2

cd ..

rm -rf Python-3.8.1

#installing ninja

tar -xf ninja-1.10.0.tar.gz

cd ninja-1.10.0

export NINJAJOBS=4

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd ..

rm -rf ninja-1.10.0

#install meson

tar -xf meson-0.53.1.tar.gz

cd meson-0.53.1

python3 setup.py build

python3 setup.py install --root=dest
cp -rv dest/* /

cd ..

rm -rf meson-0.53.1

#install coreutils

tar -xf coreutils-8.31.tar.xz

cd coreutils-8.31

patch -Np1 -i ../coreutils-8.31-i18n-1.patch

sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

make NON_ROOT_USERNAME=nobody check-root

echo "dummy:x:1000:nobody" >> /etc/group

chown -Rv nobody . 

su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

sed -i '/dummy/d' /etc/group

make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

mv -v /usr/bin/{head,nice,sleep,touch} /bin


cd ..

rm -rf coreutils-8.31

#install check

tar -xf check-0.14.0.tar.gz

cd check-0.14.0

./configure --prefix=/usr

make

make check

make docdir=/usr/share/doc/check-0.14.0 install &&
sed -i '1 s/tools/usr/' /usr/bin/checkmk

cd ..

rm -rf check-0.14.0

# installing diffutils

tar -xf diffutils-3.7.tar.xz

cd diffutils-3.7

./configure --prefix=/usr

make

make check

make install

cd ..

rm -rf diffutils-3.7

#install gawk

tar -xf gawk-5.0.1.tar.xz

cd gawk-5.0.1

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

make check

make install

mkdir -v /usr/share/doc/gawk-5.0.1
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.0.1

cd ..

rm -rf gawk-5.0.1

# install findutils

tar -xf findutils-4.7.0.tar.xz

cd findutils-4.7.0

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

make check

make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd ..

rm -rf findutils-4.7.0

# install groff

tar -xf groff-1.22.4.tar.gz

cd groff-1.22.4

PAGE=<paper_size> ./configure --prefix=/usr

make -j1

make install

cd ..

rm -rf groff-1.22.4

# install grub
tar -xf grub-2.04.tar.xz

cd grub-2.04

./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

make

make install

mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd ..

rm -rf grub-2.04

#install less

tar -xf less-551.tar.gz

cd less-551

./configure --prefix=/usr --sysconfdir=/etc

make

make install

cd ..

rm -rf less-551

#install gzip

tar -xf gzip-1.10.tar.xz

cd gzip-1.10

./configure --prefix=/usr

make

make check

make install

mv -v /usr/bin/gzip /bin

cd ..

rm -rf gzip-1.10

#install zstd

tar -xf zstd-1.4.4.tar.gz

cd zstd-1.4.4

make

make prefix=/usr install

rm -v /usr/lib/libzstd.a
mv -v /usr/lib/libzstd.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

cd ..

rm -rf zstd-1.4.4

#install Iproute

tar -xf iproute2-5.5.0.tar.xz

cd iproute2-5.5.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

sed -i 's/.m_ipt.o//' tc/Makefile

make

make DOCDIR=/usr/share/doc/iproute2-5.5.0 install

cd ..

rm -rf iproute2-5.5.0

# install kbd

tar -xf kbd-2.2.0.tar.xz

cd kbd-2.2.0

patch -Np1 -i ../kbd-2.2.0-backspace-1.patch

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock

make

make check

make install

mkdir -v       /usr/share/doc/kbd-2.2.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.2.0


cd ..

rm -rf kbd-2.2.0

# install libpipeline

tar -xf libpipeline-1.5.2.tar.gz

cd libpipeline-1.5.2

./configure --prefix=/usr

make

make check

make install

cd ..

rm -rf libpipeline-1.5.2

#install make

tar -xf make-4.3.tar.gz

cd make-4.3

./configure --prefix=/usr

make

make PERL5LIB=$PWD/tests/ check

make install

cd ..

rm -rf make-4.3

#install patch

tar -xf patch-2.7.6.tar.xz

cd patch-2.7.6

./configure --prefix=/usr

make

make check

make install

cd ..

rm -rf patch-2.7.6

#install man-db

tar -xf man-db-2.9.0.tar.xz

cd man-db-2.9.0

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.9.0 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=           \
            --with-systemdsystemunitdir=

make

make check

make install

cd ..

rm -rf man-db-2.9.0

#install tar

tar -xf tar-1.32.tar.xz

cd tar-1.32

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

make

make check

make install

make -C doc install-html docdir=/usr/share/doc/tar-1.32

cd ..

rm -rf tar-1.32

#install texinfo

tar -xf texinfo-6.7.tar.xz

cd texinfo-6.7

./configure --prefix=/usr --disable-static

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

cd ..

rm -rf texinfo-6.7

#install vim

tar -xf vim-8.2.0190.tar.gz

cd vim-8.2.0190

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -Rv nobody .

su nobody -s /bin/bash -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log

make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.0190

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

vim -c ':options'

cd ..

rm -rf vim-8.2.0190

#install procps-ng

tar -xf procps-ng-3.3.15.tar.xz

cd procps-ng-3.3.15

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.15 \
            --disable-static                         \
            --disable-kill

make

sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
rm testsuite/pgrep.test/pgrep.exp
make check

make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so


cd ..

rm -rf procps-ng-3.3.15

#install util-linux

tar -xf util-linux-2.35.1.tar.xz

cd util-linux-2.35.1

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.35.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir

make

make install

cd ..

rm -rf util-linux-2.35.1

#install e2fsprogs

tar -xf e2fsprogs-1.45.5.tar.gz

cd e2fsprogs-1.45.5

mkdir -v build
cd       build

../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make

make check

make install

chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd ..

rm -rf e2fsprogs-1.45.5

#install sysklogd

tar -xf sysklogd-1.5.1.tar.gz

cd sysklogd-1.5.1

sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c

make

make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

cd ..

rm -rf sysklogd-1.5.1

#install svinit

tar -xf sysvinit-2.96.tar.xz

cd sysvinit-2.96

patch -Np1 -i ../sysvinit-2.96-consolidated-1.patch

make

make install

cd ..

rm -rf sysvinit-2.96

#install eudev

tar -xf eudev-3.2.9.tar.gz

cd eudev-3.2.9

./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static

make

mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

make check

make install

tar -xvf ../udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install

udevadm hwdb --update

cd ..

rm -rf eudev-3.2.9

echo "Installed packages"




