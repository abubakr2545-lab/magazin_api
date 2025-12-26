# Скрипт для загрузки проекта на GitHub
# Репозиторий: https://github.com/abubakr2545-lab/magazin.git

Write-Host "🔧 Настройка Git и загрузка на GitHub..." -ForegroundColor Cyan
Write-Host ""

# Проверка наличия git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git не установлен! Установите Git и попробуйте снова." -ForegroundColor Red
    exit 1
}

# Показать текущую конфигурацию
Write-Host "📋 Текущая конфигурация Git:" -ForegroundColor Yellow
git config --global user.name
git config --global user.email
Write-Host ""

# Спросить, нужно ли сменить учетные данные
$changeConfig = Read-Host "Хотите изменить учетные данные Git? (y/n)"

if ($changeConfig -eq "y" -or $changeConfig -eq "Y") {
    Write-Host ""
    $gitUsername = Read-Host "Введите ваше имя для Git (например, Abubakr)"
    $gitEmail = Read-Host "Введите ваш email для Git"
    
    # Устанавливаем конфигурацию
    git config --global user.name "$gitUsername"
    git config --global user.email "$gitEmail"
    
    Write-Host "✅ Конфигурация Git обновлена!" -ForegroundColor Green
    Write-Host ""
}

# Очистка кэша учетных данных (выход из текущего аккаунта)
Write-Host "🔐 Очистка сохраненных учетных данных..." -ForegroundColor Cyan
git credential-manager-core erase https://github.com 2>$null
git credential reject https://github.com 2>$null

# Для Windows Credential Manager
cmdkey /delete:git:https://github.com 2>$null

Write-Host "✅ Кэш учетных данных очищен!" -ForegroundColor Green
Write-Host ""

# Инициализация Git (если не сделано)
if (-not (Test-Path ".git")) {
    Write-Host "📦 Инициализация Git репозитория..." -ForegroundColor Cyan
    git init
    Write-Host "✅ Git репозиторий инициализирован!" -ForegroundColor Green
} else {
    Write-Host "✅ Git репозиторий уже существует" -ForegroundColor Green
}

Write-Host ""

# Проверка наличия remote
$remoteExists = git remote get-url origin 2>$null
if ($remoteExists) {
    Write-Host "⚠️  Remote 'origin' уже существует: $remoteExists" -ForegroundColor Yellow
    $changeRemote = Read-Host "Хотите изменить на https://github.com/abubakr2545-lab/magazin.git? (y/n)"
    
    if ($changeRemote -eq "y" -or $changeRemote -eq "Y") {
        git remote remove origin
        git remote add origin https://github.com/abubakr2545-lab/magazin.git
        Write-Host "✅ Remote обновлен!" -ForegroundColor Green
    }
} else {
    Write-Host "🔗 Добавление remote репозитория..." -ForegroundColor Cyan
    git remote add origin https://github.com/abubakr2545-lab/magazin.git
    Write-Host "✅ Remote добавлен!" -ForegroundColor Green
}

Write-Host ""

# Добавление файлов
Write-Host "📁 Добавление файлов в git..." -ForegroundColor Cyan
git add .

# Показываем статус
Write-Host ""
Write-Host "📊 Статус репозитория:" -ForegroundColor Yellow
git status --short

Write-Host ""
$commitMessage = Read-Host "Введите сообщение коммита (или нажмите Enter для 'Initial commit')"

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Initial commit"
}

# Коммит
Write-Host ""
Write-Host "💾 Создание коммита..." -ForegroundColor Cyan
git commit -m "$commitMessage"
Write-Host "✅ Коммит создан!" -ForegroundColor Green

Write-Host ""

# Проверка наличия ветки main
$currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
Write-Host "📌 Текущая ветка: $currentBranch" -ForegroundColor Gray

if ($currentBranch -ne "main") {
    Write-Host "🔄 Переименование ветки в 'main'..." -ForegroundColor Cyan
    git branch -M main
    Write-Host "✅ Ветка переименована в 'main'!" -ForegroundColor Green
}

Write-Host ""
Write-Host "⚠️  ВАЖНО: Сейчас откроется окно для ввода учетных данных GitHub!" -ForegroundColor Yellow
Write-Host "Введите:" -ForegroundColor White
Write-Host "  Username: abubakr2545-lab" -ForegroundColor Gray
Write-Host "  Password: Ваш Personal Access Token (НЕ пароль от аккаунта!)" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Если у вас нет токена, создайте его здесь:" -ForegroundColor Cyan
Write-Host "   https://github.com/settings/tokens/new" -ForegroundColor Blue
Write-Host ""

$ready = Read-Host "Готовы продолжить? (y/n)"

if ($ready -ne "y" -and $ready -ne "Y") {
    Write-Host "❌ Отменено пользователем" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "🚀 Загрузка на GitHub..." -ForegroundColor Cyan
Write-Host ""

# Push
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ ✅ ✅ УСПЕШНО! Проект загружен на GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Ваш репозиторий:" -ForegroundColor Cyan
    Write-Host "   https://github.com/abubakr2545-lab/magazin" -ForegroundColor Blue
    Write-Host ""
    Write-Host "📊 Следующие шаги:" -ForegroundColor Yellow
    Write-Host "   1. Проверьте репозиторий на GitHub" -ForegroundColor Gray
    Write-Host "   2. Деплой на Railway: .\deploy-railway.ps1" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Ошибка при загрузке на GitHub!" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Возможные причины:" -ForegroundColor Yellow
    Write-Host "   1. Неверные учетные данные" -ForegroundColor Gray
    Write-Host "   2. Репозиторий не существует или недоступен" -ForegroundColor Gray
    Write-Host "   3. Нет прав на запись в репозиторий" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔧 Попробуйте:" -ForegroundColor Cyan
    Write-Host "   - Проверьте правильность username: abubakr2545-lab" -ForegroundColor Gray
    Write-Host "   - Создайте Personal Access Token на GitHub" -ForegroundColor Gray
    Write-Host "   - Убедитесь, что репозиторий существует" -ForegroundColor Gray
    Write-Host ""
}
