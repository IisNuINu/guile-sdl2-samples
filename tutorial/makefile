CC=gcc
#LDLIBS=`pkg-config --libs gtk+-2.0`
#CFLAGS=`pkg-config --cflags gtk+-2.0`
#LDLIBS=`pkg-config --libs glib-2.0`
#CFLAGS=`pkg-config --cflags glib-2.0`
#CFLAGS= -I/usr/include/guile/2.2 -shared -fPIC
CFLAGS= -shared -I/usr/include/guile/2.2 -fPIC
OFLAGS= -dD -c -I/usr/include/guile/2.2 -fPIC
#SDLFLAGS=`pkg-config --cflags sdl2`
#SDLLIBS=`pkg-config --libs sdl2`
SDLFLAGS  = -g -O2 -D_REENTRANT -I/usr/include/SDL2 -DHAVE_OPENGLES2 -DHAVE_OPENGL -DHAVE_SDL_TTF -g
SDLLIBS =  -lSDL2_test -lSDL2


#make my_addon_c.so
my_addon_c.so: my_addon_c.c
	${CC}  ${CFLAGS} -o $@ $<

sdlrect.o: sdlrect.c
	${CC}  ${OFLAGS} -o $@ $<

testspriteminimal: testspriteminimal.c
	${CC} -o $@ $^ $(SDLFLAGS) $(SDLLIBS)

#make 1.o
#bash -c "echo 1.c 1.c 1.o 1"
#1.c 1.c 1.o 1
1.o: 1.c
	bash -c "echo $< $? $@ $*.a"


