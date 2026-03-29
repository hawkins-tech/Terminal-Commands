# Terminal-Commands

A collection of useful command-line utilities that can be easily installed to your system.

## 📦 Installation

You can install all commands with a single command using curl:

```bash
curl -sSL https://raw.githubusercontent.com/hawkins-tech/Terminal-Commands/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/hawkins-tech/Terminal-Commands.git
sudo install -m +x Terminal-Commands/bin/* /usr/local/bin/
```

### AI Skill Installation

This repo is also a [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code). Install it so Claude knows how to use these commands:

```bash
npx skills add hawkins-tech/Terminal-Commands -g
```

## 🛠️ Available Commands

### Process & Port Management

#### killgrep

Kill processes by regex match on the full command line. Case-insensitive by default.

**Usage:**
```bash
killgrep [-s SIGNAL] [-I] [-x] [-n] [-u USER] pattern
```

**Options:**
- `-s SIGNAL` - Signal to send (default: TERM). Examples: HUP, INT, TERM, KILL, 9
- `-I` - Case-sensitive match (default is case-insensitive)
- `-C` - Alias for `-I` (case-sensitive match)
- `-x` - Exact match (treat pattern as a literal name)
- `-n` - Dry run (print matches without sending signals)
- `-u USER` - Only match processes owned by USER

**Examples:**
```bash
killgrep node              # Kill all processes with "node" in the name
killgrep -n python         # Dry run: show what would be killed
killgrep -s KILL chrome    # Send SIGKILL to chrome processes
killgrep -x bash           # Exact match: only kill processes named exactly "bash"
killgrep -u www-data nginx # Kill nginx processes owned by www-data
```

#### portowner

Show what process owns a TCP port as JSON. Optionally kill it.

**Usage:**
```bash
portowner [options] PORT
```

**Options:**
- `-k, --kill` - Kill the process owning the port
- `-s, --signal SIG` - Signal to send with --kill (default: TERM)
- `-u, --udp` - Check UDP instead of TCP

**Examples:**
```bash
portowner 3000             # JSON: pid, user, command, cmdline
portowner --kill 8080      # Kill whatever is on port 8080
portowner -k -s KILL 5432  # SIGKILL the process on 5432
```

#### waitport

Wait until a TCP port is accepting connections, then optionally run a command.

**Usage:**
```bash
waitport [options] HOST:PORT | PORT [-- command [args...]]
```

**Options:**
- `-t, --timeout SECS` - Maximum seconds to wait (default: 30, 0 = forever)
- `-i, --interval SECS` - Seconds between checks (default: 1)
- `-q, --quiet` - Suppress progress output

**Examples:**
```bash
waitport 3000                          # Wait for localhost:3000
waitport 3000 -- npm test             # Wait then run tests
waitport db:5432 -t 60                # Wait up to 60s for db:5432
```

#### waitpid

Wait for any process to exit (not just children of the current shell).

**Usage:**
```bash
waitpid [options] PID | -p PATTERN
```

**Options:**
- `-p, --pattern PAT` - Wait for process matching name pattern to exit
- `-t, --timeout SECS` - Maximum seconds to wait (default: 0 = forever)
- `-i, --interval SECS` - Seconds between checks (default: 1)
- `-q, --quiet` - Suppress progress output

**Examples:**
```bash
waitpid 1234                     # Wait for PID 1234 to exit
waitpid -p "webpack" -t 60      # Wait up to 60s for webpack to exit
waitpid -p "npm test" -q        # Quietly wait for npm test to finish
```

#### portfree

Find an available TCP port in a range. Prints the port number to stdout.

**Usage:**
```bash
portfree [START[-END]]
```

**Examples:**
```bash
portfree                # Find any free port in 3000-9999
portfree 8000-8100      # Find a free port in 8000-8100
portfree 3000           # Check if 3000 is free
```

### System Introspection

#### syssnap

Output a JSON snapshot of system health: CPU, memory, disk, load, top processes.

**Usage:**
```bash
syssnap [--pretty]
```

**Example:**
```bash
syssnap --pretty        # Pretty-printed JSON
```

Output includes: `cpu_percent`, `cpu_count`, `memory` (total/used/available), `disk` (per mount), `load` (1/5/15 min), `uptime`, `top_by_cpu`, `top_by_mem`.

#### gitstat

Output a JSON summary of the current git repository state.

**Usage:**
```bash
gitstat [--pretty]
```

**Example:**
```bash
gitstat --pretty        # Pretty-printed JSON
```

Output includes: `branch`, `sha`, `message`, `author`, `dirty`, `staged`, `unstaged`, `untracked`, `conflicts`, `ahead`, `behind`, `stashes`, `remoteUrl`, `detached`.

#### envdump

JSON dump of the current environment: OS, shell, PATH, tool versions, environment variables.

**Usage:**
```bash
envdump [--pretty]
```

**Example:**
```bash
envdump --pretty        # Pretty-printed JSON
```

Output includes: `os` (system/release/distro), `shell`, `path_entries`, `package_managers`, `tools` (version strings for node, python, go, rust, docker, etc.), `env`.

#### diskwhy

Show what's using disk space under a path, sorted by size.

**Usage:**
```bash
diskwhy [options] [PATH]
```

**Options:**
- `-n, --top N` - Show top N entries (default: 20)
- `-f, --files` - Also show largest individual files
- `-d, --depth N` - Directory depth for scan (default: 1)
- `-j, --json` - JSON output
- `-p, --pretty` - Pretty-print JSON

