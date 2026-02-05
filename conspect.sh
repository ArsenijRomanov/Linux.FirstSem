#!/bin/sh

x=1

export x=1

# test - сравнение строки и числа
if test "$x" = 1
then
    echo "x равен 1"
else
    echo "x не равен 1"
fi


case "$x" in
    1) echo "x равен 1" ;;
    *.txt) echo "x оканчивается на .txt" ;;
    *) echo "x не равен 1 и не оканчивается на .txt" ;;
esac


for i in 1 2 3
do
    echo "$i"
done 


while test -f /tmp/x
do
    echo "Файл /tmp/x существует"
    sleep 1
done

#!/bin/sh
set -e # завершить скрипт, как только команда вернет ненулевое значение
while test -n "$1" # пока первый аргумент не является пустой строкой
do
    case "$1" in
        # вывести мини-документацию при указании флага "-h" или "--help"
        -h|--help echo "usage: ./my-script [-h] [--help] [--version] ... " ;;
        # вывести версию скрипта при указании флага "--version"
        --version) echo "1.1.1" ;;
        # вывести сообщение об ошибке в поток ошибок и вернуть ненулевое значение
        *) echo "Неизвестный аргумент: $1" >&2; exit 1 ;;
    esac
    shift # сдвинуть все аргументы на один влево:
          # первый аргумент теряется, второй становится первым и т.д.
done


hello() {
  echo "Hello $1"
}

hello "X"


