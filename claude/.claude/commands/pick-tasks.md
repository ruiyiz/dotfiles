# Pick Tasks

Suggest and manage daily task priorities from a task file.

## Arguments

- `$ARGUMENTS`: Path to the task file (defaults to `@wip/toc-2026.md` if not provided)

## Category Codes

Headers contain unique codes in backticks (e.g., `` `A1` ``). When moving tasks to WIP, prefix them with their sub-category code in brackets (e.g., `[A1]`). Use this code to return tasks to their original location.

## Priority Levels

Tasks are prioritized by emoji markers:
- `🔺` = Highest priority
- `⏫` = Higher priority
- `🔼` = High priority
- No marker = Normal priority

## Steps

### 1. Read the Task File

Read the specified task file (or default). Parse:
- The WIP section (marked by `## WIP` after References)
- Category headers (`##`) with their codes in backticks
- Sub-category headers (`###`) with their codes in backticks
- Tasks with embedded `[code]` prefixes in WIP

### 2. Handle Existing WIP Tasks

If there are tasks in the WIP section:
- Ask the user: "You have tasks in WIP. Do you want to: (a) Clear them back to their categories first, (b) Keep them and add more, (c) Cancel"
- If clearing: Move each task back to its original sub-category based on the `[XX]` prefix, removing the prefix when moving back. Match the code to the sub-category header containing that code.

### 3. Ask About Focus Area

Parse all category (`##`) and sub-category (`###`) headers with codes from the file. Present them as a hierarchical choice list:
- List each category and its sub-categories
- Add "All categories" as an option

Example format:
```
A   Quantitative Research & Risk
A1  - Model Portfolios & Overlay
A2  - Risk Committee & Dashboards
...
B   Investment Research & Coverage
B1  - Current EM Coverage
...
```

User can select a category (e.g., `A`) or a specific sub-category (e.g., `A1`).

### 4. Scan and Rank Tasks

**Priority tasks (global):** First, scan ALL categories for tasks with priority markers (🔺, ⏫, 🔼). Always include the highest-priority task in suggestions, regardless of focus area selected.

**Focus area tasks:** From the selected category/sub-category, collect incomplete tasks (`- [ ]`). Rank by:
1. Priority emoji (🔺 > ⏫ > 🔼 > none)
2. Position in file (earlier = higher priority within same level)

Skip nested sub-tasks (lines starting with `\t- [ ]`).

### 5. Suggest Three Tasks

Build the suggestion list:
1. If a global priority task exists outside the focus area, include it first
2. Fill remaining slots with top tasks from the focus area

Present as a numbered choice list. Include:
- The task text
- Its sub-category name and code
- Its priority level (if any)

Ask: "Select tasks to work on today (you can pick 1-3):"

### 6. Move to WIP

For each selected task:
1. Add the sub-category code prefix (e.g., `[A1]`) to the task text
2. Remove the task from its original location (including any nested sub-tasks)
3. Add the task to the `## WIP` section
4. If the `## WIP` section doesn't exist, create it after `## References` and before the `---`

### 7. Confirm

Show the user the updated WIP section and confirm the changes.

## WIP Section Format

```markdown
## References
...

## WIP

- [ ] [D] Self review 2025 by 1/30 🔺
- [ ] [A1] Task from Model Portfolios & Overlay

---

## Quantitative Research & Risk `A`
...
```
