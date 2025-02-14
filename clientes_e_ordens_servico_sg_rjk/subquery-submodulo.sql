SELECT CONCAT('
SELECT cnpj AS CNPJSUBMODULOS, ', GROUP_CONCAT(
			CONCAT("
if(sum(IF(p.produto = ",submodulo.produto," && p.submodulo > 0, 1, 0 )) > 0, s.descricao, '') AS `",submodulo.produto,"_SUBMODULO`"
			)
		),'
FROM prodsg p
left join submodul s on p.submodulo = s.submodulo GROUP BY cnpj' 
) FROM (select pd.produto from prodsg pd where pd.submodulo is not null group by pd.produto) as submodulo;