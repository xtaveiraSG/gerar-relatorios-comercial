-- CONSTRUIR SUBQUERY PRODUTOS DINAMICAMENTE
select
	concat( 'select cnpj as CNPJPRODUTO, ', group_concat( 
CONCAT(
    "
IF( prodsg.produto = ", p.produto, ", 'OK', '') AS '", UPPER(p.descricao), "'"
  )), ' from prodsg group by cnpj' )
from
	produtos p