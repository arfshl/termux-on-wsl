# Termux on WSL
[EXPERIMENTAL] Termux environment running on WSL

[![Build](https://github.com/arfshl/termux-on-wsl/actions/workflows/build.yml/badge.svg)](https://github.com/arfshl/termux-on-wsl/actions/workflows/build.yml)

![screenshot](https://github.com/arfshl/termux-on-wsl/raw/main/image1.png)
![screenshot](https://github.com/arfshl/termux-on-wsl/raw/main/image2.png)

### [Download](https://github.com/arfshl/termux-on-wsl/releases)

## Requirements
* x86_64 or aarch64 based processors
* Windows Subsystem for Linux feature is enabled.

## Install
#### 1. [Download here](https://github.com/arfshl/termux-on-wsl/releases)

#### 2. Double-click the .wsl file to install it with default name

#### 3. Or install from elevated cmd to customize the name

     wsl --install --from-file <path>/termux-wsl-amd64.wsl --name <machine-name>

#### 4. Initial setup

- Start the Termux WSL from start menu shortcut
- Then execute the wsl.sh script to set-up proper environment and start the terminal session with this command:

      /system/bin/sh wsl.sh

#### 5. Start the termux terminal (must do for every terminal session)
There are 2 way starting the proper terminal session on termux wsl

1. With the wsl.exe command from cmd/powershell session (bring you directly to termux terminal session)

       wsl -d termux -- bash /wsl.sh
       wsl -d termux-pacman -- bash /wsl.sh

2. With start menu shortcut (manually execute wsl.sh script)

- After termux WSL window launched, run this command:

       sh wsl.sh

# Known Issues

- `ping` doesn't work with regular user (must run as root, execute `wsl-root.sh` instead of `wsl.sh` for login as root. But you can't run `pkg`, `apt` or `pacman` package manager as root on termux)
- No access to Windows filesystem (drive C:, D: or others), as `drvfs` is not supported