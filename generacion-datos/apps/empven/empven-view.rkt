
#lang racket/base
(require racket/list
	 racket/local
	 racket/file
	 db)

(require (planet neil/html-writing:2:0))
(require 2htdp/batch-io)

(define (render-table name lstv)
	`(div ((id ,name) (name ,name))
		(table
		    (thead)
		    (tbody ,@(render-table-aux lstv)))))
(define (render-table-aux lstv)
	(if (empty? lstv)
	    '()
	    (let* ((vec (first lstv))
		   (v2l (vector->list vec)))
		(define cols (map (lambda (col)
			    (set! col (sql-date-str col))
				`(td ,col)) v2l))
		(define row `(tr ,@cols))
		(cons row (render-table-aux (rest lstv))))))
(define (sql-date-str data)
	(if (sql-date? data)
	    (string-append (number->string (sql-date-year data)) "-"
			   (number->string (sql-date-month data)) "-"
			   (number->string (sql-date-day data)))
	    (cond 
		[(number? data) (number->string data)]
		[(boolean? data) (if data "true" "false")]
		[else
		    data])))
(provide render-table render-table-aux)