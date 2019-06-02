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
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки my_addon_c.so
(use-modules ((my_addon) #:prefix mySDL:))


(define img #f)
;;(define img-h 0)
;;(define img-w 0)


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



(define (RunGame ren s-rect d-rect)
  (display "Run Game\n")
  (Render ren s-rect d-rect)
  (let loop ([event (SDL:poll-event)])
    (if event
        (cond
         [(SDL:quit-event? event)
          (display "bye!\n")]
         [(SDL:keyboard-down-event? event)
          (display "Key: ")     (display (SDL:keyboard-event-key       event))
          (display ", Scan: ")  (display (SDL:keyboard-event-scancode  event))
          (display ", Mod: ")   (display (SDL:keyboard-event-modifiers event)) (newline)
          (let ([k (SDL:keyboard-event-scancode  event)]
                [m (SDL:keyboard-event-modifiers event)])
            (cond
             [(eq?  k 'up)
              (display "move UP\n")    (mySDL:rect-y-set! d-rect (- (mySDL:rect-y d-rect) 5))]
             [(eq?  k 'down)
              (display "move DOWN\n")  (mySDL:rect-y-set! d-rect (+ 5 (mySDL:rect-y d-rect)))]
             [(eq?  k 'left)
              (display "move LEFT\n")  (mySDL:rect-x-set! d-rect (- (mySDL:rect-x d-rect) 5))]
             [(eq?  k 'right)
              (display "move RIGHT\n") (mySDL:rect-x-set! d-rect (+ 5 (mySDL:rect-x d-rect)))]
             [(or (eq?  k 'keypad-minus)
                  (eq?  k 'minus))
              (when (and (> (mySDL:rect-w d-rect) 5) (> (mySDL:rect-h d-rect) 5))
                    (display "less size\n")
                    (mySDL:rect-w-set! d-rect (- (mySDL:rect-w d-rect) 5))
                    (mySDL:rect-h-set! d-rect (- (mySDL:rect-h d-rect) 5)))]
             [(or (eq?  k 'keypad-plus)
                  (and (eq?  k 'equals) (member 'left-shift m)))
              (begin
                (display "great size\n")
                (mySDL:rect-w-set! d-rect (+ (mySDL:rect-w d-rect) 5))
                (mySDL:rect-h-set! d-rect (+ (mySDL:rect-h d-rect) 5)))]
             ))

          (Render ren s-rect d-rect)

          ;;(mySDL:sdl-delay 16)
          (usleep 16)
          (loop (SDL:poll-event))
          ]
         [else
          (loop (SDL:poll-event))
          ])
        (loop (SDL:poll-event))
        )))

(define (Render ren s-rect d-rect)
  ;;(display "Run Render\n")
  ;;очистим окно и сделаем его зеленым
  ;;вернем зеленый цвет
  (SDL:set-render-draw-color ren 0 255 0 255)
  (SDL:clear-renderer ren)

  ;;выберем синий цвет
  ;;(SDL:set-render-draw-color ren 0 0 255 255)
  ;;(mySDL:render-fill-rect ren rect)
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
                     [image-list  (load-image  (string-append work-path "tux.bmp") ren)])
               (set! img   (car   image-list))
               (mySDL:rect-w-set! s-rect (cadr  image-list))
               (mySDL:rect-h-set! s-rect (caddr image-list))
               (mySDL:rect-w-set! d-rect (cadr  image-list))
               (mySDL:rect-h-set! d-rect (caddr image-list))
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

