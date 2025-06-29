# Command: /ai-pr-draft-en

# Purpose: AI-powered Pull Request Draft Creation (English Version)

## Command Execution

- **Execute**: immediate
- **Purpose**: "Create an AI-generated draft PR for the current branch using English prompts"
- **Legend**: Generated based on symbols used in command

## Examples

`/ai-pr-draft-en`

> Executes `./ai-pr-draft-en.sh` to create a new draft pull request with English AI prompts.

`/ai-pr-draft-en --debug`

> Executes `DEBUG=1 ./ai-pr-draft-en.sh` to run the script in debug mode.

## Core Operation

This command's only function is to execute the `ai-pr-draft-en.sh` script.

All logic for PR creation, AI communication, and git operations is contained within the script itself. Please refer to the `ai-pr-draft-en.sh` file for implementation details.

This English version uses English prompts for Claude AI and searches for English PR templates (`PULL_REQUEST_TEMPLATE_EN.md`).

## Flags

### `--debug`

- **Purpose**: Enables debug mode for the `ai-pr-draft-en.sh` script.
- **Action**: Sets the `DEBUG=1` environment variable before executing the script.
