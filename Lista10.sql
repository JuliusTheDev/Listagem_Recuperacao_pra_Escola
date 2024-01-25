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
('Neymar', '1992-02-05', 1000000, 'PSG', 'Atacante', 1),
('Megan Rapinoe', '1985-07-05', 500000, 'OL Reign', 'Meia', 2),
('Kylian Mbappé', '1998-12-20', 800000, 'PSG', 'Atacante', 3);

select * from jogador;

INSERT INTO estadio (nome, capacidade_maxima, custo_construcao, data_fundacao) VALUES
('Maracanã', 90000, 500000000, '1950-06-16'),
('Estádio Rose Bowl', 88000, 400000000, '1922-02-19'),
('Parc des Princes', 48000, 300000000, '1897-07-18');

select * from estadio;

INSERT INTO partida (nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b) VALUES
('Final Copa do Mundo', '2023-12-15 20:00:00', 'final', 150.00, 50000, 1, 1, 2),
('Semifinal Eurocopa', '2023-11-30 18:30:00', 'semi', 120.00, 35000, 2, 2, 3),
('Amistoso Internacional', '2023-09-10 19:45:00', 'oitavas', 80.00, 25000, 3, 3, 1);

select * from partida;


INSERT INTO torcedor (nome, data_nascimento, renda, genero, codigo_selecao) VALUES
('João Silva', '1980-01-15', 60000, 'masculino', 1),
('Maria Santos', '1995-03-25', 45000, 'feminino', 2),
('Alex Costa', '1988-08-10', 70000, 'outros', 3);

select * from torcedor;

INSERT INTO estadio_torcedor (codigo_estadio, codigo_torcedor, data) VALUES
(1, 5, '2023-12-15'),
(2, 4, '2023-11-30'),
(3, 6, '2023-09-10');

select * from estadio_torcedor;

--1) Crie uma trigger com a seguinte regra: Não é permitido aumento para os salários 
--das jogadoras.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION impedir_aumento_salario()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a jogadora está sendo atualizada
    IF TG_OP = 'UPDATE' THEN
        -- Verifica se o novo salário é maior que o salário atual
        IF NEW.posicao = 'Atacante' AND NEW.salario > OLD.salario THEN
            RAISE EXCEPTION 'Não é permitido aumento no salário das jogadoras.';
        END IF;
    END IF;

    -- Retorna a ação padrão da trigger
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_impedir_aumento_salario
BEFORE UPDATE ON jogador
FOR EACH ROW
EXECUTE FUNCTION impedir_aumento_salario();


--2) Crie uma trigger com a seguinte regra: Ao inserir uma partida, caso o valor do ingresso seja maior
--que o maior valor do ingresso das partidas já cadastradas, atualize o valor do ingresso para 75% do
--maior valor do ingresso das partidas.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION ajustar_valor_ingresso()
RETURNS TRIGGER AS $$
DECLARE
    maior_valor_ingresso NUMERIC;
BEGIN
    -- Obtém o maior valor do ingresso das partidas já cadastradas
    SELECT MAX(valor_ingresso) INTO maior_valor_ingresso FROM partida;

    -- Verifica se o valor do ingresso da nova partida é maior que o maior valor encontrado
    IF NEW.valor_ingresso > maior_valor_ingresso THEN
        -- Atualiza o valor do ingresso para 75% do maior valor do ingresso
        NEW.valor_ingresso := 0.75 * maior_valor_ingresso;
    END IF;

    -- Retorna a ação padrão da trigger
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_ajustar_valor_ingresso
BEFORE INSERT ON partida
FOR EACH ROW
EXECUTE FUNCTION ajustar_valor_ingresso();


