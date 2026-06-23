# Каталог наборов скиллов для AI-агентов

> Это **наборы скиллов** (репозитории), не отдельные скиллы. Где внутри несколько
> скиллов или конкретный скилл — отмечено. Все ссылки верифицированы 2026-06-23 через web-поиск,
> кроме помеченных `(не верифицировано)`.
>
> Универсальный установщик для большинства: `npx skills add <owner>/<repo>`
> (авто-детект агента: Claude Code, Cursor, Codex, …).
> Для Claude Code-плагинов: `/plugin marketplace add <owner>/<repo>` → `/plugin install <name>`.

---

## 1. Фреймворки / движки оркестрации

### superpowers (obra) — ~227K⭐
Базовый фреймворк скиллов: brainstorming, TDD, debugging, планы, code-review, worktrees. Фундамент.
- Repo: https://github.com/obra/superpowers
```bash
/plugin marketplace add obra/superpowers
/plugin install superpowers
```

### oh-my-claudecode (OMC)
Мульти-агентная оркестрация для Claude Code: team, autopilot, ralph, ultrawork, ultragoal. (установлено)
- Repo: https://github.com/Yeachan-Heo/oh-my-claudecode
```bash
npm install -g oh-my-claudecode   # затем: omc setup
```

### oh-my-codex (OMX) — MIT, 24K⭐
То же для OpenAI Codex CLI. Парный к OMC.
- Repo: https://github.com/Yeachan-Heo/oh-my-codex
```bash
npm install -g oh-my-codex        # затем: omx setup
```

### open-dynamic-workflows (ODW)
JS-движок динамических воркфлоу (`agent()/parallel()/pipeline()`): fan-out, adversarial-verify, loop-until-done.
⚠️ Три разные реализации — выбери одну под нужный раннер.
- xz1220 (binary + skill): https://github.com/xz1220/open-dynamic-workflows
- ChaosRealmsAI (odw + pandacode executor): https://github.com/ChaosRealmsAI/open-dynamic-workflow
- Suraj1235 (daemon, BYO-model): https://github.com/Suraj1235/open-dynamic-workflows
```bash
# вариант xz1220:
curl -fsSL https://raw.githubusercontent.com/xz1220/open-dynamic-workflows/main/scripts/install.sh | sh
```

### understand-anything (Egonex-AI, ранее Lum1104)
`/understand` — knowledge-graph репозитория + интерактивный дашборд архитектуры.
- Repo: https://github.com/Egonex-AI/Understand-Anything
```bash
/plugin marketplace add Egonex-AI/Understand-Anything
/plugin install understand-anything
```

---

## 2. Мышление / цели

### thinking-partner (mattnowdev)
150+ ментальных моделей, проверка ориентации, стресс-тест решений.
- Repo: https://github.com/mattnowdev/thinking-partner
```bash
npx skills add mattnowdev/thinking-partner
```

### ultragoal
Долговременное удержание цели (ledger `.omc/ultragoal`, гейты «done»). Часть OMC; есть самостоятельный форк.
- В составе OMC (выше) · отдельный: https://github.com/morphaxl/ultragoal

### ultrawork
Параллельный движок высокой пропускной способности. Часть OMC/OMX (см. выше).

---

## 3. Документация / ресёрч

### grill-me-with-docs
Допрос плана против доменной модели, обновление `CONTEXT.md`/ADR на лету. Скилл `grill-with-docs` внутри пака mattpocock.
- Repo: https://github.com/mattpocock/skills (скилл `grill-with-docs`)

### reverse-skill (zhaoxuya520) ✅ — 2.2K⭐
Роутер-пак для реверс-инжиниринга / авторизованного пентеста / security-research: AI-роутинг + самобутстрап тулчейна + самообучающаяся база. ⚠️ Dual-use, только для авторизованных задач.
- Repo: https://github.com/zhaoxuya520/reverse-skill

### last30days-skill (mvanhorn) ✅ — 46K⭐
Ресёрч любой темы по Reddit, X, YouTube, HN, Polymarket и вебу → грунтованный summary (deep-research/recency).
- Repo: https://github.com/mvanhorn/last30days-skill

