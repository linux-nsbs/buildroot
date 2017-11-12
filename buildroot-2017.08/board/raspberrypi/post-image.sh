#!/bin/sh

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

case "${2}" in
	--add-pi3-miniuart-bt-overlay)
	if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		echo "Adding 'dtoverlay=pi3-miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi3 ttyAMA0 serial console
dtoverlay=pi3-miniuart-bt
__EOF__
	fi
	;;
	--aarch64)
	# Run a 64bits kernel (armv8)
	sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
	if ! grep -qE '^arm_control=0x200' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_control=0x200
__EOF__
	fi

	# Enable uart console
	if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
		cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable rpi3 ttyS0 serial console
enable_uart=1
__EOF__
	fi
	;;
esac

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

if [ ! -f /bin/tar_suid ] || [ ! -f /bin/rm_suid ]; then
  echo "ERROR: Cannot extract rootfs.tar"
  [ ! -f /bin/tar_suid ] && echo "       /bin/tar_setuid is missing. Create is with: sudo cp /bin/tar /bin/tar_suid && sudo chmod u+s /bin/tar_suid"
  [ ! -f /bin/rm_suid ] && echo "       /bin/rm_setuid is missing. Create is with: sudo cp /bin/rm /bin/rm_suid && sudo chmod u+s /bin/rm_suid"
else
  rm_suid -rf ${BINARIES_DIR}/rootfs/*
  tar_suid -xf ${BINARIES_DIR}/rootfs.tar -C ${BINARIES_DIR}/rootfs
fi

exit $?
