-- ============================================================
-- 4. SCRIPT DE TESTES DO BANCO DE DADOS
-- PROJETO INTEGRADOR: SIDEWALK MAP
-- SGBD: POSTGRESQL
-- ============================================================

-- IMPORTANTE TIME:
-- 1. O script NAO apaga os dados existentes.
-- 2. Os registros de teste serao desfeitos no final.
-- 3. Os resultados ficarao disponiveis em uma tabela temporaria.
-- 4. Execute o script inteiro de uma vez
--    (mas pode ser executado em blocos se voces quiserem).
-- 5. Execute em um banco no qual as seis tabelas ja existam.
-- 6. Os testes utilizam dados ficticios.

-- ============================================================
-- ETAPA 1: PREPARAR A TABELA TEMPORARIA DE RESULTADOS
-- ============================================================

CREATE TEMP TABLE IF NOT EXISTS sidewalk_test_results (
    id_teste INTEGER,
    descricao TEXT,
    resultado_esperado TEXT,
    status_teste TEXT
) ON COMMIT PRESERVE ROWS;

TRUNCATE TABLE sidewalk_test_results;


-- ============================================================
-- ETAPA 2: INICIAR A TRANSACAO
-- ============================================================

BEGIN;


-- ============================================================
-- ETAPA 3: EXECUTAR OS TESTES
-- ============================================================

DO $$
DECLARE
    v_usuario INTEGER;
    v_responsavel INTEGER;
    v_categoria INTEGER;
    v_relato INTEGER;
    v_total INTEGER;
    v_ok BOOLEAN;
    v_sufixo TEXT;
    v_email TEXT;
    v_nome_categoria TEXT;
