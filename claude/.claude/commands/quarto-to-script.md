---
description: Convert Quarto notebook (.qmd) to standalone R script with interactive prompts
argument-hint: <source.qmd> [target.R]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

Convert a Quarto notebook to a standalone R script with interactive prompts for manual workflow steps.

## Target Files

$ARGUMENTS

- First argument: Source .qmd file (required)
- Second argument: Target .R file (optional, defaults to same name with .R extension)

## Helper Functions

The helper functions `wait_for_user()` and `prompt_execute()` are available in `utils/utils` module:

```r
box::use(utils/utils)

utils$wait_for_user("Message to display")
utils$prompt_execute("Description", function() { ... })
```

## Console Output Strategy

- `message()` - Section headers, instructions, status messages
- `print()` - Data outputs (data.table, check results)
- `utils$wait_for_user()` - Pause for user input
- `utils$prompt_execute()` - Prompt Y/n before executing optional code

## Chunk Conversion Rules

1. **Setup chunks**: Keep imports, add pipeline header with `message("=== Pipeline Name ===")`

2. **Regular chunks**:
   - Add section headers: `message("\n--- Section Name ---")`
   - Add data check headers before print statements: `message("\n## Check Name")`

3. **Manual intervention points** (comments describing user actions like "Export to Excel"):
   - Add `utils$wait_for_user("Description of what user should do before continuing")`

4. **`eval: false` chunks**:
   - Wrap executable code blocks in `utils$prompt_execute("Description", function() { ... })`
   - Use `<<-` for assignments that need to persist outside the function scope
   - Remove `&& FALSE` guards from conditions - the prompt handles user confirmation

5. **Conditional prompts**:
   - Pre-conditions go OUTSIDE `utils$prompt_execute()` calls
   - Example: `if (nrow(missing) > 0) { utils$prompt_execute(...) }`

## Data Persistence Patterns

### Save queried data first (before checking for missing records)

```r
if (!pins$exists("lib", "symbol", snapshot)) {
  utils$prompt_execute("Save queried data to pins", function() {
    pins$append(data, "lib", "symbol", snapshot, key = c("key", "Snapshot"), overwrite = TRUE)
  })
}
```

### Handle missing records (inside condition block)

```r
if (nrow(missing) > 0) {
  utils$prompt_execute("Stage 1: Generate template", function() {
    template_file <<- generate_template(...)
    message("Template generated: ", template_file)
  })

  utils$wait_for_user("Complete template manually, then continue.")

  utils$prompt_execute("Stage 2: Import template", function() {
    new_data = import_template(template_file)
    print(new_data)
    data <<- rbind(data, new_data)
    message("Added ", nrow(new_data), " records")
  })

  utils$prompt_execute("Append new data to pins", function() {
    pins$append(data, "lib", "symbol", snapshot, key = c("key", "Snapshot"), overwrite = TRUE)
  })
}
```

### Delete before write (for full dataset replacement)

```r
utils$prompt_execute("Save data to pins", function() {
  if (pins$exists("lib", "symbol", snapshot)) {
    pins$delete("lib", "symbol", snapshot)
    message("Removed old snapshot")
  }
  pins$write(data, "lib", "symbol", snapshot)
  message("Data saved to pins")
})
```

## Output Structure

```r
#!/usr/bin/env Rscript

box::use(
  data.table[...],
  # ... other imports
  utils/pins,
  utils/utils
)

message("=== Pipeline Name ===")
message("Key info: ", value)

# --- Section 1 ---
message("\n--- Section 1 ---")
message("Instructions for manual steps...")
utils$wait_for_user("Ensure files are ready before continuing.")
# ... code ...

message("\n## Data Check")
print(check_result)

# --- Section 2 ---
message("\n--- Section 2 ---")
if (condition) {
  utils$prompt_execute("Optional operation", function() {
    # ... code ...
  })
}

message("\n=== Pipeline Complete ===")
```

## File Naming

- Source: `scripts/path/notebook.qmd`
- Target: `scripts/path/notebook.R`

Keep both files - the .qmd for interactive development, the .R for batch execution.
