create database loja_deposito;
use loja_deposito;

create table t_clientes(
id int not null auto_increment,
nome varchar(50) not null,
cpf_cnpj varchar(20) not null,
tipo_cliente varchar(20) not null,
telefone varchar(15) not null,
endereco varchar(60) not null,
primary key(id)
);

create table t_produtos(
id int not null auto_increment,
nome_produto varchar(35) not null,
desc_produto varchar(50) not null,
valor_produto float not null,
primary key(id)
);

ALTER TABLE loja_deposito.t_produtos ADD COLUMN selecione_qtd INT NOT NULL AFTER valor_produto;

UPDATE loja_deposito.t_produtos SET elecione_qtd = 2 WHERE (id = 1);
UPDATE loja_deposito.t_produtos SET selecione_qtd = 4 WHERE (id = 2);
UPDATE loja_deposito.t_produtos SET selecione_qtd = 1 WHERE (id = 3);
UPDATE loja_deposito.t_produtos SET selecione_qtd = 10 WHERE (id = 4);
UPDATE loja_deposito.t_produtos SET selecione_qtd = 4 WHERE (id = 5);
UPDATE loja_deposito.t_produtos SET selecione_qtd = 10 WHERE (id = 6);


create table t_caixa(
id int not null auto_increment,
id_clientes int not null,
id_produtos int not null,
quantidade int not null,
preco_produto float not null,
primary key(id)
);

ALTER TABLE loja_deposito.t_caixa ADD COLUMN hora TIME NOT NULL AFTER preco_produto;

UPDATE loja_deposito.t_caixa SET hora = '08:30:05' WHERE (id = 1);
UPDATE loja_deposito.t_caixa SET hora = '09:40:50' WHERE (id = 2);
UPDATE loja_deposito.t_caixa SET hora = '09:40:58' WHERE (id = 3);
UPDATE loja_deposito.t_caixa SET hora = '10:45:01' WHERE (id = 4);
UPDATE loja_deposito.t_caixa SET hora = '08:21:38' WHERE (id = 5);
UPDATE loja_deposito.t_caixa SET hora = '11:40:10' WHERE (id = 6);

insert into t_clientes values
(default, 'Cebolinha Cruz', '0789456123', 'Pessoa Física', '85 96666-0018', 'rua estelita, 50'),
(default, 'Monica da Fé', '08741311000178', 'Pessoa Juridica', '85 97777-7555', 'rua alfredo miguel, 1001'),
(default, 'Pedro Abreu', '741234561', 'Pessoa Física', '85 91112-3322', 'rua nogueira, 500'),
(default, 'Maria Guerra', '10852222000133', 'Pessoa Juridica', '85 92822-7411', 'rua barra funda, 962'),
(default, 'Bel Kelly', '0046245615', 'Pessoa Física', '85 93380-7933', 'avenida brasil, 1002'),
(default, 'Raquel Braga', '01766111000112', 'Pessoa Juridica', '85 90121-4666', 'rua argentina, 890');

select * from t_clientes;

insert into t_produtos values
(default, 'Broca', 'Ferramenta Eletrica', 459.90),
(default, 'Escada 30m', 'Acessorio', 149.98),
(default, 'Parafusadeira', 'Ferramenta Eletrica', 289.87),
(default, 'Marreta', 'Ferramenta Manual', 59.69),
(default, 'Serrote', 'Ferramenta Manual', 19.95),
(default, 'Lanterna', 'Acessorio', 39.87);

select * from t_produtos;

insert into t_caixa values
(default, 1, 1, 2, 459.9),
(default, 2, 2, 4, 149.98),
(default, 3, 3, 1, 289.87),
(default, 4, 4, 10, 59.69),
(default, 5, 5, 4, 19.95),
(default, 6, 6, 10, 39.87);

select * from t_caixa;

ALTER TABLE loja_deposito.t_caixa 
ADD CONSTRAINT `FK_CLIENTES`
  FOREIGN KEY (id)
  REFERENCES loja_deposito.t_clientes (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,
ADD CONSTRAINT `FK_PRODUTOS`
  FOREIGN KEY (id)
  REFERENCES loja_deposito.t_produtos (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

/*view estoque*/
CREATE VIEW v_estoque AS SELECT t_caixa.hora
AS hr_pedido, t_clientes.nome, t_produtos.nome_produto, t_produtos.selecione_qtd
FROM t_caixa INNER JOIN t_clientes on t_caixa.id = t_clientes.id INNER JOIN t_produtos
on t_caixa.id = t_produtos.id;

select * from v_estoque;
select * from v_estoque order by hr_pedido asc;

/*view para entregador*/
CREATE VIEW v_entregador AS SELECT t_caixa.hora
AS hr_pedido, t_clientes.nome, tipo_cliente, telefone, endereco, t_produtos.nome_produto, t_produtos.valor_produto, t_produtos.selecione_qtd
FROM t_caixa INNER JOIN t_clientes on t_caixa.id = t_clientes.id INNER JOIN t_produtos
on t_caixa.id = t_produtos.id;

select * from v_entregador;
select * from v_entregador order by hr_pedido asc;

/*view Relatório*/
CREATE VIEW v_relatorio AS SELECT t_caixa.hora
AS hr_pedido, t_clientes.nome, cpf_cnpj, tipo_cliente, t_produtos.nome_produto, t_produtos.valor_produto, t_produtos.selecione_qtd
FROM t_caixa INNER JOIN t_clientes on t_caixa.id = t_clientes.id INNER JOIN t_produtos
on t_caixa.id = t_produtos.id;

select * from v_relatorio;
select * from v_relatorio order by tipo_cliente desc;

select sum(valor_produto) from v_relatorio;

/*solicitado da VIEW v_relatorio ===>*/ 

/*me retorna qual tipo de clientes que fizeram menor compras em quantidade*/
select hr_pedido, tipo_cliente, selecione_qtd as total from v_relatorio group by
hr_pedido having sum(selecione_qtd) < 4;

/*aqui não retorna valores repetidos*/ 
select distinct selecione_qtd from v_relatorio;

/*aqui ele me retorna qual foi a maior qtd comprada naquele dia abaixo de 10pdts por cliente*/
select count(*) as qtd from v_estoque where selecione_qtd <> 10;

/*aqui ele me retorna o valor maior do produto vendido naquele dia com o nome*/
select hr_pedido, nome_produto, max(valor_produto) from v_relatorio;

/*aqui ele me retorna o valor maior do produto vendido naquele dia*/
select min(valor_produto) from v_relatorio;

/*aqui ele me retorna em qual horario foram vendidos os produtos entre os valores abaixo*/
select hr_pedido, nome_produto, tipo_cliente  from v_relatorio where valor_produto between 149.98 and 459.9;

/*aqui ele procura os nomes dos clientes que começa pela letra M*/
select * from v_relatorio where nome like 'M%';