BEGIN

    -- Sufixo para evitar conflitos com dados existentes.
    v_sufixo := txid_current()::TEXT;

    v_email := 'teste.' || v_sufixo || '@example.com';

    v_nome_categoria :=
        'Categoria Teste ' || v_sufixo;


    -- ========================================================
    -- TESTE 01: VERIFICAR AS SEIS TABELAS
    -- ========================================================

    SELECT COUNT(*)
    INTO v_total
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_type = 'BASE TABLE'
      AND table_name IN (
          'usuario',
          'categoria',
          'relato',
          'localizacao',
          'foto',
          'validacao'
      );

    INSERT INTO sidewalk_test_results
    VALUES (
        1,
        'Verificacao das seis tabelas',
        'Encontrar as seis tabelas',
        CASE WHEN v_total = 6
             THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 02: CADASTRAR USUARIO E RESPONSAVEL VALIDOS
    -- ========================================================

    INSERT INTO usuario (
        nome, email, senha_hash, papel_usuario
    )
    VALUES (
        'Usuario Teste',
        v_email,
        'hash_ficticio_teste',
        'usuario'
    )
    RETURNING id_usuario INTO v_usuario;

    INSERT INTO usuario (
        nome, email, senha_hash, papel_usuario
    )
    VALUES (
        'Responsavel Teste',
        'responsavel.' || v_sufixo || '@example.com',
        'hash_ficticio_teste',
        'responsavel'
    )
    RETURNING id_usuario INTO v_responsavel;

    INSERT INTO sidewalk_test_results
    VALUES (
        2,
        'Cadastro de usuario e responsavel validos',
        'Os dois cadastros devem ser aceitos',
        'APROVADO'
    );


    -- ========================================================
    -- TESTE 03: BLOQUEAR EMAIL DUPLICADO
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            'Usuario Duplicado',
            v_email,
            'hash_ficticio_teste',
            'usuario'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        3,
        'Bloqueio de email duplicado',
        'A segunda insercao deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 04: BLOQUEAR NOME COM APENAS ESPACOS
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            '    ',
            'nome.vazio.' || v_sufixo || '@example.com',
            'hash_ficticio_teste',
            'usuario'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        4,
        'Bloqueio de nome vazio',
        'A insercao deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 05: BLOQUEAR PAPEL DE USUARIO INVALIDO
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            'Usuario Papel Invalido',
            'papel.invalido.' || v_sufixo || '@example.com',
            'hash_ficticio_teste',
            'super_admin'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        5,
        'Bloqueio de papel de usuario invalido',
        'O papel nao permitido deve ser rejeitado',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 06: CADASTRAR CATEGORIA VALIDA
    -- ========================================================

    INSERT INTO categoria (
        nome_categoria,
        descricao_categoria
    )
    VALUES (
        v_nome_categoria,
        'Categoria ficticia para testes.'
    )
    RETURNING id_categoria INTO v_categoria;

    INSERT INTO sidewalk_test_results
    VALUES (
        6,
        'Cadastro de categoria valida',
        'A categoria deve ser inserida',
        'APROVADO'
    );


    -- ========================================================
    -- TESTE 07: BLOQUEAR CATEGORIA DUPLICADA
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO categoria (
            nome_categoria,
            descricao_categoria
        )
        VALUES (
            v_nome_categoria,
            'Tentativa de duplicacao.'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        7,
        'Bloqueio de categoria duplicada',
        'A categoria duplicada deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 08: CADASTRAR RELATO VALIDO
    -- ========================================================

    INSERT INTO relato (
        id_usuario,
        id_categoria,
        titulo_relato,
        descricao
    )
    VALUES (
        v_usuario,
        v_categoria,
        'Relato de teste',
        'Descricao ficticia para testar o banco.'
    )
    RETURNING id_relato INTO v_relato;

    INSERT INTO sidewalk_test_results
    VALUES (
        8,
        'Cadastro de relato valido',
        'O relato deve ser inserido',
        'APROVADO'
    );


    -- ========================================================
    -- TESTE 09: BLOQUEAR RELATO COM USUARIO INEXISTENTE
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO relato (
            id_usuario,
            id_categoria,
            titulo_relato,
            descricao
        )
        VALUES (
            2147483000,
            v_categoria,
            'Relato com usuario inexistente',
            'Teste de chave estrangeira.'
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        9,
        'Relato com usuario inexistente',
        'A insercao deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 10: BLOQUEAR RELATO COM CATEGORIA INEXISTENTE
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO relato (
            id_usuario,
            id_categoria,
            titulo_relato,
            descricao
        )
        VALUES (
            v_usuario,
            2147483000,
            'Relato com categoria inexistente',
            'Teste de chave estrangeira.'
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        10,
        'Relato com categoria inexistente',
        'A insercao deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 11: CADASTRAR LOCALIZACAO VALIDA
    -- ========================================================

    INSERT INTO localizacao (
        id_relato,
        latitude,
        longitude
    )
    VALUES (
        v_relato,
        -16.3281,
        -48.9534
    );

    INSERT INTO sidewalk_test_results
    VALUES (
        11,
        'Cadastro de localizacao valida',
        'As coordenadas devem ser aceitas',
        'APROVADO'
    );


    -- ========================================================
    -- TESTE 12: BLOQUEAR LATITUDE INVALIDA
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO localizacao (
            id_relato,
            latitude,
            longitude
        )
        VALUES (
            v_relato,
            150,
            -48.9534
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        12,
        'Bloqueio de latitude fora do limite',
        'A latitude deve ser rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- ========================================================
    -- TESTE 13: BLOQUEAR SEGUNDA LOCALIZACAO DO RELATO
    -- ========================================================

    v_ok := FALSE;

    BEGIN
        INSERT INTO localizacao (
            id_relato,
            latitude,
            longitude
        )
        VALUES (
            v_relato,
            -16.3300,
            -48.9500
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        13,
        'Bloqueio de localizacao duplicada',
        'O segundo registro deve ser rejeitado',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


-- TESTE 14: CADASTRAR FOTO E VALIDACAO VALIDAS
v_ok := TRUE;
BEGIN
INSERT INTO foto (
id_relato,
url
)
        VALUES (
            v_relato,
            'https://exemplo.com/foto-teste.jpg'
        );

        INSERT INTO validacao (
            id_relato,
            id_responsavel,
            resultado,
            observacao
        )
        VALUES (
            v_relato,
            v_responsavel,
            'Verificado',
            'Validacao ficticia para teste.'
        );

    EXCEPTION
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        14,
        'Cadastro de foto e validacao validas',
        'As duas insercoes devem ser aceitas',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- TESTE 15: BLOQUEAR RESULTADO DE VALIDACAO INVALIDO

    v_ok := FALSE;

    BEGIN
        INSERT INTO validacao (
            id_relato,
            id_responsavel,
            resultado
        )
        VALUES (
            v_relato,
            v_responsavel,
            'Talvez'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        15,
        'Bloqueio de resultado de validacao invalido',
        'O resultado deve ser rejeitado',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );

END $$;


-- ETAPA 4: EXIBIR O RESULTADO DOS TESTES
SELECT
id_teste,
descricao,
resultado_esperado,
status_teste
FROM sidewalk_test_results
ORDER BY id_teste;

-- ETAPA 5: RESUMO DOS RESULTADOS
SELECT
    status_teste,
    COUNT(*) AS quantidade
FROM sidewalk_test_results
GROUP BY status_teste
ORDER BY status_teste;


-- ETAPA 6: DESFAZER OS DADOS DE TESTE
ROLLBACK;

-- FIM DO SCRIPT