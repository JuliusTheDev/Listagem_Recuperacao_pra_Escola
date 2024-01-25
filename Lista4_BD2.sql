-- Criação das tabelas
CREATE TABLE selecao (
    codigo serial PRIMARY KEY,
    nome varchar,
    pais varchar,
    genero varchar
);

CREATE TABLE jogador (
    codigo serial PRIMARY KEY,
    nome varchar,
    data_nascimento date,
    salario numeric,
    time varchar,
    posicao varchar,
    codigo_selecao integer,
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
);

CREATE TABLE estadio (
    codigo serial PRIMARY KEY,
    nome varchar,
    capacidade_maxima integer,
    custo_construcao numeric,
    data_fundacao date
);

CREATE TABLE partida (
    codigo serial PRIMARY KEY,
    nome varchar,
    data timestamp,
    fase varchar,
    valor_ingresso numeric,
    quantidade_ingresso integer,
    codigo_estadio integer,
    codigo_selecao_a integer,
    codigo_selecao_b integer,
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_selecao_a) REFERENCES selecao(codigo),
    FOREIGN KEY (codigo_selecao_b) REFERENCES selecao(codigo)
);

CREATE TABLE torcedor (
    codigo serial PRIMARY KEY,
    nome varchar,
    data_nascimento date,
    renda numeric,
    genero varchar,
    codigo_selecao integer,
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
);

CREATE TABLE estadio_torcedor (
    codigo_estadio integer,
    codigo_torcedor integer,
    data date,
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_torcedor) REFERENCES torcedor(codigo)
);



-- Inserção de dados

-- Tabela selecao
INSERT INTO selecao (nome, pais, genero)
VALUES
    ('Brasil', 'Brasil', 'masculino'),
    ('Estados Unidos', 'Estados Unidos', 'feminino'),
    ('França', 'França', 'outros');

-- Tabela jogador
INSERT INTO jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao)
VALUES
    ('Neymar', '1992-02-05', 1000000, 'Paris Saint-Germain', 'atacante', 1),
    ('Alex Morgan', '1989-07-02', 500000, 'Orlando Pride', 'atacante', 2),
    ('Kylian Mbappé', '1998-12-20', 800000, 'Paris Saint-Germain', 'atacante', 3);

-- Tabela estadio
INSERT INTO estadio (nome, capacidade_maxima, custo_construcao, data_fundacao)
VALUES
    ('Maracanã', 90000, 300000000, '1950-06-16'),
    ('Soldier Field', 61500, 40000000, '1924-10-04'),
    ('Stade de France', 80000, 450000000, '1998-05-28');

-- Tabela partida
INSERT INTO partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
VALUES
    ('Brasil vs Argentina', '2023-07-15 20:00:00', 'final', 100, 50000, 1, 1, 2),
    ('EUA vs Canadá', '2023-06-30 18:30:00', 'oitavas', 50, 30000, 2, 2, 3),
    ('França vs Alemanha', '2023-06-18 15:00:00', 'grupo', 40, 25000, 3, 3, 1);


-- Tabela torcedor
INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao)
VALUES
    ('José Silva', '1985-03-10', 5000, 'masculino', 1),
    ('Emily Johnson', '1990-09-15', 6000, 'feminino', 2),
    ('André Dupont', '1988-11-22', 4500, 'masculino', 3);

-- Tabela estadio_torcedor
INSERT INTO estadio_torcedor (codigo_estadio, codigo_torcedor, data)
VALUES
    (1, 1, '2023-07-15'),
    (2, 2, '2023-06-30'),
    (3, 3, '2023-06-18');

--1) Selecione a média dos salários das jogadoras por seleção. Renomeie a saída.
SELECT j.codigo_selecao, s.nome AS selecao, AVG(j.salario) AS media_salario_jogadoras
FROM jogador j
JOIN selecao s ON j.codigo_selecao = s.codigo
WHERE s.genero = 'feminino'
GROUP BY j.codigo_selecao, s.nome;

--2) Selecione a quantidade de partidas por estádio. Somente estádios com mais de uma partida devem ser mostrados. Renomeie a saída.
SELECT e.codigo, e.nome AS estadio, COUNT(p.codigo) AS quantidade_partidas
FROM estadio e
JOIN partida p ON e.codigo = p.codigo_estadio
GROUP BY e.codigo, e.nome
HAVING COUNT(p.codigo) > 1;

--3) Selecione o menor preço e o maior preço do ingresso por estádio. Ordene a saída pelo nome do 
--estádio em ordem decrescente. 
SELECT 
    e.nome AS estadio, 
    MIN(p.valor_ingresso) AS menor_preco_ingresso, 
    MAX(p.valor_ingresso) AS maior_preco_ingresso
FROM estadio e
JOIN partida p ON e.codigo = p.codigo_estadio
GROUP BY e.nome
ORDER BY e.nome DESC;

--4) Selecione o valor total da renda dos torcedores por seleção. Renomeie a saída.
SELECT 
    t.codigo_selecao, 
    s.nome AS selecao, 
    SUM(t.renda) AS valor_total_renda
FROM torcedor t
JOIN selecao s ON t.codigo_selecao = s.codigo
GROUP BY t.codigo_selecao, s.nome;

--5) Selecione o nome dos torcedores do Brasil, que foram nos estádio neste ano. O nome do estádio
--de possuir a letra ‘o’ e com tamanho mínimo de 5 letras.
SELECT 
    t.nome AS nome_torcedor
FROM torcedor t
JOIN estadio_torcedor et ON t.codigo = et.codigo_torcedor
JOIN estadio e ON et.codigo_estadio = e.codigo
WHERE t.codigo_selecao = (SELECT codigo FROM selecao WHERE nome = 'Brasil')
    AND EXTRACT(YEAR FROM et.data) = EXTRACT(YEAR FROM CURRENT_DATE)
    AND e.nome LIKE '%o%'
    AND LENGTH(e.nome) >= 5;
	
--6) Selecione o(s) nome(s) da(s) partida(s) com valor do ingresso acima da média dos valores de
--todos os ingressos. (Talvez seja necessário aprender subconsultas).
SELECT nome AS partida_ingresso_acima_media
FROM partida
WHERE valor_ingresso > (SELECT AVG(valor_ingresso) FROM partida);

--7) Selecione os torcedores nascidos em 2005.
SELECT nome AS nome_torcedor, data_nascimento
FROM torcedor
WHERE EXTRACT(YEAR FROM data_nascimento) = 2005;

--8) Selecione o(s) torcedores(s) com a menor renda de todos os torcedores. (Talvez seja necessário
--aprender subconsultas).
SELECT nome AS torcedor_menor_renda, renda
FROM torcedor
WHERE renda = (SELECT MIN(renda) FROM torcedor);





