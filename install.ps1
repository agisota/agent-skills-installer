<#
.SYNOPSIS
  agent-skills-installer — один инсталлер для курируемого набора скиллов AI-агентов (Windows / cross-platform PowerShell).
.DESCRIPTION
  Зеркало install.sh для PowerShell 5.1+ и PowerShell 7 (Windows, macOS, Linux).
.EXAMPLE
  ./install.ps1 -All
  ./install.ps1 -Skills
  ./install.ps1 -Only thinking-partner,graphify
  ./install.ps1 -List
  ./install.ps1 -DryRun -Skills
  irm https://raw.githubusercontent.com/agisota/agent-skills-installer/main/install.ps1 | iex   # интерактивно НЕ работает через pipe; используй -Skills/-All
#>
[CmdletBinding()]
param(
  [switch]$All,
  [switch]$Skills,
  [switch]$Plugins,
  [switch]$Npm,
  [switch]$Git,
  [switch]$Odw,
  [string[]]$Only,
  [switch]$List,
  [switch]$DryRun,
  [switch]$Version,
  [Alias('h')][switch]$Help
)

$ErrorActionPreference = 'Continue'
$ScriptVersion = '1.1.0'

# ключ ; тип ; repo ; описание   (тип: skill|plugin|npm|git|odw)
$Catalog = @(
  'superpowers;plugin;obra/superpowers;Базовый фреймворк: brainstorming, TDD, debugging, планы, review, worktrees'
  'understand-anything;plugin;Egonex-AI/Understand-Anything;Knowledge-graph репо + интерактивный дашборд архитектуры'
  'oh-my-claudecode;npm;oh-my-claudecode;OMC: team/autopilot/ralph/ultrawork/ultragoal для Claude Code'
  'oh-my-codex;npm;oh-my-codex;OMX: то же для OpenAI Codex CLI'
  'open-dynamic-workflows;odw;xz1220/open-dynamic-workflows;ODW: JS-движок динамических воркфлоу'
  'thinking-partner;skill;mattnowdev/thinking-partner;150+ ментальных моделей, стресс-тест решений'
  'ultragoal;skill;morphaxl/ultragoal;Самокорректирующиеся goal-loop с верификацией'
  'last30days-skill;skill;mvanhorn/last30days-skill;Ресёрч по Reddit/X/YouTube/HN/Polymarket -> summary'
  'reverse-skill;skill;zhaoxuya520/reverse-skill;Реверс/пентест/security router (dual-use, авторизованно)'
  'mattpocock-skills;skill;mattpocock/skills;TS/типы/архитектура, grill-with-docs, tdd, improve-architecture'
  'taste-skill;skill;Leonxlnx/taste-skill;Anti-slop фронтенд + gpt-taste (GSAP, Awwwards-уровень)'
  'shadcn-improve;skill;shadcn/improve;Аудит кодбейзы топ-моделью -> планы для дешёвых исполнителей'
  'vercel-agent-skills;skill;vercel-labs/agent-skills;Официальный пак Vercel: Next.js, деплой, web-design'
  'ui-ux-pro-max;skill;nextlevelbuilder/ui-ux-pro-max-skill;Design-intelligence для professional UI/UX'
  'graphify;skill;safishamsi/graphify;Код/доки/PDF/картинки -> queryable knowledge-graph'
  'gstack;git;garrytan/gstack;23 спеца (CEO/Designer/QA/Security/Release) — слэш-команды'
  'addyosmani-agent-skills;skill;addyosmani/agent-skills;Production engineering-скиллы для AI-агентов'
  'ConardLi-garden-skills;skill;ConardLi/garden-skills;web-design, gpt-image-2, kb-retriever, beautiful-article'
  'phuryn-pm-skills;skill;phuryn/pm-skills;100+ PM-скиллов: discovery->strategy->execution->launch->growth'
  'kepano-obsidian-skills;skill;kepano/obsidian-skills;Obsidian CLI + Markdown/Bases/JSON Canvas'
  'alirezarezvani-claude-skills;skill;alirezarezvani/claude-skills;330+ скиллов, 30+ агентов, 70+ команд'
)

