#!/bin/bash
#Install GCC-9.2.0

tar -xf gcc-9.2.0.tar.xz
cd gcc-9.2.0

sed -e '1161 s|^|//|' \
    -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

mkdir -v build
cd       build

SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

make

ulimit -s 32768

chown -Rv nobody . 
su nobody -s /bin/bash -c "PATH=$PATH make -k check"

make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/9.2.0/include-fixed/bits/

chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/9.2.0/include{,-fixed}

ln -sv ../usr/bin/cpp /lib

ln -sv gcc /usr/bin/cc

install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/9.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd ../..
rm -rf gcc-9.2.0

#Install Pkg-config-0.29.2

tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2

make
make check
make install

cd ..
rm -rf pkg-config-0.29.2

#Install Ncurses-6.2
tar -xf ncurses-6.2.tar.gz
cd ncurses-6.2

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec

make

make install

mv -v /usr/lib/libncursesw.so.6* /lib

ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

mkdir -v       /usr/share/doc/ncurses-6.2
cp -v -R doc/* /usr/share/doc/ncurses-6.2

cd ..
rm -rf nucurses-6.2

#Install Libcap-2.31

tar -xf libcap-2.31.tar.xz
cd libcap-2.31

sed -i '/install.*STA...LIBNAME/d' libcap/Makefile

make lib=lib


make test

make lib=lib install

chmod -v 755 /lib/libcap.so.2.31

cd ..
rm -rf libcap-2.31

#Install Sed-4.8
tar -xf sed-4.8.tar.xz
cd sed-4.8

sed -i 's/usr/tools/'                 build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in

./configure --prefix=/usr --bindir=/bin

make
make html

make check

make install
install -d -m755           /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8

cd ..
rm -rf sed-4.8

#Install Psmisc-23.2
tar -xf psmisc-23.2.tar.xz
cd psmisc-23.2

./configure --prefix=/usr
make
make install

mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

cd ..
rm -rf psmisc-23.2

#Install Iana-Etc-2.30

tar -xf iana-etc-2.30.tar.bz2
cd iana-etc-2.30

make 
make install

cd ..
rm -rf iana-etc-2.30

#Install Bison-3.5.2

tar -xf bison-3.5.2.tar.xz
cd bison-3.5.2

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.5.2

make
make install 

cd ..
rm -rf bison-3.5.2

#Install Flex-2.6.4

tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4

make 

make check

make install

ln -sv flex /usr/bin/lex

cd ..
rm -rf flex-2.6.4

#Install Grep-3.4

tar -xf grep-3.4.tar.xz
cd grep-3.4

./configure --prefix=/usr --bindir=/bin
make
make check
make install

cd ..
rm -rf grep-3.4

#Install Bash-5.0
tar -xf bash-5.0.tar.gz
cd bash-5.0

patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch
./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.0 \
            --without-bash-malloc            \
            --with-installed-readline
make

make install
mv -vf /usr/bin/bash /bin

exec /bin/bash --login +h

#Install Libtool-2.4.6
tar -xf libtool-2.4.6.tar.xz
cd libtool-2.4.6

./configure --prefix=/usr
make
make check
make install

cd ..
rm -rf libtool-2.4.6

#Install GDBM-1.18.1
tar -xf gdbm-1.18.1.tar.gz
cd gdbm-1.18.1

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
make check
make install

cd ..
rm -rf gdbm-1.18.1

#Install gperf-3.1

tar -xf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make
make -j1 check
make install

cd ..
rm -rf gperf-3.1

#Install Expat-2.2.9

tar -xf expat-2.2.9.tar.xz
cd expat-2.2.9

sed -i 's|usr/bin/env |bin/|' run.sh.in

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.2.9


make

make check

make install

install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.9

cd ..
rm -rf expat-2.2.9

#Install Inetutils-1.9.4
tar -xf inetutils-1.9.4.tar.xz
cd inetutils-1.9.4

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make
make check

make install

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

cd ..
rm -rf inetutils-1.9.4

#Install Perl-5.30.1

tar -xf perl-5.30.1.tar.xz
cd perl-5.30.1

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib                  \
                  -Dusethreads

make
make test
make install
unset BUILD_ZLIB BUILD_BZIP2

cd ..
rm -rf perl-5.30.1

#Install XML::Parser-2.46

tar -xf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46

perl Makefile.PL
make
make test
make install

cd ..
rm -rf XML-Parser-2.46

#Install Intltool-0.51.0

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

#Install Autoconf-2.69

tar -xf autoconf-2.69.tar.xz
cd autoconf-2.69

sed '361 s/{/\\{/' -i bin/autoscan.in

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf autoconf-2.69

#Install Automake-1.16.1
tar -xf automake-1.16.1.tar.xz
cd automake-1.16.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.1

make

make -j4 check

make install

cd ..
rm -rf automake-1.16.1

#Install Kmod-26

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

#Install Gettext-0.20.1

tar -xf gettext-0.20.1.tar.xz
cd gettext-0.20.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.20.1

make

make check

make install

chmod -v 0755 /usr/lib/preloadable_libintl.so

#Install Libelf from Elfutils-0.178
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

#Install Libffi-3.3

tar -xf libffi-3.3.tar.gz
cd libffi-3.3

./configure --prefix=/usr --disable-static --with-gcc-arch=native

make

make check

make install

cd ..
rm -rf libffi-3.3

#Install OpenSSL-1.1.1f

tar -xf openssl-1.1.1f.tar.gz
cd openssl-1.1.1f

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make 

make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1f
cp -vfr doc/* /usr/share/doc/openssl-1.1.1f

cd ..
rm -rf openssl-1.1.1f

#Install Python-3.8.1

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

#Install Ninja-1.10.0

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

#Install Meson-0.53.1

tar -xf meson-0.53.1.tar.gz
cd meson-0.53.1

python3 setup.py build

python3 setup.py install --root=dest
cp -rv dest/* /

cd ..
rm -rf meson-0.53.1

#Install Coreutils-8.31

tar -xf coreutils-8.31.tar.xz
cd coreutils-8.31

patch -Np1 -i ../coreutils-8.31-i18n-1.patch

sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

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

#Install Check-0.14.0

tar -xf check-0.14.0.tar.gz
cd check-0.14.0.tar

./configure --prefix=/usr

make 
make check

make docdir=/usr/share/doc/check-0.14.0 install &&
sed -i '1 s/tools/usr/' /usr/bin/checkmk

cd ..
rm -rf check-0.14.0

#Install Diffutils-3.7

tar -xf diffutils-3.7.tar.xz
cd diffutils-3.7

./configure --prefix=/usr

make
make check
make install

cd ..

rm -rf diffutils-3.7

#Install Gawk-5.0.1

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

#Install Findutils-4.7.0

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

#Install Groff-1.22.4

tar -xf groff-1.22.4.tar.gz
cd groff-1.22.4

PAGE=letter ./configure --prefix=/usr

make -j1

make install

cd ..
rm -rf groff-1.22.4

#Install Grub-2.04

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

#Install Less-551

tar -xf less-551.tar.gz
cd less-551

./configure --prefix=/usr --sysconfdir=/etc

make 

make install

cd ..
rm -rf less-551

#Install gzip-1.10
tar -xf gzip-1.10.tar.xz
cd gzip-1.10

./configure --prefix=/usr

make
make check

make install

mv -v /usr/bin/gzip /bin

cd ..

rm -rf gzip-1.10

#Install Zstd-1.4.4

tar -xf zstd-1.4.4.tar.gz
cd zstd-1.4.4

make
make prefix=/usr install
rm -v /usr/lib/libzstd.a
mv -v /usr/lib/libzstd.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

cd ..
rm -rf zstd-1.4.4

#Install IPRoute2-5.5.0
tar -xf iproute2-5.5.0.tar.xz
cd iproute2-5.5.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile

make

make DOCDIR=/usr/share/doc/iproute2-5.5.0 install

cd ..
rm -rf iproute2-5.5.0

#Install Kbd-2.2.0
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

#Install Libepipeline-1.5.2
tar -xf libpipeline-1.5.2.tar.gz
cd libpipeline-1.5.2

./configure --prefix=/usr
make
make check
make install

cd ..
rm -rf libpipeline-1.5.2

#Install Make-4.3
tar -xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr

make

make PERL5LIB=$PWD/tests/ check

make install

cd ..
rm -rf make-4.3

#Install Patch-2.7.6

tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf patch-2.7.6

#Install Man-DB-2.9.0

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

#Install Tar-1.32

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

#Install Texinfo-6.7

tar -xf texinfo-6.7.tar.xz

cd texinfo-6.7

./configure --prefix=/usr --disable-static

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

cd ..
rm -rf texinfo-6.7

#Install Vim-8.2.0190
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

cd ..
rm -rf vim-8.2.0190

#Install Procps-ng-3.3.15

tar -xf procps-ng-3.3.15.tar.xz
cd procps-ng-3.3.15

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.15 \
            --disable-static                         \
            --disable-kill

make 

make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd ..
rm -rf procps-ng-3.3.15

#Install util-linux-2.35.1

tar -xf Util-linux-2.35.1.tar.xz
cd Util-linux-2.35.1

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

#Install E2fsprogs-1.45.5
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

#Install Sysklogd-1.5.1

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

#Install sysvinit-2.96

tar -xf sysvinit-2.96.tar.xz
cd sysvinit-2.96

patch -Np1 -i ../sysvinit-2.96-consolidated-1.patch

make

make install

cd ..
rm -rf sysvinit-2.96

#Install Eudev-3.2.9

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


