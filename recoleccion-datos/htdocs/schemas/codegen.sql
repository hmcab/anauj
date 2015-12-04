

CREATE TABLE usuario (
	email character varying(32) PRIMARY KEY,
	nombre varchar(15) NOT NULL,
	apellidos varchar(25) NOT NULL,
	fecnac date NULL,
	sexo varchar(1) NOT NULL, -- F M
	pass varchar(256) NOT NULL,
	confpass varchar(256) NOT NULL,
	CHECK (sexo in ('F', 'M'))
);

CREATE TABLE esquema (
	nomesq varchar(20) PRIMARY KEY
);

CREATE TABLE proyecto (
	email character varying(32) REFERENCES usuario MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
	nomesq character(20) REFERENCES esquema MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY(email,nomesq)
);

INSERT INTO usuario VALUES ('soulraster@gmail.com', 'hector mauricio', 'cabrera murillo', '06/08/1990', 'M', 'hector', 'hector');
INSERT INTO usuario VALUES ('usuario@gmail.com', 'usuario', 'usuario', '01/03/1990', 'M', 'usuario', 'usuario');

INSERT INTO esquema VALUES ('empven');
INSERT INTO esquema VALUES ('estmat');

INSERT INTO proyecto VALUES ('soulraster@gmail.com', 'empven');
INSERT INTO proyecto VALUES ('soulraster@gmail.com', 'estmat');
INSERT INTO proyecto VALUES ('usuario@gmail.com', 'empven');
INSERT INTO proyecto VALUES ('usuario@gmail.com', 'estmat');

