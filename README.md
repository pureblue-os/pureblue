# pureblue

pureblue is a **Fedora immutable bootc image for everyone** — a close to vanilla **GNOME** desktop with sane defaults for normal users.

- Based on **Fedora**
- **Immutable** image with atomic updates
- Close to **vanilla GNOME** experience
- Out-of-the-box setup so you can just start using your system
- Supports **bootc swap** style workflows (switch between images / editions without reinstalling)

## Switch & Update

```bash
# Switch
sudo bootc switch ghcr.io/pureblue-os/pureblue:latest
sudo reboot

# Update
sudo bootc upgrade
sudo reboot
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

```
