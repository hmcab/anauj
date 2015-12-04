
INSERT INTO empven.dpto VALUES('DPTO1','Valle del cauca');
INSERT INTO empven.dpto VALUES('DPTO2','Amazonas');
INSERT INTO empven.dpto VALUES('DPTO3','Antioquia');

INSERT INTO empven.ciudad VALUES('DPTO1','CIU1', 'CALI');
INSERT INTO empven.ciudad VALUES('DPTO1','CIU2', 'PALMIRA');
INSERT INTO empven.ciudad VALUES('DPTO1','CIU3', 'TULUÁ');
INSERT INTO empven.ciudad VALUES('DPTO2','CIU4', 'LETICIA');
INSERT INTO empven.ciudad VALUES('DPTO2','CIU5', 'EL ENCANTO');
INSERT INTO empven.ciudad VALUES('DPTO2','CIU6', 'LA CHORRERA');
INSERT INTO empven.ciudad VALUES('DPTO3','CIU7', 'ABEJORRAL');
INSERT INTO empven.ciudad VALUES('DPTO3','CIU8', 'ABRIAQUI');
INSERT INTO empven.ciudad VALUES('DPTO3','CIU9', 'MEDELLÍN');

INSERT INTO empven.empleado VALUES('1001', 'hector m', 'cabrera murillo', 'cc', '06/08/1990', 'M', 'soulraster@gmail.com', 'cra 3 # 20', 'DPTO1', 'CIU2');
INSERT INTO empven.empleado VALUES('1002', 'laura c', 'cabrera murillo', 'cc', '09/03/1988', 'F', 'lau@gmail.com', 'cra 3 # 20', 'DPTO1', 'CIU2');
INSERT INTO empven.empleado VALUES('1003', 'andres f', 'murillo montoya', 'cc', '07/08/1993', 'M', 'mono@gmail.com', 'cra 14 # 22', 'DPTO1', 'CIU2');

INSERT INTO empven.empleado VALUES('1004', 'zeus', 'gil', 'cc', '02/05/1965', 'M', 'zeus@correo.com', 'cll 20 # 12-2', 'DPTO1', 'CIU1');
INSERT INTO empven.empleado VALUES('1005', 'poseidon', 'cano', 'cc', '08/05/1967', 'M', 'poseidon@correo.com', 'cll 21 # 14-3', 'DPTO1', 'CIU3');
INSERT INTO empven.empleado VALUES('1006', 'dionisio', 'ferrer', 'cc', '04/05/1968', 'M', 'dionisio@correo.com', 'cll 22 # 16-7', 'DPTO2', 'CIU4');
INSERT INTO empven.empleado VALUES('1007', 'apolo', 'vega', 'cc', '05/09/1969', 'M', 'apolo@correo.com', 'cll 23 # 17-9', 'DPTO2', 'CIU5');
INSERT INTO empven.empleado VALUES('1008', 'ares', 'medina', 'cc', '06/10/1970', 'M', 'ares@correo.com', 'cll 24 # 19-11', 'DPTO2', 'CIU6');

INSERT INTO empven.empleado VALUES('1009', 'hera', 'ruiz', 'cc', '03/05/1975', 'F', 'hera@correo.com', 'cll 20 # 12-2', 'DPTO1', 'CIU1');
INSERT INTO empven.empleado VALUES('1010', 'artemisa', 'rojas', 'cc', '11/05/1987', 'F', 'artemisa@correo.com', 'cra 56 # 14-3', 'DPTO3', 'CIU7');
INSERT INTO empven.empleado VALUES('1011', 'atenea', 'ortega', 'cc', '21/05/1988', 'F', 'atenea@correo.com', 'cra 67 # 16-7', 'DPTO3', 'CIU8');
INSERT INTO empven.empleado VALUES('1012', 'afrodita', 'garcia', 'cc', '07/09/1989', 'F', 'afrodita@correo.com', 'cra 34 # 17-9', 'DPTO3', 'CIU9');
INSERT INTO empven.empleado VALUES('1013', 'hebe', 'gil', 'cc', '06/10/1990', 'F', 'hebe@correo.com', 'cll 20 # 12-2', 'DPTO1', 'CIU1');

INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1001','01/02/2010','5500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1001','02/04/2010','4500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1001','03/06/2010','6500');

INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1002','01/02/2010','5500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1002','02/04/2010','7500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1002','03/06/2010','5500');

INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1003','01/02/2010','3500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1003','02/04/2010','6500');
INSERT INTO empven.ventas (numdoc,fecventa,totalventa) VALUES('1003','03/06/2010','7500');

