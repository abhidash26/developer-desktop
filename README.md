# JARVIS Developer Environment

A minimal, keyboard-oriented developer environment for Ubuntu on WSL2, inspired by the restrained interface design of JARVIS.

The project combines a Git-aware Zsh prompt, fuzzy history search, useful shell aliases, and a live system monitor in a consistent dark, cyan-and-blue visual theme.

## Preview

![JARVIS Developer Environment terminal and system monitor](screenshots/jarvis-terminal.png)

## Features

- **JARVIS-inspired shell:** A cyan prompt label, current directory, and Git branch indicator.
- **Zsh configuration:** Reusable shell settings and shortcuts for navigation and common Git operations.
- **Fuzzy search:** fzf integration for interactive shell history search.
- **Live system monitor:** A terminal dashboard displaying CPU utilization, memory usage, battery status when available, uptime, and system time.
- **Configurable refresh:** Choose how frequently the live dashboard refreshes.
- **Setup script:** Installs the shell configuration and preserves a backup of an existing Zsh configuration.
- **Automated tests:** A shell test script checks expected system-monitor output.
- **Version-controlled setup:** Configuration, scripts, tests, and documentation are maintained in Git.

## Requirements

- Ubuntu on WSL2 or a compatible Linux environment.
- Bash and Git.
- Zsh and fzf.

The installer does not install operating-system packages. Install any missing dependencies using your distribution's package manager.

## Installation

Clone the repository:

```bash
git clone https://github.com/abhidash26/developer-desktop.git
cd developer-desktop
```

Run the installer:

```bash
chmod +x install.sh
./install.sh
```

Start Zsh:

```bash
zsh
```

The installer configures the shell and creates a `developer-status` command linked to the system-monitor script in the repository.

## Usage

### System status snapshot

Display a single system-status report:

```bash
developer-status
```

Alternatively, run the script directly from the repository:

```bash
./scripts/system-status.sh
```

### Live system monitor

Start the interactive dashboard:

```bash
developer-status --watch
```

Set a refresh interval in seconds:

```bash
developer-status --watch --interval 5
```

The default refresh interval is two seconds. Press `q` to exit the live monitor.

Display supported options:

```bash
developer-status --help
```

### What the monitor reports

- **CPU:** Utilization estimated by sampling Linux CPU counters.
- **Memory:** Used and total system memory, with a visual utilization bar.
- **Battery:** Battery percentage when the environment exposes battery information.
- **Uptime:** Time elapsed since the Linux environment started.
- **System time and hostname:** Context for the current monitoring session.

CPU readings are estimates and may vary between samples. Battery information may be unavailable in virtualized environments such as WSL2.

## Shell shortcuts and aliases

| Command | Purpose |
|---|---|
| `ll` | Detailed directory listing |
| `la` | Show hidden files |
| `c` | Clear the terminal |
| `..` | Move up one directory |
| `...` | Move up two directories |
| `gs` | Short Git status |
| `gl` | Show recent Git commits |
| `gd` | Show unstaged changes |
| `gp` | Pull from the configured Git remote |
| `Ctrl-R` | Fuzzy shell-history search when fzf integration is active |

## Configuration backup

Before replacing an existing `~/.zshrc`, the installer saves a backup at:

```text
~/.config/developer-desktop-backup/zshrc
```

The backup is created only if one does not already exist at that location. Keep a separate copy of any custom shell configuration you cannot afford to lose.

## Testing

Run the system-monitor test:

```bash
bash tests/test-system-status.sh
```

Check the shell configuration and script syntax:

```bash
zsh -n config/zshrc
bash -n scripts/system-status.sh
bash -n tests/test-system-status.sh
```

All checks should complete without syntax errors, and the test script should pass.

## Project structure

```text
developer-desktop/
├── config/
│   └── zshrc
├── docs/
├── screenshots/
│   └── jarvis-terminal.png
├── scripts/
│   └── system-status.sh
├── tests/
│   └── test-system-status.sh
├── install.sh
├── LICENSE
└── README.md
```

## Scope and limitations

The current implementation focuses on the shell and terminal workflow inside WSL2 or a compatible Linux environment. It does not yet independently configure a complete Linux desktop, window manager, application launcher, desktop status bar, or window decorations.

The terminal color scheme is configured separately in Windows Terminal. A fully integrated desktop environment would require additional components and configuration.

## License

Released under the MIT License. See [LICENSE](LICENSE).
