-- 4. SCRIPT DE TESTES DO BANCO DE DADOS

-- IMPORTANTE TIME:
-- 1. O script NAO apaga os dados existentes.
-- 2. Os registros de teste serao desfeitos no final.
-- 3. Os resultados ficarao disponiveis em uma tabela temporaria.
-- 4. Execute o script inteiro de uma vez (Mas pode ser executado em blocos se vocês quiserem).

-- ETAPA 1: PREPARAR A TABELA TEMPORARIA DE RESULTADOS

CREATE TEMP TABLE IF NOT EXISTS sidewalk_test_results (
id_teste INTEGER,
descricao TEXT,
resultado_esperado TEXT,
status_teste TEXT
) ON COMMIT PRESERVE ROWS;

TRUNCATE TABLE sidewalk_test_results;

-- ETAPA 2: INICIAR A TRANSACAO
BEGIN;

-- ETAPA 3: EXECUTAR OS TESTES
DO $$
DECLARE
v_usuario INTEGER;
v_responsavel INTEGER;
v_categoria INTEGER;
v_relato INTEGER;
v_id_foto INTEGER;
v_id_validacao INTEGER;
v_total INTEGER;
v_ok BOOLEAN;
BEGIN

-- ETAPA 3.1: VERIFICAR SE AS SEIS TABELAS EXISTEM
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
'Existencia das seis tabelas',
'Encontrar seis tabelas',
CASE WHEN v_total = 6
THEN 'APROVADO'
ELSE 'REPROVADO'
END
);

-- etapa 3.2: INSERIR UM USUARIO VALIDO
INSERT INTO usuario (
nome,
email,
senha_hash,
papel_usuario
) VALUES (
'Usuario Teste Sidewalk',
'teste.sidewalk.usuario@example.com',
'hash_ficticio_teste',
'usuario'
)
RETURNING id_usuario INTO v_usuario;

