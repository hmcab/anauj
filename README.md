# anauj

Before you run the application it is necessary to make the following changes:

  1. Install PostgreSQL database.
  2. Change password of postgres user to 56648865.
  3. Create codegen database.
  4. Create tables for codegen database from recoleccion-datos/htdocs/schemas/codegen.sql.
  5. Create schemas empven.sql and estmat.sql from recoleccion-datos/htdocs/schemas.

Finally change the values to the constants in generacion-datos/conf.rkt
by path where you copy the anauj project. For example my user is hmc and
the project anauj (the three folders) is under /home/hmc/Documentos/racket-proy/codegen-arq/.

After you run the application

If in any time you do can't get access to the application and you get this message 
'Aplicación en uso', you have change the value of field `estado` in estado table to
false. In short words do this `update estado set estado='false' where id='anauj';`
in codegen database.
