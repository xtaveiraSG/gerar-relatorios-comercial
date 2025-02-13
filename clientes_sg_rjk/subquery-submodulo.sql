SELECT CONCAT('
SELECT cnpj AS CNPJSUBMODULO, ', GROUP_CONCAT(
			CONCAT("
	IF(p.produto = ",submodulo.produto,", s.descricao, '') AS `",submodulo.produto,"_SUBMODULO`"
			)
		),'
FROM prodsg p
left join submodul s on p.produto = s.produto GROUP BY cnpj' 
) FROM (select pd.produto from prodsg pd where pd.submodulo is not null group by pd.produto) as submodulo;