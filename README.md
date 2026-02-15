# pureblue

**A clean, immutable Fedora desktop for everyday users.**

Pureblue is a Fedora bootc-based immutable image that stays close to vanilla GNOME while providing sane defaults and a 
zero-friction setup. No tinkering required—just install and start working.

- **Immutable** atomic updates with instant rollbacks
- **Vanilla GNOME** experience, no heavy customization
- **Zero setup**—works out of the box
- **Bootc-native**—swap between editions or images without reinstalling

## Installation

### Option 1: Fresh Install (ISO)
1. Download the latest ISO from the [releases page](https://github.com/pureblue-os/pureblue/releases)
2. Create a bootable USB with [Fedora Media Writer](https://fedoraproject.org/en/workstation/download#fedora-media-writer)
3. Boot and install

### Option 2: Rebase from Fedora Immutable
Already running Fedora Silverblue/Kinoite? Switch to Pureblue without losing your data.

**Method A: rpm-ostree (Recommended)**
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/pureblue-os/pureblue:stable
reboot
```

**Method B: bootc switch**
```bash
sudo bootc switch ghcr.io/pureblue-os/pureblue:stable
reboot
```

> **Note:** While `bootc switch` works, `rpm-ostree` is recommended for most users because it supports user-layered 
packages (needed for hardware drivers). Pureblue uses `rpm-ostree` for automatic upgrades and provides better visibility 
of your system state via `rpm-ostree status`.

**Available variants:**
- `ghcr.io/pureblue-os/pureblue` (AMD/Intel)
- `ghcr.io/pureblue-os/pureblue-nvidia` (Proprietary drivers)
- `ghcr.io/pureblue-os/pureblue-nvidia-open` (Open kernel module)

**Keeping updated:**
```bash
rpm-ostree upgrade
reboot
```

---

## The Pureblue Workflow

On an immutable system, the base OS stays pristine. Here's the recommended hierarchy for installing software—follow this 
order to keep your system stable and manageable:

### 1. Flatpak → Desktop Apps
Install graphical apps from the app store (Steam, Chrome, LibreOffice). Flatpaks are sandboxed and won't touch your base 
system.

> **Exception:** IDEs (VS Code, JetBrains) work better in Distrobox, even when available as Flatpaks.

### 2. Homebrew → CLI Tools
Install command-line tools in user space:
```bash
brew install fastfetch ripgrep fd kubectl
```
Perfect for developer utilities that don't need system integration.

### 3. Distrobox → Development & Missing Apps
When Flatpak or Homebrew don't have what you need, use Distrobox. Create containers (Ubuntu, Debian, etc.) that integrate 
seamlessly with your desktop—GPU acceleration, audio, and apps appear in your launcher.

**Best for:** Development environments, specialized tools, or apps not available elsewhere.

### 4. Package Layering → System/Hardware Only
**Never** layer user applications. Only use `rpm-ostree install` for:
- Hardware control daemons (ASUS ROG tools, fan control)
- System services (power-profiles-daemon, waydroid)
- Kernel modules or deep OS integration

---

## Specific Use Cases

### Development Workflow
Keep the host minimal. Do all development inside Distrobox containers:

1. **Install BoxBuddy** from the app store (GUI for managing Distrobox)
2. **Create a dev container** with:
   - **Init system enabled** (for better compatibility)
   - **Separate home directory** (e.g., `~/Distrobox/dev`)
3. Install your toolchains inside (Node, Python, Rust, etc.)
4. Export apps to your host launcher when needed

**Multiple containers recommended:** Separate boxes for web, mobile, or game development to avoid dependency conflicts.

**Using Dev Containers?** If you need Podman inside a distrobox, create `~/.local/bin/podman`:
```bash
#!/bin/bash
distrobox-host-exec podman "$@"
```
This reuses the host's Podman instead of nesting containers.

### Running Windows Software
Install **Bottles** from the app store for Wine-based Windows app support. Handles games, productivity software, and 
modding tools without touching your base system.

### ASUS ROG Hardware Support
For ROG laptops (without kernel modules):

```bash
# Add repository
sudo dnf copr enable lukenukem/asus-linux

# Layer control software
sudo rpm-ostree override remove tuned-ppd \
  --install=asusctl \
  --install=asusctl-rog-gui \
  --install=power-profiles-daemon \
  --install=supergfxctl
reboot
```

---

**Quick Reference:**
- App → Flatpak
- CLI → Homebrew  
- Dev environment → Distrobox
- System/Hardware → `rpm-ostree install`
