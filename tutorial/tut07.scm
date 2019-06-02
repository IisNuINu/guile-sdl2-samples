#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render)  #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video)   #:prefix SDL:)
             ((sdl2 image)   #:prefix SDL:)
             ((sdl2 events)  #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
(use-modules (srfi srfi-9))
(use-modules ((rnrs bytevectors)))
(use-modules (srfi srfi-43))


;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки my_addon_c.so
(use-modules ((my_addon) #:prefix mySDL:)
             ((my_gfx) #:prefix GFX:))


(define (InitEverything x y w h)
  (display "Run InitEverything\n")
  (SDL:sdl-init '(video events))
  (display (SDL:sdl-version))
  (let ([win  (SDL:make-window #:size (list w h) #:title "GFX demo"
                             #:position (list x y)
                             )])
    (let ([ren  (SDL:make-renderer win '(accelerated))])
      ;;(mySDL:render-set-logical-size ren w h)
      (SDL:set-render-draw-color ren 0 255 0  255)
      ren   ;; возвращаем рендер
      )))

(define (clear-white ren)
    (SDL:set-render-draw-color ren 255 255 255 255)
    (SDL:clear-renderer ren)
    (SDL:present-renderer ren))

(define (RunGame ren list-job)
  (display "Run Game\n")
  (let ([job #f]
        [rest-job list-job])
    (clear-white ren)
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
             [(eq?  k 'space)
              (display "NEXT\n")
              (if (null? rest-job)
                  (begin
                    (display "All job ended - bye!\n") (break))
                  (begin
                    (set! job (car rest-job))
                    (set! rest-job (cdr rest-job))))]
             ))
          (Render ren job)
          (sleep 1) ])
        )))))

(define (Render ren job)
  (when job
        (display "run: ")
        (display (cadr job))
        (newline)
        ((car job) ren))
  ;;отобразим изменения
  ;;(SDL:present-renderer ren)
  )

(define (main jobs)
  (let ([s-rect (mySDL:make-rect 0 0 0 0)]
        [d-rect (mySDL:make-rect 0 0 0 0)]
        [posX 10] [posY 20]
        [sizeX 300] [sizeY 350])
    (catch #t   ;;перехватываем все исключения 'sdl-error
           (lambda ()
             (let ([ren         (InitEverything posX posY sizeX sizeY)]
                   [list-job jobs])
               (display list-job)
               (SDL:image-init)
               (RunGame ren list-job)
               (SDL:image-quit)
               ))
           (lambda (key .  args)
             (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
    )
  (SDL:sdl-quit)
)


(define (test-pixel-rgba ren)
  (SDL:set-render-draw-color ren 255 255 0 255)
  (SDL:clear-renderer ren)
  (let vert ([y 10] [b 0])
    (if (< b 255)
        (begin
          (let gor ([x 10] [g 0])
            (if (< g 255)
                (begin
                  ;;(format #t "make point: x:~d, y:~d g:~d~%"  x y g)
                  (GFX:pixel-rgba ren x y 0 g b 255)
                  (gor (1+ x) (1+ g)))))
          (vert (1+ y) (1+ b)))))
  (SDL:present-renderer ren))


(define (make-color r g b a)
  (logior r (ash (logior g (ash (logior b (ash a 8)) 8)) 8)))

;;квадрат разноцветных точек на красном фоне меняем синий и зеленый цвета
(define (test-pixel-color ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (let vert ([y 10] [b 0])
    (if (< b 255)
        (begin
          (let gor ([x 10] [g 0])
            (if (< g 255)
                (begin
                  ;;(format #t "make point: x:~d, y:~d g:~d~%"  x y g)
                  (GFX:pixel-color ren x y (make-color 0 g b 255))
                  (gor (1+ x) (1+ g)))))
          (vert (1+ y) (1+ b)))))
  (SDL:present-renderer ren))


;;test hline-rgba
;;на зеленом фоне рисуем горизонтальные линии красного цвета измеяющиеся вертикально
(define (test-hline-rgba ren)
  (SDL:set-render-draw-color ren 0 255 0 255)
  (SDL:clear-renderer ren)
  (let ([x1 10] [x2 265])
    (let vert ([y 10] [r 255])
      (if (> r 0)
          (begin
            ;;(format #t "make point: x:~d, y:~d g:~d~%"  x y g)
            (GFX:hline-rgba ren x1 x2 y r 0 0 255)
            (vert (1+ y) (- r 1))))))
  (SDL:present-renderer ren))


;;test hline-color
;;на синем фоне рисуем горизонтальные линии красного цвета измеяющиеся вертикально
(define (test-hline-color ren )
  (SDL:set-render-draw-color ren 0 0 255 255)
  (SDL:clear-renderer ren)
  (let ([x1 10] [x2 265])
    (let vert ([y 10] [r 255])
      (if (> r 0)
          (begin
            (GFX:hline-color ren x1 x2 y (make-color r 0 0 255))
            (vert (1+ y) (- r 1))))))
  (SDL:present-renderer ren))

;;на синем фоне рисуем вертикальные линии зеленого цвета измеяющиеся по горизонтали
(define (test-vline-color ren)
  (SDL:set-render-draw-color ren 0 0 255 255)
  (SDL:clear-renderer ren)
  (let ([y1 10] [y2 265])
    (let vert ([x 10] [g 255])
      (if (> g 0)
          (begin
            (GFX:vline-color ren x y1 y2 (make-color 0 g 0 255))
            (vert (1+ x) (- g 1))))))
  (SDL:present-renderer ren))  ;;C-x e

;;на синем фоне рисуем вертикальные линии зеленого цвета измеяющиеся по горизонтали
(define (test-vline-rgba ren)
  (SDL:set-render-draw-color ren 0 0 255 255)
  (SDL:clear-renderer ren)
  (let ([y1 10] [y2 265])
    (let vert ([x 10] [g 0])
      (if (< g 255)
          (begin
            ;;(format #t "make point: x:~d, y:~d g:~d~%"  x y g)
            (GFX:vline-rgba ren x y1 y2 0 g 0 255)
            (vert (1+ x) (1+ g))))))
  (SDL:present-renderer ren))  ;;C-x e

;;тестируем прямоугольники
(define (test-rectangle ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (let ([x1 10] [x2 265])
    (let ([y1 10] [y2  40])
      (GFX:rectangle-color ren x1 y1 x2 y2 (make-color 0 255 0 255)))
    (let ([y1 50] [y2  80])
      (GFX:rectangle-rgba  ren x1 y1 x2 y2 0 255 0 255))
    (let ([y1 90] [y2  120])
      (GFX:rounded-rectangle-color ren x1 y1 x2 y2 5 (make-color 0 255 255 255)))
    (let ([y1 130] [y2  160])
      (GFX:rounded-rectangle-rgba  ren x1 y1 x2 y2 10 0 255 255 255))
    )
  (SDL:present-renderer ren))  ;;C-x e

;;тестируем прямоугольники
(define (test-box ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (let ([x1 10] [x2 265])
    (let ([y1 10] [y2  40])
      (GFX:box-color ren x1 y1 x2 y2 (make-color 0 255 0 255)))
    (let ([y1 50] [y2  80])
      (GFX:box-rgba  ren x1 y1 x2 y2 0 255 0 255))
    (let ([y1 90] [y2  120])
      (GFX:rounded-box-color ren x1 y1 x2 y2 5 (make-color 0 255 255 255)))
    (let ([y1 130] [y2  160])
      (GFX:rounded-box-rgba  ren x1 y1 x2 y2 10 0 255 255 255))
    )
  (SDL:present-renderer ren))  ;;C-x e


(begin
  (define pi (* 2 (acos 0)))
  (define (rad->grad r)
    (/ (* r 180) pi))
  (define (grad->rad x)
    (/ (* x pi) 180))
  (define (rad->grad-int r)
    (inexact->exact (round (/ (* r 180) pi))))
  (define (grad->rad-int x)
    (inexact->exact (round (/ (* x pi) 180))))
  )

(define (test-line ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (let ([r1 20] [r2 60] [x0 75] [y0 75])
    (let rot ([alpha 0] [b 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x0 (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y0 (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x0 (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y0 (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:line-color ren x1 y1 x2 y2 (make-color 0 0 b 255))
            (rot (+ alpha 10) (+ b 7)))))
    )
   (SDL:present-renderer ren))

(define* (draw-sol-ray-rgba ren x y r1 r2 step #:key (r 0) (g 0) (b 0) (a 255))
  (let rot ([alpha 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:line-rgba ren x1 y1 x2 y2 r g b a)
            (rot (+ alpha step)))))
    )
            
(define (test-line2 ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-rgba ren 75 75 20 60 10)
    )
  (SDL:present-renderer ren))

(define (test-line3 ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-rgba ren  75 75 20 60 10 #:b 255)
    (draw-sol-ray-rgba ren  220 75 20 60 20 #:r 255 #:g 255)
    (draw-sol-ray-rgba ren  75 220 20 60 15 #:g 255)
    (draw-sol-ray-rgba ren  220 220 20 60 30 #:b 255 #:g 255)
    )
  (SDL:present-renderer ren))

(define* (draw-sol-ray-aaline-rgba ren x y r1 r2 step #:key (r 0) (g 0) (b 0) (a 255))
  (let rot ([alpha 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:aaline-rgba ren x1 y1 x2 y2 r g b a)
            (rot (+ alpha step)))))
    )

(define (test-aaline-rgba ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-aaline-rgba ren 75 75 20 60 10 #:b 255)
    (draw-sol-ray-aaline-rgba ren 220 75 20 60 20 #:r 255 #:g 255)
    (draw-sol-ray-aaline-rgba ren 75 220 20 60 15 #:g 255)
    (draw-sol-ray-aaline-rgba ren 220 220 20 60 30 #:b 255 #:g 255)
    )
  (SDL:present-renderer ren))

(define* (draw-sol-ray-aaline-color ren x y r1 r2 step color)
  (let rot ([alpha 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:aaline-color ren x1 y1 x2 y2 color)
            (rot (+ alpha step)))))
    )

(define (test-aaline-color ren)
  (SDL:set-render-draw-color ren 255 0 0 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-aaline-color ren 75 75 20 60 10 (make-color 0 0 255 255))
    (draw-sol-ray-aaline-color ren 220 75 20 60 20 (make-color 255 255 0 255))
    (draw-sol-ray-aaline-color ren 75 220 20 60 15 (make-color 0 255 0 255))
    (draw-sol-ray-aaline-color ren 220 220 20 60 30 (make-color 0 255 255 255))
    )
  (SDL:present-renderer ren))


(define* (draw-sol-ray-thick-line-color ren x y r1 r2 step width color)
  (let rot ([alpha 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:thick-line-color ren x1 y1 x2 y2 width color)
            (rot (+ alpha step)))))
    )

(define (test-thick-line-color ren )
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-thick-line-color ren 75 75 20 60 10 2 (make-color 0 0 255 255))
    (draw-sol-ray-thick-line-color ren 220 75 20 60 20 10 (make-color 255 0 0 255))
    (draw-sol-ray-thick-line-color ren 75 220 20 60 15 5 (make-color 0 255 0 255))
    (draw-sol-ray-thick-line-color ren 220 220 20 60 30 20 (make-color 0 255 255 255))
    )
  (SDL:present-renderer ren))


(define* (draw-sol-ray-thick-line-rgba ren x y r1 r2 step width #:key (r 0) (g 0) (b 0) (a 255))
  (let rot ([alpha 0])
      (if (< alpha 360)
          (let* ([rad (grad->rad alpha)] [sin-rad (sin rad)] [cos-rad (cos rad)]
                 [x1 (inexact->exact (round (+ x (* r1 cos-rad))))]
                 [y1 (inexact->exact (round (+ y (* r1 sin-rad))))]
                 [x2 (inexact->exact (round (+ x (* r2 cos-rad))))]
                 [y2 (inexact->exact (round (+ y (* r2 sin-rad))))])
            ;;(format #t "x1:~d, y1:~d x2:~d y2:~d~%"  x1 y1 x2 y2)
            (GFX:thick-line-rgba ren x1 y1 x2 y2 width r g b a)
            (rot (+ alpha step)))))
    )
            
(define (test-thick-line-rgba ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (draw-sol-ray-thick-line-rgba ren 75 75 20 60 10 2 #:b 255)
    (draw-sol-ray-thick-line-rgba ren 220 75 20 60 20 10 #:r 255 #:g 255)
    (draw-sol-ray-thick-line-rgba ren 75 220 20 60 15 5 #:g 255)
    (draw-sol-ray-thick-line-rgba ren 220 220 20 60 30 15 #:b 255 #:g 255)
    )
  (SDL:present-renderer ren))

(define (test-circle ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:circle-color ren 50 40 30 (make-color 0 0 255 255))
    (GFX:circle-rgba ren 220 40 20 255 255 0 255)
    ;;данные об угле передаются В ГРАДУСАХ!!
    (GFX:arc-color ren  50 110 30
                   10
                   120 (make-color 0 0 0 255))
    (GFX:arc-rgba ren 220 110 25 95 180 255 255 255 255)

    (GFX:aacircle-color ren 50 180 30 (make-color 255 0 255 255))
    (GFX:aacircle-rgba ren 220 180 20 255 0 0 255)
    (GFX:filled-circle-color ren 50 240 25 (make-color 10 10 0 255))
    (GFX:filled-circle-rgba ren 220 240 20 255 255 255 255)
    )
  (SDL:present-renderer ren))

(define (test-ellipse ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:ellipse-color ren 50 40 30 10 (make-color 0 0 255 255))
    (GFX:ellipse-rgba ren 220 40 10 30 255 255 0 255)
    (GFX:aaellipse-color ren 50  180 40 20 (make-color 255 0 255 255))
    (GFX:aaellipse-rgba  ren 220 180 30 30 255 0 0 255)
    (GFX:filled-ellipse-color ren 50 240 50 20 (make-color 10 10 0 255))
    (GFX:filled-ellipse-rgba ren 220 240 10 30 255 255 255 255)
    )
  (SDL:present-renderer ren))

(define (test-pie ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:pie-color ren 50 40 30 10 90 (make-color 0 0 255 255))
    (GFX:pie-rgba ren 220 40 40 90 180 255 255 0 255)
    (GFX:filled-pie-color ren 50 140 50 0   90 (make-color 10 10 0 255))
    (GFX:filled-pie-rgba ren 220 140 30 270 360 255 255 255 255)
    )
  (SDL:present-renderer ren))

(define (test-trigon ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:trigon-color ren   20  10    10  50   20  50   (make-color 0 0 255 255))
    (GFX:trigon-rgba  ren   150 40    200 40   175 10  255 255 0 255)
    (GFX:aatrigon-color ren 20  160    10  90   50  90   (make-color 10 10 0 255))
    (GFX:aatrigon-rgba  ren 220 100   280 170  150 140  0 255 255 255)
    (GFX:filled-trigon-color ren 100  250   50 280  50  190  (make-color 70 0 200 255))
    (GFX:filled-trigon-rgba  ren 280  220   180 270  290 340  255 0 0 255)
    )
  (SDL:present-renderer ren))

(define (test-polygon ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:polygon-color ren
                       (list->s16vector '(66 110 92  40  24))
                       (list->s16vector '(25 53  103 103 53))
                       (make-color 0 0 255 255))
    (GFX:polygon-rgba  ren
                       (list->s16vector '(222 272 222 172))
                       (list->s16vector '(21  71  121 71))
                       255 255 0 255)
    (GFX:aapolygon-color ren
                         (list->s16vector '(71  105  15  125  38))
                         (list->s16vector '(150 252  188 188  252))
                         (make-color 10 10 0 255))
    (GFX:aapolygon-rgba  ren
                         (list->s16vector '(218 230 272 240 252 218 182 194 161 202))
                         (list->s16vector '(152 192 192 218 258 235 258 218 192 192))
                         0 255 255 255)
    (GFX:filled-polygon-color ren
                      (list->s16vector '(72  104 92  52  40))
                      (list->s16vector '(272 295 332 332 295))
                      (make-color 70 0 200 255))
    (GFX:filled-polygon-rgba  ren
                              (list->s16vector '(210 215 232 215 210 205 188 205))
                              (list->s16vector '(288 303 308 313 329 313 308 303))
                              255 0 0 255)
    )
  (SDL:present-renderer ren))

;;очень странное поведение при отображании, разные результаты получаются от запуска к запуску
;; часть полигонов затираются, скорее всего ошибка в базовой библиотеке
;; для корректной работы НЕ НАДО вызывать обновление рендера!!!!!
;; это значит что данная функция не предназначена для непосредственного
;; рисования на экранном рендере!!!!!
(define (test-textured-polygon ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (let* ([texture (SDL:load-image "test1.png")]
         )
    ;;(mySDL:set-color-key texture
    ;;                     (ffi:boolean->sdl-bool #t)
    ;;                     (make-color  255 255 2255 255))
    ;;(set! texture  (SDL:surface->texture ren texture))

    (GFX:textured-polygon ren
                          (list->s16vector '(66 110 92  40  24  66))
                          (list->s16vector '(25 53  103 103 53  25))
                          texture
                          50 0)
    (GFX:textured-polygon  ren
                           (list->s16vector '(222 272 222 172 222))
                           (list->s16vector '(21  71  121 71  21))
                           texture
                           0 0)
    (GFX:textured-polygon ren
                          (list->s16vector '(71  105  15  125  38  71))
                          (list->s16vector '(150 252  188 188  252 150))
                          texture
                          5 0)
    (GFX:textured-polygon  ren
                           (list->s16vector '(218 230 272 240 252 218 182 194 161 202 218))
                           (list->s16vector '(152 192 192 218 258 235 258 218 192 192 152))
                           texture
                           10 0)
    (GFX:textured-polygon ren
                          (list->s16vector '(72  104 92  52  40 72))
                          (list->s16vector '(272 295 332 332 295 272))
                          texture
                          5 0)
    (GFX:textured-polygon  ren
                           (list->s16vector '(210 215 232 215 210 205 188 205 210))
                           (list->s16vector '(288 303 308 313 329 313 308 303 288))
                           texture
                           5 0)
    )
  ;;(SDL:present-renderer ren)
  )


;; 4й параметр bezier-color (s) определяет гладкость линии от двух и выше
(define (test-bezier-color ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:bezier-color ren
                      (list->s16vector '(10 20 60 100))
                      (list->s16vector '(50 20 20 50))
                      2
                      (make-color 255 0 0 255))
    (GFX:bezier-color  ren
                      (list->s16vector '(110 130 170 250))
                      (list->s16vector '(50  20   70 50))
                      2
                      (make-color 255 0 0 255))
    (GFX:bezier-color ren
                      (list->s16vector '(10  30  70  100))
                      (list->s16vector '(150 120 120 150))
                      2
                      (make-color 255 0 0 255))
    (GFX:bezier-color  ren
                      (list->s16vector '(110 140 180 250))
                      (list->s16vector '(150 130 170 150))
                      2
                      (make-color 255 0 0 255))
    (GFX:bezier-color ren
                      (list->s16vector '(10  50  90  100))
                      (list->s16vector '(250 210 215 250))
                      4
                      (make-color 255 0 0 255))
    (GFX:bezier-color  ren
                      (list->s16vector '(110 120 180 200  250))
                      (list->s16vector '(250 220 350 100  250))
                      4
                      (make-color 255 0 0 255))
    )
  (SDL:present-renderer ren))

(define (test-bezier-rgba ren)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    (GFX:bezier-rgba ren
                      (list->s16vector '(10 20 60 100))
                      (list->s16vector '(50 20 20 50))
                      2
                      255 0 0 255)
    (GFX:bezier-rgba  ren
                      (list->s16vector '(110 130 170 250))
                      (list->s16vector '(50  20   70 50))
                      2
                      255 0 255 255)
    (GFX:bezier-rgba ren
                      (list->s16vector '(10  30  70  100))
                      (list->s16vector '(150 120 120 150))
                      2
                      0 255 255 255)
    (GFX:bezier-rgba  ren
                      (list->s16vector '(110 140 180 250))
                      (list->s16vector '(150 130 170 150))
                      2
                      255 0 0 255)
    (GFX:bezier-rgba ren
                      (list->s16vector '(10  50  90  100))
                      (list->s16vector '(250 210 215 250))
                      4
                      255 255 0 255)
    (GFX:bezier-rgba  ren
                      (list->s16vector '(110 120 180 200  250))
                      (list->s16vector '(250 220 350 100  250))
                      4
                      0 0 255 255)
    )
  (SDL:present-renderer ren))

;;английские буквы рисует шрифтом по умолчанию, русских символов там нет
;; я посмотрел исходный код сделать можно, но не охота, моноширинный шрифт
;; не очень хорошо, попробуем посмотреть что даст TTF
(define (test-character-color ren int-ch)
  (SDL:set-render-draw-color ren 125 125 125 255)
  (SDL:clear-renderer ren)
  (begin
    ;;(GFX:character-color ren 10 50 (char->integer #\Я)
    ;;                  (make-color 255 0 0 255))
    (GFX:character-color ren 10 50 int-ch
                      (make-color 255 0 0 255))
    )
  (SDL:present-renderer ren))


(define tst-list
  `(
    (,test-pixel-rgba         "test-pixel-rgba")
    ;;(,test-textured-polygon   "test-textured-polygon")
    (,test-pixel-color        "test-pixel-color")
    (,test-hline-rgba         "test-hline-rgba")
    (,test-hline-color        "test-hline-color")
    (,test-vline-color        "test-vline-color")
    (,test-vline-rgba         "test-vline-rgba")
    (,test-rectangle          "test-rectangle")
    (,test-box                "test-box")
    (,test-line               "test-line")
    (,test-line2              "test-line2")
    (,test-line3              "test-line3")
    (,test-aaline-rgba        "test-aaline-rgba")
    (,test-aaline-color       "test-aaline-color")
    (,test-thick-line-color   "test-thick-line-color")
    (,test-thick-line-rgba    "test-thick-line-rgba")
    (,test-circle             "test-circle")
    (,test-ellipse            "test-ellipse")
    (,test-pie                "test-pie")
    (,test-trigon             "test-trigon")
    (,test-polygon            "test-polygon")
    (,test-textured-polygon   "test-textured-polygon")
    (,test-bezier-color       "test-bezier-color")
    (,test-bezier-rgba        "test-bezier-rgba")
    (,(lambda (ren) (test-character-color ren 139))  "test-character-color")
    ))

(main tst-list)
