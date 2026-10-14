-- Verificar usuários
SELECT id_usuario, nome FROM usuario;

-- Verificar categorias
SELECT id_categoria, nome_categoria FROM categoria;

-- Verificar relatos
SELECT id_relato, titulo_relato FROM relato;

SELECT r.id_relato,
CASE
WHEN l.id_relato IS NULL THEN 'Sem localização'
ELSE 'Já possui localização'
END AS situacao
FROM relato r
LEFT JOIN localizacao l
ON r.id_relato = l.id_relato
WHERE r.id_relato IN (26, 96);

-- Iniciar transação para não salvar os dados de teste
BEGIN;

-- TESTES SIMPLES
-- TESTE 1: Verificar se as tabelas principais existem
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'usuario',
    'categoria',
    'relato',
    'localizacao',
    'foto',
    'validacao'
);

-- TESTE 2: Cadastrar um usuário válido
INSERT INTO usuario (nome, email, senha_hash, papel_usuario)
VALUES ('Usuario Teste', 'teste7@example.com', 'senha_teste', 'usuario');


-- TESTE 3: Verificar se o banco impede e-mails duplicados
SAVEPOINT teste_email;

INSERT INTO usuario (nome, email, senha_hash, papel_usuario)
VALUES ('Outro Usuario', 'teste7@example.com', 'senha_teste', 'usuario');

-- Se o INSERT acima gerar erro, execute:
-- ROLLBACK TO SAVEPOINT teste_email;


-- TESTE 4: Verificar se é possível cadastrar uma categoria válida
INSERT INTO categoria (nome_categoria, descricao_categoria, ativa)
VALUES ('Categoria Teste', 'Categoria para testes', TRUE);


-- TESTE 5: Consultar os usuários cadastrados
SELECT id_usuario, nome, email, papel_usuario
FROM usuario;


-- TESTE 6: Consultar os relatos cadastrados
SELECT id_relato, titulo_relato, status_verificacao, status_problema
FROM relato;


-- TESTE 7: Verificar se existem relatos sem localização cadastrada
SELECT r.id_relato, r.titulo_relato
FROM relato r
LEFT JOIN localizacao l ON r.id_relato = l.id_relato
WHERE l.id_localizacao IS NULL;

-- TESTE 8: Verificar se o banco rejeita um usuário inexistente
-- Esperado: rejeição por chave estrangeira
INSERT INTO relato (id_usuario, id_categoria, titulo_relato, descricao)
VALUES (999999, 1, 'Teste 8', 'Usuário inexistente');


-- TESTE 9: Verificar se o banco rejeita uma categoria inexistente
-- Esperado: rejeição por chave estrangeira
INSERT INTO relato (id_usuario, id_categoria, titulo_relato, descricao)
VALUES (1, 999999, 'Teste 9', 'Categoria inexistente');


-- Esperado: rejeição pela restrição CHECK em localizacao (10 - 13)

-- TESTE 10: Verificar se o banco rejeita latitude inválida
INSERT INTO localizacao (id_relato, latitude, longitude)
VALUES (6, -91, 0);

-- TESTE 11: Verificar se o banco rejeita latitude acima de 90
INSERT INTO localizacao (id_relato, latitude, longitude)
VALUES (3, 91, 0);

-- TESTE 12: Verificar se o banco rejeita longitude inválida
INSERT INTO localizacao (id_relato, latitude, longitude)
VALUES (2, 0, 181);

-- TESTE 13: Verificar se o banco rejeita longitude abaixo de -180
INSERT INTO localizacao (id_relato, latitude, longitude)
VALUES (4, 0, -181);

-- Esperado: rejeição pela restrição CHECK em relatos (4 e 15)

-- TESTE 14: Verificar se o banco rejeita o status Cancelado
INSERT INTO relato (
    id_usuario, id_categoria, titulo_relato,
    descricao, status_problema
)
VALUES (1, 1, 'Teste', 'Relato de teste', 'Cancelado');


-- TESTE 15: Verificar se o banco rejeita um status não permitido
-- Esperado: rejeição pela restrição CHECK
INSERT INTO relato (
    id_usuario, id_categoria, titulo_relato,
    descricao, status_verificacao
)
VALUES (1, 1, 'Teste 15', 'Verificação inválida', 'Em análise');

-- TESTE 16: Verificar se o banco rejeita um relato inexistente
-- Esperado: rejeição por chave estrangeira
INSERT INTO localizacao (id_relato, latitude, longitude)
VALUES (999999, 0, 0);

-- TESTE 17: Verificar se o banco rejeita uma foto sem relato válido
INSERT INTO foto (id_relato, url)
VALUES (999999, 'https://example.com/teste.jpg');

-- Desfazer os dados inseridos durante os testes
ROLLBACK;
