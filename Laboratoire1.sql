-- Création de la base de données
CREATE DATABASE StockClg;
GO

USE StockClg;
GO

-- Création des tables
CREATE TABLE Clients (
    idClient SMALLINT PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    typeClient CHAR(1) DEFAULT 'r' CHECK (typeClient IN ('r', 'o', 'v')),
    adresse VARCHAR(50)
);

CREATE TABLE Articles (
    idArticle SMALLINT PRIMARY KEY,
    descriptions VARCHAR(30) NOT NULL,
    prix MONEY NOT NULL CHECK (prix > 0),
    quantiteStock SMALLINT NOT NULL CHECK (quantiteStock >= 1)
);

CREATE TABLE Commandes (
    idCommande INT PRIMARY KEY,
    dateCommande DATE NOT NULL,
    idClient SMALLINT NOT NULL FOREIGN KEY REFERENCES Clients(idClient)
);

CREATE TABLE LigneCommande (
    idCommande INT NOT NULL FOREIGN KEY REFERENCES Commandes(idCommande),
    idArticle SMALLINT NOT NULL FOREIGN KEY REFERENCES Articles(idArticle),
    quantiteCommande INT NOT NULL CHECK (quantiteCommande >= 1),
    montant MONEY,
    PRIMARY KEY (idCommande, idArticle)
);

-- Insertion des données
INSERT INTO Clients (idClient, nom, prenom, typeClient, adresse) VALUES 
(1, 'Patoche','Alain','v','14 rue Jupiter, Montréal'),
(2, 'LeRoy','Singe','v','11 avenue de la Lune, Laval'),
(3, 'LeRigolo','Coluche','r','177 rue de Venus, Montréal'),
(4, 'Lefou','Ducoin','o','12 rue de Saturne Laval');
INSERT INTO Clients (idClient, nom, prenom, typeClient, adresse) VALUES (5, 'Le magnifique','Simba','r','789 rue des Chats, Laval');
INSERT INTO Clients (idClient, nom, prenom, typeClient, adresse) VALUES (6, 'Ce client','prenom','r','789 rue des clients, Montréal');

INSERT INTO Articles (idArticle, descriptions, prix, quantiteStock) VALUES
(1, 'Imprimantes Laser HP 8000',700,20),
(2, 'Écrans tactiles 19p',550,45),
(3, 'Routeurs sans fils Azus',200,75),
(4, 'Disques durs SSD 500 Go',175,45);
INSERT INTO Articles (idArticle, descriptions, prix, quantiteStock) VALUES (5, 'Chaises de bureau',400,20);
INSERT INTO Articles (idArticle, descriptions, prix, quantiteStock) VALUES (6, 'Cet Article',400,5);
INSERT INTO Articles (idArticle, descriptions, prix, quantiteStock) VALUES (7, 'Mon article',100,10);

-- Vérification des Clients avant insertion dans Commandes
SELECT * FROM Clients;

INSERT INTO Commandes (idCommande, dateCommande, idClient) VALUES
(10, '2023-08-21',1),
(11, '2023-08-28',1),
(12, '2022-12-05',1),
(13, '2022-11-17',2),
(14, '2022-09-12',2),
(15, '2023-08-12',3);

-- Vérification des Commandes avant insertion dans LigneCommande
SELECT * FROM Commandes;

INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (10,1,2), (10,2,3), (10,3,5), (10,4,6);
INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (11,4,2), (11,3,3);
INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (12,3,5);
INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (13,1,1), (13,2,5), (13,3,6);
INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (14,3,1), (14,4,1);
INSERT INTO LigneCommande (idCommande, idArticle, quantiteCommande) VALUES (15,3,1);

-- Question 2 : Requêtes
-- 1. Liste des clients de Montréal
SELECT * FROM Clients WHERE adresse LIKE '%Montréal%';

-- 2. Description des articles commandés par le client 'Patoche' dans la commande numéro 10
SELECT a.descriptions FROM Articles a
JOIN LigneCommande lc ON a.idArticle = lc.idArticle
JOIN Commandes c ON lc.idCommande = c.idCommande
JOIN Clients cl ON c.idClient = cl.idClient
WHERE cl.nom = 'Patoche' AND c.idCommande = 10;

-- 3. Clients n'ayant fait aucune commande
SELECT * FROM Clients WHERE idClient NOT IN (SELECT DISTINCT idClient FROM Commandes);

-- 4. Articles avec leur quantité commandée (y compris ceux non commandés)
SELECT a.idArticle, a.descriptions, COALESCE(SUM(lc.quantiteCommande), 0) AS quantite_commande
FROM Articles a
LEFT JOIN LigneCommande lc ON a.idArticle = lc.idArticle
GROUP BY a.idArticle, a.descriptions;

-- 5. Nombre de commandes passées par 'Patoche'
SELECT COUNT(*) FROM Commandes c
JOIN Clients cl ON c.idClient = cl.idClient
WHERE cl.nom = 'Patoche';

-- 6. Nombre total de commandes par client
SELECT cl.nom, COUNT(c.idCommande) AS total_commandes
FROM Clients cl
LEFT JOIN Commandes c ON cl.idClient = c.idClient
GROUP BY cl.nom;

-- Question 3 : Manipulations avancées
-- 1. Insertion avec IDENTITY_INSERT
SET IDENTITY_INSERT Clients ON;
INSERT INTO Clients (idClient, nom, prenom, adresse) VALUES (50, 'Lenom', 'Leprenom', 'l’Adresse');
SET IDENTITY_INSERT Clients OFF;

-- 2. Vérification de l'auto-incrémentation après désactivation de IDENTITY_INSERT
INSERT INTO Clients (nom, prenom, adresse) VALUES ('AutreNom', 'AutrePrenom', 'AutreAdresse');
SELECT * FROM Clients;

-- 3. Justification de IDENTITY sur LigneCommande
-- Non nécessaire car il s'agit d'une clé primaire composite

-- 4. Affichage du type de client formaté
SELECT nom, prenom, 
CASE typeClient 
    WHEN 'v' THEN 'VIP'
    WHEN 'r' THEN 'Régulier'
    WHEN 'o' THEN 'Occasionnel'
END AS type_client 
FROM Clients;

GO
CREATE VIEW Vcommande_Client AS
SELECT c.idCommande, cl.nom, SUM(lc.montant) AS total_commande
FROM Commandes c
JOIN Clients cl ON c.idClient = cl.idClient
JOIN LigneCommande lc ON c.idCommande = lc.idCommande
GROUP BY c.idCommande, cl.nom;
GO
