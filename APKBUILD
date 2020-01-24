# Maintainer: Natanael Copa <ncopa@alpinelinux.org>
# Contributor: Kiyoshi Aman <kiyoshi.aman@gmail.com>

pkgname=python3
# the python3-tkinter's pkgver needs to be synchronized with this.
pkgver=3.8.1
_basever="${pkgver%.*}"
pkgrel=1
pkgdesc="A high-level scripting language"
url="https://www.python.org/"
arch="all"
license="custom"
provides="py3-pip"
subpackages="$pkgname-dbg $pkgname-dev $pkgname-doc $pkgname-tests::noarch
	$pkgname-wininst"
makedepends="expat-dev openssl-dev zlib-dev ncurses-dev bzip2-dev xz-dev
	sqlite-dev libffi-dev tcl-dev linux-headers gdbm-dev readline-dev
	bluez-dev !gettext-dev"
source="https://www.python.org/ftp/python/$pkgver/Python-$pkgver.tar.xz
	fix-xattrs-glibc.patch
	musl-find_library.patch
	ctypes.patch
	"
builddir="$srcdir/Python-$pkgver"

# secfixes:
#   3.7.5-r0:
#     - CVE-2019-16056
#     - CVE-2019-16935
#   3.6.8-r1:
#     - CVE-2019-5010

prepare() {
	default_prepare

	# force system libs
	rm -r Modules/expat \
		Modules/_ctypes/darwin* \
		Modules/_ctypes/libffi*
}

build() {
	# --enable-optimizations is not enabled because it
	# is very, very slow as many tests are ran sequentially
	# for profile guided optimizations. additionally it
	# seems some of the training tests hang on certain
	# e.g. architectures (x86) possibly due to grsec or musl.

	./configure \
		--prefix=/usr \
		--disable-rpath \
		--enable-ipv6 \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-shared \
		--with-lto \
		--with-computed-gotos \
		--with-dbmliborder=gdbm:ndbm \
		--with-system-expat \
		--with-system-ffi \
		--with-threads

	# set thread stack size to 1MB so we don't segfault before we hit
	# sys.getrecursionlimit()
	make EXTRA_CFLAGS="$CFLAGS -DTHREAD_STACK_SIZE=0x100000"
}

check() {
	# test that we reach recursionlimit before we segfault
	cat > test-stacksize.py <<-EOF
	import threading
	import sys

	def fun(i):
	  try:
	    fun(i+1)
	  except:
	    sys.exit(0)

	t = threading.Thread(target=fun, args=[1])
	t.start()
EOF
	LD_LIBRARY_PATH=$PWD ./python test-stacksize.py

	local fail

	# musl related
	fail="test__locale test_locale test_strptime test_re"	# various musl locale deficiencies
	fail="$fail test_c_locale_coercion"
	fail="$fail test_datetime"				# hangs if 'tzdata' installed
	fail="$fail test_os"					# fpathconf, ttyname errno values
	fail="$fail test_posix"					# sched_[gs]etscheduler not impl
	fail="$fail test_shutil"				# lchmod, requires real unzip

	# FIXME: failures needing investigation
	fail="$fail test_faulthandler test_gdb"			# hangs(?)
	fail="$fail test_tokenize test_tools"			# SLOW (~60s)
	fail="$fail test_capi"					# test.test_capi.EmbeddingTests
	fail="$fail test_threadsignals"				# test_{,r}lock_acquire_interruption
	fail="$fail test_time"					# strftime/strptime %Z related
	fail="$fail test_cmath test_math"			# hang(?) on x86
	fail="$fail test_hash test_plistlib"			# fail on armhf
	fail="$fail test_ctypes"				# fail on aarch64 (ctypes.test.test_win32.Structures)
	fail="$fail test_cmd_line_script"			# fails on x86_64
	fail="$fail test_multiprocessing_main_handling"		# fails on x86_64
	fail="$fail test_runpy"					# fails on x86_64

	# kernel related
	fail="$fail test_fcntl"					# wants DNOTIFY, we don't have it

	# just a single subtest test_memoryview_struct_module is breaking on pc64le.
	if [ "$CARCH" = "ppc64le" ]; then
		fail="$fail test_buffer"			# fail on ppc64le
	fi
	case "$CARCH" in
		s390x|ppc64le|arm*)	fail="$fail test_threading" ;;	# FIXME: hangs
	esac

	make quicktest TESTOPTS="-j${JOBS:-$(nproc)} --exclude $fail"
}

package() {
	make -j1 DESTDIR="$pkgdir" EXTRA_CFLAGS="$CFLAGS" install maninstall
	install -Dm644 LICENSE "$pkgdir"/usr/share/licenses/$pkgname/LICENSE
	# those are provided by python3-tkinter
	rm -r "$pkgdir"/usr/bin/idle* "$pkgdir"/usr/lib/python*/idlelib \
		"$pkgdir"/usr/lib/python*/tkinter
}

dev() {
	default_dev

	# pyconfig.h is needed runtime so we move it back
	mkdir -p "$pkgdir"/usr/include/python$_basever
	mv "$subpkgdir"/usr/include/python$_basever/pyconfig.h \
		"$pkgdir"/usr/include/python$_basever/
}

tests() {
	pkgdesc="The test modules from the main python package"

	cd "$pkgdir"/usr/lib/python$_basever
	local i; for i in */test */tests; do
		mkdir -p "$subpkgdir"/usr/lib/python$_basever/"$i"
		mv "$i"/* "$subpkgdir"/usr/lib/python$_basever/"$i"
		rm -rf "$i"
	done
	mv "$pkgdir"/usr/lib/python$_basever/test \
		"$subpkgdir"/usr/lib/python$_basever/
}

wininst() {
	pkgdesc="Python wininst files"
	mkdir -p "$subpkgdir"/usr/lib/python$_basever/distutils/command
	mv "$pkgdir"/usr/lib/python$_basever/distutils/command/*.exe \
		"$subpkgdir"/usr/lib/python$_basever/distutils/command
}

sha512sums="d41381848cc1ec8009643b71875f395a9ac2c8e12a5b1efef33caf8a9e99a337c790d4354695c85352d11b62092ae372b5af62f78724363fcbf3504ff9a6ddca  Python-3.8.1.tar.xz
37b6ee5d0d5de43799316aa111423ba5a666c17dc7f81b04c330f59c1d1565540eac4c585abe2199bbed52ebe7426001edb1c53bd0a17486a2a8e052d0f494ad  fix-xattrs-glibc.patch
ab8eaa2858d5109049b1f9f553198d40e0ef8d78211ad6455f7b491af525bffb16738fed60fc84e960c4889568d25753b9e4a1494834fea48291b33f07000ec2  musl-find_library.patch
bda9aaa2de7b679dd6ad0fd76bb2bfcc198584c77daae188cee0bbb4871c1b328abd5180b65f8d862b378dda46e467b5408fcd4a0159e4471b947b3e49df7c49  ctypes.patch"