**Examples:**
```bash
diskwhy                    # Current directory, human-readable
diskwhy /var -n 10         # Top 10 entries under /var
diskwhy -f /home           # Include largest individual files
diskwhy --json --pretty    # JSON output
```

### File Operations

#### trash

Move files to XDG recoverable trash instead of permanent deletion.

**Usage:**
```bash
trash PATH [PATH...]           # Move files/directories to trash
trash list                     # List items in trash
trash restore NAME [NAME...]   # Restore items to original location
trash empty [-f]               # Permanently delete all trash
```

**Examples:**
```bash
trash file.txt dir/            # Move to trash
trash list                     # See what's in trash
trash restore file.txt         # Restore to original location
trash empty                    # Permanently delete all trash
```

#### secure_delete

Securely delete files using DoD 5220.22-M overwriting standard with threaded processing.

Overwrites files with patterns (zeros → ones → random) for configurable cycles, scrubs filenames from filesystem journals, and optionally zeros free space to prevent recovery.

**Usage:**
```bash
secure_delete [options] PATH [PATH ...]
```

**Options:**
- `-p, --passes N` - DoD overwrite cycles (default: 1, 0 = infinite until killed)
- `-t, --threads N` - Worker threads (default: CPU count)
- `-r, --recursive` - Recurse into directories
- `--skip-free-space-wipe` - Skip zeroing free space after deletion
- `-v, --verbose` - Per-file progress output
- `-q, --quiet` - Suppress all output

**Examples:**
```bash
secure_delete /path/to/file                    # Securely delete a single file
secure_delete -r /path/to/directory            # Recursively delete directory contents
secure_delete -p 3 /path/to/sensitive/file     # Use 3 DoD cycles instead of 1
secure_delete -r --skip-free-space-wipe /tmp   # Delete without free space wipe (faster)
```

**Signal handling:**
- 1st `SIGINT`/`SIGTERM` - Stop overwriting, proceed to delete and free-space wipe
- 2nd signal - Skip free-space wipe
- 3rd signal - Force exit immediately

#### checkpoint

Create named snapshots of files/directories for easy undo.

**Usage:**
```bash
checkpoint save NAME PATH [PATH...]    # Save a named snapshot
checkpoint restore NAME [DEST]         # Restore a snapshot
checkpoint list                        # List all saved checkpoints
checkpoint show NAME                   # Show contents of a checkpoint
checkpoint delete NAME                 # Delete a checkpoint
checkpoint diff NAME [PATH]            # Diff a checkpoint against current state
```

**Examples:**
```bash
checkpoint save before-refactor ./src
checkpoint restore before-refactor
checkpoint diff before-refactor ./src
checkpoint list
checkpoint delete before-refactor
```

#### batchrename

Bulk rename files using regex substitution. Dry-run by default for safety.

**Usage:**
```bash
batchrename [options] PATTERN REPLACEMENT [PATH...]
```

**Options:**
- `-x, --execute` - Actually rename files (default is dry-run)
- `-r, --recursive` - Process directories recursively
- `-i, --ignore-case` - Case-insensitive pattern matching
- `--lower` / `--upper` - Convert filenames to lowercase/uppercase
- `--seq PREFIX N` - Sequential rename: PREFIX001, PREFIX002, ...
- `--ext EXT` - Only process files with this extension

**Examples:**
```bash
batchrename 'IMG_(\d+)' 'photo_\1' .          # Dry run: IMG_001.jpg → photo_001.jpg
batchrename -x 'IMG_(\d+)' 'photo_\1' .       # Actually rename
batchrename --lower '' '' ./documents          # Preview lowercase conversion
batchrename -x --lower '' '' ./documents       # Lowercase all filenames
batchrename --seq photo 1 ./images             # Preview photo001.jpg, photo002.jpg, ...
batchrename -x -r --ext .txt '\.txt$' '.md' .  # Rename .txt to .md
```

### Streaming & Looping

#### firstmatch

Read piped input, print the first matching line, then exit immediately.

Useful for waiting on streaming output until a specific line appears, then stopping the pipeline.

**Usage:**
```bash
firstmatch [options] pattern
```

**Options:**
- `-i, --ignore-case` - Case-insensitive matching
- `-F, --fixed-string` - Treat pattern as a literal string instead of regex
- `-v, --invert-match` - Match the first line that does not match the pattern
- `-n, --line-number` - Prefix output with the 1-based line number
- `-q, --quiet` - Do not print the line, just exit successfully on first match

**Examples:**
```bash
tail -f app.log | firstmatch "server started"
journalctl -f -u nginx | firstmatch -i "ready"
some_command | firstmatch -F "exact text"
some_command | firstmatch -q "success"
some_command | firstmatch -v "^DEBUG"
```

**Exit codes:**
- `0` - A matching line was found
- `1` - No matching line was found before input ended
- `130` - Interrupted with `Ctrl+C`

#### always

Keep running a command repeatedly until interrupted.

**Usage:**
```bash
always <command> [args...]
```

**Examples:**
```bash
always curl https://api.example.com/health     # Keep trying until the API is up
always ping -c 1 192.168.1.1                   # Keep pinging until host responds
```

Press `Ctrl+C` to stop the loop.

#### execs

List all executable files in your PATH, sorted and deduplicated.

**Usage:**
```bash
execs
```

## 📝 Development

To add new commands:

1. Create a new script in the `bin/` directory (bash preferred, python3 when needed)
2. Make it executable: `chmod +x bin/yourcommand`
3. Document it in this README
4. Add it to `SKILL.md` so AI agents know how to use it

## 📄 License

This project is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](LICENSE).
