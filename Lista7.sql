create table selecao (
  codigo integer not null primary key,
  nome varchar(255) not null,
  pais varchar(255) not null,
  genero char(1) not null
);

create table estadio (
  codigo integer not null primary key,
  nome varchar(255) not null,
  capacidade_maxima integer not null,
  custo_construcao real not null,
  data_fundacao date not null
);

create table jogador (
  codigo integer not null primary key,
  nome varchar(255) not null,
  data_nascimento date not null,
  salario integer not null,
  time varchar(255) not null,
  posicao varchar(255) not null,
  codigo_selecao integer not null references selecao(codigo)
);

create table partida (
  codigo integer not null primary key,
  nome varchar(255) not null,
  data date not null,
  fase varchar(255) not null,
  valor_ingresso real not null,
  quantidade_ingresso integer not null,
  codigo_estadio integer not null references estadio(codigo),
  codigo_selecao_a integer references selecao(codigo),
  codigo_selecao_b integer references selecao(codigo)
);


create table torcedor (
  codigo integer not null primary key,
  nome varchar(255) not null,
  data_nascimento date not null,
  renda integer not null,
  genero char(1) not null,
  codigo_selecao integer not null references selecao(codigo)
);

create table estadio_torcedor (
  codigo_estadio integer not null references estadio(codigo),
  codigo_torcedor integer not null references torcedor(codigo),
  data date not null
);

insert into selecao (codigo, nome, pais, genero)
values (1, 'Brasil', 'Brasil', 'F');

insert into selecao (codigo, nome, pais, genero)
values (2, 'Argentina', 'Argentina', 'F');

insert into selecao (codigo, nome, pais, genero)
values (3, 'EUA', 'Estados Unidos', 'F');

insert into jogador (codigo, nome, data_nascimento, salario, time, posicao, codigo_selecao)
values (1, 'Marta', '1990-03-01', 100000, 'FC Barcelona', 'Atacante', 1);

insert into jogador (codigo, nome, data_nascimento, salario, time, posicao, codigo_selecao)
values (2, 'Alex Morgan', '1992-07-20', 50000, 'Orlando Pride', 'Atacante', 2);

insert into jogador (codigo, nome, data_nascimento, salario, time, posicao, codigo_selecao)
values (3, 'Megan Rapinoe', '1985-07-30', 30000, 'OL Reign', 'Atacante', 2);

insert into estadio (codigo, nome, capacidade_maxima, custo_construcao, data_fundacao)
values (1, 'Maracanã', 78.838, 1500000.00, '1950-06-19');

insert into estadio (codigo, nome, capacidade_maxima, custo_construcao, data_fundacao)
values (2, 'Estadio Azteca', 87.523, 1000000000.00, '1966-06-29');

insert into estadio (codigo, nome, capacidade_maxima, custo_construcao, data_fundacao)
values (3, 'Rose Bowl', 92.514, 23000000.00, '1923-10-29');

insert into torcedor (codigo, nome, data_nascimento, renda, genero, codigo_selecao)
values (1, 'Maria', '1995-05-01', 10000.00, 'F', 1);


insert into partida (codigo, nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values (4, 'Brasil x Paraguai', '2023-07-03', 'Semifinal', 150.0, 100000, 1, 1, 2);

insert into partida (codigo, nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values (1, 'Brasil x Argentina', '2023-08-03', 'Final', 100.0, 100000, 1, 1, 2);

insert into partida (codigo, nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values (2, 'EUA x Brasil', '2023-07-30', 'Semifinal', 50.0, 50000, 2, 3, 1);

insert into partida (codigo, nome, data, fase, valor_ingresso, quantidade_ingresso, codigo_estadio, codigo_selecao_a, codigo_selecao_b)
values (3, 'Argentina x EUA', '2023-07-27', 'Quartas de final', 25.0, 25000, 1, 2, 3);

--Questão 1

create or replace function soma(x int, y int)
returns int as $$
declare
    soma int;
begin
    soma = x + y;
    return soma;
end;
$$ language plpgsql;

select soma(10, 20);

--Questão 2

create or replace function media(x real, y real, z real)
returns real as $$
declare
    soma real;
begin
    soma = x + y + z;
    return soma / 3;
end;
$$ language plpgsql;

select media(10.0, 20.0, 30.0);

--Questão 3

create or replace function idade_em_dias(ano_nascimento integer)
returns integer as $$
declare
    idade integer;
begin
    idade = extract(year from now()) - ano_nascimento;
    idade = idade * 365;
    return idade;
end;
$$ language plpgsql;

select idade_em_dias(1990);

--Questão 4
create or replace function contar_partidas_valor_maior_que_100()
returns integer as $$
declare
    total_partidas integer;
begin
    select count(*)
    into total_partidas
    from partida
    where valor_ingresso > 100.00;

    return total_partidas;
end;
$$ language plpgsql;

select contar_partidas_valor_maior_que_100();

--Questão 5
create or replace function salario_mais_alto_jogadoras_nascidas_apos_2000()
returns numeric as $$
declare
    max_salario numeric;
begin
    select max(salario)
    into max_salario
    from jogador
    where extract(year from data_nascimento) > 2000;

    return max_salario;
end;
$$ language plpgsql;

select salario_mais_alto_jogadoras_nascidas_apos_2000();

--Questão 6
create or replace function media_precos_ingressos_maracana()
returns numeric as $$
declare
    media_precos numeric;
begin
    select avg(valor_ingresso)
    into media_precos
    from partida
    where codigo_estadio = (select codigo from estadio where nome = 'Maracanã');

    return media_precos;
end;
$$ language plpgsql;

select media_precos_ingressos_maracana();

--Questão 7
create or replace function numero_jogadoras_selecao(p_nome_selecao varchar)
returns integer as $$
declare
    qtd_jogadoras integer;
begin
    select count(*)
    into qtd_jogadoras
    from jogador j
    join selecao s on j.codigo_selecao = s.codigo
    where s.nome = p_nome_selecao;

    return qtd_jogadoras;
end;
$$ language plpgsql;

select numero_jogadoras_selecao('Argentina');

--Questão 8
create or replace function salario_mais_alto_jogadoras_por_ano(p_ano_nascimento integer)
returns numeric as $$
declare
    max_salario numeric;
begin
    select max(salario)
    into max_salario
    from jogador
    where extract(year from data_nascimento) = p_ano_nascimento;

    return max_salario;
end;
$$ language plpgsql;

select salario_mais_alto_jogadoras_por_ano(1992);

--Questão 9
create or replace function media_precos_ingressos_por_estadio(p_nome_estadio varchar)
returns numeric as $$
declare
    media_precos numeric;
begin
    select avg(valor_ingresso)
    into media_precos
    from partida
    where codigo_estadio = (select codigo from estadio where nome = p_nome_estadio);

    return media_precos;
end;
$$ language plpgsql;

select media_precos_ingressos_por_estadio('Maracanã');