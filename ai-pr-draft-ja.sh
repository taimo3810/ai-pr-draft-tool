#!/usr/bin/env bash
###############################################################################
# ai-pr-draft-ja.sh
#   Claude を使用してPRタイトル/本文を生成し、gh CLIでドラフトPRを作成します。
#   - 保護ブランチ (main, develop, staging) では中止します。
#   - 各ステップをログ出力; DEBUG=1 でシェルトレースを有効化。
#   - あらゆるGitHubリポジトリで動作するよう設計されています。
###############################################################################

# ---- 実行時オプション ---------------------------------------------------------
DEBUG=${DEBUG:-0}            # DEBUG=1 ./script … で set -x 有効化
TRACE_COLOR="\033[1;34m"   # 青
RESET_COLOR="\033[0m"

set -euo pipefail
[[ $DEBUG -eq 1 ]] && set -x

# ---- ヘルパー関数 -------------------------------------------------------------
log() { echo -e "${TRACE_COLOR}[$(date +%H:%M:%S)] $*${RESET_COLOR}"; }
trap 'log "❌ Error at line ${LINENO}: \"${BASH_COMMAND}\""' ERR

# ---- ツールチェック -----------------------------------------------------------
log "ステップ 0: 必要なツールを確認中…"
for cmd in gh claude jq; do
  command -v "$cmd" >/dev/null || { echo "❌ $cmd が見つかりません" >&2; exit 1; }
  log "  ✓ $cmd が見つかりました"
done

# ---- 変数設定 -----------------------------------------------------------------
log "ステップ 1: リポジトリ情報を収集中…"
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# デフォルトブランチを自動検出
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
if [[ -z "$DEFAULT_BRANCH" ]]; then
  # 検出できない場合は main にフォールバック
  DEFAULT_BRANCH="main"
  log "  ⚠️  デフォルトブランチを検出できませんでした、'main' を使用します"
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
log "  リポジトリ:        $REPO"
log "  ベースブランチ:    $DEFAULT_BRANCH"
log "  現在のブランチ:    $BRANCH"

# ---- 保護ブランチガード -------------------------------------------------------
if [[ "$BRANCH" =~ ^(main|master|develop|staging|production)$ ]]; then
  echo "❌ '$BRANCH' は保護ブランチのため PR を直接作成できません。別ブランチで作業してください。" >&2
  exit 1
fi

# ---- コミット & 差分収集 ------------------------------------------------------
log "ステップ 2: コミットと差分を収集中…"
COMMITS=$(git log "$DEFAULT_BRANCH..$BRANCH" --pretty=format:"- %s (%an, %ad)" --date=short | jq -Rs '.')
DIFF_RAW=$( (git diff "$DEFAULT_BRANCH..$BRANCH" || true) | head -5000 )
DIFF=$(printf '%s' "$DIFF_RAW" | jq -Rs '.')
log "  コミットを収集しました"
log "  差分の長さ: $(echo "$DIFF_RAW" | wc -l) 行 (切り詰め済み)"

# ---- プルリクエストテンプレート -----------------------------------------------
TPL_PATH=.github/PULL_REQUEST_TEMPLATE_JA.md
if [[ -f "$TPL_PATH" ]]; then
  log "  テンプレートが見つかりました: $TPL_PATH"
  TPL_CONTENT=$(cat "$TPL_PATH")
else
  log "  テンプレートが見つかりません、デフォルト構造を使用します"
  TPL_CONTENT="## 概要 (Overview)

変更の目的や背景を簡潔に説明してください。

## 変更内容 (Changes)

具体的な変更内容をリスト形式で記述してください。

## テスト (Testing)

実施したテストについて記述してください。

## 確認事項 (Checklist)

- [ ] 機能要件は実装されたか
- [ ] テストは追加/更新されたか
- [ ] ドキュメントは更新されたか (必要な場合)"
fi

