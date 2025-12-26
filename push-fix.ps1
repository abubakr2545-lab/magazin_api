# Скрипт для загрузки исправлений на GitHub

Write-Host "🔧 Загрузка исправлений на GitHub..." -ForegroundColor Cyan
Write-Host ""

# Проверка git
if (-not (Test-Path ".git")) {
    Write-Host "❌ Git не инициализирован!" -ForegroundColor Red
    Write-Host "Запустите сначала: .\upload-to-github.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Измененные файлы:" -ForegroundColor Yellow
Write-Host ""
git status --short
Write-Host ""

Write-Host "📝 Что было исправлено:" -ForegroundColor Cyan
Write-Host "  ✅ Обновлены версии пакетов в requirements.txt" -ForegroundColor Green
Write-Host "  ✅ Изменена версия Python на 3.11 в runtime.txt" -ForegroundColor Green
Write-Host "  ✅ Добавлен psycopg2-binary для PostgreSQL" -ForegroundColor Green
Write-Host ""

$continue = Read-Host "Продолжить загрузку исправлений на GitHub? (y/n)"

if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "❌ Отменено" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "📦 Добавление файлов..." -ForegroundColor Cyan
git add requirements.txt runtime.txt RENDER_FIX.md

Write-Host ""
Write-Host "💾 Создание коммита..." -ForegroundColor Cyan
git commit -m "Fix: Update dependencies for Python 3.11 compatibility

- Updated all packages to latest versions
- Changed Python version to 3.11 for better compatibility
- Added psycopg2-binary for PostgreSQL support
- Fixes Render build error with pydantic-core Rust compilation"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при создании коммита!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Коммит создан!" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Загрузка на GitHub..." -ForegroundColor Cyan
git push

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "✅ ✅ ✅ УСПЕШНО! Исправления загружены!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Следующие шаги:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Render автоматически начнет новый деплой" -ForegroundColor White
    Write-Host "   Проверьте прогресс: https://dashboard.render.com" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Или вручную запустите деплой:" -ForegroundColor White
    Write-Host "   Dashboard → Ваш сервис → Manual Deploy → Deploy latest commit" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Следите за логами билда" -ForegroundColor White
    Write-Host "   Убедитесь что установка пакетов прошла успешно" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. После успешного деплоя проверьте:" -ForegroundColor White
    Write-Host "   - https://magazin-api.onrender.com/health" -ForegroundColor Blue
    Write-Host "   - https://magazin-api.onrender.com/docs" -ForegroundColor Blue
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Ошибка при загрузке на GitHub!" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Попробуйте:" -ForegroundColor Yellow
    Write-Host "   git push" -ForegroundColor Gray
    Write-Host ""
}
