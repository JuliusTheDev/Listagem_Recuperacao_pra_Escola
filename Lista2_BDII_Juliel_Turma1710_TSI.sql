 CREATE TYPE genero as enum('Feminino','Masculino','Outros');
 create TABLE selecao(
    codigo serial not null,
    nome VARCHAR(50) not null,
    pais VARCHAR(20),
    genero genero,
    PRIMARY KEY(codigo)
  );
 
 CREATE TABLE estadio(
    codigo serial not NULL,
    nome VARCHAR(50) not NULL,
    capacidade_maxima INTEGER,
    custo_construcao NUMERIC (15,2),
    data_fundacao DATE,
    PRIMARY KEY(codigo)  
  );
 
 CREATE TABLE jogador(
    codigo serial not null,
    nome VARCHAR(50) not NULL,
    data_nascimento date,
    salario NUMERIC(20,2),
    time VARCHAR(20),
    posicao VARCHAR(20),
    codigo_selecao int,
    PRIMARY KEY(codigo),
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
   );
 
 CREATE TABLE torcedor(
    codigo serial NOT NULL,
    nome VARCHAR(50) NOT NULL,
    data_nascimento DATE,
    renda NUMERIC (20,2),
    genero genero,
    codigo_selecao INT,
    PRIMARY KEY(codigo),
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
  );
 
 CREATE TYPE fase as enum('grupo', 'oitavas', 'quartas','semi','final');
 CREATE TABLE partida(
    codigo serial not NULL,
    nome VARCHAR(50) not NULL,
    data DATE,
    fase fase,
    valor_ingresso NUMERIC (10,2),
    quantidade_ingresso INTEGER,
    codigo_estadio int ,
    codigo_selecao_a int ,
    codigo_selecao_b INT,
    PRIMARY KEY(codigo),
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_selecao_a) REFERENCES selecao(codigo),
    FOREIGN KEY (codigo_selecao_b) REFERENCES selecao(codigo)
  );

 CREATE TABLE estadio_torcedor(
    codigo_estadio INT not NULL,
    codigo_torcedor INT NOT NULL,
    data date,
    PRIMARY KEY(codigo_estadio, codigo_torcedor),
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_torcedor) REFERENCES torcedor(codigo)
  );
 
 
  INSERT INTO selecao(nome, pais, genero)
  values('Brasileira','Brasil','Feminino');
  INSERT INTO selecao(nome, pais, genero)
  values('Italiana','Itália','Masculino');
  INSERT INTO selecao(nome, pais, genero)
  values('Inglesa','Inglaterra','Feminino');
 
  INSERT INTO estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
  values('Macaranã',100000,1000000000.00,'1958-11-19');
  INSERT INTO estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
  values('Estádio Supimpa',5000000,1000000.00,'1974-11-10');
  INSERT INTO estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
  values('Estádio Verde',57508838,5000000.00,'1955-08-16');
 
 
  INSERT INTO jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
  values('Harry Potter','1982-05-08',150000.00,'Brasil','Meio-Campo',1);
  INSERT INTO jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
  values('Tanajura Boots','1980-15-12',26000.00,'Arco-Íris','Goleira',2);
  INSERT INTO jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
  values('Possilga Silva','1936-05-29',500000.00,'Glamurosas','Atacante',3);
 
   
  INSERT INTO torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
  values('Khalel','1985-03-30', 55000,'Masculino',3);
  INSERT INTO torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
  values('Super Supra','1989-04-02',88000,'Masculino',2);
  INSERT INTO torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
  values('Supla','2014-01-23',520000,'Feminino',1);
 
  INSERT INTO partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio,codigo_selecao_a, codigo_selecao_b)
  values('Brasil X Itália','2023-11-02','semi', 1400.00,200000,3,1,1);
  INSERT INTO partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio,codigo_selecao_a, codigo_selecao_b)
  values('Itália X Inglaterra','2023-01-20','quartas', 1800.00,5000,2,3,3);
  INSERT INTO partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio,codigo_selecao_a, codigo_selecao_b)
  values('Brasil X México','2020-10-26','final', 2000.00,2500,3,2,2);
 
  INSERT INTO estadio_torcedor(codigo_estadio, codigo_torcedor, data)
  values(2,2,'2021-11-14');
  INSERT INTO estadio_torcedor(codigo_estadio, codigo_torcedor, data)
  values(3,1,'2021-11-02');
  INSERT INTO estadio_torcedor(codigo_estadio, codigo_torcedor, data)
  values(4,3,'2021-12-20');  

