# agent-skills-installer

Один инсталлер для курируемого набора из **21 пака скиллов** для AI-агентов
(Claude Code, Codex, Cursor, OpenCode, Gemini CLI и др.). Все репозитории
проверены и живые на 2026-06-23.

## Быстрый старт

```bash
git clone https://github.com/agisota/agent-skills-installer.git
cd agent-skills-installer
./install.sh            # интерактивно
```

Или одной строкой (без клона):

```bash
curl -fsSL https://raw.githubusercontent.com/agisota/agent-skills-installer/main/install.sh | bash -s -- --skills
```

## Режимы

| Команда | Что делает |
|---|---|
| `./install.sh` | интерактивное меню |
| `./install.sh --all` | поставить всё (skill + plugin + npm + git + odw) |
| `./install.sh --skills` | только skill-паки через `npx skills add` |
| `./install.sh --only thinking-partner,graphify` | только указанные ключи |
| `./install.sh --list` | показать каталог |
| `./install.sh --dry-run` | напечатать команды, ничего не выполняя |

Флаги комбинируются: `./install.sh --skills --dry-run`.

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
- **open-dynamic-workflows** — существует в нескольких реализациях; по умолчанию ставится `xz1220/open-dynamic-workflows`. Альтернативы см. в каталоге.
- Плагины Claude Code (`superpowers`, `understand-anything`) нельзя поставить из shell — инсталлер выведет нужные `/plugin`-команды.

## Лицензия

MIT. Сам инсталлер — обёртка; каждый пак скиллов сохраняет свою лицензию.