--3) Crie uma trigger com a seguinte regra: Ao excluir um torcedor, tudo que é vinculado ao torcedor
--deve ser excluído antes.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION excluir_tudo_vinculado_ao_torcedor()
RETURNS TRIGGER AS $$
BEGIN
    -- Exclui todas as entradas vinculadas ao torcedor que está sendo excluído
    DELETE FROM estadio_torcedor WHERE codigo_torcedor = OLD.codigo;
    -- Adicione mais exclusões conforme necessário para outras tabelas vinculadas ao torcedor

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_excluir_tudo_vinculado_ao_torcedor
BEFORE DELETE ON torcedor
FOR EACH ROW
EXECUTE FUNCTION excluir_tudo_vinculado_ao_torcedor();


--4) Crie uma trigger com a seguinte regra: Ao excluir um estádio, tudo que é vinculado ao estádio
--deve ser excluído antes.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION excluir_tudo_vinculado_ao_estadio()
RETURNS TRIGGER AS $$
BEGIN
    -- Exclui todas as entradas vinculadas ao estádio que está sendo excluído
    DELETE FROM estadio_torcedor WHERE codigo_estadio = OLD.codigo;
    DELETE FROM partida WHERE codigo_estadio = OLD.codigo;
    -- Adicione mais exclusões conforme necessário para outras tabelas vinculadas ao estádio

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_excluir_tudo_vinculado_ao_estadio
BEFORE DELETE ON estadio
FOR EACH ROW
EXECUTE FUNCTION excluir_tudo_vinculado_ao_estadio();


--5) Crie uma trigger com a seguinte regra: Antes de remover uma seleção, tudo que é vinculado a
--seleção deve ser transferido para a seleção brasileira.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION transferir_para_selecao_brasileira()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza as entradas vinculadas à seleção que está sendo removida
    UPDATE estadio_torcedor SET codigo_selecao = (SELECT codigo FROM selecao WHERE nome = 'Brasil') WHERE codigo_selecao = OLD.codigo;
    UPDATE jogador SET codigo_selecao = (SELECT codigo FROM selecao WHERE nome = 'Brasil') WHERE codigo_selecao = OLD.codigo;
    -- Adicione mais atualizações conforme necessário para outras tabelas vinculadas à seleção

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_transferir_para_selecao_brasileira
BEFORE DELETE ON selecao
FOR EACH ROW
EXECUTE FUNCTION transferir_para_selecao_brasileira();


--6) Modifique a trigger do exercício número dois para atender a seguinte regra: Ao modificar uma
--partida (inserir ou atualizar os dados), caso o valor do ingresso seja maior que o maior valor do
--ingresso das partidas já cadastradas, atualize o valor do ingresso para 75% do maior valor do
--ingresso das partidas.

-- Criação da Trigger
CREATE OR REPLACE FUNCTION ajustar_valor_ingresso()
RETURNS TRIGGER AS $$
DECLARE
    maior_valor_ingresso NUMERIC;
BEGIN
    -- Obtém o maior valor de ingresso das partidas já cadastradas
    SELECT MAX(valor_ingresso) INTO maior_valor_ingresso FROM partida;

    -- Verifica se o novo valor de ingresso é maior que o maior valor existente
    IF NEW.valor_ingresso > maior_valor_ingresso THEN
        -- Atualiza o valor do ingresso para 75% do maior valor existente
        NEW.valor_ingresso = 0.75 * maior_valor_ingresso;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_ajustar_valor_ingresso
BEFORE INSERT OR UPDATE ON partida
FOR EACH ROW
EXECUTE FUNCTION ajustar_valor_ingresso();


--7) Crie uma trigger com a seguinte regra: Jogadoras nascidas antes do ano de 1995 não podem ser
--cadastradas

-- Criação da Trigger
CREATE OR REPLACE FUNCTION validar_data_nascimento()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a jogadora nasceu antes de 1995
    IF EXTRACT(YEAR FROM NEW.data_nascimento) < 1995 THEN
        RAISE EXCEPTION 'Jogadoras nascidas antes de 1995 não podem ser cadastradas.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação da Trigger
CREATE TRIGGER trigger_validar_data_nascimento
BEFORE INSERT OR UPDATE ON jogador
FOR EACH ROW
EXECUTE FUNCTION validar_data_nascimento();




