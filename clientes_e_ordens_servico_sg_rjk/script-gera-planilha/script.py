import json
import pandas as pd
import os
import re
from datetime import datetime
from openpyxl import load_workbook

# Padrão do nome dos arquivos JSON
def encontrar_arquivo_mais_recente():
    arquivos = [f for f in os.listdir() if re.match(r'\d{4}-\d{2}-\d{2}-ordenada-clientes-(sg|rjk)\.json', f)]
    
    if not arquivos:
        print("Nenhum arquivo correspondente encontrado.")
        return None
    
    arquivos.sort(reverse=True, key=lambda x: datetime.strptime(x[:10], "%Y-%m-%d"))
    return arquivos[0]  # Retorna o mais recente

# Encontrar o arquivo mais recente
json_file = encontrar_arquivo_mais_recente()
if not json_file:
    exit()

# Carregar os dados do JSON
with open(json_file, "r", encoding="utf-8") as file:
    data = json.load(file)

# Função para encontrar o primeiro array de objetos dentro do JSON
def encontrar_array(obj):
    for value in obj.values():
        if isinstance(value, list) and all(isinstance(item, dict) for item in value):
            return value  # Retorna o primeiro array encontrado
    return None

# Função para formatar datas
def formatar_datas(df, colunas):
    for coluna in colunas:
        if coluna in df.columns:
            df[coluna] = pd.to_datetime(df[coluna], errors='coerce').dt.strftime('%d/%m/%Y')
    return df

# Identificar o array de objetos
array_dados = encontrar_array(data)

# Determinar o nome da planilha com base no nome do arquivo JSON
# Remover a palavra "ordenada" do nome do arquivo antes de salvar
nome_planilha = json_file.replace('ordenada-clientes', 'CLIENTES-DETALHADOS').replace('.json', '.xlsx')

if array_dados:
    # Converter para DataFrame
    df = pd.DataFrame(array_dados)
    
    # Identificar automaticamente colunas de datas (YYYY-MM-DD ou variantes)
    colunas_de_data = [col for col in df.columns if df[col].astype(str).str.match(r'\d{4}-\d{2}-\d{2}').any()]
    
    # Formatar datas
    df = formatar_datas(df, colunas_de_data)
    
    # Salvar em Excel com o nome correspondente ao arquivo JSON
    df.to_excel(nome_planilha, index=False, engine="openpyxl")
    
    # Ajustar automaticamente as colunas ao conteúdo
    wb = load_workbook(nome_planilha)
    ws = wb.active
    for col in ws.columns:
        max_length = 0
        col_letter = col[0].column_letter  # Obtém a letra da coluna
        for cell in col:
            try:
                if cell.value:
                    max_length = max(max_length, len(str(cell.value)))
            except:
                pass
        adjusted_width = (max_length + 2)
        ws.column_dimensions[col_letter].width = adjusted_width
    
    wb.save(nome_planilha)
    print(f"Planilha gerada com sucesso: {nome_planilha} (Baseado em: {json_file})")
else:
    print("Nenhum array de objetos encontrado no JSON.")

