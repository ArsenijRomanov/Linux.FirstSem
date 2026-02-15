# Отчёт №3

## Цель работы
- Закрепить написание shell-скриптов: проверка аргументов, условные переходы (`case`), обработка опций через `getopts`.
- Реализовать функцию-обёртку для запуска команд с перенаправлением вывода.
- Научиться генерировать скрипт, формирующий команды переименования файлов с изменением регистра.

## Среда выполнения
- ОС: Ubuntu
- Используемые утилиты: `file`, `curl`, `tr`, `mv`, `gimp`, `libreoffice`, `mpv`

---

## Ход работы

## 1) Открытие файлов по MIME-типу

### Задача
Написать утилиту `open`, которая определяет MIME-тип файла и открывает его подходящей программой. Для определения типа используется `file` с флагом вывода MIME-типа.

### Решение
```bash
#!/bin/bash

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
	echo "usage: open [file]"
	echo "Ensure that only one existing file is transferred"
	exit 1
fi

FILE="$1"

MIME_TYPE=$(file --mime-type -b "$FILE")

case "$MIME_TYPE" in
image/*)
	nohup gimp "$FILE" &>/dev/null &
	;;
application/msword | application/vnd.ms-excel | application/vnd.ms-powerpoint | application/vnd.openxmlformats-officedocument.wordprocessingml.document)
	nohup libreoffice "$FILE" &>/dev/null &
	;;
video/* | audio/*)
	nohup mpv "$FILE" &>/dev/null &
	;;
*)
	echo "Unknown MIME type: $MIME_TYPE. No suitable program to open the file"
	exit 1
	;;
esac

exit 0
```

### Пояснение
- `file --mime-type -b FILE` возвращает MIME-тип (например, `image/jpeg`, `video/ogg`).
- `case` выбирает программу по шаблону (`image/*`, `video/*` и т.д.).
- `nohup ... &` запускает программу в фоне и не привязывает её к текущему терминалу.
- `&>/dev/null` скрывает вывод программы (stdout и stderr).

---

## 2) Аргументы: погода по координатам (getopts)

### Задача
Написать скрипт, принимающий опции `-x` и `-y`, и выводящий погоду в точке с долготой `X` и широтой `Y`, используя сервис `wttr.in`. Для разбора опций использовать `getopts`.

### Решение
```bash
#!/bin/bash

LATITUDE=""
LONGITUDE=""

while getopts "x:y:" option; do
	case "$option" in
	x) LONGITUDE="$OPTARG" ;;
	y) LATITUDE="$OPTARG" ;;
	*)
		echo "Usage: $0 -x <longitude> -y <latitude>"
		exit 1
		;;
	esac
done

if [ -z "$LATITUDE" ] || [ -z "$LONGITUDE" ]; then
	echo "Usage: $0 -x <longitude> -y <latitude>"
	exit 1
fi

echo "Getting weather for coordinates: Latitude=$LATITUDE, Longitude=$LONGITUDE"
curl "wttr.in/$LATITUDE,$LONGITUDE"
```

### Пояснение
- Строка `"x:y:"` в `getopts` означает, что у опций `-x` и `-y` есть значения.
- Значение текущей опции доступно в переменной `OPTARG`.
- Проверка `-z` используется, чтобы убедиться, что обе координаты переданы.
- Запрос выполняется через `curl` к `wttr.in/<lat>,<lon>`.

---

## 3) Функции: запуск команды с перенаправлением stdout/stderr в файл

### Задача
Написать функцию, которая принимает первым аргументом имя файла, а дальше команду с аргументами, и перенаправляет стандартный вывод и ошибки в указанный файл.

### Решение
```bash
#!/bin/bash

my_func() {
	if [ $# -lt 2 ]; then
		echo "Usage: my_func <output_file> <command> [args...]"
		return 1
	fi

	OUTPUT_FILE="$1"
	shift # Убираем первый аргумент, чтобы остались только команда и её аргументы

	"$@" >"$OUTPUT_FILE" 2>&1
}

my_func ./my-output ls -l
```

### Пояснение
- `shift` сдвигает аргументы: после него `$@` содержит только команду и её параметры.
- `>"$OUTPUT_FILE"` перенаправляет stdout в файл, `2>&1` объединяет stderr со stdout.
- `return` используется внутри функции (вместо `exit`).

---

## 4) Генерация файлов: создание скрипта переименования в верхний регистр

### Задача
Написать скрипт, который генерирует другой скрипт, переименовывающий все файлы в директории, меняя регистр имени на верхний. Для изменения регистра использовать `tr`, для переименования — `mv`.

### Решение (генератор)
```bash
#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

DIRECTORY="$1"

if [ ! -d "$DIRECTORY" ]; then
	echo "$DIRECTORY is not a valid directory."
	exit 1
fi

DIRECTORY=$(echo "$DIRECTORY" | sed 's:/*$::')

GENERATED_SCRIPT="rename_to_uppercase.sh"

echo "#!/bin/bash" >"$GENERATED_SCRIPT"

for FILE in "$DIRECTORY"/*; do
	if [ -f "$FILE" ]; then
		BASENAME=$(basename "$FILE")
		NAME="${BASENAME%.*}"
		EXT="${BASENAME##*.}"

		NEW_NAME=$(echo "$NAME" | tr 'a-z' 'A-Z')

		NEW_FILE="$DIRECTORY/$NEW_NAME.$EXT"

		echo "mv "$FILE" "$NEW_FILE"" >>"$GENERATED_SCRIPT"
	fi
done

chmod +x "$GENERATED_SCRIPT"

echo "$GENERATED_SCRIPT generated."
```

### Пояснение
- Генератор проходит по файлам в директории и дописывает строки `mv "старое" "новое"` в новый файл-скрипт.
- Имя файла переводится в верхний регистр через `tr 'a-z' 'A-Z'`.
- Для формирования файла используется перенаправление `>` (создать/перезаписать) и `>>` (дописать в конец).

---

## Вывод
Были реализованы скрипты для выбора программы по MIME-типу, обработки опций через `getopts`, перенаправления вывода команды в файл через функцию, а также генерации скрипта переименования файлов с преобразованием регистра. Закреплены навыки работы с аргументами, `case`, перенаправлениями и утилитами `file`, `curl`, `tr`, `mv`.
