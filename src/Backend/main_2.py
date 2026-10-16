import hashlib
import os
from datetime import datetime

# Lista que guarda todos os usuários, categorias, relatos e das localizações
usuarios = []
categorias = []
relatos = []
localizacoes = []



# SENHAS
def gerar_hash_senha(senha):
    """Transforma a senha em um texto embaralhado que não pode ser revertido."""
    sal = os.urandom(16)  # texto aleatório, diferente para cada usuário
    hash_senha = hashlib.pbkdf2_hmac("sha256", senha.encode("utf-8"), sal, 100000)
    return sal.hex() + "$" + hash_senha.hex()


def verificar_senha(senha_digitada, senha_hash):
    """Confere se a senha digitada corresponde ao hash guardado."""
    sal_texto, hash_guardado = senha_hash.split("$")
    sal = bytes.fromhex(sal_texto)
    novo_hash = hashlib.pbkdf2_hmac("sha256", senha_digitada.encode("utf-8"), sal, 100000)
    return novo_hash.hex() == hash_guardado


# USUÁRIOS: CADASTRO E LOGIN
def email_ja_cadastrado(email):
    """Devolve True se já existir um usuário com esse e-mail."""
    for usuario in usuarios:
        if usuario["email"] == email:
            return True
    return False


def existe_gestor():
# Devolve True se já existir pelo menos um gestor cadastrado.
    for usuario in usuarios:
        if usuario["perfil"] == "gestor":
            return True
    return False


def cadastrar_usuario(perfil="comum"):
    print("\n--- Cadastro de usuário ---")

    nome = input("Nome: ").strip()
    if nome == "":
        print("Erro: o nome não pode ficar vazio.")
        return

    email = input("E-mail: ").strip().lower()
    if email == "":
        print("Erro: o e-mail não pode ficar vazio.")
        return
    if "@" not in email:
        print("Erro: digite um e-mail válido (precisa ter @).")
        return
    if email_ja_cadastrado(email):
        print("Erro: já existe uma conta com esse e-mail.")
        return

    senha = input("Senha: ").strip()
    if senha == "":
        print("Erro: a senha não pode ficar vazia.")
        return

    novo_usuario = {
        "id_usuario": len(usuarios) + 1,
        "nome": nome,
        "email": email,
        "senha_hash": gerar_hash_senha(senha),
        "perfil": perfil,
        "data_criacao": datetime.now().strftime("%d/%m/%Y %H:%M"),
    }
    usuarios.append(novo_usuario)

    print("Conta criada com sucesso! Perfil:", perfil, "| Identificador:", novo_usuario["id_usuario"])


def cadastrar_primeiro_gestor():
    print("\n--- Criar o primeiro gestor ---")
    if existe_gestor():
        print("Já existe um gestor. Novos gestores só podem ser criados por um gestor logado.")
        return
    cadastrar_usuario("gestor")


def fazer_login():
# Devolve o usuário (dicionário) se o login der certo, ou None se falhar.
    print("\n--- Login ---")
    email = input("E-mail: ").strip().lower()
    senha = input("Senha: ").strip()

    for usuario in usuarios:
        if usuario["email"] == email and verificar_senha(senha, usuario["senha_hash"]):
            return usuario

    print("E-mail ou senha incorretos.")
    return None


# CATEGORIAS
def nome_categoria_ja_existe(nome):

# Devolve True se já existir uma categoria com esse nome (ignora maiúsculas).
    for categoria in categorias:
        if categoria["nome_categoria"].lower() == nome.lower():
            return True
    return False


def mostrar_descricao(categoria):

# Devolve a descrição da categoria, ou um aviso se estiver vazia.
    if categoria["descricao_categoria"] == "":
        return "(sem descrição)"
    return categoria["descricao_categoria"]


def consultar_categorias():
# Mostra só as categorias ativas. Todos os usuários podem usar.
    print("\n--- Categorias disponíveis ---")

    if len(categorias) == 0:
        print("Nenhuma categoria cadastrada.")
        return

    achou_ativa = False
    for categoria in categorias:
        if categoria["ativa"]:
            print(categoria["id_categoria"], "-", categoria["nome_categoria"], "|", mostrar_descricao(categoria))
            achou_ativa = True

    if not achou_ativa:
        print("Nenhuma categoria ativa no momento.")


def listar_todas_categorias():
    """Mostra todas as categorias, ativas e inativas. Só o gestor usa."""
    print("\n--- Todas as categorias ---")

    if len(categorias) == 0:
        print("Nenhuma categoria cadastrada.")
        return

    for categoria in categorias:
        if categoria["ativa"]:
            estado = "Ativa"
        else:
            estado = "Inativa"
        print(categoria["id_categoria"], "-", categoria["nome_categoria"], "|", mostrar_descricao(categoria), "|", estado)