function Info($m) { Write-Host "==> $m" -ForegroundColor Blue }
function Warn($m) { Write-Host " ! $m"  -ForegroundColor Yellow }

$script:N_OK = 0; $script:N_MANUAL = 0; $script:N_FAIL = 0
$script:Summary = New-Object System.Collections.Generic.List[string]

function Mark-Ok($k)     { $script:N_OK++;     $script:Summary.Add("  [ok] $k") }
function Mark-Manual($k) { $script:N_MANUAL++; $script:Summary.Add("  [->] $k (ручной шаг)") }
function Mark-Fail($k,$m){ $script:N_FAIL++;   $script:Summary.Add("  [x] $k"); Warn $m }

function Show-Usage {
@'
agent-skills-installer — один инсталлер для курируемого набора скиллов AI-агентов.

Usage:
  ./install.ps1 -All            поставить ВСЁ (skill + plugin + npm + git + odw)
  ./install.ps1 -Skills         только skill-паки (npx skills add)
  ./install.ps1 -Plugins        только Claude Code плагины (печатает /plugin-команды)
  ./install.ps1 -Npm            только npm-паки (OMC/OMX)
  ./install.ps1 -Git            только git-паки (gstack)
  ./install.ps1 -Odw            только open-dynamic-workflows
  ./install.ps1 -Only a,b,c     только указанные ключи (см. -List)
  ./install.ps1 -List           показать каталог
  ./install.ps1 -DryRun         показать команды, ничего не выполняя
  ./install.ps1 -Version        версия
  ./install.ps1 -Help           эта справка

Флаги комбинируются: ./install.ps1 -Skills -DryRun
'@ | Write-Host
}

function Show-List {
  '{0,-30} {1,-8} {2}' -f 'KEY','TYPE','REPO' | Write-Host
  '{0,-30} {1,-8} {2}' -f '---','----','----' | Write-Host
  foreach ($row in $Catalog) {
    $p = $row.Split(';'); $k=$p[0]; $t=$p[1]; $r=$p[2]; $d=$p[3]
    '{0,-30} {1,-8} {2}' -f $k,$t,$r | Write-Host
    Write-Host ("{0,-40}{1}" -f '',$d) -ForegroundColor DarkGray
  }
}

function Invoke-Step($cmd) {
  if ($DryRun) { Write-Host "   > $cmd" -ForegroundColor DarkGray; return $true }
  try { Invoke-Expression $cmd; return ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) }
  catch { return $false }
}

function Get-SkillsDir {
  $base = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
  Join-Path $base 'skills'
}

