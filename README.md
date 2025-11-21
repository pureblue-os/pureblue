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

# Update
sudo bootc upgrade
sudo reboot