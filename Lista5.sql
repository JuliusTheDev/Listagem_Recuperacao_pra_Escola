
create type genero_enum as enum ('feminino', 'masculino', 'outros');
create table selecao(
	codigo serial not null, 
	nome varchar(50) not null, 
	pais varchar(50), 
	genero genero_enum,
	primary key(codigo)
);

insert into selecao(nome, pais, genero)
values('Francesa', 'Franca', 'feminino');
insert into selecao(nome, pais, genero)
values('Mexicana', 'México', 'feminino');
insert into selecao(nome, pais, genero)
values('Americana', 'EUA', 'feminino');

  
create table estadio(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	capacidade_maxima int, 
	custo_construcao numeric(20,2), 
	data_fundacao date
);

insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Tananã', 58000, 4000000000, '1940-09-14');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Lalala', 65000, 2000000000, '1976-02-08');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('França Term', 12500, 1000000, '1998-11-24');

create table jogador(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	salario numeric(20,2), 
	time varchar(50), 
	posicao varchar(50), 
	codigo_selecao int,
	foreign key(codigo_selecao) references selecao(codigo)
);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Joana','1984-03-17', 4000000, 'Corinthians', 'Atacante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Barata','1988-02-13', 12000000, 'Santos', 'Volante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Kali','1990-08-16', 25500000, 'Sao Paulo', 'Goleira', 3);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Amada','2011-01-14', 4100000, 'Gremio', 'Lateral', 2);

create type fase_enum as enum ('grupo','oitavas', 'quartas', 'semi', 'final');

create table partida(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data timestamp, 
	fase fase_enum, 
	valor_ingresso numeric(8,2), 
	quantidade_ingresso int, 
	codigo_estadio int references estadio(codigo),     
	codigo_selecao_a int references selecao(codigo), 
	codigo_selecao_b int references selecao(codigo)
);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Final da Copa', '2023-08-20 06:00:00', 'final', 15000, 78000, 1, 3, 3);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Disputa Terceiro Lugar', '2023-08-19 06:00:00', 'final', 5000, 2500, 3, 2, 1);

insert into partida(nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values('Grupo A', '2023-07-24 06:00:00', 'grupo', 1000, 78000, 2, 1, 2);

create table torcedor(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	data_nascimento date, 
	renda numeric(20,2), 
	genero genero_enum, 
	codigo_selecao int references selecao(codigo)
);

insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulano', '1959-08-26', 2587416, 'masculino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Ciclano', '1959-09-07', 2587416, 'feminino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Chouriço', '1984-04-01', 10, 'masculino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Sandra Madalena', '1965-11-12', 5000, 'feminino', 3);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Hermione', '1984-10-22', 900000, 'feminino', 2);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Harry', '2005-01-20', 150, 'masculino', 2);

create table estadio_torcedor(
	codigo_estadio int references estadio (codigo), 
	codigo_torcedor int references torcedor(codigo), 
	data timestamp,
	primary key(codigo_estadio, codigo_torcedor)
);

insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(1, 2, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(3, 1, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(2, 2, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(3, 3, current_timestamp);
insert into estadio_torcedor(codigo_estadio, codigo_torcedor, data)
values(2, 1, current_timestamp);

--1) Selecione o nome das jogadoras, data de nascimento, idade em anos e o nome da seleção que
--cada uma joga. Considere que todas as datas devem sair no formato DD/MM/YYYY. Ordene a saída
--pela data de nascimento.

SELECT j.nome AS nome_da_jogadora,
TO_CHAR(j.data_nascimento, 'DD/MM/YYYY') AS data_de_nascimento,
EXTRACT(YEAR FROM AGE(j.data_nascimento)) AS idade,
s.nome AS nome_da_selecao
FROM jogador j  
JOIN selecao s ON j.codigo_selecao = s.codigo
WHERE s.genero = 'feminino'
ORDER BY j.data_nascimento;

select *
from selecao;
SELECT * 
from jogador;

--2) Selecione o nome da(s) partidas(s) mais caras.
SELECT nome as nome_partida_mais_cara
FROM partida
WHERE valor_ingresso = (SELECT MAX(valor_ingresso) FROM partida);

--3) Selecione o nome da partida e das seleções que disputaram a(s) partida(s) com o ingresso mais
--barato.
SELECT nome as nome_partida_mais_barata
FROM partida
WHERE valor_ingresso = (SELECT MIN(valor_ingresso) FROM partida);

--4) Qual a data de fundação dos estádios fundados a 100 dias. Formate a saída para o padrão
--DD/MM/YYYY.

SELECT TO_CHAR(data_fundacao - INTERVAL '100 days', 'DD/MM/YYYY') AS data_de_fundacao
FROM estadio
WHERE data_fundacao >= CURRENT_DATE - INTERVAL '100 days';


--5) Qual a data de fundação dos estádios fundados a 5 anos. Formate a saída para o padrão DD/MM/
--YYYY.

SELECT TO_CHAR(data_fundacao - INTERVAL '5 years', 'DD/MM/YYYY') as data_de_fundacao
from estadio
WHERE data_fundacao >= CURRENT_date - INTERVAL '5 years';


--6) Selecione o nome e o tempo de fundação em anos dos estádios que possuam partidas
--disputadas em 2023.

SELECT e.nome AS nome_do_estadio,
EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.data_fundacao)) AS tempo_de_fundacao_anos
FROM estadio e
WHERE EXISTS (SELECT 1 
              FROM partida pa
              WHERE pa.codigo_estadio = e.codigo
            AND EXTRACT(YEAR FROM pa.data) = 2023);


--7) Selecione o nome e a data da partida no padrão nacional ( Ex: 31/08/2023 19:50:11). Somente
--partidas em que o nome termine com a letra ‘a’, possuam tamanho mínimo de 7 letras no nome e
--que tem valor do ingresso abaixo da média devem ser mostradas. Atenção, não é permitido
--saídas duplicadas.

SELECT DISTINCT
    TO_CHAR(data, 'DD/MM/YYYY HH24:MI:SS') AS data_da_partida,nome
FROM partida
WHERE nome LIKE '%a'
    AND LENGTH(nome) >= 7
    AND valor_ingresso < (SELECT AVG(valor_ingresso) FROM partida);


--8) Verifique se o torcedor ‘Fulano’ está cadastrado. Retorne verdadeiro caso esteja cadastrado e
--falso caso não esteja.

SELECT EXISTS (
    SELECT 1
    FROM torcedor
    WHERE nome = 'Fulano') AS esta_cadastrado;


--9) No sistema existem diversas jogadoras cadastradas, porém foi solicitado dados somente das
--posições Goleira, Volante, Atacante e Lateral. Com base no que foi informado,

SELECT nome AS nome_da_jogadora, data_nascimento AS data_de_nascimento,posicao,
    (EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nascimento))) AS idade,
    (SELECT nome FROM selecao WHERE codigo = jogador.codigo_selecao) AS nome_da_selecao
FROM jogador
WHERE posicao IN ('Goleira', 'Volante', 'Atacante', 'Lateral');
