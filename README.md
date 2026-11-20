# CyberShell

CyberShell — это легковесный эстетичный модуль кастомизации для PowerShell 5.1 и PowerShell 7+, добавляющий неоновое оформление, статус Git-репозиториев и замер времени выполнения команд.

## Возможности

- **Высокая скорость работы**: статус Git и ветка считываются напрямую без лагов и задержек.
- **Телеметрия команд**: отображение времени выполнения долгих процессов (`⏱ 1.4s`).
- **Темы оформления**: выбор цветовых палитр (`neon-pulse`, `retro-wave`, `digital-rain`, `midnight-cyan`, `crimson-dusk`, `arctic-frost`).
- **Стили промпта**: режимы `Powerline`, `NeonBar` и `Minimal`.
- **Интерактивные виджеты**: цифровая заставка `Start-CyberMatrix` и часы `Show-CyberClock`.
- **Готовые тесты**: набор автоматических проверок в каталоге `Tests/`.

## Быстрый старт

### Установка

Запустите скрипт установки из папки проекта:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Скрипт автоматически скопирует модуль в пользовательскую директорию PowerShell и добавит инициализацию в `$PROFILE`.

### Ручное подключение

```powershell
Import-Module .\CyberShell\CyberShell.psd1
Enable-CyberShell
```

## Основные команды

- `Enable-CyberShell` — включить стилизованный промпт.
- `Disable-CyberShell` — вернуть стандартный вид консоли.
- `Show-CyberBanner` (или `cyberbanner`) — показать логотип и параметры системы.
- `Get-CyberTheme -ListAvailable` — список доступных цветовых схем.
- `Set-CyberTheme -Name retro-wave` — переключить тему.
- `Set-CyberConfig -Style NeonBar` — сменить стиль отображения.
- `Start-CyberMatrix` (или `matrix`) — консольная анимация цифрового дождя.
- `Show-CyberClock` (или `cyberclock`) — терминальные часы.

## Тестирование

Для запуска проверки модулей выполните:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tests\CyberShell.Tests.ps1
```

## Публикация на GitHub

1. Инициализируйте локальный Git-репозиторий:
   ```powershell
   git init
   git add .
   git commit -m "Initial commit of CyberShell module"
   ```
2. Создайте новый репозиторий на [GitHub](https://github.com/new).
3. Привяжите удаленный репозиторий и отправьте код:
   ```powershell
   git branch -M main
   git remote add origin https://github.com/<ваш-логин>/CyberShell.git
   git push -u origin main
   ```
