import json

# so o nome do produto
query_produto = 'q.`{0}`,'

# se triver submodulo (codigo_)
query_submodulo = 'q.`{0}_SUBMODULO`,'

# se triver PDVs (codigo_)
query_pdv = 'q.`{0}_PDVs`,'

# se triver estacoes (codigo_)
query_estacoes = 'q.`{0}_ESTACOES`,'

# se tiver modulo (codigo_desc}
query_modulo = 'q.`{0}_{1}`,'


# planilha = pd.read_excel('teste.xlsx')

aux = ''
with open('ordenacao.json', 'r') as f:
        data = json.load(f)


# def encontrar_codigo(nome: str):
#     for obj in data['aaa']:
#         produto = obj['PRODUTO']
#         if produto == nome.upper():
#             cod = int(obj['produto'])
#             return cod


# Função para encontrar o primeiro array de objetos dentro do JSON
def encontrar_array(obj):
    for value in obj.values():
        if isinstance(value, list) and all(isinstance(item, dict) for item in value):
            return value  # Retorna o primeiro array encontrado
    return None

# Identificar o array de objetos
array_dados = encontrar_array(data)

# with open('davi2.txt', 'w') as w:
with open('query-ordenada.sql', 'w') as w:

    # for i, j in planilha.iterrows():
    for obj in array_dados:
        codigo = int(obj['idproduto'])

        if obj['nomeproduto'] == aux:

            query = query_modulo.format(codigo, obj['nomemodulo'])
            query+=('\n')

            # if pd.notnull(obj['nomemodulo']) and obj['nomemodulo'] != '--':
            #     query = query_modulo.format(codigo, obj['nomemodulo'])
        else:
            a = True
            b = True
            c = True
            query = query_produto.format(obj['nomeproduto'])
            query+=('\n')

        if   obj['submodulo']  and a:
            a = False
            query+=(query_submodulo.format(codigo))
            query+=('\n')

        if   obj['pdvs']  and b:
            b = False
            query+=(query_pdv.format(codigo))
            query+=('\n')

        if   obj['estacoes']  and c:
            c = False
            query+=(query_estacoes.format(codigo))
            query+=('\n')

        if obj['nomeproduto'] != aux:
            if   obj['nomemodulo'] :
                query += query_modulo.format(codigo, obj['nomemodulo'])
                query+=('\n')


        aux =obj['nomeproduto'] 
        w.write(query)

print('query gerada! :)')



    # if pd.isnull(j.iloc[2]) or j.iloc[2] == '--':
    #     print()
    # else:
    #     print(j.iloc[2])