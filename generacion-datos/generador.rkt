
#lang racket

(require "conf.rkt")
(require "tablas.rkt") ; -> conn
(require "campos.rkt") ; -> conn
(require "crud.rkt") ; -> crud-format
(require "crud-funcs.rkt")
(require "crud-render.rkt")
(require "view-funcs.rkt")

(require 2htdp/batch-io)

; Directorio de aplicación prototipo
;(define app-dir "/home/hmc/Documentos/racket-proy/codegen/apps/")
(define default-page "")

; Lista que almacena temporalmenta las tablas del esquema a ser generadas.
(define lsttables (list))

; -----------------------------------------------------------
; Generacion grafica de una tabla-de-bd (desde tabla de conf)
; -----------------------------------------------------------
     
; make-page-view :: string string string -> expr?
; Despliega visualmente configuración de una tabla del esquema de base de datos.
; Retorna expresion.
(define (make-page-view id sch ntb)
    (define npg (string-append sch "-" ntb))
    `(html 
        (head 
            (title ,npg)
                (style ((type "text/css")) ,(file->string (build-path "app.css") #:mode 'text))
                (script ((type "text/javascript") (src "/app.js")) " "))
        (body ((onload "init();"))
            (div ((id "msgrest") (name "msgrest")) " ")
            (div ((id "div-form-real-view")) (form ((id "form-real")) ,@(form-render-real ntb)))
            (div ((id "div-link")) (a ((href "/codegen")) "<< Regresar"))
        )))

; make-page :: syntax -> syntax
; Macro que se extiende en su definición para generar función encargada de
; especificar y crear pagina web de una tabla en especifico. Usando en el
; proceso la configuración hecha a los campos y funciones CRUD.
; Retorna sintaxis.
(define-syntax (make-page stx)
  (syntax-case stx ()
    [(_ sch npg ntb) 
     (if (and (identifier? #'npg) (identifier? #'ntb))
         #'`(define (,(string->symbol npg) args request)
              (local [(define (response-generator embed/url)
                        (response/xexpr 
                         ,(list 'quasiquote (render-page sch npg ntb))))
                      ,@(func-sql-render npg ntb)
                      ,@(func-sql-per-render npg ntb)
                      ]
                (send/suspend/dispatch response-generator)))
         (raise-syntax-error #f "No es un identificador." stx #'ntb))
     ])) ; work
    
; render-page :: string string string -> expr?
; Construye pagina web de una tabla especificada. 
; Retorna expresion.
(define (render-page sch npg ntb)
    (define css (string-append app-dir "/" sch "/htdocs/app.css"))
    `(html (head (title ,npg)
                 (style ((type "text/css")) ,(file->string css #:mode 'text))
                 (script ((type "text/javascript") (src "/app.js")) " "))
        (body ((onload "init();"))
            (div ((id "div-menu") (name "div-menu")) ,(menu-lst lsttables))
            (div ((id "div-form-buttons") (name "div-form-buttons")) 
                ,@(form-sql-render npg ntb)
                ,@(form-sql-per-render npg ntb))
            (div  ((id "msgrest-container" )) (div ((id "msgrest") (name "msgrest")) " "))
            (form ((id "form-real")) ,@(form-render-real ntb))
            ,(response-msg)
            ,@(no-form-sql-render npg ntb)
            )))
            
; menu-lst-aux :: string -> expr?
; Crea elemento HTML li.
; Retorna expresión.
(define (menu-lst-aux elemt)
    `(li (a ((href ,(string-append "/" elemt))) ,elemt)))
            
; menu-lst :: list? -> expr?
; Crea elemento HTML ul.
; Retorna expresión.
(define (menu-lst lst)
    `(ul ,@(map menu-lst-aux lst)))
          
; response-msg :: nothing -> expr?
; Construye expresión racket para la muestra de mensajes generados
; por la aplicación prototipo. Retorna expresión.
(define (response-msg)
    (define args (string->symbol "args"))
    (define divrs `(div ((id "message")) (span "* ") ,(list 'unquote args)))
    (define wdivrs (list 'quasiquote divrs))
    (define if-in  `(if (list? ,args) (render-table "div-table-response" ,args) ""))
    (define if-ext `(if (string? ,args) ,wdivrs ,if-in))
    (define rs `,(list 'unquote if-ext))
    rs)

; form-render-real :: string -> expr?
; Construye formulario web para tabla especificada. Su construcción
; se basa en la configuración hecha en sus campos.
; Retorna expresion.
(define (form-render-real ntable)
  (define listelemts (get-elemts-table ntable vcamposg))
  (local [(define (render-elemts j)
            (let  ((label  (third j))
                   (id     (fourth j))
                   (type   (fifth j))
                   (restc  (sixth j))
                   (sizel  (seventh j))
                   (sizef  (eighth j))
                   (isnull (ninth j))
                   (show   (tenth j))
                   (opcs   (last j)))
              (if (string=? show "t")
                  (cond
                    ;[(string=? type "text") `(input ((type ,type) (name ,id) (id ,id) (size ,sizef) (maxlength ,sizel)))]
                    [(string=? type "text")        `(div ((class ,restc)) (span ((class "titulo")) ,label) (input ((type ,type) (name ,id) (id ,id) (size ,sizef) (maxlength ,sizel) (onblur "checkRestrictions(this);" ))))]
                    [(string=? type "select")      `(div ((class ,restc)) (span ((class "titulo")) ,label) (select ((id ,id)) ,@(get-select opcs)))]
                    [(string=? type "checkbox")    `(div ((class ,restc)) (span ((class "titulo")) ,label) ,@(get-checkbox id opcs))]
                    [(string=? type "radio")       `(div ((class ,restc)) (span ((class "titulo")) ,label) ,@(get-radio id opcs))]
                    [(string=? type "select_date") `(div ((class ,restc)) (span ((class "titulo")) ,label) ,(get-select-date id))]
                    [(string=? type "textarea")    `(div ((class ,restc)) (span ((class "titulo")) ,label) ,(get-textarea id sizef))]
                    [else empty])
                  empty))
            )]
    (map render-elemts listelemts)))
   
