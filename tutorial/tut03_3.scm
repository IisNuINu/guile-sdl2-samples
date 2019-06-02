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
(use-modules ((cairo) #:prefix CAI:))


;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки my_addon_c.so
(use-modules ((my_addon) #:prefix mySDL:))


(define img #f)
(define img-w 250)
(define img-h 100)
(define pi (* 2 (acos 0)))
;;(define tex #f)


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


(define (InitEverything x y w h)
  (display "Run InitEverything\n")
  (SDL:sdl-init '(video events))
  (display (SDL:sdl-version))
  (let ([win  (SDL:make-window #:size (list w h) #:title "Event's move"
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

(define  (cairo-fill-img ren)
  (let* ([i       (SDL:make-rgb-surface img-w img-h 32)]
         [surface (CAI:cairo-image-surface-create-for-data (SDL:surface-pixels i)
                                                     'argb32
                                                     (SDL:surface-width  i)
                                                     (SDL:surface-height i)
                                                     (SDL:surface-pitch  i))]
         [cr (CAI:cairo-create surface)])

    (display cr) (newline)
    (CAI:cairo-set-source-rgba cr 0.6 0.6 0.6 0.5)
    (CAI:cairo-rectangle      cr 0 0 250 100)
    (CAI:cairo-fill           cr)

    (CAI:cairo-set-source-rgb cr 0 0 0)
    (CAI:cairo-set-line-width cr 5)
    (CAI:cairo-move-to        cr 10  10)
    (CAI:cairo-line-to        cr 210 10)
    (CAI:cairo-stroke         cr)
    (CAI:cairo-arc            cr 110  50 40 0 (* 2 pi))
    (CAI:cairo-stroke         cr)

    (CAI:cairo-arc            cr 110 50 30 0 (* 2 pi))
    (CAI:cairo-fill           cr)

    (let ([tex (SDL:surface->texture ren i)])
      (CAI:cairo-destroy         cr)
      (CAI:cairo-surface-destroy surface)
      (SDL:delete-surface!       i)
      tex)
  ))



(define (RunGame ren s-rect d-rect)
  (display "Run Game\n")
  (Render ren s-rect d-rect)
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
           (Render ren s-rect d-rect)
           (usleep 16) ])
        ))))

(define (Render ren s-rect d-rect)
  (display "Run Render\n")
  ;;очистим окно и сделаем его зеленым
  ;;вернем зеленый цвет
  (SDL:set-render-draw-color ren 0 255 0 255)
  (SDL:clear-renderer ren)

  ;;выберем синий цвет
  ;;(SDL:set-render-draw-color ren 0 0 255 255)
  ;;(mySDL:render-fill-rect ren rect)
  (display img) (newline)
  (mySDL:render-copy ren img #:srcrect s-rect #:dstrect d-rect)
  
  ;;отобразим изменения
  (SDL:present-renderer ren)  
  )

(define (main)
  (let ([s-rect (mySDL:make-rect 0 0 0 0)]
        [d-rect (mySDL:make-rect 0 0 0 0)]
        [posX 100] [posY 200]
        [sizeX 300] [sizeY 400])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let*  ([ren         (InitEverything posX posY sizeX sizeY)]
                     )
               (set! img (cairo-fill-img ren))
               (mySDL:rect-w-set! s-rect img-w)
               (mySDL:rect-h-set! s-rect img-h)
               (mySDL:rect-w-set! d-rect img-w)
               (mySDL:rect-h-set! d-rect img-h)
               (RunGame ren s-rect d-rect)
               ))
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    ;;(SDL:free-rect rect) ;;нет необходимости надеемся на GC
    )
  (when img (mySDL:destroy-texture  img))
  (SDL:sdl-quit)
)
(main)

