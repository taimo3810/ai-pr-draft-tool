#!/usr/bin/env bash
###############################################################################
# ai-pr-draft.sh
#   Generate PR title/body with Claude and create Draft PR via gh CLI.
#   - Aborts on protected branches (main, develop, staging).
#   - Logs each step; DEBUG=1 enables shell trace.
#   - Designed to work with any GitHub repository.
###############################################################################

# ---- Runtime options ---------------------------------------------------------
DEBUG=${DEBUG:-0}            # DEBUG=1 ./script … で set -x 有効化
TRACE_COLOR="\033[1;34m"   # 青
RESET_COLOR="\033[0m"

set -euo pipefail
[[ $DEBUG -eq 1 ]] && set -x

# ---- Helper ------------------------------------------------------------------
log() { echo -e "${TRACE_COLOR}[$(date +%H:%M:%S)] $*${RESET_COLOR}"; }
trap 'log "❌ Error at line ${LINENO}: \"${BASH_COMMAND}\""' ERR

# ---- Tool checks -------------------------------------------------------------
log "Step 0: Checking required tools…"
for cmd in gh claude jq; do
  command -v "$cmd" >/dev/null || { echo "❌ $cmd が見つかりません" >&2; exit 1; }
  log "  ✓ $cmd found"
done

# ---- Variables ---------------------------------------------------------------
log "Step 1: Gathering repository context…"
REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)

# Automatically detect the default branch
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
if [[ -z "$DEFAULT_BRANCH" ]]; then
  # Fallback to main if unable to detect
  DEFAULT_BRANCH="main"
  log "  ⚠️  Could not detect default branch, using 'main'"
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
log "  repo:            $REPO"
log "  base branch:     $DEFAULT_BRANCH"
log "  current branch:  $BRANCH"

# ---- Protected branch guard --------------------------------------------------
if [[ "$BRANCH" =~ ^(main|master|develop|staging|production)$ ]]; then
  echo "❌ '$BRANCH' は保護ブランチのため PR を直接作成できません。別ブランチで作業してください。" >&2
  exit 1
fi

# ---- Collect commits & diff --------------------------------------------------
log "Step 2: Collecting commits and diff…"
COMMITS=$(git log "$DEFAULT_BRANCH..$BRANCH" --pretty=format:"- %s (%an, %ad)" --date=short | jq -Rs '.')
DIFF_RAW=$( (git diff "$DEFAULT_BRANCH..$BRANCH" || true) | head -5000 )
DIFF=$(printf '%s' "$DIFF_RAW" | jq -Rs '.')
log "  commits collected"
log "  diff length: $(echo "$DIFF_RAW" | wc -l) lines (truncated)"

# ---- Pull‑request template ---------------------------------------------------
TPL_PATH=.github/PULL_REQUEST_TEMPLATE.md
if [[ -f "$TPL_PATH" ]]; then
  log "  template found: $TPL_PATH"
  TPL_CONTENT=$(cat "$TPL_PATH")
else
  log "  no template found, using default structure"
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

# ---- Build Claude prompt -----------------------------------------------------
log "Step 3: Generating PR title/body via Claude…"

PROMPT="あなたは日本語で Conventional Commits 準拠の PR を作成するシニアエンジニアです。
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

# ---- Query Claude with retry logic -------------------------------------------
log "  Sending prompt to Claude..."
CLAUDE_JSON=""
MAX_RETRIES=3
RETRY_COUNT=0

