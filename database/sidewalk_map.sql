-- Sidewalk Map
-- Banco de Dados

-- Criar banco de Dados
-- CREATE DATABASE sidewalk_map

-- Mudar o Caminho
-- CREATE SCHEMA testes;
-- SET search_path TO testes, public;

-- Comandos para deletar as Tabelas
DROP TABLE IF EXISTS validacao;
DROP TABLE IF EXISTS foto;
DROP TABLE IF EXISTS localizacao;
DROP TABLE IF EXISTS relato;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS usuario;

-- 1. TABELAS
CREATE TABLE usuario (
    id_usuario     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    email          VARCHAR(255) NOT NULL,
    senha_hash     TEXT NOT NULL,
    papel_usuario  VARCHAR(20) NOT NULL,
    data_criacao   TIMESTAMP WITH TIME ZONE NOT NULL
	DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_usuario_email
	UNIQUE (email),
	
    CONSTRAINT ck_usuario_nome
	CHECK (btrim(nome) <> ''),
	
    CONSTRAINT ck_usuario_email
	CHECK (btrim(email) <> ''),
	
    CONSTRAINT ck_usuario_papel
	CHECK (papel_usuario IN ('usuario', 'responsavel'))
);


CREATE TABLE categoria (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome_categoria VARCHAR(80) NOT NULL,
    descricao_categoria TEXT,
    ativa BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP WITH TIME ZONE NOT NULL
	DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_categoria_nome
	UNIQUE (nome_categoria),
	
    CONSTRAINT ck_categoria_nome
	CHECK (btrim(nome_categoria) <> '')
);


CREATE TABLE relato (
    id_relato INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario INTEGER NOT NULL
	REFERENCES usuario (id_usuario),
    id_categoria INTEGER NOT NULL
	REFERENCES categoria (id_categoria),
    titulo_relato VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    status_verificacao VARCHAR(20) NOT NULL DEFAULT 'Pendente',
    status_problema VARCHAR(20) NOT NULL DEFAULT 'Aberto',
    data_relato TIMESTAMP WITH TIME ZONE NOT NULL
	DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_relato_titulo
	CHECK (btrim(titulo_relato) <> ''),
	
    CONSTRAINT ck_relato_descricao
	CHECK (btrim(descricao) <> ''),
	
    CONSTRAINT ck_relato_status_verificacao
	CHECK (status_verificacao IN
	('Pendente', 'Verificado', 'Rejeitado')),
	
    CONSTRAINT ck_relato_status_problema
	CHECK (status_problema IN
	('Aberto', 'Em andamento', 'Resolvido'))
);

CREATE TABLE localizacao (
    id_localizacao INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_relato INTEGER NOT NULL
	REFERENCES relato(id_relato),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,

    CONSTRAINT uq_localizacao_relato
	UNIQUE (id_relato),
	
    CONSTRAINT ck_localizacao_latitude
	CHECK (latitude  BETWEEN -90  AND 90),
	
    CONSTRAINT ck_localizacao_longitude
	CHECK (longitude BETWEEN -180 AND 180)
);

CREATE TABLE foto (
    id_foto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_relato INTEGER NOT NULL REFERENCES relato (id_relato),
    url TEXT NOT NULL,
    data_envio TIMESTAMP WITH TIME ZONE NOT NULL
	DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_foto_url
	CHECK (btrim(url) <> '')
);

CREATE TABLE validacao (
    id_validacao INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_relato INTEGER NOT NULL REFERENCES relato (id_relato),
    id_responsavel INTEGER NOT NULL REFERENCES usuario (id_usuario),
    resultado VARCHAR(20) NOT NULL,
    observacao TEXT,
    data_validacao TIMESTAMP WITH TIME ZONE NOT NULL
	DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT ck_validacao_resultado
	CHECK (resultado IN ('Verificado', 'Rejeitado'))
);