; get-checkbox :: string list? -> list?
; Construye lista con elementos HTML checkbox, que fueron especificados
; en la tabla de configuración de campos.
; Retorna lista.
(define (get-checkbox id opcs)
  (local [(define (get-elemts elemt)
            `(input ((type "checkbox") (name ,id) (id ,id)  (value ,(rc (first elemt)))) ,(rc (second elemt))))
          ]
    (map get-elemts opcs)))

; get-radio :: string list? -> list?
; Construye lista con elementos HTML radio, que fueron especificados
; en la tabla de configuración de campos.
; Retorna lista. 
(define (get-radio id opcs)
  (local [(define (get-elemts elemt)
            `(input ((type "radio") (name ,id) (id ,id)  (value ,(rc (first elemt)))) ,(rc (second elemt))))
          ]
    (map get-elemts opcs)))
    
; get-textarea :: string number/string -> expr?
; Construye elemento HTML textarea.
; Retorna expresion.
(define (get-textarea id sizef)
  `(textarea ((name ,id) (id ,id) (cols ,sizef) (rows "1"))
                       ;,(if (string? sizef) 
                       ;     (number->string (floor (/ (string->number sizef) 2)))
                       ;     (number->string (floor (/ sizef 2))))
             "texto prueba."))

; get-select :: list? -> list?
; Construye lista con elementos option para elemento HTML select 
; que fueron especificados en la tabla de configuración de campos.
; Retorna lista. 
(define (get-select opcs)
  (define defaults (list "" ""))
  (set! opcs (cons defaults opcs))
  (local [(define (get-option key-value)
            `(option ((value ,(rc (first key-value)))) ,(rc (second key-value))))
          ]
    (map get-option opcs)))
    
