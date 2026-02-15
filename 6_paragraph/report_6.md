# Отчёт №6

## Цель работы
- Реализовать условную компиляцию с макросами `USE_GPU` и `USE_FLOAT` и проверить её через `g++ -E`.
- Собрать `sha1-benchmark` с разными уровнями оптимизации и сравнить время работы.
- Повторить измерения с оптимизацией линковки (LTO) и с профилированием (PGO).

## Среда выполнения
- ОС: Ubuntu
- Компилятор: `g++` 

---

## 1) Условная компиляция (проверка через `g++ -E`)

### Код
```c
#include <stdio.h>

int main(void) {
#if defined(USE_GPU) && defined(USE_FLOAT)
    printf("USE_GPU and USE_FLOAT\n");
#elif defined(USE_GPU)
    printf("USE_GPU\n");
#elif defined(USE_FLOAT)
    printf("USE_FLOAT\n");
#else
    printf("None\n");
#endif
    return 0;
}
```

### Проверка препроцессора
Команды:
```bash
g++ -E main.c | grep 'None'
g++ -E -DUSE_GPU main.c | grep 'USE_'
g++ -E -DUSE_FLOAT main.c | grep 'USE_'
g++ -E -DUSE_GPU -DUSE_FLOAT main.c | grep 'USE_'
```

Результат (выбирается нужная из 4 веток):
```text
printf("None\n");
printf("USE_GPU\n");
printf("USE_FLOAT\n");
printf("USE_GPU and USE_FLOAT\n");
```

---

## 2) Тесты производительности (O0 vs O3)

### Сборка
```bash
g++ -std=c++17 -O0  -o sha1-bench-O0 sha1_benchmark.cc sha1.cc
g++ -std=c++17 -O3 -march=native -o sha1-bench-O3 sha1_benchmark.cc sha1.cc
```

### Измерение времени
```bash
for i in {1..5}; do /usr/bin/time -f "O0 real=%e" sh -c './sha1-bench-O0 >/dev/null 2>&1'; done
for i in {1..5}; do /usr/bin/time -f "O3 real=%e" sh -c './sha1-bench-O3 >/dev/null 2>&1'; done
```

Результаты:
- O0: 20.90, 17.41, 18.29, 18.02, 18.37 (с), среднее **18.598**
- O3: 5.04, 4.92, 4.89, 4.89, 4.85 (с), среднее **4.918**

Итог:
- ускорение: **3.78×**
- уменьшение времени: **73.6%**

---

## 3) Оптимизация во время линковки (LTO)

### Сборка
```bash
g++ -std=c++17 -O0 -flto -o sha1-bench-O0-lto sha1_benchmark.cc sha1.cc
g++ -std=c++17 -O3 -march=native -flto -o sha1-bench-O3-lto sha1_benchmark.cc sha1.cc
```

### Измерение времени
```bash
for i in {1..5}; do /usr/bin/time -f "O0+LTO real=%e" sh -c './sha1-bench-O0-lto >/dev/null 2>&1'; done
for i in {1..5}; do /usr/bin/time -f "O3+LTO real=%e" sh -c './sha1-bench-O3-lto >/dev/null 2>&1'; done
```

Результаты:
- O0+LTO: 20.88, 17.42, 17.39, 17.44, 17.49 (с), среднее **18.124**
- O3+LTO: 4.57, 4.62, 4.59, 4.59, 4.57 (с), среднее **4.588**

Итог для O3:
- ускорение O3+LTO относительно O3: **1.07×**
- уменьшение времени: **6.7%**

---

## 4) Оптимизация с помощью профилирования (PGO)

### Сборка с генерацией профиля и прогон
```bash
rm -rf pgo && mkdir pgo
g++ -std=c++17 -O3 -march=native -flto -fprofile-generate -fprofile-dir=pgo   -o sha1-bench-pgo-gen sha1_benchmark.cc sha1.cc
for i in {1..5}; do ./sha1-bench-pgo-gen 2>/dev/null; done
```

### Пересборка с использованием профиля
```bash
g++ -std=c++17 -O3 -march=native -flto -fprofile-use -fprofile-dir=pgo   -fprofile-correction -Wno-missing-profile   -o sha1-bench-O3-lto-pgo sha1_benchmark.cc sha1.cc
```

### Измерение времени
```bash
/usr/bin/time -f "baseline O3+LTO real=%e" sh -c './sha1-bench-O3-lto 2>/dev/null'
/usr/bin/time -f "PGO O3+LTO real=%e"      sh -c './sha1-bench-O3-lto-pgo 2>/dev/null'
```

Результаты:
- baseline O3+LTO: 4.55, 4.55, 4.54, 4.54, 4.74 (с), среднее **4.584**
- PGO O3+LTO: 4.74, 4.81, 4.73, 4.76, 4.74 (с), среднее **4.756**

Итог:
- замедление baseline относительно PGO: **1.04×**
- увеличение времени: **3.7%**

---

## Вывод
Условная компиляция корректно выбирает одну из четырёх веток по макросам `USE_GPU`/`USE_FLOAT`.  
Оптимизация `-O3 -march=native` ускорила `sha1-benchmark` примерно в **3.78×**, а LTO дополнительно снизила время ещё примерно на **6.7%**. Использование PGO дало замедление относительно baseline O3+LTO примерно **1.04×**.