def cadastrar_categoria():
    print("\n--- Cadastrar categoria ---")

    nome = input("Nome da categoria: ").strip()
    if nome == "":
        print("Erro: o nome da categoria não pode ficar vazio.")
        return
    if nome_categoria_ja_existe(nome):
        print("Erro: já existe uma categoria com esse nome.")
        return

    descricao = input("Descrição (opcional, pode deixar vazia): ").strip()

    nova_categoria = {
        "id_categoria": len(categorias) + 1,
        "nome_categoria": nome,
        "descricao_categoria": descricao,
        "ativa": True,
        "data_criacao": datetime.now().strftime("%d/%m/%Y %H:%M"),
    }
    categorias.append(nova_categoria)

    print("Categoria cadastrada com sucesso! Identificador:", nova_categoria["id_categoria"])


def alternar_estado_categoria():
    """Se a categoria está ativa, desativa. Se está inativa, ativa."""
    print("\n--- Ativar ou desativar categoria ---")

    if len(categorias) == 0:
        print("Nenhuma categoria cadastrada.")
        return

    listar_todas_categorias()

    texto = input("\nDigite o identificador da categoria: ").strip()
    if not texto.isdigit():
        print("Erro: digite um número válido.")
        return
    id_escolhido = int(texto)

    for categoria in categorias:
        if categoria["id_categoria"] == id_escolhido:
            if categoria["ativa"]:
                categoria["ativa"] = False
                print("Categoria '" + categoria["nome_categoria"] + "' desativada.")
            else:
                categoria["ativa"] = True
                print("Categoria '" + categoria["nome_categoria"] + "' ativada.")
            return

    print("Categoria não encontrada.")


def menu_gerenciar_categorias():
    """Submenu exclusivo do gestor."""
    while True:
        print("\n=== GERENCIAR CATEGORIAS ===")
        print("1 - Cadastrar categoria")
        print("2 - Listar todas as categorias (ativas e inativas)")
        print("3 - Ativar ou desativar categoria")
        print("4 - Ver somente as categorias ativas")
        print("0 - Voltar")
        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            cadastrar_categoria()
        elif opcao == "2":
            listar_todas_categorias()
        elif opcao == "3":
            alternar_estado_categoria()
        elif opcao == "4":
            consultar_categorias()
        elif opcao == "0":
            break
        else:
            print("Opção inválida. Tente novamente.")


# ---------------------------------------------------------------
# RELATOS
# ---------------------------------------------------------------

def existe_categoria_ativa():
    """Devolve True se houver pelo menos uma categoria ativa."""
    for categoria in categorias:
        if categoria["ativa"]:
            return True
    return False


def buscar_categoria_ativa(id_categoria):
    """Devolve a categoria ativa com esse identificador, ou None se não existir."""
    for categoria in categorias:
        if categoria["id_categoria"] == id_categoria and categoria["ativa"]:
            return categoria
    return None


def converter_para_numero(texto):
    """Tenta transformar o texto em número. Devolve None se não for possível."""
    texto = texto.strip().replace(",", ".")
    try:
        return float(texto)
    except ValueError:
        return None


def cadastrar_relato(usuario):
    print("\n--- Registrar relato ---")

    # Sem categoria ativa não dá para classificar o relato.
    if not existe_categoria_ativa():
        print("Não há categorias ativas. Peça a um gestor para cadastrar uma categoria.")
        return

    titulo = input("Título do relato: ").strip()
    if titulo == "":
        print("Erro: o título não pode ficar vazio.")
        return

    descricao = input("Descrição do problema: ").strip()
    if descricao == "":
        print("Erro: a descrição não pode ficar vazia.")
        return

    consultar_categorias()
    texto_categoria = input("\nDigite o identificador da categoria: ").strip()
    if not texto_categoria.isdigit():
        print("Erro: digite um número válido.")
        return
    categoria = buscar_categoria_ativa(int(texto_categoria))
    if categoria is None:
        print("Erro: categoria não encontrada ou desativada.")
        return

    print("\nLocalização do problema (use ponto ou vírgula nos decimais, ex.: -23.5505)")
    latitude = converter_para_numero(input("Latitude (-90 a 90): "))
    if latitude is None or latitude < -90 or latitude > 90:
        print("Erro: latitude inválida. Digite um número entre -90 e 90.")
        return
    longitude = converter_para_numero(input("Longitude (-180 a 180): "))
    if longitude is None or longitude < -180 or longitude > 180:
        print("Erro: longitude inválida. Digite um número entre -180 e 180.")
        return

    # Só chegamos aqui se todos os dados estão corretos.
    id_novo = len(relatos) + 1

    novo_relato = {
        "id_relato": id_novo,
        "id_usuario": usuario["id_usuario"],
        "id_categoria": categoria["id_categoria"],
        "titulo": titulo,
        "descricao": descricao,
        "status_problema": "Aberto",
        "status_verificacao": "Pendente",
        "data_relato": datetime.now().strftime("%d/%m/%Y %H:%M"),
    }
    relatos.append(novo_relato)

    nova_localizacao = {
        "id_localizacao": len(localizacoes) + 1,
        "id_relato": id_novo,
        "latitude": latitude,
        "longitude": longitude,
    }
    localizacoes.append(nova_localizacao)

    print("\nRelato registrado com sucesso!")
    print("Identificador:", id_novo)
    print("Título:", titulo)
    print("Categoria:", categoria["nome_categoria"])
    print("Localização:", latitude, ",", longitude)
    print("Status do problema:", novo_relato["status_problema"], "| Verificação:", novo_relato["status_verificacao"])