; get-select-date :: string -> expr?
; Construye elementos HTML select para campo tipo select_date, especificado
; en tabla de configuración de campos.
; Retorna expresión.
(define (get-select-date id)
  `(div ((class "date") (name ,id) (id ,id))
        (select ((id "select_day")) ,@(get-option-day))
        (select ((id "select_month")) ,@(get-option-month))
        (select ((id "select_year")) ,@(get-option-year))
        ))
		
; get-option-day :: nothing -> list?
; Construye lista de elementos HTML option para dias.
; Retorna lista.
(define (get-option-day)
  (for/list ((i (gen-list-num 1 31)))
    `(option ((value ,(ns i))) ,(ns i))))

; get-option-month :: nothing -> list?
; Construye lista de elementos HTML option para meses.
; Retorna lista.
(define month (list "Enero" "Febrero" "Marzo" "Abril" "Mayo" "Junio" "Julio" "Agosto" "Septiembre" "Octubre" "Noviembre" "Diciembre"))
(define (get-option-month)
  (for/list ((i (gen-list-num 1 12)))
    `(option ((value ,(ns i))) ,(get-month i))))

; get-option-year :: nothing -> list?
; Construye lista de elementos HTML option para años.
; Retorna lista.
(define (get-option-year)
  (for/list ((i (gen-list-num 1910 2015)))
    `(option ((value ,(ns i))) ,(ns i))))
		
; get-list-num :: number number -> list?
; Construye lista de numeros en el rango especificado.
; Retorna lista.
(define (gen-list-num a b)
  (if (> a b)
      '()
      (cons a (gen-list-num (+ a 1) b))))
		
; get-month :: number -> string
; Consulta mes ubicado en posicion especifica.
; Retorna string.
(define (get-month i)
  (get-month-aux month i 1))
	
; get-month-aux :: number -> string
; Busca mes ubicado en posicion especifica.
; Retorna string.
(define (get-month-aux lst i idx)
  (if (empty? lst)
      ""
      (if (= i idx)
          (first lst)
          (get-month-aux (rest lst) i (+ idx 1)))))
			
; ns :: number -> string
; Convierte entero en cadena de texto. Retorna string.
(define (ns i)
  (number->string i))
  
; Buscar tabla y listar sus campos (de vcamposg)
; get-elemts-table :: string listof list? -> listof list?
; Consulta configuracion de campos de tabla especificada.
; Retorna lista de listas.
(define (get-elemts-table ntable lst)
  (if (empty? lst) '()
      (if (string=? (second (first lst)) ntable)
          (cons (first lst) (get-elemts-table ntable (rest lst)))
          (get-elemts-table ntable (rest lst)))))
          
