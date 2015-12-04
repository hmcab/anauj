
#lang racket/base
(require racket/list
		 racket/local
		 racket/file
		 db)

; Variable global para conocer estado de la conexión 
; a la base de datos.
(define db #f)

; inicializar-conn :: nothing -> boolean
; Establece conexión con base de datos, de ser así
; devuelve #t, de lo contrario #f.
(define (inicializar-conn)
	(set! db (postgresql-connect 
			#:server "localhost"
			#:port 5432
			#:database "codegen"
			#:user "postgres"
			#:password "56648865"))
  	(if (connected? db)
		#t
		#f))
		
; inicializado :: nothing -> boolean
; Verifica si existe conexión con base de datos establecida,
; si es así devuelve #t, de lo contrario #f.
(define (inicializado)
	(if (and (not (boolean? db)) (connected? db))
		#t
		#f))

; Control de errores
; manage-error-sql :: list? -> string
; Procesa errores originados en las funciones de persistencia.
; Retorna string.
(define (manage-error-sql lst) 
	(if (void? lst) 
		"801: Consulta procesada con éxito. Verifique los datos." 
		(let ((code (string->number (cdr (car (cdr lst)))))) 
			(cond ((= code 23505) "802: Datos ya registrados.") 
				(else "803: Consulta no fue procesada con éxito.")))))
				
; Registrar un nuevo cliente
; insert-new-user :: string string string string string string -> string/boolean
; Registra nuevo cliente en la base de datos. Si se crea nuevo usuario se
; retorna cadena de texto confirmando operacion, de lo contrario #f.
(define (insert-new-user email nom ape sexo pass confpass)
	(if (inicializado)
		(manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info))
			(query-exec db "INSERT INTO usuario (email,nombre,apellidos,sexo,pass,confpass) VALUES($1,$2,$3,$4,$5,$6)" email nom ape sexo pass confpass))) #f))

; insert-relation :: string string string -> string/boolean
; Relaciona un nuevo usuario con dos esquemas de base de datos pre-establecidos.
; Retorna cadena de texto en caso de ejecutar la operación, #f en caso de no
; hacerlo.
(define (insert-relation id esqa esqb)
	(if (inicializado)
	   (let ()
		(define rsa (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info))
			(query-exec db "INSERT INTO proyecto (email,nomesq) VALUES ($1,$2)" id esqa))))
		
		(define rsb (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info))
			(query-exec db "INSERT INTO proyecto (email,nomesq) VALUES ($1,$2)" id esqb))))
		rsb) #f))
			
; Consulta la existencia de esquema en base de datos,
; <no como registro en tabla esquemas>.
; login-check-schema-inbd :: string -> string/boolean
; Consulta si esquema está creado en la base de datos, no como
; registro en tabla esquemas. Si existe el esquema devuelve su nombre,
; de lo contrario #f.
(define (login-check-schema-inbd schema)
	(define rs (query-maybe-row db "SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1" schema))
	(if (vector? rs)
		(first (vector->list rs))
		#f))

; Consulta de esquemas
; select-schema :: nothing -> list?/boolean
; Consulta todos los esquemas registrados en tabla esquema. Retorna lista si
; operacion es exitosa, de lo contrario #f.
(define (select-schema)
	(define rs (query-rows db "SELECT * FROM esquema"))
	(if (list? rs)
		(let* ((lst-lst (map (lambda (cell) (vector->list cell)) rs)) ; lst de lst
			   (lst-str (map (lambda (cell) (first cell)) lst-lst)))  ; lst de str
			   lst-str)
		#f))
		
; Consulta de usuario - proceso de login
; login-check-user :: string string -> boolean
; Consulta si usuario se encuentra registrado. Retorna #t de ser asi, 
; #f en caso contrario.
(define (login-check-user user pass)
	(define rs (query-maybe-row db "SELECT email FROM usuario WHERE email = $1 AND pass = $2" user pass))
	(if (vector? rs)
		#t
		#f))
	
; Consulta de schema - proceso de login
; login-check-schema :: string string -> boolean
; Consulta si esquema se encuentra asociado al usuario. Retorna #t de ser asi,
; #f en caso contrario.
(define (login-check-schema user schema)
	(define rs (query-maybe-row db "SELECT email, nomesq FROM proyecto WHERE email = $1 AND nomesq = $2" user schema))
	(if (vector? rs)
		#t
		#f))
		
; select-user :: string string -> list?
; Consulta informacion de usuario. Retorna lista si existe, 
; #f en caso contrario.
(define (select-user user pass)
	(define rs (query-maybe-row db "SELECT email FROM usuario WHERE email = $1 AND pass = $2" user pass))
	(if (vector? rs)
		(vector->list rs)
		#f))
		
; -----------------------------------------------------------------------------

; Tablas de un esquema especificado
; get-tablas :: string -> list?
; Consulta tablas pertenecientes a un esquema,
; retorna lista con los nombres de las tablas.
(define (get-tablas schema)
	(define rs (query-list db "SELECT tablename FROM pg_tables WHERE schemaname = $1" schema))
	(if (empty? rs)
		'()
		rs))
		
; Campos de una tabla y esquema especificado
; get-campos :: string string -> (listof vector?)
; Consulta campos y propiedades de una tabla perteneciente a un esquema,
; retorna una lista de vectores con los campos y propiedades.
(define (get-campos schema table)
	(define rs (query-rows db "SELECT table_schema, table_name, column_name, data_type, character_maximum_length, is_nullable, ordinal_position FROM information_schema.columns WHERE table_schema = $1 and table_name = $2" schema table))
	(if (empty? rs)
		'()
		rs))

; Tipos de los campos de una tabla y esquema especificado
; get-tipodatos-campos :: string string -> (listof vector?)
; Consulta los tipos de datos de los campos de una tabla y esquema en especifico.
; Retorna una lista de vectores.
(define (get-tipodatos-campos schema table)
	(define rs (query-rows db "SELECT table_schema, table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = $1 and table_name = $2" schema table))
	(if (empty? rs)
		'()
		rs))
		
; login-app :: nothing -> boolean
; Consulta estado actual de la herramienta, 
(define (login-app)
	(define rs (query-row db "SELECT estado from estado where id=$1" "anauj"))
	(if (vector? rs)
		(first (vector->list rs))
		#f))
	
; set-login-app :: nothing -> string
; Cambia estado actual de la herramienta, #t si empezó a ser usada, #f en caso contrario.
(define (set-login-app value)
	(manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info))
		(query-exec db "UPDATE estado set estado=$1 where id=$2" value "anauj"))))
			
(provide (all-defined-out))
