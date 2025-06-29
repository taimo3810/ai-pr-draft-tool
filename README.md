# AI PR Draft Tool / AI PR 下書きツール

> AI-powered tool for automatically generating GitHub Pull Request titles and descriptions using Claude AI and the GitHub CLI.
>
> Claude AI と GitHub CLI を使用して GitHub プルリクエストのタイトルと説明を自動生成する AI 駆動ツール。

---

## 🌐 Language / 言語

- **[English](#english)** - English documentation
- **[日本語](#日本語)** - 日本語ドキュメント

---

# English

## 🚀 Features

- **Automatic PR Generation**: Creates comprehensive PR titles and descriptions based on your git commits and diff
- **Bilingual Support**: Separate English and Japanese versions with full localization
- **Enhanced Security**: Built-in prompt safety to prevent command execution
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

2. **Make the scripts executable**:

   ```bash
   chmod +x ai-pr-draft-en.sh
   chmod +x ai-pr-draft-ja.sh
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
   # For English PRs
   ./ai-pr-draft-en.sh

   # For Japanese PRs
   ./ai-pr-draft-ja.sh
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
# English version
DEBUG=1 ./ai-pr-draft-en.sh

# Japanese version
DEBUG=1 ./ai-pr-draft-ja.sh
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

### PR Templates

The tool looks for language-specific PR templates in your repository:

- **English version**: `.github/PULL_REQUEST_TEMPLATE_EN.md`
- **Japanese version**: `.github/PULL_REQUEST_TEMPLATE_JA.md`

If language-specific templates are not found, it falls back to `.github/PULL_REQUEST_TEMPLATE.md`, and finally uses a sensible default.

#### Example PR Template Structure

```markdown
## Overview

<!-- Description of changes -->

## Changes

<!-- List of specific changes -->

## Testing

<!-- Testing information -->

## Checklist

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
## Overview

Updated the IdeaCreationTool to include detailed layout instructions in prompts, ensuring all content fits within specified boundaries and maintains readability.

## Changes

- [x] **Feature**: Enhanced prompt generation with layout constraints
- [ ] **Bug Fix**:
- [ ] **Refactoring**:

### Change Details

- Modified prompt handling for both image editing and generation processes
- Added boundary detection and content fitting algorithms
- Improved readability checks for generated layouts

## Testing

- [x] Unit Tests
- [x] Manual Testing
- [ ] End-to-End Tests

## Confirmation of Completion Criteria

- [x] **Are functional requirements implemented?**
- [x] **Is appropriate test coverage ensured?**
- [x] **Do all existing tests pass?**
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

This tool includes Claude Code commands for easy execution:

### Setup for Claude Code Users

1. **Copy the command definitions**:

   ```bash
   # For English version
   cp .claude/commands/ai-pr-draft-en.md /path/to/your/project/.claude/commands/

   # For Japanese version
   cp .claude/commands/ai-pr-draft-ja.md /path/to/your/project/.claude/commands/
   ```

2. **Use the commands**:

   ```
   /ai-pr-draft-en              # English version
   /ai-pr-draft-en --debug      # English version with debug

   /ai-pr-draft-ja              # Japanese version
   /ai-pr-draft-ja --debug      # Japanese version with debug
   ```

The Claude Code integration provides a convenient way to execute the tool directly from your Claude Code session.

## 🔒 Security Features

- **Prompt Safety**: Built-in safeguards prevent Claude from executing any commands
- **Read-Only Mode**: Claude is explicitly instructed to only read provided information
- **Input Validation**: Comprehensive validation of all inputs and outputs

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
- Inspired by the need for better PR documentation in development teams

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
   - Debug output (`DEBUG=1 ./ai-pr-draft-en.sh` or `DEBUG=1 ./ai-pr-draft-ja.sh`)
   - Error messages

---

# 日本語

## 🚀 機能

- **自動 PR 生成**: Git コミットと diff に基づいて包括的な PR タイトルと説明を作成
- **バイリンガルサポート**: 完全にローカライズされた英語版と日本語版を分離
- **セキュリティ強化**: コマンド実行を防ぐ組み込みプロンプト安全機能
- **Conventional Commits**: Conventional Commits 仕様に従った PR タイトル生成
- **下書き PR 作成**: GitHub で自動的に下書き PR を作成
- **テンプレート統合**: リポジトリの PR テンプレートを使用、または適切なデフォルトを提供
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

3. **jq** (JSON プロセッサ)

   ```bash
   # macOS
   brew install jq

   # Ubuntu/Debian
   sudo apt install jq

   # Windows
   winget install jqlang.jq
   ```

### 認証設定

1. **GitHub 認証**:

   ```bash
   gh auth login
   ```

2. **Claude API キー**:
   環境に Anthropic API キーを設定：

   ```bash
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```

   または Claude CLI のドキュメントに従って設定してください。

## ��️ インストール

1. **このリポジトリをクローンまたはダウンロード**:

   ```bash
   git clone https://github.com/your-username/ai-pr-draft-tool.git
   cd ai-pr-draft-tool
   ```

2. **スクリプトを実行可能にする**:

   ```bash
   chmod +x ai-pr-draft-en.sh
   chmod +x ai-pr-draft-ja.sh
   ```

3. **PATH に追加** (オプションですが推奨):
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

2. **AI PR 下書きツールを実行**:

   ```bash
   # 英語版PR用
   ./ai-pr-draft-en.sh

   # 日本語版PR用
   ./ai-pr-draft-ja.sh
   ```

ツールは以下を実行します：

- ベースブランチ以降のコミットを分析
- 変更の diff を生成
- Claude AI に情報を送信して分析
- 包括的な PR タイトルと説明を作成
- ブランチを GitHub にプッシュ
- 自動的に下書き PR を作成

### デバッグモード

トラブルシューティングのため、デバッグモードを有効にして実行：

```bash
# 英語版
DEBUG=1 ./ai-pr-draft-en.sh

# 日本語版
DEBUG=1 ./ai-pr-draft-ja.sh
```

これにより以下の詳細な出力が表示されます：

- Claude API レスポンス
- JSON 解析ステップ
- Git コマンド出力

### 高度な使用方法

**カスタムベースブランチ** (ツールは自動的にデフォルトブランチを検出しますが、強制することもできます):

```bash
# スクリプトは自動的にmain/masterをベースブランチとして検出
# 手動設定は不要
```

## 🔧 設定

### PR テンプレート

ツールはリポジトリ内の言語固有の PR テンプレートを探します：

- **英語版**: `.github/PULL_REQUEST_TEMPLATE_EN.md`
- **日本語版**: `.github/PULL_REQUEST_TEMPLATE_JA.md`

言語固有のテンプレートが見つからない場合、`.github/PULL_REQUEST_TEMPLATE.md`にフォールバックし、最終的に適切なデフォルトを使用します。

#### PR テンプレート構造の例

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

ツールは自動的に保護されたブランチからの PR 作成を防止します：

- `main`
- `master`
- `develop`
- `staging`
- `production`

### 環境変数

- `DEBUG`: デバッグ出力を有効にするには`1`に設定
- `ANTHROPIC_API_KEY`: あなたの Claude API キー（必須）

## 📊 出力例

### 生成された PR タイトル

```
feat: Enhance image generation prompts for square banner layouts
```

### 生成された PR 説明

```markdown
## 概要 (Overview)

画像生成プロンプトにレイアウト制約を追加し、正方形バナーでのコンテンツの配置と readability を向上させました。

## 変更内容 (Changes)

- [x] **機能追加 (Feature)**: Enhanced prompt generation with layout constraints
- [ ] **バグ修正 (Bug Fix)**:
- [ ] **リファクタリング (Refactoring)**:

### 変更点の詳細 (Change Details)

- 画像編集と生成の両プロセスでプロンプト処理を調整
- 境界検出とコンテンツフィッティングアルゴリズムを追加
- 生成されたレイアウトの読みやすさチェックを改善

## テスト (Testing)

- [x] ユニットテスト (Unit Tests)
- [x] 手動テスト (Manual Testing)
- [ ] E2E テスト (End-to-End Tests)

## 完了基準の確認 (Confirmation of Completion Criteria)

- [x] **機能要件は実装されたか**
- [x] **適切なテストカバレッジは確保されているか**
- [x] **既存のテストはすべてパスしているか**
```

## 🐛 トラブルシューティング

### よくある問題

1. **"gh not found"エラー**:

   - GitHub CLI をインストール: `brew install gh` (macOS) または同等のコマンド
   - 認証: `gh auth login`

2. **"claude not found"エラー**:

   - Claude CLI をインストール: `npm install -g @anthropic-ai/claude-cli`
   - API キーを設定: `export ANTHROPIC_API_KEY="your-key"`

3. **"jq not found"エラー**:

   - jq をインストール: `brew install jq` (macOS) または同等のコマンド

4. **JSON 解析エラー**:

   - `DEBUG=1`で実行して詳細な解析情報を確認
   - Claude API キー設定を確認
   - インターネット接続を確認

5. **PR 作成時の権限エラー**:
   - リポジトリへの書き込み権限があることを確認
   - GitHub 認証を確認: `gh auth status`

### デバッグ情報

`DEBUG=1`が設定されている場合、ツールは以下の詳細なデバッグ情報を提供します：

- 生の Claude API レスポンス
- JSON 抽出と解析ステップ
- Git コマンド出力
- ステップバイステップの実行フロー

## 💻 Claude Code 統合

このツールには簡単な実行のための Claude Code コマンドが含まれています：

### Claude Code ユーザー向け設定

1. **コマンド定義をコピー**:

   ```bash
   # 英語版用
   cp .claude/commands/ai-pr-draft-en.md /path/to/your/project/.claude/commands/

   # 日本語版用
   cp .claude/commands/ai-pr-draft-ja.md /path/to/your/project/.claude/commands/
   ```

2. **コマンドを使用**:

   ```
   /ai-pr-draft-en              # 英語版
   /ai-pr-draft-en --debug      # 英語版（デバッグ付き）

   /ai-pr-draft-ja              # 日本語版
   /ai-pr-draft-ja --debug      # 日本語版（デバッグ付き）
   ```

Claude Code 統合により、Claude Code セッションから直接ツールを実行する便利な方法が提供されます。

## 🔒 セキュリティ機能

- **プロンプト安全性**: Claude がコマンドを実行することを防ぐ組み込み保護機能
- **読み取り専用モード**: Claude は提供された情報のみを読み取るよう明示的に指示
- **入力検証**: すべての入力と出力の包括的な検証

## 🤝 貢献

1. リポジトリをフォーク
2. フィーチャーブランチを作成: `git checkout -b feature/my-new-feature`
3. 変更をコミット: `git commit -am 'Add some feature'`
4. ブランチにプッシュ: `git push origin feature/my-new-feature`
5. プルリクエストを送信

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- インテリジェントな PR 生成のための[Claude AI](https://www.anthropic.com/claude)で構築
- シームレスな GitHub 統合のための[GitHub CLI](https://cli.github.com/)を使用
- 開発チームでのより良い PR ドキュメントの必要性からインスピレーション

## 🔗 関連ツール

- [GitHub CLI](https://cli.github.com/) - 公式 GitHub コマンドラインツール
- [Claude CLI](https://github.com/anthropics/claude-code) - Claude AI コマンドラインインターフェース
- [Conventional Commits](https://www.conventionalcommits.org/) - コミットメッセージ規約

## 📞 サポート

問題や質問については：

1. 上記の[トラブルシューティングセクション](#-troubleshooting)を確認
2. 既存の[GitHub Issues](https://github.com/your-username/ai-pr-draft-tool/issues)を検索
3. 以下を含む新しい issue を作成：
   - あなたのオペレーティングシステム
   - ツールバージョン (`gh --version`, `claude --version`, `jq --version`)
   - デバッグ出力 (`DEBUG=1 ./ai-pr-draft-en.sh` または `DEBUG=1 ./ai-pr-draft-ja.sh`)
   - エラーメッセージ
