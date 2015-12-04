
#lang racket

(require "../almacenamiento-datos/conn.rkt")

; Estructura de datos que almacena las tablas 
; pertenecientes a un esquema.
(define vtablasg (list))

; Estructura de datos que almacena tablas a generar 
; en la aplicacion prototipo.
(define vtablas (list))

; inic-vtablas :: string -> void?
; Construye lista de tablas pertenecientes a un esquema.
; El nombre del esquema lo adiciona como primer elemento.
; Retorna lista.
(define (inic-vtablas schema)
	(if (inicializar-conn)
		(let ((lst (get-tablas schema)))
			(set! vtablasg (cons schema lst)))
		(display "No connect.")))

; Retornamos lista de tablas
; get-vtablas :: string -> list?
; Consulta tablas pertenecientes al esquema especificado y las
; asigna en vtablasg. Retorna lista.
(define (get-vtablas schema)
	(if (empty? vtablasg)
		(inic-vtablas schema)
		(display "tables loaded."))
	vtablasg)
	
; check-ext-table :: string -> boolean
; Verifica si tabla especificada se encuentra listada
; en vtablas. Retorna boolean.
(define (check-ext-table ntable)
	(check-table vtablas ntable))
	
; check-table :: list? string -> boolean
; Busca si tabla especificada se encuentra listada
; en vtablas. Retorna boolean.
(define (check-table lst ntable)
	(if (empty? lst)
		#f
		(if (string=? (first lst) ntable)
			#t
			(check-table (rest lst) ntable))))

; active-table :: string -> string
; Verifica si tabla especificada se encuentra activa, es decir
; se encuentra en vtablas. 
; Retorna string.
(define (active-table ntable)
	(if (check-table vtablas ntable)
		"on"
		"off"))
		
; add-table :: string -> list?
; Agrega tabla especificada en vtablas.
; Retorna lista.
(define (add-table ntable)
	(define istable (check-table vtablas ntable))
	(if istable
		vtablas
		(cons ntable vtablas)))
		
; remove-table :: list? string -> list?
; Elimina tabla especificada de vtablas.
; Retorna lista.
(define (remove-table lst ntable)
	(if (empty? lst)
		'()
		(if (string=? (first lst) ntable)
			(remove-table (rest lst) ntable)
			(cons (first lst) (remove-table (rest lst) ntable)))))
	
; modf-tables :: string -> void?
; Verifica si usuario activó alguna tabla del esquema (opción on), 
; si es así, almacena su nombre en vtablas, de lo contrario la elimina.
; Retorna void?
(define (modf-tables tablevalue)
	(define table-value (regexp-split #rx":" tablevalue))	
	(let* ((ntable (first table-value))
		   (value (second table-value)))
		  (if (string=? value "on")
			  (set! vtablas (add-table ntable))
			  (set! vtablas (remove-table vtablas ntable)))))

; get-tablas-alm :: nothing -> list?
; Retorna lista de tablas.	  
(define (get-tablas-alm)
	vtablasg)

; get-tables :: nothing -> list?
; Retorna lista de tablas activas.
(define (get-tables)
	vtablas)
	
; clean-tablas-data :: nothing -> void?
; Elimina datos de estructura de datos vtablasg y vtablas.
; Relacionadas con la listas de tablas del esquema y lista
; de tablas activas. Retorna void?.
(define (clean-tablas-data)
	(set! vtablasg (list))
	(set! vtablas (list)))
	
(provide (all-defined-out))
