# bash-commands

A collection of useful bash command-line utilities that can be easily installed to your system.

## 📦 Installation

You can install all commands with a single command using curl:

```bash
curl -sSL https://raw.githubusercontent.com/hawkins-tech/bash-commands/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/hawkins-tech/bash-commands.git
cd bash-commands
sudo cp bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/{killgrep,always,execs}
```

## 🛠️ Available Commands

### killgrep

Kill processes by regex match on the process name (not full command line).

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
- `-h` - Show help

**Examples:**
```bash
killgrep node              # Kill all processes with "node" in the name
killgrep -n python         # Dry run: show what would be killed
killgrep -s KILL chrome    # Send SIGKILL to chrome processes
killgrep -x bash           # Exact match: only kill processes named exactly "bash"
killgrep -u www-data nginx # Kill nginx processes owned by www-data
```

### firstmatch

Read piped input, print the first matching line, then exit immediately.

Useful for waiting on streaming output until a specific line appears, then stopping the pipeline.

**Usage:**
```bash
firstmatch [options] pattern
````

**Options:**

* `-i, --ignore-case` - Case-insensitive matching
* `-F, --fixed-string` - Treat pattern as a literal string instead of regex
* `-v, --invert-match` - Match the first line that does not match the pattern
* `-n, --line-number` - Prefix output with the 1-based line number
* `-q, --quiet` - Do not print the line, just exit successfully on first match
* `-h, --help` - Show help

**Examples:**

```bash
tail -f app.log | firstmatch "server started"
journalctl -f -u nginx | firstmatch -i "ready"
some_command | firstmatch -F "exact text"
some_command | firstmatch -n "connected"
some_command | firstmatch -q "success"
some_command | firstmatch -v "^DEBUG"
```

**Exit codes:**

* `0` - A matching line was found
* `1` - No matching line was found before input ended
* `130` - Interrupted with `Ctrl+C`

### always

Keep running a command repeatedly until interrupted.

**Usage:**
```bash
always <command> [args...]
```

**Example:**
```bash
always curl https://api.example.com/health     # Keep trying until the API is up
always ping -c 1 192.168.1.1                   # Keep pinging until host responds
```

Press `Ctrl+C` to stop the loop.

### execs

List all executable files in your PATH.

**Usage:**
```bash
execs
```

**Example output:**
```
7z
bash
curl
docker
git
grep
ls
node
npm
python3
...
```

## 📝 Development

To add new commands:

1. Create a new bash script in the `bin/` directory
2. Make it executable: `chmod +x bin/yourcommand`
3. Add a shebang line: `#!/bin/bash`
4. Document it in this README

## 📄 License

MIT
