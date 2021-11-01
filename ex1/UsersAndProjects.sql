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

---CONSULTAS
SELECT id, name, email, username, 
CASE WHEN (password != '123mudar') THEN '******' ELSE password END AS senha 
FROM users

SELECT name, description, CONVERT(CHAR(11), data_inicio, 103) AS inicio, CONVERT(CHAR(11), DATEADD(DAY, 3, data_inicio), 103) as fim 
FROM projects 
WHERE id = 10001

SELECT name, email FROM users
WHERE id in
( 
SELECT users_id FROM users_has_projects 
WHERE projects_id in 
(SELECT id FROM projects 
WHERE name = 'Auditoria')
)

SELECT name, description, 
CONVERT(CHAR(10), data_inicio, 103) AS inicio,
CONVERT(CHAR(10), DATEADD(DAY, 4, data_inicio), 103 ) AS fim,
(79.85 * DATEDIFF(DAY, data_inicio, DATEADD(DAY,4, data_inicio))) AS custo_total
FROM projects 
WHERE name LIKE '%Manutenção%'
	
---RESETAR IDENT
DBCC CHECKIDENT(projects, RESEED, 10001);

DELETE from projects 

--CHECAR COLUNAS DE UMA TABELA
exec sp_columns users
exec sp_columns projects
exec sp_columns users_has_projects

select GETDATE(); 

drop table users