---

## 4. UI / UX / фронтенд

### gpt-taste (внутри taste-skill, Leonxlnx) — 49K⭐
Строгий anti-slop для GPT/Codex, GSAP-моушн, Awwwards-уровень.
- Repo: https://github.com/Leonxlnx/taste-skill (скилл `gpt-taste`)
```bash
npx skills add https://github.com/Leonxlnx/taste-skill
```

### shadcn improve (shadcn) — ⚠️ не про shadcn/ui
Скилл `improve`: топ-модель аудит кодбейзы → пишет планы для дешёвых моделей-исполнителей.
- Repo: https://github.com/shadcn/improve
```bash
npx skills add shadcn/improve
```

### all vercel skills / vercel-labs/agent-skills ✅ — 28K⭐
Официальный пак Vercel Labs (это и есть «all vercel skills»): Next.js, деплой, web-design, view transitions. Реестр: skills.sh.
- Repo: https://github.com/vercel-labs/agent-skills
```bash
npx skills add vercel-labs/agent-skills
```

### ui-ux-pro-max-skill (nextlevelbuilder) ✅ — 95K⭐
Design-intelligence скилл для professional UI/UX на многих платформах (mobile-ui, React, Tailwind, landing). MIT.
- Repo: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
```bash
npx skills add nextlevelbuilder/ui-ux-pro-max-skill
```

### graphify (safishamsi)
`/graphify` — код/доки/PDF/картинки → queryable knowledge-graph (`graph.html/json` + отчёт). PyPI `graphifyy`.
- Repo: https://github.com/safishamsi/graphify
```bash
npx skills add safishamsi/graphify
```

---

## 5. Тематические паки скиллов

### gstack (garrytan) — 108K⭐
«Точный сетап Гарри Тана»: 23 спеца (CEO, Designer, Eng Manager, QA, Security, Release) — слэш-команды.
- Repo: https://github.com/garrytan/gstack
```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack \
  && cd ~/.claude/skills/gstack && ./setup
```

### mattpocock/skills — 130K⭐
TS, типы, архитектура, grill-me, tdd, improve-architecture.
- Repo: https://github.com/mattpocock/skills

### addyosmani/agent-skills ✅ — 66K⭐ (в исходном списке дважды)
Production-grade engineering-скиллы для AI-агентов (Claude Code, Cursor, Antigravity). MIT.
- Repo: https://github.com/addyosmani/agent-skills
```bash
npx skills add addyosmani/agent-skills
```

### ConardLi/garden-skills — 8.5K⭐
web-design-engineer, gpt-image-2, kb-retriever, beautiful-article, web-video-presentation.
- Repo: https://github.com/ConardLi/garden-skills
```bash
npx skills add ConardLi/garden-skills
```

### phuryn/pm-skills ✅ — 20K⭐
PM Skills Marketplace: 100+ скиллов/команд/плагинов — discovery → strategy → execution → launch → growth. MIT.
- Repo: https://github.com/phuryn/pm-skills

### kepano/obsidian-skills ✅ — 36K⭐
Скиллы для Obsidian: Obsidian CLI + открытые форматы (Markdown, Bases, JSON Canvas). MIT.
- Repo: https://github.com/kepano/obsidian-skills

### alirezarezvani/claude-skills ✅ — 19K⭐
Огромный пак: 30+ агентов, 70+ команд, 330+ скиллов (engineering, marketing, product, compliance, C-level, research). MIT.
- Repo: https://github.com/alirezarezvani/claude-skills

---

## Замечания
- **Дубли в исходном списке:** `addyosmani/agent-skills` и `vercel-labs/agent-skills` — по два раза.
- **`gpt-taste`** и **`grill-me-with-docs`** — отдельные скиллы внутри паков (taste-skill, mattpocock/skills), не самостоятельные репо.
- **ODW** — три реализации; выбрать одну под раннер.
- Все ссылки пробиты web-fetch'ем 2026-06-23: все репозитории живые (✅), звёзды проставлены.
- ⚠️ **reverse-skill** — dual-use (реверс/пентест); использовать только в авторизованных задачах.
