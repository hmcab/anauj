
#lang racket/base
    (require racket/list
	    racket/local
	    racket/file
	    db)
    (define db #f)

(define (inicializar-conn) (set! db (postgresql-connect #:server "localhost" #:port 5432 #:database "codegen" #:user "postgres" #:password "56648865")) (if (connected? db) #t #f))

(define (inicializado) (if (and (not (boolean? db)) (connected? db)) #t (inicializar-conn)))

(define (manage-error-sql lst) (if (void? lst) "Consulta procesada con éxito. Verifique los datos." (let ((code (string->number (cdr (car (cdr lst)))))) (cond ((= code 23505) "Datos ya registrados.") (else "Consulta no fue procesada con éxito.")))))

(define (format-date elemt) (if (regexp-match? #px"[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}" elemt) (let* ((date (regexp-split #rx"-" elemt)) (anio (first date)) (mes (second date)) (dia (third date))) (make-sql-date (string->number anio) (string->number mes) (string->number dia))) elemt))

(define (bd-select-all-ventas) (if (inicializado) (let () (define rs (query-rows db "SELECT totalventa,fecventa,numdoc,id FROM empven.ventas")) (if (empty? rs) "Consulta no arrojó algún resultado." rs)) #f))
(define (bd-insert-venta totalventa fecventa numdoc id) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "INSERT INTO empven.ventas (totalventa,fecventa,numdoc,id) VALUES($1,$2,$3,$4)" (string->number totalventa) (format-date fecventa) numdoc (string->number id)))) #f))
(define (bd-insert-empleado idciudad iddpto dir email sexo fecnac tipodoc apellidos nombre numdoc) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "INSERT INTO empven.empleado (idciudad,iddpto,dir,email,sexo,fecnac,tipodoc,apellidos,nombre,numdoc) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)" idciudad iddpto dir email sexo (format-date fecnac) tipodoc apellidos nombre numdoc))) #f))
(define (bd-select-all-empleado) (if (inicializado) (let () (define rs (query-rows db "SELECT idciudad,iddpto,dir,email,sexo,fecnac,tipodoc,apellidos,nombre,numdoc FROM empven.empleado")) (if (empty? rs) "Consulta no arrojó algún resultado." rs)) #f))
(define (bd-update-totalventa totalventa id) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "update empven.ventas set totalventa=$1 where id=$2" (string->number totalventa) (string->number id)))) #f))
(define (bd-update-email-empleado email numdoc) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "update empven.empleado set email=$1 where numdoc=$2" email numdoc))) #f))
(define (bd-select-for-ciudad idciudad) (if (inicializado) (let () (define rs (query-rows db "select nombre,apellidos,email from empven.empleado where idciudad=$1" idciudad)) rs) #f))
(define (bd-update-empleado-per nombre apellidos email dir fecnac numdoc) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "update empven.empleado set nombre=$1,apellidos=$2,email=$3,dir=$4,fecnac=$5 where numdoc=$6" nombre apellidos email dir (format-date fecnac) numdoc))) #f))
(define (bd-delete-empleado-per numdoc) (if (inicializado) (manage-error-sql (with-handlers ((exn:fail:sql? exn:fail:sql-info)) (query-exec db "delete from empven.empleado where numdoc=$1" numdoc))) #f))

(provide (all-defined-out))