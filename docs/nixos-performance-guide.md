# NixOS Performance System - Usage Guide

This guide covers the basics of the performance-focused configuration in this repo.

## Gaming launch options

Use one of the following in Steam launch options:

- `gamemoderun mangohud PROTON_ENABLE_NVAPI=1 %command%` (recommended for sim racing)
- `gamemoderun PROTON_LOG=1 %command%` (troubleshooting)
- `gamemoderun PROTON_USE_WINED3D=1 %command%` (older titles)

## Handy scripts

The following script is installed into `~/.local/bin`:

- `perf-report`: prints a quick status report of governors, I/O scheduler, huge pages, and GPU stats.

## MangoHud

MangoHud is configured at `~/.config/MangoHud/MangoHud.conf` with FPS, CPU, GPU, and memory stats enabled.