# ---- Claude プロンプト構築 ---------------------------------------------------
log "ステップ 3: Claude を使用してPRタイトル/本文を生成中…"

PROMPT="あなたは日本語で Conventional Commits 準拠の PR を作成するシニアエンジニアです。
いかなるコマンドも実行しないように、ただ、与えられた情報をreadするのみ。
以下のPRテンプレートに従って、git commitログとdiffを分析し、PR titleとbodyを生成してください。

Repository: $REPO
Branch: $BRANCH -> $DEFAULT_BRANCH

## Recent commits:
$COMMITS

## Git diff (truncated):
$DIFF

## PR Template to follow:
$TPL_CONTENT

**重要な指示:**
1. PRテンプレートの構造に従って本文を作成してください
2. 変更内容に応じて適切なチェックボックスを選択してください
3. 各セクションの間には必ず空行を入れてください
4. 出力は以下のJSON形式で返してください：

\`\`\`json
{
  \"title\": \"feat: 機能の説明\",
  \"body\": \"## 概要 (Overview)\\n\\n変更内容の説明...\\n\\n## 変更の種類 (Type of change)\\n\\n- [x] 新機能...\"
}
\`\`\`

**JSON形式の注意点:**
- 改行は必ず \\\\n でエスケープしてください
- 各セクション間の空行も \\\\n\\\\n で表現してください
- ダブルクォートは \\\\\" でエスケープしてください
- 1行のJSONとして出力してください（改行を含まない）
- 必ずコードフェンス（\`\`\`json）で囲んでください"

# ---- リトライロジック付きClaude クエリ ----------------------------------------
log "  Claude にプロンプトを送信中..."
CLAUDE_JSON=""
MAX_RETRIES=3
RETRY_COUNT=0

while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  log "  試行 $RETRY_COUNT/$MAX_RETRIES..."
  
  if CLAUDE_JSON=$(claude -p "$PROMPT" --permission-mode acceptEdits --output-format json 2>&1); then
    log "  ✓ Claude が正常に応答しました"
    break
  else
    log "  ⚠️  Claude リクエストが失敗しました (試行 $RETRY_COUNT/$MAX_RETRIES)"
    if [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; then
      SLEEP_TIME=$((2 ** (RETRY_COUNT - 1)))  # 指数バックオフ: 1, 2, 4 秒
      log "  ${SLEEP_TIME} 秒後に再試行します..."
      sleep $SLEEP_TIME
    else
      echo "❌ $MAX_RETRIES 回の試行後、Claude リクエストが失敗しました:" >&2
      echo "$CLAUDE_JSON" >&2
      exit 1
    fi
  fi
done

# デバッグ: DEBUG=1 の場合、Claude の生出力を表示
if [[ $DEBUG -eq 1 ]]; then
  echo "DEBUG: Claude raw output:" >&2
  echo "$CLAUDE_JSON" | head -c 1000 >&2
  echo "..." >&2
fi

# レスポンスが配列形式（旧）か単一オブジェクト形式（新）かをチェック
if echo "$CLAUDE_JSON" | jq -e 'type == "array"' >/dev/null 2>&1; then
  # 旧形式: イベントの配列
  RAW=$(echo "$CLAUDE_JSON" | jq -r '[.[] | select(.type=="assistant")][-1].message.content[0].text')
elif echo "$CLAUDE_JSON" | jq -e 'has("result")' >/dev/null 2>&1; then
  # 新形式: result フィールドを持つ単一オブジェクト
  RAW=$(echo "$CLAUDE_JSON" | jq -r '.result')
else
  # フォールバック: レスポンス全体をテキストとして扱う
  RAW="$CLAUDE_JSON"
fi

# デバッグ: 改行解析付きで抽出されたテキストを表示
if [[ $DEBUG -eq 1 ]]; then
  echo "DEBUG: Extracted text length: $(echo "$RAW" | wc -c)" >&2
  echo "DEBUG: Line count in RAW: $(echo "$RAW" | wc -l)" >&2
  echo "DEBUG: Checking for \\n sequences in RAW:" >&2
  echo "$RAW" | head -c 800 | sed 's/\\n/<NEWLINE>/g' >&2
  echo "..." >&2
  echo "DEBUG: First 500 chars of RAW:" >&2
  echo "$RAW" | head -c 500 >&2
  echo "..." >&2
fi

# ---- Claude レスポンスからJSONを抽出 ------------------------------------------
# 新しい Claude CLI 形式のエスケープされたJSONを処理
JSON_PAYLOAD=""

# まず、コードフェンスからの抽出を試行
if [[ "$RAW" =~ \`\`\`json[[:space:]]*(.+)\`\`\` ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[1]}"
  # JSON をアンエスケープ
  JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
  log "  ✓ コードフェンスから抽出しました"
# エスケープされたJSONパターンを検索（新しいClaude CLI形式）
elif [[ "$RAW" =~ \{\\\"title\\\".*\\\"body\\\".*\} ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[0]}"
  # JSON をアンエスケープ
  JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
  log "  ✓ エスケープされたJSONオブジェクトが見つかりました"
# 通常のJSONパターンを検索
elif [[ "$RAW" =~ (\{[^}]*\"title\"[^}]*\"body\"[^}]*\}) ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[1]}"
  log "  ✓ JSONオブジェクトが見つかりました"
else
  log "  ⚠️  レスポンス全体を使用します"
  JSON_PAYLOAD="$RAW"
fi

# クリーンアップ - 復帰文字のみ削除、適切なJSON解析のため改行は保持
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | tr -d '\r' | sed 's/[[:space:]]*$//')
log "  JSON: $(echo "$JSON_PAYLOAD" | head -c 100)..."

# デバッグ: DEBUG=1 の場合、JSONペイロードを表示
if [[ $DEBUG -eq 1 ]]; then
  echo "DEBUG: JSON_PAYLOAD length: $(echo "$JSON_PAYLOAD" | wc -c)" >&2
  echo "DEBUG: JSON_PAYLOAD (first 300 chars):" >&2
  echo "$JSON_PAYLOAD" | head -c 300 >&2
  echo "..." >&2
fi

# ---- JSON クリーンアップと検証 -----------------------------------------------
# 末尾のカンマを削除するが、適切なJSON解析のため改行は保持
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/,$//' | tr -d '\r')

# 優先順位に従って複数の解析方法を試行
TITLE=""
BODY=""

# 方法 1: 適切なJSONでjqを試行
if TITLE=$(echo "$JSON_PAYLOAD" | jq -r '.title' 2>/dev/null) && 
   BODY=$(echo "$JSON_PAYLOAD" | jq -r '.body' 2>/dev/null) && 
   [[ -n "$TITLE" && -n "$BODY" && "$TITLE" != "null" && "$BODY" != "null" ]]; then
  log "  ✓ jq でJSONの解析に成功しました"
  
# 方法 2: Python json モジュールを試行（jqより寛容）
elif command -v python3 >/dev/null 2>&1; then
  log "  ⚠️  jq 解析が失敗しました、Python json を試行中..."
  
  # シェルエスケープ問題を回避するため一時ファイルを作成
  TEMP_JSON=$(mktemp)
  echo "$JSON_PAYLOAD" > "$TEMP_JSON"
  
  if PYTHON_RESULT=$(python3 -c "
import json
import sys
try:
    with open('$TEMP_JSON', 'r') as f:
        content = f.read().strip()
    data = json.loads(content)
    if 'title' in data and 'body' in data and data['title'] and data['body']:
        # 競合を避けるため一意のセパレータを使用
        print(data['title'] + '###SEPARATOR###' + data['body'])
    else:
        sys.exit(1)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null); then
    TITLE=$(echo "$PYTHON_RESULT" | cut -d'#' -f1)
    BODY=$(echo "$PYTHON_RESULT" | cut -d'#' -f3-)
    rm -f "$TEMP_JSON"
    log "  ✓ Python でJSONの解析に成功しました"
  else
    rm -f "$TEMP_JSON"
  fi
fi

# 方法 3: 両方のJSONパーサーが失敗した場合の正規表現フォールバック
if [[ -z "$TITLE" || -z "$BODY" ]]; then
  log "  ⚠️  JSON解析が失敗しました、正規表現フォールバックを試行中..."
  
  # デバッグ: 解析しようとしているものを表示
  if [[ $DEBUG -eq 1 ]]; then
    echo "DEBUG: JSON_PAYLOAD length: $(echo "$JSON_PAYLOAD" | wc -c)" >&2
    echo "DEBUG: First 200 chars: $(echo "$JSON_PAYLOAD" | head -c 200)" >&2
    echo "DEBUG: Last 200 chars: $(echo "$JSON_PAYLOAD" | tail -c 200)" >&2
  fi
  
  # より柔軟なタイトル抽出 - エスケープされたJSONと非エスケープJSONの両方を処理
  if [[ "$JSON_PAYLOAD" =~ \"title\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || 
     [[ "$JSON_PAYLOAD" =~ \'title\'[[:space:]]*:[[:space:]]*\'([^\']+)\' ]] ||
     [[ "$JSON_PAYLOAD" =~ title[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] ||
     [[ "$RAW" =~ \\\"title\\\"[[:space:]]*:[[:space:]]*\\\"([^\\\"]+)\\\" ]]; then
    TITLE="${BASH_REMATCH[1]}"
    TITLE=$(echo "$TITLE" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
    log "    ✓ タイトルを抽出しました: ${TITLE:0:50}..."
  else
    echo "❌ JSONからタイトルを抽出できませんでした。" >&2
    echo "生レスポンス（最初の500文字）:" >&2
    echo "$RAW" | head -c 500 >&2
    echo "" >&2
    echo "JSONペイロード:" >&2
    echo "$JSON_PAYLOAD" >&2
    exit 1
  fi
  
  # より柔軟な本文抽出 - エスケープされたJSONと非エスケープJSONの両方を処理
  if [[ "$JSON_PAYLOAD" =~ \"body\"[[:space:]]*:[[:space:]]*\"(.*)\"\}?[[:space:]]*$ ]] ||
     [[ "$JSON_PAYLOAD" =~ \"body\"[[:space:]]*:[[:space:]]*\"(.*)\"[[:space:]]*\} ]] ||
     [[ "$JSON_PAYLOAD" =~ body[[:space:]]*:[[:space:]]*\"(.*)\" ]] ||
     [[ "$RAW" =~ \\\"body\\\"[[:space:]]*:[[:space:]]*\\\"(.*)\\\" ]]; then
    BODY="${BASH_REMATCH[1]}"
    # JSON文字列を適切にアンエスケープ - \n, \t, \", \\ を処理
    BODY=$(echo "$BODY" | sed 's/\\n/\
/g' | sed 's/\\t/	/g' | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
    log "    ✓ 本文を抽出しました: ${#BODY} 文字"
    
    # デバッグ: DEBUG=1 の場合、処理された本文を表示
    if [[ $DEBUG -eq 1 ]]; then
      echo "DEBUG: Processed body (first 500 chars):" >&2
      echo "$BODY" | head -c 500 >&2
      echo "..." >&2
    fi
  else
    echo "❌ JSONから本文を抽出できませんでした。" >&2
    echo "生レスポンス（最初の500文字）:" >&2
    echo "$RAW" | head -c 500 >&2
    echo "" >&2
    echo "JSONペイロード:" >&2
    echo "$JSON_PAYLOAD" >&2
    exit 1
  fi
  
  log "  ✓ 正規表現フォールバックを使用して抽出に成功しました"
fi

# 最終検証
if [[ -z "$TITLE" || -z "$BODY" ]]; then
  echo "❌ レスポンスからタイトルまたは本文の抽出に失敗しました:" >&2
  echo "$RAW" >&2
  exit 1
fi

# ---- 抽出された情報を表示 -----------------------------------------------------
log "ステップ 4: PR情報を抽出しました"
log "  タイトル: $TITLE"
log "  本文の長さ: $(echo "$BODY" | wc -c) 文字"

# ---- ブランチをリモートにプッシュ ---------------------------------------------
log "ステップ 5: ブランチをリモートに公開中…"
if git push -u origin "$BRANCH" 2>/dev/null; then
  log "  ✓ ブランチの公開に成功しました"
elif git push origin "$BRANCH" 2>/dev/null; then
  log "  ✓ リモートのブランチが更新されました"
else
  echo "❌ ブランチのリモートプッシュに失敗しました。権限を確認してください。" >&2
  exit 1
fi

# ---- ドラフトPR作成 -----------------------------------------------------------
log "ステップ 6: ドラフトPRを作成中…"

# デバッグ: まずリポジトリ権限をチェック
log "  リポジトリ権限を確認中..."
if [[ $DEBUG -eq 1 ]] || ! gh pr create --help >/dev/null 2>&1; then
  log "  DEBUG: 現在のユーザー: $(gh api user --jq .login)"
  log "  DEBUG: リポジトリ権限:"
  gh api "repos/$REPO" --jq '.permissions // "権限情報が利用できません"' || log "  ⚠️  リポジトリ権限を確認できませんでした"
fi

# シェルエスケープ問題を回避するため本文を一時ファイルに保存
TEMP_BODY=$(mktemp)
echo "$BODY" > "$TEMP_BODY"

log "  PR作成の準備中:"
log "    タイトル: $TITLE"
log "    ベース: $DEFAULT_BRANCH"
log "    ヘッド: $BRANCH"
log "    本文ファイル: $TEMP_BODY ($(wc -c < "$TEMP_BODY") バイト)"

# 詳細なエラーキャプチャ付きでPR作成を試行
log "  gh pr create コマンドを実行中..."
PR_CREATE_OUTPUT=$(gh pr create \
  --title "$TITLE" \
  --body-file "$TEMP_BODY" \
  --base "$DEFAULT_BRANCH" \
  --head "$BRANCH" \
  --draft \
  2>&1)
PR_CREATE_EXIT_CODE=$?

if [[ $PR_CREATE_EXIT_CODE -eq 0 ]]; then
  PR_URL="$PR_CREATE_OUTPUT"
  log "✅ ドラフトPRが正常に作成されました！"
  log "   URL: $PR_URL"
  rm -f "$TEMP_BODY"
else
  echo "❌ PRの作成に失敗しました (終了コード: $PR_CREATE_EXIT_CODE)" >&2
  echo "エラー出力:" >&2
  echo "$PR_CREATE_OUTPUT" >&2
  echo "" >&2
  echo "デバッグ情報:" >&2
  echo "  リポジトリ: $REPO" >&2
  echo "  ベースブランチ: $DEFAULT_BRANCH" >&2
  echo "  ヘッドブランチ: $BRANCH" >&2
  echo "  タイトル: $TITLE" >&2
  echo "  本文プレビュー（最初の10行）:" >&2
  echo "$BODY" | head -10 >&2
  echo "" >&2
  echo "GitHub認証を確認中..." >&2
  gh auth status >&2 || echo "認証チェックが失敗しました" >&2
  echo "" >&2
  echo "リモートにブランチが存在するかを確認中..." >&2
  git ls-remote --heads origin "$BRANCH" >&2 || echo "ヘッドブランチがリモートに見つかりません" >&2
  git ls-remote --heads origin "$DEFAULT_BRANCH" >&2 || echo "ベースブランチがリモートに見つかりません" >&2
  rm -f "$TEMP_BODY"
  exit 1
fi

log "🎉 処理が正常に完了しました！" 