-- 2. iNSERINDO VALORES PARA TESTES
-- a. INSERINDO USUÁRIOS
INSERT INTO usuario (nome, email, senha_hash, papel_usuario) VALUES
('Carlos Silva', 'carlos.silva@email.com', '$2a$10$ExemploHashSenhaFalsa1', 'usuario'),
('Mariana Souza', 'mariana.souza@email.com', '$2a$10$ExemploHashSenhaFalsa2', 'usuario'),
('João Pedro Santos', 'joao.pedro@email.com', '$2a$10$ExemploHashSenhaFalsa3', 'responsavel'),
('Ana Beatriz Lima', 'ana.beatriz@email.com', '$2a$10$ExemploHashSenhaFalsa4', 'usuario'),
('Lucas Oliveira', 'lucas.oliveira@email.com', '$2a$10$ExemploHashSenhaFalsa5', 'responsavel');

-- b. INSERINDO CATEGORIAS 
INSERT INTO categoria (nome_categoria, descricao_categoria) VALUES
('Iluminação Pública', 'Problemas com lâmpadas queimadas, postes danificados ou falta de luz nas ruas.'),
('Buraco na Via', 'Buracos, afundamentos ou asfalto danificado nas ruas e avenidas.'),
('Lixo Irregular', 'Acúmulo de entulhos, descarte irregular de lixo em terrenos baldios ou praças.'),
('Vazamento de Água', 'Vazamentos na rede de esgoto ou tubulações de água potável nas calçadas.');

-- c. INSERINDO RELATOS
INSERT INTO relato (id_usuario, id_categoria, titulo_relato, descricao, status_verificacao, status_problema) VALUES
(1, 1, 'Poste apagado na Rua 4', 'A lâmpada do poste em frente ao número 200 está queimada há uma semana.', 'Pendente', 'Aberto'),
(2, 2, 'Buraco grande na Avenida Brasil', 'Buraco perigoso na faixa central, risco de danificar carros.', 'Verificado', 'Em andamento'),
(4, 3, 'Entulho acumulado na praça', 'Descarte de restos de construção civil e galhos jogados na praça do bairro.', 'Pendente', 'Aberto'),
(1, 4, 'Vazamento de água limpa', 'Cano estourado na calçada desperdiçando muita água desde cedo.', 'Verificado', 'Resolvido'),
(2, 1, 'Vários postes sem luz', 'Trecho completo da rua escura, gerando insegurança para pedestres.', 'Rejeitado', 'Aberto'),
(4, 2, 'Cratera aberta após chuva', 'O asfalto cedeu e abriu uma cratera após a tempestade de ontem.', 'Verificado', 'Em andamento'),
(1, 3, 'Lixo doméstico espalhado', 'Cachorros rasgaram sacos de lixo deixados fora do horário de coleta.', 'Pendente', 'Aberto'),
(2, 4, 'Esgoto transbordando', 'Tampa de bueiro quebrada com esgoto correndo a céu aberto.', 'Verificado', 'Em andamento'),
(4, 1, 'Fiação solta em poste', 'Cabos de energia baixos e quase encostando no chão.', 'Verificado', 'Aberto'),
(1, 2, 'Pequeno buraco na esquina', 'Começando a abrir um buraco bem na curva da rua.', 'Pendente', 'Aberto'),
(2, 3, 'Móveis velhos abandonados', 'Sofás velhos e colchões descartados na beira da rodovia urbana.', 'Pendente', 'Aberto'),
(4, 4, 'Vazamento na tubulação da rua', 'Água vazando direto do asfalto sem parar.', 'Verificado', 'Resolvido'),
(1, 1, 'Lâmpada piscando', 'Lâmpada de LED fica piscando a noite toda na rua principal.', 'Pendente', 'Aberto'),
(2, 2, 'Asfalto afundando', 'Afundamento na pista devido a passagem de caminhões pesados.', 'Verificado', 'Em andamento'),
(4, 3, 'Descarte de galhadas', 'Muita poda de árvore jogada na calçada atrapalhando a passagem.', 'Pendente', 'Aberto'),
(1, 4, 'Falta de água e vazamento', 'Cano rompido na entrada do bairro.', 'Verificado', 'Resolvido'),
(2, 1, 'Poste atingido por batida', 'Poste inclinado após pequeno acidente automobilístico.', 'Verificado', 'Em andamento'),
(4, 2, 'Bueiro sem tampa', 'Bueiro aberto na ciclista, oferecendo risco de queda.', 'Verificado', 'Aberto'),
(1, 3, 'Lixo acumulado em terreno', 'Terreno privado com mato alto e muito lixo acumulado.', 'Pendente', 'Aberto'),
(2, 4, 'Água servida na rua', 'Morador jogando água suja direto na sarjeta.', 'Rejeitado', 'Aberto'),
(4, 1, 'Falta iluminação na praça', 'Todas as lâmpadas da praça central apagadas.', 'Verificado', 'Resolvido'),
(1, 2, 'Recapeamento necessário', 'Rua inteira esburacada precisando de tapa-buraco urgente.', 'Pendente', 'Aberto'),
(2, 3, 'Lixo hospitalar descartado errado', 'Achado material estranho perto da lixeira comunitária.', 'Verificado', 'Em andamento'),
(4, 4, 'Vazamento leve na esquina', 'Pequeno filetinho de água limpa escorrendo.', 'Pendente', 'Aberto'),
(1, 1, 'Lâmpada nova queimou de novo', 'A prefeitura trocou e já queimou novamente.', 'Pendente', 'Aberto');

