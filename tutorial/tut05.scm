#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:)
             ((sdl2 events) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
(use-modules (srfi srfi-9))
(use-modules ((rnrs bytevectors)))
(use-modules (srfi srfi-43))


;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки my_addon_c.so
(use-modules ((my_addon) #:prefix mySDL:))


(define img #f)
(define bg  #f)
(define bg-h 0)
(define bg-w 0)


;; загрузка обычного изображения без определения прозрачного цвета, возвращает список из
;; изображения, ширины и высоты
(define (load-image f-name ren)
  (let* ([temp-surface (SDL:load-bmp f-name)]
         [sprite-w (SDL:surface-width  temp-surface)]
         [sprite-h (SDL:surface-height temp-surface)])
    (let ([tex (SDL:surface->texture ren temp-surface)])
      (SDL:delete-surface! temp-surface)
      (list  tex sprite-w sprite-h))
    ))

;;загрузка спрайта, возвращает список из спрайта ширину и высоту
(define (load-sprite f-name ren)
  (let* ([temp-surface (SDL:load-bmp f-name)]
         [sprite-w (SDL:surface-width  temp-surface)]
         [sprite-h (SDL:surface-height temp-surface)]
         [t-pixels (SDL:surface-pixels temp-surface)])
    (if (SDL:pixel-format? temp-surface)
        (mySDL:set-color-key temp-surface
                     (ffi:boolean->sdl-bool #t)
                     (bytevector-u8-ref t-pixels 0))
        (let* ([pf  (SDL:surface-pixel-format temp-surface)]
               [bpp (SDL:pixel-format-bits-per-pixel pf)])
          (case bpp ;;bits-per-pixel
            [(15) (mySDL:set-color-key temp-surface
                                       (ffi:boolean->sdl-bool #t)
                                       (logand (bytevector-u16-native-ref t-pixels 0)
                                               #x000007ff))]
            [(16) (mySDL:set-color-key temp-surface
                                       (ffi:boolean->sdl-bool #t)
                                       (bytevector-u16-native-ref t-pixels 0))]
            [(24) (mySDL:set-color-key temp-surface
                                       (ffi:boolean->sdl-bool #t)
                                       (logand (bytevector-u32-native-ref t-pixels 0)
                                               #x00ffffff))]
            [(32) (mySDL:set-color-key temp-surface
                                       (ffi:boolean->sdl-bool #t)
                                       (bytevector-u32-native-ref t-pixels 0))]
            )))
    (let ([tex (SDL:surface->texture ren temp-surface)])
      (SDL:delete-surface! temp-surface)
      (list  tex sprite-w sprite-h))
    ))


(define (InitEverything x y w h)
  (display "Run InitEverything\n")
  (SDL:sdl-init '(video events))
  (display (SDL:sdl-version))
  (let ([win  (SDL:make-window #:size (list w h) #:title "Sprite rotate"
                             #:position (list x y)
                             )])
    (let ([ren  (SDL:make-renderer win '(accelerated))])
      ;;(mySDL:render-set-logical-size ren w h)
      (SDL:set-render-draw-color ren 0 255 0  255)
      ren   ;; возвращаем рендер
      )))

(define (change-rect-by-delta-width! rect delta)
  (let ([w (mySDL:rect-w rect)]
        [h (mySDL:rect-h rect)])
    (when (or (> delta 0)
              (> w (abs delta)))
          (let* ([new-w (+ w delta)]
                 [new-h (round (/ (* h new-w) w))])
            (mySDL:rect-w-set! rect new-w)
            (mySDL:rect-h-set! rect new-h)))) 
  )

(define (RunGame ren s-rect d-rect bg-rect)
  (display "Run Game\n")
  (let ([angle 0]
        [flip mySDL:SDL_FLIP_NONE])
    (Render ren s-rect d-rect  bg-rect angle flip)
    (while #t
     (let ([event (SDL:poll-event)])
       (when event
        (cond
         [(SDL:quit-event? event)
          (display "bye!\n")
          (break)]
         [(SDL:keyboard-down-event? event)
          (display "Key: ")     (display (SDL:keyboard-event-key       event))
          (display ", Scan: ")  (display (SDL:keyboard-event-scancode  event))
          (display ", Mod: ")   (display (SDL:keyboard-event-modifiers event)) (newline)
          (let ([k (SDL:keyboard-event-scancode event)]
                [m (SDL:keyboard-event-modifiers event)])
            (cond
             [(eq?  k 'escape) (display "Escape - bye!\n") (break)]
             [(eq?  k '0)(display "FLIP: none\n")  (set! flip  mySDL:SDL_FLIP_NONE)]
             [(eq?  k '1)(display "FLIP: HORIZ\n")  (set! flip  mySDL:SDL_FLIP_HORIZONTAL)]
             [(eq?  k '2)(display "FLIP: VERT\n")   (set! flip  mySDL:SDL_FLIP_VERTICAL)]
             [(eq?  k '3)(display "FLIP: HORIZ and VERT\n")
              (set! flip (logior  mySDL:SDL_FLIP_HORIZONTAL mySDL:SDL_FLIP_VERTICAL))]
             [(eq?  k 'q)(display "ROT ^\n")  (set! angle  (floor-remainder (- angle 5) 360.0))]
             [(eq?  k 'w)(display "ROT v\n")  (set! angle  (floor-remainder (+ angle 5) 360.0))]
             [(eq?  k 'up)  (display "UP\n")    (mySDL:rect-y-set! d-rect (- (mySDL:rect-y d-rect) 5))]
             [(eq?  k 'down)(display "DOWN\n")  (mySDL:rect-y-set! d-rect (+ 5 (mySDL:rect-y d-rect)))]
             [(eq?  k 'left)(display "LEFT\n")  (mySDL:rect-x-set! d-rect (- (mySDL:rect-x d-rect) 5))]
             [(eq?  k 'right)(display "RIGHT\n")(mySDL:rect-x-set! d-rect (+ 5 (mySDL:rect-x d-rect)))]
             [(or (eq?  k 'keypad-minus) (eq?  k 'minus))
              (when (and (> (mySDL:rect-w d-rect) 5) (> (mySDL:rect-h d-rect) 5))
                    (display "less size\n")
                    (change-rect-by-delta-width! d-rect -5))]
             [(or (eq?  k 'keypad-plus)
                  (and (eq?  k 'equals) (member 'left-shift m)))
              (begin (display "great size\n")  (change-rect-by-delta-width! d-rect 5))]
             ))
          (Render ren s-rect d-rect  bg-rect  angle flip)
          (usleep 16000) ])
        )))))

(define (Render ren s-rect d-rect bg-rect angle flip)
  ;;(display "Run Render\n")
  ;;очистим окно и сделаем его зеленым
  ;;вернем зеленый цвет
  ;;(SDL:set-render-draw-color ren 0 255 0 255)
  ;;(SDL:clear-renderer ren)
  (mySDL:render-copy ren bg #:srcrect bg-rect #:dstrect bg-rect)

  ;;выберем синий цвет
  ;;(SDL:set-render-draw-color ren 0 0 255 255)
  ;;(mySDL:render-fill-rect ren rect)
  (mySDL:render-copy-ex ren img #:srcrect s-rect #:dstrect d-rect #:angle angle #:flip flip)
  
  ;;отобразим изменения
  (SDL:present-renderer ren)  
  )

(define (main)
  (let ([s-rect (mySDL:make-rect 0 0 0 0)]
        [d-rect (mySDL:make-rect 0 0 0 0)]
        [posX 100] [posY 200]
        [sizeX 640] [sizeY 480])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let*  ([ren         (InitEverything posX posY sizeX sizeY)]
                     [image-list  (load-sprite (string-append work-path "tux.bmp") ren)]
                     [bg-list     (load-image  (string-append work-path "bg.bmp") ren)]
                     [bg-rect     (mySDL:make-rect 0 0 sizeX sizeY)])
               (set! img   (car   image-list))
               (mySDL:rect-w-set! s-rect (cadr  image-list))
               (mySDL:rect-h-set! s-rect (caddr image-list))
               (mySDL:rect-w-set! d-rect (cadr  image-list))
               (mySDL:rect-h-set! d-rect (caddr image-list))
               (set! bg   (car   bg-list))
               (RunGame ren s-rect d-rect bg-rect)
               ))
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    ;;(SDL:free-rect rect) ;;нет необходимости надеемся на GC
    )
  (SDL:sdl-quit)
)
(main)

