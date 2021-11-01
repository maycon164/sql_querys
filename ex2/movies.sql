CREATE DATABASE movie;
USE movie;

---------------------- CRIANDO AS TABELAS

CREATE TABLE cliente(
	id INT NOT NULL,
	nome VARCHAR(70),
	logradouro VARCHAR(150),
	num INT CHECK(num > 0),
	cep CHAR(8) CHECK (LEN(cep) = 8),
	PRIMARY KEY(id)
)

CREATE TABLE filme(
	id INT NOT NULL,
	titulo VARCHAR(40),
	ano INT CHECK(ano <= 2021),
	PRIMARY KEY(id)
)

CREATE TABLE dvd(
	id INT NOT NULL,
	data_fabricacao DATE CHECK(data_fabricacao < GETDATE()),
	id_filme  INT NOT NULL,
	
	PRIMARY KEY(id),
	FOREIGN KEY (id_filme) REFERENCES filme(id)
)

CREATE TABLE locacao(
	id_cliente INT NOT NULL,
	id_dvd INT NOT NULL,
	data_locacao DATE DEFAULT(GETDATE()),
	data_devolucao DATE,
	valor DECIMAL(7,2) CHECK(valor > 0),
	
	PRIMARY KEY(id_cliente, id_dvd, data_locacao),
	FOREIGN KEY(id_cliente) REFERENCES cliente(id),
	FOREIGN KEY(id_dvd) REFERENCES dvd(id),

	CHECK(data_devolucao > data_locacao)
)

CREATE TABLE estrela(
	id INT NOT NULL,
	nome VARCHAR(50),
	PRIMARY KEY(id)
)

CREATE TABLE filme_estrela(
	id_filme INT NOT NULL,
	id_estrela INT NOT NULL,
	
	PRIMARY KEY(id_filme, id_estrela),
	FOREIGN KEY (id_filme) REFERENCES filme(id),
	FOREIGN KEY (id_estrela) REFERENCES estrela(id)
)

---------------------- MODIFICANDO AS TABELAS
ALTER TABLE estrela 
	ADD nome_real VARCHAR(50);

ALTER TABLE filme
	ALTER COLUMN titulo VARCHAR(80);
	
---------------------- ADICIONANDO VALORES NAS TABELAS
INSERT INTO filme (id, titulo, ano) VALUES
(1001, 'Whiplash', 2015),
(1002, 'Birdman', 2015),
(1003, 'Interestelas', 2014),
(1004, 'A Culpa é das estrelas', 2014),
(1005, 'Alexandre e o Dia Terrível, Horrível, Espantoso e Horroroso', 2014),
(1006, 'Sing', 2016)

SELECT * FROM filme;

INSERT INTO estrela(id, nome, nome_real) VALUES
(9901, 'Michael Keaton', 'Michael John Douglas'),
(9902, 'Emma Stone', 'Emily Jean Stone'),
(9903, 'Miles Teller', NULL),
(9904, 'Steve Carell', 'Steven John Carell'),
(9905, 'Jennifer Garner', 'Jennifer Anne Garner')

SELECT * FROM estrela;

INSERT INTO filme_estrela (id_filme, id_estrela) VALUES
(1002, 9901),
(1002, 9902),
(1001, 9903),
(1005, 9904),
(1005, 9905)

SELECT * FROM filme_estrela;

INSERT INTO dvd (id, data_fabricacao, id_filme) VALUES
(10001, '2020-12-02', 1001),
(10002, '2019-10-18', 1002),
(10003, '2020-04-03', 1003),
(10004, '2020-12-02', 1001),
(10005, '2019-10-18', 1004),
(10006, '2020-04-03', 1002),
(10007, '2020-12-02', 1005),
(10008, '2019-10-18', 1002),
(10009, '2020-04-03', 1003)

SELECT * FROM dvd;

INSERT INTO cliente(id, nome, logradouro, num, cep) VALUES
(5501, 'Matilde Luz', 'Rua Síria', 150, '03086040'),
(5502, 'Carlos Carreiro', 'Rua Bartolomeu Aires', 1250, '04419110'),
(5503, 'Daniel Ramalho', 'Rua Itajutiba', 169, NULL),
(5504, 'Roberta Bento', 'Rua Jayme Von Rosenburg', 36, NULL),
(5505, 'Rosa Cerqueira', 'Rua Arnaldo Simões Pinto', 235, '02917110')

