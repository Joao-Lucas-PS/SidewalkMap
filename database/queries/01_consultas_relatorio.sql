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