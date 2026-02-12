# Todo CLI Reference

`todo` is a local CLI tool for task management backed by SQLite (`~/.local/share/todo/todo.db`).

## Commands

### `todo today`
Shows today's agenda: overdue, due today, upcoming 7 days, and high-priority items.

### `todo show [filter]`
List todos with optional filter. Without a filter, shows active todos from the default list.

Filters: `today`, `tomorrow`, `week`, `overdue`, `upcoming`, `done`/`completed`, `all`, `high`, `medium`, `low`, or any natural language date ("next friday", `YYYY-MM-DD`).

Options:
- `-l, --list <name>` -- filter by list (name or numeric ID)

Results are indexed; subsequent commands can reference todos by index (e.g., `todo edit 1`).

### `todo add [title]`
Options:
- `--title <title>` -- alternative to positional arg
- `--list <name>` -- target list (default: "Todos")
- `--due <date>` -- natural language date
- `--priority <level>` -- `none` (default), `low`, `medium`, `high`
- `--notes <notes>`

### `todo edit <id>`
Options:
- `--title <title>`
- `--list <name>` -- move to different list
- `--due <date>`
- `--clear-due`
- `--priority <level>` -- `none`, `low`, `medium`, `high`
- `--notes <notes>`
- `--complete` / `--incomplete`

### `todo complete [ids...]`
Mark one or more todos complete. `--dry-run` to preview.

### `todo delete [ids...]`
Delete todos. `--force` skips confirmation. `--dry-run` to preview.

### `todo get <id>`
Show full detail for a single todo (all fields including notes and timestamps).

### `todo list [name]`
Without args: show all lists with counts. With a name:
- `--create` -- create list
- `--rename <new>` -- rename list
- `--delete` -- delete list and its todos (`--force` to skip confirmation)
- `--id <number>` -- reassign numeric ID

### `todo status`
Database path, total/completed/overdue counts, number of lists.

## Global Options
`-j, --json` | `--plain` (tab-separated) | `-q, --quiet` | `--no-color` | `--no-input`

## ID Resolution
Todos are referenced by: (1) numeric index from last `show`/`today`, (2) full UUID, or (3) unambiguous UUID prefix. Always run `show`/`today` first to populate the index.
