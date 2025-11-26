# pureblue

A **Fedora immutable bootc image for everyone**. It's close to vanilla **GNOME** desktop experince with sane defaults for normal everyday users.

- Based on **Fedora Bootc**
- **Immutable** image with atomic updates
- Close to **vanilla GNOME** experience
- Out-of-the-box setup so you can just start using your system
- Supports **bootc swap** style workflows (switch between images / editions without reinstalling)

## Switch & Update (bootc)

```bash
# Switch
sudo bootc switch ghcr.io/pureblue-os/pureblue:latest
reboot

# Update (bootc)
sudo bootc upgrade
reboot

# Update (rpm-ostree)
rpm-ostree upgrade
reboot
```

## Asus ROG

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
