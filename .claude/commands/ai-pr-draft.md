# Command: /ai-pr-draft
# Purpose: AI-powered Pull Request Draft Creation

## Command Execution
- **Execute**: immediate
- **Purpose**: "Create an AI-generated draft PR for the current branch"
- **Legend**: Generated based on symbols used in command


## Examples

`/ai-pr-draft`
> Executes `./ai-pr-draft.sh` to create a new draft pull request.

`/ai-pr-draft --debug`
> Executes `DEBUG=1 ./ai-pr-draft.sh` to run the script in debug mode.


## Core Operation

This command's only function is to execute the `ai-pr-draft.sh` script.

All logic for PR creation, AI communication, and git operations is contained within the script itself. Please refer to the `ai-pr-draft.sh` file for implementation details.

## Flags
### `--debug`
- **Purpose**: Enables debug mode for the `ai-pr-draft.sh` script.
- **Action**: Sets the `DEBUG=1` environment variable before executing the script.