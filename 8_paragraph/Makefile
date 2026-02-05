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
