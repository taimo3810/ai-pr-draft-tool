# AI PR Draft Tool

AI-powered tool for automatically generating GitHub Pull Request titles and descriptions using Claude AI and the GitHub CLI.

## 🚀 Features

- **Automatic PR Generation**: Creates comprehensive PR titles and descriptions based on your git commits and diff
- **Japanese Language Support**: Designed for Japanese development teams with bilingual templates
- **Conventional Commits**: Generates PR titles following Conventional Commits specification
- **Draft PR Creation**: Automatically creates draft PRs on GitHub
- **Template Integration**: Uses your repository's PR template or provides a sensible default
- **Debug Mode**: Comprehensive debugging output for troubleshooting

## 📋 Prerequisites

Before using this tool, make sure you have the following installed:

### Required Tools

1. **[GitHub CLI (gh)](https://cli.github.com/)**
   ```bash
   # macOS
   brew install gh
   
   # Ubuntu/Debian
   sudo apt install gh
   
   # Windows
   winget install GitHub.cli
   ```

2. **[Claude CLI](https://github.com/anthropics/claude-code)**
   ```bash
   # Install Claude CLI
   npm install -g @anthropic-ai/claude-cli
   # or
   pip install claude-cli
   ```

3. **jq** (JSON processor)
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt install jq
   
   # Windows
   winget install jqlang.jq
   ```

### Authentication Setup

1. **GitHub Authentication**:
   ```bash
   gh auth login
   ```

2. **Claude API Key**:
   Set up your Anthropic API key in your environment:
   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```
   
   Or configure Claude CLI according to its documentation.

## 🛠️ Installation

1. **Clone or download this repository**:
   ```bash
   git clone https://github.com/your-username/ai-pr-draft-tool.git
   cd ai-pr-draft-tool
   ```

2. **Make the script executable**:
   ```bash
   chmod +x ai-pr-draft.sh
   ```

3. **Add to PATH** (optional but recommended):
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or equivalent
   export PATH="$PATH:/path/to/ai-pr-draft-tool"
   ```

## 📖 Usage

### Basic Usage

1. **Create a feature branch and make your changes**:
   ```bash
   git checkout -b feature/new-awesome-feature
   # Make your changes
   git add .
   git commit -m "feat: add awesome new feature"
   ```

2. **Run the AI PR draft tool**:
   ```bash
   ./ai-pr-draft.sh
   ```

The tool will:
- Analyze your commits since the base branch
- Generate a diff of your changes
- Send the information to Claude AI for analysis
- Create a comprehensive PR title and description
- Push your branch to GitHub
- Create a draft PR automatically

### Debug Mode

For troubleshooting, run with debug mode enabled:

```bash
DEBUG=1 ./ai-pr-draft.sh
```

This will show detailed output including:
- Claude API responses
- JSON parsing steps
- Git command outputs

### Advanced Usage

**Custom base branch** (the tool auto-detects the default branch, but you can force it):
```bash
# The script automatically detects main/master as the base branch
# No manual configuration needed
```

## 🔧 Configuration

### PR Template

The tool looks for `.github/PULL_REQUEST_TEMPLATE.md` in your repository. If found, it will use this template structure for generating the PR description. If not found, it uses a default template.

#### Example PR Template Structure

```markdown
## 概要 (Overview)
<!-- Description of changes -->

## 変更内容 (Changes)
<!-- List of specific changes -->

## テスト (Testing)
<!-- Testing information -->

## 確認事項 (Checklist)
<!-- Completion checklist -->
```

### Protected Branches

The tool automatically prevents creating PRs from protected branches:
- `main`
- `master`
- `develop`
- `staging`
- `production`

### Environment Variables

- `DEBUG`: Set to `1` to enable debug output
- `ANTHROPIC_API_KEY`: Your Claude API key (required)

## 📊 Example Output

### Generated PR Title
```
feat: Enhance image generation prompts for square banner layouts
```

### Generated PR Description
```markdown
## 概要 (Overview)

Updated the IdeaCreationTool to include detailed layout instructions in prompts, ensuring all content fits within specified boundaries and maintains readability.

## 変更内容 (Changes)

- [x] **機能追加 (Feature)**: Enhanced prompt generation with layout constraints
- [ ] **バグ修正 (Bug Fix)**:
- [ ] **リファクタリング (Refactoring)**:

### 変更点の詳細 (Change Details)

- Modified prompt handling for both image editing and generation processes
- Added boundary detection and content fitting algorithms
- Improved readability checks for generated layouts

## テスト (Testing)

- [x] ユニットテスト (Unit Tests)
- [x] 手動テスト (Manual Testing)
- [ ] E2Eテスト (End-to-End Tests)

## 完了基準の確認 (Confirmation of Completion Criteria)

- [x] **機能要件は実装されたか**
- [x] **適切なテストカバレッジは確保されているか**
- [x] **既存のテストはすべてパスしているか**
```

## 🐛 Troubleshooting

### Common Issues

1. **"gh not found" error**:
   - Install GitHub CLI: `brew install gh` (macOS) or equivalent
   - Authenticate: `gh auth login`

2. **"claude not found" error**:
   - Install Claude CLI: `npm install -g @anthropic-ai/claude-cli`
   - Set up API key: `export ANTHROPIC_API_KEY="your-key"`

3. **"jq not found" error**:
   - Install jq: `brew install jq` (macOS) or equivalent

4. **JSON parsing errors**:
   - Run with `DEBUG=1` to see detailed parsing information
   - Check Claude API key configuration
   - Verify internet connection

5. **Permission errors when creating PR**:
   - Ensure you have write access to the repository
   - Check GitHub authentication: `gh auth status`

### Debug Information

When `DEBUG=1` is set, the tool provides extensive debugging information:

- Raw Claude API responses
- JSON extraction and parsing steps
- Git command outputs
- Step-by-step execution flow

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Claude AI](https://www.anthropic.com/claude) for intelligent PR generation
- Uses [GitHub CLI](https://cli.github.com/) for seamless GitHub integration
- Inspired by the need for better PR documentation in Japanese development teams

## 💻 Claude Code Integration

This tool includes a Claude Code command for easy execution:

### Setup for Claude Code Users

1. **Copy the command definition**:
   ```bash
   cp .claude/commands/ai-pr-draft.md /path/to/your/project/.claude/commands/
   ```

2. **Use the `/ai-pr-draft` command**:
   ```
   /ai-pr-draft              # Normal execution
   /ai-pr-draft --debug      # Debug mode
   ```

The Claude Code integration provides a convenient way to execute the tool directly from your Claude Code session.

## 🔗 Related Tools

- [GitHub CLI](https://cli.github.com/) - Official GitHub command line tool
- [Claude CLI](https://github.com/anthropics/claude-code) - Claude AI command line interface
- [Conventional Commits](https://www.conventionalcommits.org/) - Commit message convention

## 📞 Support

For issues and questions:

1. Check the [troubleshooting section](#-troubleshooting) above
2. Search existing [GitHub Issues](https://github.com/your-username/ai-pr-draft-tool/issues)
3. Create a new issue with:
   - Your operating system
   - Tool versions (`gh --version`, `claude --version`, `jq --version`)
   - Debug output (`DEBUG=1 ./ai-pr-draft.sh`)
   - Error messages