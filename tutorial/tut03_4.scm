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


(define pi (* 2 (acos 0)))
(define points '((41 40) (0 40) (33 66) (21 106) (57 83) (91 106) (79 66) (111 40) (69 40) (57 0)))



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
      ;;(SDL:set-render-draw-color ren 0 255 0  255)
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


(define do-draw
  (let ([angle 0]        [scale 1]        [delta 0.01])
    (lambda (cr w h)
      ;;(display "Drawing with cairo\n")
      (let ([radius   40]
            )
        (CAI:cairo-set-source-rgb      cr 1  0  0)
        (CAI:cairo-set-line-width      cr 1)

        (CAI:cairo-translate           cr (/ w 2) (/ h 2))
        (CAI:cairo-rotate              cr angle)
        (CAI:cairo-scale               cr scale scale)

        (do ((plist points (cdr plist)))
            ((null?  plist))
          (let ([p (car plist)])
            (CAI:cairo-line-to         cr (car p) (cadr p))
            ))

        (CAI:cairo-close-path          cr)
        (CAI:cairo-fill                cr)
        (CAI:cairo-stroke              cr)

        (when (or (< scale 0.01)
                  (> scale 0.99))
              (set! delta (- delta)))
        
        (set! scale (+ scale delta))
        (let ([a (+ angle 0.01)])
          (if (> a 360)
              (set! angle (- a 360))
              (set! angle a)))
        ))))

(define (Render ren s-rect d-rect)
  ;;(display "Run Render\n")
  (let* ([w (mySDL:rect-w s-rect)]
         [h (mySDL:rect-h s-rect)]
         [i       (SDL:make-rgb-surface w h 32)]
         [surface (CAI:cairo-image-surface-create-for-data (SDL:surface-pixels i)
                                                     'argb32
                                                     (SDL:surface-width  i)
                                                     (SDL:surface-height i)
                                                     (SDL:surface-pitch  i))]
         [cr (CAI:cairo-create surface)])
    (do-draw cr w h)
    (let ([tex (SDL:surface->texture ren i)])
      (CAI:cairo-destroy         cr)
      (CAI:cairo-surface-destroy surface)
      (SDL:delete-surface!       i)
      
      (mySDL:render-copy ren  tex #:srcrect s-rect #:dstrect d-rect)
      (mySDL:destroy-texture  tex)
      ))
  ;;отобразим изменения
  (SDL:present-renderer ren)  
  )






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
              [(eq?  k 'up)  (display "UP\n")]
              [(eq?  k 'down)(display "DOWN\n")  ]
              [(eq?  k 'left)(display "LEFT\n")]
              [(eq?  k 'right)(display "RIGHT\n")]

               ))
           (Render ren s-rect d-rect)
           (usleep 16) ])
         )
      (Render ren s-rect d-rect)
      (usleep 100)
      )))



(define (main)
  (let ([s-rect (mySDL:make-rect 0 0 0 0)]
        [d-rect (mySDL:make-rect 0 0 0 0)]
        [posX 10] [posY 50]
        [sizeX 400] [sizeY 300])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let*  ([ren         (InitEverything posX posY sizeX sizeY)]
                     )
               (mySDL:rect-w-set! s-rect sizeX)
               (mySDL:rect-h-set! s-rect sizeY)
               (mySDL:rect-w-set! d-rect sizeX)
               (mySDL:rect-h-set! d-rect sizeY)
               (RunGame ren s-rect d-rect)
               ))
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    ;;(SDL:free-rect rect) ;;нет необходимости надеемся на GC
    )
  
  (SDL:sdl-quit)
  )
(main)

