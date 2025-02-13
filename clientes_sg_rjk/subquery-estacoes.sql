SELECT CONCAT('
SELECT cnpj AS CNPJESTACOES, ', GROUP_CONCAT(
			CONCAT("
	IF(p.produto = ",estac.produto,", p.qtdestac, 0) AS `",estac.produto,"_ESTACOES`"
			)
		),' 
FROM prodsg p GROUP BY cnpj'
) FROM (select pd.produto  from prodsg pd where pd.qtdestac is not null group by pd.produto) as estac;
	