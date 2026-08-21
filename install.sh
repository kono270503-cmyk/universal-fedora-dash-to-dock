#!/usr/bin/env bash

# Строгий режим
set -euo pipefail

UUID="dash-to-dock@://gmail.com"
INSTALL_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"

echo "======================================================"
echo " Универсальное Зеркало Dash to Dock (Fedora 38 - 44)  "
echo "======================================================"

# Проверка и автоматическая установка unzip
if ! command -v unzip &> /dev/null; then
    echo "[*] Утилита unzip не найдена. Устанавливаем..."
    sudo dnf install -y unzip
fi

# 1. Проверяем версию GNOME Shell у пользователя
GNOME_VER=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)
echo "[*] Обнаружена мажорная версия GNOME: $GNOME_VER"

# 2. Подбираем правильный файл в зависимости от версии GNOME
case "$GNOME_VER" in
    "44")
        ARCHIVE_NAME="dash-to-dock-gnome44.zip"
        ;;
    "45" | "46")
        ARCHIVE_NAME="dash-to-dock-gnome45-46.zip"
        ;;
    "47" | "48" | "49" | "50")
        ARCHIVE_NAME="dash-to-dock-gnome47.zip"
        ;;
    *)
        echo "[!] Внимание: Ваша версия GNOME ($GNOME_VER) официально не тестировалась."
        echo "[*] Пробуем установить самую свежую версию расширения..."
        ARCHIVE_NAME="dash-to-dock-gnome47.zip"
        ;;
esac

# 3. Создаем структуру папок для расширений
mkdir -p "$HOME/.local/share/gnome-shell/extensions"

# 4. Очищаем старую установку, если она была
if [ -d "$INSTALL_DIR" ]; then
    echo "[*] Удаление предыдущей версии расширения..."
    rm -rf "$INSTALL_DIR"
fi
mkdir -p "$INSTALL_DIR"

# 5. Скачивание выбранного архива из твоего зеркала GitHub
echo "[*] Скачивание файла: $ARCHIVE_NAME..."
URL="https://github.com"

if ! curl -L "$URL" -o /tmp/dash-to-dock.zip; then
    echo "[✕] Ошибка: Не удалось скачать файл с зеркала GitHub."
    exit 1
fi

# 6. Распаковка архива в системный каталог пользователя
echo "[*] Распаковка и интеграция в GNOME Shell..."
unzip -q /tmp/dash-to-dock.zip -d "$INSTALL_DIR"
rm -f /tmp/dash-to-dock.zip

# 7. Принудительное включение расширения через консольную утилиту
echo "[*] Активация расширения..."
gnome-extensions enable "$UUID" || true

echo "======================================================"
echo "[🎉] Установка успешно завершена для GNOME $GNOME_VER!"
echo "[💡] ВАЖНО ДЛЯ АКТИВАЦИИ ИНТЕРФЕЙСА:"
echo "     - Перезагрузите ПК или просто перезайдите в систему (Log Out)."
echo "======================================================"
