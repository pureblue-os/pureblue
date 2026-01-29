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
sudo bootc switch ghcr.io/pureblue-os/pureblue:stable
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

## Guide

### Using Distrobox (Highly Recommended)

On an immutable (atomic) system, the base OS is designed to stay clean and stable.
Instead of installing lots of software directly on the system, the recommended approach is to use **Distrobox**.

**Distrobox** lets you create normal Linux environments (such as Ubuntu or Debian) that run in containers on top of your system. Inside these environments, you can install software the traditional way—without risking your host OS.

Distrobox integrates very well with the system, including:

* GPU acceleration (including NVIDIA)
* Audio and networking
* Desktop integration (apps appear in your launcher)

For most users, it feels just like using a normal Linux system.

---

### BoxBuddy (Recommended)

**BoxBuddy** is a graphical tool that makes Distrobox easy to use and manage.
It is the recommended way to create and manage distroboxes, especially for beginners.

With BoxBuddy, you can:

* Create and delete distroboxes easily
* **Select a separate home folder during creation** (recommended)
* **Enable the init system during creation** (recommended for better compatibility)
* Install apps inside distroboxes
* Export apps so they appear in your host’s app launcher

Both **BoxBuddy** and **Bottles** are available from the **app store**.

**Tip:**
When creating a distrobox, it’s recommended to:

* Enable **Init System**
* Use a separate home directory, for example:

  ```
  ~/Distrobox/my-dev-pod
  ```

---

### Using Podman Inside Distrobox (Optional)

If you use tools like **Dev Containers** or need Podman inside a distrobox, it’s best to reuse the **host’s Podman** instead of installing another one inside the container.

To do this, create the following file **inside the distrobox**:

**`~/.local/bin/podman`**

```bash
#!/bin/bash
distrobox-host-exec podman "$@"
```

Then make it executable:

```bash
chmod +x ~/.local/bin/podman
```

If you’re not using containers for development yet, you can safely skip this step.

---

### Doing Development on an Atomic OS

For development work, the recommended workflow is simple:

* Keep the host OS minimal and stable
* Use **Distrobox** for development tools and SDKs

Ubuntu-based images are commonly recommended since many tools officially support Ubuntu.

Inside a distrobox, you can:

* Install programming languages and SDKs
* Use editors like VS Code or JetBrains IDEs
* Install compilers, build tools, and dependencies

You can also create **multiple distroboxes** for different purposes, such as:

* Web development
* Mobile app development
* Game development

This keeps everything organized and easy to remove later.

---

### What If an App Doesn’t Have a Flatpak?

That’s fine.

If an app isn’t available as a Flatpak or isn’t easy to install on an immutable system:

1. Install it inside a distrobox
2. Export it using BoxBuddy or the Distrobox CLI

Once exported, the app will show up in your normal app launcher and behave like a native app.

---

### Running Windows Apps

To run Windows apps or games, use **Bottles**.

Bottles provides an easy-to-use interface for Wine and makes installing Windows software much simpler.
Many apps and games work well, and with some tweaking, mods can also be installed.

Bottles is available from the **app store**.

---

### Final Tip

On pureblue, there is a **recommended order** for installing software.
Following this keeps your system clean, stable, and easy to update.

---

#### 1. Flatpak — **Desktop apps**

Use Flatpak for:

* Graphical desktop applications (Steam, Brave, Chrome)
* End-user tools from the app store

Flatpaks are sandboxed and safe, and they do not modify the base system.

> For IDEs (VSCode, JetBrains, etc), even if a Flatpak version exists, prefer Distrobox. IDEs work best in a full Linux environment where SDKs, toolchains, and container tools are not restricted.

---

#### 2. Homebrew — **CLI tools**

Use **Homebrew** for:

* Command-line tools
* Developer utilities
* Tools that don’t need system integration

Homebrew installs everything in user space and is ideal for tools like:

* `fastfetch`
* `deno` # To run typescript scripts.
* `kubectl`
* `terraform`
* `ripgrep`, `fd`, etc.

This is the preferred way to install CLI tools on pureblue.

---

#### 3. Distrobox — **When Flatpak or Brew aren’t enough**

Use Distrobox when:

* An app is not available as a Flatpak
* A CLI tool doesn’t exist in Homebrew
* You need a full Linux environment (e.g. language runtimes, SDKs, package managers)

If it doesn’t exist as a Flatpak **or** in Homebrew → use Distrobox.

> For IDEs (VSCode, JetBrains, etc), even if a Flatpak version exists, prefer Distrobox. IDEs work best in a full Linux environment where SDKs, toolchains, and container tools are not restricted.

---

#### 4. Package Layering — **System-level only**

Package layering should **never** be used for apps.

Only layer packages that must run on the host system, such as:

* Hardware control tools (e.g. `asusctl`, ASUS ROG control center)
* System services and daemons
  (e.g. `power-profiles-daemon`, `waydroid`)
* Software that requires deep OS or hardware integration

If it’s user-facing or something you launch manually, it does **not** belong on the host.

---

**Rule of thumb:**

> App → Flatpak
> CLI tool → Homebrew
> Dev -> Distrobox
> Not available → Distrobox
> System / hardware control → Package layering