-- d. INSERINDO LOCALIZAÇÕES
INSERT INTO localizacao (id_relato, latitude, longitude) VALUES
(1, -16.3281, -48.9534),
(2, -16.3315, -48.9482),
(3, -16.3250, -48.9601),
(4, -16.3402, -48.9500),
(5, -16.3201, -48.9455),
(6, -16.3354, -48.9578),
(7, -16.3198, -48.9512),
(8, -16.3421, -48.9623),
(9, -16.3275, -48.9431),
(10, -16.3300, -48.9590),
(11, -16.3450, -48.9410),
(12, -16.3223, -48.9564),
(13, -16.3380, -48.9495),
(14, -16.3155, -48.9520),
(15, -16.3299, -48.9640),
(16, -16.3340, -48.9440),
(17, -16.3210, -48.9580),
(18, -16.3410, -48.9530),
(19, -16.3260, -48.9470),
(20, -16.3333, -48.9610),
(21, -16.3244, -48.9505),
(22, -16.3395, -48.9555),
(23, -16.3180, -48.9490),
(24, -16.3362, -48.9425),
(25, -16.3290, -48.9545);

-- f. INSERINDO FOTOS
INSERT INTO foto (id_relato, url) VALUES
(1, 'https://storage.exemplo.com/fotos/relato_1.jpg'),
(2, 'https://storage.exemplo.com/fotos/relato_2.jpg'),
(3, 'https://storage.exemplo.com/fotos/relato_3.jpg'),
(4, 'https://storage.exemplo.com/fotos/relato_4.jpg'),
(5, 'https://storage.exemplo.com/fotos/relato_5.jpg'),
(6, 'https://storage.exemplo.com/fotos/relato_6.jpg'),
(7, 'https://storage.exemplo.com/fotos/relato_7.jpg'),
(8, 'https://storage.exemplo.com/fotos/relato_8.jpg'),
(9, 'https://storage.exemplo.com/fotos/relato_9.jpg'),
(10, 'https://storage.exemplo.com/fotos/relato_10.jpg'),
(11, 'https://storage.exemplo.com/fotos/relato_11.jpg'),
(12, 'https://storage.exemplo.com/fotos/relato_12.jpg'),
(13, 'https://storage.exemplo.com/fotos/relato_13.jpg'),
(14, 'https://storage.exemplo.com/fotos/relato_14.jpg'),
(15, 'https://storage.exemplo.com/fotos/relato_15.jpg'),
(16, 'https://storage.exemplo.com/fotos/relato_16.jpg'),
(17, 'https://storage.exemplo.com/fotos/relato_17.jpg'),
(18, 'https://storage.exemplo.com/fotos/relato_18.jpg'),
(19, 'https://storage.exemplo.com/fotos/relato_19.jpg'),
(20, 'https://storage.exemplo.com/fotos/relato_20.jpg'),
(21, 'https://storage.exemplo.com/fotos/relato_21.jpg'),
(22, 'https://storage.exemplo.com/fotos/relato_22.jpg'),
(23, 'https://storage.exemplo.com/fotos/relato_23.jpg'),
(24, 'https://storage.exemplo.com/fotos/relato_24.jpg'),
(25, 'https://storage.exemplo.com/fotos/relato_25.jpg');

