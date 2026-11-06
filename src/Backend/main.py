import hashlib
import os
import psycopg2
from dotenv import load_dotenv

load_dotenv()


# CONEXÃO COM O BANCO DE DADOS
def conectar_banco():
  return psycopg2.connect(
      host=os.getenv("DB_HOST"),
      database=os.getenv("DB_NAME"),
      user=os.getenv("DB_USER"),
      password=os.getenv("DB_PASSWORD"),
  )


# FUNÇÃO AUXILIAR PARA GERAR O HASH DA SENHA
def gerar_hash_senha(senha):
  # Transforma a senha em bytes e calcula o hash SHA-256
  return hashlib.sha256(senha.encode("utf-8")).hexdigest()


# 1. USUÁRIOS E AUTENTICAÇÃO
def existe_gestor():
  conexao = conectar_banco()
  cursor = conexao.cursor()

  cursor.execute(
      "SELECT COUNT(*) FROM usuario WHERE papel_usuario = 'responsavel';"
  )
  total = cursor.fetchone()[0]

  cursor.close()
  conexao.close()
  return total > 0


def cadastrar_usuario(perfil="usuario"):
  print("\nCADASTRO DE USUARIO:\n")
  nome = input("Nome: ").strip()
  email = input("E-mail: ").strip().lower()
  senha = input("Senha: ").strip()

  if nome == "" or email == "" or senha == "":
    print("Erro: Nenhum campo pode ficar vazio.")
    return

  if "@" not in email:
    print("Erro: Digite um e-mail válido (precisa ter @).")
    return

  conexao = conectar_banco()
  cursor = conexao.cursor()

  # Checa se o e-mail já existe
  cursor.execute("SELECT email FROM usuario WHERE email = %s;", (email,))
  if cursor.fetchone() != None:
    print("Erro: Já existe uma conta com esse e-mail.")
    cursor.close()
    conexao.close()
    return

  # Aplica o hash na senha antes de salvar no banco
  senha_criptografada = gerar_hash_senha(senha)

  comando_sql = "INSERT INTO usuario (nome, email, senha_hash, papel_usuario) VALUES (%s, %s, %s, %s);"
  cursor.execute(comando_sql, (nome, email, senha_criptografada, perfil))
  conexao.commit()

  cursor.close()
  conexao.close()
  print("Conta criada com sucesso! Perfil:", perfil)


def cadastrar_primeiro_gestor():
  if existe_gestor():
    print("Erro: Já existe um gestor cadastrado no sistema.")
  else:
    cadastrar_usuario("responsavel")


def fazer_login():
  print("\n=== LOGIN ===")
  email = input("E-mail: ").strip().lower()
  senha = input("Senha: ").strip()

  # Gera o hash da senha digitada para comparar com o hash salvo no banco
  senha_criptografada = gerar_hash_senha(senha)

  conexao = conectar_banco()
  cursor = conexao.cursor()

  # O banco retorna: (id_usuario, nome, email, papel_usuario)
  comando_sql = "SELECT id_usuario, nome, papel_usuario FROM usuario WHERE email = %s AND senha_hash = %s;"
  cursor.execute(comando_sql, (email, senha_criptografada))
  usuario_encontrado = cursor.fetchone()

  cursor.close()
  conexao.close()

  if usuario_encontrado != None:
    print("\nBem-vindo(a),", usuario_encontrado[1] + "!")
    # Retorna em formato de dicionário para facilitar o uso nos menus
    return {
        "id_usuario": usuario_encontrado[0],
        "nome": usuario_encontrado[1],
        "perfil": usuario_encontrado[2],
    }
  else:
    print("Erro: E-mail ou senha incorretos.")
    return None


# 2. GERENCIAMENTO DE CATEGORIAS
def consultar_categorias():
  print("\nCATEGORIAS DISPONIVEIS:\n")
  conexao = conectar_banco()
  cursor = conexao.cursor()

  cursor.execute(
      "SELECT id_categoria, nome_categoria, descricao_categoria FROM categoria"
      " WHERE ativa = TRUE ORDER BY id_categoria;"
  )
  categorias_banco = cursor.fetchall()

  cursor.close()
  conexao.close()

  if len(categorias_banco) == 0:
    print("Nenhuma categoria ativa no momento.")
    return

  for cat in categorias_banco:
    desc = cat[2]
    if desc == None or desc == "":
      desc = "(sem descrição)"
    print(cat[0], "-", cat[1], "|", desc)


