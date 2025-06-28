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

画像生成プロンプトにレイアウト制約を追加し、正方形バナーでのコンテンツの配置とreadabilityを向上させました。

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
- APIドキュメントに新しいパラメータの説明を追加

## テスト (Testing)

- [x] ユニットテスト (Unit Tests)
- [x] インテグレーションテスト (Integration Tests)  
- [x] 手動テスト (Manual Testing)
- [ ] E2Eテスト (End-to-End Tests)

### テスト内容の詳細 (Test Details)

- 正方形レイアウトでの境界検出テストケースを追加
- プロンプトバリデーションの各エッジケースを検証
- 新しいAPIパラメータの動作確認
- 既存機能への影響がないことを確認

## 関連リンク (Related Links)

- Closes #123
- Related to #456  
- Documentation: [API Reference](https://docs.example.com/api)

## レビュアーへの確認事項 (Items for Reviewer)

- レイアウト制約の実装が適切か確認してください
- パフォーマンスへの影響がないか確認してください
- APIドキュメントが十分詳細か確認してください

## 完了基準の確認 (Confirmation of Completion Criteria)

- [x] **機能要件は実装されたか** (Are functional requirements implemented?)
- [x] **非機能要件は達成されているか** (Are non-functional requirements met?)
- [x] **適切なテストカバレッジは確保されているか** (Is appropriate test coverage ensured?)
- [x] **既存のテストはすべてパスしているか** (Do all existing tests pass?)
- [x] **ドキュメントは更新されたか (必要な場合)** (Is documentation updated if necessary?)
- [x] **Breaking Changeはないか** (Are there no breaking changes?)

## その他 (Additional Notes)

この変更により、正方形バナーの生成品質が大幅に向上し、より読みやすく魅力的なコンテンツが作成できるようになります。

---
*This template helps ensure comprehensive PR documentation and review.*
```

## Command Line Output

```bash
$ ./ai-pr-draft.sh
[14:32:15] Step 0: Checking required tools…
[14:32:15]   ✓ gh found
[14:32:15]   ✓ claude found
[14:32:15]   ✓ jq found
[14:32:15] Step 1: Gathering repository context…
[14:32:16]   repo:            username/example-repo
[14:32:16]   base branch:     main
[14:32:16]   current branch:  feature/enhance-image-generation
[14:32:16] Step 2: Collecting commits and diff…
[14:32:16]   template found: .github/PULL_REQUEST_TEMPLATE.md
[14:32:16]   commits collected
[14:32:16]   diff length: 127 lines (truncated)
[14:32:16] Step 3: Generating PR title/body via Claude…
[14:32:16]   Sending prompt to Claude...
[14:32:18]   ✓ Extracted from code fence
[14:32:18]   JSON: {"title":"feat: Enhance image generation prompts for square banner layouts","body":"## 概要...
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

## Debug Mode Output

When running with `DEBUG=1`, you'll see additional information:

```bash
$ DEBUG=1 ./ai-pr-draft.sh
# ... (normal output above)
DEBUG: Claude raw output:
{"result": "{\"title\":\"feat: Enhance image generation prompts for square banner layouts\",\"body\":\"## 概要 (Overview)\\n\\n画像生成プロンプトにレ..."}
...
DEBUG: Extracted text length: 2951
DEBUG: Line count in RAW: 1
DEBUG: JSON_PAYLOAD length: 2847
DEBUG: JSON_PAYLOAD (first 300 chars):
{"title":"feat: Enhance image generation prompts for square banner layouts","body":"## 概要 (Overview)\\n\\n画像生成プロンプトにレイアウト制約を追加し、正方形バナーでのコンテンツの配置とreadabilityを向上させました。\\n\\n## 変更内容 (Changes)\\n\\n- [x] **機能追加...
...
```

This example demonstrates how the tool processes your changes and generates a comprehensive, bilingual PR that follows best practices for documentation and review.