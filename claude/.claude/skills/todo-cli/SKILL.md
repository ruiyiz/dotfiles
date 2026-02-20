---
name: todo-cli
description: Manage todos and task lists using the local `todo` CLI tool. Use when the user asks to add, edit, complete, delete, or view tasks and todos.
user-invocable: false
allowed-tools: Bash, Read
---

# Todo CLI

`todo` is a local CLI tool for task management backed by SQLite (`~/.local/share/todo/todo.db`). Use it whenever the user asks to manage todos, tasks, or checklists.

## Commands

### `todo today`

Shows today's agenda: overdue items, items due today, upcoming (rest of week), and prioritized items.

### `todo show [filter]`

List todos with optional filter. Without a filter, shows active todos from the default list.

**Filters:** `today`, `tomorrow`, `week`, `overdue`, `upcoming`, `done`/`completed`, `all`, `prioritized`, or any natural language date ("next friday", `YYYY-MM-DD`).

**Options:**
- `-l, --list <name>` -- filter by list (name or numeric ID)

Results are indexed; subsequent commands can reference todos by index (e.g., `todo edit 1`).

### `todo add [title]`

**Options:**
- `--title <title>` -- alternative to positional arg
- `--list <name>` -- target list (default: "Todos")
- `--due <date>` -- natural language date ("tomorrow", "next friday", "Jan 15")
- `--priority <level>` -- `normal` (default), `prioritized`
- `--notes <notes>` -- supports `\n` for multi-line (e.g., `--notes 'line1\nline2'`)

```bash
todo add "Review PR" --priority prioritized --due tomorrow
todo add "Quarterly report" --list Work --due "next friday"
todo add "Groceries" --notes 'milk\nbread\neggs'
```

### `todo edit <id>`

**Options:**
- `--title <title>`
- `--list <name>` -- move to different list
- `--due <date>` -- natural language date
- `--clear-due` -- remove due date
- `--priority <level>` -- `normal`, `prioritized`
- `--notes <notes>` -- supports `\n` for multi-line
- `--complete` / `--incomplete`

```bash
todo edit 1 --title "Buy oat milk" --due friday
todo edit 3 --complete
```

### `todo complete [ids...]`

Mark one or more todos complete. `--dry-run` to preview.

```bash
todo complete 1 2 3
```

### `todo delete [ids...]`

Delete todos. `--force` skips confirmation. `--dry-run` to preview.

```bash
todo delete 1 --force
todo delete 1 2 3 --force
```

### `todo get <id>`

Show full detail for a single todo (all fields including notes and timestamps).

### `todo list [name]`

Without args: show all lists with counts. With a name:
- `--create` -- create list
- `--rename <new>` -- rename list
- `--delete` -- delete list and its todos (`--force` to skip confirmation)
- `--id <number>` -- reassign numeric ID

```bash
todo list
todo list Work --create
todo list Work --rename Job
```

### `todo status`

Database path, total/completed/overdue counts, number of lists.

## Global Options

`-j, --json` | `--plain` (tab-separated) | `-q, --quiet` | `--no-color` | `--no-input`

## ID Resolution

Todos are referenced by: (1) numeric index from last `show`/`today`, (2) full UUID, or (3) unambiguous UUID prefix. Always run `show`/`today` first to populate the index.

**IMPORTANT: Numeric indices are global and ephemeral.** Any `todo show` or `todo today` call reassigns all indices across the entire database. Running `todo show -l "List A"` then `todo show -l "List B"` invalidates the indices from List A. This means:
- When operating on a single list, use numeric indices freely after a `show` on that list.
- When operating across multiple lists, use `--json` to extract UUID prefixes and reference tasks by UUID prefix instead of numeric index. Example:

```bash
todo show -l "My List" --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for t in data:
    print(f\"{t['id'][:8]}  {t['title']}\")
"
# Then use UUID prefixes: todo complete abc12345
```

## Usage Notes

- Always use `--force` with `delete` to avoid interactive prompts that block execution.
- Use `--json` when you need to parse output programmatically.
- Run `todo show` or `todo today` before commands that take `<id>` so numeric indices are populated.
- Due dates accept natural language via chrono-node: "tomorrow", "next friday", "in 3 days", "Dec 25", etc.
- When batch-ingesting tasks from a file, add all tasks first (parallelizable), then use `--json` to get UUIDs, then mark completed tasks using UUID prefixes.
