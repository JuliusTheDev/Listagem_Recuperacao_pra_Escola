
create type genero_enum as enum ('feminino', 'masculino', 'outros');
create table selecao(
	codigo serial not null, 
	nome varchar(50) not null, 
	pais varchar(50), 
	genero genero_enum,
	primary key(codigo)
);

insert into selecao(nome, pais, genero)
values('Brasileira', 'Brasil', 'feminino');
insert into selecao(nome, pais, genero)
values('Mexicana', 'México', 'feminino');
insert into selecao(nome, pais, genero)
values('Jamaicana', 'Jamaica', 'feminino');

  
create table estadio(
	codigo serial not null primary key, 
	nome varchar(50) not null, 
	capacidade_maxima int, 
	custo_construcao numeric(20,2), 
	data_fundacao date
);

insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Maracanã', 78000, 5000000000, '1950-06-16');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Morenão', 45000, 1000000000, '1971-03-07');
insert into estadio(nome, capacidade_maxima, custo_construcao, data_fundacao)
values('Elias Gadia', 2500, 5000000, '1990-12-25');

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
values('Marta','1986-02-19', 2000000, 'Orlando', 'Atacante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Formiga','1978-03-03', 1000000, 'Santos', 'Volante', 1);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Khalix','1992-08-26', 500000, 'Vasco', 'Goleira', 3);

insert into jogador(nome, data_nascimento, salario, time, posicao, codigo_selecao)
values('Menina','2001-10-14', 100000, 'flamengo', 'Lateral', 2);

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
values('Fulana', '1959-09-07', 2587416, 'feminino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Fulaninho', '1984-04-01', 10, 'masculino', 1);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Gertrudes', '1965-11-12', 5000, 'feminino', 3);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Cloriandia', '1984-10-22', 900000, 'feminino', 2);
insert into torcedor(nome, data_nascimento, renda, genero, codigo_selecao)
values('Potrezin', '2005-01-20', 150, 'masculino', 2);

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

--1) Crie uma view que tenha como saída: o nome das jogadoras, data de nascimento, idade em anos
--e o nome da seleção que cada uma joga. Considere que todas as datas devem sair no formato DD/
--MM/YYYY. Ordene a saída pela data de nascimento. Mostre como usar a view.

CREATE VIEW jogadoras_info AS
SELECT jogador.nome AS nome_jogadora, to_char(jogador.data_nascimento, 'DD/MM/YYYY') AS data_nascimento, 
EXTRACT(YEAR FROM age(now(), jogador.data_nascimento)) AS idade, selecao.nome AS nome_selecao
FROM jogador
JOIN selecao ON jogador.codigo_selecao = selecao.codigo
WHERE genero = 'feminino'
ORDER BY jogador.data_nascimento;

SELECT * FROM jogadoras_info;

--2) Crie uma view que tenha como saída: o nome do estádio, tempo de fundação em dias do estádio,
--o nome das partidas e das seleções que jogaram a partida. Considere somente partidas do ano de
--2023. Mostre como usar a view.

CREATE VIEW vw_estadio_partida AS
SELECT
    e.nome AS nome_estadio,
    DATE_PART('day', AGE(current_date, e.data_fundacao)) AS dias_fundacao,
    p.nome AS nome_partida,
    s1.nome AS selecao_a,
    s2.nome AS selecao_b
FROM
    estadio e
JOIN
    partida p ON e.codigo = p.codigo_estadio
JOIN
    selecao s1 ON p.codigo_selecao_a = s1.codigo
JOIN
    selecao s2 ON p.codigo_selecao_b = s2.codigo
WHERE
    DATE_PART('year', p.data) = 2023;

SELECT * FROM vw_estadio_partida;


--3) Crie uma view que tenha como saída: Os dados das jogadoras que possuem salário acima da
--média dos salários das jogadoras que nasceram entre o ano de 2000 e 2009. Mostre como usar a
--view

CREATE VIEW vw_jogadoras_acima_da_media AS
SELECT
    j.codigo AS codigo_jogadora,
    j.nome AS nome_jogadora,
    j.data_nascimento,
    j.salario,
    s.genero,
    s.nome AS nome_selecao
FROM
    jogador j
JOIN
    selecao s ON j.codigo_selecao = s.codigo
WHERE
    j.data_nascimento BETWEEN '2000-01-01' AND '2009-12-31'
    AND j.salario > (
        SELECT AVG(salario)
        FROM jogador
        WHERE data_nascimento BETWEEN '2000-01-01' AND '2009-12-31'
    );

SELECT * FROM vw_jogadoras_acima_da_media;

--4) Crie uma view que tenha como saída: A quantidade de torcedores nascidos por ano e a média da
--renda destes torcedores. Arredonde a média em duas casas decimais. Ordene pelo ano a saída.
--Mostre como usar a view.

CREATE VIEW vw_torcedores_por_ano AS
SELECT
    EXTRACT(YEAR FROM data_nascimento) AS ano_nascimento,
    COUNT(*) AS quantidade_torcedores,
    ROUND(AVG(renda)::numeric, 2) AS media_renda
FROM
    torcedor
GROUP BY
    ano_nascimento
ORDER BY
    ano_nascimento;

SELECT * FROM vw_torcedores_por_ano;

--5) Crie uma view que tenha como saída: O nome das jogadoras e das partidas que cada uma
--disputou. Ordene pelo nome das jogadoras. Mostre como usar a view

CREATE VIEW vw_jogadoras_partidas AS
SELECT
    j.nome AS nome_jogadora,
    p.nome AS nome_partida
FROM
    jogador j
JOIN
    partida p ON (j.codigo_selecao = p.codigo_selecao_a OR j.codigo_selecao = p.codigo_selecao_b)
ORDER BY
    nome_jogadora;

SELECT * FROM vw_jogadoras_partidas;

--6) Remova a view criada no exercício dois

DROP VIEW vw_estadio_partida;




