## R

- The `box` package is not supposed to be attached. So, don't call `library(box)`. Instead, use the fully qualified function names when calling `box` functions.
- Don't use chaining calls with data.table.
- Avoid using readxl in the future, as it has performance issues, particularly in a WSL environment.

## Python

- Prefer uv for package and project management.

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
