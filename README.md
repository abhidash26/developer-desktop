# Developer Desktop

A reproducible, keyboard-oriented developer environment for Ubuntu on WSL2.

## Features

- Automated installation of a personal Zsh configuration.
- Short Git and navigation aliases.
- Fuzzy history search with fzf.
- CPU, memory and battery status reporting.
- A setup script that backs up an existing Zsh configuration.
- A portable project structure managed with Git.

## Requirements

- Ubuntu on WSL2 or a compatible Linux environment.
- Bash and Git.
- Zsh and fzf for the configured shell workflow.

The installer does not install operating-system packages. Install missing
dependencies separately using your distribution's package manager.

## Installation

Clone this repository, enter the project directory, and run:

    chmod +x install.sh
    ./install.sh

Start Zsh:

    zsh

Run the system monitor:

    ~/.local/bin/developer-status

The installer saves an existing ~/.zshrc to
~/.config/developer-desktop-backup/zshrc before replacing it, if a backup
does not already exist.

## Shortcuts

| Command | Purpose |
| --- | --- |
| `ll` | Detailed directory listing |
| `la` | Show hidden files |
| `c` | Clear the terminal |
| `gs` | Short Git status |
| `gl` | Recent Git commits |
| `Ctrl-R` | Fuzzy history search, when fzf integration is active |

## System monitor

The monitor reads Linux system interfaces to calculate CPU and memory usage.
It checks whether battery information is exposed by the environment and
reports when it is unavailable.

CPU utilization is sampled over a one-second interval. Values may vary
between runs.

## Environment and limitations

This project currently targets the shell and terminal workflow inside WSL2.
It does not independently configure a Linux window manager, desktop launcher,
status bar, or window decorations. Those features require a compatible Linux
desktop environment and additional configuration.

## Project structure

    config/zshrc
    scripts/system-status.sh
    install.sh
    README.md
    LICENSE

## Testing

Run the monitor with:

    ./scripts/system-status.sh

Check shell configuration syntax with:

    zsh -n config/zshrc

## License

MIT

## Preview

![JARVIS Developer Environment terminal and system monitor](screenshots/jarvis-terminal.png)

The terminal uses a dark graphite background with cyan and blue accents,
a Git-aware Zsh prompt, and a lightweight system monitor for CPU, memory,
battery, and uptime.