# ---------------------------------------------------------------
# LISTAGEM E CONSULTA DE RELATOS
# ---------------------------------------------------------------

def buscar_categoria(id_categoria):
    """Devolve a categoria com esse identificador (ativa ou não), ou None."""
    for categoria in categorias:
        if categoria["id_categoria"] == id_categoria:
            return categoria
    return None


def buscar_localizacao(id_relato):
    """Devolve a localização ligada a esse relato, ou None."""
    for localizacao in localizacoes:
        if localizacao["id_relato"] == id_relato:
            return localizacao
    return None


def listar_relatos():
    """Mostra um resumo de todos os relatos. Usuário comum e gestor podem usar."""
    print("\n--- Relatos cadastrados ---")

    if len(relatos) == 0:
        print("Nenhum relato cadastrado.")
        return

    for relato in relatos:
        categoria = buscar_categoria(relato["id_categoria"])
        if categoria is None:
            nome_categoria = "(categoria não encontrada)"
        else:
            nome_categoria = categoria["nome_categoria"]

        print(relato["id_relato"], "-", relato["titulo"], "|", nome_categoria,
              "| Problema:", relato["status_problema"],
              "| Verificação:", relato["status_verificacao"])


def mostrar_detalhes_relato(relato):
    categoria = buscar_categoria(relato["id_categoria"])
    if categoria is None:
        nome_categoria = "(categoria não encontrada)"
    else:
        nome_categoria = categoria["nome_categoria"]

    localizacao = buscar_localizacao(relato["id_relato"])

    print("\n=== RELATO", relato["id_relato"], "===")
    print("Título:", relato["titulo"])
    print("Descrição:", relato["descricao"])
    print("Categoria:", nome_categoria)
    if localizacao is None:
        print("Localização: não informada")
    else:
        print("Localização: latitude", localizacao["latitude"], "| longitude", localizacao["longitude"])
    print("Status do problema:", relato["status_problema"])
    print("Situação da verificação:", relato["status_verificacao"])
    print("Data do relato:", relato["data_relato"])


def consultar_relato():
    """Pede um identificador e mostra os detalhes do relato. Usuário comum e gestor podem usar."""
    print("\n--- Consultar relato ---")

    if len(relatos) == 0:
        print("Nenhum relato cadastrado.")
        return

    texto = input("Digite o identificador do relato: ").strip()
    if not texto.isdigit():
        print("Erro: digite um número válido.")
        return
    id_escolhido = int(texto)

    for relato in relatos:
        if relato["id_relato"] == id_escolhido:
            mostrar_detalhes_relato(relato)
            return

    print("Relato não encontrado.")


# ---------------------------------------------------------------
# MENUS
# ---------------------------------------------------------------

def em_breve(nome_funcao):
    print("'" + nome_funcao + "' será implementado nas próximas etapas.")


def menu_usuario_comum(usuario):
    while True:
        print("\n=== MENU DO USUÁRIO ===")
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
            print("Opção inválida. Tente novamente.")


def menu_gestor(usuario):
    while True:
        print("\n=== MENU DO GESTOR ===")
        print("Olá,", usuario["nome"])
        print("1 - Gerenciar categorias")
        print("2 - Listar relatos")
        print("3 - Consultar relato específico")
        print("4 - Validar relato")
        print("5 - Atualizar status do problema")
        print("6 - Histórico de validações")
        print("7 - Criar conta de outro gestor")
        print("0 - Sair da conta")
        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            menu_gerenciar_categorias()
        elif opcao == "2":
            listar_relatos()
        elif opcao == "3":
            consultar_relato()
        elif opcao == "4":
            em_breve("Validar relato")
        elif opcao == "5":
            em_breve("Atualizar status do problema")
        elif opcao == "6":
            em_breve("Histórico de validações")
        elif opcao == "7":
            cadastrar_usuario("gestor")
        elif opcao == "0":
            print("Você saiu da conta.")
            break
        else:
            print("Opção inválida. Tente novamente.")


def menu_inicial():
    while True:
        print("\n=== SIDEWALK MAP ===")
        print("1 - Cadastrar nova conta")
        print("2 - Entrar (login)")
        if not existe_gestor():
            print("3 - Criar o primeiro gestor")
        print("0 - Sair")
        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            cadastrar_usuario()
        elif opcao == "2":
            usuario_logado = fazer_login()
            if usuario_logado is not None:
                if usuario_logado["perfil"] == "gestor":
                    menu_gestor(usuario_logado)
                else:
                    menu_usuario_comum(usuario_logado)
        elif opcao == "3":
            cadastrar_primeiro_gestor()
        elif opcao == "0":
            print("Encerrando o programa. Até logo!")
            break
        else:
            print("Opção inválida. Tente novamente.")


# Início do programa (sempre a última linha do arquivo)
menu_inicial()