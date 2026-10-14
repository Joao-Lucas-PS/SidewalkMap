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