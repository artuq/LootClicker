# Directive: Git and Commit Workflow

## Objective
Ensure all code changes are correctly staged, committed, and pushed to GitHub while referencing the appropriate issues, as per the established project workflow.

## Inputs
- Commit message (description of changes).
- Issue numbers (comma-separated).

## Tools / Scripts
- `.\commit.ps1`: The primary PowerShell script for committing and pushing.
- `git status`: To check the state of the repository.

## Procedure
1. **Verification:** Always run `git status` before committing to ensure only intended changes are staged.
2. **Execution:** Use the `run_shell_command` tool to execute `.\commit.ps1` with the `-message` and `-issues` parameters.
   - Example: `.\commit.ps1 -message "feat: Add new enemy type" -issues "8, 11"`
3. **Validation:** Confirm the push was successful by checking the output for "✅ Pushed to GitHub successfully!".

## Edge Cases
- **Missing Issues:** If no issue is relevant, omit the `-issues` parameter (not recommended).
- **Execution Policy:** If `commit.ps1` fails due to execution policy, run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.

## Outputs
- Success message in the terminal.
- Updated remote repository on GitHub.
