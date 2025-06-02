go
use EmpclgDB;


DROP TABLE IF EXISTS EmpFormations, EmpPermanent, EmpTemporaire, EmployesClg, Departements, Formations;

--------------------------------------------------------------------------

create table EmployesClg
(
empno int identity(1,1),
nom varchar (30) not null,
prenom varchar (30) not null,
typeEmploye char(1) not null constraint ckemp check (typeEmploye ='P' or typeEmploye ='T'),
constraint pkemp primary key(empno),
adresse varchar(60)
);

Create table Departements
(
deptno char(3) constraint pkdept primary key,
nomdepartement varchar(30) not null
);

create table EmpPermanent
(
empno int not null,
salaire money not null,
echelon smallint not null,
soldeFormation money not null default 15000,
deptno Char(3),
constraint fkemp foreign key(empno) references employesClg(empno),
constraint fkdep foreign key(deptno) references Departements(deptno),
constraint pkpermanent primary key (empno),
);


create table EmpTemporaire
(
empno int not null,
TauxHoraire money not null,
nbHeureMin smallint not null,
constraint fkemp2 foreign key(empno) references employesClg(empno),
constraint pktemporaire primary key (empno),
);

create table Formations
(
idformation int identity(1,1), 
description varchar(40) ,
coutMinimum money not null,
coutMaximum money not null,
duree int not null,
nbPlacesDisponibles int not null,
constraint pk_formation primary key(idformation)
);

create table EmpFormations
(
idformation int not null,
empno int not null,
dateFromation date not null,
lieu varchar(40) not null,
coutreel money not null,
constraint fk_formation Foreign key(idformation) references formations(idformation),
constraint fk_empformation foreign key (empno) references EmpPermanent(empno),
constraint pk_inscription primary key(idformation,empno)
);



-- insertions----

insert into Departements values
(1, 'informatique'),
(2, 'Ressources humaines'),
(3, 'Achats');

select * from EmployesClg;
--- les employes
insert into employesClg values
('Patoche', 'Alain','P','125 rue de jupiter Montr�al'),
('Saturne', 'Lune','P','12 rue de la soif Laval'),
('Fafar', 'Kelly','P','170 rue des chats Monr�al'),
('Monsieur', 'Spock','P','12 avenue de la lib�rt�,Laval'),
('Lechat', 'Simba','P','12 chemin du roi Montr�al'),
('Bien', 'Alain','T','1756 boulevard st-Pierre'),
('Saturne', 'Lune','T','33 avenue du bonheur Laval' ),
('Simpson', 'Homer','T','22 ici Montr�al'),
('Fafar', 'Ruby','P','33 rue CLG'); 

insert into EmpPermanent(empno,salaire,echelon,deptno) values(1,90000,17,1);
insert into EmpPermanent (empno,salaire,echelon,deptno) values(2,120000,23,1);
insert into EmpPermanent (empno,salaire,echelon,deptno) values(3,75000,17,1);
insert into EmpPermanent (empno,salaire,echelon,deptno) values(4,96000,17,1);
insert into EmpPermanent (empno,salaire,echelon,deptno) values(5,45000,11, 3);
insert into EmpPermanent (empno,salaire,echelon,deptno) values(9,60000,13, 3);
insert into EmpTemporaire values(6,65,10);
insert into EmpTemporaire values(7,25,20);
insert into EmpTemporaire values(8,100,5);

--- table formations
insert into formations values('Oracle Administration',5000, 10000,20,30);
insert into formations values('Oracle SQL',2500, 5000,30,10);
insert into formations values('Oracle PL/SQL',2500,6000 ,15,20);
insert into formations values('Livres comptables',2500,3500 ,4,10);


/*Q2-6*/
go
CREATE FUNCTION moyenneSalaireParDepartement()
RETURNS TABLE
AS
RETURN (
    SELECT d.nomdepartement, AVG(e.salaire) AS moyenne_salaire
    FROM EmpPermanent e
    JOIN Departements d ON e.deptno = d.deptno
    GROUP BY d.nomdepartement
);
go
/**Q2-7*/

CREATE FUNCTION coutMoyenFormation(@nomDept VARCHAR(30))
RETURNS MONEY
AS
BEGIN
    DECLARE @coutMoyen MONEY;
    
    SELECT @coutMoyen = AVG(f.coutMinimum + f.coutMaximum) / 2
    FROM Formations f
    JOIN EmpFormations ef ON f.idformation = ef.idformation
    JOIN EmpPermanent ep ON ef.empno = ep.empno
    JOIN Departements d ON ep.deptno = d.deptno
    WHERE d.nomdepartement = @nomDept;

    RETURN @coutMoyen;
END;
go
