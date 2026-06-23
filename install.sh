#!/usr/bin/env bash
# agent-skills-installer — один инсталлер для курируемого набора скиллов AI-агентов.
# Verified 2026-06-23. MIT.
#
# Usage:
#   ./install.sh                 # интерактивно: спросит, что ставить
#   ./install.sh --all           # поставить ВСЁ (skill + plugin + npm + git + odw)
#   ./install.sh --skills        # только skill-format паки (npx skills add)
#   ./install.sh --list          # показать каталог и выйти
#   ./install.sh --dry-run       # показать команды, ничего не выполняя
#   ./install.sh --only a,b,c    # поставить только указанные ключи (см. --list)
#
# Флаги-модификаторы можно комбинировать: ./install.sh --skills --dry-run
set -uo pipefail

DRY=0
RUN_SKILLS=0
RUN_PLUGINS=0
RUN_NPM=0
RUN_GIT=0
RUN_ODW=0
ONLY=""
INTERACTIVE=1

# --- каталог: ключ | тип | repo | описание -------------------------------------
# тип: skill | plugin | npm | git | odw
read -r -d '' CATALOG <<'EOF'
superpowers|plugin|obra/superpowers|Базовый фреймворк: brainstorming, TDD, debugging, планы, review, worktrees
understand-anything|plugin|Egonex-AI/Understand-Anything|Knowledge-graph репо + интерактивный дашборд архитектуры
oh-my-claudecode|npm|oh-my-claudecode|OMC: team/autopilot/ralph/ultrawork/ultragoal для Claude Code
oh-my-codex|npm|oh-my-codex|OMX: то же для OpenAI Codex CLI
open-dynamic-workflows|odw|xz1220/open-dynamic-workflows|ODW: JS-движок динамических воркфлоу (binary + skill)
thinking-partner|skill|mattnowdev/thinking-partner|150+ ментальных моделей, стресс-тест решений
ultragoal|skill|morphaxl/ultragoal|Самокорректирующиеся goal-loop с верификацией
last30days-skill|skill|mvanhorn/last30days-skill|Ресёрч темы по Reddit/X/YouTube/HN/Polymarket → summary
reverse-skill|skill|zhaoxuya520/reverse-skill|Реверс/пентест/security router (dual-use, авторизованно)
mattpocock-skills|skill|mattpocock/skills|TS/типы/архитектура, grill-with-docs, tdd, improve-architecture
taste-skill|skill|Leonxlnx/taste-skill|Anti-slop фронтенд + gpt-taste (GSAP, Awwwards-уровень)
shadcn-improve|skill|shadcn/improve|Аудит кодбейзы топ-моделью → планы для дешёвых исполнителей
vercel-agent-skills|skill|vercel-labs/agent-skills|Официальный пак Vercel: Next.js, деплой, web-design
ui-ux-pro-max|skill|nextlevelbuilder/ui-ux-pro-max-skill|Design-intelligence для professional UI/UX (multi-platform)
graphify|skill|safishamsi/graphify|Код/доки/PDF/картинки → queryable knowledge-graph
gstack|git|garrytan/gstack|23 спеца (CEO/Designer/QA/Security/Release) — слэш-команды
addyosmani-agent-skills|skill|addyosmani/agent-skills|Production engineering-скиллы для AI-агентов
ConardLi-garden-skills|skill|ConardLi/garden-skills|web-design, gpt-image-2, kb-retriever, beautiful-article
phuryn-pm-skills|skill|phuryn/pm-skills|100+ PM-скиллов: discovery→strategy→execution→launch→growth
kepano-obsidian-skills|skill|kepano/obsidian-skills|Obsidian CLI + Markdown/Bases/JSON Canvas
alirezarezvani-claude-skills|skill|alirezarezvani/claude-skills|330+ скиллов, 30+ агентов, 70+ команд
EOF

c_blue=$'\033[34m'; c_grn=$'\033[32m'; c_yel=$'\033[33m'; c_dim=$'\033[2m'; c_rst=$'\033[0m'

# счётчики итога
N_OK=0; N_MANUAL=0; N_FAIL=0
SUMMARY=""

log()  { printf '%s\n' "$*"; }
info() { printf '%s==>%s %s\n' "$c_blue" "$c_rst" "$*"; }
warn() { printf '%s ! %s%s\n' "$c_yel" "$*" "$c_rst"; }

