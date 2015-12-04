
#lang racket

(require "conf.rkt")

; Directorio donde residirá aplicación protitipo.
;(define view-funcs-dir "/home/hmc/Documentos/racket-proy/codegen/apps/")

; save-view-funcs-file :: string -> void?
; Crea archivo de codigo fuente con algunas funciones de vista.
; Retorna void?. 
(define (save-view-funcs-file schema)
    (let* ((file (string-append view-funcs-dir schema "/" schema "-view.rkt"))
	   (out (open-output-file file
		    #:mode 'binary
		    #:exists 'replace)))
	(write-head-view out)
	(write-end-view out)
	(close-output-port out)))

; remove-view-funcs-file :: string -> void?
; Elimina archivo de codigo fuente de funciones de vista.
; Retorna void?.
(define (remove-view-funcs-file schema)
    (define file (string-append view-funcs-dir schema "/" schema "-view.rkt"))
    (if (file-exists? file)
	(delete-file file)
	(display "\nremove-view-file: file does not exist.\n")))
	    
; get-render-table :: nothing -> expr?
; Crea expresion encargada de crear tabla en HTML. 
; Retorna expresion.
(define (get-render-table)
  (define funcstr ; ((id \"div-table-form\"))
    "\n(define (render-table name lstv)
	`(div ((id ,name) (name ,name))
		(table
		    (thead)
		    (tbody ,@(render-table-aux lstv)))))") funcstr)
	
; get-render-table-aux :: nothing -> expr?
; Funcion auxiliar que crea expresion para construir cuerpo de tabla HTML.
; Retorna expresion.
(define (get-render-table-aux)
  (define funcstr
    "\n(define (render-table-aux lstv)
	(if (empty? lstv)
	    '()
	    (let* ((vec (first lstv))
		   (v2l (vector->list vec)))
		(define cols (map (lambda (col)
			    (set! col (sql-date-str col))
				`(td ,col)) v2l))
		(define row `(tr ,@cols))
		(cons row (render-table-aux (rest lstv))))))") funcstr)
	
; get-sql-date-str :: nothing -> expr?
; Crea expresion encargada de convertir estructura de fecha (date) sql-date?
; o valor numerico en cadena de texto. 
; Retorna expresion.
(define (get-sql-date-str)
  (define funcstr
    "\n(define (sql-date-str data)
	(if (sql-date? data)
	    (string-append (number->string (sql-date-year data)) \"-\"
			   (number->string (sql-date-month data)) \"-\"
			   (number->string (sql-date-day data)))
	    (cond 
		[(number? data) (number->string data)]
		[(boolean? data) (if data \"true\" \"false\")]
		[else
		    data])))") funcstr)
	    
; *** write-head
; write-head :: open-output-file -> void?
; Escribe en archivo algunas funciones de vista. 
; Retona void?.
(define (write-head-view df)
    (define head 
"\n#lang racket/base
(require racket/list
	 racket/local
	 racket/file
	 db)\n
(require (planet neil/html-writing:2:0))
(require 2htdp/batch-io)\n")
    (define table (get-render-table))
    (define table-aux (get-render-table-aux))
    (define date (get-sql-date-str))
    (display head df)
    (display table df)
    (display table-aux df)
    (display date df))

; *** write-end
; write-end-view :: open-output-file -> void?
; Escribe en archivo funcion de exportacion de funciones.
; Retorna void?.
(define (write-end-view df)
    (display "\n(provide render-table render-table-aux)" df))
    
(provide (all-defined-out))
