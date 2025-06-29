# Command: /ai-pr-draft-ja

# Purpose: AI-powered Pull Request Draft Creation (Japanese Version)

## Command Execution

- **Execute**: immediate
- **Purpose**: "Create an AI-generated draft PR for the current branch using Japanese prompts"
- **Legend**: Generated based on symbols used in command

## Examples

`/ai-pr-draft-ja`

> Executes `./ai-pr-draft-ja.sh` to create a new draft pull request with Japanese AI prompts.

`/ai-pr-draft-ja --debug`

> Executes `DEBUG=1 ./ai-pr-draft-ja.sh` to run the script in debug mode.

## Core Operation

This command's only function is to execute the `ai-pr-draft-ja.sh` script.

All logic for PR creation, AI communication, and git operations is contained within the script itself. Please refer to the `ai-pr-draft-ja.sh` file for implementation details.

This Japanese version uses Japanese prompts for Claude AI and searches for Japanese PR templates (`PULL_REQUEST_TEMPLATE_JA.md`).

## Flags

### `--debug`

- **Purpose**: Enables debug mode for the `ai-pr-draft-ja.sh` script.
- **Action**: Sets the `DEBUG=1` environment variable before executing the script.
