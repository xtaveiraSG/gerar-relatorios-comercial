select
    upper(p.descricao) as nomeproduto,
    p.produto as idproduto,
    m.descricao as nomemodulo,
    m.modulo as idmodulo,
    sum(submodulo) as submodulo,
    sum(qtdpdv) as pdvs,
    sum(qtdestac) as estacoes
from
    produtos p
left join modulos m on
    p.produto = m.produto
left join prodsg p2 on
    p.produto = p2.produto
group by
    p.produto,
    m.descricao
order by
    p.descricao,
    m.descricao