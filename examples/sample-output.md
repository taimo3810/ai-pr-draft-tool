# Sample Output Example

This document shows example output from the AI PR Draft Tool.

## Example Scenario

Imagine you've created a feature branch with the following commits:

```bash
git log main..feature/enhance-image-generation --oneline
a1b2c3d feat: enhance image generation prompts for square layouts
d4e5f6g fix: handle edge case in prompt validation
g7h8i9j docs: update API documentation for new parameters
```

## Generated PR Title

```
feat: Enhance image generation prompts for square banner layouts
```

## Generated PR Body

```markdown
## 概要 (Overview)

画像生成プロンプトにレイアウト制約を追加し、正方形バナーでのコンテンツの配置と readability を向上させました。

## 変更内容 (Changes)

- [x] **機能追加 (Feature)**: Enhanced prompt generation with layout constraints for square banners
- [x] **バグ修正 (Bug Fix)**: Fixed edge case in prompt validation that caused generation failures
- [x] **ドキュメント更新 (Documentation)**: Updated API documentation to reflect new parameters
- [ ] **リファクタリング (Refactoring)**:
- [ ] **その他 (Other)**:

### 変更点の詳細 (Change Details)

- `IdeaCreationTool`にレイアウト境界検出機能を追加
- プロンプト生成時にコンテンツが指定された境界内に収まるよう制約を追加
- 画像編集と生成の両プロセスでプロンプト処理を調整
- エッジケースでのバリデーション失敗を修正
- API ドキュメントに新しいパラメータの説明を追加

## テスト (Testing)

- [x] ユニットテスト (Unit Tests)
- [x] インテグレーションテスト (Integration Tests)
- [x] 手動テスト (Manual Testing)
- [ ] E2E テスト (End-to-End Tests)

### テスト内容の詳細 (Test Details)

- 正方形レイアウトでの境界検出テストケースを追加
- プロンプトバリデーションの各エッジケースを検証
- 新しい API パラメータの動作確認
- 既存機能への影響がないことを確認

## 関連リンク (Related Links)

- Closes #123
- Related to #456
- Documentation: [API Reference](https://docs.example.com/api)

## レビュアーへの確認事項 (Items for Reviewer)

- レイアウト制約の実装が適切か確認してください
- パフォーマンスへの影響がないか確認してください
- API ドキュメントが十分詳細か確認してください

## 完了基準の確認 (Confirmation of Completion Criteria)

- [x] **機能要件は実装されたか** (Are functional requirements implemented?)
- [x] **非機能要件は達成されているか** (Are non-functional requirements met?)
- [x] **適切なテストカバレッジは確保されているか** (Is appropriate test coverage ensured?)
- [x] **既存のテストはすべてパスしているか** (Do all existing tests pass?)
- [x] **ドキュメントは更新されたか (必要な場合)** (Is documentation updated if necessary?)
- [x] **Breaking Change はないか** (Are there no breaking changes?)

## その他 (Additional Notes)

この変更により、正方形バナーの生成品質が大幅に向上し、より読みやすく魅力的なコンテンツが作成できるようになります。

---

_This template helps ensure comprehensive PR documentation and review._
```

## Command Line Output

### English Version

```bash
$ ./ai-pr-draft-en.sh
[14:32:15] Step 0: Checking required tools…
[14:32:15]   ✓ gh found
[14:32:15]   ✓ claude found
[14:32:15]   ✓ jq found
[14:32:15] Step 1: Gathering repository context…
[14:32:16]   repo:            username/example-repo
[14:32:16]   base branch:     main
[14:32:16]   current branch:  feature/enhance-image-generation
[14:32:16] Step 2: Collecting commits and diff…
[14:32:16]   template found: .github/PULL_REQUEST_TEMPLATE_EN.md
[14:32:16]   commits collected
[14:32:16]   diff length: 127 lines (truncated)
[14:32:16] Step 3: Generating PR title/body via Claude…
[14:32:16]   Sending prompt to Claude...
[14:32:18]   ✓ Extracted from code fence
[14:32:18]   JSON: {"title":"feat: Enhance image generation prompts for square banner layouts","body":"## Overview...
[14:32:18]   ✓ Successfully parsed JSON with jq
[14:32:18] Step 4: Extracted PR information
[14:32:18]   Title: feat: Enhance image generation prompts for square banner layouts
[14:32:18]   Body length: 2847 characters
[14:32:18] Step 5: Publishing branch to remote…
[14:32:19]   ✓ Branch published successfully
[14:32:19] Step 6: Creating draft PR…
[14:32:21] ✅ Draft PR created successfully!
[14:32:21]    URL: https://github.com/username/example-repo/pull/42
[14:32:21] 🎉 Process completed successfully!
```

