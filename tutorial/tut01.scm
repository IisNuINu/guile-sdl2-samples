#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")

(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
(eval-when (compile load)
    (load "my_config.scm")
    (setenv "LTDL_LIBRARY_PATH" lib-path))  ;;для поиска разделяемой библиотеки
(use-modules ((my_addon) #:prefix mySDL:))

  
(define (hello-sdl)
  (catch 'sdl-error
         (lambda ()
           (SDL:sdl-init '(video))
           (display "SDL version: ") (display (SDL:sdl-version)) (newline)
           (let* ((posX 100) (posY 200)
                  (sizeX 300)  (sizeY 400)
                  (posXn 200) (posYn 20)
                  (sizeXn 250) (sizeYn 300)
                  (win (SDL:make-window #:size (list sizeX sizeY) #:title "Server"
                                       #:position (list posX posY)
                                       )))
             (let ((ren (SDL:make-renderer win '(accelerated)))) ;;default '(accelerated vsync)
               (display "Render draw color:") (display (mySDL:get-render-draw-color ren)) (newline)
               (SDL:clear-renderer ren)
               (SDL:present-renderer ren)  ;;show

               (format #t "Window ID: ~d~%" (SDL:window-id win))
               (display "Size window: ") (display (SDL:window-size win)) (newline)
               (display "Logical Size render: ") (display (mySDL:render-get-logical-size ren)) (newline)
               (sleep 5)
               
               (format #t "Set Logical Size w:~d h:~d~%" sizeXn sizeYn) 
               (mySDL:render-set-logical-size ren sizeXn sizeYn)
               (display "New Size window: ") (display (SDL:window-size win)) (newline)
               (display "New Logical Size render: ") (display (mySDL:render-get-logical-size ren)) (newline)
               (display "Output Size render: ") (display (mySDL:get-render-output-size ren)) (newline)

               (SDL:set-window-position! win  (list posXn posYn))
               (sleep 5)

               (SDL:set-window-size! win  (list sizeXn sizeYn))

               (display "New Pos  window: ") (display (SDL:window-position win)) (newline)
               (display "New Size window: ") (display (SDL:window-size     win)) (newline)
               (display "New Size render: ") (display (mySDL:render-get-logical-size ren)) (newline)

               (display "Output Size render: ") (display (mySDL:get-render-output-size ren)) (newline)

               (SDL:set-render-draw-color ren 255 0 0 255)
               (SDL:clear-renderer ren)
               (SDL:present-renderer ren)  ;;show
               (sleep 5)
               ;;(SDL:sdl-delay 5000)

               (display "New Render draw color:") (display (mySDL:get-render-draw-color ren)) (newline)
               )))
             (lambda (key .  args)
               (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
  (SDL:sdl-quit)
)
(hello-sdl)

