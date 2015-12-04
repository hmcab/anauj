#lang racket

(require 2htdp/batch-io)

; Conversion de cadena en lista con delimitador &
; lst-split :: (listof string) -> (listof list?)
; Convierte funciones CRUD de cada tabla del esquema especificado por el
; usuario (Cadena de texto formateada en javascript), en lista de listas 
; de funciones CRUD. Retorna lista de listas.
(define (lst-split lst)
  (if (empty? lst)
      '()
      (let* ((elemt (third (first lst)))
             (lsts (regexp-split #rx"&" elemt)))
        (cons lsts (lst-split (rest lst))))))
        
; lst-split-esp :: list -> (listof list?)
; Convierte funciones CRUD personalizadas de cada tabla del esquema especificado
; por el usuario (Cadena de texto formateada en javascript), en lista de listas.
; Retorna lista de listas. 
(define (lst-split-esp lst)
  (if (empty? lst)
      '()
      (let* ((elemt   (third (first lst)))
             (lsts    (regexp-split #rx"&" elemt))
             (sublst  (regexp-split #rx"," (last lsts)))
             (symlst  (to-sym sublst)))
        (cons (append (take lsts 5) (list symlst)) (lst-split-esp (rest lst))))))

; Formacion de sentencia SQL
; format-sql :: (listof list?) -> (listof list?)
; Construye formato adecuado para cada instruccion SQL (funcion CRUD) 
; de cada tabla. Retorna lista de listas.
(define (format-sql lst)
  (if (empty? lst)
      '()
      (let* ((elemt (first lst))
             (long  (length elemt)))
        (if (= long 7) ; campo de restricciones activo
            (cons (format-sql-rest elemt) (format-sql (rest lst)))
            (cons (format-sql-norest elemt) (format-sql (rest lst)))))))

; ***** Formato SQL sin restricciones 
; format-sql-norest :: list? -> list?
; Construye instruccion INSERT y SELECT con restricciones.
; Retorna lista.
(define (format-sql-norest lst)
  (let ((schema (second lst))
        (ntable (third lst))
        (nfunc (fourth lst))
        (noper (fifth lst))
        (campos (sixth lst)))
    [cond
      ((string=? noper "INSERT") (append (list schema ntable nfunc noper) (format-insert schema ntable campos)))
      ((string=? noper "SELECT") (list schema ntable nfunc noper (format-select schema ntable campos)))
      ((string=? noper "UPDATE") (list "*UPDATE*"))
      ((string=? noper "DELETE") (list "*DELETE*"))]))
      
; format-insert :: string string string -> (listof string list?)
; Construye instruccion INSERT con campos especificados, para tabla de un esquema.
; Retorna lista con elemento string y lista.
(define (format-insert schema ntable campos)
  (define lstcampos (regexp-split #rx"," campos))
  (define longcampos (length lstcampos))
  (define sqlinsert (string-append "INSERT INTO " schema "." ntable " (" campos ") VALUES" (get-markers longcampos)))
  (define lstsym (to-sym (get-lst-sym lstcampos)))
  (list sqlinsert lstsym))

; format-select :: string string string -> string
; Construye instruccion SELECT sin restricciones, 
; con campos especificados, para tabla de un esquema.
; Retorna string.
(define (format-select schema ntable campos)
  (define lstcampos (regexp-split #rx"," campos))
  (define sqlselect (string-append "SELECT " campos " FROM " schema "." ntable))
  sqlselect)

; format-update :: string string string -> string
; Construye instruccion UPDATE sin restricciones,
; con campos especificados, para tabla de un esquema.
; Retorna string.
(define (format-update schema ntable campos)
  (define lstcampos (regexp-split #rx"," campos))
  (define sqlupdate (string-append "UPDATE " schema "." ntable " SET " (get-update-markers "" lstcampos)))
  sqlupdate)

; ***** Formato SQL con restricciones
; format-sql-rest :: list? -> list?
; Construye instruccion SELECT, UPDATE o DELETE con restricciones.
; Retorna lista.
(define (format-sql-rest lst)
  (let ((conntg (first lst))
        (schema (second lst))
        (ntable (third lst))
        (nfunc (fourth lst))
        (noper (fifth lst))
        (campos (sixth lst))
        (rests (seventh lst)))
    [cond
      ((string=? noper "SELECT") (append (list schema ntable nfunc noper) (format-select-rest schema ntable campos conntg rests)))
      ((string=? noper "UPDATE") (append (list schema ntable nfunc noper) (format-update-rest schema ntable campos conntg rests)))
      ;((string=? noper "DELETE") (list "*DELETE*"))]))
      ((string=? noper "DELETE") (append (list schema ntable nfunc noper) (format-delete-rest schema ntable campos conntg rests)))]))

; format-select-rest :: string string string string -> (listof string list?)
; Construye instruccion SELECT con restricciones,
; con campos especificados, para una tabla del esquema.
; Retorna lista con elemento string y lista.
(define (format-select-rest schema ntable campos conntg rests)
  (define lstrests (regexp-split #rx";" rests))
  (define sqlselect (format-select schema ntable campos))
  (define sqlrests (format-rest schema ntable conntg rests))
  (define ssr (string-append sqlselect sqlrests))
  (define ssrf (fix-markers ssr))
  (define lstsym (to-sym (get-lst-sym lstrests)))
  (list ssrf lstsym))
  
; format-update-rest :: string string string string -> (listof string list?)
; Construye instruccion UPDATE con restricciones,
; con campos especificados, para una tabla del esquema.
; Retorna lista con elemento string y lista.
(define (format-update-rest schema ntable campos conntg rests)
  (define lstcampos (regexp-split #rx"," campos))
  (define lstrests (regexp-split #rx";" rests))
  (define sqlupdate (format-update schema ntable campos))
  (define sqlrests (format-rest schema ntable conntg rests))
  (define sur (string-append sqlupdate sqlrests))
  (define surf (fix-markers sur))
  (define lstsymc (get-lst-sym lstcampos))
  (define lstsymr (get-lst-sym lstrests))
  (define lstsym (to-sym (append lstsymc lstsymr)))
  (list surf lstsym))

; DELETE a traves de funcion UPDATE
; format-delete-rest :: string string string string -> (listof string list?)
; Construye instruccion UPDATE con restricciones,
; con campos especificados, para una tabla del esquema.
; Retorna lista con elemento string y lista.
(define (format-delete-rest schema ntable campos conntg rests)
  (define lstcampos (regexp-split #rx"," campos))
  (define lstrests (regexp-split #rx";" rests))
  (define sqlupdate (format-update schema ntable campos))
  (define sqlrests (format-rest schema ntable conntg rests))
  (define sur (string-append sqlupdate sqlrests))
  (define surf (fix-markers sur))
  ; Agregamos _del a cada campo (act) para impedir
  ; colision con los nombres de los campos (rest)
  (define lstsymc (get-lst-sym (fix-del lstcampos)))
  (define lstsymr (get-lst-sym lstrests))
  (define lstsym (to-sym (append lstsymc lstsymr)))
  (list surf lstsym))

; *** Formacion de restricciones
; format-rest :: string string string -> string
; Construye restricciones para instruccion SQL.
; Retorna string.
(define (format-rest schema ntable conntg rests)
  (define lstrests (regexp-split #rx";" rests))
  ;(define longrests (length lstrests))
  ;(define sqlrest (string-append " WHERE 1=1" (format-rest-aux lstrests)))
  (define sqlrest (string-append " WHERE " (format-rest-aux conntg lstrests #t)))
  sqlrest)

; format-rest-aux :: list? -> string !!! CAMBIO 
; Convierte lista de restricciones a cadena de texto.
; Retorna string.
(define (format-rest-aux conntg lst master)
  (if (empty? lst)
      ""
      (let* ((elemt (first lst))
             (subelemt (regexp-split #rx"," elemt))
             (longelemt (length subelemt)))
        (if master
            (if (> longelemt 1)
                (string-append (format-rest-many subelemt) (format-rest-aux conntg (rest lst) #f))
                (string-append (format-rest-one subelemt) (format-rest-aux conntg (rest lst) #f)))
            (if (> longelemt 1)
                (string-append " " conntg " " (format-rest-many subelemt) (format-rest-aux conntg (rest lst) #f))
                (string-append " " conntg " " (format-rest-one subelemt) (format-rest-aux conntg (rest lst) #f)))))))            
            
; format-rest-many :: list? -> string
; Convierte lista compuesta de restricciones en cadena de texto.
; Retorna string.
(define (format-rest-many lst)
  (define opr (first lst))
  (define nlst (rest lst))
  (fmt-many "" opr nlst))

; format-rest-one :: list? -> string
; Convierte lista simple de restricciones en cadena de texto.
; Retorna string.
(define (format-rest-one lst)
  (define elemt (first lst))
  (string-append elemt "=?"))

; fmt-many :: string string list? -> string
; Construye cadena de texto de restricciones a partir de una lista
; compuesta de restricciones. Retorna string.
(define (fmt-many s opr lst)
  (if (empty? lst)
      (string-append s ")")
      (let ((elemt (first lst)))
        (define sone (string-append s "(" elemt "=?"))
        (define stwo (string-append s " " opr " " elemt "=?"))
        (if (string=? s "")
             (fmt-many sone opr (rest lst))            
             (fmt-many stwo opr (rest lst))))))
  
; ***** Creacion de marcadores ($1,$2, ... ,$n)
; get-markers :: number -> string
; Construye cadena de texto de marcadores $ con la cantidad especificada.
; Retorna string.
(define (get-markers long)
  (if (= long 1)
      "($1)"
      (let loop ((i 1)
                 (s ""))
        (define stri (number->string i))
        (if (< i long)
            (if (string=? s "")
                (loop (+ i 1) (string-append s "($" stri))
                (loop (+ i 1) (string-append s ",$" stri)))
            (string-append s ",$" stri ")")))))

; ***** Creacion de marcadores (campo1=? campo2=? ... campon=?)
; get-update-markers :: string list? -> string
; Construye cadena de texto, con marcador update ? para cada
; elemento de la lista. Retorna string.
(define (get-update-markers s lst)
  (if (empty? lst)
      s
      (let ((newsp (string-append s (first lst) "=?"))
            (newsq (string-append s ", " (first lst) "=?")))     
        (if (string=? s "")
            (get-update-markers newsp (rest lst))
            (get-update-markers newsq (rest lst))))))

; ***** Creacion de lista de simbolos
; get-lst-sym :: list? -> list?
; Obtiene lista de campos o restricciones. Retorna lista.
(define (get-lst-sym lst)
  (if (empty? lst)
      '()
      (let* ((elemt (first lst))
             (subelemt (regexp-split #rx"," elemt))
             (logelemt (length subelemt)))
        (if (> logelemt 1)
            (append (rest subelemt) (get-lst-sym (rest lst)))
            (cons (first subelemt) (get-lst-sym (rest lst)))))))
  
; to-sym :: list? -> (listof symbol?)
; Convierte lista de elementos string a lista de simbolos.
; Retorna lista de simbolos.
(define (to-sym lst)
  (if (empty? lst)
      '()
      (cons (string->symbol (first lst)) (to-sym (rest lst)))))

; Reparacion de markers
; fix-markers-aux :: number string -> string
; Convierte marcador ? a $# segun la posicion que ubique.
; Retorna string.
(define (fix-markers-aux n str)
  (if (not (regexp-match #rx"\\?" str))
      str
      (let* ((strn (number->string n))
             (substr (string-append "$" strn)))
        (fix-markers-aux (+ n 1) (regexp-replace #rx"\\?" str substr)))))

; fix-markers :: string -> string
; Convierte marcador ? a $# segun la posicion que ubique.
; Retorna string.
(define (fix-markers str)
  (fix-markers-aux 1 str))
  
; Reparacion de campos (bajo DELETE)
; Agregamos _del a cada campo
; fix-del :: list? -> list?
; Adiciona a cada cadena de la lista la cadena _del.
; Retorna lista.
(define (fix-del lst)
    (if (empty? lst)
        '()
        (let* ((elemt (first lst))
               (elemt-del (string-append elemt "_del")))
            (cons elemt-del (fix-del (rest lst))))))
                         

; ==========================================================
; ==========================================================

;(define crudlst (lst-split crudstr))
;(define flst (format-sql crudlst))

;(define (show-flst)
;  flst)
;(show-flst)
  
; ==========================================================
; ==========================================================

; ***** form-sql-render
;(define (form-sql-render npg ntb)
;  (prev-make-block-form npg ntb flst))

(provide (all-defined-out))
