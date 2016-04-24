CC = gcc
CFLAGS = -Wall 
UB = /usr/bin/
UI = /usr/include
OBJ = -o main
OBJ_GTK = -o gtk
LINK = -llua -lm
PKGCONFIG = `pkg-config --cflags --libs gtk+-3.0`
FILE = main.c

all:
	$(CC) $(CFLAGS) $(OBJ) $(PKGCONFIG) $(LINK) $(FILE)

gtk:
	$(CC) $(CFLAGS) -o gtk $(PKGCONFIG) $(LINK) gtk.c

clean:
	rm gtk
