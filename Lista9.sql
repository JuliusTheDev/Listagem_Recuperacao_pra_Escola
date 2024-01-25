--Juliel Alves TSI Turma1710

CREATE TYPE genero_enum AS ENUM ('feminino', 'masculino', 'outros');
CREATE TABLE selecao (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR,
    pais VARCHAR,
    genero genero_enum
);


CREATE TABLE jogador (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR,
    data_nascimento DATE,
    salario NUMERIC,
    time VARCHAR,
    posicao VARCHAR,
    codigo_selecao INTEGER,
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
);

CREATE TABLE estadio (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR,
    capacidade_maxima INTEGER,
    custo_construcao NUMERIC,
    data_fundacao DATE
);

CREATE TYPE fase_enum AS ENUM ('grupo', 'oitavas', 'quartas', 'semi', 'final');

CREATE TABLE partida (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR,
    data TIMESTAMP,
    fase fase_enum,
    valor_ingresso NUMERIC,
    quantidade_ingresso INTEGER,
    codigo_estadio INTEGER,
    codigo_selecao_a INTEGER,
    codigo_selecao_b INTEGER,
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_selecao_a) REFERENCES selecao(codigo),
    FOREIGN KEY (codigo_selecao_b) REFERENCES selecao(codigo)
);

CREATE TYPE genero_enum2 AS ENUM ('feminino', 'masculino', 'outros');

CREATE TABLE torcedor (
    codigo SERIAL PRIMARY KEY,
    nome VARCHAR,
    data_nascimento DATE,
    renda NUMERIC,
    genero genero_enum2,
    codigo_selecao INTEGER,
    FOREIGN KEY (codigo_selecao) REFERENCES selecao(codigo)
);


CREATE TABLE estadio_torcedor (
    codigo_estadio INTEGER,
    codigo_torcedor INTEGER,
    data DATE,
    PRIMARY KEY (codigo_estadio, codigo_torcedor),
    FOREIGN KEY (codigo_estadio) REFERENCES estadio(codigo),
    FOREIGN KEY (codigo_torcedor) REFERENCES torcedor(codigo)
);
select * from estadio_torcedor;

INSERT INTO selecao (nome, pais, genero) VALUES
('Brasil', 'Brasil', 'masculino'),
('Estados Unidos', 'EUA', 'feminino'),
('França', 'França', 'outros');

select * from selecao;

INSERT INTO jogador (nome, data_nascimento, salario, time, posicao, codigo_selecao) VALUES
('Neymar', '1992-02-05', 1000000, 'PSG', 'Atacante', 4),
('Megan Rapinoe', '1985-07-05', 500000, 'OL Reign', 'Meia', 5),
('Kylian Mbappé', '1998-12-20', 800000, 'PSG', 'Atacante', 6);

select * from jogador;

INSERT INTO estadio (nome, capacidade_maxima, custo_construcao, data_fundacao) VALUES
('Maracanã', 90000, 500000000, '1950-06-16'),
('Estádio Rose Bowl', 88000, 400000000, '1922-02-19'),
('Parc des Princes', 48000, 300000000, '1897-07-18');

select * from estadio;

INSERT INTO partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b) VALUES
('Final Copa do Mundo', '2023-12-15 20:00:00', 'final', 150.00, 50000, 1, 4, 6),
('Semifinal Eurocopa', '2023-11-30 18:30:00', 'semi', 120.00, 35000, 2, 5, 4),
('Amistoso Internacional', '2023-09-10 19:45:00', 'oitavas', 80.00, 25000, 3, 6, 5);

select * from partida;


INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao) VALUES
('João Silva', '1980-01-15', 60000, 'masculino', 4),
('Maria Santos', '1995-03-25', 45000, 'feminino', 5),
('Alex Costa', '1988-08-10', 70000, 'outros', 6);

select * from torcedor;

INSERT INTO estadio_torcedor (codigo_estadio, codigo_torcedor, data) VALUES
(1, 5, '2023-12-15'),
(2, 4, '2023-11-30'),
(3, 6, '2023-09-10');

select * from estadio_torcedor;


 --1 ) Crie uma função que retorne os seguintes dados: nome do s jogadores, salário, idade em anos e
 --o nome da seleção onde o jogador joga. Atenção, a sua função deve receber o nome d a posição do
 --jogador como parâmetro e deve apresentar na saída somente dados referentes a est a posição.
 --Mostre como utilizar a função. Para implementar a função deste exercício é necessário estudar o
--comando: create type. Mostre como utilizar a função.
 
