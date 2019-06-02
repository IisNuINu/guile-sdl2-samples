/*
  Copyright (C) 1997-2018 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely.
*/
/* Simple program:  Move N sprites around on the screen as fast as possible */

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>

#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>
#endif

#include "SDL.h"

#define WINDOW_WIDTH    640
#define WINDOW_HEIGHT   480
#define NUM_SPRITES     100
#define MAX_SPEED       5

static SDL_Texture *sprite;
static SDL_Texture *bg;
static int bg_w, bg_h;
static SDL_Rect positions[NUM_SPRITES];
static SDL_Rect velocities[NUM_SPRITES];
static int sprite_w, sprite_h;

SDL_Renderer *renderer;
int done;

/* Call this instead of exit(), so we can clean up SDL: atexit() is evil. */
static void
quit(int rc)
{
    exit(rc);
}

int
LoadSprite(char *file, SDL_Renderer *renderer)
{
    SDL_Surface *temp;

    /* Load the sprite image */
    temp = SDL_LoadBMP(file);
    if (temp == NULL) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't load %s: %s\n", file, SDL_GetError());
        return (-1);
    }
    sprite_w = temp->w;
    sprite_h = temp->h;

    /* Set transparent pixel as the pixel at (0,0) */
    if (temp->format->palette) {
        SDL_SetColorKey(temp, SDL_TRUE, *(Uint8 *) temp->pixels);
    } else {
        switch (temp->format->BitsPerPixel) {
        case 15:
            SDL_SetColorKey(temp, SDL_TRUE,
                            (*(Uint16 *) temp->pixels) & 0x00007FFF);
            break;
        case 16:
            SDL_SetColorKey(temp, SDL_TRUE, *(Uint16 *) temp->pixels);
            break;
        case 24:
            SDL_SetColorKey(temp, SDL_TRUE,
                            (*(Uint32 *) temp->pixels) & 0x00FFFFFF);
            break;
        case 32:
            SDL_SetColorKey(temp, SDL_TRUE, *(Uint32 *) temp->pixels);
            break;
        }
    }

    /* Create textures from the image */
    sprite = SDL_CreateTextureFromSurface(renderer, temp);
    if (!sprite) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't create texture: %s\n", SDL_GetError());
        SDL_FreeSurface(temp);
        return (-1);
    }
    SDL_FreeSurface(temp);

    /* We're ready to roll. :) */
    return (0);
}


int
LoadBg(char *file, SDL_Renderer *renderer)
{
    SDL_Surface *temp;

    /* Load the sprite image */
    temp = SDL_LoadBMP(file);
    if (temp == NULL) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't load %s: %s\n", file, SDL_GetError());
        return (-1);
    }
    bg_w = temp->w;
    bg_h = temp->h;

    /* Create textures from the image */
    bg = SDL_CreateTextureFromSurface(renderer, temp);
    if (!bg) {
        SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, "Couldn't create texture: %s\n", SDL_GetError());
        SDL_FreeSurface(temp);
        return (-1);
    }
    SDL_FreeSurface(temp);

    /* We're ready to roll. :) */
    return (0);
}


void
MoveSprites(SDL_Renderer * renderer, SDL_Texture * sprite)
{
    int i;
    int window_w = WINDOW_WIDTH;
    int window_h = WINDOW_HEIGHT;
    SDL_Rect *position, *velocity;

    /* Draw a gray background */
    //SDL_SetRenderDrawColor(renderer, 0xA0, 0xA0, 0xA0, 0xFF);
    //SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, bg, NULL, NULL);

    /* Move the sprite, bounce at the wall, and draw */
    for (i = 0; i < NUM_SPRITES; ++i) {
        position = &positions[i];
        velocity = &velocities[i];
        position->x += velocity->x;
        if ((position->x < 0) || (position->x >= (window_w - sprite_w))) {
            velocity->x = -velocity->x;
            position->x += velocity->x;
        }
        position->y += velocity->y;
        if ((position->y < 0) || (position->y >= (window_h - sprite_h))) {
            velocity->y = -velocity->y;
            position->y += velocity->y;
        }

        /* Blit the sprite onto the screen */
        SDL_RenderCopy(renderer, sprite, NULL, position);
    }

    /* Update the screen! */
    SDL_RenderPresent(renderer);
}

void loop()
{
    SDL_Event event;

    /* Check for events */
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT || event.type == SDL_KEYDOWN) {
            done = 1;
        }
    }
    MoveSprites(renderer, sprite);
#ifdef __EMSCRIPTEN__
    if (done) {
        emscripten_cancel_main_loop();
    }
#endif
}

int
main(int argc, char *argv[])
{
    SDL_Window *window;
    int i;


    /* Enable standard application logging */
    SDL_LogSetPriority(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_INFO);

    if (SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer) < 0) {
        quit(2);
    }

    if (LoadSprite("tux.bmp", renderer) < 0) {
        quit(2);
    }

    if (LoadBg("bg.bmp", renderer) < 0) {
        quit(2);
    }

    /* Initialize the sprite positions */
    srand(time(NULL));
    for (i = 0; i < NUM_SPRITES; ++i) {
        positions[i].x = rand() % (WINDOW_WIDTH - sprite_w);
        positions[i].y = rand() % (WINDOW_HEIGHT - sprite_h);
        positions[i].w = sprite_w;
        positions[i].h = sprite_h;
        velocities[i].x = 0;
        velocities[i].y = 0;
        while (!velocities[i].x && !velocities[i].y) {
            velocities[i].x = (rand() % (MAX_SPEED * 2 + 1)) - MAX_SPEED;
            velocities[i].y = (rand() % (MAX_SPEED * 2 + 1)) - MAX_SPEED;
        }
    }

    /* Main render loop */
    done = 0;
   /* Animate 300 frames (approximately 10 seconds). */
    #define MAX_CYCLES  1300
    int ret;
    struct timeval  start_time;
    struct timeval  end_time;
    struct timezone tz;
    
    ret = gettimeofday(&start_time, &tz);
    if(ret == 0) {
       printf("Start sec: %ld, and microsec: %ld\n",
              start_time.tv_sec, start_time.tv_usec);
    } else {
       printf("Cannot get time of day, err: %d\n", ret);
    }

#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop(loop, 0, 1);
#else
    //while (!done) {
    //    loop();
    //}
   for (int frames = 0; frames < MAX_CYCLES; frames++) {
        loop();
   }
#endif
    ret = gettimeofday(&end_time, &tz);
    printf("End sec: %d, and microsec: %d\n",
           (unsigned int)end_time.tv_sec, (unsigned int)end_time.tv_usec);

    unsigned long int delta_mks;

    delta_mks  = 1000000 *
                 (unsigned long int)(end_time.tv_sec - start_time.tv_sec)+
                 (end_time.tv_usec - start_time.tv_usec);
    unsigned int mks_per_cadr;
    mks_per_cadr = delta_mks / MAX_CYCLES;
    unsigned int cadr_in_sec;
    cadr_in_sec  = 1000000/mks_per_cadr;

    printf("All time execute: %d mks, mks per cadr: %d mks, Cadr in sec: %d\n" ,
            (unsigned int)delta_mks, mks_per_cadr, cadr_in_sec);

    quit(0);

    return 0; /* to prevent compiler warning */
}

/* vi: set ts=4 sw=4 expandtab: */
