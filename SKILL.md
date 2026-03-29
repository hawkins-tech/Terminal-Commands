---
name: terminal-commands
description: "Collection of terminal CLI utilities for AI agents and developers on Linux. Use this skill whenever the user needs to: kill processes by name/pattern (killgrep), find what owns a port (portowner), wait for a port to be ready (waitport), wait for a process to exit (waitpid), find a free port (portfree), get system health as JSON (syssnap), get git repo state as JSON (gitstat), dump environment info as JSON (envdump), find what uses disk space (diskwhy), safely delete files to trash (trash), securely wipe files (secure_delete), create file snapshots for undo (checkpoint), bulk rename files (batchrename), match first line in a stream (firstmatch), retry a command forever (always), or list PATH executables (execs). Also use when the user mentions port conflicts, service readiness, process monitoring, system diagnostics, disk usage analysis, recoverable deletion, file snapshots, batch file renaming, regex process matching, streaming log matching, or JSON system introspection."
version: 1.1.0
---

# Terminal Commands

A collection of CLI utilities for Linux. Use these commands directly in Bash tool calls.

## Installation

Before using these commands, check if they are available by running `which killgrep`. If not installed, install with:

```bash
curl -sSL https://raw.githubusercontent.com/hawkins-tech/Terminal-Commands/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/hawkins-tech/Terminal-Commands.git
sudo install -m +x Terminal-Commands/bin/* /usr/local/bin/
```

---

## Process & Port Management

### killgrep

Kill processes by regex match on the full command line. Case-insensitive by default.

```
killgrep [-s SIGNAL] [-I] [-x] [-n] [-u USER] pattern
```

- `-s SIGNAL` — Signal to send (default: TERM)
- `-I` or `-C` — Case-sensitive match
- `-x` — Exact literal match
- `-n` — Dry run
- `-u USER` — Only match processes owned by USER

```bash
killgrep node              # Kill all "node" processes
killgrep -n python         # Dry run
killgrep -s KILL chrome    # SIGKILL
```

### portowner

Show what process owns a TCP port as JSON. Optionally kill it.

```
portowner [options] PORT
```

- `-k, --kill` — Kill the process on the port
- `-s, --signal SIG` — Signal to send with --kill (default: TERM)
- `-u, --udp` — Check UDP instead of TCP

```bash
portowner 3000             # JSON: pid, user, command, cmdline
portowner --kill 8080      # Kill whatever is on port 8080
portowner -k -s KILL 5432  # SIGKILL the process on 5432
```

### waitport

Wait until a TCP port is accepting connections, then optionally run a command.

```
waitport [options] HOST:PORT | PORT [-- command [args...]]
```

- `-t, --timeout SECS` — Max wait (default: 30, 0 = forever)
- `-i, --interval SECS` — Check interval (default: 1)
- `-q, --quiet` — Suppress output

```bash
waitport 3000                          # Wait for localhost:3000
waitport 3000 -- npm test             # Wait then run tests
waitport db:5432 -t 60                # Wait for remote db
```

### waitpid

Wait for any process to exit (not just children of current shell).

```
waitpid [options] PID | -p PATTERN
```

- `-p, --pattern PAT` — Match process by name pattern
- `-t, --timeout SECS` — Max wait (default: 0 = forever)
- `-q, --quiet` — Suppress output

```bash
waitpid 1234                     # Wait for PID 1234
waitpid -p "webpack" -t 60      # Wait for webpack to exit
```

### portfree

Find an available TCP port. Prints the port number to stdout.

```
portfree [START[-END]]
```

```bash
portfree                # Free port in 3000-9999
portfree 8000-8100      # Free port in 8000-8100
```

---

## System Introspection

### syssnap

JSON snapshot of system health: CPU, memory, disk, load, top processes.

```
syssnap [--pretty]
```

```bash
syssnap                 # Compact JSON
syssnap --pretty        # Pretty-printed
```

Output fields: `cpu_percent`, `cpu_count`, `memory`, `disk`, `load`, `uptime`, `top_by_cpu`, `top_by_mem`.

### gitstat

JSON summary of git repository state.

```
gitstat [--pretty]
```

```bash
gitstat                 # Compact JSON
gitstat --pretty        # Pretty-printed
```

