
CREATE SCHEMA pedrest;

CREATE TABLE pedrest.cliente (
    idcli varchar(10) PRIMARY KEY,
    nombre varchar(15) NOT NULL,
    apellidos varchar(25) NOT NULL,
    nummov varchar(15) NOT NULL,
    nummov2 varchar(15) NULL
);

insert into pedrest.cliente values ('60890', 'Héctor M', 'Cabrera', '3003019082', '');

CREATE TABLE pedrest.categoria (
    idcat varchar(2) PRIMARY KEY,
    descp varchar(24) NOT NULL
);

insert into pedrest.categoria values('1','entrada');
insert into pedrest.categoria values('2','plato');
insert into pedrest.categoria values('3','postre');
insert into pedrest.categoria values('4','bebida');
insert into pedrest.categoria values('5','salsa');

CREATE TABLE pedrest.menu (
    idmenu varchar(4) PRIMARY KEY,
    idcat varchar(2) NOT NULL,--REFERENCES pedrest.categoria MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    descp varchar(196) NOT NULL,
    precio varchar(5) NOT NULL, -- integer
    FOREIGN KEY(idcat) REFERENCES pedrest.categoria MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE
);

insert into pedrest.menu values ('M1', '1', 'Tostadas', '4500');
insert into pedrest.menu values ('M2', '1', 'Pan con pasas', '3200');
insert into pedrest.menu values ('M3', '2', 'Spaghetti Napolitano', '16500');
insert into pedrest.menu values ('M4', '2', 'Lasagna', '18000');
insert into pedrest.menu values ('M5', '3', 'Brownie con helado', '6800');
insert into pedrest.menu values ('M6', '3', 'Helado', '5200');
insert into pedrest.menu values ('M7', '4', 'Limonada', '4500');
insert into pedrest.menu values ('M8', '4', 'Naranjada', '4500');
insert into pedrest.menu values ('M9', '5', 'Salsa tartara', '2300');
insert into pedrest.menu values ('M10', '5', 'Salsa holandesa', '2500');

CREATE TABLE pedrest.pedido (
    idcli varchar(10) NOT NULL,
    idped varchar(6) NOT NULL, -- p1 p2 p3 ... pN
    fecped date NOT NULL,
    FOREIGN KEY(idcli) REFERENCES pedrest.cliente MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY(idcli,idped,fecped)
);

insert into pedrest.pedido values('60890','p1','22/06/2014');
insert into pedrest.pedido values('60890','p2','24/06/2014');
insert into pedrest.pedido values('60890','p3','26/06/2014');
    
CREATE TABLE pedrest.detalle (
    idcli varchar(10) NOT NULL,
    idped varchar(6) NOT NULL, -- p1 p2 p3 ... pN
    fecped date NOT NULL,
    iddet varchar(4) NOT NULL, -- increment 1 2 3 ... n
    idmenu varchar(4) NOT NULL,
    cant varchar(5) NOT NULL, -- integer
    FOREIGN KEY(idcli,idped,fecped) REFERENCES pedrest.pedido MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY(idmenu) REFERENCES pedrest.menu MATCH FULL ON DELETE RESTRICT ON UPDATE CASCADE,
    PRIMARY KEY(idcli,idped,fecped,iddet,idmenu)
);

insert into pedrest.detalle values('60890','p1','22/06/2014','1','M1','1');
insert into pedrest.detalle values('60890','p1','22/06/2014','2','M3','1');
insert into pedrest.detalle values('60890','p1','22/06/2014','3','M7','1');
insert into pedrest.detalle values('60890','p2','24/06/2014','1','M5','2');
insert into pedrest.detalle values('60890','p3','26/06/2014','1','M9','1');
insert into pedrest.detalle values('60890','p3','26/06/2014','2','M10','1');
