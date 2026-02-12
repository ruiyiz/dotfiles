---
description: Add interactive prompts to Quarto notebook for manual workflow execution
argument-hint: <source.qmd>
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
---

Add interactive prompts to a Quarto notebook (.qmd) for manual workflow execution, modifying the file in place.

## Target File

$ARGUMENTS

- Argument: Source .qmd file to modify (required)

## Helper Functions

The helper functions `wait_for_user()` and `prompt_execute()` are available in `utils/utils` module:

```r
box::use(utils/utils)

utils$wait_for_user("Message to display")
utils$prompt_execute("Description", function() { ... })
utils$prompt_select("Description:", c(label1 = "val1", label2 = "val2"))
```

## Chunk Conversion Rules

1. **Setup chunks**:
   - Ensure `utils/utils` is imported in `box::use()`
   - Add pipeline header: `message("=== Pipeline Name ===")`

2. **`eval: false` chunks** (optional execution):
   - Change `#| eval: false` to `#| eval: true` (or remove the line)
   - Wrap the chunk body in `utils$prompt_execute("Description", function() { ... })`
   - Use `<<-` for assignments that need to persist outside the function scope

3. **Hardcoded literal values** (e.g., `output_mode = "m"`, `target_year = 2024`):
   - Replace with `utils$prompt_select()` when there is a fixed set of valid choices
   - Display labels and validate selection; first choice is the default
   - Use named vectors for descriptive labels: `c("Monthly" = "m", "Quarterly" = "q")`
   - For free-form values (dates, numbers), use `readline()` with validation

4. **Boolean decision guards** (e.g., `if (save_excel) { ... }`):
   - Remove the boolean variable, its YAML param, and the `if` wrapper
   - `prompt_execute` replaces the guard -- the y/n prompt is the decision point
   - Remove the variable from dev/prod parameter blocks as well

5. **Manual intervention points** (comments like "open and revise", "export to Excel"):
   - Add `utils$wait_for_user("Description of what user should do before continuing")`
   - Place AFTER the action that opens/creates something, BEFORE code that depends on user completion
   - **`utils$open()` typically requires `wait_for_user()`** - whether opening a file for editing or a directory for user action, pause before proceeding, always add a wait
   - **Skip `wait_for_user` if the next action is `prompt_execute`** - the y/n prompt serves as the continue signal; instead, add a reminder to the prompt description (e.g., "Copy X - paste before continuing")

6. **Data checks** (print statements showing results):
   - Add header before print: `message("\n## Check Name")`

7. **Section boundaries** (markdown headers or major transitions):
   - Add section markers in code: `message("\n--- Section Name ---")`

## Patterns

### Prompted execution block

Before:
```r
#| eval: false
result = expensive_operation()
pins$write(result, "lib", "name")
```

After:
```r
utils$prompt_execute("Run expensive operation", function() {
  result <<- expensive_operation()
  pins$write(result, "lib", "name")
})
```

### Replacing hardcoded literal values

Before:
```r
## options: m, q, ytd, 1y
output_mode = "m"
```

After:
```r
output_mode = utils$prompt_select(
  "Select output mode:",
  c(m = "m", q = "q", ytd = "ytd", `1y` = "1y")
)
```

### Replacing boolean decision guards

Before:
```r
#| eval: false
if (save_excel) {
  write_output(result)
}
```

After:
```r
utils$prompt_execute("Save Excel output", function() {
  write_output(result)
})
```

Also remove the boolean from YAML params and the parameters chunk.

### File/directory open requiring user action

When `utils$open()` opens a file for editing or a directory for user action:

Before:
```r
#| eval: false

# DO: Update values and save
utils$open(data_sheet)
```

After:
```r
utils$open(data_sheet)
utils$wait_for_user("Update values, save and close the file.")
```

### Conditional prompts

Pre-conditions go OUTSIDE `utils$prompt_execute()` calls:

```r
if (nrow(missing) > 0) {
  utils$prompt_execute("Handle missing records", function() {
    # ... code ...
  })
}
```

### Clipboard operations

All `write_clipboard` operations copy then `wait_for_user`. Only the **first** is wrapped in `prompt_execute` (gateway decision to enter the clipboard workflow):

First clipboard operation:
```r
utils$prompt_execute("Start clipboard paste workflow", function() {
  data |> utils$write_clipboard()
  utils$wait_for_user("Paste to sheet!A1")
})
```

All subsequent:
```r
data |> utils$write_clipboard()
utils$wait_for_user("Paste to sheet!B1")
```

Loop:
```r
for (item in items) {
  data[Item == item] |> utils$write_clipboard()
  utils$wait_for_user(paste("Paste", item, "to tab"))
}
```

### Multi-stage workflows with external action

Use `wait_for_user` only when an external action (not just pasting) must complete:

```r
if (nrow(missing) > 0) {
  utils$prompt_execute("Stage 1: Generate template", function() {
    template_file <<- generate_template(...)
    message("Template generated: ", template_file)
  })

  utils$wait_for_user("Complete template manually, then continue.")

  utils$prompt_execute("Stage 2: Import template", function() {
    new_data = import_template(template_file)
    data <<- rbind(data, new_data)
  })
}
```

## What NOT to Change

- Keep all markdown content unchanged
- Keep chunk labels unchanged
- Keep other chunk options (e.g., `#| include: false`) unchanged
- Don't add prompts to chunks that should always run (setup, data loading without side effects)

## Execution

After modification, run the notebook interactively in RStudio/VS Code or via:
```bash
quarto render notebook.qmd --execute
```