def listar_todas_categorias():
  print("\nTODAS AS CATEGORIAS:\n")
  conexao = conectar_banco()
  cursor = conexao.cursor()

  cursor.execute(
      "SELECT id_categoria, nome_categoria, descricao_categoria, ativa FROM"
      " categoria ORDER BY id_categoria;"
  )
  categorias_banco = cursor.fetchall()

  cursor.close()
  conexao.close()

  if len(categorias_banco) == 0:
    print("Nenhuma categoria cadastrada.")
    return

  for cat in categorias_banco:
    desc = cat[2]
    if desc == None or desc == "":
      desc = "(sem descrição)"

    if cat[3] == True:
      status = "Ativa"
    else:
      status = "Inativa"

    print(cat[0], "-", cat[1], "\nDescricao: ", desc, "\nStatus: ", status)


def cadastrar_categoria():
  print("\n--- CADASTRAR CATEGORIA ---")
  nome = input("Nome da categoria: ").strip()

  if nome == "":
    print("Erro: O nome da categoria não pode ficar vazio.")
    return

  conexao = conectar_banco()
  cursor = conexao.cursor()

  cursor.execute(
      "SELECT id_categoria FROM categoria WHERE LOWER(nome_categoria) = %s;",
      (nome.lower(),),
  )
  if cursor.fetchone() != None:
    print("Erro: Já existe uma categoria com esse nome.")
    cursor.close()
    conexao.close()
    return

  descricao = input("Descrição (opcional): ").strip()

  comando_sql = "INSERT INTO categoria (nome_categoria, descricao_categoria, ativa) VALUES (%s, %s, TRUE);"
  cursor.execute(comando_sql, (nome, descricao))
  conexao.commit()

  cursor.close()
  conexao.close()
  print("Categoria cadastrada com sucesso!")


def menu_gerenciar_categorias():
  while True:
    print("\nGERENCIAR CATEGORIAS:\n")
    print("1 - Cadastrar nova categoria")
    print("2 - Listar todas as categorias")
    print("0 - Voltar")
    opcao = input("Escolha uma opção: ").strip()

    if opcao == "1":
      cadastrar_categoria()
    elif opcao == "2":
      listar_todas_categorias()
    elif opcao == "0":
      break
    else:
      print("Opção inválida.")


# 3. REGISTRO E CONSULTA DE RELATOS


def cadastrar_relato(usuario):
  print("\n--- REGISTRAR RELATO ---")

  consultar_categorias()
  id_cat_digitado = input("\nDigite o ID da categoria desejada: ").strip()

  if id_cat_digitado == "":
    print("Erro: O ID da categoria não pode ficar vazio.")
    return

  conexao = conectar_banco()
  cursor = conexao.cursor()

  # 1. Checa se a categoria existe e está ativa
  cursor.execute(
      "SELECT id_categoria FROM categoria WHERE id_categoria = %s AND ativa ="
      " TRUE;",
      (id_cat_digitado,),
  )
  if cursor.fetchone() == None:
    print("Erro: Categoria não encontrada ou desativada.")
    cursor.close()
    conexao.close()
    return

  titulo = input("Título do relato: ").strip()
  if titulo == "":
    print("Erro: O título não pode ficar vazio.")
    cursor.close()
    conexao.close()
    return

  descricao = input("Descrição do problema: ").strip()
  if descricao == "":
    print("Erro: A descrição não pode ficar vazia.")
    cursor.close()
    conexao.close()
    return

  print("\nLocalização do problema:")
  lat_texto = input("Latitude (-90 a 90): ").strip().replace(",", ".")
  long_texto = input("Longitude (-180 a 180): ").strip().replace(",", ".")

  if lat_texto == "" or long_texto == "":
    print("Erro: Latitude e longitude são obrigatórias.")
    cursor.close()
    conexao.close()
    return

  latitude = float(lat_texto)
  longitude = float(long_texto)

  if latitude < -90 or latitude > 90 or longitude < -180 or longitude > 180:
    print("Erro: Coordenadas fora dos limites do mapa.")
    cursor.close()
    conexao.close()
    return

  # 2. Insere na tabela relato
  comando_relato = """
        INSERT INTO relato (id_usuario, id_categoria, titulo_relato, descricao)
        VALUES (%s, %s, %s, %s)
        RETURNING id_relato;
    """
  cursor.execute(
      comando_relato, (usuario["id_usuario"], id_cat_digitado, titulo, descricao)
  )
  id_novo_relato = cursor.fetchone()[0]

  # 3. Insere na tabela localizacao ligada ao id_relato
  comando_loc = "INSERT INTO localizacao (id_relato, latitude, longitude) VALUES (%s, %s, %s);"
  cursor.execute(comando_loc, (id_novo_relato, latitude, longitude))

  conexao.commit()
  cursor.close()
  conexao.close()

  print("\nRelato e localização registrados com sucesso! ID:", id_novo_relato)