SELECT * FROM cliente;

INSERT INTO locacao(id_dvd, id_cliente, data_locacao, data_devolucao, valor) VALUES
(10001, 5502, '2021-02-18', '2021-02-21', 3.50),
(10009, 5502, '2021-02-18', '2021-02-21', 3.50),
(10002, 5503, '2021-02-18', '2021-02-19', 3.50),

(10002, 5505, '2021-02-20', '2021-02-23', 3.00),
(10004, 5505, '2021-02-20', '2021-02-23', 3.00),
(10005, 5505, '2021-02-20', '2021-02-23', 3.00),

(10001, 5501, '2021-02-24', '2021-02-26', 3.50),
(10008, 5501, '2021-02-24', '2021-02-26', 3.50)

SELECT * FROM locacao;

---------------------- UPDATES 
SELECT * FROM cliente

--- updates em cliente
UPDATE cliente
	SET cep = '08411150'
	WHERE id = 5503

UPDATE cliente
	SET cep = '02918190'
	WHERE id = 5504

--- update em locacoes
UPDATE locacao
	SET valor = 3.25
	WHERE id_cliente = 5502
	
UPDATE locacao 
	SET valor = 3.10
	WHERE id_cliente = 5501
	
SELECT * FROM locacao
	WHERE id_cliente = 5501

--- update em dvd

UPDATE dvd
	SET data_fabricacao = '2019-07-14'
WHERE id = 10005
	
SELECT * FROM dvd	
	WHERE id = 10005

--- update em estrela
UPDATE estrela
	SET nome_real = 'Miles Alexander Teller'
WHERE id = 9903
	
SELECT * FROM estrela	
	WHERE id = 9903

--- delete em filme

DELETE filme
	WHERE id = 1006
	
---------------------- CONSULTAS

/*1) Fazer uma consulta que retorne ID, Ano, nome do Filme (Caso o nome do filme tenha
mais de 10 caracteres, para caber no campo da tela, mostrar os 10 primeiros
caracteres, seguidos de reticências ...) dos filmes cujos DVDs foram fabricados depois
de 01/01/2020*/

SELECT id, 
	CASE WHEN (len(titulo) > 10)
		THEN SUBSTRING(titulo, 1, 10) + '...'
		ELSE titulo
		END AS titulo,
	ano 
FROM filme
WHERE id in
	(SELECT id_filme FROM dvd WHERE data_fabricacao < '2020-01-01')

/*
 * 2) Fazer uma consulta que retorne num, data_fabricacao, qtd_meses_desde_fabricacao
(Quantos meses desde que o dvd foi fabricado até hoje) do filme Interestelar
 */

SELECT id, data_fabricacao, DATEDIFF(MONTH, data_fabricacao, GETDATE()) as meses 
FROM dvd
WHERE id_filme in 
	(SELECT id FROM filme WHERE titulo LIKE '%Interestelar%' )

/*
 * 3) Fazer uma consulta que retorne num_dvd, data_locacao, data_devolucao,
dias_alugado(Total de dias que o dvd ficou alugado) e valor das locações da cliente que
tem, no nome, o termo Rosa
 * */
	
SELECT id_dvd, data_locacao, data_devolucao, DATEDIFF(DAY, data_locacao, data_devolucao) as dias_alugados, valor
FROM locacao 
	WHERE id_cliente in 
	(SELECT id FROM cliente WHERE nome LIKE '%Rosa%')

/*4) Nome, endereço_completo (logradouro e número concatenados), cep (formato
XXXXX-XXX) dos clientes que alugaram DVD de num 10002.
 * */

SELECT nome, CONCAT(logradouro, ' - ', num) as endereco_completo,  
(SUBSTRING(cep, 1, 5) + '-' + SUBSTRING(cep, 6, 8)) as cep
FROM cliente
WHERE id IN
	(SELECT id_cliente FROM locacao WHERE id_dvd = 10002)

--- tabelas colunas
exec sp_columns estrela;
exec sp_columns filme;
exec sp_columns dvd;
exec sp_columns cliente;
exec sp_columns locacao;

select GETDATE(); 