run() {
  if [ "$DRY" = 1 ]; then printf '%s   $ %s%s\n' "$c_dim" "$*" "$c_rst"; return 0; fi
  "$@"
}
run_sh() { # для составных команд через строку
  if [ "$DRY" = 1 ]; then printf '%s   $ %s%s\n' "$c_dim" "$1" "$c_rst"; return 0; fi
  bash -c "$1"
}

print_list() {
  printf '%-30s %-8s %s\n' "KEY" "TYPE" "REPO / DESC"
  printf '%-30s %-8s %s\n' "---" "----" "-----------"
  while IFS='|' read -r key typ repo desc; do
    [ -z "$key" ] && continue
    printf '%-30s %-8s %s\n' "$key" "$typ" "$repo"
    printf '%-30s %-8s %s%s%s\n' "" "" "$c_dim" "$desc" "$c_rst"
  done <<< "$CATALOG"
}

want() { # ключ нужен? учитывает --only и type-фильтры
  local key="$1" typ="$2"
  if [ -n "$ONLY" ]; then
    case ",$ONLY," in *",$key,"*) return 0;; *) return 1;; esac
  fi
  case "$typ" in
    skill)  [ "$RUN_SKILLS"  = 1 ] && return 0;;
    plugin) [ "$RUN_PLUGINS" = 1 ] && return 0;;
    npm)    [ "$RUN_NPM"     = 1 ] && return 0;;
    git)    [ "$RUN_GIT"     = 1 ] && return 0;;
    odw)    [ "$RUN_ODW"     = 1 ] && return 0;;
  esac
  return 1
}

mark_ok()     { N_OK=$((N_OK+1));         SUMMARY+=$'\n'"  ${c_grn}✓${c_rst} $1"; }
mark_manual() { N_MANUAL=$((N_MANUAL+1)); SUMMARY+=$'\n'"  ${c_yel}→${c_rst} $1 (ручной шаг)"; }
mark_fail()   { N_FAIL=$((N_FAIL+1));     SUMMARY+=$'\n'"  ${c_yel}✗${c_rst} $1"; warn "$2"; }

install_one() {
  local key="$1" typ="$2" repo="$3"
  case "$typ" in
    skill)
      info "[skill] $key — npx skills add $repo"
      if [ "$DRY" = 1 ]; then run npx -y skills add "$repo" --yes; mark_ok "$key"; return 0; fi
      if npx -y skills add "$repo" --yes 2>/dev/null || npx -y skills add "$repo"; then
        mark_ok "$key"
      else
        mark_fail "$key" "$key: не удалось через npx skills (вручную: npx skills add $repo)"
      fi
      ;;
    plugin)
      info "[plugin] $key — Claude Code marketplace ($repo)"
      warn "Плагины ставятся ВНУТРИ Claude Code. Выполни в сессии:"
      log  "    /plugin marketplace add $repo"
      log  "    /plugin install ${key}"
      mark_manual "$key"
      ;;
    npm)
      info "[npm] $key — npm install -g $repo"
      if [ "$DRY" = 1 ]; then run npm install -g "$repo"; mark_ok "$key"; return 0; fi
      if npm install -g "$repo"; then
        mark_ok "$key"
        [ "$key" = "oh-my-claudecode" ] && log "    затем: omc setup"
        [ "$key" = "oh-my-codex" ]      && log "    затем: omx setup"
      else
        mark_fail "$key" "$key: npm install не удался"
      fi
      ;;
    git)
      info "[git] $key — clone в ~/.claude/skills/$key"
      local dest="$HOME/.claude/skills/$key"
      if [ -d "$dest/.git" ] && [ "$DRY" != 1 ]; then
        if run_sh "cd \"$dest\" && git pull --ff-only -q"; then
          mark_ok "$key (обновлён)"
        else
          mark_fail "$key" "$key: git pull не удался"
        fi
      elif run_sh "git clone --single-branch --depth 1 https://github.com/$repo.git \"$dest\" && cd \"$dest\" && ([ -x ./setup ] && ./setup || true)"; then
        mark_ok "$key"
      else
        mark_fail "$key" "$key: clone/setup не удался"
      fi
      ;;
    odw)
      info "[odw] $key — install.sh от $repo"
      if run_sh "curl -fsSL https://raw.githubusercontent.com/$repo/main/scripts/install.sh | sh"; then
        mark_ok "$key"
      else
        mark_fail "$key" "$key: установка ODW не удалась (см. https://github.com/$repo)"
      fi
      ;;
  esac
  return 0
}

