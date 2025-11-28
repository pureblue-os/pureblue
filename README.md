# pureblue

A **Fedora immutable bootc image for everyone**. It's close to vanilla **GNOME**
desktop experince with sane defaults for normal everyday users.

- Based on **Fedora Bootc**
- **Immutable** image with atomic updates
- Close to **vanilla GNOME** experience
- Out-of-the-box setup so you can just start using your system
- Supports **bootc swap** style workflows (switch between images / editions
  without reinstalling)

## ISO Installation

- Download the latest ISO from the
  [releases page](https://github.com/pureblue-os/pureblue/releases)

- Create a bootable USB using
  [Fedora Media Writer](https://fedoraproject.org/en/workstation/download#fedora-media-writer).

## Already have a fedora immutable system?

**Switch to pureblue:**

```bash
sudo bootc switch ghcr.io/pureblue-os/pureblue:latest
reboot
```

---

**Update (rpm-ostree):**

```bash
# Recommended if you are layering packages
# (Also used for automated updates)
rpm-ostree upgrade
reboot
```

---

**Update (bootc):**

```bash
# Might not work if you have layered packages
sudo bootc upgrade
reboot
```

## Layering Asus ROG (without kernel modules)

Add the repo:

```bash
sudo wget -O /etc/yum.repos.d/_copr_lukenukem-asus-linux.repo \
  "https://copr.fedorainfracloud.org/coprs/lukenukem/asus-linux/repo/fedora-$(rpm -E %fedora)/lukenukem-asus-linux-fedora-$(rpm -E %fedora).repo"
```

Layer packages:

```bash
sudo rpm-ostree override remove tuned-ppd \
  --install=asusctl \
  --install=asusctl-rog-gui \
  --install=power-profiles-daemon \
  --install=supergfxctl
reboot
```
