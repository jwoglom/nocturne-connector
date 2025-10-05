#!/bin/sh

if [ "$USB_WIFI_SUPPORT" = "true" ]; then
  "$HELPERS_PATH"/chroot_exec.sh apk add wireless-tools wpa_supplicant wpa_supplicant-openrc nftables eudev udev-init-scripts networkmanager networkmanager-cli linux-firmware-brcm linux-firmware-ralink linux-firmware-ath9k_htc linux-firmware-rtlwifi networkmanager-wifi
else
  "$HELPERS_PATH"/chroot_exec.sh apk add wireless-tools wpa_supplicant wpa_supplicant-openrc nftables eudev udev-init-scripts networkmanager networkmanager-cli linux-firmware-brcm networkmanager-wifi
fi

mkdir -p "$ROOTFS_PATH"/etc/wpa_supplicant
cat > "$ROOTFS_PATH"/etc/wpa_supplicant/wpa_supplicant.conf << EOF
ctrl_interface=/run/wpa_supplicant
update_config=1
EOF

sed -i '\|default_conf=/etc/wpa_supplicant/wpa_supplicant.conf|a \
  ifup wlan0' "$ROOTFS_PATH"/etc/init.d/wpa_supplicant

cat > "$ROOTFS_PATH"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet dhcp
EOF

echo "net.ipv4.ip_forward=1" >> "$ROOTFS_PATH"/etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> "$ROOTFS_PATH"/etc/sysctl.conf

echo "172.16.42.2 nocturne" >> "$ROOTFS_PATH"/etc/hosts

rm -f "$ROOTFS_PATH"/etc/nftables.nft
cp "$RES_PATH"/config/nftables.nft "$ROOTFS_PATH"/etc/nftables.nft

echo "SUBSYSTEM==\"net\", ATTRS{idVendor}==\"0000\", ATTRS{idProduct}==\"1014\", NAME=\"usb0\"" > "$ROOTFS_PATH"/usr/lib/udev/rules.d/carthing.rules

cat > "$ROOTFS_PATH"/etc/NetworkManager/NetworkManager.conf << EOF
[main]
dhcp=internal
rc-manager=file
EOF

cat > "$ROOTFS_PATH"/etc/NetworkManager/system-connections/usb0.nmconnection << EOF
[connection]
id=usb0
type=ethernet
interface-name=usb0
autoconnect=true

[ipv4]
method=manual
address1=172.16.42.1/24
dns=1.1.1.1;8.8.8.8;
EOF
chmod 600 "$ROOTFS_PATH"/etc/NetworkManager/system-connections/usb0.nmconnection

echo "ENV{DEVTYPE}==\"gadget\", ENV{NM_UNMANAGED}=\"0\"" > "$ROOTFS_PATH"/usr/lib/udev/rules.d/98-network.rules

DEFAULT_SERVICES="${DEFAULT_SERVICES} wpa_supplicant wpa_cli nftables udev-postmount networkmanager"
SYSINIT_SERVICES="${SYSINIT_SERVICES} udev udev-trigger"
