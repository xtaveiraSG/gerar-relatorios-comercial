 select
	sg.empresa as "EMPRESA",
	SG.cgc as "CNPJ",
	cc.razsoc10 as "RAZAOSOCIAL",
	tp.desctipo as "REPRESENTANTE",
	tp2.desctipo as "REPRESENTANTE2"
from
	sgscli sg
inner join cadcli cc on
	cc.cgccpf10 = sg.cgc
inner join tipcli tp on
	tp.codtipo = cc.tipocli10
left join tipcli tp2 on
	tp2.codtipo = sg.parceiro2
left join prodsg p on
	p.cnpj = sg.cgc and p.produto = 23
where
	cc.situacao10 in (1, 4)
	and p.cnpj is null
group by
	sg.empresa,
	sg.cgc
