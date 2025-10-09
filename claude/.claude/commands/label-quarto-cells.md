---
description: Label code cells in Quarto files with descriptive, lowercase, dash-delimited names
argument-hint: [file1.qmd file2.qmd ...]
allowed-tools:
  - Bash
  - EditFile
  - ReadFiles
---

You are tasked with labeling code cells in Quarto (.qmd) files.

## Target Files

$ARGUMENTS

If no arguments are provided, process the current file in the conversation context or the file being edited in the IDE.

## Code Cell Labeling Rules

1. Each code cell should have a `label` option in its header using the format: `#| label: name`
2. Label naming convention:
   - **All lowercase**
   - **Dash-delimited** (use `-` between words)
   - **Descriptive one-word or compound names**
   - Examples: `setup`, `load-data`, `plot-results`, `model-fit`, `clean-variables`

## Instructions

For each code cell in the Quarto file(s):

1. **If a label already exists**: 
   - Examine the code content carefully
   - Verify the label accurately describes what the code does
   - If the label is inappropriate, misleading, or doesn't follow naming conventions, revise it
   - Examples of revisions needed:
     - `myPlot123` → `plot-scatter`
     - `dataPrep` → `clean-data`
     - `FinalModel` → `model-regression`

2. **If no label exists**:
   - Analyze the code to understand its purpose
   - Assign an appropriate descriptive label
   - Common patterns to consider:
     - `setup` - library loading, initial configuration
     - `load-*` - data loading operations (e.g., `load-csv`, `load-database`)
     - `clean-*` - data cleaning/preprocessing
     - `transform-*` - data transformation
     - `plot-*` - visualization code (e.g., `plot-histogram`, `plot-scatter`)
     - `model-*` - statistical modeling (e.g., `model-fit`, `model-regression`)
     - `analyze-*` - analysis operations
     - `summarize-*` - summary statistics or tables
     - `save-*` - saving outputs

3. **Placement**:
   - Place the `#| label:` line as the first option in the code cell header
   - Maintain other existing cell options

## Example Transformations

**Before** (no label):
```{r}
library(tidyverse)
library(ggplot2)
options(scipen = 999)
```

**After**:
```{r}
#| label: setup
library(tidyverse)
library(ggplot2)
options(scipen = 999)
```

---

**Before** (poor label):
```{r}
#| label: myPlot123
#| echo: false
ggplot(data, aes(x = age, y = income)) + 
  geom_point() +
  geom_smooth(method = "lm")
```

**After**:
```{r}
#| label: plot-income-age
#| echo: false
ggplot(data, aes(x = age, y = income)) + 
  geom_point() +
  geom_smooth(method = "lm")
```

---

**Before** (no label):
```{python}
import pandas as pd
df = pd.read_csv('data/survey.csv')
df_clean = df.dropna()
```

**After**:
```{python}
#| label: load-clean-data
import pandas as pd
df = pd.read_csv('data/survey.csv')
df_clean = df.dropna()
```

## Output Format

1. Show a summary of changes for each file
2. List each code cell with:
   - Cell location (line number if possible)
   - Old label (if existed) → New label
   - Or: "Added label: `new-label`"
3. Apply the changes to the file(s)
4. Provide a final summary with total cells labeled/revised

Now process the Quarto file(s) and label all code cells following these guidelines.

