
#|
Estructura de tablas (De manipulacion)
--------------------
1 esquema
2 nombretabla

3 label 		
4 nombrecampo 
5 tipoelemt(text passwd checkbox radio textarea select select_date ...) 
6 restriccion(numerico alfabetico alfanumerico alfanumerico_simb_esp numerico_simb_esp) 
7 tamlogico
8 tamfisico
9 esnulable 
10 show

11 opciones
checkbox(value show value show)
radio(value show value show)
select(value show value show)

--------------------
(
	("empven" "empleado" "numdoc" "numdoc" "text" "numerico" 10 66 "NO" "t" ())
	("empven" "empleado" "nombre" "nombre" "text" "alfanumerico" 15 15 "NO" "t" ()) 
	("empven" "empleado" "apellidos" "apellidos" "text" "alfanumerico" 25 25 "NO" "t" ()) 
	("empven" "ventas" "numdoc" "numdoc" "text" "numerico" 10 66 "NO" "t" ())
	("empven" "ventas" "fecventa" "fecventa" "select_date" "alfanumerico" 15 15 "NO" "t" ()) 
	("empven" "ventas" "totalventa" "totalventa" "text" "alfanumerico" 25 25 "NO" "t" ())
)
--------------------- 

Estructura de tablas a mostrar (De vista)

1-Esquema - 2-nombretabla
4-nombrecampo 3-label 5-tipoelemt 6-restriccion 7-tamlogico 8-tamfisico 9-esnulable 10-show 11-opciones

|#

; ----------------------------------------------------------------------
; CONEXION A BD Y CREACION DE LISTA DE CONFIGURACION DE CAMPOS
; ----------------------------------------------------------------------

#lang racket

(require "conf.rkt")
(require "tablas.rkt")
(require "../almacenamiento-datos/conn.rkt")

; Directorio de herramienta CASE
;(define schema-dir "/home/hmc/Documentos/racket-proy/codegen/")

; Estructura de datos global que almacena temporalmente las propiedades de 
; los campos de la totalidad de las tablas de un esquema. 
; Lista de configuracion de campos global.
(define vcamposg (list))

; Estructura de datos global que almacena temporalmente los tipos de datos
; de los campos de cada una de las tablas pertenecientes a un esquema.
(define vcamposg-td (list))

; inic-campos :: string -> (listof list?)
; Consulta las propiedades de los campos de cada tabla de un esquema
; de base de datos, si exite archivo con esas configuraciones, las carga
; desde este, de lo contrario lo hace desde la base de datos.
; Retorna lista de listas.
(define (inic-vcampos schema)
	(if (not (inicializado))		
		(if (inicializar-conn)
			(load-data-tables schema)
			(display "\ninic-vcampos: No connect.\n"))
		(if (empty? vcamposg)
			(load-data-tables schema)
			(display "\ninic-vcampos: schema loaded.\n"))))
		
; lstvec-to-lst :: (listof vector?) -> (listof list?)
; Convierte lista de vectores en lista de listas.
(define (lstvec-to-lst lstvec)
	(if (empty? lstvec) 
		'()
		(cons (vector->list (first lstvec)) (lstvec-to-lst (rest lstvec)))))
	
; save-all-lst :: string (listof list?) -> void?
; Si vcamposg se encuentra vacío, se agrega lista de listas de propiedades de
; los campos de cada tabla, de lo contrario si vcamposg no se encuentra vacío,
; pero no tiene las propiedades de los campos de una tabla especifica, de 
; nuevo se agregan, en caso contrario, las propiedades de los campos de esa
; tabla ya existen. Retorna void?.
(define (save-all-lst table lst)
	(let ()
		(if (empty? vcamposg)
			(set! vcamposg (add-elemts lst))
			(if (not (exist-lst table vcamposg))
				(set! vcamposg (add-elemts lst))
				(printf "\nsave-all-lst: Tabla ~s ya existe.\n" table)))
	))
						
; add-elemts :: (listof list?) -> (listof list?)
; Construye lista de listas de las propiedades de los campos de cada tabla,
; sobre vcamposg. Retorna lista de listas.
(define (add-elemts lst)
	(if (empty? lst)
		vcamposg
		(cons (first lst) (add-elemts (rest lst)))))

; exist-lst :: string (listof list?) -> boolean
; Consulta si existen propiedades de los campos de tabla especificada en lista
; vcamposg. Si es asi, retorna #t, de lo contrario #f.
(define (exist-lst table lst)
	(if (empty? lst)
		#f
		(let* ((ltable (first lst))
			   (ntable (second ltable)))
			(if (string=? table ntable)
				#t
				(exist-lst table (rest lst))))))

