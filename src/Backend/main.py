usuarios = []
categorias = []
relatos = []



# 1. USUÁRIOS E AUTENTICAÇÃO

def existe_gestor():
    for usuario in usuarios:
        if usuario["perfil"] == "gestor":
            return True
    return False


def cadastrar_usuario(perfil="comum"):
    print("\n--- CADASTRO DE USUÁRIO ---")
    nome = input("Nome: ").strip()
    email = input("E-mail: ").strip().lower()
    senha = input("Senha: ").strip()

    if nome == "" or email == "" or senha == "":
        print("Erro: Nenhum campo pode ficar vazio.")
        return

    if "@" not in email:
        print("Erro: Digite um e-mail válido (precisa ter @).")
        return

    # Verifica se e-mail já existe
    for u in usuarios:
        if u["email"] == email:
            print("Erro: Já existe uma conta com esse e-mail.")
            return

    novo_usuario = {
        "id_usuario": len(usuarios) + 1,
        "nome": nome,
        "email": email,
        "senha": senha,
        "perfil": perfil
    }

    usuarios.append(novo_usuario)
    print("Conta criada com sucesso! Perfil:", perfil)


def cadastrar_primeiro_gestor():
    if existe_gestor():
        print("Erro: Já existe um gestor cadastrado no sistema.")
    else:
        cadastrar_usuario("gestor")


def fazer_login():
    print("\n=== LOGIN ===")
    email = input("E-mail: ").strip().lower()
    senha = input("Senha: ").strip()

    for usuario in usuarios:
        if usuario["email"] == email and usuario["senha"] == senha:
            print("\nBem-vindo(a),", usuario["nome"] + "!")
            return usuario

    print("Erro: E-mail ou senha incorretos.")
    return None



# 2. GERENCIAMENTO DE CATEGORIAS

def consultar_categorias():
    print("\n--- CATEGORIAS DISPONÍVEIS ---")
    if len(categorias) == 0:
        print("Nenhuma categoria cadastrada.")
        return

    achou = False
    for cat in categorias:
        if cat["ativa"]:
            desc = cat["descricao"]
            if desc == "":
                desc = "(sem descrição)"
            print(cat["id_categoria"], "-", cat["nome"], "|", desc)
            achou = True

    if not achou:
        print("Nenhuma categoria ativa no momento.")


def listar_todas_categorias():
    print("\n--- TODAS AS CATEGORIAS ---")
    if len(categorias) == 0:
        print("Nenhuma categoria cadastrada.")
        return

    for cat in categorias:
        if cat["ativa"]:
            status = "Ativa"
        else:
            status = "Inativa"

        desc = cat["descricao"]
        if desc == "":
            desc = "(sem descrição)"

        print(cat["id_categoria"], "-", cat["nome"], "|", desc, "| Status:", status)


def cadastrar_categoria():
    print("\n--- CADASTRAR CATEGORIA ---")
    nome = input("Nome da categoria: ").strip()

    if nome == "":
        print("Erro: O nome da categoria não pode ficar vazio.")
        return

    # Verifica se a categoria já existe
    for cat in categorias:
        if cat["nome"].lower() == nome.lower():
            print("Erro: Já existe uma categoria com esse nome.")
            return

    descricao = input("Descrição (opcional): ").strip()

    nova_categoria = {
        "id_categoria": len(categorias) + 1,
        "nome": nome,
        "descricao": descricao,
        "ativa": True
    }

    categorias.append(nova_categoria)
    print("Categoria cadastrada com sucesso!")


def menu_gerenciar_categorias():
    while True:
        print("\n=== GERENCIAR CATEGORIAS ===")
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
            print("Opção inválida. Tente novamente.")



# 3. REGISTRO E CONSULTA DE RELATOS

def cadastrar_relato(usuario):
    print("\n--- REGISTRAR RELATO ---")

    # Verifica se há pelo menos uma categoria ativa
    tem_categoria = False
    for cat in categorias:
        if cat["ativa"]:
            tem_categoria = True
            break

    if not tem_categoria:
        print("Erro: Não há categorias ativas. Peça a um gestor para cadastrar uma.")
        return

    titulo = input("Título do relato: ").strip()
    if titulo == "":
        print("Erro: O título não pode ficar vazio.")
        return

    descricao = input("Descrição do problema: ").strip()
    if descricao == "":
        print("Erro: A descrição não pode ficar vazia.")
        return

    # Exibe categorias ativas para o usuário escolher
    consultar_categorias()
    id_cat_digitado = input("\nDigite o ID da categoria desejada: ").strip()

    categoria_encontrada = None
    for cat in categorias:
        if str(cat["id_categoria"]) == id_cat_digitado and cat["ativa"]:
            categoria_encontrada = cat
            break

    if categoria_encontrada is None:
        print("Erro: Categoria não encontrada ou desativada.")
        return

    print("\nLocalização do problema:")
    lat_texto = input("Latitude (-90 a 90): ").strip().replace(",", ".")
    long_texto = input("Longitude (-180 a 180): ").strip().replace(",", ".")

    latitude = float(lat_texto)
    longitude = float(long_texto)

    if latitude < -90 or latitude > 90:
        print("Erro: Latitude fora do limite (-90 a 90).")
        return

    if longitude < -180 or longitude > 180:
        print("Erro: Longitude fora do limite (-180 a 180).")
        return

    novo_relato = {
        "id_relato": len(relatos) + 1,
        "id_usuario": usuario["id_usuario"],
        "nome_usuario": usuario["nome"],
        "nome_categoria": categoria_encontrada["nome"],
        "titulo": titulo,
        "descricao": descricao,
        "latitude": latitude,
        "longitude": longitude,
        "status_problema": "Aberto",
        "status_verificacao": "Pendente"
    }

    relatos.append(novo_relato)

    print("\nRelato registrado com sucesso!")
    print("ID:", novo_relato["id_relato"])
    print("Título:", titulo)
    print("Categoria:", categoria_encontrada["nome"])
    print("Coordenadas:", latitude, ",", longitude)


def listar_relatos():
    print("\n--- RELATOS CADASTRADOS ---")

    if len(relatos) == 0:
        print("Nenhum relato cadastrado.")
        return

    for relato in relatos:
        print(relato["id_relato"], "-", relato["titulo"], "| Categoria:", relato["nome_categoria"], "| Status:", relato["status_problema"])


def consultar_relato():
    print("\n--- CONSULTAR RELATO ---")

    if len(relatos) == 0:
        print("Nenhum relato cadastrado.")
        return

    id_digitado = input("Digite o ID do relato: ").strip()

    for relato in relatos:
        if str(relato["id_relato"]) == id_digitado:
            print("\n=== DETALHES DO RELATO ===")
            print("ID:", relato["id_relato"])
            print("Título:", relato["titulo"])
            print("Descrição:", relato["descricao"])
            print("Categoria:", relato["nome_categoria"])
            print("Usuário que relatou:", relato["nome_usuario"])
            print("Localização (Lat/Long):", relato["latitude"], ",", relato["longitude"])
            print("Status do problema:", relato["status_problema"])
            print("Status da verificação:", relato["status_verificacao"])
            return

    print("Relato não encontrado.")


# 4. MENUS DO SISTEMA

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


# Início da execução do programa
menu_inicial()