#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


;;(display %load-path)
(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:)
             ((sdl2 ttf) #:prefix SDL:)
             ((sdl2 bindings) #:prefix ffi:))

;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки my_addon_c.so
(use-modules ((my_addon) #:prefix mySDL:)
             )


(begin
  (SDL:sdl-init '(video))
  (define win_w 400)
  (define win_h 350)
  (define win (SDL:make-window #:size (list win_w win_h)
                               #:title "Testing TTF"
                               #:position (list ffi:SDL_WINDOWPOS_CENTERED
                                                ffi:SDL_WINDOWPOS_CENTERED)
                               #:show? #t))
  (define ren (SDL:make-renderer win))
  )

;;Печатаем приветствие
(begin
  (SDL:ttf-init)
  (define font1 (SDL:load-font "schou___.ttf" 20))

  (SDL:set-render-draw-color ren 255 255 255 255)
  (SDL:clear-renderer ren)
  (define s1 (SDL:render-font-solid font1 "Hello World!" (SDL:make-color 255 0 0 255)))
  (define tex1 (SDL:surface->texture ren s1))
  (SDL:render-copy ren tex1
                   #:srcrect (list 0 0 (SDL:surface-width s1) (SDL:surface-height s1))
                   #:dstrect (list 10 30 (SDL:surface-width s1) (SDL:surface-height s1)))
  (SDL:delete-surface! s1)
  (mySDL:destroy-texture tex1)
  
  (define s2 (SDL:render-font-solid font1 "Привет МИР!" (SDL:make-color 255 0 0 255)))
  (define tex2 (SDL:surface->texture ren s2))
  (let ([w (SDL:surface-width s2)] [h (SDL:surface-height s2)])
    (SDL:render-copy ren tex2
                     #:srcrect (list 0 0  w h)
                     #:dstrect (list 10 60 w h)))
  (SDL:delete-surface! s2)
  (mySDL:destroy-texture tex2)
  (SDL:present-renderer ren)
)

(sleep 10)