function Install-One($key,$typ,$repo) {
  switch ($typ) {
    'skill' {
      Info "[skill] $key — npx skills add $repo"
      if (Invoke-Step "npx -y skills add $repo --yes") { Mark-Ok $key }
      elseif (Invoke-Step "npx -y skills add $repo")   { Mark-Ok $key }
      else { Mark-Fail $key "${key}: не удалось через npx skills (вручную: npx skills add $repo)" }
    }
    'plugin' {
      Info "[plugin] $key — Claude Code marketplace ($repo)"
      Warn 'Плагины ставятся ВНУТРИ Claude Code. Выполни в сессии:'
      Write-Host "    /plugin marketplace add $repo"
      Write-Host "    /plugin install $key"
      Mark-Manual $key
    }
    'npm' {
      Info "[npm] $key — npm install -g $repo"
      if (Invoke-Step "npm install -g $repo") {
        Mark-Ok $key
        if ($key -eq 'oh-my-claudecode') { Write-Host '    затем: omc setup' }
        if ($key -eq 'oh-my-codex')      { Write-Host '    затем: omx setup' }
      } else { Mark-Fail $key "${key}: npm install не удался" }
    }
    'git' {
      $dest = Join-Path (Get-SkillsDir) $key
      Info "[git] $key — clone в $dest"
      if ((Test-Path (Join-Path $dest '.git')) -and -not $DryRun) {
        if (Invoke-Step "git -C `"$dest`" pull --ff-only -q") { Mark-Ok "$key (обновлён)" }
        else { Mark-Fail $key "${key}: git pull не удался" }
      } elseif (Invoke-Step "git clone --single-branch --depth 1 https://github.com/$repo.git `"$dest`"") {
        Mark-Ok $key
        if ((Test-Path (Join-Path $dest 'setup')) -and -not $DryRun) {
          Warn "${key}: ./setup — bash-скрипт; на Windows запусти его в Git Bash/WSL вручную."
        }
      } else { Mark-Fail $key "${key}: clone не удался" }
    }
    'odw' {
      Info "[odw] $key — установщик $repo"
      $url = "https://raw.githubusercontent.com/$repo/main/scripts/install.sh"
      if ($script:OnWindows -and -not (Get-Command sh -ErrorAction SilentlyContinue)) {
        Warn "${key}: официальный установщик — bash (sh не найден). Поставь через Git Bash/WSL:"
        Write-Host "    curl -fsSL $url | sh"
        Mark-Manual $key
      } elseif (Invoke-Step "curl -fsSL $url | sh") { Mark-Ok $key }
      else { Mark-Fail $key "${key}: установка ODW не удалась (см. https://github.com/$repo)" }
    }
  }
}

# --- маршрутизация -------------------------------------------------------------
if ($Help)    { Show-Usage; exit 0 }
if ($Version) { Write-Host "agent-skills-installer $ScriptVersion"; exit 0 }
if ($List)    { Show-List; exit 0 }

# PS 5.1 не определяет автопеременную $IsWindows — вычислим собственную (встроенную не трогаем)
$script:OnWindows = if ($null -ne $IsWindows) { [bool]$IsWindows } else { $true }

# при запуске через -File PowerShell передаёт "a,b" одной строкой — нормализуем
if ($Only) { $Only = @($Only | ForEach-Object { $_ -split ',' } | Where-Object { $_ -ne '' }) }
$useOnly = ($Only -and $Only.Count -gt 0)
if (-not ($All -or $Skills -or $Plugins -or $Npm -or $Git -or $Odw -or $useOnly)) {
  Warn 'Режим не указан. Примеры: ./install.ps1 -All  |  -Skills  |  -List'
  Show-Usage
  exit 2
}

$wantTypes = @{}
if ($All) { 'skill','plugin','npm','git','odw' | ForEach-Object { $wantTypes[$_] = $true } }
if ($Skills)  { $wantTypes['skill']  = $true }
if ($Plugins) { $wantTypes['plugin'] = $true }
if ($Npm)     { $wantTypes['npm']    = $true }
if ($Git)     { $wantTypes['git']    = $true }
if ($Odw)     { $wantTypes['odw']    = $true }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Warn 'node не найден — skill/npx-паки могут не поставиться' }
if (-not (Get-Command git  -ErrorAction SilentlyContinue)) { Warn 'git не найден — git-паки (gstack) не поставятся' }
if ($DryRun) { Warn 'DRY-RUN: команды только печатаются.' }

$selected = 0
foreach ($row in $Catalog) {
  $p = $row.Split(';'); $key=$p[0]; $typ=$p[1]; $repo=$p[2]
  $take = if ($useOnly) { $Only -contains $key } else { [bool]$wantTypes[$typ] }
  if (-not $take) { continue }
  $selected++
  Install-One $key $typ $repo
}

if ($selected -eq 0) { Warn 'Ничего не выбрано (проверь -Only ключи через -List).'; exit 0 }

Write-Host ''
Info 'Сводка:'
$script:Summary | ForEach-Object { Write-Host $_ }
Write-Host ''
Write-Host ("установлено: {0} | ручных: {1} | ошибок: {2}" -f $script:N_OK,$script:N_MANUAL,$script:N_FAIL)
if ($script:N_MANUAL -gt 0) { Write-Host 'Плагины Claude Code ставятся командами /plugin внутри сессии (см. выше).' }
if ($DryRun) { Warn 'Это был DRY-RUN — реальная установка не выполнялась.' }
if ($script:N_FAIL -gt 0) { exit 1 } else { exit 0 }
