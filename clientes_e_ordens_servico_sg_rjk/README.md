## CLIENTES SG / RJK (Só mudar o banco que funciona para as duas)
---

### Estrutura da Query:
```
    select
        q.(informações dos clientes)
        q.(informações ordenadas pelo script)
    from (

        PASSO -> 2
        select (essa é a subquery gigante que terá tudo)
            (dados da empresa),
            produtos.*,
            modulos.*,
            submodulos.*,
            quantidadesPDV.*,
            quantidadesESTACOES.*,
        from sgsclisg
        
        aqui vai ficar uma sequência de inner joins e left joins 
        (primeiro alguns para ligar aos dados dos clientes depois os que você vai gerar)
        
        PASSO -> 3
        left join produtos

        PASSO -> 4
        left join modulos

        PASSO -> 5
        left join submodulos

        PASSO -> 6
        left join quantidadesPDV

        PASSO -> 7
        left join quantidadesESTACOES

    ) as q 
```

### Construção:
- Passo 1: criar o arquivo da query atualizada: ANO-MES-DIA-CLIENTES-EMPRESA.sql
- Passo 2: pegar a base da subquery principal no arquivo subquery-principal.sql

- <strong>A SUBQUERY É O RESULTADO DA QUERY EXISTENTE EM CADA ARQUIVO </strong>
- <strong>TESTE A SUBQUERY ANTES DE COLOCAR NA SUBQUERY PRINCIPAL, TALVEZ ALGUM NOME DE PRODUTO OU MÓDULO COM '(ASPAS) PODE ESTRAGAR A QUERY, AÍ VOCÊ APAGA A ASPAS</strong>
- Passo 3: gerar a subquery produtos e adicionar ao left join da subquery principal (subquery-produtos.sql)
- Passo 4: gerar a subquery modulos e adicionar ao left join da subquery principal
- Passo 5: gerar a subquery submodulos e adicionar ao left join da subquery principal
- Passo 6: gerar a subquery quantidadesPDV e adicionar ao left join da subquery principal
- Passo 7: gerar a subquery quantidadesESTACOES e adicionar ao left join da subquery principal



- rodar script de ordenação da query principal (que vai puxar os dados da subquery de forma ordenada)
- rodar o script que vai transformar o .json em um .xlsx

