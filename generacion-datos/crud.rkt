
#lang racket

(require "conf.rkt")
(require "crud-format.rkt")

; ::: CRUD
; reg-exp : operlog & nschema & ntable & nprocd & funcsql & camposql (or & restsql)
; nschema | ntable  | reg-exp
; operlog | nschema | ntable | nprocd | funcsql | camposql
; operlog | nschema | ntable | nprocd | funcsql | camposql | restsql

; Antes de iniciar la generacion de codigo
; CRUD es reformateada a:
; nschema | ntable | nprocd | funcsql | sql_string | lista campos
; nschema | ntable | nprocd | funcsql | sql_string | lista campos & restricciones
; sql_string : INSERT -> INSERT INTO ... VALUES (...)

; ::: CRUD PER
; reg-exp : nschema & ntable & nprocd & fsql & sql (lista para usar) & campos , rest
; nschema | ntable  | reg-exp

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

; Directorio de herramienta CASE
;(define crud-dir "/home/hmc/Documentos/racket-proy/codegen/")

; Estructura de datos global que almacena temporalmente configuraciones 
; de funciones CRUD de la totalidad de tablas del esquema.
(define vcrudg (list))

; Estructura de datos para configuraciones de funciones CRUD personalizadas.
(define vcrudg-per (list))

