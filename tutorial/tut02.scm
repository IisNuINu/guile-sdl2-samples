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
;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path)
)
(use-modules ((my_addon) #:prefix mySDL:))


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



(define (RunGame ren rect)
  (display "Run Game\n")
  (Render ren rect)
  (let loop ([event (SDL:poll-event)])
    (if event
        (cond
         [(SDL:quit-event? event)
          (display "bye!\n")]
         [(SDL:keyboard-down-event? event)
          (display "Key: ")     (display (SDL:keyboard-event-key event))
          (display ", Scan: ")  (display (SDL:keyboard-event-scancode event)) (newline)
          (let ([k (SDL:keyboard-event-scancode event)])
            (cond
             [(eq?  k 'up)
              (display "move UP\n")    (mySDL:rect-y-set! rect (- (mySDL:rect-y rect) 5))]
             [(eq?  k 'down)
              (display "move DOWN\n")  (mySDL:rect-y-set! rect (+ 5 (mySDL:rect-y rect)))]
             [(eq?  k 'left)
              (display "move LEFT\n")  (mySDL:rect-x-set! rect (- (mySDL:rect-x rect) 5))]
             [(eq?  k 'right)
              (display "move RIGHT\n") (mySDL:rect-x-set! rect (+ 5 (mySDL:rect-x rect)))]
             ))

          (Render ren rect)

          ;;(mySDL:sdl-delay 16)
          (usleep 16)
          (loop (SDL:poll-event))
          ]
         [else
          (loop (SDL:poll-event))
          ])
        (loop (SDL:poll-event))
        )))

(define (Render ren rect)
  (display "Run Render\n")
  ;;очистим окно и сделаем его зеленым
  (SDL:clear-renderer ren)

  ;;выберем синий цвет
  (SDL:set-render-draw-color ren 0 0 255 255)
  ;;заполним область выбранным цветом
  
  ;;(display "Run fill rect\n")
  (mySDL:render-fill-rect ren rect)
  ;;вернем зеленый цвет
  ;;(display "Run draw color\n")
  (SDL:set-render-draw-color ren 0 255 0 255)
  ;;отобразим изменения
  (SDL:present-renderer ren)  
  )

(define (main)
  (let ([rect (mySDL:make-rect 20 20 20 20)]
        [posX 100] [posY 200]
        [sizeX 300] [sizeY 400])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let  ([ren (InitEverything posX posY sizeX sizeY)])
               (RunGame ren rect)
               ))
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    ;;(SDL:free-rect rect) ;;нет необходимости надеемся на GC
    )
  (SDL:sdl-quit)
)
(main)

