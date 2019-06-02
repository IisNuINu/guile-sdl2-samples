#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

(begin
(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:)
             ((sdl2 events) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))

;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))
(use-modules ((my_addon) #:prefix mySDL:))
(define work-path (string-append base-path "test/"))
(display base-path)(newline)

(use-modules (srfi srfi-9))
(use-modules ((rnrs bytevectors)))
(use-modules (srfi srfi-43))
)

(define MAX_SPEED 6)
;;randomize
(set! *random-state* (random-state-from-platform))

;;нужна структура которая будет хранить данные о спрайтах положение и скорость
(define-record-type <sprite-data>
  (make-sprite-data x y vx vy)
  sprite-data?
  (x sprite-data-x sprite-data-x-set!)
  (y sprite-data-y sprite-data-y-set!)
  (vx sprite-data-vx sprite-data-vx-set!)
  (vy sprite-data-vy sprite-data-vy-set!)
  )
;;и структура представляющая в scheme изображение спрайта(чтобы постоянн его не перезапрашивать
;;у sdl
(define-record-type <rect>
  (make-rect x y w h)
  rect?
  (x rect-x rect-x-set!)
  (y rect-y rect-y-set!)
  (w rect-w rect-w-set!)
  (h rect-h rect-h-set!)
  )


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

;; инициализирует окно и возвращает рендер
(define (init-everything x y w h)
  (display "Run InitEverything\n")
  (SDL:sdl-init '(video events))
  (display (SDL:sdl-version))
  (let ([win  (SDL:make-window #:size (list w h) #:title "Sprite demo"
                               #:position (list x y)
                               )])
    (let ([ren  (SDL:make-renderer win '(accelerated))])
      ;;(SDL:render-set-logical-size ren w h)
      (mySDL:set-render-draw-color ren 0 255 0  255)
      ren   ;; возвращаем рендер
      )))

;;создает одиночный спрайт инициализируя его случайными данными
;;пределы возможной скорости ограничены
(define init-sprite-data
  (let ([MAX-VX  MAX_SPEED]
        [MAX-VY  MAX_SPEED]
        [MIN-VX (- MAX_SPEED)]
        [MIN-VY (- MAX_SPEED)])
    (lambda (bound s-width s-height)
      (if (rect? bound)
          (let ([max-x  (- (rect-w bound) s-width)]
                [max-y  (- (rect-h bound) s-height)])
            (make-sprite-data (random max-x)
                              (random max-y)
                              (+ MIN-VX (random (- MAX-VX MIN-VX)))
                              (+ MIN-VY (random (- MAX-VY MIN-VY)))
                              ))
          (SDL:sdl-error "init-sprite-data" "invalid type bound")
          ))))

;;перемещение одного спрайта
(define  move-sprite-and-reflect-bound2
  (lambda (sprite bound spr-rect)
    (if (and (rect? bound) (sprite-data? sprite))
        (let ([max-x  (- (rect-w bound) (rect-w spr-rect))]
              [max-y  (- (rect-h bound) (rect-h spr-rect))])
          (let ([new-x (+ (sprite-data-x sprite) (sprite-data-vx sprite))]
                [new-y (+ (sprite-data-y sprite) (sprite-data-vy sprite))]
                )
            ;; check bound x
            (cond
             ((and (> (sprite-data-vx sprite) 0) (> new-x max-x) )
              ;;(set!  new-x (- (* 2 max-x) new-x))
              (sprite-data-vx-set! sprite (- (sprite-data-vx sprite))))
             ((and (< (sprite-data-vx sprite) 0) (< new-x 0))
              ;;(set!  new-x (- new-x))
              (sprite-data-vx-set! sprite (- (sprite-data-vx sprite))))
             )
            (sprite-data-x-set!  sprite new-x)
            ;; check bound y
            (cond
             ((and (> (sprite-data-vy sprite) 0) (> new-y max-y) )
              ;;(set!  new-y (- (* 2 max-y) new-y))
              (sprite-data-vy-set! sprite (- (sprite-data-vy sprite))))
             ((and (< (sprite-data-vy sprite) 0) (< new-y 0))
              ;;(set!  new-y (- new-y))
              (sprite-data-vy-set! sprite (- (sprite-data-vy sprite))))
             )
            (sprite-data-y-set!  sprite new-y)
            ))
        (SDL:sdl-error "init-sprite-data" "invalid type bound")
        )))

(define (move-vect-spr ren spr-tex num-cycles vect-spr bound spr-rect bg)
  (let ([num-sprite (vector-length vect-spr)]
        [s-rect     (mySDL:make-rect (rect-x spr-rect)
                                     (rect-y spr-rect)
                                     (rect-w spr-rect)
                                     (rect-h spr-rect))]
        [d-rect     (mySDL:make-rect 0 0
                                     (rect-w spr-rect)
                                     (rect-h spr-rect))]
        [bg-tex     (car bg)]
        [bg-rect    (mySDL:make-rect 0 0
                                     (rect-w bound)
                                     (rect-h bound))]
        )
    (do ([i 0 (1+ i)])
        ((>= i num-cycles))
      ;;(mySDL:set-render-draw-color ren 255 0 0 255)    ;;clear screen
      ;;(SDL:clear-renderer ren)
      (mySDL:render-copy ren bg-tex #:srcrect bg-rect #:dstrect bg-rect)
      ;;(display "Cycle: ") (display i) (newline)
      (do ([i-spr 0 (1+ i-spr)]) ;;move  and draw all sprite
          ((>= i-spr num-sprite))

        (let ([spr-dat (vector-ref vect-spr i-spr)])
          (move-sprite-and-reflect-bound2 spr-dat  bound spr-rect)  ;;move
          (mySDL:rect-x-set! d-rect (sprite-data-x spr-dat))  ;;draw
          (mySDL:rect-y-set! d-rect (sprite-data-y spr-dat))
          (mySDL:render-copy ren spr-tex #:srcrect s-rect #:dstrect d-rect)))
      (SDL:present-renderer ren)
      ;;(usleep 15000)
      )
      ))


(define  (run-game scr-rect ren spr-vect sprite spr-rect bg)
  (let ([start-time (gettimeofday)] [MAX_CYCLES 1300]
        [end-time -1]  [delta-mks 0]  [mks-per-cadr 0] [cadr-in-sec  0])
    (move-vect-spr ren (car sprite)  MAX_CYCLES spr-vect scr-rect spr-rect bg)
    (set! end-time (gettimeofday))
    (set! delta-mks (+ (* 1000000 (- (car end-time) (car start-time)))
                       (- (cdr end-time) (cdr start-time))))
    (set! mks-per-cadr (quotient delta-mks MAX_CYCLES))
    (set! cadr-in-sec  (quotient 1000000 mks-per-cadr))
    (display (string-append "All time execute: " (number->string delta-mks)
                            "mks, mks per cadr: " (number->string mks-per-cadr)
                            "mks, Cadr in sec: " (number->string cadr-in-sec) "\n"))
    ))


(define (main)
  ;;rect теперь берет память из кучи управляемой сборщиком мусора, его можно не освобождать
  (let ([posX 10] [posY 10]
        [sizeX 640] [sizeY 480]
        [spr1-x1 5 ] [spr1-y1 19]
        [spr1-x2 74] [spr1-y2 102]
        [max-spr 100])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let*  ([ren      (init-everything posX posY sizeX sizeY)]
                     [sprite   (load-sprite (string-append work-path "tux.bmp") ren)]
                     [bg       (load-image  (string-append work-path "bg.bmp") ren)]
                     [spr-w    (cadr sprite)]
                     [spr-h    (caddr sprite)]
                     [scr-rect (make-rect posX posY sizeX sizeY)]
                     [spr-rect (make-rect spr1-x1
                                          spr1-y1
                                          (- spr1-x2 spr1-x1)
                                          (- spr1-y2 spr1-y1))]
                     [bound    (make-rect 0 0 sizeX sizeY)]
                     [spr-vect (make-vector max-spr)])
               (vector-map! (lambda (ind el)
                              (init-sprite-data bound spr-w spr-h))
                            spr-vect)
               (run-game scr-rect ren spr-vect sprite spr-rect bg)
               )
             )
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    (SDL:sdl-quit)
  ))

(main)