def listar_relatos():
  print("\nRELATOS CADASTRADOS:\n")
  conexao = conectar_banco()
  cursor = conexao.cursor()

  comando_sql = """
        SELECT r.id_relato, r.titulo_relato, c.nome_categoria, r.status_problema
        FROM relato r
        JOIN categoria c ON r.id_categoria = c.id_categoria
        ORDER BY r.id_relato;
    """
  cursor.execute(comando_sql)
  relatos_banco = cursor.fetchall()

  cursor.close()
  conexao.close()

  if len(relatos_banco) == 0:
    print("Nenhum relato cadastrado.")
    return

  for rel in relatos_banco:
    print(rel[0], "-", rel[1], "| Categoria:", rel[2], "| Status:", rel[3])


def consultar_relato():
  print("\nCONSULTAR RELATO:\n")
  id_digitado = input("Digite o ID do relato: ").strip()

  conexao = conectar_banco()
  cursor = conexao.cursor()

  comando_sql = """
        SELECT r.id_relato, r.titulo_relato, r.descricao, c.nome_categoria, u.nome, 
               l.latitude, l.longitude, r.status_problema, r.status_verificacao
        FROM relato r
        JOIN categoria c ON r.id_categoria = c.id_categoria
        JOIN usuario u ON r.id_usuario = u.id_usuario
        JOIN localizacao l ON r.id_relato = l.id_relato
        WHERE r.id_relato = %s;
    """
  cursor.execute(comando_sql, (id_digitado,))
  relato = cursor.fetchone()

  cursor.close()
  conexao.close()

  if relato != None:
    print("\nDETALHES DO RELATO:\n")
    print("ID:", relato[0])
    print("Título:", relato[1])
    print("Descrição:", relato[2])
    print("Categoria:", relato[3])
    print("Usuário que relatou:", relato[4])
    print("Localização (Lat/Long):", relato[5], ",", relato[6])
    print("Status do problema:", relato[7])
    print("Status da verificação:", relato[8])
  else:
    print("Relato não encontrado.")


# 4. MENUS DO SISTEMA


def menu_usuario_comum(usuario):
  while True:
    print("\nMENU DO USUÁRIO\n")
    print("Olá,", usuario["nome"])
    print("1 - Consultar categorias")
    print("2 - Registrar relato")
    print("3 - Listar relatos")
    print("4 - Consultar relato específico")
    print("0 - Sair da conta")
    opcao = input("Escolha uma opção: ").strip()

    if opcao == "1":
      consultar_categorias()
    elif opcao == "2":
      cadastrar_relato(usuario)
    elif opcao == "3":
      listar_relatos()
    elif opcao == "4":
      consultar_relato()
    elif opcao == "0":
      print("Você saiu da conta.")
      break
    else:
      print("Opção inválida.")


def menu_gestor(usuario):
  while True:
    print("\nMENU DO GESTOR\n")
    print("Olá,", usuario["nome"])
    print("1 - Gerenciar categorias")
    print("2 - Listar relatos")
    print("3 - Consultar relato específico")
    print("4 - Criar conta de outro gestor")
    print("0 - Sair da conta")
    opcao = input("Escolha uma opção: ").strip()

    if opcao == "1":
      menu_gerenciar_categorias()
    elif opcao == "2":
      listar_relatos()
    elif opcao == "3":
      consultar_relato()
    elif opcao == "4":
      cadastrar_usuario("responsavel")
    elif opcao == "0":
      print("Você saiu da conta.")
      break
    else:
      print("Opção inválida.")


def menu_inicial():
  while True:
    print("\nSIDEWALK MAP\n")
    print("1 - Cadastrar nova conta")
    print("2 - Entrar (login)")
    if not existe_gestor():
      print("3 - Criar o primeiro gestor")
    print("0 - Sair")
    opcao = input("Escolha uma opção: ").strip()

    if opcao == "1":
      cadastrar_usuario("usuario")
    elif opcao == "2":
      usuario_logado = fazer_login()
      if usuario_logado != None:
        if usuario_logado["perfil"] == "responsavel":
          menu_gestor(usuario_logado)
        else:
          menu_usuario_comum(usuario_logado)
    elif opcao == "3":
      cadastrar_primeiro_gestor()
    elif opcao == "0":
      print("Encerrando o programa. Até logo!")
      break
    else:
      print("Opção inválida.")


# Execução do sistema
menu_inicial()