; rc :: string -> string
; Remueve comillas dobles "" de cadena de texto especificada.
; Retorna string.
(define (rc str)
  (if (not (string=? str ""))
      (let ((str-array (string->list str)))
        (if (and (char=? (first str-array) #\")
                 (char=? (last str-array) #\"))
            (let ()
              ; removemos primera comilla 
              (define str-sf (rest str-array)) 
              ; removemos ultima collima (de der->izq la 1ra pos)
              (define str-sl (drop-right str-sf 1)) 
              (define newstr (list->string str-sl))
              newstr)
            str))
      str))
      
; -----------------------------------------------------------
; Producción de forms y funciones crud
; -----------------------------------------------------------

(define (func-sql-render npg ntb)
  (prev-make-block npg ntb vcrudg))

(define (form-sql-render npg ntb)
  (prev-make-block-form npg ntb vcrudg))
  
(define (no-form-sql-render npg ntb)
  (prev-make-block-no-form npg ntb vcrudg))
  
; Funciones CRUD personalizadas

(define (func-sql-per-render npg ntb)
  (prev-make-block npg ntb (format-crud-per-data)))

(define (form-sql-per-render npg ntb)
  (prev-make-block-form npg ntb (format-crud-per-data)))

; -----------------------------------------------------------
; Generacion de archivo
; -----------------------------------------------------------

; to-string-func :: expr? -> string
; Convierte expresion en cadena de texto.
; Retonar string.
(define (to-string-func f)
  (define strf (format "~s" f))
  strf)

; create-app-descfile :: string -> output-port?
; Crea descriptor de archivo para salida.
; Retorna descriptor.
(define (create-app-descfile file)
  (let ((out  (open-output-file file
                                #:mode 'binary
                                #:exists 'replace)))
    out))

; write-cv-req :: string -> string
; Especifica los requerimientos para manipulacion de funciones CRUD y de vista.
; Retorna string.
(define (write-cv-req schema)
    (if (crud-exist)
        (let ((filecrud (string-append schema "-crud.rkt"))
              (fileview (string-append schema "-view.rkt")))
            ;(format-crud-data)
            (define reqs (string-append "\n(require \"" filecrud "\")" "\n(require \"" fileview "\")"))
            reqs)
        ""))

; write-reqs :: output-port? string -> void?
; Escribe los requerimientos de la aplicacion prototipo en archivo <schema>-app.rkt.
; Retorna void?.
(define (write-reqs df schema)
  (define reqs 
        "\n#lang racket
		(require web-server/servlet
				web-server/servlet-env
				web-server/dispatch)
		(require (planet neil/html-writing:2:0))
		(provide/contract (start (request? . -> . response?)))
		(require 2htdp/batch-io)")
  (define nstart (string-append "(" schema "-dispatch request))"))
  (define start (string-append "\n(define (start request) \n\t" nstart "\n"))
  (define cvreq (write-cv-req schema))
  (displayln reqs df)
  (displayln cvreq df)
  (displayln start df))
	
; defv :: string list? -> string
; Especifica reglas de despacho de aplicacion prototipo.
; Retorna string.
; (empven-empleado-tmp)
(define (defv schema lst)
  (if (empty? lst)
      (string-append "\n\t\t[(\"\") " schema "-index-tmp]")
      (let* ((ntable (first lst))
             (str (string-append "\n\t\t[(\"" ntable "\") " schema "-" ntable "-tmp]")))
        (string-append str (defv schema (rest lst))))))

; deff :: string list? -> string
; Especifica funciones de despacho de aplicacion prototipo.
; Retorna string.
; (empven-empleado null request)
(define (deff schema lst)
  (if (empty? lst)
      (string-append "\n(define (" schema "-index-tmp" " request)"
                     "\n\t(" schema "-" default-page " null request))\n")
      ; "\n\t(" schema "-index null request))\n")
      (let* ((ntable (first lst))
             (str (string-append "\n(define (" schema "-" ntable "-tmp" " request)"
                                 "\n\t(" schema "-" ntable " null request))\n")))
        (string-append str (deff schema (rest lst))))))
            
; write-rules :: output-port? string string list? -> void?
; Escribe reglas y funciones de despacho en archivo <schema>-app.rkt.
; Retorna void?.
(define (write-rules df schema lst)
	; Definicion de pagina por defecto (pagina de inicio)
	; Primera tabla de la lista de tablas
	(set! default-page (first lst))
	(define rules (defv schema lst))
	(define funcs (deff schema lst))
	(define srules (string-append "(define-values (" schema "-dispatch" " " schema "-url)" "\n\t(dispatch-rules"))
	(define erules "))")
	(define rrules (string-append srules rules erules))
	(displayln rrules df)
	(displayln funcs df))

; write-pages :: output-port? string listof list? -> void?
; Escribe las paginas que representan a cada una de las tablas
; del esquema de base de datos que fueron activadas, considerando
; la configuración de sus campos y funciones CRUD asociadas en archivo
; <schema>-app.rkt. Retorna void?.
(define (write-pages df schema lst)
  (if (empty? lst)
      ""
      (let* ((ntable (first lst))
             (npage  (string-append schema "-" ntable)))
        (displayln (string-append "\n" (to-string-func (make-page schema npage ntable))) df)
        (write-pages df schema (rest lst)))))
			
; write-server :: output-port string list? -> void?
; Escribe configuración de servidor Web, que permite despliegue y ejecución
; de aplicación prototipo en archivo <schema>-app.rkt.
; Retorna void?.
(define (write-server df schema lst)
  (define default-page-tmp (string-append schema "-" default-page "-tmp"))
  (define dir (string-append "\"" app-dir schema "\""))
  (define path (string-append "\n(define path (build-path " dir "))"))
  (define server (string-append
        "\n(serve/servlet start
		#:launch-browser? #f
		#:quit? #t
		#:listen-ip #f
		#:port 8900
		#:server-root-path path
		#:extra-files-paths (list (build-path " dir " \"htdocs\"))
		#:servlet-path " "\"" "/" default-page "\"
		#:servlet-regexp #rx\"\"
		#:file-not-found-responder " default-page-tmp ")"))
  (define server-conf (string-append path server))
  (displayln server-conf df))

; create-dirs-aux :: string string -> boolean
; Crea directorios de aplicación prototipo. Directorio raiz y de archivos
; estaticos htdocs. Retorna #t si fueron creados, #f de lo contrario.
(define (create-dirs-aux dir dirh)
  (define (dir-create dr)
    (if (directory-exists? dr)
      #t
      (let ((drc (make-directory dr)))
        (if (directory-exists? dr)
            #t
            #f))))
  (define dir-root (dir-create dir))
  (define dir-second (dir-create dirh))
  (define (dir-show drc drcstr)
    (if drc
        (displayln (string-append "Directorio " drcstr " creado."))
        (displayln (string-append "Directorio " drcstr " no creado."))))
  (dir-show dir-root "root")
  (dir-show dir-second "second")
  (if (and dir-root dir-second)
      #t
      #f))

; Lanzador principal
; create-app-file :: schema list? -> void?
; Creación de archivo de código fuente de aplicación prototipo
; en base a la configuración de los campos y funciones CRUD 
; de la totalidad de las tablas. (Paginas y formularios).
; Retorna void?.
(define (create-app-file schema lst)
  ; Creación de directorios de trabajo (root y second)
  (define dir-root (string-append app-dir schema))
  (define dir-second (string-append app-dir schema "/htdocs"))
  (define rsc (create-dirs-aux dir-root dir-second))
  (define css-dest (string-append dir-second "/app.css"))
  (define js-dest (string-append dir-second "/app.js"))
  ; Creación de archivo .rkt del aplicativo
  (define file-rkt (string-append dir-root "/" schema "-app.rkt"))
  ; Almacenamos globalmente lista de tablas a generar
  (set! lsttables lst)
  (if rsc
      (let ()
        (copy-file css-src css-dest #t)
        (copy-file js-src js-dest #t)
        (define df (create-app-descfile file-rkt))
        (format-crud-data)              ; configuración de formato de funciones CRUD  
        (write-reqs df schema)          ; especificación de archivos requeridos
        (write-rules df schema lst)     ; reglas de despacho
        (write-pages df schema lst)     ; pagina por cada tabla del esquema activa
        (write-server df schema lst)    ; configuración del servidor
        (close-output-port df))
      (displayln "Directorios necesarios no creados. Aplicación no generada.")))
      
; create-crud-file :: string -> void?
; Creación de archivo de código fuente de aplicación prototipo
; en base a la configuración de las funciones CRUD.
; (Funciones de persistencia). Retorna void?.
; En caso de no existir funciones CRUD, el archivo es eliminado.
(define (create-crud-file schema)
    (define vcrudg-per-f (format-crud-per-data))
    (cond 
        [(and (crud-exist) (crud-per-exist)) (save-crud-funcs-file schema (append vcrudg vcrudg-per-f))]
        [(crud-exist)      (save-crud-funcs-file schema vcrudg)]
        [(crud-per-exist)  (save-crud-funcs-file schema vcrudg-per-f)]
        [else
            (remove-crud-funcs-file schema)]))
            
    ;(if (crud-exist)
    ;    (save-crud-funcs-file schema vcrudg)
    ;    (remove-crud-funcs-file schema)))

; create-view-file :: string -> void?
; Creación de archivo de código fuente de aplicación prototipo con
; funciones de vista. Retorna void?.
; En caso de no existir funciones CRUD, el archivo es eliminado.
(define (create-view-file schema)
    (if (crud-exist)
        (save-view-funcs-file schema)
        (remove-view-funcs-file schema)))    
        	 
(provide (all-defined-out))
