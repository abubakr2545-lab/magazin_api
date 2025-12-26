# ⚡ Быстрая настройка для Render.com

Write-Host "🎨 Подготовка проекта для деплоя на Render.com..." -ForegroundColor Cyan
Write-Host ""

# Проверка необходимых файлов
$files = @("requirements.txt", "main.py", ".gitignore")
$allFilesExist = $true

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file найден" -ForegroundColor Green
    } else {
        Write-Host "❌ $file НЕ найден!" -ForegroundColor Red
        $allFilesExist = $false
    }
}

Write-Host ""

if (-not $allFilesExist) {
    Write-Host "❌ Не все необходимые файлы существуют!" -ForegroundColor Red
    exit 1
}

# Генерация SECRET_KEY
Write-Host "🔑 Генерация SECRET_KEY..." -ForegroundColor Cyan
$secretKey = python -c "import secrets; print(secrets.token_urlsafe(32))"
Write-Host "✅ SECRET_KEY сгенерирован!" -ForegroundColor Green
Write-Host ""

# Создание файла с переменными окружения для справки
$envVarsContent = @"
# Переменные окружения для Render.com
# Добавьте эти переменные в Render Dashboard → Environment Variables

SECRET_KEY=$secretKey
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_ORIGINS=*

# DATABASE_URL будет автоматически добавлена после создания PostgreSQL базы
# Используйте Internal Database URL для подключения
"@

Set-Content -Path "render-env-vars.txt" -Value $envVarsContent
Write-Host "✅ Переменные окружения сохранены в файл: render-env-vars.txt" -ForegroundColor Green
Write-Host ""

# Создание README для Render
$renderReadme = @"
# 🚀 Деплой на Render.com

## Быстрый старт

1. **Зарегистрируйтесь**: https://render.com
2. **New + → Web Service**
3. **Подключите GitHub**: abubakr2545-lab/magazin
4. **Настройте**:

### Build Settings:
\`\`\`
Environment: Python 3
Build Command: pip install -r requirements.txt
Start Command: uvicorn main:app --host 0.0.0.0 --port `$PORT
\`\`\`

### Environment Variables:
Скопируйте из файла \`render-env-vars.txt\` или:

\`\`\`
SECRET_KEY=$secretKey
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_ORIGINS=*
\`\`\`

5. **Создайте PostgreSQL базу**:
   - New + → PostgreSQL
   - Name: magazin-db
   - Free tier
   
6. **Подключите БД**:
   - Скопируйте Internal Database URL
   - Добавьте как переменную DATABASE_URL в Web Service

7. **Deploy!**

## Проверка

После деплоя проверьте:
- https://ваш-сервис.onrender.com/health
- https://ваш-сервис.onrender.com/docs

## 📝 Важно

⚠️ Бесплатный сервис засыпает через 15 минут неактивности
⚠️ Холодный старт займет ~30-60 секунд
"@

Set-Content -Path "RENDER_DEPLOY.md" -Value $renderReadme
Write-Host "✅ Инструкция сохранена в файл: RENDER_DEPLOY.md" -ForegroundColor Green
Write-Host ""

# Проверка git статуса
if (Test-Path ".git") {
    Write-Host "📦 Git репозиторий существует" -ForegroundColor Green
    
    $addFiles = Read-Host "Добавить новые файлы в git? (y/n)"
    
    if ($addFiles -eq "y" -or $addFiles -eq "Y") {
        git add render-env-vars.txt RENDER_DEPLOY.md
        git commit -m "Add Render deployment configuration"
        
        $pushToGit = Read-Host "Загрузить на GitHub? (y/n)"
        if ($pushToGit -eq "y" -or $pushToGit -eq "Y") {
            git push
            Write-Host "✅ Изменения загружены на GitHub!" -ForegroundColor Green
        }
    }
} else {
    Write-Host "⚠️  Git не инициализирован. Запустите upload-to-github.ps1 сначала!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Подготовка завершена!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Следующие шаги:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Загрузите проект на GitHub (если еще не сделали):" -ForegroundColor White
Write-Host "   .\upload-to-github.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Зайдите на Render.com:" -ForegroundColor White
Write-Host "   https://render.com" -ForegroundColor Blue
Write-Host ""
Write-Host "3. Создайте Web Service из GitHub репозитория" -ForegroundColor White
Write-Host ""
Write-Host "4. Используйте настройки из файла:" -ForegroundColor White
Write-Host "   RENDER_DEPLOY.md" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Скопируйте переменные окружения из:" -ForegroundColor White
Write-Host "   render-env-vars.txt" -ForegroundColor Gray
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Ваш SECRET_KEY:" -ForegroundColor Cyan
Write-Host "   $secretKey" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 Сохраните его в безопасном месте!" -ForegroundColor Gray
Write-Host ""
