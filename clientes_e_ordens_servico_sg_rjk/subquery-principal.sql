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
	date_format(ultimaSatisfacaoCliente.dataPesquisa, '%d/%m/%Y') as dataPesquisaSatisfacaoCliente,
	ultimaSatisfacaoCliente.nota as notaPesquisaSatisfacaoCliente,
	ultimaSatisfacaoCliente.contato as contatoPesquisaSatisfacaoCliente,
	date_format(ultimoControleVisita.dataVisita, '%d/%m/%Y') as dataUltimoControleVisita,
	ultimoControleVisita.contato as contatoUltimoControleVisita,
	ifnull(totalControleVisita12Meses.numeroVisitas12Meses,0) as totalControleVisita12Meses,
	dataOSVelha.dataOSAbertaAntiga as dataOSVelha, 
	concat(ultimoControleVisita.fkIdUsuario, ' ', ultimoControleVisita.login) as tecnicoUltimaVisita,
	ifnull(totalOS12meses.totalOSUltimosDozeMeses,0) as totalOSUltimosDozeMeses,
	ifnull(quantidadeOSEmAberto.totalOSEmAberto,0) as quantidadeOSEmAberto,
	ifnull(quantidadeOSEmAbertoBug.totalOSEmAbertoBug,0) as quantidadeOSEmAbertoBug,
	ifnull(quantidadeOSEmAbertoAlteracao.totalOSEmAbertoAlteracao,0) as quantidadeOSEmAbertoAlteracao,
	ifnull(quantidadeOSEmAbertoPendencia.totalOSEmAbertoPendencia,0) as quantidadeOSEmAbertoPendencia,
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
LEFT JOIN(
        SELECT wpsc.fkCodcliCadcli, wpsc.dataPesquisa,wpsc.nota, wpsc.contato
        FROM webPesquisaSatisfacaoCliente wpsc
        INNER JOIN (
                    SELECT fkCodcliCadcli,max(dataPesquisa) as dataPesquisa
                    FROM webPesquisaSatisfacaoCliente group by fkCodcliCadcli
        ) wpscsub ON wpsc.dataPesquisa = wpscsub.dataPesquisa AND wpsc.fkCodcliCadcli = wpscsub.fkCodcliCadcli
) as ultimaSatisfacaoCliente ON ultimaSatisfacaoCliente.fkCodcliCadcli = cc.codcli10
LEFT JOIN(
        SELECT c.codcli10, controleVisita.dataVisita, controleVisita.contato, controleVisita.fkIdUsuario, wu.login FROM webcontrolevisita controleVisita
        INNER JOIN (
                    SELECT wc.cnpj, max(wc.dataVisita) as dataPesquisa from webcontrolevisita wc group by wc.cnpj
        ) t2 ON (controleVisita.dataVisita = t2.dataPesquisa AND t2.cnpj = controleVisita.cnpj)
        inner join cadcli c on (c.cgccpf10 = t2.cnpj)
        left join webUsuario wu on wu.id = controleVisita.fkIdUsuario
        group by t2.cnpj
) as ultimoControleVisita ON ultimoControleVisita.codcli10 = cc.codcli10
LEFT JOIN (
        SELECT c.codcli10 as codcli, count(*) as numeroVisitas12Meses
        FROM webcontrolevisita wc
        INNER JOIN cadcli c on (c.cgccpf10 = wc.cnpj)
        WHERE wc.dataVisita is not null AND DATE_ADD(wc.dataVisita, INTERVAL 12 MONTH) >= NOW()
        GROUP BY c.codcli10
) as totalControleVisita12Meses ON (totalControleVisita12Meses.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, count(codord) as totalOSEmAberto
        FROM suptec spt
        WHERE spt.codsit is null
        GROUP BY codcli
) as quantidadeOSEmAberto ON (quantidadeOSEmAberto.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, date_format(min(data), '%d/%m/%Y') as dataOSAbertaAntiga FROM suptec spt WHERE spt.codsit is null
        GROUP BY codcli
) as dataOSVelha ON (dataOSVelha.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, count(codord) as totalOSUltimosDozeMeses
        FROM suptec spt
        WHERE DATE_ADD(spt.data, INTERVAL 12 MONTH) >= NOW()
        GROUP BY codcli
) as totalOS12meses ON (totalOS12meses.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, count(codord) as totalOSEmAbertoBug
        FROM suptec spt
        WHERE spt.codcat in (3, 27, 29) and codsit is null
        GROUP BY codcli
) as quantidadeOSEmAbertoBug ON (quantidadeOSEmAbertoBug.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, count(codord) as totalOSEmAbertoAlteracao
        FROM suptec spt
        WHERE spt.codcat in (4,25) and codsit is null
        GROUP BY codcli
) as quantidadeOSEmAbertoAlteracao ON (quantidadeOSEmAbertoAlteracao.codcli = cc.codcli10)
LEFT JOIN(
        SELECT codcli, count(codord) as totalOSEmAbertoPendencia
        FROM suptec spt
        WHERE spt.codcat in (6,11,19,21) and codsit is null
        GROUP BY codcli
) as quantidadeOSEmAbertoPendencia ON (quantidadeOSEmAbertoPendencia.codcli = cc.codcli10)
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