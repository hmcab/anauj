
CREATE SCHEMA estmat;

CREATE TABLE estmat.estudiante (
    codest integer PRIMARY KEY,
    nombre varchar(15) NOT NULL,
    apellido varchar(15) NOT NULL,
    carrera varchar(25) NOT NULL
);

--INSERT INTO estmat.estudiante VALUES ('2010378AG','Andres','Garcia','Ingenieria de sistemas');
--INSERT INTO estmat.estudiante VALUES ('2010378FB','Fabio','Gomez','Ingenieria de sistemas');
--INSERT INTO estmat.estudiante VALUES ('2009378LV','Lucia','Velez','Matematicas');

CREATE TABLE estmat.docente (
    iddoc varchar(10) PRIMARY KEY,
    nombre varchar(15) NOT NULL,
    apellido varchar(15) NOT NULL
);

--INSERT INTO estmat.docente VALUES ('9601','Efrain','Vasquez');
--INSERT INTO estmat.docente VALUES ('9602','Pablo','Amaya');
--INSERT INTO estmat.docente VALUES ('9603','Camilo','Contreras');
--INSERT INTO estmat.docente VALUES ('9604','Jeff','Dean');
--INSERT INTO estmat.docente VALUES ('9605','Eric S','Raymond');

CREATE TABLE estmat.materia (
    codmat varchar(5) PRIMARY KEY,
    nombre varchar(30) NOT NULL,
    iddoc varchar(10) NOT NULL,
    FOREIGN KEY(iddoc) REFERENCES estmat.docente MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE
);

--INSERT INTO estmat.materia VALUES ('IS214','Simulacion computacional','9603');
--INSERT INTO estmat.materia VALUES ('IS215','Desarrollo de software','9605');
--INSERT INTO estmat.materia VALUES ('IS216','Fundamentos de redes','9604');
--INSERT INTO estmat.materia VALUES ('IS217','Sistemas distribuidos','9604');
--INSERT INTO estmat.materia VALUES ('M112','Estadistica y probabilidad','9602');
--INSERT INTO estmat.materia VALUES ('M113','Metodos numericos','9601');

--["IS214" "Simulacion_computacional"],["IS215" "Desarrollo_de_software"],["IS216" "Fundamentos_de_redes"],["IS217" "Sistemas_distribuidos"],["M112" "Estadistica_y_probabilidad"],["M113", "Metodos_numericos"]

CREATE TABLE estmat.matricula (
    codest integer NOT NULL,
    codmat varchar(5) NOT NULL,
    calificacion real NOT NULL,
    FOREIGN KEY(codest) REFERENCES estmat.estudiante MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(codmat) REFERENCES estmat.materia MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY(codest,codmat)
);

--INSERT INTO estmat.matricula VALUES ('2010378AG','IS214','4.1');
--INSERT INTO estmat.matricula VALUES ('2010378AG','IS217','4.0');
--INSERT INTO estmat.matricula VALUES ('2010378FB','IS215','3.8');
--INSERT INTO estmat.matricula VALUES ('2010378FB','IS216','3.7');
--INSERT INTO estmat.matricula VALUES ('2010378FB','M112','3.4');
--INSERT INTO estmat.matricula VALUES ('2009378LV','IS214','4.1');
--INSERT INTO estmat.matricula VALUES ('2009378LV','M112','4.5');
--INSERT INTO estmat.matricula VALUES ('2009378LV','M113','3.6');