Output fields: `branch`, `sha`, `message`, `author`, `dirty`, `staged`, `unstaged`, `untracked`, `conflicts`, `ahead`, `behind`, `stashes`, `remoteUrl`, `detached`.

### envdump

JSON dump of environment: OS, shell, PATH, tool versions, env variables.

```
envdump [--pretty]
```

```bash
envdump                 # Compact JSON
envdump --pretty        # Pretty-printed
```

Output fields: `os`, `shell`, `path_entries`, `package_managers`, `tools`, `env`.

### diskwhy

Show what's using disk space under a path, sorted by size.

```
diskwhy [options] [PATH]
```

- `-n, --top N` — Show top N entries (default: 20)
- `-f, --files` — Also show largest individual files
- `-d, --depth N` — Directory depth (default: 1)
- `-j, --json` — JSON output
- `-p, --pretty` — Pretty-print JSON

```bash
diskwhy                    # Current directory, human-readable
diskwhy /var -n 10         # Top 10 under /var
diskwhy -f -j --pretty .   # JSON with largest files
```

---

## File Operations

### trash

Move files to XDG recoverable trash instead of permanent deletion.

```
trash PATH [PATH...]           # Move to trash
trash list                     # List trash contents
trash restore NAME [NAME...]   # Restore to original location
trash empty [-f]               # Permanently delete all trash
```

```bash
trash file.txt dir/            # Move to trash
trash list                     # See what's in trash
trash restore file.txt         # Restore original
```

### secure_delete

Securely wipe files using DoD 5220.22-M overwriting (zeros, ones, random). Multi-threaded.

```
secure_delete [options] PATH [PATH ...]
```

- `-p, --passes N` — Overwrite cycles (default: 1, 0 = infinite)
- `-t, --threads N` — Worker threads (default: CPU count)
- `-r, --recursive` — Recurse into directories
- `--skip-free-space-wipe` — Skip free space zeroing
- `-v, --verbose` / `-q, --quiet`

```bash
secure_delete /path/to/file                     # Securely delete
secure_delete -r /path/to/directory             # Recursive
secure_delete -p 3 /path/to/sensitive/file      # 3 DoD cycles
```

### checkpoint

Create named snapshots of files/directories for easy undo.

```
checkpoint save NAME PATH [PATH...]    # Save snapshot
checkpoint restore NAME [DEST]         # Restore snapshot
checkpoint list                        # List all checkpoints
checkpoint show NAME                   # Show checkpoint contents
checkpoint delete NAME                 # Delete checkpoint
checkpoint diff NAME [PATH]            # Diff against current state
```

```bash
checkpoint save before-refactor ./src
checkpoint restore before-refactor
checkpoint diff before-refactor ./src
```

### batchrename

Bulk rename files with regex substitution. Dry-run by default for safety.

```
batchrename [options] PATTERN REPLACEMENT [PATH...]
```

- `-x, --execute` — Actually rename (default is dry-run)
- `-r, --recursive` — Process recursively
- `-i, --ignore-case` — Case-insensitive matching
- `--lower` / `--upper` — Case conversion mode
- `--seq PREFIX N` — Sequential numbering mode
- `--ext EXT` — Only process files with extension

```bash
batchrename 'IMG_(\d+)' 'photo_\1' .          # Dry run preview
batchrename -x 'IMG_(\d+)' 'photo_\1' .       # Execute rename
batchrename --lower '' '' ./documents          # Preview lowercase
batchrename -x -r --ext .txt '\.txt$' '.md' .  # Rename .txt to .md
```

---

## Streaming & Looping

### firstmatch

Read piped input, print the first matching line, then exit.

```
command | firstmatch [options] pattern
```

- `-i, --ignore-case` — Case-insensitive
- `-F, --fixed-string` — Literal string match
- `-v, --invert-match` — Match first NON-matching line
- `-n, --line-number` — Prefix with line number
- `-q, --quiet` — Exit without printing

```bash
tail -f app.log | firstmatch "server started"
journalctl -f -u nginx | firstmatch -i "ready"
```

### always

Retry a command repeatedly with 1-second delay until Ctrl+C.

```
always <command> [args...]
```

```bash
always curl https://api.example.com/health
always ping -c 1 192.168.1.1
```

### execs

List all executables in PATH, sorted and deduplicated. One per line.

```
execs
```
