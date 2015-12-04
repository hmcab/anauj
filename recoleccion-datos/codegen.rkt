
#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch)
(require (planet neil/html-writing:2:0))
        
(provide/contract (start (request? . -> . response?)))

(require "../almacenamiento-datos/conn.rkt")
(require "../generacion-datos/tablas.rkt")
(require "../generacion-datos/campos.rkt")
(require "../generacion-datos/crud.rkt")
(require "../generacion-datos/generador.rkt")
(require "../generacion-datos/conf.rkt")

(require 2htdp/batch-io) 

; start :: request -> expr?/boolean
; Inicia conexión con base de datos y dirige la ejecución
; de la aplicación web a la página de inicio. Retorna expr?.
; En caso de no ser posible iniciar la base de datos retorna
; #f.
(define (start request)
    (if (not (inicializado))
        (let ((inic-app (inicializar-conn)))
            (if inic-app
                (codegen-dispatch request)
                #f))
        (codegen-dispatch request)))

; Reglas de despacho 
; codegen-dispatch :: url -> expr?
; Selecciona regla de despacho según pagina web solicitada por
; el usuario, perteneciente a la herramienta CASE.
; Retorna expresión.
(define-values (codegen-dispatch codegen-url)
    (dispatch-rules
        [("") codegen-login-tmp]
        [("login") codegen-login-tmp]
        [("register") codegen-register-tmp]
        [("codegen") codegen-login-tmp]))
        
; Reglas temporales de despacho
; codegen-login-tmp :: request -> expr?
; Especificacion de regla de despacho para pagina denominada login
; en herramienta CASE. Retorna expresion.
(define (codegen-login-tmp request)
    (codegen-login null request))

; codegen-register-tmp :: request -> expr?
; Especificacion de regla de despacho para pagina denominada register
; en herramienta CASE. Retorna expresion.
(define (codegen-register-tmp request)
    (codegen-register null request))
    
; ----------------------------------------------------------------------    
; Pagina regiter - Registro de usuario
; ----------------------------------------------------------------------

; codegen-register :: string request -> expr?
; Despliega pagina HTML de registro para la especificación
; de un nuevo usuario.
; Retorna expresion.
(define (codegen-register args request)
  (local [(define (response-generator embed/url)
	(response/xexpr
	    `(html (head (title "Codegen - Registro")
		    (style ((type "text/css")) ,(file->string (build-path "codegen.css") #:mode 'text))
		    (script ((type "text/javascript") (src "/codegen-start.js")) " "))
		(body
		  (div ((id "cont"))
		    (div ((id "header")) (h1 "Codegen - Registro"))
		    (div ((id "central"))
			(div ((id "formreg"))
			    (form ((id "freg") (method "post") (action ,(embed/url make-reg)))
				
				(span ((class "todo"))
				    (span ((class "titulo")) "Nombre")
				    (span ((class "entrada")) (input ((type "text") (id "nom") (name "nom") 
								(class "alfabetico") (onblur "checkRest(this);")))))
				    
				(span ((class "todo"))
				    (span ((class "titulo")) "Apellidos")
				    (span ((class "entrada")) (input ((type "text") (id "ape") (name "ape") 
								(class "alfabetico") (onblur "checkRest(this);")))))
				    
				(span ((class "todo"))
				    (span ((class "titulo")) "Correo electrónico")
				    (span ((class "entrada")) (input ((type "text") (id "email") (name "email") 
								(class "email") (onblur "checkRest(this);")))))
				
;				(span ((class "todo"))
;				    (span ((class "titulo")) "* Fecha de nacimiento")
;				    (span ((class "entrada"))))
				
				(span ((class "todo"))
				    (span ((class "titulo")) "Sexo")
				    (span ((class "entrada")) 
					(span ((id "entradain")) 
						(label (input ((type "radio") (id "sexo") (name "sexo") (value "F") 
							    (class "radio") (onblur "checkRest(this);")) "Femenino")))
					(span ((id "entradain")) (label (input ((type "radio") (id "sexo") 
						(name "sexo") (value "M") (class "radio")) "Masculino")))))
				
				(span ((class "todo"))
				    (span ((class "titulo")) "Contraseña")
				    (span ((class "entrada")) (input ((type "password") (id "pass") 
								(name "pass") (class "pass") (onblur "checkRest(this);")))))
				
				(span ((class "todo"))
				    (span ((class "titulo")) "Confirmar contraseña")
				    (span ((class "entrada")) (input ((type "password") (id "cpass") (name "cpass") 
								(class "cpass") (onblur "checkRest(this);")))))
				    
				(div ((id "divmsg")) ,(if (not (null? args)) args ""))
				
				(span ((class "envio")) (input ((type "button") (value "Registrar") (onclick "registrar();"))))))

			(a ((href "/login")) "Iniciar sesión")))))))
             
	    ; make-reg :: request -> expr?
	    ; Captura información de registro especificada por el usuario e
	    ; inicia proceso de almacenamiento. Retorna expresión.
            (define (make-reg request)
                (define bind (request-bindings request))
                (define nom (extract-binding/single 'nom bind))
                (define ape (extract-binding/single 'ape bind))
                (define email (extract-binding/single 'email bind))
		;(define fecnac (extract-binding/single 'fecnac bind))
                (define sexo (extract-binding/single 'sexo bind))
                (define pass (extract-binding/single 'pass bind))
                (define cpass (extract-binding/single 'cpass bind))
                (define rs (insert-new-user email nom ape sexo pass cpass))
		(define rsb (insert-relation email "empven" "estmat"))
		(if (and (match-correct rs) (match-correct rsb))
			(codegen-login rs request)
			(if (not (match-correct rs))
				(codegen-register rs request)
				(codegen-register rsb request))))
                ;(codegen-register rs request))
        ]
	(send/suspend/dispatch response-generator)))

(define (match-correct exp)
	(if (regexp-match? #px"801:" exp)
		#t
		#f))

; ----------------------------------------------------------------------    
; Pagina login - Login de usuario
; ----------------------------------------------------------------------

; Identificar si usuario ya inicio sesion,
; Para desplazarlo a pagina principal.
; codegen-login :: string request -> expr?
; Despliega pagina HTML para la autenticación e ingreso del
; usuario a la herramienta CASE. Retorna expresion.
(define (codegen-login args request)
 (define auth-data (auth request))
 (if auth-data ; Si ya se inicio sesion
    (let ((id     (first auth-data))
	  (schema (second auth-data))
	  (ntable (third auth-data)))
       ; Redireccionamos a pagina principal (codegen-index id schema ntable)
     (codegen-index id schema ntable request))
     (local [(define (response-generator embed/url)
	      (response/xexpr
	       `(html (head (title "Inicio de sesión")
			 (style ((type "text/css")) ,(file->string (build-path "codegen.css") #:mode 'text))
			 (script ((type "text/javascript") (src "/codegen-start.js")) " "))
		    (body
		      (div ((id "cont"))
			 
			(div ((id "head"))
			    (h1 "Codegen"))
				    
			(div ((id "central"))
			  (div ((id "formlogin"))
			    (form ((id "flogin") (method "post") (action ,(embed/url make-login)))
				
				(span ((class "todo"))
				  (span ((class "titulo")) "Correo electrónico")
				    (span ((class "entrada")) (input ((id "user") 
					    (name "user") (type "text") (maxlength "32")))))
				
				(span ((class "todo"))  
				  (span ((class "titulo")) "Contraseña")
				    (span ((class "entrada")) (input ((id "pass") 
					    (name "pass") (type "password") (maxlength "32")))))
	       
				(span ((class "todo"))
				  (span ((class "titulo")) "Esquema de base de datos")
				    (span ((class "entrada")) ,(make-select (select-schema))))
						 
				(div ((id "divmsg")) ,(if (not (null? args)) args "")) ; Mensaje de respuesta.
				
				(span ((class "envio" )) 
				    (input ((type "button") (value "Iniciar sesión") (onclick "iniciar();")))))))
				    
			(p "Si aún no estas registrado, haz tu registro " (a ((href "/register")) "aquí."))
		    )))))

	    ; Iniciar sesion.
	    ; make-login :: request -> expr?
	    ; Captura datos especificados por el usuario necesarios para iniciar sesión, comprueba
	    ; su autenticidad ante la base de datos, y de ser correcto crea cookies para la sesión y
	    ; redirecciona al usuario a la pagina principal. De lo contrario no inicia sesión y 
	    ; advierte al usuario a través de un mensaje de error. Retornar expresión.
	    (define (make-login request)
	    (define bind (request-bindings request))
	    (define user (extract-binding/single 'user bind))
	    (define pass (extract-binding/single 'pass bind))
	    (define schema (extract-binding/single 'schema bind))
	    (if (and (not (string=? user ""))
		     (not (string=? pass ""))
		     (not (string=? schema "")))
		(let ()
		    (define exist_user (login-check-user user pass))
		    (define exist_schema (login-check-schema user schema))
		    (define myschema (login-check-schema-inbd schema))
		    (define mytable (get-tablas schema))
		    (if (and exist_user exist_schema)
			(if (and (not (boolean? myschema)) (string=? myschema schema) (not (empty? mytable)))
			    ; Si datos de usuario especificados son correctos, 
			    ; el esquema de base de datos existe y se encuentra asociado, 
			    ; creamos cookies y redirigimos a pagina principal
			    (if (not (login-app))
				(let ()
				    (set-login-app #t)
				    (make-auth-cookie-then-redirect-to user myschema (first mytable) "/codegen"))
				(codegen-login "Aplicación en uso." request))
			    ; Esquema no existe en la base de datos
			    (codegen-login error-02 request))
			(if (not exist_schema)
			    ; Esquema no se encuentra relacionado
			    (codegen-login error-04 request)
			    ; Usuario y/o contraseña incorrecto
			    (codegen-login error-01 request))
		    ))
		; No hubo especificación de campos
		(codegen-login error-03 request)))
	] 
	(send/suspend/dispatch response-generator)
	)))

; make-options :: string -> expr?
; Crea elemento HTML option. 
; Retorna expresión.
(define (make-options elemt)
    `(option ((value ,elemt)) ,elemt))
            
; make-select :: list? -> expr?
; Crea elemento HTML select con los valores de la lista como opciones.
; Retorna expresión.
(define (make-select lst)
    `(select ((id "schema") (name "schema")) (option ((value "")) "") ,@(map make-options lst)
	(option ((value "invalido")) "invalido")
    ))
    
; ----------------------------------------------------------------------------------    
; Pagina index - Configuracion grafica del esquema (tablas, campos, funciones CRUD)
; ----------------------------------------------------------------------------------

; codegen-index string string string request -> expr?
; Despliega pagina principal de la herramienta CASE. Lista tablas del esquema,
; crea tabla de configuración de campos, tabla de funciones CRUD y formulario 
; de configuración de funciones CRUD.
; Retorna expresión. 
(define (codegen-index id schema ntable request)
    (define auth-data (auth request))
    (if auth-data
	(let ()
	    (inic-vcampos schema)
	    (define vtablas (get-vtablas schema))
	    (define vcampos (get-vcampos schema ntable))
	    (define act-table (active-table ntable))
	    (get-campos-td schema)
	    
	    (local [(define (response-generator embed/url)
		(response/xexpr
		 `(html (head 
		    (title "Index")
		    (style ((type "text/css")) ,(file->string (build-path "codegen.css") #:mode 'text))
		    (script ((type "text/javascript") (src "/codegen.js")) " ")
		    (script ((type "text/javascript") (src "/codegen-tablaconf.js")) " ")
		    (script ((type "text/javascript") (src "/codegen-crudform.js")) " ")
		    (script ((type "text/javascript") (src "/codegen-crudpers.js")) " ")
		    (script ((type "text/javascript") (src "/codegen-settable.js")) " "))
		    (body ((onload "init();") (onclick "show_comps('body');")) ;(onclick "show_menu_float('body');"))
		    
			; Menu de control e información de sesión
			(div ((id "div_session"))
			    
			    ; Form para guardar en archivo esquema gráfico configurado (de todas las tablas)
			    ; Configuración de campos
			    (form ((id "fschema") (method "post") (action ,(embed/url save-schema)))
				(input ((type "button") (id "savebutton") (name "savebutton") (value "save") (onclick "save_schema();"))))
		
			    ; Form para guardar configuración de funciones CRUD (de todas las tablas)
			    (form ((id "fcrud") (method "post") (action ,(embed/url save-crud)))
				(input ((type "hidden") (name "datacrud") (id "datacrud")))
				(input ((type "button") (name "savecrud") (id "savecrud") (value "save crud") (onclick "save_crud_in_file();"))))
				
			    ; Form para guardar configuración de funciones CRUD personalizadas
			    (form ((id "fcrudp") (method "post") (action ,(embed/url save-crud-per)))
				(input ((type "hidden") (name "datacrudp") (id "datacrudp"))))
			     
			     ; Form para generar archivos de aplicativo
			    (form ((id "fapp") (method "post") (action ,(embed/url export-app)))
				(input ((type "button") (id "appbutton") (name "appbutton") (value "export app") (onclick "export_app();"))))

			    ; Form para ejecución de la aplicación prototipo
			    (form ((id "fexec") (method "post") (action ,(embed/url exec-app)))
				(input ((type "button") (id "execbutton") (name "execbutton") (value "+ exec app") (onclick "exec_app();"))))
			    
			    ; Boton de información
			    (div ((id "div_info_barra")) (button ((class "info") (onclick "show_info('info_barra');"))) "")
			    
			    ; Boton para despliegue de menu flotante (Información de usuario/sesión)
			    (div ((id "div_pulse")) (button ((id "userbutton") (onclick "show_menu_float('elemt');")) ""))
			)
				
			; Menú flotante (Información de usuario/sesión)
			; Cierre de sesión
			(div ((id "menufloat") (style "display:none"))
			    (div ((class "dropdown-header header-nav-current css-truncate"))
				"Sesión iniciada como " (strong ,id)) ;(strong "Hector M"))
			    (div ((class "dropdown-divider")) "")
			    (form ((id "flogout") (method "post") (class "logout-form") (action ,(embed/url logout)))
				(button ((class "dropdown-item dropdown-signout")) "Salir")))
			    
			(div ((id "div_contenido"))
			
			; Listado de tablas del esquema    
			,(if (and (list? vtablas) (> (length vtablas) 1))
			    `(div ((id "div_tablas")) 
				,(render-tablas "ul_tablas" "Codegen" "info" vtablas))
			    "Ninguna tabla encontrada.")
			
			; Titulos (Nombre de esquema y tabla)
			,(if (and (not (empty? schema)) (not (empty? ntable)))
			    `(div ((id "div_titulo")) 
				(span ((class "esqtab")) 
				    (span ((class "stitulo")) "Esquema") 
				    (span ((id "spanschemav") (class "svalor")) ,schema))
				(span 
				    (span ((class "stitulo")) "Tabla") 
				    (span ((id "spanntablev") (class "svalor")) ,ntable)))
			    "Ningún esquema encontrado.")
		    
			; Botón de encendido/apagado para incorporación de una tabla
			; en la generación de código fuente y funciones CRUD asociadas
			(div ((id "div_titulo_enc") (class "stitulo")) "Generar tabla")
			(div ((id "div_encendido"))
			    (form ((id "ftable") (method "post") (action ,(embed/url set-table)))
				(input ((type "hidden") (id "settable") (name "settable"))))
				(div ((id "bar") (class ,act-table))				    
				    (div ((id "side_left")) (span ((id "label")) ,act-table))
				    (div ((id "side_right")) (button ((id "button") (onclick "change_state_bar();"))))))
				    
			(div ((id "div_info_acttabla"))
			    (button ((class "infog") (onclick "show_info('info_acttabla');")) ""))
			    
			; Mensajes de error
			(div ((id "div_msgerror") (name "div_msgerror")) "")
			
			; Tabla de configuración para tabla actual del esquema de base de datos
			,(if (not (empty? vcampos))
			    `(div ((id "div_campos"))
				(table ((id "table_campos") (border "1")) 
				    (thead
					(th "Nombre de campo"	(button ((class "infog in_table") (onclick "show_info('info_tabconf');")) ""))
					(th "Etiqueta" 		(button ((class "infog in_table") (onclick "show_info('info_label');")) ""))
					(th "Tipo de elemento"	(button ((class "infog in_table") (onclick "show_info('info_te');")) ""))
					(th "Restricción"	(button ((class "infog in_table") (onclick "show_info('info_rest');")) ""))
					(th "Tam. lógico")
					(th "Tam. físico"	(button ((class "infog in_table") (onclick "show_info('info_tamfis');")) ""))
					(th "Nulable")
					(th "Mostrar"		(button ((class "infog in_table") (onclick "show_info('info_mostrar');")) ""))
					(th "Lista de opciones"	(button ((class "infog in_table") (onclick "show_info('info_lstopc');")) "")))
				    (tbody ,@(render-vcampos-table-conf vcampos 1))))
			    `(div ((id "div_campos")) "Ningun campo encontrado."))
			     
			; Form para obtención de (tabla de configuración) de la tabla del esquema
			; de base de datos seleccionada
			(form ((id "ftablas") (method "post") (action ,(embed/url make-table)))
			    (input ((type "hidden") (id "ntabla") (name "ntabla") (value ""))))
			    
			
			(div ((id "div_form"))
			    
			    ; Form para modificación de la tabla de configuración de campos
			    (form ((id "fmtablas") (method "post") (action ,(embed/url modf-table)))
				(input ((type "hidden") (id "nmtabla") (name "nmtabla")))
				(input ((type "hidden") (id "dmtabla") (name "dmtabla")))
				(input ((type "button") (id "mtabla") (name "mtabla") (value "Guardar") (onclick "modf_table();"))))
			    (button ((class "infog in_form") (onclick "show_info('info_guaconf');")) "")
			    
			    ; Form para visualización de tabla de campos configurada
			    (form ((id "fvtablas") (method "post") (action ,(embed/url view-table)))
				(input ((type "button") (id "vtabla") (name "vtabla") (value "Visualizar") (onclick "view_table();"))))
			    (button ((class "infog in_form") (onclick "show_info('info_visconf');")) "")
			)
			
			; Tabla auxiliar para las configuraciones de funciones CRUD
			,(if (and (get-crud-file schema) (not (empty? vcrudg)))
			    `(div ((id "div_tabla_aux"))
				(table ((id "tabla_crud_aux") (border "1"))
				    (thead (th "data"))
				    (tbody
					,@(render-crud-table ntable 'crud))))
			    "")
			
			; Tabla auxiliar para las configuraciones de funciones CRUD
			; personalizadas
			,(if (and (get-crud-per-file schema) (not (empty? vcrudg-per)))
			    `(div ((id "div_crud_per")) ,(crud-per-text ntable))
			    `(div ((id "div_crud_per")) ""))
			
			(div ((id "div_tabla"))
			    (table ((id "tabla_crud") (border "1")) ""))
			(div ((id "div_tabla_per"))
			    (table ((id "tabla_crud_per") (border "1")) ""))
			
			; Formulario para generación y configuración de funciones CRUD
			,(render-crud-index schema ntable vcampos)
			
			; Formulario para generación y configuración de funciones CRUD personalizadas
			,(render-crud-per-index schema ntable vcampos)
			
			) ; div_contenido
			
			; Contenedores de los mensajes de información
			(div ((id "info_tablas")	(name "info_case") (class "info_case") (style "display:none")) ,info-tablas)
			(div ((id "info_tabconf")	(name "info_case") (class "info_case") (style "display:none")) ,info-tabconf)
			(div ((id "info_label")		(name "info_case") (class "info_case") (style "display:none")) ,info-label)
			(div ((id "info_te")		(name "info_case") (class "info_case") (style "display:none")) ,info-te)
			(div ((id "info_rest")		(name "info_case") (class "info_case") (style "display:none")) ,info-rest)
			(div ((id "info_tamfis")	(name "info_case") (class "info_case") (style "display:none")) ,info-tamfis)
			(div ((id "info_mostrar")	(name "info_case") (class "info_case") (style "display:none")) ,info-mostrar)
			(div ((id "info_lstopc")	(name "info_case") (class "info_case") (style "display:none")) ,info-lstopc)
			(div ((id "info_guaconf")	(name "info_case") (class "info_case") (style "display:none")) ,info-guaconf)
			(div ((id "info_visconf")	(name "info_case") (class "info_case") (style "display:none")) ,info-visconf)
			(div ((id "info_confcrud")	(name "info_case") (class "info_case") (style "display:none")) ,info-confcrud)
			(div ((id "info_nomproc")	(name "info_case") (class "info_case") (style "display:none")) ,info-nomproc)
			(div ((id "info_camposcrud")	(name "info_case") (class "info_case") (style "display:none")) ,info-camposcrud)
			(div ((id "info_restcrud")	(name "info_case") (class "info_case") (style "display:none")) ,info-restcrud)
			(div ((id "info_conlogcrud")	(name "info_case") (class "info_case") (style "display:none")) ,info-conlogcrud)
			(div ((id "info_conlogcrudg")	(name "info_case") (class "info_case") (style "display:none")) ,info-conlogcrudg)
			(div ((id "info_guacrud")	(name "info_case") (class "info_case") (style "display:none")) ,info-guacrud)
			(div ((id "info_acttabla")	(name "info_case") (class "info_case") (style "display:none")) ,info-acttabla)
			(div ((id "info_barra")		(name "info_case") (class "info_case") (style "display:none")) ,info-barra)
			
			(div ((id "info_crudper")		(name "info_case") (class "info_case") (style "display:none")) ,info-crudper)
			(div ((id "info_crudper_defsql")	(name "info_case") (class "info_case") (style "display:none")) ,info-crudper-defsql)
			
		    ) ; body
		))) ; response-generator
		    
		; Funciones para formularios
		
		; make-table :: request -> expr?
		; Carga pagina principal con tabla del esquema de base de datos
		; seleccionada por el usuario.
		; Retorna expresión.
		(define (make-table request)
		    (define bind (request-bindings request))
		    (define changetable (extract-binding/single 'ntabla bind))
		    (codegen-index id schema changetable request))
		
		; modf-table [En estructura racket]
		; modf-table :: request -> expr?
		; Captura nombre de tabla, configuración de campos
		; y modifica estructura de datos para almacenar la nueva información.
		; Retorna expresión.
		(define (modf-table request)
		    (define bind (request-bindings request))
		    (define nmtabla (extract-binding/single 'nmtabla bind)) ; Nombre de la tabla
		    (define dmtabla (extract-binding/single 'dmtabla bind)) ; Datos de configuración de campos
		    (define newlst (prepare-new-lst schema nmtabla dmtabla)) ; Prepara los nuevos datos
		    (modf-lst schema nmtabla newlst) ; Modifica estructura de datos de racket
		    (codegen-index id schema ntable request))
		    
		; save-schema [En archivo]
		; save-schema :: request -> expr?
		; Almacena en archivo las configuraciones de los campos
		; de la totalidad de las tablas.
		; Retorna expresión.
		(define (save-schema request)
		    (save-schema-file schema)
		    (codegen-index id schema ntable request))
		    
		; save-crud [En estructura racket y archivo]
		; save-crud :: request -> expr?
		; Captura configuración de función CRUD especificada, 
		; modifica estructura de datos y almacena en archivo funciones CRUD
		; de la totalidad de las tablas incluyendo la modificación previa.
		; Retorna expresión.
		(define (save-crud request)
		    (define bind (request-bindings request))
		    (define datacrud (extract-binding/single 'datacrud bind))		    
		    (let ()
			(if (match-remove-crud datacrud)
			    (remove-only-table datacrud)
			    (let ((newcrud (prepare-data-crud schema ntable datacrud)))
				(modf-crud schema ntable newcrud)))
			(save-crud-file-a schema 'crud))
		    (codegen-index id schema ntable request))
		
		; save-crud-per :: request -> expr?
		; Captura configuración de función CRUD personalizada, modifica
		; estructura de datos y almacena en archivo la totalidad de las
		; funciones CRUD personalizadas incluyendo la modificación previa.
		; Retorna expresión.
		(define (save-crud-per request)
		    (define bind (request-bindings request))
		    (define datacrudp (extract-binding/single 'datacrudp bind))
		    (let ()
			(if (match-remove-crud-per datacrudp)
			    (remove-only-table-per datacrudp)
			    (let ((newcrud (prepare-data-crud schema ntable datacrudp)))
				(modf-crud-per schema ntable newcrud)))
			(save-crud-file-a schema 'crudp))
		    (codegen-index id schema ntable request))
		    
		; export-app :: request -> expr?
		; Genera archivos de código fuente de aplicación prototipo,
		; en base a las configuraciones de campos y funciones CRUD
		; especificadas. Retorna expresión.
		(define (export-app request)
		    (if (not (empty? (get-tables)))
			(let ()
			    (create-app-file schema (get-tables))
			    (create-crud-file schema) 
			    (create-view-file schema)
			    (codegen-index id schema ntable request))
			(codegen-index id schema ntable request)))

		; Ejecuta aplicación prototipo
		; exec-app :: request -> expr?
		; Inicia servidor web y aplicación web prototipo previamente generada,
		; a la espera de peticiones del usuario.
		; Retorna expresión.
		(define (exec-app request)
		    (yes-exec-app schema)
		    (codegen-index id schema ntable request))
		    
		; set-table :: request -> expr?
		; Activa o desactiva tabla del esquema de base datos.
		; De acuerdo a su estado, se genera código fuente
		; asociado. Retorna expresión.
		(define (set-table request)
		    (define bind (request-bindings request))
		    (define thistable (extract-binding/single 'settable bind))
		    (modf-tables thistable) ; ntable:on||off
		    (codegen-index id schema ntable request))
		    
		; view-table :: request -> expr?
		; Despliega visualmente las configuraciones de campos
		; hecha a la tabla seleccionada. Retorna expresión.
		(define (view-table request)
		    (codegen-vista id schema ntable request))
		    
		; logout :: request -> expr?
		; Cierra sesión del usuario, elimina datos de las estructuras
		; y cookies relacionadas.
		; Retorna expresión.
		(define (logout request)
		    (clean-tablas-data)
		    (clean-campos-data)
		    (clean-crud-data)
		    (yes-kill-app schema)
		    (set-login-app #f)
		    (del-auth-cookie-then-redirect-to id schema ntable "/codegen"))
		]
		(send/suspend/dispatch response-generator)
	))
	; Se regresa a página de inicio de sesión en caso de que los
	; datos de autenticación no sean correctos.
	(codegen-login null request)))
	
; match-remove-crud :: string -> boolean
; Verifica si cadena de texto entrante contiene el valor
; "remove_crud_table", para dar inicio a la eliminación
; de las configuraciones de funciones CRUD especificas de 
; una tabla. Retorna #t si es así, #f en caso contrario.
(define (match-remove-crud str)
    (if (regexp-match? #px"remove_crud_table:" str)
	#t
	#f))
	
; match-remove-crud-per :: string -> boolean
; Verifica si cadena de texto entrante contiene el valor
; "remove_crud_per_table", para dar inicio a la eliminación
; de las configuraciones de funciones CRUD personalizadas
; especificas de una tabla. Retorna #t si es así, #f en caso
; contrario.
(define (match-remove-crud-per str)
    (if (regexp-match? #px"remove_crud_per_table:" str)
	#t
	#f))

;(define cmd "racket -t /home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/apps/")

; kill :: string -> boolean
; Detiene ejecución de aplicación web prototipo previamente
; iniciada con procedimiento yes-exec-app. Retorna #t si 
; instrucción a través de system se ejecutó con éxito, #f en caso contrario.
(define (kill app)
    (define kill-app (string-append "kill -9 $(pgrep -f \"" app "\")"))
    (system kill-app))

; yes-exec-app :: string -> list?
; Inicia ejecución de aplicación web prototipo, en caso
; de haber sido ya iniciada, cierra e inicia un nuevo
; proceso de ejecución. Retorna una lista.
(define (yes-exec-app sch)
    (define app (string-append cmd sch "/" sch "-app.rkt"))
    (kill app)
    (process app))
    
; yes-kill-app :: string -> boolean
; Inicia la detención de aplicación web prototipo previamente
; inicializada. Retorna #t si se detuvo la aplicación,
; #f en caso contrario.
(define (yes-kill-app sch)
    (define app (string-append cmd sch "/" sch "-app.rkt"))
    (kill app))
	
; render-tablas :: string string string list? -> expr?
; Despliega gráficamente las tablas pertenecientes al
; esquema de base de datos. Retonar expresión.
; Basa su despliegue en el elemento HTML ul.
; Retorna expresión.
(define (render-tablas idt str1 str2 lst)
    (elemt-ul idt (cons str1 (cons str2 (rest lst)))))
	
; elemt-ul :: string list? -> expr?
; Crea elemento HTML ul con subelementos li para los valores
; de la lista. Retorna expresión.
(define (elemt-ul idt lst)
    `(ul ((id ,idt)) ,@(map elemt-li lst)))

; elemt-li :: string -> expr?
; Crea elemento HTML li para valor especificado.
; Retorna expresión.
(define (elemt-li elemt)
    (cond 
	[(string=? elemt "Codegen") `(li ((id "li_logo")) "Codegen")]
	[(string=? elemt "info") `(li ((id "li_info")) (button ((class "info") (onclick "show_info('info_tablas');")) ""))]
        [else `(li (a ((href "#") (onclick "make_table(this);") (id ,elemt) (name ,elemt)) ,elemt))]))

; ---------------------------------------------------------------------
; Formulario de configuracion de funciones CRUD
; ---------------------------------------------------------------------

; render-crud-index :: string string (listof list?) -> expr?
; Despliega formulario de configuración de funciones CRUD.
; Retorna expresión.
(define (render-crud-index schema ntable vcampos)
   `(div ((id "sql_generator"))
        (div ((id "div_funcion"))
            (span "Función SQL:")
            (select ((id "funcionsql") (onchange "seleccion_funcion();"))
                (option ((value "")) "")
                (option ((value "INSERT")) "Insert")
                (option ((value "SELECT")) "Select")
                (option ((value "UPDATE")) "Update")
                (option ((value "DELETE")) "Delete"))
	    (button ((class "infog in_crud") (onclick "show_info('info_confcrud');")) ""))
        (div ((id "div_create"))
            (input ((type "hidden") (id "nschema") (name "nschema") (value ,schema))) 
            (input ((type "hidden") (id "ntable") (name "ntable") (value ,ntable))) 
            
            (span "Nombre del procedimiento:")
            (input ((type "text") (id "nprocd") (name "nprocd")))
	    (button ((class "infog in_crud") (onclick "show_info('info_nomproc');")) "")
	    
	    (div ((id "msg_cruderror") (name "msg_cruderror")) "")
	    
            (div ((id "div_campos_normal"))
                (span "Campos" (button ((class "infog in_crud") (onclick "show_info('info_camposcrud');")) ""))
                (div ((id "campos"))
                    ,@(render-vcampos-list vcampos)
                )
                (div ((id "div_buttons_campos"))
                    (input ((type "button") (onclick "addcampo();") (value "agregar")))
                    (input ((type "button") (onclick "remcampo();") (value "quitar")))))
            (div ((id "div_campos_rest"))
                (span "Restricciones" (button ((class "infog in_crud") (onclick "show_info('info_restcrud');")) ""))
                (div ((id "camposr"))
                    ,@(render-vcampos-list vcampos)
                )
                (div ((id "div_conector"))
                    (span "Conector lógico:" (button ((class "infog in_crud") (onclick "show_info('info_conlogcrud');")) ""))
                    (label (input ((type "radio") (id "connt") (name "connt") (value "AND")) "AND"))
                    (label (input ((type "radio") (id "connt") (name "connt") (value "OR")) "OR")))
                (div ((id "div_buttons_rests"))
                    (input ((type "button") (onclick "addrestriccion();") (value "agregar")))
                    (input ((type "button") (onclick "remrestriccion();") (value "quitar")))))
	    (div ((id "div_conector_global"))
		(span "Conector lógico global:")
		    (select ((id "conntg") (onclick "setconntg();"))
			(option ((value "")) "")
			(option ((value "AND")) "AND")
			(option ((valule "OR")) "OR"))
		(button ((class "infog in_crud") (onclick "show_info('info_conlogcrudg');")) ""))
            (div ((id "div_sql"))
                (span "Prototipo SQL:")(br)
                (textarea ((id "sql_text") (cols "64") (rows "8") (spellcheck "false")) "")
                (input ((type "button") (onclick "save_sql();") (value "Guardar")))
                (input ((type "button") (onclick "cancel_sql();") (value "Cancelar")))
		(button ((class "infog in_crud") (onclick "show_info('info_guacrud');")) "")))
    ))
    
; render-vcampos-list :: (listof list?) -> list?
; Despliega elemento HTML checkbox para cada uno de los campos
; de la tabla del esquema de base de datos y los enlista. 
; Retorna lista.
(define (render-vcampos-list lsta)
    (if (empty? lsta)
	'()
	(let* ((lst (first lsta))
	       (nombrecampo (fourth lst)))
		(cons
		    `(label (input ((type "checkbox") (id "campo") (name "campo") (value ,nombrecampo)) ,nombrecampo))
			(render-vcampos-list (rest lsta))))))

; -----------------------------------------
; FUNCION CRUD PERSONALIZADA
; -----------------------------------------

; render-crud-per-index :: string string (listof list?) -> expr?
; Despliega formulario de configuración de funciones CRUD personalizadas.
; Retorna expresión.
(define (render-crud-per-index schema ntable vcampos)
    (define schtb   (string-append schema "." ntable))
    (define lcampos (render-vcampos-listtext "" vcampos))
    (set!   lcampos (string-append lcampos "," schtb))
    (define lsql "insert into,select,update,where,from,values,set,delete from")
    
    `(div ((id "sql_generator_per"))
	(div ((id "div_funcion_per"))
	    (span "Función SQL personalizada:")
	    (input ((type "button") (onclick "mostrar_componente_per('div_create_per',true);") (value "")))
	    (button ((class "infog in_crud") (onclick "show_info('info_crudper');")) ""))
	(div ((id "div_create_per"))
	    (input ((type "hidden") (id "nschema_per") (name "nschema_per") (value ,schema)))
            (input ((type "hidden") (id "ntable_per") (name "ntable_per") (value ,ntable))) 
	    (input ((type "hidden") (id "lst_campos") (name "lst_campos") (value ,lcampos)))
	    (input ((type "hidden") (id "lst_sql") (name "lst_sql") (value ,lsql)))
	    (input ((type "hidden") (id "fsql_per") (name "fsql_per")))
	    
	    (span ((class "pos")) "Nombre del procedimiento:")
	    (input ((type "text") (id "nprocd_per") (name "nprocd_per")))
	    (button ((class "infog in_crud") (onclick "show_info('info_nomproc');")) "")
	    
	    (div ((id "msg_crudper_error") (name "msg_crudper_error")) "")
	    
	    (div ((id "div_campos_text"))
		(span ((class "pos")) "Lista campos:")
		(textarea ((id "lcampos") (cols "64") (rows "3") (class "crud_per") (spellcheck "false")) ""))
	    
	    (div ((id "div_rests_text"))
		(span ((class "long")) "Lista campos en restricciones:")(br)
		(textarea ((id "lrest") (cols "64") (rows "3") (class "crud_per") (spellcheck "false")) ""))
	    
	    (div ((id "div_sql_text"))
		(div ((id "div_defsql"))
		    (span ((class "long")) "Definición de instrucción SQL:")
		    (span ((class "simple")) (label (input ((type "checkbox") (id "updel") (name "updel") 
						(onclick "activar_updel(this);")) "Usar update para invalidar")))
			(button ((class "infog in_crud") (onclick "show_info('info_crudper_defsql');")) ""))
		    (div ((id "lstmatch") (name "lstmatch")) "")		
		(textarea ((id "lsql") (cols "64") (rows "8") (class "crud_per") (spellcheck "false")) "")
		(input ((type "button") (onclick "save_sql_per();") (value "Guardar")))
                (input ((type "button") (onclick "cancel_sql_per();") (value "Cancelar")))
		(button ((class "infog in_crud") (onclick "show_info('info_guacrud');")))))))
	
; render-vcampos-listtext :: string (listof list?) -> string
; Convierte lista de elementos en una cadena
; de texto. Retorna cadena de texto.
(define (render-vcampos-listtext str lsta)
    (if (empty? lsta)
	str
	(let* ((lst (first lsta))
	       (ncampo (fourth lst)))
	    (if (string=? str "")
		(render-vcampos-listtext ncampo (rest lsta))
		(render-vcampos-listtext (string-append str "," ncampo) (rest lsta))))))	    
	
; ----------------------------------------------------------------------  
; Pagina vista - Visualizacion de configuracion de campos
; ----------------------------------------------------------------------

; codegen-vista :: string string request -> expr?
; Despliega pagina que visualiza la configuración de los
; campos de la tabla seleccionada. Retorna expresión.
(define (codegen-vista id schema ntable request)
    (local [(define (response-generator embed/url)
        (response/xexpr     
	    (make-page-view id schema ntable)))
        ]
        (send/suspend/dispatch response-generator)
        ))

; ----------------------------------------------------------------------
; Cookies
; ----------------------------------------------------------------------

(require web-server/stuffers/hmac-sha1)
(require net/base64)

; Creacion y codificacion de cookie
; Eliminamos ultimos 3 caracteres =\r\n por defecto generados
; bajo base64-encode

; sub-str :: string -> string
; Elimina últimos 3 caracteres =\r\n.
; Retorna string.
(define (sub-str str)
  (define lst (string->list str))
  (define newlst (drop-right lst 3))
  (define newstr (list->string newlst))
  newstr)

; make-digest :: string string -> string
; Codifica valor de las dos cadenas de texto.
; Retorna string.
(define (make-digest str1 str2)
  (sub-str (bytes->string/utf-8
    (base64-encode
	(HMAC-SHA1 (string->bytes/utf-8 str1)
	    (string->bytes/utf-8 str2))))))
	    
; Eliminación de cookie - Establecemos max-age en 0
; Expiramos tiempo permitido (> 1800 secs)

; del-auth-cookie :: string string string -> list?
; Expira y elimina cookies. Usuario sale
; de la herramienta. Retorna lista.
(define (del-auth-cookie user schema table)
    
    ; time
    (define time
	(number->string (+ (current-seconds) 2000)))
    (define time-cookie
	(make-cookie "time" time #:max-age 0))
    ; id	
    (define id-cookie
	(make-cookie "id" user #:max-age 0))
    ; schema
    (define schema-cookie
	(make-cookie "schema" schema #:max-age 0))
    ; table
    (define table-cookie
	(make-cookie "table" table #:max-age 0))
    ; digest
    ; Semilla key.pass
    (define digest
	(make-digest "B7.4.b34Ut7.w0r1d" (string-append "time" time "id" user "schema" schema "table" table)))
        
    (define digest-cookie
	(make-cookie "digest" digest #:max-age 0))
        
    ; retornamos lista con cookies
    (list time-cookie id-cookie schema-cookie table-cookie digest-cookie))
    

; Creacion de cookie
; make-auth-cookie :: string string string -> list?
; Crea cookies para identificación del usuario a través
; de la herramienta. Retorna string.					   
(define (make-auth-cookie user schema table)
	
    ; time
    (define time
	(number->string (current-seconds)))
    (define time-cookie
	(make-cookie "time" time))
    ; id	
    (define id-cookie
	(make-cookie "id" user))
    ; schema
    (define schema-cookie
	(make-cookie "schema" schema))
    ; table
    (define table-cookie
	(make-cookie "table" table))
    ; digest
    ; Semilla key.pass
    (define digest
	(make-digest "B7.4.b34Ut7.w0r1d" (string-append "time" time "id" user "schema" schema "table" table)))
        
    (define digest-cookie
	(make-cookie "digest" digest))
        
    ; retornamos lista con cookies
    (list time-cookie id-cookie schema-cookie table-cookie digest-cookie))

; Recuperacion y decodificacion de cookie
; extract-auth-cookies :: request -> list?
; Recupera y decodifica cookies para autenticación del
; usuario. Si es correcto, se retorna lista con el contenido 
; de las cookies, de lo contrario se retorna #f.
(define (extract-auth-cookies req)
    (define cookies (request-cookies req))
    (define (cookie-named name)
	(findf (lambda (cookie)
	    (string=? name (client-cookie-name cookie)))
		cookies))
	
    (define time-cookie
	(cookie-named "time"))
    (define time-val
	(client-cookie-value time-cookie))
	
    (define id-cookie
	(cookie-named "id"))
    (define id-val
	(client-cookie-value id-cookie))
        
    (define schema-cookie
	(cookie-named "schema"))
    (define schema-val
	(client-cookie-value schema-cookie))
        
    (define table-cookie
	(cookie-named "table"))
    (define table-val
	(client-cookie-value table-cookie))
	
    (define digest-cookie
	(cookie-named "digest"))
    (define digest-val
	(client-cookie-value digest-cookie))
		
    ; expired (Pasaron más de 1800 secs)
    (define (expired?)
	; (< (+ (* 60) (string->number time-val)) (current-seconds)))
	(> (current-seconds) (+ (* 10000) (string->number time-val)))) ; 1/2 hora 1800
	
    ; tempered (Cambió algún valor)
    (define (tempered?)
	(not (equal? digest-val
	    (make-digest "B7.4.b34Ut7.w0r1d" (string-append "time" time-val "id" id-val "schema" schema-val "table" table-val)))))
	
    (cond 
	[(expired?) #f]
	[(tempered?) #f]
	[else
            ; Si cookie es válida, retornamos lista (id schema table)
            (list id-val schema-val table-val)]))
			
; Inicio de creacion de cookie, esta
; se introduce en cabecera.
; make-auth-cookie-then-redirect-to :: string string string -> expr?
; Creamos cookies para identificación del usuario.
; Retorna expresión.
(define (make-auth-cookie-then-redirect-to user schema table where-to)
  (redirect-to where-to
               see-other
               #:headers
               (map cookie->header
                    (make-auth-cookie user schema table))))
		    
; Eliminacion de cookie
; del-auth-cookie-then-redirect-to :: string string string -> expr?
; Eliminamos cookies para cierre de sesión y salida del
; usuario. Retorna expresión.
(define (del-auth-cookie-then-redirect-to user schema table where-to)
    (redirect-to where-to
               see-other
               #:headers
               (map cookie->header
                    (del-auth-cookie user schema table))))
					
; Inicio de recuperacion de cookie
; auth :: request -> list?/boolean
; Comprueba autenticidad del usuario a través de las cookies,
; de ser correcto se retorna lista con sus valores, de lo
; contrario se retorna #f.
(define (auth req)
    (define cookies (request-cookies req))
    (if (not (null? cookies))		
	(extract-auth-cookies req)
	#f))

; Mensajes de error
(define error-01 "Usuario y/o contraseña incorrectos.")
(define error-02 "Esquema no se encuentra creado y/o relacionado.")
(define error-03 "Especifique un usuario, contraseña y esquema.")
(define error-04 "Esquema no se encuentra creado y/o relacionado.")

; Mensajes de información
(define welcome "Bienvenido a Anauj, ahora puedes iniciar a armar tu aplicación. Cada icono <i> aportará información que te guiará en el proceso. Puedes empezar con el icono en el panel izquierdo.")
(define info-tablas "Aquí encontrarás todas las tablas del esquema de base de datos. Selecciona una de ellas para desplegar su tabla de configuración de campos al costado derecho.")
(define info-tabconf "Esta es la tabla de configuración de campos, aquí podrás configurar los campos de cada tabla. Para cambiar la propiedad de algún campo, da click en la celda en que se intersecta la columna de alguna propiedad con la fila de algún nombre de campo. Ten en cuenta que propiedades como tamaño lógico y nulable no son modificables.")
(define info-label "Aquí puedes modificar el nombre de la etiqueta que acompaña al campo.")
(define info-te "Este será el tipo de elemento HTML que representará al campo. select_date esta diseñado para campos date/fecha de la base de datos, lo componen tres elementos select cada uno representando el dia, mes y año.")
(define info-rest "Aquí puedes establecer el tipo de texto que permitirá el campo. numérico sólo permitirá números [0-9], alfabetico sólo permitirá letras del alfabeto [a-zA-Z], alfanumérico sólo para letras y números [0-9a-zA-Z], email esta especialmente diseñado para aceptar correos electrónicos y alfanumérico_esp permitirá además caracteres como [@#.,/- espacio].")
(define info-tamfis "Aquí puedes establecer el tamaño físico del elemento HTML que representa al campo.")
(define info-mostrar "Aquí decides si el campo es necesario mostrarse gráficamente. Será necesario si el campo representa información que el usuario suministra. Por ejemplo: Número de documento, fecha de nacimiento, etc.")
(define info-lstopc "Aquí establecerás las opciones para los campos (select, radio, checkbox) siguiendo el siguiente formato: [\"value\" \"show\"],[\"v\" \"s\"],...,[\"v\" \"s\"] Donde value/v será el valor real del campo y show/s será el valor que se mostrará gráficamente. Las comas que separan a cada opción no deben tener espacios a su alrededor y las comillas dobles siempre serán necesarias.")
(define info-guaconf "Para guardar temporalmente la configuración de los campos, haz click en 'Guardar'. Si deseas guardar permanentemente su configuración, y así en un nuevo ingreso a la aplicación los valores esten conservados, haz click en 'save' en la barra superior. Ten en cuenta que antes de guardarlos permanentemente debes guardarlos temporalmente.")
(define info-visconf "Si deseas visualizar gráficamente la configuración de los campos, haz click en 'Visualizar'.")
(define info-confcrud "Aquí podrás configurar las funciones CRUD (de persistencia) para cada tabla del aplicativo. Para iniciar selecciona el tipo de función que quieres crear. Es necesario crear al menos una función CRUD.")
(define info-nomproc "Aquí establecerás el nombre del procedimiento que dará manejo a la función de persistencia. Este es importante puesto que a través de el se hará la ejecución de la función CRUD. Para nombrar el procedimiento se puede utilizar los caracteres del alfabeto y los simbolos _-/. Ten en cuenta que todas las funciones CRUD irán en un solo archivo, por lo que todos los nombres deben ser diferentes.")
(define info-camposcrud "Aquí podrás seleccionar los campos que intervienen en la función de persistencia. Por ejemplo: Si es la función INSERT, entonces serán los campos que se insertarán. Para UPDATE serán los campos que se actualizarán, DELETE los campos que serán invalidados (esto debido a que se trabaja con instrucción UPDATE), para usar DELETE directamente ve a la opción de función CRUD personalizada. Finalmente para SELECT serán los campos mostrados.")
(define info-restcrud "Aquí podrás seleccionar los campos que actuarán como restricción en la función de persistencia. Por ejemplo: Si es la función SELECT, serán los campos por los que se hará la búsqueda. Para UPDATE, serán los campos por los que se hará la búsqueda para actualizar. Para DELETE, serán los campos por los que se hará la búsqueda para invalidar. Se recomienda que UPDATE y DELETE tengan restricciones. Si quieres una consulta de todos los registros de una tabla, crea un SELECT sin restricciones.")
(define info-conlogcrud "Si la restricción a crear involucra más de un campo simultáneamente, debes establecer que conector lógico los une. El conector por defecto es AND.")
(define info-conlogcrudg "Para más de una restricción (bien sea simple o compuesta) se debe especificar que conector global los une. El conector global por defecto es AND.")
(define info-guacrud "Una vez que tengas la función CRUD especificada podrás guardarla temporalmente a través de 'Guardar', esto creará una tabla en la parte superior que mostrará la función creada. Es importante que una vez hayas creado/editado/eliminado tus funciones CRUD, las guardes de forma permanente a través de 'save crud' en la barra superior, hazlo antes de cambiar a otra tabla o hacer cualquier cosa. Si no lo haces, perderás todo el esfuerzo involucrado en la creación de estas funciones.")
(define info-acttabla "Aquí podrás activar la tabla, si quieres que sea involucrada en la generación del aplicativo. Si no tienes ninguna tabla activa no se generará el aplicativo. Su valor por defecto siempre estará off/apagada cada vez que inicies sesión.")
(define info-barra "A través de estos lanzadores podrás controlar el almacenamiento de tus configuraciones, generación y ejecución de la aplicación prototipo. Con 'save' almacenarás todas las configuraciones de los campos de la totalidad de las tablas. Con 'save crud' almacenarás todas las funciones CRUD creadas para la tabla actual. Con 'export app' generarás los archivos con el código fuente de la aplicación prototipo incluyendo las configuraciones hechas en los campos y funciones CRUD de las tablas que se encuentran activas y finalmente con 'exec app' pondrás en ejecución la aplicación prototipo.")

; Mensajes de información - funciones CRUD personalizadas
(define info-crudper "Aquí podrás establecer las funciones CRUD de persistencia textualmente, según el criterio utilizado por el lenguaje de programación Racket.")
(define info-crudper-defsql
    `(span 
	"Aquí es donde definirás textualmente las funciones de persistencia. Cada una de ellas a excepción de la función INSERT deberán ir con restricciones, es decir con la cláusula (where) y algún parámetro." (br)(br)
	
	"Las funciones tendrán el siguiente formato:" (br)(br)
	
	    "+ insert into nombreTabla (...) values (...) - Los paréntesis aquí son obligatorios." (br)
	    "+ select ... from nombreTabla where ..." (br)
	    "+ update nombreTabla set ... where ..." (br)
	    "+ delete from nombreTabla where ..."

	(br)(br)
	"Un ejemplo de cada una sería:" (br)(br)

	    "+ insert into empven.dpto (iddpto,descp) values ($1,$2)" (br)
	    "+ select iddpto,descp from empven.dpto where iddpto=$1" (br)
	    "+ update empven.dpto set descp=$1,capital=$2 where iddpto=$3" (br)
	    "+ delete from empven.dpto where iddpto=$1"

	(br)(br)
	"En caso de necesitar una actualización con valores predeterminados activa la opción 'Usar update para invalidar', cuya definición debes cambiar a algo como:" (br)(br)

	"+ update empven.dpto set descp='cualquier_valor',capital='algún_otro_valor' where iddpto=$1" (br)(br)
	
	"Tener en cuenta que: " (br)(br)
	
	"+ Los campos deben estar separados por coma ( , )." (br)
	"+ La zona de las restricciones (parte despues de where) hasta ahora se ha definido de forma simple, pero es posible hacer restricciones compuestas considerando los operadores lógicos (and y or). Un ejemplo seria: where (idciudad=$1 and sexo=$2) or iddpto=$3." (br)
	"+ No es posible declarar un mismo campo más de 1 vez en cada instrucción." (br)(br)
))

;(define server-path "/home/hmc/Documentos/racket-proy/codegen-arq/recoleccion-datos/")
(define path (build-path server-path))

; Configuración básica del servidor web donde se desplegará
; la herramienta CASE.
(serve/servlet start
        #:launch-browser? #f 
	    ; ¿Lanzar navegador web al iniciar servidor?	
        #:quit? #f 
	    ; si quit? es #t, entonces URL /quit cierra el servidor.
        #:listen-ip #f 
	    ; #f para aceptar conexiones de todas las direcciones IP.
        #:port 8000 
	    ; Especifica el puerto sobre el cual corre aplicación web.
        #:server-root-path path
	    ; Ruta en el sistema de archivos donde reside configuración y arranque del servidor.
		#:extra-files-paths (list (build-path server-path "htdocs"))
		    ; Ruta para los archivos estáticos de la aplicación web.
	    ; Forma URL para acceso a nuestra aplicación.
	#:servlet-path "/codegen"
        #:servlet-regexp #rx""	    
	    ; En caso de que URL no corresponda con alguna regla de despacho,
	    ; cargamos pagina de login.
        #:file-not-found-responder codegen-login-tmp)
        
; Iniciamos nuestra aplicacion con
; cmd racket -t <file.rkt>

; Accedemos a nuestra aplicacion desde nuestro
; browser bajo URL localhost:8000/codegen
