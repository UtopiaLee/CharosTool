# Linux Toolbox Development Standards

## Bash Scripting Guidelines
- Use `set -euo pipefail` at the top of all scripts.
- Use `#!/usr/bin/env bash` for the shebang.
- Store reusable functions in `lib/`.
- All scripts must source `lib/common.sh` if needed.
- Use `logger` for logging errors and informational messages.
