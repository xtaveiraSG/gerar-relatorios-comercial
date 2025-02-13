SELECT CONCAT('
SELECT cnpj AS CNPJPDV, ', GROUP_CONCAT(
			CONCAT("
	IF(p.produto = ",pdv.produto,", p.qtdpdv, 0) AS `",pdv.produto,"_PDVs`"
			)
		),' 
FROM prodsg p GROUP BY cnpj'
) FROM (select pd.produto  from prodsg pd where pd.qtdpdv is not null group by pd.produto) as pdv;