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
('Neymar', '1992-02-05', 1000000, 'PSG', 'Atacante', 22),
('Megan Rapinoe', '1985-07-05', 500000, 'OL Reign', 'Meia', 23),
('Kylian Mbappé', '1998-12-20', 800000, 'PSG', 'Atacante', 24);

select * from jogador;

INSERT INTO estadio (nome, capacidade_maxima, custo_construcao, data_fundacao) VALUES
('Maracanã', 90000, 500000000, '1950-06-16'),
('Estádio Rose Bowl', 88000, 400000000, '1922-02-19'),
('Parc des Princes', 48000, 300000000, '1897-07-18');

select * from estadio;

INSERT INTO partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b) VALUES
('Final Copa do Mundo', '2023-12-15 20:00:00', 'final', 150.00, 50000, 4, 22, 24),
('Semifinal Eurocopa', '2023-11-30 18:30:00', 'semi', 120.00, 35000, 5, 23, 22),
('Amistoso Internacional', '2023-09-10 19:45:00', 'oitavas', 80.00, 25000, 6, 24, 23);

select * from partida;


INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao) VALUES
('João Silva', '1980-01-15', 60000, 'masculino', 22),
('Maria Santos', '1995-03-25', 45000, 'feminino', 23),
('Alex Costa', '1988-08-10', 70000, 'outros', 24);

select * from torcedor;

INSERT INTO estadio_torcedor (codigo_estadio, codigo_torcedor, data) VALUES
(4, 5, '2023-12-15'),
(5, 4, '2023-11-30'),
(6, 6, '2023-09-10');

select * from estadio_torcedor;


--1) Crie uma função que retorne os dados d as seleções (todos os dados da tabela selecao ). Mostre
--como utilizar a função.

CREATE OR REPLACE FUNCTION obter_dados_selecoes()
RETURNS TABLE (
    codigo INTEGER,
    nome VARCHAR,
    pais VARCHAR,
    genero selecao.genero%TYPE
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM selecao;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obter_dados_selecoes(); 


--2) Crie uma função que retorne os dados da seleção informando o nome do País (todos os dados da
--tabela selecao). Mostre como utilizar a função.
CREATE OR REPLACE FUNCTION obter_dados_selecao_por_pais(p_pais VARCHAR)
RETURNS TABLE (
    codigo INTEGER,
    nome VARCHAR,
    pais VARCHAR,
    genero genero_enum
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM selecao WHERE selecao.pais = p_pais;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM obter_dados_selecao_por_pais('Brasil');


--3) Crie uma função que retorne os dados das jogadoras de uma seleção, o nome da seleção deve
--ser informada como entrada da função (todos os dados da tabela jogador devem retornar como
--saída). Mostre como utilizar a função.
CREATE OR REPLACE FUNCTION obter_dados_jogadoras_por_selecao(p_nome_selecao VARCHAR)
RETURNS TABLE (
    codigo INTEGER,
    nome VARCHAR,
    data_nascimento DATE,
    salario NUMERIC,
    clube VARCHAR,
    posicao VARCHAR,
    codigo_selecao INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT j.* FROM jogador j
                  JOIN selecao s ON j.codigo_selecao = s.codigo
                  WHERE s.nome = p_nome_selecao;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM obter_dados_jogadoras_por_selecao('Brasil');

--4 ) Crie uma função que receba como entrada o nome de uma seleção, nome do novo torcedor , a
-- data_nascimento, renda e genero. A sua função deve fazer a inserção deste novo torcedor no banco
--de dados. Não esqueça de descobrir o código da seleção, considere que a seleção já está
--cadastrada no banco de dados. A função não possui retorno (void). Mostre como utilizar a função.
CREATE OR REPLACE FUNCTION inserir_torcedor(
    p_nome_selecao VARCHAR,
    p_nome_torcedor VARCHAR,
    p_data_nascimento DATE,
    p_renda NUMERIC,
    p_genero VARCHAR
)
RETURNS VOID AS $$
DECLARE
    v_codigo_selecao INTEGER;
BEGIN
    -- Descobrir o código da seleção pelo nome
    SELECT codigo INTO v_codigo_selecao FROM selecao WHERE nome = p_nome_selecao;

    -- Inserir novo torcedor
    INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao)
    VALUES (p_nome_torcedor, p_data_nascimento, p_renda, p_genero::genero_enum2, v_codigo_selecao);
END;
$$ LANGUAGE plpgsql;

SELECT inserir_torcedor('Brasil', 'João Silva', '1990-05-15', 80000, 'masculino');


--5) Crie uma função que receba como entrada o valor de aumento dos ingressos de uma partida e o
--nome do estádio da partida. Aplique o aumento no valor do ingresso das partidas que ocorreram no
--estádio informado. Mostre como utilizar a função.

CREATE OR REPLACE FUNCTION aumentar_ingressos_por_estadio(
    p_valor_aumento NUMERIC,
    p_nome_estadio VARCHAR
)
RETURNS VOID AS $$
BEGIN
    UPDATE partida
    SET valor_ingresso = valor_ingresso + p_valor_aumento
    WHERE codigo_estadio = (SELECT codigo FROM estadio WHERE nome = p_nome_estadio);
END;
$$ LANGUAGE plpgsql;

SELECT aumentar_ingressos_por_estadio(20.00, 'Maracanã');


--6) Crie uma função que faça a inserção de uma nova seleção, caso ela ainda não exista (considere
--que cada seleção possui um nome distinto). Se a seleção for cadastrada com sucesso a função
--deve retornar verdadeiro, caso a seleção exista, a função deve retornar falso. Mostre como utilizar a
--função. Dicas: utilizar EXISTS e ver a sintaxe do IF/ELSE 
CREATE OR REPLACE FUNCTION inserir_selecao_se_nao_existir(
    p_nome_selecao VARCHAR,
    p_pais VARCHAR,
    p_genero VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar se a seleção já existe
    SELECT EXISTS (SELECT 1 FROM selecao WHERE nome = p_nome_selecao) INTO v_existe;

    -- Inserir a seleção se não existir
    IF NOT v_existe THEN
        INSERT INTO selecao (nome, pais, genero) VALUES (p_nome_selecao, p_pais, p_genero);
    END IF;

    -- Retornar verdadeiro se a seleção foi cadastrada, falso se já existia
    RETURN NOT v_existe;
END;
$$ LANGUAGE plpgsql;


SELECT inserir_selecao_se_nao_existir('Brasil', 'Brasil', '1');
