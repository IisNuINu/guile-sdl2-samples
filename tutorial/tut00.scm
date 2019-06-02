#!/usr/bin/guile -s
!#
;;Руссификация вывода для кодировки utf-8
(define stdout (current-output-port))
(set-port-encoding! stdout "utf-8")


;;(add-to-load-path (dirname (current-filename)))
;;(add-to-load-path "./")
;;(display %load-path)
(use-modules ((sdl2) #:prefix SDL:)
             ((sdl2 render) #:prefix SDL:)
             ;;((sdl2 surface) #:prefix SDL:)
             ((sdl2 video) #:prefix SDL:))
(use-modules ((sdl2 bindings) #:prefix ffi:))
;;(use-modules ((my_addon) #:prefix mySDL:))

  
(define (hello-sdl)
  (catch 'sdl-error
         (lambda ()
           (SDL:sdl-init '(video))
           (let ((win (SDL:make-window #:size '(300 350) #:title "Chapter 1: Setting up SDL!"
                                       #:position (list ffi:SDL_WINDOWPOS_CENTERED
                                                        ffi:SDL_WINDOWPOS_CENTERED)
                                       #:show? #t)))
             (let ((ren (SDL:make-renderer win)))
               (SDL:set-render-draw-color ren 255 0 0 255)
               ;;(mySDL:render-draw-color ren 255 0 0 255)
               (SDL:clear-renderer ren)
               (SDL:present-renderer ren)  ;;show
               ;;(mySDL:sdl-delay 5000)
               (sleep 5)
               )))
             (lambda (key .  args)
               (format #t "Have exception '~a' witch detail info: ~{ ~A ~}~%" key args))
           )
  (SDL:sdl-quit)
  (display "End of SDL!\n")
  (sleep 5)
)
(hello-sdl)

