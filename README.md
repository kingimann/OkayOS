# OkayOS

> A homemade Linux distribution. Debian under the hood, dressed up to look like Windows.
> Built for fun and tinkering — everything here is yours to change.

OkayOS is a **live ISO** you can boot in a virtual machine or from a USB stick.
It's assembled with [`live-build`](https://wiki.debian.org/live-build) from a
Debian base, with an XFCE desktop themed to feel like Windows: a bottom taskbar,
a **Start** menu, window controls on the right, and a custom wallpaper.

It is **not** a from-scratch kernel — it's a real, practical way to make *your own
distro* by choosing what software ships and how it looks.

---

## Quick start

```bash
git clone https://github.com/kingimann/OkayOS.git
cd OkayOS
./build.sh        # builds out/OkayOS-amd64.iso
./run.sh          # boots it in QEMU
```

- `build.sh` uses **Docker** if it's available (reproducible, nothing installed on
  your host). If Docker isn't running, it falls back to a **native** build using
  `sudo` on a Debian/Ubuntu machine.
- The first build downloads a few hundred MB of packages and takes ~15–40 min
  depending on your connection. Later builds are faster thanks to the package cache.

You can also burn `out/OkayOS-amd64.iso` to a USB stick (e.g. with
[balenaEtcher](https://etcher.balena.io/) or `dd`) and boot real hardware.
The live system logs in automatically; the user is `okay` (passwordless `sudo`).

---

## What's in the box

| Area        | Choice                                                            |
|-------------|-------------------------------------------------------------------|
| Base        | Debian 12 (bookworm)                                               |
| Desktop     | XFCE 4                                                             |
| Look        | B00merang **Windows-10** GTK theme + icons, bottom taskbar, Start menu |
| Display mgr | LightDM (auto-login in live mode)                                  |
| Apps        | Firefox ESR, Thunar file manager, terminal, text editor, image viewer, calculator |
| CLI         | git, vim, nano, htop, tmux, neofetch, and a friendly OkayOS shell  |

---

## How it's put together

```
auto/config                      # live-build settings: base distro, ISO name, boot options
config/
  package-lists/okayos.list.chroot   # the list of software OkayOS ships
  hooks/normal/*.hook.chroot         # scripts that run during build (branding, etc.)
  includes.chroot/                   # files copied verbatim into the system:
    etc/skel/.config/xfce4/...       #   default XFCE layout = the Windows look
    etc/skel/.bashrc                 #   default shell + welcome banner
    etc/lightdm/...                  #   login screen branding
    usr/local/bin/okayos-*           #   helper scripts
scripts/
  fetch-assets.sh                # downloads the Windows theme + icons
  make-wallpaper.sh              # generates the wallpaper with ImageMagick
  build-native.sh               # native (sudo) build
  in-container-build.sh         # build steps run inside Docker
Dockerfile                       # reproducible build environment
build.sh / run.sh                # build the ISO / boot it in QEMU
```

The Windows look comes entirely from `config/includes.chroot/etc/skel/.config/xfce4/`
(panel layout, window-button order, theme names) plus the theme assets fetched by
`scripts/fetch-assets.sh`. Nothing is hard-wired — change those files and rebuild.

---

## Make it yours

- **Add or remove software:** edit `config/package-lists/okayos.list.chroot`.
- **Turn it into a full desktop with more apps:** add package names to that list.
- **Change the name/version:** edit `auto/config` and
  `config/hooks/normal/0100-okayos-branding.hook.chroot`.
- **Change the wallpaper:** edit `scripts/make-wallpaper.sh`, or drop your own
  `wallpaper.png` into `config/includes.chroot/usr/share/backgrounds/okayos/`.
- **Tweak the desktop layout:** edit the XML files under
  `config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/`.

After any change: `./build.sh` again.

---

## Requirements

**Docker path (recommended):** Docker. That's it.

**Native path:** a Debian/Ubuntu host with `sudo`. `build-native.sh` installs the
rest (`live-build`, `debootstrap`, `xorriso`, `squashfs-tools`, `imagemagick`, …).

**To test the ISO:** `qemu-system-x86` (`sudo apt install qemu-system-x86`).

---

## Notes & limitations

- The ISO boots in **BIOS / legacy** mode (great for QEMU and most VMs). For
  UEFI-only machines you may need to enable legacy/CSM boot, or extend
  `auto/config` with UEFI bootloader options.
- This is a **live** system: changes you make while running it are not persisted
  unless you set up persistence or install it to disk. It's meant for experimenting.
- The Windows theme is the community [B00merang](https://github.com/B00merang-Project)
  project — it's a *look-alike*, not Microsoft software.

Have fun. It's gonna be okay.
