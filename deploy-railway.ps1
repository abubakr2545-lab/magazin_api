# Скрипт быстрого деплоя на Railway

Write-Host "🚂 Начинаем деплой на Railway..." -ForegroundColor Cyan
Write-Host ""

# Проверка наличия git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git не установлен! Установите Git и попробуйте снова." -ForegroundColor Red
    exit 1
}

# Проверка наличия Railway CLI
if (-not (Get-Command railway -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️  Railway CLI не установлен!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Установите Railway CLI одним из способов:" -ForegroundColor White
    Write-Host "1. npm i -g @railway/cli" -ForegroundColor Gray
    Write-Host "2. https://docs.railway.app/develop/cli#installing-the-cli" -ForegroundColor Gray
    Write-Host ""
    $install = Read-Host "Хотите установить через npm сейчас? (y/n)"
    
    if ($install -eq "y" -or $install -eq "Y") {
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            npm i -g @railway/cli
        } else {
            Write-Host "❌ npm не установлен! Установите Node.js сначала." -ForegroundColor Red
            exit 1
        }
    } else {
        exit 1
    }
}

# Инициализация Git (если не сделано)
if (-not (Test-Path ".git")) {
    Write-Host "📦 Инициализация Git репозитория..." -ForegroundColor Cyan
    git init
    git add .
    git commit -m "Initial commit for Railway deployment"
    Write-Host "✅ Git репозиторий создан!" -ForegroundColor Green
} else {
    Write-Host "✅ Git репозиторий уже существует" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔐 Вход в Railway..." -ForegroundColor Cyan
railway login

Write-Host ""
Write-Host "🚀 Инициализация Railway проекта..." -ForegroundColor Cyan
railway init

Write-Host ""
$addDatabase = Read-Host "Хотите добавить PostgreSQL базу данных? (y/n)"

if ($addDatabase -eq "y" -or $addDatabase -eq "Y") {
    Write-Host "🗄️  Добавление PostgreSQL..." -ForegroundColor Cyan
    railway add --database postgres
    Write-Host "✅ PostgreSQL добавлена!" -ForegroundColor Green
}

Write-Host ""
Write-Host "⚙️  Настройка переменных окружения..." -ForegroundColor Cyan
Write-Host ""

# Генерация SECRET_KEY
$secretKey = python -c "import secrets; print(secrets.token_urlsafe(32))"
Write-Host "Сгенерирован SECRET_KEY: $secretKey" -ForegroundColor Gray

Write-Host ""
$setVars = Read-Host "Хотите установить переменные окружения сейчас? (y/n)"

if ($setVars -eq "y" -or $setVars -eq "Y") {
    railway variables set SECRET_KEY="$secretKey"
    railway variables set ALGORITHM="HS256"
    railway variables set ACCESS_TOKEN_EXPIRE_MINUTES="30"
    
    $origins = Read-Host "Введите ALLOWED_ORIGINS (например, https://myapp.com) или нажмите Enter для пропуска"
    if ($origins) {
        railway variables set ALLOWED_ORIGINS="$origins"
    }
    
    Write-Host "✅ Переменные окружения установлены!" -ForegroundColor Green
}

Write-Host ""
Write-Host "🚀 Деплой на Railway..." -ForegroundColor Cyan
railway up

Write-Host ""
Write-Host "🌐 Создание публичного домена..." -ForegroundColor Cyan
railway domain

Write-Host ""
Write-Host "✅ Деплой завершен!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Полезные команды:" -ForegroundColor Cyan
Write-Host "  railway logs        - Просмотр логов" -ForegroundColor Gray
Write-Host "  railway open        - Открыть в браузере" -ForegroundColor Gray
Write-Host "  railway variables   - Просмотр переменных" -ForegroundColor Gray
Write-Host "  railway restart     - Перезапустить сервис" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Ваш API должен быть доступен!" -ForegroundColor Green
Write-Host ""
