SELECT CONCAT(
  'SELECT cnpj AS CNPJPRODUTO, ', GROUP_CONCAT(
      CONCAT("
  IF(SUM(IF(pd.produto = " ,p.produto, ", 1, 0)) > 0, 'OK', '') AS `", UPPER(REPLACE(p.descricao,"`","``")),"`"
      )
    ),' FROM prodsg pd GROUP BY cnpj'
) FROM produtos p;