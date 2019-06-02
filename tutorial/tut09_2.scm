#!/usr/bin/guile -s
!#

(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


(define base-path "/home/bear/work/guile/sdl2/")


(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:)
             ((sdl2 events) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
(use-modules ((gl)   #:prefix GL:))
(use-modules ((glu)   #:prefix GLU:))
(use-modules ((gl enums) #:prefix GL-ENUM:))


(begin
  (SDL:sdl-init '(video))
  (define win_w 640)
  (define win_h 480)
  (define win (SDL:make-window #:size (list win_w win_h)
                               #:title "Testing OpenGL SDL2"
                               #:position (list 10 10)
                               #:opengl? #t
                               #:show? #t))
  ;;OpenGL attribute
  (SDL:set-gl-attribute! 'double-buffer 1)
  (SDL:set-gl-attribute! 'red-size 5)
  (SDL:set-gl-attribute! 'green-size 6)
  (SDL:set-gl-attribute! 'blue-size 5)
  (define context (SDL:make-gl-context win))
  ;;init OpenGL
  (GL:gl-viewport 0 0 win_w win_h)
  (GL:gl-frustum -1.0 1.0 -1.0 1.0 1.0 100.0)
  ;;(GL:set-gl-clear-color 1.0 1.0 1.0 1.0)
  (GL:set-gl-clear-color 0.0 0.0 0.0 1.0)
  (GL:set-gl-matrix-mode (GL-ENUM:matrix-mode  modelview))
)

;;(mySDL:gl-make-current win context)

(define (draw-quads rf)
  (GL:gl-clear (GL-ENUM:clear-buffer-mask color-buffer))
  ;; (GL:gl-load-identity)
  (GL:with-gl-push-matrix
   (GL:gl-translate 0.0 0.0 -2.0)

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
  
(define (move-cycle2 win)
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
           )
          ))
     ;;(mySDL:sdl-delay 30)
     (usleep 30000)
     (set! zrf (floor-remainder (+ zrf 5.0) 360.0))
     (draw-quads zrf)
     (SDL:swap-gl-window win)     
     )))

;;start position
(draw-quads 0.0)
(SDL:swap-gl-window win)
;;(mySDL:sdl-delay 3000)
(sleep 3)

(move-cycle2 win)
