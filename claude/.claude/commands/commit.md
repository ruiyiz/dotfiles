ADD all modified and new files to git in the specified repository, or all working directories if no repository is specified. Trust that .gitignore is properly configured to exclude unwanted files, but if you encounter files that seem unusual for version control (large binaries, obvious secrets, etc.), ask the user for confirmation.

If you think files should be bundled into separate commits for logical grouping, ask the user.

THEN commit with a clear and concise one-line commit message using semantic commit notation with scope when applicable (e.g., "feat(auth): add user login", "fix(api): handle null responses").

When you make a commit, always include an explicit `cd` command to make it clear which working directory is being affected.

Handle these scenarios:
- No changes to commit: abort and inform the user
- Merge conflicts detected: ask the user whether to let you attempt to resolve the conflict
- No remote origin: abort and inform the user

DO NOT ask whether to push the commit to origin. The user is EXPLICITLY requesting you to perform these git operations, and `git commit` is configured as an "Ask" permission that will prompt for user confirmation.

Usage: 
- `commit` - processes all configured working directories
- `commit <repo-name>` - processes only the specified repository