-- g. INSERINDO VALIDAÇÕES
INSERT INTO validacao (id_relato, id_responsavel, resultado, observacao) VALUES
(2, 3, 'Verificado', 'Equipe de obras encaminhada para o local.'),
(4, 5, 'Verificado', 'Reparo na tubulação concluído com sucesso.'),
(5, 3, 'Rejeitado', 'Local verificado e a iluminação estava funcionando normalmente.'),
(6, 5, 'Verificado', 'Sinalizado com cones e agendado recapeamento.'),
(8, 3, 'Verificado', 'Setor de saneamento acionado.'),
(9, 5, 'Verificado', 'Companhia de energia elétrica notificada sobre os fios.'),
(12, 3, 'Verificado', 'Vazamento estancado pela equipe técnica.'),
(14, 5, 'Verificado', 'Incluso na rota de manutenção asfáltica da semana.'),
(16, 3, 'Verificado', 'Cano consertado.'),
(17, 5, 'Verificado', 'Poste escorado com segurança, troca agendada.'),
(18, 3, 'Verificado', 'Nova tampa de bueiro instalada.'),
(21, 5, 'Verificado', 'Lâmpadas da praça substituídas por LED.');


-- 3. CONSULTAS PARA VISUALIZAÇÃO E FILTRAGEM DE DADOS
-- 3.1. Todos os relatos
SELECT 
id_relato, 
titulo_relato, 
status_verificacao, 
status_problema, 
data_relato 
FROM relato 
ORDER BY data_relato DESC;

-- 3.2. Relatos filtrados por nome da categoria
SELECT 
r.id_relato, 
r.titulo_relato, 
c.nome_categoria, 
r.status_problema
FROM relato r
JOIN categoria c ON r.id_categoria = c.id_categoria
WHERE c.nome_categoria = 'Buraco na Via';

-- 3.3. Relatos com o nome de quem os criou e a categoria
SELECT 
r.id_relato, 
r.titulo_relato, 
r.descricao, 
u.nome AS autor_relato, 
c.nome_categoria, 
r.status_verificacao, 
r.status_problema,
r.data_relato
FROM relato r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN categoria c ON r.id_categoria = c.id_categoria
ORDER BY r.data_relato DESC;

-- 3.4. Quantos relatos existem em cada categoria
SELECT c.nome_categoria, 
COUNT(r.id_relato) AS total_relatos
FROM categoria c
LEFT JOIN relato r ON c.id_categoria = r.id_categoria
GROUP BY c.nome_categoria
ORDER BY total_relatos DESC;

-- 3.5. Todos os usuários cadastrados
SELECT 
id_usuario, 
nome, 
email, 
papel_usuario, 
data_criacao 
FROM usuario;

-- 3.6. Relatos com suas localizações
SELECT 
r.id_relato, 
r.titulo_relato, 
l.latitude, 
l.longitude
FROM relato r
JOIN localizacao l ON r.id_relato = l.id_relato;

-- 3.7. Relatos que possuem fotos cadastradas
SELECT 
r.id_relato, 
r.titulo_relato, 
f.url AS url_foto
FROM relato r
JOIN foto f ON r.id_relato = f.id_relato;

-- 3.8. Relatos validados por um gestor
SELECT 
r.id_relato, 
r.titulo_relato, 
v.resultado AS status_validacao, 
v.observacao, 
resp.nome AS nome_responsavel,
v.data_validacao
FROM relato r
JOIN validacao v ON r.id_relato = v.id_relato
JOIN usuario resp ON v.id_responsavel = resp.id_usuario;