CREATE OR REPLACE FUNCTION obter_dados_jogadores_por_posicao(p_posicao VARCHAR)
RETURNS TABLE (
    nome_jogador VARCHAR,
    salario NUMERIC,
    idade NUMERIC,
    nome_selecao VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        j.nome,
        j.salario,
        EXTRACT(YEAR FROM AGE(NOW(), j.data_nascimento))::NUMERIC AS idade,
        s.nome AS nome_selecao
    FROM
        jogador j
        JOIN selecao s ON j.codigo_selecao = s.codigo
    WHERE
        j.posicao = p_posicao;
END;
$$ LANGUAGE plpgsql;


 SELECT * FROM obter_dados_jogadores_por_posicao('Atacante');

 --2 ) Crie uma função que retorne os seguintes dados: nome do s jogadores, salário, idade em anos e
 --o nome da seleção onde o jogador joga. Atenção, a sua função deve receber o nome d a posição do
 --jogador como parâmetro e deve apresentar na saída somente dados referentes a est a posição.
 --Mostre como utilizar a função. Para implementar a função deste exercício é necessário estudar o
 --comando: setof record .Mostre como utilizar a função.

CREATE OR REPLACE FUNCTION obter_dados_jogadores_por_posicao_setof(p_posicao VARCHAR)
RETURNS TABLE (
    nome VARCHAR,
    salario NUMERIC,
    idade NUMERIC,
    nome_selecao VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        j.nome,
        j.salario,
        EXTRACT(YEAR FROM AGE(NOW(), j.data_nascimento))::NUMERIC AS idade,
        s.nome AS nome_selecao
    FROM
        jogador j
        JOIN selecao s ON j.codigo_selecao = s.codigo
    WHERE
        j.posicao = p_posicao;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM obter_dados_jogadores_por_posicao_setof('Atacante');

--3) Crie uma função que retorne os seguintes dados: nome do estádio, sua data de fundação, custo
--de construção, o nome das partidas neste estádio, a data das partidas e o nome dos torcedores que
--foram nas partidas. Atenção, a sua função deve receber um inteiro referente ao ano que aconteceu a
--partida e apresentar os dados somente após este ano. Para implementar a função deste exercício é
--necessário estudar os comandos: setof record ou create type. Mostre como utilizar a função.

CREATE OR REPLACE FUNCTION obter_dados_estadio_partidas_torcedores(p_ano INTEGER)
RETURNS TABLE (
    nome_estadio VARCHAR,
    data_fundacao_estadio DATE,
    custo_construcao_estadio NUMERIC,
    nome_partida VARCHAR,
    data_partida TIMESTAMP, -- Ajuste para TIMESTAMP para corresponder ao tipo de dado na tabela
    nome_torcedor VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.nome AS nome_estadio,
        e.data_fundacao AS data_fundacao_estadio,
        e.custo_construcao AS custo_construcao_estadio,
        p.nome AS nome_partida,
        p.data AS data_partida,
        t.nome AS nome_torcedor
    FROM
        estadio e
        JOIN partida p ON e.codigo = p.codigo_estadio
        JOIN estadio_torcedor et ON e.codigo = et.codigo_estadio
        JOIN torcedor t ON et.codigo_torcedor = t.codigo
    WHERE
        EXTRACT(YEAR FROM p.data) > p_ano;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obter_dados_estadio_partidas_torcedores(2022);


--4) Crie uma função que retorne os seguintes dados: o nome das seleções e a média do salários de
--suas jogadoras. Mostre como utilizar a função. Para implementar a função deste exercício é
--necessário estudar os comandos: setof record ou create type. Mostre como utilizar a função.

CREATE OR REPLACE FUNCTION obter_media_salarios_selecoes()
RETURNS TABLE (
    nome_selecao VARCHAR,
    media_salarios NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.nome AS nome_selecao,
        AVG(j.salario) AS media_salarios
    FROM
        selecao s
        JOIN jogador j ON s.codigo = j.codigo_selecao
    GROUP BY
        s.nome;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obter_media_salarios_selecoes();


--5) Considere que as funções de agregação não existem na sua versão do SGBD, ou seja, não
--é permitido a sua utilização. Crie uma função que retorne a quantidade de jogadoras e o salário
--médio das jogadoras. Mostre como utilizar a função

CREATE OR REPLACE FUNCTION obter_estatisticas_jogadoras()
RETURNS TABLE (
    quantidade_jogadoras INTEGER,
    salario_medio NUMERIC
) AS $$
DECLARE
    total_jogadoras INTEGER;
    total_salarios NUMERIC;
BEGIN
    -- Contagem de jogadoras
    SELECT COUNT(*), COALESCE(AVG(salario), 0)
    INTO total_jogadoras, total_salarios
    FROM jogador;

    RETURN QUERY SELECT total_jogadoras, total_salarios;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obter_estatisticas_jogadoras();
