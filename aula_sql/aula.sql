CREATE TABLE tab_idade 
( 
 id_idade INTEGER GENERATED ALWAYS AS IDENTITY,  
 mun_idade_id INT NOT NULL,  
 CONSTRAINT id_idade PRIMARY KEY (id_idade)
); 

CREATE TABLE ref_mun 
( 
 id_mun INTEGER GENERATED ALWAYS AS IDENTITY,  
 nome_mun VARCHAR(100) NOT NULL,  
 codigo_ibge CHAR(7),  
 codigo_ibge_6 CHAR(6),  
 UNIQUE (codigo_ibge,codigo_ibge_6),
 CONSTRAINT id_mun PRIMARY KEY (id_mun)
); 

ALTER TABLE tab_idade ADD FOREIGN KEY(mun_idade_id) REFERENCES ref_mun (id_mun)



INSERT INTO ref_mun (nome_mun, codigo_ibge, codigo_ibge_6) VALUES
('São Paulo', '3550308', '355030'),
('Rio de Janeiro', '3304557', '330455'),
('Belo Horizonte', '3106200', '310620'),
('Brasília', '5300108', '530010'),
('Salvador', '2927408', '292740'),
('Fortaleza', '2304400', '230440'),
('Curitiba', '4106902', '410690'),
('Manaus', '1302603', '130260'),
('Recife', '2611606', '261160'),
('Porto Alegre', '4314902', '431490');



INSERT INTO ref_mun (nome_mun, codigo_ibge, codigo_ibge_6) VALUES
('Botucatu', '0000000', '000000');



------------------------------------------------------------
-- criando tabelas para base de dados
------------------------------------------------------------

CREATE TABLE projetinho.tab_idade 
( 
 id_idade INT GENERATED ALWAYS AS IDENTITY,  
 mun_idade_id INT NOT NULL,  
 sexo CHAR NOT NULL,  
 grupo_idade_id INT NOT NULL,  
 N INT NOT NULL,  
 CONSTRAINT pk_idade PRIMARY KEY (id_idade)
); 

CREATE TABLE projetinho.ref_mun 
( 
 id_mun INT GENERATED ALWAYS AS IDENTITY,  
 nome_mun VARCHAR NOT NULL,  
 codigo_ibge CHAR(7),  
 codigo_ibge_6 CHAR(6),  
 UNIQUE (codigo_ibge,codigo_ibge_6),  
 CONSTRAINT pk_mun PRIMARY KEY (id_mun)
); 

CREATE TABLE projetinho.ref_grupo_idade 
( 
 id_gi INT GENERATED ALWAYS AS IDENTITY,  
 grupo_idade VARCHAR NOT NULL,  
 UNIQUE (grupo_idade),  
 CONSTRAINT pk_gi PRIMARY KEY (id_gi)
); 

ALTER TABLE projetinho.tab_idade ADD FOREIGN KEY(mun_idade_id) REFERENCES projetinho.ref_mun (id_mun);
ALTER TABLE projetinho.tab_idade ADD FOREIGN KEY(grupo_idade_id) REFERENCES projetinho.ref_grupo_idade (id_gi);



-----------------------------
select mun_idade_id, nome_mun, SUM(n) FROM projetinho.tab_idade
LEFT JOIN projetinho.ref_mun ON mun_idade_id = id_mun
GROUP BY
mun_idade_id, nome_mun
HAVING nome_mun LIKE 'Botucatu%'




---------------------------------------------------------------

CREATE TABLE projetinho.ref_raca 
( 
 id_raca INT GENERATED ALWAYS AS IDENTITY,  
 raca VARCHAR,  
 UNIQUE (raca),
 CONSTRAINT pk_ref_raca PRIMARY KEY (id_raca) 
); 

CREATE TABLE projetinho.tab_raca 
( 
 id_tabraca INT GENERATED ALWAYS AS IDENTITY,  
 raca_id INT,  
 mun_raca_id INT,  
 N INT NOT NULL, 
 CONSTRAINT pk_raca PRIMARY KEY (id_tabraca) 
); 

ALTER TABLE projetinho.tab_raca ADD FOREIGN KEY(raca_id) REFERENCES projetinho.ref_raca (id_raca);
ALTER TABLE projetinho.tab_raca ADD FOREIGN KEY(mun_raca_id) REFERENCES projetinho.ref_mun (id_mun)





CREATE TABLE projetinho.ref_renda 
( 
 id_renda INT GENERATED ALWAYS AS IDENTITY,  
 renda VARCHAR,  
 UNIQUE (renda), 
 CONSTRAINT pk_renda PRIMARY KEY (id_renda)
); 

CREATE TABLE projetinho.tab_renda 
( 
 id_tab_renda INT GENERATED ALWAYS AS IDENTITY,  
 renda_id INT,  
 mun_renda_id INT,  
 n INT NOT NULL, 
 CONSTRAINT pk_ref_renda PRIMARY KEY (id_tab_renda) 
); 

ALTER TABLE projetinho.tab_renda ADD FOREIGN KEY(renda_id) REFERENCES projetinho.ref_renda (id_renda);
ALTER TABLE projetinho.tab_renda ADD FOREIGN KEY(mun_renda_id) REFERENCES projetinho.ref_mun (id_mun)

--------------------------------------------------
-- Fazendo algumas queries

SELECT codigo_ibge, nome_mun, grupo_idade, grupo_idade_id, SUM(n) FROM projetinho.tab_idade LEFT JOIN projetinho.ref_grupo_idade ON
grupo_idade_id = id_gi LEFT JOIN projetinho.ref_mun ON mun_idade_id = id_mun
GROUP BY codigo_ibge, nome_mun, grupo_idade, grupo_idade_id
ORDER BY nome_mun, grupo_idade_id


----------------------------------------------------
WITH tabela_idade AS (
    SELECT mun_idade_id, SUM(n) AS soma_idade FROM "projetinho"."tab_idade" WHERE grupo_idade_id > 12 GROUP BY mun_idade_id
),
tabela_renda AS (
    SELECT mun_renda_id, SUM(n) AS soma_renda FROM "projetinho"."tab_renda"
	WHERE renda_id = 12 OR renda_id BETWEEN 1 AND 4
	GROUP BY mun_renda_id
),
tabela_total AS (
    SELECT mun_idade_id as mun_total_id, SUM(n) AS soma_total FROM "projetinho"."tab_idade" GROUP BY mun_idade_id
)
SELECT mun_idade_id AS mun_id, soma_idade, soma_renda, soma_total FROM tabela_idade INNER JOIN tabela_renda ON
mun_idade_id = mun_renda_id INNER JOIN tabela_total ON mun_idade_id = mun_total_id;