; save-crud-file :: string string string -> void?
; Almacena en archivo las configuraciones de funciones CRUD estándar
; y personalizadas de la totalidad de las tablas del esquema, haciendo
; distinción del archivo a través de su extensión. Retorna void?.
(define (save-crud-file schema extfile data)
    (if (not (empty? data))
	(let* ((file (string-append crud-dir schema extfile))
	       (out (open-output-file file
			#:mode 'binary
			#:exists 'replace)))
	    (write data out)
	    (close-output-port out))
	(remove-crud-file schema extfile)))
	;(display "\nsave-crud-file: uncharged crud. file was not created.\n")))
	
; get-crud-file :: string -> void?
; Obtiene configuraciones de funciones CRUD desde archivo schema.crud,
; y los asigna a lista vcrudg. Retorna void?.
(define (get-crud-file schema)
    (define file (string-append crud-dir schema ".crud"))
    (if (file-exists? file)
	(let* ((in (open-input-file file))
	       (data (read in)))
	    (set! vcrudg data)
	    (close-input-port in)
	    #t)
	#f))

; get-crud-per-file :: string -> void?
; Obtiene configuraciones de las funciones CRUD personalizadas desde
; el archivo schema.crudp, y los asigna a lista vcrudg-per. 
; Retorna void?.
(define (get-crud-per-file schema)
    (define file (string-append crud-dir schema ".crudp"))
    (if (file-exists? file)
	(let* ((in (open-input-file file))
	       (data (read in)))
	    (set! vcrudg-per data)
	    (close-input-port in)
	    #t)
	#f))

; remove-crud-file :: string string -> void?
; Elimina archivo de configuración de funciones CRUD estándar y
; personalizadas haciendo distinción del archivo por su extensión.
; Retorna void?.
(define (remove-crud-file schema extfile)
    (define file (string-append crud-dir schema extfile))
    (if (file-exists? file)
	(delete-file file)
	(display "\nremove-crud-file: file does not exist.\n")))
	
; save-crud-file-a :: string string -> void?
; Inicia proceso de almacenamiento de las funciones CRUD estándar y
; personalizadas. Retorna void?.
(define (save-crud-file-a schema type)
    (define strtype (symbol->string type))
    (cond
	((string=? strtype "crud") (save-crud-file schema ".crud" vcrudg))
	((string=? strtype "crudp") (save-crud-file schema ".crudp" vcrudg-per))))
	
; prepare-data-crud :: string string string -> (listof list?)
; Toma expresión en cadena de caracteres proveniente del
; formulario de configuración de funciones CRUD creada por
; el usuario (Cadena de texto formateada en javascript) y la transforma
; en lista de listas. Retorna lista de listas.
(define (prepare-data-crud schema ntable datacrud)
    (define precrud (regexp-split #rx"%" datacrud))
    (define lstcrud (map (lambda (elemt)
			    (list schema ntable elemt))
			precrud))
    lstcrud)
  
; clean-crud :: string (listof list?) -> (listof list?)
; Elimina configuraciones de funciones CRUD de una tabla en especifico.
; Retorna lista de listas.
(define (clean-crud ntable lst)
    (if (empty? lst)
	'()
	(let* ((lsta (first lst))
	       (table (second lsta)))
	    (if (string=? table ntable)
		(clean-crud ntable (rest lst))
		(cons lsta (clean-crud ntable (rest lst)))))))
		
; add-crud :: (listof list?) -> (listof list?)
; Construye lista de configuraciones de funciones CRUD de una tabla 
; en especifico. Retorna lista de listas.
(define (add-crud lst)
    (if (empty? lst)
	vcrudg
	(cons (first lst) (add-crud (rest lst)))))
    
; modf-crud-aux :: string string (listof list?) -> void?
; Modifica lista de configuraciones de funciones CRUD, elimina y
; agrega nuevas configuraciones de una tabla en especifico.
; Retorna void?.
(define (modf-crud-aux schema ntable lstcrud)
    (set! vcrudg (clean-crud ntable vcrudg))
    (set! vcrudg (add-crud lstcrud)))

; modf-crud :: string string (listof list?) -> void?
; Modifica lista de configuraciones de funciones CRUD, si lista vcrudg 
; se encuentra vacia, se agregan las configuraciones, de lo contrario 
; se modifican. Retorna void?.
(define (modf-crud schema ntable lstcrud)
    (if (empty? vcrudg)
	(set! vcrudg lstcrud)
	(modf-crud-aux schema ntable lstcrud)))
	
; Construccion y edicion de estructura vcrudg-per
; -----------------------------------------------
; CRUD Personalizado
; -----------------------------------------------

; add-crud-per :: (listof list?) -> (listof list?)
; Construye lista de configuraciones de funciones CRUD personalizadas 
; de una tabla en especifico. Retorna lista de listas.
(define (add-crud-per lst)
    (if (empty? lst)
	vcrudg-per
	(cons (first lst) (add-crud-per (rest lst)))))
    
; modf-crud-per-aux :: string string (listof list?) -> void?
; Modifica lista de configuración de funciones CRUD personalizadas.
; Retorna void?.
(define (modf-crud-per-aux schema ntable lstcrud)
    (set! vcrudg-per (clean-crud ntable vcrudg-per))
    (set! vcrudg-per (add-crud-per lstcrud)))

; modf-crud-per :: string string (listof list?) -> void?
; Modifica lista de configuraciones de funciones CRUD personalizadas, si lista 
; vcrudg-per se encuentra vacía, se agregan las configuraciones, de lo contrario 
; se modifican. Retorna void?.
(define (modf-crud-per schema ntable lstcrud)
    (if (empty? vcrudg-per)
	(set! vcrudg-per lstcrud)
	(modf-crud-per-aux schema ntable lstcrud)))
	
; Filtrado y produccion de tabla (por ntable)
; filter-crud :: string (listof list?) -> (listof list?)
; Obtiene lista de configuraciones de funciones CRUD de una tabla en
; especifico. Retorna lista de listas.
(define (filter-crud ntable lst)
    (if (empty? lst)
	'()
	(let* ((lsta (first lst))
	       (table (second lsta)))
	    (if (string=? table ntable)
		(cons lsta (filter-crud ntable (rest lst)))
		(filter-crud ntable (rest lst))))))

; render :: (listof list?) -> list?
; Construye lista que representa el cuerpo de tabla dinamica de funciones CRUD 
; para una tabla en especifico. Retorna lista.
(define (render lst)
    (if (empty? lst)
	'()
	(let* ((lsta (first lst))
	       (data (third lsta)))
	    (cons `(tr (td (span ,data))) (render (rest lst))))))

; render-crud-table :: string -> list?
; Construye cuerpo de tabla dinamica de funciones CRUD para una tabla especifica
; del esquema. Retorna lista.
(define (render-crud-table ntable type)
    (define strtype (symbol->string type))
    (cond 
	((string=? strtype "crud") (render (filter-crud ntable vcrudg)))
	((string=? strtype "crud_per") (render (filter-crud ntable vcrudg-per)))))
	
; crud-per-text-aux :: string (listof list?) -> string
; Convierte lista de configuraciones de funciones CRUD personalizadas a cadena de texto
; separadas por el delimitador %. Retorna cadena de texto.
(define (crud-per-text-aux str lst)
    (if (empty? lst)
	str
	(let* ((lsta (first lst))
	       (data (third lsta)))
	    (if (string=? str "")
		(crud-per-text-aux data (rest lst))
		(crud-per-text-aux (string-append str "%" data) (rest lst))))))

; crud-per-text :: string -> string
; Filtra lista de configuraciones CRUD personalizadas por una tabla en especifico, y 
; convierte dicha lista en cadena de texto. Retorna cadena de texto.
(define (crud-per-text ntable)
    (crud-per-text-aux "" (filter-crud ntable vcrudg-per)))    
    
; Formateo de operaciones crud
; format-crud-data :: nothing -> void?
; Construye formato adecuado para cada función CRUD de cada tabla.
; Retorna lista de listas.
(define (format-crud-data)
    (set! vcrudg (format-sql (lst-split vcrudg))))
    
; format-crud-per-data :: nothing -> (listof list?)
; Construye lista de listas con formato adecuado para cada función CRUD
; personalizada. Retorna lista de listas.
(define (format-crud-per-data)
    (lst-split-esp vcrudg-per))
  
; crud-exist :: nothing -> boolean
; Verifica si existen configuraciones de funciones CRUD.
; Retorna #t si existen, #f en caso contrario.
(define (crud-exist)
    (if (not (empty? vcrudg))
	#t
	#f))
	
; crud-exist :: nothing -> boolean
; Verifica si existen configuraciones de funciones CRUD personalizadas.
; Retorna #t de si existen, #f en caso contrario.
(define (crud-per-exist)
    (if (not (empty? vcrudg-per))
	#t
	#f))

; clean-crud-data :: nothing -> void?
; Elimina datos de estructura de datos vcrudg.
; Relacionada con la lista de configuración de funciones CRUD.
; Retorna void?.
(define (clean-crud-data)
    (set! vcrudg (list))
    (set! vcrudg-per (list)))
    
; remove-only-table :: string -> void?
; Elimina configuraciones de funciones CRUD asociadas a una tabla en especifico.
; Retorna void?.
(define (remove-only-table str)
    (define ntable (first (rest (regexp-split #rx":" str))))
    (set! vcrudg (clean-crud ntable vcrudg)))

; remove-only-table-per :: string -> void?
; Elimina configuraciones de funciones CRUD personalizadas asociadas a una 
; tabla en especifico. Retorna void?.
(define (remove-only-table-per str)
    (define ntable (first (rest (regexp-split #rx":" str))))
    (set! vcrudg-per (clean-crud ntable vcrudg-per)))
	
(provide (all-defined-out))
