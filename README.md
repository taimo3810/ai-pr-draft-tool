# AI PR Draft Tool / AI PR下書きツール

> AI-powered tool for automatically generating GitHub Pull Request titles and descriptions using Claude AI and the GitHub CLI.
> 
> Claude AIとGitHub CLIを使用してGitHubプルリクエストのタイトルと説明を自動生成するAI駆動ツール。

---

## 🌐 Language / 言語

- **[English](#english)** - English documentation
- **[日本語](#日本語)** - 日本語ドキュメント

---

# English

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

---

# 日本語

## 🚀 機能

- **自動PR生成**: Gitコミットとdiffに基づいて包括的なPRタイトルと説明を作成
- **日本語サポート**: 日本語開発チーム向けにバイリンガルテンプレートで設計
- **Conventional Commits**: Conventional Commits仕様に従ったPRタイトル生成
- **下書きPR作成**: GitHubで自動的に下書きPRを作成
- **テンプレート統合**: リポジトリのPRテンプレートを使用、または適切なデフォルトを提供
- **デバッグモード**: トラブルシューティング用の包括的なデバッグ出力

## 📋 前提条件

このツールを使用する前に、以下がインストールされていることを確認してください：

### 必須ツール

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
   # Claude CLIのインストール
   npm install -g @anthropic-ai/claude-cli
   # または
   pip install claude-cli
   ```

3. **jq** (JSONプロセッサ)
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt install jq
   
   # Windows
   winget install jqlang.jq
   ```

### 認証設定

1. **GitHub認証**:
   ```bash
   gh auth login
   ```

2. **Claude APIキー**:
   環境にAnthropic APIキーを設定：
   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```
   
   またはClaude CLIのドキュメントに従って設定してください。

## 🛠️ インストール

1. **このリポジトリをクローンまたはダウンロード**:
   ```bash
   git clone https://github.com/your-username/ai-pr-draft-tool.git
   cd ai-pr-draft-tool
   ```

2. **スクリプトを実行可能にする**:
   ```bash
   chmod +x ai-pr-draft.sh
   ```

3. **PATHに追加** (オプションですが推奨):
   ```bash
   # ~/.bashrc、~/.zshrc、または同等のファイルに追加
   export PATH="$PATH:/path/to/ai-pr-draft-tool"
   ```

## 📖 使用方法

### 基本的な使用方法

1. **フィーチャーブランチを作成して変更を行う**:
   ```bash
   git checkout -b feature/new-awesome-feature
   # 変更を行う
   git add .
   git commit -m "feat: add awesome new feature"
   ```

2. **AI PR下書きツールを実行**:
   ```bash
   ./ai-pr-draft.sh
   ```

ツールは以下を実行します：
- ベースブランチ以降のコミットを分析
- 変更のdiffを生成
- Claude AIに情報を送信して分析
- 包括的なPRタイトルと説明を作成
- ブランチをGitHubにプッシュ
- 自動的に下書きPRを作成

### デバッグモード

トラブルシューティングのため、デバッグモードを有効にして実行：

```bash
DEBUG=1 ./ai-pr-draft.sh
```

これにより以下の詳細な出力が表示されます：
- Claude APIレスポンス
- JSON解析ステップ
- Gitコマンド出力

### 高度な使用方法

**カスタムベースブランチ** (ツールは自動的にデフォルトブランチを検出しますが、強制することもできます):
```bash
# スクリプトは自動的にmain/masterをベースブランチとして検出
# 手動設定は不要
```

## 🔧 設定

### PRテンプレート

ツールはリポジトリ内の`.github/PULL_REQUEST_TEMPLATE.md`を探します。見つかった場合、PR説明の生成にこのテンプレート構造を使用します。見つからない場合は、デフォルトテンプレートを使用します。

#### PRテンプレート構造の例

```markdown
## 概要 (Overview)
<!-- 変更の説明 -->

## 変更内容 (Changes)
<!-- 具体的な変更のリスト -->

## テスト (Testing)
<!-- テスト情報 -->

## 確認事項 (Checklist)
<!-- 完了チェックリスト -->
```

### 保護されたブランチ

ツールは自動的に保護されたブランチからのPR作成を防止します：
- `main`
- `master`
- `develop`
- `staging`
- `production`

### 環境変数

- `DEBUG`: デバッグ出力を有効にするには`1`に設定
- `ANTHROPIC_API_KEY`: あなたのClaude APIキー（必須）

## 📊 出力例

### 生成されたPRタイトル
```
feat: Enhance image generation prompts for square banner layouts
```

### 生成されたPR説明
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

## 🐛 トラブルシューティング

### よくある問題

1. **"gh not found"エラー**:
   - GitHub CLIをインストール: `brew install gh` (macOS) または同等のコマンド
   - 認証: `gh auth login`

2. **"claude not found"エラー**:
   - Claude CLIをインストール: `npm install -g @anthropic-ai/claude-cli`
   - APIキーを設定: `export ANTHROPIC_API_KEY="your-key"`

3. **"jq not found"エラー**:
   - jqをインストール: `brew install jq` (macOS) または同等のコマンド

4. **JSON解析エラー**:
   - `DEBUG=1`で実行して詳細な解析情報を確認
   - Claude APIキー設定を確認
   - インターネット接続を確認

5. **PR作成時の権限エラー**:
   - リポジトリへの書き込み権限があることを確認
   - GitHub認証を確認: `gh auth status`

### デバッグ情報

`DEBUG=1`が設定されている場合、ツールは以下の詳細なデバッグ情報を提供します：

- 生のClaude APIレスポンス
- JSON抽出と解析ステップ
- Gitコマンド出力
- ステップバイステップの実行フロー

## 💻 Claude Code統合

このツールには簡単な実行のためのClaude Codeコマンドが含まれています：

### Claude Codeユーザー向け設定

1. **コマンド定義をコピー**:
   ```bash
   cp .claude/commands/ai-pr-draft.md /path/to/your/project/.claude/commands/
   ```

2. **`/ai-pr-draft`コマンドを使用**:
   ```
   /ai-pr-draft              # 通常実行
   /ai-pr-draft --debug      # デバッグモード
   ```

Claude Code統合により、Claude Codeセッションから直接ツールを実行する便利な方法が提供されます。

## 🤝 貢献

1. リポジトリをフォーク
2. フィーチャーブランチを作成: `git checkout -b feature/my-new-feature`
3. 変更をコミット: `git commit -am 'Add some feature'`
4. ブランチにプッシュ: `git push origin feature/my-new-feature`
5. プルリクエストを送信

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- インテリジェントなPR生成のための[Claude AI](https://www.anthropic.com/claude)で構築
- シームレスなGitHub統合のための[GitHub CLI](https://cli.github.com/)を使用
- 日本語開発チームでのより良いPRドキュメントの必要性からインスピレーション

## 🔗 関連ツール

- [GitHub CLI](https://cli.github.com/) - 公式GitHubコマンドラインツール
- [Claude CLI](https://github.com/anthropics/claude-code) - Claude AIコマンドラインインターフェース
- [Conventional Commits](https://www.conventionalcommits.org/) - コミットメッセージ規約

## 📞 サポート

問題や質問については：

1. 上記の[トラブルシューティングセクション](#-トラブルシューティング)を確認
2. 既存の[GitHub Issues](https://github.com/your-username/ai-pr-draft-tool/issues)を検索
3. 以下を含む新しいissueを作成：
   - あなたのオペレーティングシステム
   - ツールバージョン (`gh --version`, `claude --version`, `jq --version`)
   - デバッグ出力 (`DEBUG=1 ./ai-pr-draft.sh`)
   - エラーメッセージ