#!/usr/bin/env bash

mkdir -p "$WORK_PATH"/kernel "$ROOTFS_PATH"/tempapk

"$HELPERS_PATH"/chroot_exec.sh apk fetch linux-rpi -o /tempapk
tar -C "$WORK_PATH"/kernel -zxf "$ROOTFS_PATH"/tempapk/linux-rpi* 2> /dev/null || return 1
rm "$ROOTFS_PATH"/tempapk/linux-rpi*

for i in raspberrypi-bootloader-common raspberrypi-bootloader; do
  "$HELPERS_PATH"/chroot_exec.sh apk fetch $i -o /tempapk
  tar -C "$WORK_PATH"/kernel/boot -zxf "$ROOTFS_PATH"/tempapk/$i* --strip=1 boot/ 2> /dev/null || return 1
  rm "$ROOTFS_PATH"/tempapk/$i*
done

rmdir "$ROOTFS_PATH"/tempapk

(
  cd "$WORK_PATH"/kernel || exit 1
  rm -f boot/System.map-* boot/config-*

  rm -rf lib/modules/*/kernel/{arch,sound,security,kernel}

  if [ "$USB_WIFI_SUPPORT" = "true" ]; then
    # Keep all crypto modules for WiFi (kernel/crypto and kernel/lib/crypto)
    # Keep lib/crc-ccitt.ko for rt2800usb WiFi driver
    find lib/modules/*/kernel/lib -type f ! -name 'crc-ccitt.ko.xz' ! -path '*/lib/crypto/*' -exec rm -f {} + 2> /dev/null
  else
    find lib/modules/*/kernel/crypto ! -name 'zstd.ko.xz' -exec rm -rf {} + 2> /dev/null
    rm -rf lib/modules/*/kernel/lib
  fi

  if [ "$USB_WIFI_SUPPORT" = "true" ]; then
    # Keep bcma and ssb for Broadcom WiFi support
    rm -rf lib/modules/*/kernel/drivers/{ata,auxdisplay,accessibility,base,block,bluetooth,cdrom,clk,connector,gpu,hid,iio,input,i2c,leds,md,mfd,mmc,mtd,mux,nvmem,pinctrl,pps,rtc,scsi,spi,staging,uio,vhost,video,w1}
  else
    rm -rf lib/modules/*/kernel/drivers/{ata,auxdisplay,accessibility,base,bcma,block,bluetooth,cdrom,clk,connector,gpu,hid,iio,input,i2c,leds,md,mfd,mmc,mtd,mux,net,nvmem,pinctrl,pps,rtc,scsi,spi,ssb,staging,uio,vhost,video,w1}
  fi

  rm -rf lib/modules/*/kernel/drivers/media/{cec,common,dvb-core,dvb-frontends,i2c,mc,pci,radio,rc,spi,test-drivers,tuners,v4l2-core,platform}
  if [ "$USB_WIFI_SUPPORT" = "true" ]; then
    rm -rf lib/modules/*/kernel/net/{6lowpan,9p,802,8021q,appletalk,atm,ax25,batman-adv,bluetooth,can,ceph,core,ieee802154,key,l2tp,llc,mpls,mptcp,netrom,nfc,nsh,openvswitch,rose,sched,sctp,vmw_vsock,xfrm}
  else
    rm -rf lib/modules/*/kernel/net/{6lowpan,9p,802,8021q,appletalk,atm,ax25,batman-adv,bluetooth,can,ceph,core,ieee802154,key,l2tp,llc,mpls,mptcp,netrom,nfc,nsh,openvswitch,rose,sched,sctp,vmw_vsock,wireless,xfrm}
  fi
)
