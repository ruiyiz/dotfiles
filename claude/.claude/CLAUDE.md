## R

- The `box` package is not supposed to be attached. So, don't call `library(box)`. Instead, use the fully qualified function names when calling `box` functions.
- Don't use chaining calls with data.table.
- Avoid using readxl in the future, as it has performance issues, particularly in a WSL environment.

## Python

- Prefer uv for package and project management.
- Run pytest via `uv run python -m pytest`; `uv run pytest` fails with "Failed to spawn".
- ruff isort (I001): with default config (`combine-as-imports = false`), each aliased import requires its own line. Grouping aliases in one block triggers I001:
  - Wrong: `from foo import bar as _bar, baz as _baz`
  - Correct: `from foo import bar as _bar` / `from foo import baz as _baz`
- ruff E501 in docstrings: `# noqa: E501` inside a docstring does not suppress the error (the comment itself adds length). Wrap the line instead.
- Global git pre-commit hook at `~/.config/git/hooks/pre-commit` runs `ruff format` then `ruff check` on every staged `.py` file.

## JavaScript/TypeScript

- Prefer bun over npm for JavaScript/TypeScript projects.

## Data

- Prefer the CLI tool for duckdb interactions.

## Coding Style

- Add minimal comments.

## Writing Style

- Don't use em dashes in prose writing.

## Workflow

- When managing todos or tasks, use the `todo` CLI tool (see todo-cli skill).