usage() {
  cat <<'USAGE'
agent-skills-installer — один инсталлер для курируемого набора скиллов AI-агентов.

Usage:
  ./install.sh                 интерактивно: спросит, что ставить
  ./install.sh --all           поставить ВСЁ (skill + plugin + npm + git + odw)
  ./install.sh --skills        только skill-паки (npx skills add)
  ./install.sh --plugins       только Claude Code плагины (печатает /plugin-команды)
  ./install.sh --npm           только npm-паки (OMC/OMX)
  ./install.sh --git           только git-паки (gstack)
  ./install.sh --odw           только open-dynamic-workflows
  ./install.sh --only a,b,c    только указанные ключи (см. --list)
  ./install.sh --list          показать каталог и выйти
  ./install.sh --dry-run       показать команды, ничего не выполняя
  -h | --help                  эта справка

Флаги комбинируются: ./install.sh --skills --dry-run
USAGE
}

# --- разбор аргументов ---------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --all)      RUN_SKILLS=1; RUN_PLUGINS=1; RUN_NPM=1; RUN_GIT=1; RUN_ODW=1; INTERACTIVE=0;;
    --skills)   RUN_SKILLS=1; INTERACTIVE=0;;
    --plugins)  RUN_PLUGINS=1; INTERACTIVE=0;;
    --npm)      RUN_NPM=1; INTERACTIVE=0;;
    --git)      RUN_GIT=1; INTERACTIVE=0;;
    --odw)      RUN_ODW=1; INTERACTIVE=0;;
    --only)     ONLY="${2:-}"; shift; RUN_SKILLS=1; RUN_PLUGINS=1; RUN_NPM=1; RUN_GIT=1; RUN_ODW=1; INTERACTIVE=0;;
    --dry-run)  DRY=1;;
    --list)     print_list; exit 0;;
    -h|--help)  usage; exit 0;;
    *) warn "неизвестный флаг: $1"; usage; exit 2;;
  esac
  shift
done

# --- интерактивный режим -------------------------------------------------------
if [ "$INTERACTIVE" = 1 ]; then
  echo "agent-skills-installer — что ставим?"
  echo "  1) Всё (--all)"
  echo "  2) Только skill-паки (npx skills add)"
  echo "  3) Показать каталог и выйти (--list)"
  printf 'Выбор [1/2/3]: '
  read -r ans
  case "$ans" in
    1) RUN_SKILLS=1; RUN_PLUGINS=1; RUN_NPM=1; RUN_GIT=1; RUN_ODW=1;;
    2) RUN_SKILLS=1;;
    3) print_list; exit 0;;
    *) warn "отмена"; exit 0;;
  esac
fi

# --- проверки окружения --------------------------------------------------------
command -v node >/dev/null 2>&1 || warn "node не найден — skill/npx-паки могут не поставиться"
command -v git  >/dev/null 2>&1 || warn "git не найден — git-паки (gstack) не поставятся"

[ "$DRY" = 1 ] && warn "DRY-RUN: команды только печатаются, ничего не выполняется"

# --- основной цикл -------------------------------------------------------------
selected=0
while IFS='|' read -r key typ repo desc; do
  [ -z "$key" ] && continue
  want "$key" "$typ" || continue
  selected=$((selected+1))
  install_one "$key" "$typ" "$repo"
done <<< "$CATALOG"

if [ "$selected" = 0 ]; then
  warn "Ничего не выбрано. Подсказка: ./install.sh --all  или  --skills  (или --list)."
  exit 0
fi

# --- сводка --------------------------------------------------------------------
echo
info "Сводка:${SUMMARY}"
echo
printf '%s установлено: %d%s | %s ручных: %d%s | %s ошибок: %d%s\n' \
  "$c_grn" "$N_OK" "$c_rst" "$c_yel" "$N_MANUAL" "$c_rst" "$c_yel" "$N_FAIL" "$c_rst"
[ "$N_MANUAL" -gt 0 ] && echo "Плагины Claude Code ставятся командами /plugin внутри сессии (см. выше)."
[ "$DRY" = 1 ] && warn "Это был DRY-RUN — реальная установка не выполнялась."
[ "$N_FAIL" -gt 0 ] && exit 1
exit 0
