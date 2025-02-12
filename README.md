## Passo a passo para construção dos relatórios do Comercial (Interno)
---

### Basicamente dentro de cada pasta está as instruções necessárias para:

- construir as primeiras colunas (informações dos clientes)
- construção das subqueries (todos os produtos, todos os módulos, quantidades de pdv, estações, etc...)
- construção da subquery principal de cada relatório (join entre as subqueries)
- rodar script de ordenação da query principal (que vai puxar os dados da subquery de forma ordenada)
- rodar o script que vai transformar o .json em um .xlsx

