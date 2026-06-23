# agent-skills-installer

[![ci](https://github.com/agisota/agent-skills-installer/actions/workflows/ci.yml/badge.svg)](https://github.com/agisota/agent-skills-installer/actions/workflows/ci.yml)

Один инсталлер для курируемого набора из **21 пака скиллов** для AI-агентов
(Claude Code, Codex, Cursor, OpenCode, Gemini CLI и др.). Все репозитории
проверены и живые на 2026-06-23.

Кроссплатформенно: **macOS · Linux · Windows · WSL**. Два эквивалентных энтрипоинта —
`install.sh` (bash) и `install.ps1` (PowerShell), общий каталог и режимы.

## Быстрый старт

### macOS / Linux / WSL / Git Bash
```bash
git clone https://github.com/agisota/agent-skills-installer.git
cd agent-skills-installer && ./install.sh        # интерактивно
```
Без клона, одной строкой:
```bash
curl -fsSL https://raw.githubusercontent.com/agisota/agent-skills-installer/main/install.sh | bash -s -- --skills
```

### Windows (PowerShell 5.1+ / PowerShell 7)
```powershell
git clone https://github.com/agisota/agent-skills-installer.git
cd agent-skills-installer
./install.ps1 -All
```
Без клона, одной строкой:
```powershell
$s = irm https://raw.githubusercontent.com/agisota/agent-skills-installer/main/install.ps1
& ([scriptblock]::Create($s)) -Skills
```
> Требуется **Node.js** (для `npx skills`) и **git**. На нативной Windows bash-шаги
> (`gstack/setup`, ODW-installer) запускаются через **Git Bash** или **WSL** — инсталлер
> подскажет это и пометит как ручной шаг.

| Платформа | Энтрипоинт | Полная установка |
|---|---|---|
| macOS / Linux / WSL / Git Bash | `install.sh` | `./install.sh --all` |
| Windows (PowerShell) | `install.ps1` | `./install.ps1 -All` |

## Режимы

| bash (`install.sh`) | PowerShell (`install.ps1`) | Что делает |
|---|---|---|
| `./install.sh` | — *(меню только в bash)* | интерактивное меню |
| `--all` | `-All` | поставить всё (skill + plugin + npm + git + odw) |
| `--skills` | `-Skills` | только skill-паки через `npx skills add` |
| `--only a,b` | `-Only a,b` | только указанные ключи |
| `--list` | `-List` | показать каталог |
| `--dry-run` | `-DryRun` | напечатать команды, ничего не выполняя |
| `--version` | `-Version` | версия |

Флаги комбинируются: `./install.sh --skills --dry-run` / `./install.ps1 -Skills -DryRun`.

В конце печатается сводка (`установлено / ручных / ошибок`); код выхода `1`, если
была хоть одна ошибка установки — удобно для CI. Git-паки при повторном запуске
обновляются через `git pull` (идемпотентно).

## Типы установки

- **skill** — `npx skills add <repo>` (авто-детект агента)
- **plugin** — Claude Code marketplace; ставится командами `/plugin` **внутри сессии** (инсталлер печатает что вводить)
- **npm** — глобальный npm-пакет (OMC/OMX)
- **git** — clone в `~/.claude/skills/` + `./setup` (gstack)
- **odw** — официальный `install.sh` проекта (open-dynamic-workflows)

## Каталог

Полные описания, звёзды и ссылки — в [`skills-catalog.md`](./skills-catalog.md).
Сводка: `./install.sh --list`.

## Заметки

- **reverse-skill** — dual-use (реверс/пентест/security). Использовать только в авторизованных задачах.
- **open-dynamic-workflows** — существует в нескольких реализациях; по умолчанию ставится `xz1220/open-dynamic-workflows` (binary + skill). Альтернативы:
  - `npx skills add ChaosRealmsAI/open-dynamic-workflow` (odw + pandacode executor)
  - `npx skills add Suraj1235/open-dynamic-workflows` (daemon, BYO-model)
- Плагины Claude Code (`superpowers`, `understand-anything`) нельзя поставить из shell — инсталлер выведет нужные `/plugin`-команды.

## Лицензия

MIT. Сам инсталлер — обёртка; каждый пак скиллов сохраняет свою лицензию.
