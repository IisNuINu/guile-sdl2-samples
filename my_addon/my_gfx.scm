;;; guile-sdl2 --- FFI bindings for SDL2
;;; Code:

(define-module (my_gfx)
  #:use-module (system foreign)
  #:use-module (rnrs bytevectors)
  #:use-module (srfi srfi-9)
  #:use-module (sdl2)
  #:use-module (sdl2 render)
  #:use-module (sdl2 surface)
  #:use-module (sdl2 ttf)
  #:use-module ((sdl2 bindings) #:prefix ffi:)
  #:export (pixel-color
            pixel-rgba
            hline-color
            hline-rgba
            vline-color
            vline-rgba
            rectangle-color
            rectangle-rgba
            rounded-rectangle-color
            rounded-rectangle-rgba
            box-color
            box-rgba
            rounded-box-color
            rounded-box-rgba
            line-color
            line-rgba
            aaline-color
            aaline-rgba
            thick-line-color
            thick-line-rgba
            circle-color
            circle-rgba
            arc-color
            arc-rgba
            aacircle-color
            aacircle-rgba
            filled-circle-color
            filled-circle-rgba
            ellipse-color
            ellipse-rgba
            aaellipse-color
            aaellipse-rgba
            filled-ellipse-color
            filled-ellipse-rgba
            pie-color
            pie-rgba
            filled-pie-color
            filled-pie-rgba
            trigon-color
            trigon-rgba
            aatrigon-color
            aatrigon-rgba
            filled-trigon-color
            filled-trigon-rgba
            polygon-color
            polygon-rgba
            aapolygon-color
            aapolygon-rgba
            filled-polygon-color
            filled-polygon-rgba
            textured-polygon
            bezier-color
            bezier-rgba
            gfx-primitives-set-font
            gfx-primitives-set-font-rotation
            character-color
            character-rgba
            ))


;;(define %libgfx "libSDL2_gfx-1.0")
(define %libgfx "libSDL2_gfx")
(define gfx-func
  (let ((lib (dynamic-link %libgfx)))
    (display "load and link  libgfx\n")
    (lambda (return-type function-name arg-types)
      "Return a procedure for the foreign function FUNCTION-NAME in
the SDL2 shared library.  That function must return a value of
RETURN-TYPE and accept arguments of ARG-TYPES."
      (pointer->procedure return-type
                          (dynamic-func function-name lib)
                          arg-types))))


