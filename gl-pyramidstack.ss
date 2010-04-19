#lang scheme
(require (planet jaymccarthy/chipmunk:1:0)
         (planet jaymccarthy/gl-world:1:0)
         (planet jaymccarthy/gl2d:1:0)
         sgl)

(printf "Space setup~n")
(define space (cpSpaceNew))
(set-cpSpace-iterations! space 60)
(cpSpaceResizeStaticHash space 40.0 1000)
(cpSpaceResizeActiveHash space 40.0 1000)
(set-cpSpace-gravity! space (cpv 0.0 -100.0))

(printf "Static setup~n")
(define staticBody (cpBodyNew +inf.0 +inf.0))

(define width 640.0)
(define height 480.0)
(define hwidth (/ width 2))
(define hheight (/ height 2))

(printf "Shape 1~n")
(define left-side
  (cpSegmentShapeNew staticBody (cpv 0.0 0.0) (cpv 0.0 height) 1.0))
(set-cpShape-e! left-side 1.0)
(set-cpShape-u! left-side 1.0)
(cpSpaceAddStaticShape space left-side)

(printf "Shape 2~n")
(define right-side
  (cpSegmentShapeNew staticBody (cpv width 0.0) (cpv width height) 1.0))
(set-cpShape-e! right-side 1.0)
(set-cpShape-u! right-side 1.0)
(cpSpaceAddStaticShape space right-side)

(printf "Shape 3~n")
(define ceiling
  (cpSegmentShapeNew staticBody (cpv 0.0 0.0) (cpv width 0.0) 1.0))
(set-cpShape-e! ceiling 1.0)
(set-cpShape-u! ceiling 1.0)
(cpSpaceAddStaticShape space ceiling)

(printf "Shape 4~n")
(define floor
  (cpSegmentShapeNew staticBody (cpv 0.0 height) (cpv width height) 1.0))
(set-cpShape-e! floor 1.0)
(set-cpShape-u! floor 1.0)
(cpSpaceAddStaticShape space floor)

(printf "Bodies~n")
(define block-mass 0.1)
(define block-size 32.0)
(define rows 14)
(define verts
  (vector (cpv 0.0 0.0)
          (cpv 0.0 block-size)
          (cpv block-size block-size)
          (cpv block-size 0.0)))
(define tiles
  (for*/list ([i (in-range rows)]
              [j (in-range (add1 i))])
    (local [(define body (cpBodyNew block-mass (cpMomentForPoly block-mass verts cpvzero)))]
      (set-cpBody-p! body (cpv (+ hwidth (- (* j block-size) (* i 16)))
                               (* (- rows i) block-size)))
      (cpSpaceAddBody space body)
      (local [(define shape (cpPolyShapeNew body verts cpvzero))]
        (set-cpShape-e! shape 0.0)
        (set-cpShape-u! shape 0.2)
        (cpSpaceAddShape space shape))
      body)))

(printf "Add a ball to make things more interesting~n")
(printf "Body~n")

(define ball-radius 15.0)
(define ball-mass 10.0)
(define ball-body (cpBodyNew ball-mass (cpMomentForCircle ball-mass 0.0 ball-radius cpvzero)))
(set-cpBody-p! ball-body (cpv hwidth (- height ball-radius)))
(cpSpaceAddBody space ball-body)

(printf "Shape~n")
(define ball-shape (cpCircleShapeNew ball-body ball-radius cpvzero))
(set-cpShape-e! ball-shape 0.0)
(set-cpShape-u! ball-shape 0.9)
(cpSpaceAddShape space ball-shape)

(printf "Setup Done~n")

(define (body-x b)
  (cpVect-x (cpBody-p b)))
(define (body-y b)
  (cpVect-y (cpBody-p b)))

(define steps +inf.0)
(define rate 1/60)
(define dt (exact->inexact rate))

(require scheme/runtime-path)
(define-runtime-path texture-path '(lib "stop-32x32.png" "icons"))

(define display-width 800)
(define display-height 600)

(define stop-text (box #f))
(big-bang exact-integer? 0 
          #:height display-height
          #:width display-width
          #:on-tick 
          (lambda (i)
            (cpSpaceStep space dt)
            (add1 i))
          #:tick-rate rate
          #:on-key 
          (lambda (i k)
            (define strength 1000.0)
            (define force
              (match (send k get-key-code)
                ['down (cpv 0.0 (* -1 strength))]
                ['up (cpv 0.0 strength)]
                ['left (cpv (* -1 strength) 0.0)]
                ['right (cpv strength 0.0)]
                [else #f]))
            (when force
              (cpBodyApplyImpulse ball-body force cpvzero))
            i)
          #:draw-init
          (lambda ()
            (set-box! stop-text (gl-load-texture texture-path)))
          #:on-draw 
          (lambda (i)
            (gl-clear-color 255 255 255 0)
            (gl-clear 'color-buffer-bit)
            
            (gl-init display-width display-height
                     width height
                     (/ width 2) (/ height 2)
                     (body-x ball-body) (body-y ball-body))
            
            (gl-bind-texture (unbox stop-text))
            (for ([t (in-list tiles)])
              (with-translate (body-x t) (body-y t)
                (with-rotation (* (cpBody-a t) (/ 180 pi))
                  (gl-color 1 1 1 1)
                  (gl-draw-rectangle/texture block-size block-size))))
            
            (gl-color 1 1 1 1)
            (with-translate (body-x ball-body) (body-y ball-body)
              (with-scale ball-radius ball-radius
                (gl-draw-circle 'solid))))
          #:stop-when 
          (lambda (i)
            (i . >= . steps))
          #:stop-timer
          (lambda (i)
            (i . >= . steps)))

(printf "Done~n")
(cpBodyFree staticBody)
(cpSpaceFreeChildren space)
(cpSpaceFree space)