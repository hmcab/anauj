
#lang racket

(require "conf.rkt")
(require "campos.rkt")

; Directorio de funciones crud de aplicación prototipo
;(define crud-funcs-dir "/home/hmc/Documentos/racket-proy/codegen/apps/")

; Lista con los nombres de los campos date en base de datos
;(define datelst (list "fecnac" "fecventa" "fecped"))

; save-crud-funcs-file :: string list? -> void?
; Crea archivo de codigo fuente con funciones de persistencia del aplicativo
; generado, para todas las tablas especificadas. Retorna void?.
(define (save-crud-funcs-file schema lst)
    (let* ((file (string-append crud-funcs-dir schema "/" schema "-crud.rkt"))
	   (out (open-output-file file
		    #:mode 'binary
		    #:exists 'replace)))
	(define funcs-lst (make-crud-funcs lst))
	(write-head out schema)
	(write-crud-funcs-file out funcs-lst)
	(write-end out)
	(close-output-port out)))

; remove-crud-funcs-file :: string -> void?
; Elimina archivo de codigo fuente schema-crud.rkt.
; Retorna void?.
(define (remove-crud-funcs-file schema)
    (define file (string-append crud-funcs-dir schema "/" schema "-crud.rkt"))
    (if (file-exists? file)
	(delete-file file)
	(display "\nremove-crud-file: file does not exist.\n")))

; write-crud-funcs-file :: open-output-file list? -> void?
; Escribe funciones de persistencia en archivo.
; Retorna void?.
(define (write-crud-funcs-file df lst)
    (if (empty? lst)
	""
	(let ((func (first lst)))
	    (displayln func df)
	    ;(displayln (format "~s" func) df)
	    (write-crud-funcs-file df (rest lst)))))
	    
; func-conn :: nothing -> expr?
; Crea expresion para conexion con base de datos del aplicativo generado.
; Retorna expresion.
(define (func-conn)
    `(define (inicializar-conn)
	(set! db (postgresql-connect 
	    #:server "localhost"
	    #:port 5432
	    #:database "codegen"
	    #:user "postgres"
	    #:password "56648865"))
	(if (connected? db)
	    #t
	    #f)))
	    
; check-conn :: nothing -> expr?
; Crea expresion para verificacion de conexion con base de datos del aplicativo
; generado. Retorna expresion.
(define (check-conn)
    `(define (inicializado)
	(if (and (not (boolean? db)) (connected? db))
	    #t
	    (inicializar-conn))))
	    
; error-sql :: nothing -> expr?
; Crea expresion para manejo de errores de las funciones CRUD del archivo
; de persistencia del aplicativo generado. Retorna expresion.
(define (error-sql)
    `(define (manage-error-sql lst)
	(if (void? lst)
	    "Consulta procesada con éxito. Verifique los datos."
	    ;#t
	    ; code error --- codigos de error especificos de postgresql
	    (let ((code (string->number (cdr (car (cdr lst))))))
		(cond
		    [(= code 23505) "Datos ya registrados."]
		    [else "Consulta no fue procesada con éxito."])))))

; *** write-head
; write-head :: open-output-file string -> void?.
; Crea y escribe funciones cabecera en archivo de persistencia del 
; aplicativo generado. Retorna void?.
(define (write-head df schema)
    (define head 
    "\n#lang racket/base
    (require racket/list
	    racket/local
	    racket/file
	    db)
    (define db #f)")
    (define inicdb 	(format "\n\n~s" (func-conn)))
    (define checkdb 	(format "\n\n~s" (check-conn)))
    (define errorsql 	(format "\n\n~s" (error-sql)))
    (define fmtdate 	(format "\n\n~s\n\n" (format-date)))
    (display head df)
    (display inicdb df)
    (display checkdb df)
    (display errorsql df)
    (display fmtdate df))

; *** write-end
; write-end :: open-output-file -> void?
; Escribe funcion exportacion para las funciones definidas en el
; archivo de persistencia. Retorna void?.
(define (write-end df)
    (display "\n(provide (all-defined-out))" df))

; Creacion de funcion format-date para la conversion
; de los campos date (fecha) de la bd
; format-date :: string -> expr?
; Crea expresion para la conversion de valores date (fecha) de string
; a estructura make-sql-date. Retorna expresion.
(define (format-date)
    `(define (format-date elemt)
	(if (regexp-match? #px"[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}" elemt)
	    (let* ((date (regexp-split #rx"-" elemt))
		   (anio (first date))
		   (mes (second date))
		   (dia (third date)))
		(make-sql-date 
		    (string->number anio)
		    (string->number mes)
		    (string->number dia)))
	    elemt)))
	
; find-term :: string -> boolean
; Busca si campo especificado es el campo date (fecha) en la base de datos.
; Retorna #t si es asi, #t en caso contrario.
; (if (regexp-match? mydate (first flst))
(define (find-term mydate)
    (let loop ((flst datelst)) ; datelst from conf.rkt
	(if (empty? flst)
	    #f
	    (if (string=? mydate (first flst))
		#t
		(loop (rest flst))))))
	    
; format-args :: list? -> list?
; Busca si en lista especificada existe un campo date (fecha) para
; especificar su funcion de conversion. Retorna lista.
; (if (regexp-match? #rx"[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}" elemt)
(define (format-args args)
    (if (empty? args)
	'()
	(let ((elemt (first args)))
	    (if (find-term (symbol->string elemt))
		(append (list `(format-date ,elemt)) (format-args (rest args)))
		(cons elemt (format-args (rest args)))))))
		
; format-args-td :: string string list? -> expr?
; Extrae el tipo de datos de cada campo de la lista otorgada, 
; para especificar la expresión de conversión adecuada. Retorna expresión.
(define (format-args-td sch tab args)
    (if (empty? args)
	'()
	(let* ((campo (first args))
	       (lsttd (get-campo-td sch tab campo))
	       (tipodato (if (list? lsttd) (fourth lsttd) "")))
	    (cond
		[(or (string=? tipodato "smallint")
		     (string=? tipodato "integer")
		     (string=? tipodato "bigint"))  
			(append (list `(string->number ,campo)) (format-args-td sch tab (rest args)))]
		[(or (string=? tipodato "numeric")
		     (string=? tipodato "real")
		     (string=? tipodato "double precision"))
			(append (list `(string->number ,campo)) (format-args-td sch tab (rest args)))]
		[(string=? tipodato "boolean")
		    (append (list `(if (string=? ,campo "\"true\"") #t #f)) (format-args-td sch tab (rest args)))]
		[(string=? tipodato "date")
		    (append (list `(format-date ,campo)) (format-args-td sch tab (rest args)))]
		[else
		    (cons campo (format-args-td sch tab (rest args)))]))))
		 
; Generacion de funciones crud
; make-crud-funcs :: (listof list?) -> list?
; Crea expresiones para las funciones CRUD especificadas de la totalidad de
; tablas del esquema de base de datos. Retorna lista.
(define (make-crud-funcs lst)
    (for/list [(elemt lst)]
	(make-crud-func elemt)))
    
; make-crud-func :: list? -> expr?
; Obtiene el tamaño de la lista especificada, para decidir que tipo
; de funcion CRUD crear. Retorna expresion.
(define (make-crud-func elemt)
  (let ((schema	(first elemt))
	(ntable	(second elemt))
	(nprocd	(third elemt))	; 3 nprocd
        (fsql	(fourth elemt)) ; 4 fsql
        (sql	(fifth elemt))  ; 5 sql_string_format
        (args	(last elemt))   ; last campos y rests
        (long	(length elemt)))
    (if (< long 6)
        (make-crud-func-nargs nprocd fsql sql)
        (make-crud-func-args schema ntable nprocd fsql sql args))))

; make-crud-func-nargs :: string string string -> expr?
; Decide que tipo de funcion CRUD a crear. 
; Retorna expresion.
(define (make-crud-func-nargs nprocd fsql sql)
  (cond 
    [(string=? fsql "SELECT") (sql-select-nargs nprocd sql)]))

; make-crud-func-args :: string string list? -> expr?
; Decide que tipo de funcion CRUD a crear.
; Retorna expresion.
(define (make-crud-func-args sch tab nprocd fsql sql args)
  (cond 
    [(string=? fsql "INSERT") (sql-insert-args sch tab nprocd sql args)]
    [(string=? fsql "SELECT") (sql-select-args sch tab nprocd sql args)]
    [(string=? fsql "UPDATE") (sql-update-args sch tab nprocd sql args)]
    [(string=? fsql "DELETE") (sql-update-args sch tab nprocd sql args)]))

; SQL sin argumentos
; sql-select-nargs :: string string -> expr?
; Crea expresion de funcion SELECT sin argumentos, que posteriormente
; se escribe en archivo de persistencia de aplicativo generado. 
; Retorna expresion.
(define (sql-select-nargs nprocd sql)
  (define bdf (string->symbol (string-append "bd-" nprocd)))
  (define strsql (string-append "\"" sql "\""))
  (define bdfn `(define (,bdf)
                  (if (inicializado)
                      (let ()
                        (define rs (query-rows db ,strsql))
                        (if (empty? rs) "\"Consulta no arrojó algún resultado.\"" rs))
                      #f))) 
  bdfn)

; SQL con argumentos - format-date para fechas
; sql-insert-args :: string string list? -> expr?
; Crea expresion de funcion INSERT con argumentos, que posteriormente
; se escribe en archivo de persistencia de aplicativo generado. 
; Retorna expresion.
(define (sql-insert-args sch tab nprocd sql args)
  (define bdf (string->symbol (string-append "bd-" nprocd)))
  (define strsql (string-append "\"" sql "\""))
  (define bdfn `(define (,bdf ,@args)
                  (if (inicializado)
                      (manage-error-sql
                       (with-handlers ([exn:fail:sql? exn:fail:sql-info])
			 (query-exec db ,strsql ,@(format-args-td sch tab args))))
                      #f)))
  bdfn)

; sql-select-args :: string string list? -> expr?
; Crea expresion de funcion SELECT con argumentos, que posteriormente
; se escribe en archivo de persistencia de aplicativo generado. 
; Retorna expresion.
(define (sql-select-args sch tab nprocd sql args)
  (define bdf (string->symbol (string-append "bd-" nprocd)))
  (define strsql (string-append "\"" sql "\""))
  (define bdfn `(define (,bdf ,@args)
                  (if (inicializado)
                      (let ()
                        (define rs (query-rows db ,strsql ,@args))
                        rs)
                      #f))) 
  bdfn)

; sql-update-args :: string string list? -> expr?
; Crea expresion de funcion UPDATE con argumentos, que posteriormente
; se escribe en archivo de persistencia de aplicativo generado. 
; Retorna expresion.
(define (sql-update-args sch tab nprocd sql args)
  (define bdf (string->symbol (string-append "bd-" nprocd)))
  (define strsql (string-append "\"" sql "\""))
  (define bdfn `(define (,bdf ,@args)
                  (if (inicializado)
                      (manage-error-sql
                       (with-handlers ([exn:fail:sql? exn:fail:sql-info])
                         (query-exec db ,strsql ,@(format-args-td sch tab args))))
                      #f)))
  bdfn)
	    
(provide (all-defined-out))
