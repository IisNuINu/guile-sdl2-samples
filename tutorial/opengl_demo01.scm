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
  (GL:set-gl-clear-color 1.0 1.0 1.0 1.0)
  (GL:set-gl-clear-depth 1.0)
  (GL:set-gl-depth-function (GL-ENUM:depth-function less))
  (GL:gl-enable (GL-ENUM:enable-cap depth-test))
  (GL:set-gl-shade-model (GL-ENUM:shading-model smooth))
  (GL:set-gl-matrix-mode (GL-ENUM:matrix-mode  projection))
  (GL:gl-load-identity)
  (GLU:glu-perspective 45.0 (/ win_w win_h) 0.1 100.0)
  (GL:set-gl-matrix-mode (GL-ENUM:matrix-mode  modelview))
)

;;(mySDL:gl-make-current win context)

(define (draw-cube xrf yrf zrf)
  (GL:gl-clear (GL-ENUM:clear-buffer-mask color-buffer depth-buffer))
  (GL:gl-load-identity)
  (GL:gl-translate 0.0 0.0 -7.0)

  (GL:gl-rotate xrf 1.0 0.0 0.0)
  (GL:gl-rotate yrf 0.0 1.0 0.0)
  (GL:gl-rotate zrf 0.0 0.0 1.0)

  (GL:gl-begin (GL-ENUM:begin-mode  quads)
               
               (GL:gl-color   0.0  1.0  0.0)
               (GL:gl-vertex  1.0  1.0 -1.0)
               (GL:gl-vertex -1.0  1.0 -1.0)
               (GL:gl-vertex -1.0  1.0  1.0)
               (GL:gl-vertex  1.0  1.0  1.0)

               (GL:gl-color   1.0  0.5  0.0)
               (GL:gl-vertex  1.0 -1.0  1.0)
               (GL:gl-vertex -1.0 -1.0  1.0)
               (GL:gl-vertex -1.0 -1.0 -1.0)
               (GL:gl-vertex  1.0 -1.0 -1.0)

               (GL:gl-color   1.0  0.0  0.0)
               (GL:gl-vertex  1.0  1.0  1.0)
               (GL:gl-vertex -1.0  1.0  1.0)
               (GL:gl-vertex -1.0 -1.0  1.0)
               (GL:gl-vertex  1.0 -1.0  1.0)

               (GL:gl-color   1.0  1.0  0.0)
               (GL:gl-vertex  1.0 -1.0 -1.0)
               (GL:gl-vertex -1.0 -1.0 -1.0)
               (GL:gl-vertex -1.0  1.0 -1.0)
               (GL:gl-vertex  1.0  1.0 -1.0)

               (GL:gl-color   0.0  0.0  1.0)
               (GL:gl-vertex -1.0  1.0  1.0)
               (GL:gl-vertex -1.0  1.0 -1.0)
               (GL:gl-vertex -1.0 -1.0 -1.0)
               (GL:gl-vertex -1.0 -1.0  1.0)

               (GL:gl-color   1.0  0.0  1.0)
               (GL:gl-vertex  1.0  1.0 -1.0)
               (GL:gl-vertex  1.0  1.0  1.0)
               (GL:gl-vertex  1.0 -1.0  1.0)
               (GL:gl-vertex  1.0 -1.0 -1.0)
               ))
  
(define (move-cycle2 win)
  (let ([xrf 0.0] [yrf 0.0] [zrf 0.0])
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
               [(eq?  k 'up)     (display "rotate -X\n")     (set! xrf (- xrf 5.0)) ]
               [(eq?  k 'down)   (display "rotate +X\n")     (set! xrf (+ xrf 5.0)) ]
               [(eq?  k 'left)   (display "rotate -Y\n")     (set! yrf (- yrf 5.0)) ]
               [(eq?  k 'right)  (display "rotate +Y\n")     (set! yrf (+ yrf 5.0)) ]
               [(eq?  k 'q)      (display "rotate -Z\n")     (set! zrf (- zrf 5.0)) ]
               [(eq?  k 'a)      (display "rotate +Z\n")     (set! zrf (+ zrf 5.0)) ] )
              (set! xrf (floor-remainder xrf 360.0))
              (set! yrf (floor-remainder yrf 360.0))
              (set! zrf (floor-remainder zrf 360.0)))
          
            (draw-cube xrf yrf zrf)
            (SDL:swap-gl-window win)]
           )
          )))))

;;start position
(draw-cube 0.0 0.0 0.0)
(SDL:swap-gl-window win)

(move-cycle2 win)
