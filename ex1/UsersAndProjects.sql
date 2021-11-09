CREATE DATABASE projetos;
USE projetos;

----CRIAÇÃO DAS TABELAS
CREATE TABLE users(
	
	id INT IDENTITY(1, 1) ,
	name VARCHAR(45),
	username VARCHAR(45),
	password VARCHAR(45) DEFAULT('123mudar') NOT NULL,
	email VARCHAR(45),
	
	CONSTRAINT pk_user PRIMARY KEY (id)
) 

CREATE TABLE projects(

	id INT IDENTITY(10001, 1),
	name VARCHAR(45),
	description VARCHAR(45),
	data_inicio DATETIME CHECK(data_inicio > 2014-09-01),
	
	CONSTRAINT pk_project PRIMARY KEY (id)
)

CREATE TABLE users_has_projects(
	
	users_id INT NOT NULL,
	projects_id INT NOT NULL,
	
	FOREIGN KEY (users_id) REFERENCES users(id),
	FOREIGN KEY (projects_id) REFERENCES projects(id)
)

---MODIFICAÇÕES NAS COLUNAS
ALTER TABLE users
	ALTER COLUMN username VARCHAR(10) 
	
ALTER TABLE users
	ADD UNIQUE (username)

ALTER TABLE users
	ALTER COLUMN password VARCHAR(8)  NOT NULL

ALTER TABLE users_has_projects
	ADD CONSTRAINT pk_primary_key PRIMARY KEY (users_id, projects_id)
	
EXEC sp_columns users_has_projects
	
DROP TABLE users_has_projects;
DROP TABLE projects;
DROP TABLE users;

---INSERINDO DADOS NAS TABELAS
INSERT INTO users (name, username, password, email) VALUES 
('Maria', 'Rh_maria', default, 'maria@empresa.com'),
('Paulo', 'Ti_paulo', '123@456', 'paulo@empresa.com'),
('Ana', 'Rh_ana', default, 'ana@empresa.com'),
('Clara', 'Ti_clara', default, 'clara@empresa.com'),
('Aparecido', 'Rh_apareci', '55@!cido', 'aparecido@empresa.com')

INSERT INTO projects (name, description, data_inicio) VALUES
('Re-folha', 'Refatoração das folhas', '2014-09-05'),
('Manutenção de PCs', 'Manutenção de PCS', '2014-09-06'),
('Auditoria', null, '2014-09-07')

INSERT INTO users_has_projects (users_id, projects_id) VALUES
(1, 10001),
(5, 10001),
(3, 10003),
(4, 10002),
(2, 10002)

SELECT * FROM users;
SELECT id, name, CONVERT(CHAR(11), data_inicio, 103) as data FROM projects;
SELECT * FROM users_has_projects

---ALTERAÇÕES NAS DADOS DA TABELA
UPDATE projects 
	SET data_inicio = '2014-09-12'
	WHERE id = 10002

UPDATE users
	SET username = 'Rh_cido'
	WHERE name = 'Aparecido'
	
UPDATE users
	SET password = '888@*'
	WHERE username = 'Rh_maria' AND password = '123mudar'

DELETE FROM users_has_projects 
WHERE users_id = 2 AND projects_id = 10002

----------------------------------CONSULTAS

--- 1 
SELECT id, name, email, username, 
CASE WHEN (password != '123mudar') THEN '********' ELSE password END AS senha 
FROM users

--- 2
SELECT name, description, 
CONVERT(CHAR(11), data_inicio, 103) AS inicio, 
CONVERT(CHAR(11), DATEADD(DAY, 3, data_inicio), 103) as fim 
FROM projects 
WHERE id = 10001

---3
SELECT name, email FROM users
WHERE id in
( 
SELECT users_id FROM users_has_projects 
WHERE projects_id in 
(SELECT id FROM projects 
WHERE name = 'Auditoria')
)

---4
SELECT name, description, 
CONVERT(CHAR(10), data_inicio, 103) AS inicio,
CONVERT(CHAR(10), DATEADD(DAY, 4, data_inicio), 103 ) AS fim,
(79.85 * DATEDIFF(DAY, data_inicio, DATEADD(DAY,4, data_inicio))) AS custo_total
FROM projects 
WHERE name LIKE '%Manutenção%'
	
---RESETAR IDENT
DBCC CHECKIDENT(projects, RESEED, 10001);
DELETE from projects 

-------------------------------CONSULTAS COM JOINS

/*1) Id, Name e Email de Users, Id, Name, Description e Data de Projects, dos usuários que
participaram do projeto Name Re-folha
*/
SELECT u.id AS id_user, u.name AS name_user, u.email,
p.id AS id_project, p.name AS name_project, p.description,
CONVERT(CHAR(11), p.data_inicio, 103) AS data_inicio_projeto
FROM users u, projects p, users_has_projects uhp
WHERE u.id = uhp.users_id 
AND p.id = uhp.projects_id 
AND p.name = 'RE-folha'

/*2) Name dos Projects que não tem Users
 * 
 * DADOS QUE ESTÃO NA TABELA projects, mas não estão na tabela associativa de
 * user_has_projects
 * retorna vazio, pois todos os projetos tem ao menos 1 user
 * */

SELECT p.name
FROM projects AS p
LEFT OUTER JOIN users_has_projects AS uhp
ON p.id = uhp.projects_id 
WHERE uhp.projects_id IS NULL

SELECT * FROM projects p 
SELECT * FROM users_has_projects uhp 

--APENAS PARA TESTE 
--user has project '3, 10003'

DELETE users_has_projects
	WHERE users_id = 3 AND projects_id = 10003

INSERT INTO users_has_projects 
VALUES(3, 10003)

/*3) Name dos Users que não tem Projects
 * A IDEIA AQUI É A MESMA
 * */
SELECT u.*
FROM users u
LEFT OUTER JOIN users_has_projects uhp 
ON u.id = uhp.users_id 
WHERE uhp.users_id IS NULL

SELECT * FROM users u 
SELECT * FROM users_has_projects uhp 	

--CHECAR COLUNAS DE UMA TABELA
exec sp_columns users
exec sp_columns projects
exec sp_columns users_has_projects

