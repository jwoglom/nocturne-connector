<h1 align="center">
  <br>
  <img src="https://usenocturne.com/images/logo.png" alt="Nocturne" width="200">
  <br>
  Nocturne Connector
  <br>
</h1>

<p align="center">Raspberry Pi OS for Wi-Fi connectivity on the Spotify Car Thing</p>

<p align="center">
  <a href="#prerequisites">Prerequisites</a> •
  <a href="#usage">Usage</a> •
  <a href="#donate">Donate</a> •
  <a href="#building">Building</a> •
  <a href="#tinkering-advanced">Tinkering (Advanced)</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

<div align="center">
  <a href="https://usenocturne.com"><img alt="Website" src="https://img.shields.io/badge/website-gray?style=flat-square&logo=react&logoColor=FFFFFF"></a>
  <a href="https://discord.gg/mnURjt3M6m"><img alt="Discord" src="https://img.shields.io/discord/1304909652387172493?style=flat-square&logo=discord&logoColor=FFFFFF&label=discord"></a>
</div>

## Prerequisites

- Raspberry Pi with networking
  - Pi 1, Pi Zero 1 (W), and Pi 2 require custom build instructions, see below
- SD card
  - Nocturne Connector is super small (~60 MB for Pi 3+, ~150MB for Pi 1/2/Zero), so you have many choices for SD cards
- Working Wi-Fi network
- Car Thing with Nocturne 3.0.0 or later installed

## Usage

1. Download the [img.gz from the latest release](https://github.com/usenocturne/nocturne-connector/releases/latest)
2. Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/), [balenaEtcher](https://etcher.balena.io/), or dd to flash the image to your SD card
   - In Raspberry Pi Imager, choose your Pi model, use "Use custom" in "Choose OS", select your SD card, press next, then choose "No" for customization.
4. Insert the SD card into your Raspberry Pi
5. Plug your Car Thing into a USB 3 port (if applicable) on your Raspberry Pi
   - If you are using a Pi Zero, plug your Car Thing into the data port.
6. Power the Raspberry Pi & set up Wi-Fi on your Car Thing

## Donate

Nocturne is a massive endeavor, and the team has spent every day over the last year making it a reality out of our passion for creating something that people like you love to use.

All donations are split between the three members of the Nocturne team and go towards the development of future features. We are so grateful for your support!

[Donation Page](https://usenocturne.com/donate)

## Building

`curl`, `zip/unzip`, `genimage`, `mkpasswd`, and `m4` binaries are required.

If you are on an architecture other than arm64, qemu-user-static (+ binfmt, or use `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes`) is required.

Use the `Justfile`. `just run` will output a flashable `img.gz` in `output`.

```
$ just -l
Available recipes:
  connector-api
  docker-qemu
  lint
  run
```

### Building for Pi 1, 2, and Zero

The Pi 1, 2, and original Zero doe not have onboard Wi-Fi, and us older 32-bit ARM architectures, so support is limited.

However, if you have a compatible Realtek/Mediatek WiFi adapter (e.g., the [CanoKit Wi-Fi USB adapter](https://www.canakit.com/raspberry-pi-wifi.html), included with some Raspberry Pi 2 kits), you can follow these build instructions to create a working image:

**Raspberry Pi 2:**

1. Start up the qemu-user-static Docker container on your build host (see above)
2. Invoke build steps specified in the Justfile with environment variables `USB_WIFI_SUPPORT=true ALPINE_ARCH=armv7`:

```
$ USB_WIFI_SUPPORT=true ALPINE_ARCH=armv7 just run
```

**Raspberry Pi 1 / Zero:**

1. Start up the qemu-user-static Docker container on your build host (see above)
2. Invoke build steps specified in the Justfile with environment variables `USB_WIFI_SUPPORT=true ALPINE_ARCH=armhf`:

```
$ USB_WIFI_SUPPORT=true ALPINE_ARCH=armhf just run
```


Then use Raspberry Pi Imager or another image flash tool to write the produced `img.gz` to a MicroSD card, and be sure to connect the USB Wi-Fi adapter.

This method has been tested with Realtek RT2x00 USB adapters, your mileage may vary.

## Tinkering (Advanced)

UART (with a TTY) is enabled and is the recommended way to debug and interact with the system without the need for SSH. SSH is open on port 22 if you'd like instead. Root password is `nocturne`.

## Credits

This software was made possible only through the following individuals and open source programs:

- [shadow](https://github.com/68p)
- [Dominic Frye](https://github.com/itsnebulalol)

### Image

- [gitlab.com/raspi-alpine/builder](https://gitlab.com/raspi-alpine/builder)

### API

- [kairos-io/kairos](https://github.com/kairos-io/kairos/blob/v1.6.0/pkg/machine/openrc/unit.go) (openrc package)

## License

This project is licensed under the **Apache** license.

---

> © 2025 Vanta Labs.

> "Spotify" and "Car Thing" are trademarks of Spotify AB. This software is not affiliated with or endorsed by Spotify AB.

> [usenocturne.com](https://usenocturne.com) &nbsp;&middot;&nbsp;
> GitHub [@usenocturne](https://github.com/usenocturne) &nbsp;&middot;&nbsp;
> [Discord](https://discord.gg/mnURjt3M6m)
