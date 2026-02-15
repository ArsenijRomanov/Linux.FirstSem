# Отчёт №8

## Цель работы
1. Описать зависимости сборки в Make так, чтобы пересборка происходила при изменении `main.hh`.
2. Подключить библиотеку **zlib** в Make через `pkg-config`.
3. Собрать код с библиотекой **zlib** с помощью Meson.
4. Склонировать проект `unistdx` и собрать его Meson с оптимизациями.

## Исходные файлы
### main.cc
```cpp
// #include <zlib.h>
#include "main.hh"

int main()
{
	return 0;
}

```

### main.hh
```cpp
#pragma once
```

---

## 1) Make: зависимости для пересборки при изменении заголовка

```make
all: main

main: main.o

main.o: main.cc main.hh
```

---

## 2) Make + pkg-config: сборка с библиотекой zlib

Для подключения zlib использован флаг из `pkg-config`:
- `--libs` — для линковщика

```make
CXX = g++
LIBS = $(shell pkg-config --libs zlib)

TARGET = main

SRC = main.cc
OBJ = main.o

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(OBJ) -o $(TARGET) $(LIBS)

$(OBJ): $(SRC) main.hh
	$(CXX) -c $(SRC)

clean:
	rm -f $(OBJ) $(TARGET)
```

---

## 3) Meson: сборка кода с zlib

Команды сборки:
```bash
meson setup builddir
meson compile -C builddir
```

---

## 4) Git + Meson: сборка unistdx с оптимизациями

### Использованные команды
```bash
meson setup builddir -Dc_args="-march=native -O3" -Dcpp_link_args="-flto"
 meson compile -C builddir
```