### Japanese Version

```bash
$ ./ai-pr-draft-ja.sh
[14:32:15] ステップ 0: 必要なツールをチェック中…
[14:32:15]   ✓ gh が見つかりました
[14:32:15]   ✓ claude が見つかりました
[14:32:15]   ✓ jq が見つかりました
[14:32:15] ステップ 1: リポジトリ情報を収集中…
[14:32:16]   リポジトリ:            username/example-repo
[14:32:16]   ベースブランチ:        main
[14:32:16]   現在のブランチ:        feature/enhance-image-generation
[14:32:16] ステップ 2: コミットとdiffを収集中…
[14:32:16]   テンプレートが見つかりました: .github/PULL_REQUEST_TEMPLATE_JA.md
[14:32:16]   コミットを収集しました
[14:32:16]   diff の長さ: 127 行 (切り詰められました)
[14:32:16] ステップ 3: Claude を使用してPRタイトル/本文を生成中…
[14:32:16]   Claude にプロンプトを送信中...
[14:32:18]   ✓ コードフェンスから抽出しました
[14:32:18]   JSON: {"title":"feat: Enhance image generation prompts for square banner layouts","body":"## 概要...
[14:32:18]   ✓ jq で JSON の解析に成功しました
[14:32:18] ステップ 4: PR 情報を抽出しました
[14:32:18]   タイトル: feat: Enhance image generation prompts for square banner layouts
[14:32:18]   本文の長さ: 2847 文字
[14:32:18] ステップ 5: ブランチをリモートに公開中…
[14:32:19]   ✓ ブランチの公開に成功しました
[14:32:19] ステップ 6: 下書きPRを作成中…
[14:32:21] ✅ 下書きPRの作成に成功しました！
[14:32:21]    URL: https://github.com/username/example-repo/pull/42
[14:32:21] 🎉 処理が正常に完了しました！
```

## Debug Mode Output

When running with `DEBUG=1`, you'll see additional information:

### English Version

```bash
$ DEBUG=1 ./ai-pr-draft-en.sh
# ... (normal output above)
DEBUG: Claude raw output:
{"result": "{\"title\":\"feat: Enhance image generation prompts for square banner layouts\",\"body\":\"## Overview\\n\\nUpdated the IdeaCreationTool to include detailed layout instructions..."}
...
DEBUG: Extracted text length: 2951
DEBUG: Line count in RAW: 1
DEBUG: JSON_PAYLOAD length: 2847
DEBUG: JSON_PAYLOAD (first 300 chars):
{"title":"feat: Enhance image generation prompts for square banner layouts","body":"## Overview\\n\\nUpdated the IdeaCreationTool to include detailed layout instructions in prompts...
...
```

### Japanese Version

```bash
$ DEBUG=1 ./ai-pr-draft-ja.sh
# ... (通常の出力は上記)
DEBUG: Claude の生レスポンス:
{"result": "{\"title\":\"feat: Enhance image generation prompts for square banner layouts\",\"body\":\"## 概要 (Overview)\\n\\n画像生成プロンプトにレイアウト制約を追加し..."}
...
DEBUG: 抽出されたテキストの長さ: 2951
DEBUG: RAW の行数: 1
DEBUG: JSON_PAYLOAD の長さ: 2847
DEBUG: JSON_PAYLOAD (最初の300文字):
{"title":"feat: Enhance image generation prompts for square banner layouts","body":"## 概要 (Overview)\\n\\n画像生成プロンプトにレイアウト制約を追加し、正方形バナーでのコンテンツの配置とreadabilityを向上させました...
...
```

This example demonstrates how both versions of the tool process your changes and generate comprehensive, well-structured PRs with appropriate language localization.
