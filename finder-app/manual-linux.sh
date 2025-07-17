
#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
GIT_ROOT=$(git rev-parse --show-toplevel)

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}
cd "$OUTDIR"
mkdir -p rootfs
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
    
    # TODO: Add your kernel build steps here
    make defconfig
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper 
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig 
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all 
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules 
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs 
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}
echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    #sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p rootfs
cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys temp usr var
mkdir -p usr/bin usr/sbin usr/lib
mkdir -p var/log
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
else
    cd busybox
fi

# TODO: Make and install busybox
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
echo "CONFIG_STATIC=y" >> .config
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
echo "Library dependencies"
cd ${OUTDIR}
#${CROSS_COMPILE}readelf -a /bin/busybox | grep "program interpreter"
#${CROSS_COMPILE}readelf -a /bin/busybox | grep "Shared library"
#cp /home/ramadan/LinuxTest/RamadanCourseraRepo/finder-app/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
#cp /home/ramadan/LinuxTest/RamadanCourseraRepo/finder-app/libc.so.6 ${OUTDIR}/rootfs/lib64
#cp /home/ramadan/LinuxTest/RamadanCourseraRepo/finder-app/libm.so.6 ${OUTDIR}/rootfs/lib64
#cp /home/ramadan/LinuxTest/RamadanCourseraRepo/finder-app/libresolv.so.2 ${OUTDIR}/rootfs/lib64
# TODO: Add library dependencies to rootfs

# TODO: Make device nodes
cd ${OUTDIR}/rootfs/dev
mknod sda b 8 0
mknod console c 5 1
# TODO: Clean and build the writer utility

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp ${GIT_ROOT}/finder-app/{writer.c,writer.sh,start-qemu-app.sh,start-qemu-terminal.sh,Makefile,finder-test.sh,finder.sh,autorun-qemu.sh} ${OUTDIR}/rootfs/home/
mkdir -p ${OUTDIR}/rootfs/home/conf
cp ${GIT_ROOT}/finder-app/conf/* ${OUTDIR}/rootfs/home/conf/
cd ${OUTDIR}/rootfs/home
make clean
make CROSS_COMPILE=${CROSS_COMPILE}
# TODO: Chown the root directory
chown -R root:root ${OUTDIR}/rootfs
chmod 744 ${OUTDIR}/rootfs -R
# TODO: Create initramfs.cpio.gz
cd ${OUTDIR}/rootfs
find . -print0 | cpio --null -ov --format=newc > ${OUTDIR}/initramfs.cpio
gzip ${OUTDIR}/./initramfs.cpio
