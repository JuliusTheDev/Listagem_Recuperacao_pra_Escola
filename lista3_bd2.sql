CREATE TYPE genero_enum AS ENUM ('feminino', 'masculino', 'outros');

CREATE TYPE fase_enum AS ENUM ('grupo', 'oitavas', 'quartas', 'semi', 'final');

CREATE TABLE selecao (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    pais VARCHAR(30),
    genero genero_enum
);

CREATE TABLE estadio (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    capacidade_maxima INTEGER,
    custo_construcao NUMERIC,
    data_fundacao DATE
);

CREATE TABLE jogador (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    data_nascimento DATE,
    salario NUMERIC,
    time VARCHAR(30),
    posicao VARCHAR(30),
    codigo_selecao INTEGER REFERENCES selecao(codigo)
);

CREATE TABLE partida (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    data TIMESTAMP,
    fase fase_enum,
    valor_ingresso NUMERIC,
    quantidade_ingresso INTEGER,
    codigo_estadio INTEGER REFERENCES estadio(codigo),
    codigo_selecao_a INTEGER REFERENCES selecao(codigo),
    codigo_selecao_b INTEGER REFERENCES selecao(codigo)
);

CREATE TABLE torcedor (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR(30),
    data_nascimento DATE,
    renda NUMERIC,
    genero genero_enum,
    codigo_selecao INTEGER REFERENCES selecao(codigo)
);

CREATE TABLE estadio_torcedor (
    codigo_estadio INTEGER REFERENCES estadio(codigo),
    codigo_torcedor INTEGER REFERENCES torcedor(codigo),
    data DATE,
    PRIMARY KEY (codigo_estadio, codigo_torcedor)
);

INSERT INTO selecao (nome, pais, genero)
VALUES
    ('Brasil', 'Brasil', 'feminino'),
    ('EUA', 'Estados Unidos', 'feminino'),
    ('França', 'França', 'feminino');

INSERT INTO estadio (nome, capacidade_maxima, custo_construcao, data_fundacao)
VALUES
    ('Estádio Nacional', 60000, 150000000, '1950-05-01'),
    ('Estádio dos EUA', 70000, 200000000, '1960-07-15'),
    ('Estádio Paris', 55000, 180000000, '1975-03-10');

INSERT INTO jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao)
VALUES
    ('Marta', '1986-02-19', 100000, 'Brasil FC', 'Atacante', 1),
    ('Alex Morgan', '1989-07-02', 95000, 'EUA United', 'Atacante', 2),
    ('Eugénie Le Sommer', '1989-05-18', 90000, 'França FC', 'Atacante', 3);

INSERT INTO partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
VALUES
    ('Partida 1', '2023-08-20 15:00:00', 'grupo', 50, 25000, 1, 1, 2),
    ('Partida 2', '2023-08-21 16:30:00', 'grupo', 45, 28000, 2, 2, 3),
    ('Partida 3', '2023-08-22 18:00:00', 'grupo', 40, 22000, 3, 3, 1);

INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao)
VALUES
    ('Ana', '1990-03-12', 50000, 'feminino', 1),
    ('John', '1985-09-25', 60000, 'masculino', 2),
    ('Sophie', '1995-01-03', 45000, 'feminino', 3);

INSERT INTO estadio_torcedor (codigo_estadio, codigo_torcedor, data)
VALUES
    (1, 1, '2023-08-20'),
    (2, 2, '2023-08-21'),
    (3, 3, '2023-08-22');


--1) Selecione o nome das jogadoras, o salário e o nome de suas seleções. Ordene a saída pelo nome da seleção e depois da jogadora.
SELECT j.nome AS nome_jogadora, j.salario, s.nome AS nome_selecao
FROM jogador j
JOIN selecao s ON j.codigo_selecao = s.codigo
WHERE s.genero = 'feminino'
ORDER BY s.nome, j.nome;


