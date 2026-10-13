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