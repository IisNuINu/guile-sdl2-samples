#include <libguile.h>
#include <SDL2/SDL.h>
#include <stdlib.h>


const char *what = "sdl-rect";

SDL_Rect *
make_rect(int x, int y, int w, int h) {
  SDL_Rect * r;
  r = scm_gc_malloc(sizeof(SDL_Rect), what);
  r->x = x;
  r->y = y;
  r->w = w;
  r->h = h;  
  return r;
}

void
free_rect(SDL_Rect *r) {
  scm_gc_free(r, sizeof(SDL_Rect), what);
}

//getters
int
rect_get_x(SDL_Rect * r) {
  return r->x;
}

int
rect_get_y(SDL_Rect * r) {
  return r->y;
}

int
rect_get_w(SDL_Rect * r) {
  return r->w;
}

int
rect_get_h(SDL_Rect * r) {
  return r->h;
}

//setters
void
rect_set_x(SDL_Rect * r, int t) {
  r->x = t;
  return;
}

void
rect_set_y(SDL_Rect * r, int t) {
  r->y = t;
  return;
}

void
rect_set_w(SDL_Rect * r, int t) {
  r->w = t;
  return;
}

void
rect_set_h(SDL_Rect * r, int t) {
  r->h = t;
  return;
}


/*
void init_my_addon_c() {
  scm_c_define_gsubr("make-rect", 4, 0, 0, make_rect);
  scm_c_define_gsubr("free-rect", 1, 0, 0, free_rect);
}
*/
