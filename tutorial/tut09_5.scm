#!/usr/bin/guile -s
!#

(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")
(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:)
             ((sdl2 events) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
(use-modules ((gl)   #:prefix GL:))
(use-modules ((glu)   #:prefix GLU:))
(use-modules ((gl enums) #:prefix GL-ENUM:))
(use-modules ((srfi srfi-1)))
(use-modules (srfi srfi-9))

;;define path to my_addom modules
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки
(use-modules ((my_addon) #:prefix mySDL:))




(define-record-type <win-data>
  (make-win-data win id w h ctx)
  win-data?
  (win win-data-win win-data-win-set!)
  (id  win-data-id  win-data-id-set!)
  (w   win-data-w   win-data-w-set!)
  (h   win-data-h   win-data-h-set!)
  (ctx win-data-ctx win-data-ctx-set!)
  )

(define (eq-by-win-id? id win-d)
  (if (eq? id (win-data-id win-d))
      win-d
      #f))


(define (change-size base-xy base-z  w h)
  (let ([loc-h h])
    (when (eq? 0 loc-h)  ;;don't divide 0!
          (set! loc-h 1))
    (GL:gl-viewport 0 0 w loc-h)
    (GL:set-gl-matrix-mode (GL-ENUM:matrix-mode  projection))
    (GL:gl-load-identity)
    (let ([aspect-ratio (/ w loc-h)])
      (if (< w loc-h)
          (GL:gl-ortho (- base-xy) base-xy
                       (/ (- base-xy) aspect-ratio) (/ base-xy aspect-ratio)
                       base-z (- base-z))
          (GL:gl-ortho (* (- base-xy) aspect-ratio) (* base-xy aspect-ratio)
                       (- base-xy) base-xy
                       base-z (- base-z))
      ))
    (GL:set-gl-matrix-mode (GL-ENUM:matrix-mode  modelview))
    (GL:gl-load-identity)))


(begin
  (SDL:sdl-init '(video))
  (define win_w 300)
  (define win_h 400)
  (define base-xy 2.0)
  (define base-z  1.0)
  (define wins '())
  ;;OpenGL attribute
  (SDL:set-gl-attribute! 'double-buffer 1)
  (SDL:set-gl-attribute! 'red-size 5)
  (SDL:set-gl-attribute! 'green-size 6)
  (SDL:set-gl-attribute! 'blue-size 5)
  (let* ([win (SDL:make-window #:size (list win_w win_h)
                               #:title "Win1 OpenGL SDL2"
                               #:position (list 10 10)
                               #:resizable? #t
                               #:opengl? #t
                               #:show? #t)]
         [context (SDL:make-gl-context win)]
         [id      (SDL:window-id win)])
    (mySDL:gl-make-current win context)
    (GL:set-gl-clear-color 0.0 0.0 0.0 1.0)
    (change-size base-xy base-z win_w win_h)
    (set! wins (append wins  (list (make-win-data win id win_w win_h context)))))
  (let* ([win (SDL:make-window #:size (list win_w win_h)
                               #:title "Win2 OpenGL SDL2"
                               #:position (list 320 10)
                               #:resizable? #t
                               #:opengl? #t
                               #:show? #t)]
         [context (SDL:make-gl-context win)]
         [id      (SDL:window-id win)])
    (mySDL:gl-make-current win context)
    (GL:set-gl-clear-color 0.0 0.0 0.0 1.0)
    (change-size base-xy base-z win_w win_h)
    (set! wins (append wins  (list (make-win-data win id win_w win_h context)))))
)

;;(mySDL:gl-make-current win context)

(define (draw-triangle rf)
  (GL:gl-clear (GL-ENUM:clear-buffer-mask color-buffer))
  ;; (GL:gl-load-identity)
  (GL:with-gl-push-matrix
   (GL:gl-translate 0.0 0.0 -0.2)

   ;;(GL:gl-rotate rf 1.0 0.0 0.0)
   ;;(GL:gl-rotate rf 0.0 1.0 0.0)
   (GL:gl-rotate rf 0.0 0.0 1.0)

   (GL:gl-begin (GL-ENUM:begin-mode  triangles)
                (GL:gl-color 1.0 0 0)
                (GL:gl-vertex 0.0 1.0 0.0)
                (GL:gl-color 0 1.0 0)
                ;;(GL:gl-vertex 1.0 -1.0 0.0)
                (GL:gl-vertex 0.866 -0.5 0.0)
                (GL:gl-color 0  0  1.0)
                ;;(GL:gl-vertex -1.0  -1.0 0.0))
                (GL:gl-vertex  -0.866  -0.5 0.0))
  ))

(define (draw-quads rf)
  (GL:gl-clear (GL-ENUM:clear-buffer-mask color-buffer))
  ;; (GL:gl-load-identity)
  (GL:with-gl-push-matrix
   (GL:gl-translate 0.0 0.0 -0.2)
                     
   ;;(GL:gl-rotate rf 1.0 0.0 0.0)
   ;;(GL:gl-rotate rf 0.0 1.0 0.0)
   (GL:gl-rotate rf 0.0 0.0 1.0)
  
   (GL:gl-begin (GL-ENUM:begin-mode  quads)
                (GL:gl-color 1.0 0 0)
                (GL:gl-vertex 1.0 1.0 0.0)
                (GL:gl-color 0 1.0 0)
                (GL:gl-vertex -1.0 1.0 0.0)
                (GL:gl-color 0  0  1.0)
                (GL:gl-vertex  -1.0  -1.0 0.0)
                (GL:gl-color 0  0  0.0 0.0)
                (GL:gl-vertex  1.0  -1.0 0.0))
  ))


(define (move-cycle2 wins)
  (let ([zrf 0.0])
    (while #t
     (let ([event (SDL:poll-event)])
       (when event
          (cond
           [(SDL:quit-event? event)
            (display "bye!\n")
            (break)]
           [(SDL:keyboard-down-event? event)
            (display "Key: ")    (display (SDL:keyboard-event-key event))
            (display ", Scan: ") (display (SDL:keyboard-event-scancode event))
            (newline)
            (let ([k (SDL:keyboard-event-scancode event)])
              (cond
               [(eq?  k 'escape) (display "Escape - bye!\n") (break)                ]
               [(eq?  k 'up)     (display "rotate -X\n")    ]
               [(eq?  k 'down)   (display "rotate +X\n")    ]
               [(eq?  k 'left)   (display "rotate -Y\n")    ]
               [(eq?  k 'right)  (display "rotate +Y\n")    ]
               [(eq?  k 'q)      (display "rotate -Z\n")    ]
               [(eq?  k 'a)      (display "rotate +Z\n")    ])
              )
          
            ]
           [(SDL:window-resized-event? event)
            (let ([size    (SDL:window-event-vector    event)]
                  [win-id  (SDL:window-event-window-id event)])
              (let ([new_w (car size) ]
                    [new_h (cadr size)]
                    [win-d (find (lambda (t) (eq-by-win-id? win-id t))  wins)])
                (if (win-data? win-d)
                    (begin
                      (win-data-w-set! win-d new_w)
                      (win-data-h-set! win-d new_h)
                      (mySDL:gl-make-current (win-data-win win-d) (win-data-ctx win-d))
                      (change-size base-xy base-z new_w new_h)
                      )
                    (format #t "Unknown message from: ~d~%" win-id)))
              )
            ]

           )
          ))
     ;;(mySDL:sdl-delay 30)
     (usleep 30000)
     (set! zrf (floor-remainder (+ zrf 5.0) 360.0))
     (draw-wins wins zrf)

     )))

(define (draw-wins wins zrf)
  (let ([w1 (car  wins)]
        [w2 (cadr wins)])
    (mySDL:gl-make-current (win-data-win w1) (win-data-ctx w1))
    (draw-triangle zrf)
    (SDL:swap-gl-window (win-data-win w1))
    (mySDL:gl-make-current (win-data-win w2) (win-data-ctx w2))
    (draw-quads zrf)
    (SDL:swap-gl-window (win-data-win w2))))
    
  

  
;;start position
(draw-wins wins 0.0)
;;(mySDL:sdl-delay 3000)
(sleep 3)

(move-cycle2 wins)
