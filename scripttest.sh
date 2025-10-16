#!/bin/bash

echo "[ ! ] ТЕСТЫ ДЛЯ СКРИПТА АРХИВАЦИИ"
echo

echo "[Тест 1] Проверка без аргументов"
./script.sh
echo

echo "[Тест 2] Слишком много аргументов"
echo "Ожидается: ERROR: Введено слишком много аргументов!"
./script.sh arg1 arg2 arg3 arg4 arg5
echo

echo "=== Тест 3: Несуществующая папка ==="
echo "Ожидается: ERROR: Папка '/nonexistent/folder' не существует!"
echo "----------------------------------------"
./script.sh /nonexistent/folder
echo

echo "[Тест 4] Проверка с пустой папкой"
TEST_DIR=$(mktemp -d)
echo "Создана временная папка: $TEST_DIR"
./script.sh "$TEST_DIR"
echo

echo "[Тест 5] Проверка с нормальной папкой (~0.6 GB)"
TEST_DIR=$(mktemp -d)
echo "Создана временная папка: $TEST_DIR"
echo "Создаем файлы общим размером ~0.6 GB..."

for i in {1..100}; do
    dd if=/dev/zero of="$TEST_DIR/large_file_$i.dat" bs=1M count=6 2>/dev/null
done

mkdir -p "$TEST_DIR/subdir"
for i in {1..10}; do
    echo "test content $i" > "$TEST_DIR/file$i.txt"
    echo "sub content $i" > "$TEST_DIR/subdir/sfile$i.txt"
done

echo "Размер папки: $(du -sh "$TEST_DIR" | cut -f1)"
echo "Ожидается: Заполненность папки и выход"
./script.sh "$TEST_DIR"
echo

echo "[Тест 6] Архивация с низким порогом (архивация должна выполниться)"
ARCHIVE_DIR=$(mktemp -d)
echo "Папка для архива: $ARCHIVE_DIR"
echo "Размер исходной папки: $(du -sh "$TEST_DIR" | cut -f1)"
./script.sh "$TEST_DIR" "$ARCHIVE_DIR" 0.00000001 3
echo "Проверяем создание архива..."
find "$ARCHIVE_DIR" -name "*.tar.gz" 2>/dev/null | head -5
echo

echo "[Тест 7] Архивация с высоким порогом (архивация НЕ выполнится)"
./script.sh "$TEST_DIR" "$ARCHIVE_DIR" 90 5
echo

echo "очищаем файлы"
rm -rf "$TEST_DIR" "$ARCHIVE_DIR"
echo "[ ! ] временные папки удалены"
echo

echo "[ ! ] ВСЕ ТЕСТЫ ЗАВЕРШЕНЫ"