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


-- Iniciar transação para não salvar os dados de teste
BEGIN;


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


-- Desfazer os dados inseridos durante os testes
ROLLBACK;