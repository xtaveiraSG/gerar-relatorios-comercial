SELECT 
  CONCAT(
    'SELECT cnpj AS CNPJMODULO, ', 
    GROUP_CONCAT(
      CONCAT(
        "
	IF( modulosg.modulo = '", m.modulo, "' AND modulosg.produto = '", m.produto, "', 'OK', '') AS `", m.produto, "_", REPLACE(m.descricao,"`","``"), "`"
      ) 
    ), 
    ' FROM modulosg GROUP BY cnpj'
  ) 
FROM modulos m;

