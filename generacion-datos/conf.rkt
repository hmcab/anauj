
#lang racket

; Configuración de constantes de herramienta CASE - Anauj

; Tablas

;###############################
; Codegen
;###############################

(define cmd "racket -t /home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/apps/")
(define server-path "/home/hmc/Documentos/racket-proy/codegen-arq/recoleccion-datos/")

;###############################
; Campos
;###############################

; Directorio de herramienta CASE
(define schema-dir "/home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/data/")

;###############################
; Crud
;###############################

; Directorio de herramienta CASE
(define crud-dir "/home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/data/")

; Crud-format
; Crud-render

;###############################
; Crud-funcs
;###############################

; Directorio de funciones crud de aplicación prototipo
(define crud-funcs-dir "/home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/apps/")

; Lista con los nombres de los campos date en base de datos
(define datelst (list "fecnac" "fecventa" "fecped"))

;###############################
; Generador
;###############################

; Directorio de aplicación prototipo
(define app-dir "/home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/apps/")
;(define default-page "")

;###############################
; View-funcs
;###############################

; Directorio donde residirá aplicación protitipo.
(define view-funcs-dir "/home/hmc/Documentos/racket-proy/codegen-arq/generacion-datos/apps/")

;###############################
; Archivos estaticos
;###############################
(define css-src "/home/hmc/Documentos/racket-proy/codegen-arq/recoleccion-datos/htdocs/app.css")
(define js-src "/home/hmc/Documentos/racket-proy/codegen-arq/recoleccion-datos/htdocs/app.js")

(provide (all-defined-out))