--2) Selecione o nome dos estádios, a capacidade máxima dos estádios, o nome das partidas e a fase. A saída deve conter estádios onde a capacidade seja entre 10000 e 70000 pessoas e as
--partidas foram da fase de grupos
SELECT
    e.nome AS nome_estadio,
    e.capacidade_maxima,
    p.nome AS nome_partida,
    p.fase
FROM
    estadio e
JOIN
    partida p ON e.codigo = p.codigo_estadio
WHERE
    e.capacidade_maxima BETWEEN 10000 AND 70000
    AND p.fase = 'grupo';

--3) Selecione o nome das partidas e o nome das seleções que jogaram as partidas.
SELECT
    p.nome AS nome_partida,
    sa.nome AS nome_selecao_a,
    sb.nome AS nome_selecao_b
FROM
    partida p
JOIN
    selecao sa ON p.codigo_selecao_a = sa.codigo
JOIN
    selecao sb ON p.codigo_selecao_b = sb.codigo;

--4) Selecione o nome das jogadoras e de suas seleções. Jogadoras sem seleção também devem ser
--mostradas, e no lugar do nome da seleção deve ser mostrado a mensagem ‘Sem Seleção’

SELECT
    j.nome AS nome_jogadora,
    COALESCE(s.nome, 'Sem Seleção') AS nome_selecao
FROM
    jogador j
LEFT JOIN
    selecao s ON j.codigo_selecao = s.codigo;

--5) Selecione o nome das jogadoras e de suas seleções. Jogadoras sem seleção também devem ser
--mostradas, e no lugar do nome da seleção deve ser mostrado a mensagem ‘Sem Seleção’. Também
--deve ser mostrado o nome das seleções sem jogadoras, e no lugar do nome da jogadora deve ser
--mostrado a mensagem ‘Sem Jogadora’.

SELECT
    j.nome AS nome_jogadora,
    COALESCE(s.nome, 'Sem Seleção') AS nome_selecao
FROM
    jogador j
LEFT JOIN
    selecao s ON j.codigo_selecao = s.codigo

UNION

SELECT
    'Sem Jogadora' AS nome_jogadora,
    s.nome AS nome_selecao
FROM
    selecao s
LEFT JOIN
    jogador j ON s.codigo = j.codigo_selecao
WHERE
    j.codigo IS NULL;

--6) Selecione o nome e a renda dos torcedores, nome da seleção do torcedor, os estádios que ele
--visitou e a data da visita. Ordene a saída pelo nome do estádio. Limite a saída para 3 a partir do segundo.

SELECT
    t.nome AS nome_torcedor,
    t.renda,
    s.nome AS nome_selecao,
    e.nome AS nome_estadio,
    et.data AS data_visita
FROM
    torcedor t
LEFT JOIN
    selecao s ON t.codigo_selecao = s.codigo
JOIN
    estadio_torcedor et ON t.codigo = et.codigo_torcedor
JOIN
    estadio e ON et.codigo_estadio = e.codigo
ORDER BY
    e.nome
OFFSET 1
LIMIT 3;

--7) Selecione o nome do estádio, da partida e das seleções que jogaram as partidas. Considere
--somente as partidas da fase oitavas, com valor de ingresso maior que R$ 100,00, que aconteceram
--em 2023 nos estádios construídos em 2022

SELECT
    e.nome AS nome_estadio,
    p.nome AS nome_partida,
    sa.nome AS nome_selecao_a,
    sb.nome AS nome_selecao_b
FROM
    estadio e
JOIN
    partida p ON e.codigo = p.codigo_estadio
JOIN
    selecao sa ON p.codigo_selecao_a = sa.codigo
JOIN
    selecao sb ON p.codigo_selecao_b = sb.codigo
WHERE
    p.fase = 'oitavas'
    AND p.valor_ingresso > 100.00
    AND EXTRACT(YEAR FROM p.data) = 2023
    AND EXTRACT(YEAR FROM e.data_fundacao) = 2022;