; lst-conf :: (listof list?) -> (listof list?)
; Se toma lista de listas de las propiedades de los campos de cada tabla,
; generada inicialmente desde la base de datos y se complementan con otras 
; propiedades. Retorna lista de listas.
(define (lst-conf lsta)
	(if (empty? lsta)
		'()
		(let* ((lst 	(first lsta))
			   (schema 	(first lst))
			   (ntabla 	(second lst))
			   (ncampo	(third lst))
			   (label 	ncampo)
			   (tipoelemt (get-tipo-elemt (fourth lst)))
			   (restr 	"alfanumerico")
			   (taml 	(get-tam-elemt tipoelemt (fifth lst)))
			   (tamf 	taml)
			   (nulable (sixth lst))
			   (show 	"t"))
			(cons (list schema ntabla label ncampo tipoelemt restr
						taml tamf nulable show '()) (lst-conf (rest lsta))))))

; get-tipo-elemt :: string -> string
; Renombra tipos de datos de la base de datos a tipos de 
; datos utilizados en la herramienta. Retorna string.
(define (get-tipo-elemt elemt)
	(cond
		[(string=? elemt "character varying") "text"]
		[(string=? elemt "integer") "text"]
		[(string=? elemt "date") "select_date"]
		[else "text"]))

; get-tam-elemt :: string number -> string
; Establece tamaño adecuado para tipo de dato select_date,
; y tamaño por defecto para los demas elementos en caso
; de no estar establecido. Retorna string.
(define (get-tam-elemt tipoelemt tam)
	(cond
		[(string=? tipoelemt "select_date") "10"] ; 00/00/0000
		[else (if (number? tam) (number->string tam) "10")]))

; save-schema-file :: string -> void?
; Almacena en archivo schema.data los valores contenidos en vcamposg.
; Retorna void?.
(define (save-schema-file schema)
	(if (not (empty? vcamposg))
		(let* ((file (string-append schema-dir schema ".data"))
			    (out  (open-output-file file
					  #:mode 'binary
					  #:exists 'replace)))
			(write vcamposg out)
			(close-output-port out))
		(display "\nsave-schema-file: uncharged scheme. file was not created.\n")))
		
; get-schema-file :: string -> boolean
; Si archivo con nombre schema.data existe,
; carga lista vcamposg con los datos almacenados en este.
; Retorna #t si fue asi, #f si no existe archivo.
(define (get-schema-file schema)
	(define file (string-append schema-dir schema ".data"))
	(if (file-exists? file)
		(let* ((in (open-input-file file))
			    (data (read in)))
			(set! vcamposg data)
			(close-input-port in)
			#t)
		#f))

; Carga configuracion desde base de datos
; load-tables :: string -> empty list?
; Consulta campos y propiedades por cada tabla perteneciente al esquema,
; la lista de vectores se convierte en lista de listas, se crea lista de
; configuración de campos y se almacena en lista de listas vcamposg.
; Retorna lista vacía.
(define (load-tables schema)
	(if (null? schema)
		'()
		(let ((lst-tables (get-tablas schema)))
			(for/list ((ntable lst-tables))
				(save-all-lst ntable (lst-conf (lstvec-to-lst (get-campos schema ntable))))
				))))
				
; load-data-tables :: string -> (listof list?)
; Consulta campos y propiedades por cada tabla perteneciente al esquema,
; y crea estructura adecuada que almacena en vcamposg.
; Retorna lista de listas.
(define (load-data-tables schema)
	(if (not (get-schema-file schema))
		(load-tables schema)
		(display "\nload-data-tables: loaded from file.\n"))
	;(load-tables schema) ; tables loaded.
	vcamposg)

; get-vcamposg :: string string -> (listof list?)
; Obtiene lista de listas de propiedades de los campos de una tabla 
; especificada desde vcamposg. Retorna lista de listas.
(define (get-vcampos schema table)
	(if (or (null? schema) (null? table))
		'()
		(if (exist-lst table vcamposg)
			(let ((lst (get-lst table vcamposg)))
				lst)
			'())))
			;(get-vcampos schema table))))

; Obtenemos la lista de configuracion de campos de una tabla
; desde vcamposg.
; get-lst :: string (listof list?) -> (listof list?)
; Construye lista de listas de propiedades de los campos de una tabla 
; especificada desde vcamposg. Retorna lista de listas. 
(define (get-lst table lst)
	(if (empty? lst)
		'()
		(let* ((ltable (first lst))
			   (ntable (second ltable)))
			(if (string=? table ntable)
				(cons ltable (get-lst table (rest lst)))
				(get-lst table (rest lst))))))

; ----------------------------------------------------------------------
; MODIFICAR LISTA DE CONFIGURACION DE CAMPOS
; ----------------------------------------------------------------------

; Pequeño ajuste <<label de js queda de 4to en vcamposg
; al adicionar schema y nombretabla, modificando en este
; el nombre del campo y no el label inicialmente>>

; nombrecampo:label:tipoelemt:restriccion:taml:tamf:nulable:show:lstopc
; 1-Esquema - 2-nombretabla
; 4-nombrecampo 3-label 5-tipoelemt 6-restriccion 7-tamlogico 8-tamfisico 9-esnulable 10-show 11-opciones

; descp:descp:text:alfanumerico:10:10:NO:t:bad!&
; idciudad:idciudad:text:alfanumerico:7:7:NO:t:bad!&
; iddpto:iddpto:text:alfanumerico:6:6:NO:t:bad!

;#|
;(define (prepare-new-lst schema table str)
;  (define camplst (regexp-split #rx"&" str))
;  (define camp2lst (map (lambda (row)
;                         (let* ((fields (regexp-split #rx":" row))
;                                (opcs (last fields))
;                                (ropcs (real-opcs opcs)))
;                           (display fields)
;                           (append (append (list schema table) (drop-right fields 1)) (list ropcs)))) 
;                       camplst))
;  ;(display camp2lst)
;  camp2lst)
;|#

; Parsea expresion proveniente de tabla de configuración de campos a estructura de racket
; prepare-new-lst :: string string list? -> (listof list?)
; Toma expresión en cadena de caracteres proveniente de la tabla de 
; configuración de campos editada por el usuario (formateada en javascript) 
; y la transforma en lista de listas. Retorna lista de listas.
(define (prepare-new-lst schema table str)
  (define camplst (regexp-split #rx"&" str))
  (define camp2lst (map (lambda (row)
                         (let* ((fields (fix-fields (regexp-split #rx":" row))))
								(append (list schema table) fields)))
                       camplst))
  camp2lst)
  
; fix-fields :: list? -> (listof list?)
; Construye lista de listas de las propiedades de los campos de una tabla del
; esquema, con la información proveniente de la tabla de configuración de campos 
; editada por el usuario (formateada en javascript).
(define (fix-fields lst)
(let* ((nombrecampo	(first lst))
	  (label		(second lst))
	  (tipoelemt	(third lst))
	  (restriccion	(fourth lst))
	  (taml 		(fifth lst))
	  (tamf 		(sixth lst))
	  (nulable 		(seventh lst))
	  (show 		(eighth lst))
	  (opcs 		(last lst))
	  (ropcs 		(if (string=? opcs "") '() (real-opcs opcs))))
	(list label nombrecampo tipoelemt restriccion taml tamf nulable show ropcs)))
		
		
; real-opcs :: string -> (listof list?)
; Construye lista de listas de valores para las opciones que deben especificarse
; en los elementos select, checkbox o radio. Retorna lista de listas.
(define (real-opcs str)
  	(define opclst (regexp-split #rx"," str))
	(define opc2lst (map (lambda (row)
						(let* ((vs (regexp-split #rx"-" row)))
							vs)) 
					  opclst))
	opc2lst)
  
; Modificar tabla conf de campos (vcamposg)
; modf-lst :: string string (listof list?) -> void?
; Modifica las propiedades de los campos de una tabla especifica sobre
; vcamposg. Retorna void?.
(define (modf-lst schema table lst)
	(set! vcamposg (clean-lst table vcamposg))
	(set! vcamposg (add-elemts lst)))
	
; clean-lst :: string (listof list?) -> (listof list?)
; Elimina las propiedades de los campos de una tabla especifica sobre
; vcamposg. Retorna lista de listas.
(define (clean-lst table lst)
	(if (empty? lst)
		'()
		(let* ((ltable (first lst))
			   (ntable (second ltable)))
			(if (string=? table ntable)
				(clean-lst table (rest lst))
				(cons ltable (clean-lst table (rest lst)))))))

; flatten-lst :: (listof list?) -> list?
; Encargado de aplanar una lista de listas un nivel mas bajo.
; Retorna una lista.
(define (flatten-lst lst)
  (if (empty? lst)
      '()
      (let ((elemt (first lst)))
        (cond
          [(empty? elemt) (flatten-lst (rest lst))]
          [(list?  elemt) (append elemt (flatten-lst (rest lst)))]
          [else
           (cons elemt (flatten-lst (rest lst)))]))))

; get-campos-td-aux :: string -> (listof list?)
; Construye una lista de listas con los tipos de datos de los campos
; de cada una de las tablas del esquema especificado.
; Retorna una lista de listas.
(define (get-campos-td-aux schema)
	(for/list ((ntable (get-tablas-alm)))
		(lstvec-to-lst (get-tipodatos-campos schema ntable))))
		
; get-campos-td :: string -> (listof list?)
; Retorna lista de listas con los tipos de datos de los campos de las
; tablas de un esquema. Retorna una lista de listas.
(define (get-campos-td schema)
	(if (empty? vcamposg-td)
		(begin
			(set! vcamposg-td (get-campos-td-aux schema))
			(set! vcamposg-td (flatten-lst vcamposg-td))
			vcamposg-td)
		vcamposg-td))
		
; get-campo-td :: string string string -> list?
; Obtiene el tipo de dato de un campo para un esquema, tabla y nombre de campo
; especificado. Retorna lista.
(define (get-campo-td schema ntable field)
    (let loop ((lst vcamposg-td))
		(if (empty? lst)
			#f
			(let* ((sublst	(first lst))
				   (fschema	(first sublst))
				   (fntable	(second sublst))
				   (ffield	(third sublst))
				   (sfield  (symbol->string field)))
				(if (and (string=? schema fschema)
						 (string=? ntable fntable)
						 (string=? sfield ffield))
					sublst
					(loop (rest lst)))))))
				
; ----------------------------------------------------------------------
; IMPRESION DE LISTA DE CONFIGURACION DE CAMPOS EN HTML
; ----------------------------------------------------------------------

; Orden explicito en que se disponen en HTML
; El numero indica posicion en estructura Racket

; 1-Esquema - 2-nombretabla (No se disponen)
; 4-nombrecampo 3-label 5-tipoelemt 6-restriccion 7-tamlogico 8-tamfisico 9-esnulable 10-show 11-opciones

; Despliega tabla dinámica de configuración de campos
; render-vcampos-table-conf :: (listof list?) number -> list?
; Extrae cada valor de las propiedades de los campos de cada tabla
; y forma lista con elementos html <tr>, que forman la tabla de
; configuración de campos. Retorna lista.
(define (render-vcampos-table-conf lsta n)
	(if (empty? lsta)
		'()
		(let* ((lst 		(first lsta))
			   (schema 		(first lst))
			   (nombretabla (second lst))
			   (label 		(third lst))
			   (nombrecampo	(fourth lst))
			   (tipoelemt 	(fifth lst))
			   (restriccion (sixth lst))
			   (taml 		(seventh lst))
			   (tamf 		(eighth lst))
			   (nulable 	(ninth lst))
			   (show 		(tenth lst))
			   (opcs 		(last lst))
			   (alt 		(if (even? n) "alt" "")))
			;(render-opcs opcs)
			(cons 
				`(tr ((class ,alt)) 
				 (td ((class "thd")) (span ,nombrecampo))
				 (td (span ((onclick "edit_field(this, 'label');")) ,label))
				 (td (span ((onclick "edit_field(this, 'tipoelemt');")) ,tipoelemt))
				 (td (span ((onclick "edit_field(this, 'restriccion');")) ,restriccion))
				 (td (span ,(if (number? taml) (number->string taml) taml)))
				 (td (span ((onclick "edit_field(this, 'tamfisico');")) ,(if (number? tamf) (number->string tamf) tamf)))
				 (td (span ,nulable))
				 (td (span ((onclick "edit_field(this, 'show');")) ,show))
				 (td (span ((onclick "edit_field(this, 'opciones');")) ,(if (empty? opcs) "opciones" (render-opcs opcs)))))
					(render-vcampos-table-conf (rest lsta) (+ n 1))))))
				;)))))
				;(td "Guardar")) (render-vcampos-table-conf (rest lsta) (+ n 1))))))

; Convierte lista de los valores de las opciones en cadena de texto
; select, checkbox o radio.
; render-opcs :: (listof list?) -> string
; Convierte lista de los valores de las opciones en cadena de texto,
; para luego ser desplegados en la tabla de configuración de campos.
; Retorna string.
(define (render-opcs opcs)
  (if (empty? opcs)
      ""
      (let* ((elemt (first opcs))
             (name  (car elemt))
             (value (car (cdr elemt))))
             ;(str (string-append "[" name " " value "]")))
        (define str
          (if (empty? (rest opcs))
              (string-append "[" name " " value "]")
              (string-append "[" name " " value "],")))
        (string-append str (render-opcs (rest opcs))))))

; clean-campos-data :: nothing -> void?
; Elimina datos de estructura de datos vcampog.
; Relacionada con la lista de configuración de campos.
; Retorna void?.
(define (clean-campos-data)
	(set! vcamposg (list)))
				
(provide (all-defined-out))