while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  log "  Attempt $RETRY_COUNT/$MAX_RETRIES..."
  
  if CLAUDE_JSON=$(claude -p "$PROMPT" --output-format json 2>&1); then
    log "  ✓ Claude responded successfully"
    break
  else
    log "  ⚠️  Claude request failed (attempt $RETRY_COUNT/$MAX_RETRIES)"
    if [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; then
      SLEEP_TIME=$((2 ** (RETRY_COUNT - 1)))  # Exponential backoff: 1, 2, 4 seconds
      log "  Retrying in ${SLEEP_TIME} seconds..."
      sleep $SLEEP_TIME
    else
      echo "❌ Claude request failed after $MAX_RETRIES attempts:" >&2
      echo "$CLAUDE_JSON" >&2
      exit 1
    fi
  fi
done

# Debug: Show Claude's raw output if DEBUG=1
if [[ $DEBUG -eq 1 ]]; then
  echo "DEBUG: Claude raw output:" >&2
  echo "$CLAUDE_JSON" | head -c 1000 >&2
  echo "..." >&2
fi

# Check if response is array format (old) or single object format (new)
if echo "$CLAUDE_JSON" | jq -e 'type == "array"' >/dev/null 2>&1; then
  # Old format: array of events
  RAW=$(echo "$CLAUDE_JSON" | jq -r '[.[] | select(.type=="assistant")][-1].message.content[0].text')
elif echo "$CLAUDE_JSON" | jq -e 'has("result")' >/dev/null 2>&1; then
  # New format: single object with result field
  RAW=$(echo "$CLAUDE_JSON" | jq -r '.result')
else
  # Fallback: treat entire response as text
  RAW="$CLAUDE_JSON"
fi

# Debug: Show extracted text with newline analysis
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

# ---- Extract JSON from Claude response ---------------------------------------
# Handle escaped JSON from new Claude CLI format
JSON_PAYLOAD=""

# First, try to extract from code fence
if [[ "$RAW" =~ \`\`\`json[[:space:]]*(.+)\`\`\` ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[1]}"
  # Unescape the JSON
  JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
  log "  ✓ Extracted from code fence"
# Look for escaped JSON pattern (new Claude CLI format)
elif [[ "$RAW" =~ \{\\\"title\\\".*\\\"body\\\".*\} ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[0]}"
  # Unescape the JSON
  JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
  log "  ✓ Found escaped JSON object"
# Look for regular JSON pattern
elif [[ "$RAW" =~ (\{[^}]*\"title\"[^}]*\"body\"[^}]*\}) ]]; then
  JSON_PAYLOAD="${BASH_REMATCH[1]}"
  log "  ✓ Found JSON object"
else
  log "  ⚠️  Using entire response"
  JSON_PAYLOAD="$RAW"
fi

# Clean up - only remove carriage returns, keep newlines for proper JSON parsing
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | tr -d '\r' | sed 's/[[:space:]]*$//')
log "  JSON: $(echo "$JSON_PAYLOAD" | head -c 100)..."

# Debug: Show JSON payload if DEBUG=1
if [[ $DEBUG -eq 1 ]]; then
  echo "DEBUG: JSON_PAYLOAD length: $(echo "$JSON_PAYLOAD" | wc -c)" >&2
  echo "DEBUG: JSON_PAYLOAD (first 300 chars):" >&2
  echo "$JSON_PAYLOAD" | head -c 300 >&2
  echo "..." >&2
fi

# ---- Clean and validate JSON -------------------------------------------------
# Remove any trailing commas but preserve newlines for proper JSON parsing
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed 's/,$//' | tr -d '\r')

# Try multiple parsing methods in order of preference
TITLE=""
BODY=""

# Method 1: Try jq with proper JSON
if TITLE=$(echo "$JSON_PAYLOAD" | jq -r '.title' 2>/dev/null) && 
   BODY=$(echo "$JSON_PAYLOAD" | jq -r '.body' 2>/dev/null) && 
   [[ -n "$TITLE" && -n "$BODY" && "$TITLE" != "null" && "$BODY" != "null" ]]; then
  log "  ✓ Successfully parsed JSON with jq"
  
# Method 2: Try Python json module (more lenient than jq)
elif command -v python3 >/dev/null 2>&1; then
  log "  ⚠️  jq parsing failed, trying Python json..."
  
  # Create a temporary file to avoid shell escaping issues
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
        # Use a unique separator to avoid conflicts
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
    log "  ✓ Successfully parsed JSON with Python"
  else
    rm -f "$TEMP_JSON"
  fi
fi

# Method 3: Regex fallback if both JSON parsers fail
if [[ -z "$TITLE" || -z "$BODY" ]]; then
  log "  ⚠️  JSON parsing failed, trying regex fallback..."
  
  # Debug: Show what we're trying to parse
  if [[ $DEBUG -eq 1 ]]; then
    echo "DEBUG: JSON_PAYLOAD length: $(echo "$JSON_PAYLOAD" | wc -c)" >&2
    echo "DEBUG: First 200 chars: $(echo "$JSON_PAYLOAD" | head -c 200)" >&2
    echo "DEBUG: Last 200 chars: $(echo "$JSON_PAYLOAD" | tail -c 200)" >&2
  fi
  
  # More flexible title extraction - handle both escaped and unescaped JSON
  if [[ "$JSON_PAYLOAD" =~ \"title\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] || 
     [[ "$JSON_PAYLOAD" =~ \'title\'[[:space:]]*:[[:space:]]*\'([^\']+)\' ]] ||
     [[ "$JSON_PAYLOAD" =~ title[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] ||
     [[ "$RAW" =~ \\\"title\\\"[[:space:]]*:[[:space:]]*\\\"([^\\\"]+)\\\" ]]; then
    TITLE="${BASH_REMATCH[1]}"
    TITLE=$(echo "$TITLE" | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
    log "    ✓ Extracted title: ${TITLE:0:50}..."
  else
    echo "❌ Could not extract title from JSON." >&2
    echo "Raw response (first 500 chars):" >&2
    echo "$RAW" | head -c 500 >&2
    echo "" >&2
    echo "JSON payload:" >&2
    echo "$JSON_PAYLOAD" >&2
    exit 1
  fi
  
  # More flexible body extraction - handle both escaped and unescaped JSON
  if [[ "$JSON_PAYLOAD" =~ \"body\"[[:space:]]*:[[:space:]]*\"(.*)\"\}?[[:space:]]*$ ]] ||
     [[ "$JSON_PAYLOAD" =~ \"body\"[[:space:]]*:[[:space:]]*\"(.*)\"[[:space:]]*\} ]] ||
     [[ "$JSON_PAYLOAD" =~ body[[:space:]]*:[[:space:]]*\"(.*)\" ]] ||
     [[ "$RAW" =~ \\\"body\\\"[[:space:]]*:[[:space:]]*\\\"(.*)\\\" ]]; then
    BODY="${BASH_REMATCH[1]}"
    # Properly unescape JSON string - handle \n, \t, \", \\
    BODY=$(echo "$BODY" | sed 's/\\n/\
/g' | sed 's/\\t/	/g' | sed 's/\\"/"/g' | sed 's/\\\\/\\/g')
    log "    ✓ Extracted body: ${#BODY} characters"
    
    # Debug: Show processed body if DEBUG=1
    if [[ $DEBUG -eq 1 ]]; then
      echo "DEBUG: Processed body (first 500 chars):" >&2
      echo "$BODY" | head -c 500 >&2
      echo "..." >&2
    fi
  else
    echo "❌ Could not extract body from JSON." >&2
    echo "Raw response (first 500 chars):" >&2
    echo "$RAW" | head -c 500 >&2
    echo "" >&2
    echo "JSON payload:" >&2
    echo "$JSON_PAYLOAD" >&2
    exit 1
  fi
  
  log "  ✓ Successfully extracted using regex fallback"
fi

# Final validation
if [[ -z "$TITLE" || -z "$BODY" ]]; then
  echo "❌ Failed to extract title or body from response:" >&2
  echo "$RAW" >&2
  exit 1
fi

# ---- Display extracted information -------------------------------------------
log "Step 4: Extracted PR information"
log "  Title: $TITLE"
log "  Body length: $(echo "$BODY" | wc -c) characters"

# ---- Push branch to remote ---------------------------------------------------
log "Step 5: Publishing branch to remote…"
if git push -u origin "$BRANCH" 2>/dev/null; then
  log "  ✓ Branch published successfully"
elif git push origin "$BRANCH" 2>/dev/null; then
  log "  ✓ Branch updated on remote"
else
  echo "❌ Failed to push branch to remote. Please check your permissions." >&2
  exit 1
fi

# ---- Create Draft PR ---------------------------------------------------------
log "Step 6: Creating draft PR…"

# Debug: Check repository permissions first
log "  Checking repository permissions..."
if [[ $DEBUG -eq 1 ]] || ! gh pr create --help >/dev/null 2>&1; then
  log "  DEBUG: Current user: $(gh api user --jq .login)"
  log "  DEBUG: Repository permissions:"
  gh api "repos/$REPO" --jq '.permissions // "No permissions info available"' || log "  ⚠️  Could not check repository permissions"
fi

# Save body to temporary file to avoid shell escaping issues
TEMP_BODY=$(mktemp)
echo "$BODY" > "$TEMP_BODY"

log "  Preparing PR creation with:"
log "    Title: $TITLE"
log "    Base: $DEFAULT_BRANCH"
log "    Head: $BRANCH"
log "    Body file: $TEMP_BODY ($(wc -c < "$TEMP_BODY") bytes)"

# Attempt to create PR with detailed error capture
log "  Executing gh pr create command..."
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
  log "✅ Draft PR created successfully!"
  log "   URL: $PR_URL"
  rm -f "$TEMP_BODY"
else
  echo "❌ Failed to create PR (exit code: $PR_CREATE_EXIT_CODE)" >&2
  echo "Error output:" >&2
  echo "$PR_CREATE_OUTPUT" >&2
  echo "" >&2
  echo "Debug information:" >&2
  echo "  Repository: $REPO" >&2
  echo "  Base branch: $DEFAULT_BRANCH" >&2
  echo "  Head branch: $BRANCH" >&2
  echo "  Title: $TITLE" >&2
  echo "  Body preview (first 10 lines):" >&2
  echo "$BODY" | head -10 >&2
  echo "" >&2
  echo "Checking GitHub authentication..." >&2
  gh auth status >&2 || echo "Authentication check failed" >&2
  echo "" >&2
  echo "Checking if branches exist on remote..." >&2
  git ls-remote --heads origin "$BRANCH" >&2 || echo "Head branch not found on remote" >&2
  git ls-remote --heads origin "$DEFAULT_BRANCH" >&2 || echo "Base branch not found on remote" >&2
  rm -f "$TEMP_BODY"
  exit 1
fi

log "🎉 Process completed successfully!"