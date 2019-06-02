;;; guile-sdl2 --- FFI bindings for SDL2
;;; Code:

(define-module (my_addon)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)
  #:use-module (srfi srfi-9)
  #:use-module (sdl2)
  #:use-module (sdl2 render)
  #:use-module (sdl2 video)
  #:use-module (sdl2 surface)
  #:use-module ((sdl2 bindings) #:prefix ffi:)
  #:export (make-rect
            free-rect
            rect-x
            rect-y
            rect-h
            rect-w
            rect-x-set!
            rect-y-set!
            rect-h-set!
            rect-w-set!
            set-render-draw-color
            render-fill-rect
            render-copy
            render-copy-ex
            get-render-draw-color
            render-set-logical-size
            render-get-logical-size
            get-render-output-size
            sdl-delay
            get-num-video-displays
            get-display-bounds
            get-display-usable-bounds
            get-window-surface
            set-color-key
            gl-make-current
            gl-get-drawable-size
            destroy-texture
            ))

(define sdl-set-render-draw-color
  ( (@@ (sdl2 bindings) sdl-func)
   int "SDL_SetRenderDrawColor" (list '* uint8 uint8 uint8 uint8)))

(define (set-render-draw-color ren r g b a)
  (if (renderer? ren)
      (sdl-set-render-draw-color ((@@ (sdl2 render) unwrap-renderer) ren) r g b a)
      (sdl-error "set-render-draw-color" "bad render type")))

(define sdl-render-set-logical-size
  ( (@@ (sdl2 bindings) sdl-func)
   int "SDL_RenderSetLogicalSize" (list '* int int)))

(define (render-set-logical-size ren x y)
  (if (renderer? ren)
      (sdl-render-set-logical-size ((@@ (sdl2 render) unwrap-renderer) ren) x y)
      (sdl-error "render-set-logical-size" "bad render type")))


;;функция для получения данных из SDL конкретно получет 2 значения типа int
;;передавая Си функции указатели на заранее выделенные места, с помощью bytevector
(define (%get-coords-ren ren proc)
  (let ((bv (make-bytevector (* 2 (sizeof int)) 0)))
    ;;(display proc) (newline)
    (proc ((@@ (sdl2 render) unwrap-renderer) ren)
          (bytevector->pointer bv)
          (bytevector->pointer bv (sizeof int)))
    ;;(display (bytevector->pointer bv))(newline)
    ;;(display (bytevector->pointer bv (sizeof int)))(newline)
    ;;(display bv)(newline)
    (bytevector->sint-list bv (native-endianness) (sizeof int))))

;;void SDL_RenderGetLogicalSize(SDL_Renderer * renderer, int *w, int *h)
(define sdl-render-get-logical-size
  ( (@@ (sdl2 bindings) sdl-func)
  ;;( sdl-func
   void "SDL_RenderGetLogicalSize" (list '* '* '*)))

(define (render-get-logical-size ren)
  (if (renderer? ren)
      (%get-coords-ren ren sdl-render-get-logical-size)
      (sdl-error "render-get-logical-size" "bad render type")))

;;int SDL_GetRendererOutputSize(SDL_Renderer * renderer, int *w, int *h)
(define sdl-get-render-output-size
  ( (@@ (sdl2 bindings) sdl-func)
  ;;( sdl-func
   void "SDL_GetRendererOutputSize" (list '* '* '*)))

(define (get-render-output-size ren)
  (if (renderer? ren)
      (%get-coords-ren ren sdl-get-render-output-size)
      (sdl-error "get-render-output-size" "bad render type")))


;;SDL_GetRenderDrawColor
;;функция для получения данных из SDL конкретно получет 4 значения типа uint8
;;передавая Си функции указатели на заранее выделенные места, с помощью bytevector
(define (%get-color-ren ren proc)
  (let ((bv (make-bytevector (* 4 (sizeof uint8)) 0)))
    (proc ((@@ (sdl2 render) unwrap-renderer) ren)
          (bytevector->pointer bv)
          (bytevector->pointer bv (sizeof uint8))
          (bytevector->pointer bv (* 2 (sizeof uint8)))
          (bytevector->pointer bv (* 3 (sizeof uint8))))
    ;;(display bv)(newline)
    (bytevector->u8-list bv)))

(define sdl-get-render-draw-color
  ( (@@ (sdl2 bindings) sdl-func)
   void "SDL_GetRenderDrawColor" (list '* '* '* '* '*)))

(define (get-render-draw-color ren)
  (if (renderer? ren)
      (%get-color-ren ren sdl-get-render-draw-color)
      (sdl-error "get-render-draw-color" "bad render type")))

(define sdl-delay
  ( (@@ (sdl2 bindings) sdl-func)
    void "SDL_Delay" (list uint32)))

;;(eval-when (compile load)
;;    (define lib-path (@@ (guile-user) lib-path)))

(define my-addon-func
  (let ((lib (dynamic-link "my_addon_c.so")))
    (lambda (return-type function-name arg-types)
      "Return a procedure for the foreign function FUNCTION-NAME in
the MY shared library.  That function must return a value of
RETURN-TYPE and accept arguments of ARG-TYPES."
      (pointer->procedure return-type
                          (dynamic-func function-name lib)
                          arg-types))))

(define-wrapped-pointer-type <rect>
  rect?
  wrap-rect unwrap-rect
  (lambda (r port)
    (format port "#<rect ~x>: x:~d, y:~d, w:~d, h:~d"
            (pointer-address (unwrap-rect r))
            (rect-x r) (rect-y r)
            (rect-w r) (rect-h r))))

(define make-rect
  (let ([f  (my-addon-func
             '* "make_rect" (list int int int int))])
    (lambda (x y w h)
      ;;здесь можно проверить параметры
      (wrap-rect (f x y w h)))))


;;после применения rect использовать нельзя, т.к он ссылается на освобожденную
;;область памяти
(define free-rect
  (let ([f  (my-addon-func
             void "free_rect" (list '*))])
    (lambda (r)
      (if (rect? r)
          (f (unwrap-rect r))
          (sdl-error "free-rect" "free not rect pointer!\n")))))

(define rect-x
  (let ([f  (my-addon-func
             int "rect_get_x" (list '*))])
    (lambda (r)
      (if (rect? r)
          (f (unwrap-rect r))
          (sdl-error "rect-x" "Error: is not pointer!" r)))))

(define rect-y
  (let ([f (my-addon-func
            int "rect_get_y" (list '*))])
    (lambda (r)
      (if (rect? r)
          (f (unwrap-rect r))
          (sdl-error "rect-y" "Error: is not pointer!" r)))))
    

(define rect-w
  (let ([f  (my-addon-func
             int "rect_get_w" (list '*))])
    (lambda (r)
      (if (rect? r)
          (f (unwrap-rect r))
          (sdl-error "rect-w" "Error: is not pointer!" r)))))


(define rect-h
  (let ([f  (my-addon-func
             int "rect_get_h" (list '*))])
    (lambda (r)
      (if (rect? r)
          (f (unwrap-rect r))
          (sdl-error "rect-h" "Error: ~a is not pointer!" r)))))
    

(define rect-x-set!
  (let ([f  (my-addon-func
             void "rect_set_x" (list '* int))])
    (lambda (r val)
      (if (rect? r)
          (f (unwrap-rect r) val)
          (sdl-error "rect-x-set!" "Error:  is not pointer!" r)))))
    

(define rect-y-set!
  (let ([f  (my-addon-func
             void "rect_set_y" (list '* int))])
    (lambda (r val)
      (if (rect? r)
          (f (unwrap-rect r) val)
          (sdl-error "rect-y-set!" "Error: is not pointer!" r)))))
    

(define rect-h-set!
  (let ([f  (my-addon-func
             void "rect_set_h" (list '* int))])
    (lambda (r val)
      (if (rect? r)
          (f (unwrap-rect r) val)
          (sdl-error "rect-h-set!" "Error:  is not pointer!" r)))))
    
(define rect-w-set!
  (let ([f  (my-addon-func
             void "rect_set_w" (list '* int))])
    (lambda (r val)
      (if (rect? r)
          (f (unwrap-rect r) val)
          (sdl-error "rect-w-set!" "Error: is not pointer!" r)))))
    

;;int SDL_RenderFillRect(SDL_Renderer * renderer, const SDL_Rect * rect)
(define sdl-render-fill-rect
  ( (@@ (sdl2 bindings) sdl-func)
  ;;( sdl-func
   int "SDL_RenderFillRect" (list '* '*)))

(define (render-fill-rect ren rect)
  (if (and (renderer? ren) (rect? rect))
      (sdl-render-fill-rect ((@@ (sdl2 render) unwrap-renderer) ren)
                                   (unwrap-rect rect))
      (sdl-error "render-fill-rect" "bad render type")))

;;SDL_render.h
;; int SDLCALL SDL_RenderCopy(SDL_Renderer * renderer,
;;                                           SDL_Texture * texture,
;;                                           const SDL_Rect * srcrect,
;;                                           const SDL_Rect * dstrect);
;; это определение должно быть уже в ffi:
;;(define sdl-render-copy
;;  ( (@@ (sdl2 bindings) sdl-func)
;;  ;;( sdl-func
;;   int "SDL_RenderCopy" (list '* '* '* '*)))

(define* (render-copy renderer texture #:key srcrect dstrect)
  "Copy TEXTURE to the rendering target of RENDERER."
  (let ((result (ffi:sdl-render-copy ((@@ (sdl2 render) unwrap-renderer) renderer)
                                     ((@@ (sdl2 render) unwrap-texture)  texture)
                                     (if (rect? srcrect)
                                         (unwrap-rect srcrect)
                                         %null-pointer)
                                     (if (rect? dstrect)
                                         (unwrap-rect dstrect)
                                         %null-pointer))))
    (unless (zero? result)
      (sdl-error "render-copy" "failed to copy texture"))))

;; int SDLCALL SDL_RenderCopyEx(SDL_Renderer * renderer,
;;                                           SDL_Texture * texture,
;;                                           const SDL_Rect * srcrect,
;;                                           const SDL_Rect * dstrect,
;;                                           const double angle,
;;                                           const SDL_Point *center,
;;                                           const SDL_RendererFlip flip);
(define-public SDL_FLIP_NONE          #x00000000)     ;;/**< Do not flip */
(define-public SDL_FLIP_HORIZONTAL    #x00000001)     ;;/**< flip horizontally */
(define-public SDL_FLIP_VERTICAL      #x00000002)     ;;/**< flip vertically */

(define sdl-render-copy-ex
  ( (@@ (sdl2 bindings) sdl-func)
   int "SDL_RenderCopyEx" (list '* '* '* '* double '* uint32)))

(define* (render-copy-ex renderer texture #:key srcrect dstrect angle center flip)
  "Copy TEXTURE to the rendering target of RENDERER."
  (let ((result (sdl-render-copy-ex ((@@ (sdl2 render) unwrap-renderer) renderer)
                                    ((@@ (sdl2 render) unwrap-texture)  texture)
                                     (if (rect? srcrect)
                                         (unwrap-rect srcrect)
                                         %null-pointer)
                                     (if (rect? dstrect)
                                         (unwrap-rect dstrect)
                                         %null-pointer)
                                     (if (number? angle)
                                         angle
                                         0)
                                     (if (rect? center)
                                         (unwrap-rect dstrect)
                                         %null-pointer)
                                     (if (number? flip)
                                         flip
                                         SDL_FLIP_NONE)
                                        )))
    (unless (zero? result)
      (sdl-error "render-copy-ex" "failed to copy texture"))))



;;int SDL_GetNumVideoDisplays()
(define get-num-video-displays
  ( (@@ (sdl2 bindings) sdl-func)
    int "SDL_GetNumVideoDisplays" (list )))

;;int SDL_GetDisplayBounds(int a, SDL_Rect *b)
(define sdl-get-display-bounds
  ( (@@ (sdl2 bindings) sdl-func)
    int "SDL_GetDisplayBounds" (list int '*)))

(define (get-display-bounds id-disp)
  (let ([rect (make-rect -1 -1 -1 -1)])
    (sdl-get-display-bounds id-disp
                            (unwrap-rect rect))
    (list (rect-x rect) (rect-y rect) (rect-w rect) (rect-h rect))))

;;int SDL_GetDisplayUsableBounds(int a, SDL_Rect *b)
(define sdl-get-display-usable-bounds
  ( (@@ (sdl2 bindings) sdl-func)
    int "SDL_GetDisplayUsableBounds" (list int '*)))

(define (get-display-usable-bounds id-disp)
  (let ([rect (make-rect -1 -1 -1 -1)])
    (sdl-get-display-usable-bounds id-disp
                            (unwrap-rect rect))
    (list (rect-x rect) (rect-y rect) (rect-w rect) (rect-h rect))))

;;SDL_video.h
;;SDL_Surface * SDLCALL SDL_GetWindowSurface(SDL_Window * window);
(define sdl-get-window-surface
  ( (@@ (sdl2 bindings) sdl-func)
    '* "SDL_GetWindowSurface" (list '*)))

(define (get-window-surface win)
  (if (window? win)
      ((@@ (sdl2 surface) wrap-surface)
       (sdl-get-window-surface
        ((@@ (sdl2 video) unwrap-window) win)))
      (sdl-error "get-window-surface" "bad window type")
      ))

;;SDL_surface.h
;;int SDLCALL SDL_SetColorKey(SDL_Surface * surface,
;;                                          int flag, Uint32 key);
(define sdl-set-color-key
  ( (@@ (sdl2 bindings) sdl-func)
    int "SDL_SetColorKey" (list '* int uint32)))

(define (set-color-key surface flag key)
  (if (surface? surface)
      (sdl-set-color-key
       ((@@ (sdl2 surface) unwrap-surface) surface) flag key)
      (sdl-error "set-color-key" "bad surface type")
      ))

;;/video/SDL_video.c
;;   SDL_GL_MakeCurrent(state->windows[i], context);
;;int SDL_GL_MakeCurrent(SDL_Window * window, SDL_GLContext ctx)
(define sdl-gl-make-current
  ( (@@ (sdl2 bindings) sdl-func)
    int "SDL_GL_MakeCurrent" (list '* '*)))

(define (gl-make-current win context)
  (if (and (window? win) (gl-context? context))
      (sdl-gl-make-current ((@@ (sdl2 video) unwrap-window) win)
                           ((@@ (sdl2 video) unwrap-gl-context) context))
      (sdl-error "render-fill-rect" "bad render type")))



;;/video/SDL_video.c
;;   SDL_GL_GetDrawableSize(state->windows[i], &w, &h);
;;void SDL_GL_GetDrawableSize(SDL_Window * window, int *w, int *h)
(define sdl-gl-get-drawable-size
  ( (@@ (sdl2 bindings) sdl-func)
    void "SDL_GL_GetDrawableSize" (list '* '* '*)))

;;функция для получения данных из SDL конкретно получет 2 значения типа int
;;передавая Си функции указатели на заранее выделенные места, с помощью bytevector
(define (%get-coords-win win proc)
  (let ((bv (make-bytevector (* 2 (sizeof int)) 0)))
    ;;(display proc) (newline)
    (proc ((@@ (sdl2 video) unwrap-window) win)
          (bytevector->pointer bv)
          (bytevector->pointer bv (sizeof int)))
    (bytevector->sint-list bv (native-endianness) (sizeof int))))

(define (gl-get-drawable-size win)
  (if (window? win)
      (%get-coords-win win sdl-gl-get-drawable-size)
      (sdl-error "gl-get-drawable-size" "bad render type")))


;;void SDLCALL SDL_DestroyTexture(SDL_Texture * texture);
(define sdl-destroy-texture
  ( (@@ (sdl2 bindings) sdl-func)
   void "SDL_DestroyTexture" (list '*)))

(define (destroy-texture tex)
  (if ((@@ (sdl2 render) texture?) tex)
      (sdl-destroy-texture ((@@ (sdl2 render) unwrap-texture) tex))
      (sdl-error "sdl-destroy-texture" "bad texture type")))

