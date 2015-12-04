
#lang racket

; --------------------------------------------------------------------
; Funciones bajo response-generator
; Asociadas a las funciones de bd

; block :: list? -> list?
; Especifica asignacion de valores a variables, que fueron tomadas 
; de un formulario HTML perteneciente a una funcion CRUD. Retorna lista.
(define (block lst)
  (if (empty? lst)
      '()
      (let* ((sym (first lst))
             (symc (string->symbol (string-append (symbol->string sym) "_crud"))))
        (define exp `(define ,sym (extract-binding/single ',symc bind)))
        (cons exp (block (rest lst))))))
        
;(define (addmarkcrud lst)
;    (if (empty? lst)
;        '()
;        (let* ((elemt (first lst))
;               (mark (string-append elemt "_crud")))
;            (cons mark (addmarkcrud (rest lst))))))

; make-block :: string string list? -> expr?
; Crea asignacion de variables y llamado a funcion CRUD de una tabla 
; especifica. Retorna expresion.
(define (make-block npg func lst)
  (define symnpg (string->symbol npg))
  (define symfunc (string->symbol func))
  (define bdf (string->symbol (string-append "bd-" func)))
  (define blk `(define (,symfunc request)
                 (define bind (request-bindings request)) 
                  ,@(block lst)
                  ;(,bdf ,@lst)
                  ;(,symnpg args request)))
                  (define nargs (,bdf ,@lst))
                  (,symnpg nargs request)))
  blk)

; lst-for-block :: string string list? -> (listof list?)
; Construye lista de listas de valores de asignacion y llamado de funciones 
; CRUD de una tabla en especifico, para posteriormente crear sus expresiones. 
; Retorna lista de listas.
(define (lst-for-block npg ntb lst)
  (if (empty? lst)
      '()
      (let* ((sublst (first lst))
             (ntable (second sublst))
             (nfunc  (third sublst)) ; nprocd
             (lstarg (last sublst))  ; campos y rest
             (long (length sublst)))
        (if (< long 6)
            ; Ignoramos aquellas func sin rests
            (lst-for-block npg ntb (rest lst))
            (if (string=? ntb ntable)
                (cons (list npg nfunc lstarg) (lst-for-block npg ntb (rest lst)))
                (lst-for-block npg ntb (rest lst)))))))

; prev-make-block :: string string (listof list?) -> list?
; Busca y crea expresiones de asignacion y llamado de funciones CRUD
; de una tabla en especifico. Retorna lista.
(define (prev-make-block npg ntb lst)
  (define lstblk (lst-for-block npg ntb lst))
  (for/list ((elemt lstblk))
    ; nombrepagina nombrefuncion lstarg
    (make-block (first elemt) (second elemt) (third elemt))))

; ***** func-sql-render
;(define (func-sql-render npg ntb)
;  (prev-make-block npg ntb flst))

; --------------------------------------------------------------------
; Funciones para generacion de forms (formularios)
; lst-for-block-form :: string string list? -> (listof list?)
; Construye lista de listas de valores de asignacion y llamado de funciones 
; CRUD de una tabla en especifico, para posteriormente crear sus expresiones. 
; Retorna lista de listas.
(define (lst-for-block-form npg ntb lst)
  (if (empty? lst)
      '()
      (let* ((sublst (first lst))
             (ntable (second sublst))
             (nfunc  (third sublst))  ; 3 nprocd
             (tfunc  (fourth sublst)) ; 4 tipo sql
             (lstarg (last sublst))   ; last campos y rest
             (long (length sublst)))
        (if (< long 6)
            ; Ignoramos aquellas func sin rests
            (lst-for-block-form npg ntb (rest lst))
            (if (string=? ntb ntable)
                (cons (list npg nfunc tfunc lstarg) (lst-for-block-form npg ntb (rest lst)))
                (lst-for-block-form npg ntb (rest lst)))))))

; block-form :: string string list? -> list?
; Crea elementos HTML input para formulario de funcion CRUD perteneciente
; a una tabla en especifico. Retorna lista.
(define (block-form func jsform lst)
  (if (empty? lst)
      (list `(input ((type "button") (value ,func) 
                (onclick ,(string-append "process_crud_form(" jsform ");")))))
      (let* ((field (symbol->string (first lst)))
             (field (string-append field "_crud")))
        (define exp `(input ((type "hidden") (name ,field) (id ,field))))
        (cons exp (block-form func jsform (rest lst))))))

; make-block-form :: string string string list? -> expr?
; Construye formulario de una funcion CRUD de una tabla en especifico.
; Retorna expresion.
(define (make-block-form npg func typef lst)
  (define symnpg (string->symbol npg))
  (define symfunc (string->symbol func))
  (define dtypef (string-append (string-downcase typef) "-form"))
  (define formf (string-append "form-" func))
  (define jsformf (string-append "'" formf "'"))
  (define embed `(embed/url ,symfunc))
  (define blk `(form ((id ,formf) (class ,dtypef) (method "post") (action ,(list 'unquote embed))) 
                  ,@(block-form func jsformf lst)))               ; ,(embed/url
  blk)
         
; prev-make-block-form :: string string list? -> list?
; Busca y crea formularios para todas las funciones CRUD de una tabla
; en especifico. Retorna lista.
(define (prev-make-block-form npg ntb lst)
  (define lstblk (lst-for-block-form npg ntb lst))
  (for/list ((elemt lstblk))
    ; nombrepagina nombrefuncion tipofuncion lstarg
    (make-block-form (first elemt) (second elemt) (third elemt) (fourth elemt))))

; --------------------------------------------------------------------
; Funciones para generacion de bloques-select-all (select sin restricciones)

; lst-for-block-sa :: string string list? -> list?
; Crea lista con valores de asignacion de funcion SELECT sin
; restriccion de una tabla en especifico. Retorna lista.
(define (lst-for-block-sa npg ntb lst)
  (if (empty? lst)
      '()
      (let* ((sublst (first lst))
             (ntable (second sublst))
             (nfunc  (third sublst))
             (noper  (fourth sublst))
             (long (length sublst)))
        (if (and (= long 5) (string=? noper "SELECT"))
            (if (string=? ntb ntable)
                (cons nfunc (lst-for-block-sa npg ntb (rest lst)))
                (lst-for-block-sa npg ntb (rest lst)))
            (lst-for-block-sa npg ntb (rest lst))))))
                
; make-block-sa :: string -> list?
; Crea expresion de llamado a funcion SELECT sin restricciones.
; Retorna lista.
(define (make-block-sa nfunc)
    (define bdf (string->symbol (string-append "bd-" nfunc)))
    (define blk `(render-table "div-tableselect-all" (,bdf)))
    (define blkf (list 'unquote blk))
    blkf)

; prev-make-block-no-form :: string string list? -> list?
; Busca y crea expresiones de asignacion y llamado de funcion SELECT sin
; restricciones de una tabla en especifico. Retorna lista.
(define (prev-make-block-no-form npg ntb lst)
    (define lstblk (lst-for-block-sa npg ntb lst))
    (for/list ((nfunc lstblk))
        (make-block-sa nfunc)))

(provide (all-defined-out))
