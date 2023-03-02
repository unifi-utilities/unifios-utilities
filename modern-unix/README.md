# Modern Unix tools for the UDM

## Features

[Modern Unix tools](https://github.com/ibraheemdev/modern-unix) to make the UDM shell more pleasant
and modern:

- [bat](https://github.com/sharkdp/bat): A `cat` clone with syntax highlighting and Git integration.
- [bottom](https://github.com/ClementTsang/bottom): Yet another cross-platform graphical
  process/system monitor.
- [croc](https://github.com/schollz/croc): Easily and securely send things from one computer to another 🐊 📦
- [duf](https://github.com/muesli/duf): A better `df` alternative.
- [gping](https://github.com/orf/gping): `ping`, but with a graph.
- [ncdu](https://dev.yorhel.nl/ncdu): Ncdu is a disk usage analyzer with an ncurses interface.
- [lsd](https://github.com/Peltoche/lsd): The next gen file listing command. Backwards compatible with `ls`.
- [xh](https://github.com/ducaale/xh): A friendly and fast tool for sending HTTP requests.
  It reimplements as much as possible of HTTPie's excellent design, with a focus on improved performance.

## Demo

[![asciicast](https://asciinema.org/a/e2E1x0QilIvOgSy2N4dKSWwJ8.svg)](https://asciinema.org/a/e2E1x0QilIvOgSy2N4dKSWwJ8)

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## Steps

1. You may copy the files in `on_boot.d/`, `scripts/`, and `settings/` to `/data/` in the UDM, or you can
   use the Makefile targets to copy and install the tools from a remote machine:

   ```sh
   make push-config install-tools
   ```
