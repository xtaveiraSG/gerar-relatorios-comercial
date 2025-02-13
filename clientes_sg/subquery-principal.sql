(
    select
	sg.empresa as "EMPRESA",
	cc.codcli10 as "CADCL",
	cc.nomefan10 as "FANTASIA",
	cc.razsoc10 as "RAZAOSOCIAL",
	cc.situacao10 as "SITUACAO",
	cc.dtultsit10 as "DATASITUACAO",
	sg.datainstal as "DATAINSTALACAO",
	sg.dtreajuste as "DATAULTIMOREAJUSTE",
	tv.nome as "VENDEDOR",
	ct.descricao as "CLASSIFICACAO",
	tp.desctipo as "REPRESENTANTE",
	tp2.desctipo as "REPRESENTANTE2",
	cc.nomecon10 as "CONTATO",
	cc.fonecli10 as "TELEFONE",
	sr.VALOR,
	SG.cgc as "CNPJ",
	produtos.*,
	modulos.*,
	submodulos.*,
	quantidadesPDV.*,
	quantidadesESTACOES.*,
	cc.vended10 as "TECNICO",
	cc.emailcli10 as "EMAIL",
	case sg.tipo
		 WHEN 'C' THEN "ADMINISTRADORA DE CARTOES" 
         WHEN 'T' THEN "ASSISTENCIA TECNICA"       
         WHEN 'A' THEN "ASSOCIACAO DE COMPRAS"     
         WHEN 'P' THEN "AUTO PECAS"                
         WHEN 'F' THEN "ACOUGUE"                   
         WHEN 'K' THEN "C.D."                      
         WHEN 'V' THEN "CONFECCOES/CALCADOS"       
         WHEN 'D' THEN "DISTRIBUIDORA"             
         WHEN 'I' THEN "IND. PANIFICACAO"          
         WHEN 'L' THEN "LOJA DE DEPARTAMENTOS"     
         WHEN 'M' THEN "MATERIAL DE CONSTRUCAO"    
         WHEN 'B' THEN "MONITORAMENTO DE TELA"     
         WHEN 'J' THEN "OFICINAS MECANICA/ELETRICA"
         WHEN 'G' THEN "PANIFICADORA"              
         WHEN 'N' THEN "PAPELARIA"                 
         WHEN 'R' THEN "RESTAURANTE E SIMILAR"     
         WHEN 'S' THEN "SUPERMERCADO"              
         WHEN 'O' THEN "OUTROS" 
         ELSE          "NAO INFORMADO"  
     end TIPOEMPRESA
from
	sgscli sg
inner join cadcli cc on
	cc.cgccpf10 = sg.cgc
left join tabven tv on
	tv.codigo = cc.vended210
left join catcli ct on
	ct.codigo = sg.codcatcli
inner join tipcli tp on
	tp.codtipo = cc.tipocli10
left join tipcli tp2 on
	tp2.codtipo = sg.parceiro2
left join (
	select
		sc.codcli,
		sum(sc.valor) as VALOR
	from
		sercli sc
	inner join (
		select
			codigo
		from
			tipser
		where
			servrecor is null) tp on
		tp.codigo = sc.codsercli
	group by
		sc.codcli ) sr on
	sr.codcli = cc.codcli10
left join (

    SUBQUERY PRODUTOS

)  produtos on
	produtos.CNPJPRODUTO = sg.cgc
left join (

    SUBQUERY MODULOS

)  modulos on
    modulos.CNPJMODULO = sg.cgc
left join (
	select 
		cnpj as CNPJPDV,
	    SUM(qtdpdv) as "TOTAL_PDVs",
    
    SUBQUERY TOTAL PDVS

)   quantidadesPDV on quantidadesPDV.CNPJPDV = sg.cgc
	left join (		
	select 
		cnpj as CNPJESTACOES,
	    SUM(qtdestac) as "TOTAL_ESTACOES",

    SUBQUERY TOTAL ESTACOES

)   quantidadesESTACOES on quantidadesESTACOES.CNPJESTACOES = sg.cgc
left join (
		select
			pd.cnpj as CNPJSUBMODULOS,

    SUBQUERY SUBMODULOS

) submodulos on submodulos.CNPJSUBMODULOS = sg.cgc
) as q