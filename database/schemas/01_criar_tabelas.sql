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