;;int pixelColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Uint32 color);
(define pixel-color
  (let ([ptr (gfx-func int "pixelColor" (list '* int16 int16 uint32))])
    (display "bind pixelColor\n")
    (lambda (ren x y color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y color)
          (sdl-error "pixel-color" "bad render type")))
    ))
      


;;int pixelRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define pixel-rgba
  (let ([ptr (gfx-func int "pixelRGBA" (list '* int16 int16 uint8  uint8  uint8  uint8))])
    (display "bind pixelRGBA\n")
    (lambda (ren x y r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y r g b a)
          (sdl-error "pixel-rgba" "bad render type")))
    ))

;;int hlineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 x2, Sint16 y, Uint32 color);
(define hline-color
  (let ([ptr (gfx-func int "hlineColor" (list '* int16 int16 int16  uint32))])
    (lambda (ren x1 x2 y color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 x2 y color)
          (sdl-error "hline-color" "bad render type")))
    ))

;;int hlineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 x2,
;;                                       Sint16 y, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define hline-rgba
  (let ([ptr (gfx-func int "hlineRGBA" (list '* int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 x2 y r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 x2 y r g b a)
          (sdl-error "hline-rgba" "bad render type")))
    ))


;;int vlineColor(SDL_Renderer * renderer, Sint16 x, Sint16 y1, Sint16 y2, Uint32 color);
(define vline-color
  (let ([ptr (gfx-func int "vlineColor" (list '* int16 int16 int16  uint32))])
    (lambda (ren x y1 y2 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y1 y2 color)
          (sdl-error "vline-color" "bad render type")))
    ))

;;int vlineRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y1,
;;                                       Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define vline-rgba
  (let ([ptr (gfx-func int "vlineRGBA" (list '* int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x y1 y2 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y1 y2 r g b a)
          (sdl-error "vline-rgba" "bad render type")))
    ))


;;int rectangleColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
(define rectangle-color
  (let ([ptr (gfx-func int "rectangleColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x1 y1 x2 y2 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 color)
          (sdl-error "rectangle-color" "bad render type")))
    ))

;;int rectangleRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                                           Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define rectangle-rgba
  (let ([ptr (gfx-func int "rectangleRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 r g b a)
          (sdl-error "rectangle-rgba" "bad render type")))
    ))


;;int roundedRectangleColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 rad,
(define rounded-rectangle-color
  (let ([ptr (gfx-func int "roundedRectangleColor" (list '* int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x1 y1 x2 y2 rad color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 rad color)
          (sdl-error "rounded-rectangle-color" "bad render type")))
    ))

;;int roundedRectangleRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;               Sint16 x2, Sint16 y2, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define rounded-rectangle-rgba
  (let ([ptr (gfx-func int "roundedRectangleRGBA" (list '* int16 int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 rad r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 rad r g b a)
          (sdl-error "rounded-rectangle-rgba" "bad render type")))
    ))

;;int boxColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
(define box-color
  (let ([ptr (gfx-func int "boxColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x1 y1 x2 y2 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 color)
          (sdl-error "box-color" "bad render type")))
    ))

;;int boxRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2,
;;                Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define box-rgba
  (let ([ptr (gfx-func int "boxRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 r g b a)
          (sdl-error "box-rgba" "bad render type")))
    ))


;;int roundedBoxColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 rad, Uint
(define rounded-box-color
  (let ([ptr (gfx-func int "roundedBoxColor" (list '* int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x1 y1 x2 y2 rad color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 rad color)
          (sdl-error "rounded-box-color" "bad render type")))
    ))

;;int roundedBoxRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2,
;;                Sint16 y2, Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define rounded-box-rgba
  (let ([ptr (gfx-func int "roundedBoxRGBA" (list '* int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 rad r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 rad  r g b a)
          (sdl-error "rounded-box-rgba" "bad render type")))
    ))


;;int lineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
(define line-color
  (let ([ptr (gfx-func int "lineColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x1 y1 x2 y2 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 color)
          (sdl-error "line-color" "bad render type")))
    ))


;;int lineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define line-rgba
  (let ([ptr (gfx-func int "lineRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 r g b a)
          (sdl-error "line-rgba" "bad render type")))
    ))


;;int aalineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Uint32 color);
(define aaline-color
  (let ([ptr (gfx-func int "aalineColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x1 y1 x2 y2 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 color)
          (sdl-error "aaline-color" "bad render type")))
    ))


;;int aalineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                Sint16 x2, Sint16 y2, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define aaline-rgba
  (let ([ptr (gfx-func int "aalineRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 r g b a)
          (sdl-error "aaline-rgba" "bad render type")))
    ))


;;int thickLineColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2,
;;                Uint8 width, Uint32 color);
(define thick-line-color
  (let ([ptr (gfx-func int "thickLineColor" (list '* int16 int16 int16 int16  uint8 uint32))])
    (lambda (ren x1 y1 x2 y2 width color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 width color)
          (sdl-error "thick-line-color" "bad render type")))
    ))


;;int thickLineRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2,
;;                Uint8 width, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define thick-line-rgba
  (let ([ptr (gfx-func int "thickLineRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 width r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 width r g b a)
          (sdl-error "thick-line-rgba" "bad render type")))
    ))

;;int circleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Uint32 color);
(define circle-color
  (let ([ptr (gfx-func int "circleColor" (list '* int16 int16 int16 uint32))])
    (lambda (ren x y rad color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad color)
          (sdl-error "circle-color" "bad render type")))
    ))

;;int circleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define circle-rgba
  (let ([ptr (gfx-func int "circleRGBA" (list '* int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad r g b a)
          (sdl-error "circle-rgba" "bad render type")))
    ))

;;int arcColor(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rad, Sint16 start, Sint16 end, Uint32 color);
(define arc-color
  (let ([ptr (gfx-func int "arcColor" (list '* int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x y rad start end color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad start end color)
          (sdl-error "arc-color" "bad render type")))
    ))

;;int arcRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Sint16 start, Sint16 end,
;;                Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define arc-rgba
  (let ([ptr (gfx-func int "arcRGBA" (list '* int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad start end r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad start end r g b a)
          (sdl-error "arc-rgba" "bad render type")))
    ))


;;int aacircleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad, Uint32 color);
(define aacircle-color
  (let ([ptr (gfx-func int "aacircleColor" (list '* int16 int16 int16 uint32))])
    (lambda (ren x y rad color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad color)
          (sdl-error "aacircle-color" "bad render type")))
    ))

;;int aacircleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define aacircle-rgba
  (let ([ptr (gfx-func int "aacircleRGBA" (list '* int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad r g b a)
          (sdl-error "aacircle-rgba" "bad render type")))
    ))


;;int filledCircleColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 r, Uint32 color);
(define filled-circle-color
  (let ([ptr (gfx-func int "filledCircleColor" (list '* int16 int16 int16 uint32))])
    (lambda (ren x y rad color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad color)
          (sdl-error "filled-circle-color" "bad render type")))
    ))

;;int filledCircleRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rad, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define filled-circle-rgba
  (let ([ptr (gfx-func int "filledCircleRGBA" (list '* int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad r g b a)
          (sdl-error "filled-circle-rgba" "bad render type")))
    ))


;;int ellipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
(define ellipse-color
  (let ([ptr (gfx-func int "ellipseColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x y rx ry color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rx ry color)
          (sdl-error "ellipse-color" "bad render type")))
    ))

;;int ellipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define ellipse-rgba
  (let ([ptr (gfx-func int "ellipseRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x y rx ry r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rx ry r g b a)
          (sdl-error "ellipse-rgba" "bad render type")))
    ))

;;int aaellipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
(define aaellipse-color
  (let ([ptr (gfx-func int "aaellipseColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x y rx ry color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rx ry color)
          (sdl-error "aaellipse-color" "bad render type")))
    ))

;;int aaellipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define aaellipse-rgba
  (let ([ptr (gfx-func int "aaellipseRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x y rx ry r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rx ry r g b a)
          (sdl-error "aaellipse-rgba" "bad render type")))
    ))


;;int filledEllipseColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rx, Sint16 ry, Uint32 color);
(define filled-ellipse-color
  (let ([ptr (gfx-func int "filledEllipseColor" (list '* int16 int16 int16 int16  uint32))])
    (lambda (ren x y rx ry color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rx ry color)
          (sdl-error "filled-ellipse-color" "bad render type")))
    ))

;;int filledEllipseRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;                Sint16 rx, Sint16 ry, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define filled-ellipse-rgba
  (let ([ptr (gfx-func int "filledEllipseRGBA" (list '* int16 int16 int16 int16  uint8 uint8 uint8 uint8))])
    (lambda (ren x y rx ry r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rx ry r g b a)
          (sdl-error "filled-ellipse-rgba" "bad render type")))
    ))


;;int pieColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
;;                Sint16 start, Sint16 end, Uint32 color);
(define pie-color
  (let ([ptr (gfx-func int "pieColor" (list '* int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x y rad start end color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad start end color)
          (sdl-error "pie-color" "bad render type")))
    ))

;;int pieRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
;;                Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define pie-rgba
  (let ([ptr (gfx-func int "pieRGBA" (list '* int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad start end r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad start end r g b a)
          (sdl-error "pie-rgba" "bad render type")))
    ))


;;int filledPieColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
;;                Sint16 start, Sint16 end, Uint32 color);
(define filled-pie-color
  (let ([ptr (gfx-func int "filledPieColor" (list '* int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x y rad start end color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y rad start end color)
          (sdl-error "filled-pie-color" "bad render type")))
    ))

;;int filledPieRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, Sint16 rad,
;;                Sint16 start, Sint16 end, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define filled-pie-rgba
  (let ([ptr (gfx-func int "filledPieRGBA" (list '* int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x y rad start end r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x y rad start end r g b a)
          (sdl-error "filled-pie-rgba" "bad render type")))
    ))


;;int trigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                  Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);
(define trigon-color
  (let ([ptr (gfx-func int "trigonColor" (list '* int16 int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x1 y1 x2 y2 x3 y3 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 x3 y3 color)
          (sdl-error "trigon-color" "bad render type")))
    ))

;;int trigonRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1, Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
;; Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define trigon-rgba
  (let ([ptr (gfx-func int "trigonRGBA" (list '* int16 int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 x3 y3 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 x3 y3 r g b a)
          (sdl-error "trigon-rgba" "bad render type")))
    ))


;;int aatrigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                 Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color);
(define aatrigon-color
  (let ([ptr (gfx-func int "aatrigonColor" (list '* int16 int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x1 y1 x2 y2 x3 y3 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 x3 y3 color)
          (sdl-error "aatrigon-color" "bad render type")))
    ))

;;int aatrigonRGBA(SDL_Renderer * renderer,  Sint16 x1, Sint16 y1,
;;                 Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
;;                 Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define aatrigon-rgba
  (let ([ptr (gfx-func int "aatrigonRGBA" (list '* int16 int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 x3 y3 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 x3 y3 r g b a)
          (sdl-error "aatrigon-rgba" "bad render type")))
    ))

;;int filledTrigonColor(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                 Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3, Uint32 color)
(define filled-trigon-color
  (let ([ptr (gfx-func int "filledTrigonColor" (list '* int16 int16 int16 int16 int16 int16 uint32))])
    (lambda (ren x1 y1 x2 y2 x3 y3 color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x1 y1 x2 y2 x3 y3 color)
          (sdl-error "filled-trigon-color" "bad render type")))
    ))


;;int filledTrigonRGBA(SDL_Renderer * renderer, Sint16 x1, Sint16 y1,
;;                 Sint16 x2, Sint16 y2, Sint16 x3, Sint16 y3,
;;                  Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define filled-trigon-rgba
  (let ([ptr (gfx-func int "filledTrigonRGBA" (list '* int16 int16 int16 int16 int16 int16 uint8 uint8 uint8 uint8))])
    (lambda (ren x1 y1 x2 y2 x3 y3 r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren) x1 y1 x2 y2 x3 y3 r g b a)
          (sdl-error "filled-trigon-rgba" "bad render type")))
    ))

;;int polygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
(define polygon-color
  (let ([ptr (gfx-func int "polygonColor" (list '* '* '* int uint32))])
    (lambda (ren vx vy color)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len color))
              (sdl-error "polygon-color" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "polygon-color" "bad render type")))
    ))

;;int polygonRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
;;                  int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define polygon-rgba
  (let ([ptr (gfx-func int "polygonRGBA" (list '* '* '* int uint8 uint8 uint8 uint8))])
    (lambda (ren vx vy r g b a)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len r g b a))
              (sdl-error "polygon-rgba" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "polygon-rgba" "bad render type")))
    ))


;;int aapolygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
(define aapolygon-color
  (let ([ptr (gfx-func int "aapolygonColor" (list '* '* '* int uint32))])
    (lambda (ren vx vy color)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len color))
              (sdl-error "aapolygon-color" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "aapolygon-color" "bad render type")))
    ))

;;int aapolygonRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
;;                  int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define aapolygon-rgba
  (let ([ptr (gfx-func int "aapolygonRGBA" (list '* '* '* int uint8 uint8 uint8 uint8))])
    (lambda (ren vx vy r g b a)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len r g b a))
              (sdl-error "aapolygon-rgba" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "aapolygon-rgba" "bad render type")))
    ))

;;int filledPolygonColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, Uint32 color);
(define filled-polygon-color
  (let ([ptr (gfx-func int "filledPolygonColor" (list '* '* '* int uint32))])
    (lambda (ren vx vy color)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len color))
              (sdl-error "filled-polygon-color" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "filled-polygon-color" "bad render type")))
    ))

;;int filledPolygonRGBA(SDL_Renderer * renderer, const Sint16 * vx,
;;                 const Sint16 * vy, int n, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define filled-polygon-rgba
  (let ([ptr (gfx-func int "filledPolygonRGBA" (list '* '* '* int uint8 uint8 uint8 uint8))])
    (lambda (ren vx vy r g b a)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len r g b a))
              (sdl-error "filled-polygon-rgba" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "filled-polygon-rgba" "bad render type")))
    ))


;;int texturedPolygon(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
;;                  int n, SDL_Surface * texture,int texture_dx,int texture_dy);
(define textured-polygon
  (let ([ptr (gfx-func int "texturedPolygon" (list '* '* '* int '* int int))])
    (lambda (ren vx vy texture dx dy)
      (if (surface? texture)
          (if (renderer? ren)
              (if (and (s16vector? vx) (s16vector? vy))
                  (let ([ptr-vx (bytevector->pointer vx)]
                        [ptr-vy (bytevector->pointer vy)]
                        [len (s16vector-length vx)])
                    (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len
                         ((@@ (sdl2 surface) unwrap-surface) texture) dx dy))
                  (sdl-error "polygon-color" "bad type arg vx or vy(need s16vector)"))
              (sdl-error "polygon-color" "bad render type"))
          (sdl-error "polygon-color" "bad texture type(need surface)"))
          )
    ))

;;int bezierColor(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy, int n, int s, Uint32 color);
(define bezier-color
  (let ([ptr (gfx-func int "bezierColor" (list '* '* '* int int uint32))])
    (lambda (ren vx vy s color)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len s color))
              (sdl-error "bezier-color" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "bezier-color" "bad render type")))
    ))

;;int bezierRGBA(SDL_Renderer * renderer, const Sint16 * vx, const Sint16 * vy,
;;                  int s, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define bezier-rgba
  (let ([ptr (gfx-func int "bezierRGBA" (list '* '* '* int int uint8 uint8 uint8 uint8))])
    (lambda (ren vx vy s r g b a)
      (if (renderer? ren)
          (if (and (s16vector? vx) (s16vector? vy))
              (let ([ptr-vx (bytevector->pointer vx)]
                    [ptr-vy (bytevector->pointer vy)]
                    [len (s16vector-length vx)])
                (ptr ((@@ (sdl2 render) unwrap-renderer) ren) ptr-vx ptr-vy len s r g b a))
              (sdl-error "bezier-rgba" "bad type arg vx or vy(need s16vector)"))
          (sdl-error "bezier-rgba" "bad render type")))
    ))

      
;;void gfxPrimitivesSetFont(const void *fontdata, Uint32 cw, Uint32 ch);
(define gfx-primitives-set-font
  (let ([ptr (gfx-func void "gfxPrimitivesSetFont" (list '* uint32 uint32))])
    (lambda (font cw ch)
      (if (font? font)
          (ptr ((@@ (sdl2 ttf) unwrap-font) font) cw ch)
          (sdl-error "gfx-primitives-set-font" "bad font type")))
    ))


;;void gfxPrimitivesSetFontRotation(Uint32 rotation);
(define gfx-primitives-set-font-rotation
  (let ([ptr (gfx-func void "gfxPrimitivesSetFontRotation" (list uint32))])
    (lambda (font rotation)
      (ptr ((@@ (sdl2 ttf) unwrap-font) font) rotation)
      )
    ))


;;с символами не понятка, возможно надо будет разбираться позже. 8битовый char как будет печататься?
;;int characterColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, char c, Uint32 color);
(define character-color
  (let ([ptr (gfx-func int "characterColor" (list '* int16 int16  uint8 uint32))])
    (lambda (ren x y ch color)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y ch color)
          (sdl-error "character-color" "bad render type")))
    ))

;;int characterRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y, char c, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
(define character-rgba
  (let ([ptr (gfx-func int "characterColor" (list '* int16 int16  uint8 uint8 uint8 uint8 uint8))])
    (lambda (ren x y ch r g b a)
      (if (renderer? ren)
          (ptr ((@@ (sdl2 render) unwrap-renderer) ren)  x y ch r g b a)
          (sdl-error "character-rgba" "bad render type")))
    ))


;;int stringColor(SDL_Renderer * renderer, Sint16 x, Sint16 y, const char *s, Uint32 color);
;;int stringRGBA(SDL_Renderer * renderer, Sint16 x, Sint16 y,
;;               const char *s, Uint8 r, Uint8 g, Uint8 b, Uint8 a);