INSERT INTO sidewalk_test_results VALUES
(2, 'Cadastro de usuario valido','Insercao aceita','APROVADO');


    -- --------------------------------------------------------
    -- T03: INSERIR UM RESPONSAVEL VALIDO
    -- --------------------------------------------------------

    INSERT INTO usuario (
        nome, email, senha_hash, papel_usuario
    )
    VALUES (
        'Responsavel Teste Sidewalk',
        'teste.sidewalk.responsavel@example.com',
        'hash_ficticio_teste',
        'responsavel'
    )
    RETURNING id_usuario INTO v_responsavel;

    INSERT INTO sidewalk_test_results
    VALUES (
        3,
        'Cadastro de responsavel',
        'Insercao aceita',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T04: INSERIR UMA CATEGORIA VALIDA
    -- --------------------------------------------------------

    INSERT INTO categoria (
        nome_categoria,
        descricao_categoria
    )
    VALUES (
        'Categoria Teste Sidewalk',
        'Categoria criada para testes automatizados.'
    )
    RETURNING id_categoria INTO v_categoria;

    INSERT INTO sidewalk_test_results
    VALUES (
        4,
        'Cadastro de categoria valida',
        'Insercao aceita',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T05: INSERIR UM RELATO VALIDO
    -- --------------------------------------------------------

    INSERT INTO relato (
        id_usuario,
        id_categoria,
        titulo_relato,
        descricao
    )
    VALUES (
        v_usuario,
        v_categoria,
        'Relato Teste Sidewalk',
        'Relato ficticio para testar o banco de dados.'
    )
    RETURNING id_relato INTO v_relato;

    INSERT INTO sidewalk_test_results
    VALUES (
        5,
        'Cadastro de relato valido',
        'Insercao aceita',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T06: INSERIR UMA LOCALIZACAO VALIDA
    -- --------------------------------------------------------

    INSERT INTO localizacao (
        id_relato, latitude, longitude
    )
    VALUES (
        v_relato, -16.3281, -48.9534
    );

    INSERT INTO sidewalk_test_results
    VALUES (
        6,
        'Cadastro de localizacao valida',
        'Coordenadas aceitas',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T07: INSERIR UMA FOTO VALIDA
    -- --------------------------------------------------------

    INSERT INTO foto (id_relato, url)
    VALUES (
        v_relato,
        'https://exemplo.com/teste-sidewalk.jpg'
    )
    RETURNING id_foto INTO v_id_foto;

    INSERT INTO sidewalk_test_results
    VALUES (
        7,
        'Cadastro de foto valida',
        'Foto associada ao relato',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T08: INSERIR UMA VALIDACAO POR RESPONSAVEL
    -- --------------------------------------------------------

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

    INSERT INTO sidewalk_test_results
    VALUES (
        8,
        'Validacao por responsavel',
        'Insercao aceita',
        'APROVADO'
    );


    -- --------------------------------------------------------
    -- T09: BLOQUEAR EMAIL DUPLICADO
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            'Usuario Duplicado',
            'teste.sidewalk.usuario@example.com',
            'hash_ficticio_teste',
            'usuario'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        9,
        'Bloqueio de email duplicado',
        'Insercao rejeitada por unicidade',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T10: BLOQUEAR NOME COM APENAS ESPACOS
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            '    ',
            'teste.nome.vazio@example.com',
            'hash_ficticio_teste',
            'usuario'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        10,
        'Bloqueio de nome vazio',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T11: BLOQUEAR PAPEL DE USUARIO INVALIDO
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO usuario (
            nome, email, senha_hash, papel_usuario
        )
        VALUES (
            'Usuario Papel Invalido',
            'teste.papel.invalido@example.com',
            'hash_ficticio_teste',
            'super_admin'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        11,
        'Bloqueio de papel invalido',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T12: BLOQUEAR CATEGORIA DUPLICADA
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO categoria (
            nome_categoria, descricao_categoria
        )
        VALUES (
            'Categoria Teste Sidewalk',
            'Categoria duplicada.'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        12,
        'Bloqueio de categoria duplicada',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T13: BLOQUEAR RELATO COM USUARIO INEXISTENTE
    -- --------------------------------------------------------

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
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        13,
        'Relato com usuario inexistente',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T14: BLOQUEAR RELATO COM CATEGORIA INEXISTENTE
    -- --------------------------------------------------------

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
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        14,
        'Relato com categoria inexistente',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T15: BLOQUEAR LATITUDE FORA DOS LIMITES
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO localizacao (
            id_relato, latitude, longitude
        )
        VALUES (
            v_relato, 150, 20
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        15,
        'Bloqueio de latitude invalida',
        'Latitude fora de -90 a 90 rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T16: BLOQUEAR LONGITUDE FORA DOS LIMITES
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO localizacao (
            id_relato, latitude, longitude
        )
        VALUES (
            v_relato, 20, -200
        );

    EXCEPTION
        WHEN check_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        16,
        'Bloqueio de longitude invalida',
        'Longitude fora de -180 a 180 rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T17: BLOQUEAR SEGUNDA LOCALIZACAO DO MESMO RELATO
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO localizacao (
            id_relato, latitude, longitude
        )
        VALUES (
            v_relato, -16.3300, -48.9500
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        17,
        'Bloqueio de localizacao duplicada',
        'Segunda localizacao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T18: BLOQUEAR FOTO COM RELATO INEXISTENTE
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO foto (id_relato, url)
        VALUES (
            2147483000,
            'https://exemplo.com/foto-invalida.jpg'
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            v_ok := TRUE;
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        18,
        'Foto com relato inexistente',
        'Insercao rejeitada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T19: BLOQUEAR RESULTADO DE VALIDACAO INVALIDO
    -- --------------------------------------------------------

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
        WHEN OTHERS THEN
            v_ok := FALSE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        19,
        'Bloqueio de resultado invalido',
        'Resultado rejeitado',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );


    -- --------------------------------------------------------
    -- T20: VERIFICAR SE USUARIO COMUM PODE VALIDAR
    --
    -- O banco atual provavelmente ACEITARA esta operacao.
    -- Nesse caso, o teste sera REPROVADO, pois a regra
    -- esperada e impedir que usuario comum valide relatos.
    -- --------------------------------------------------------

    v_ok := FALSE;

    BEGIN
        INSERT INTO validacao (
            id_relato,
            id_responsavel,
            resultado,
            observacao
        )
        VALUES (
            v_relato,
            v_usuario,
            'Verificado',
            'Teste de permissao de usuario comum.'
        )
        RETURNING id_validacao INTO v_id_validacao;

        -- Se chegou aqui, a operacao foi aceita.
        -- Removemos o registro de teste dentro da transacao.
        DELETE FROM validacao
        WHERE id_validacao = v_id_validacao;

        v_ok := FALSE;

    EXCEPTION
        WHEN OTHERS THEN
            -- Alguma restricao bloqueou a operacao.
            v_ok := TRUE;
    END;

    INSERT INTO sidewalk_test_results
    VALUES (
        20,
        'Usuario comum tentando validar relato',
        'Operacao deve ser bloqueada',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO - REGRA AUSENTE'
        END
    );


    -- --------------------------------------------------------
    -- T21: ATUALIZAR O STATUS DO RELATO
    -- --------------------------------------------------------

    UPDATE relato
    SET status_problema = 'Em andamento'
    WHERE id_relato = v_relato;

    IF EXISTS (
        SELECT 1
        FROM relato
        WHERE id_relato = v_relato
          AND status_problema = 'Em andamento'
    ) THEN
        v_ok := TRUE;
    ELSE
        v_ok := FALSE;
    END IF;

    INSERT INTO sidewalk_test_results
    VALUES (
        21,
        'Atualizacao do status do relato',
        'Status atualizado corretamente',
        CASE WHEN v_ok THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );

    -- T22: CONSULTAR RELATO COM AUTOR E CATEGORIA

    SELECT COUNT(*)
    INTO v_total
    FROM relato r
    JOIN usuario u
      ON u.id_usuario = r.id_usuario
    JOIN categoria c
      ON c.id_categoria = r.id_categoria
    WHERE r.id_relato = v_relato;

    INSERT INTO sidewalk_test_results
    VALUES (
        22,
        'Consulta de relato, autor e categoria',
        'Consulta deve encontrar um registro',
        CASE WHEN v_total = 1
             THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );



-- T23: VERIFICAR A CONTAGEM DE RELATOS POR CATEGORIA

    SELECT COUNT(*)
    INTO v_total
    FROM categoria c
    LEFT JOIN relato r
      ON r.id_categoria = c.id_categoria
    WHERE c.id_categoria = v_categoria
    GROUP BY c.id_categoria;

    INSERT INTO sidewalk_test_results
    VALUES (
        23,
        'Contagem de relatos por categoria',
        'Categoria deve possuir um relato',
        CASE WHEN v_total = 1
             THEN 'APROVADO'
             ELSE 'REPROVADO'
        END
    );

END $$;


-- ETAPA 4: MOSTRAR O RELATORIO DE TESTES

SELECT
    id_teste,
    descricao,
    resultado_esperado,
    status_teste
FROM sidewalk_test_results
ORDER BY id_teste;


-- Resumo dos resultados
SELECT
    status_teste,
    COUNT(*) AS quantidade
FROM sidewalk_test_results
GROUP BY status_teste
ORDER BY status_teste;



-- ETAPA 5: DESFAZER OS DADOS DE TESTE
ROLLBACK;

-- FIM DOS TESTES