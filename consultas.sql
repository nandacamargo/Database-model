-----------------------------------------
-- Consultas
-----------------------------------------

-------------------------------------
--Consulta envolvendo Visita
-------------------------------------
--Recupere os nomes de Mães e respectivas Crianças atendidas por uma Enfermeira que 
--trabalhe no Hospital das Dores. Além disso, conte quantas Visitas a Enfermeira realizou para elas.

SELECT m.PNOME as pnome_mae, m.SNOME as snome_mae, 
       c.PNOME as pnome_crianca, c.SNOME as snome_crianca, 
       e.PNOME as pnome_enfermeira, e.SNOME as snome_enfermeira, count(v.Num_visita)
FROM (SELECT * FROM Mae NATURAL JOIN Pessoa) as m, 
     (SELECT * FROM Enfermeira NATURAL JOIN Pessoa) as e,
     (SELECT * FROM Crianca NATURAL JOIN Pessoa) as c, Visita AS v
WHERE  e.NomeHospital = 'Hospital das Dores' AND e.CPF = v.CPF_enfermeira 
      AND m.CPF = v.CPF_mae AND c.idCertidaoNascimento = v.idCertidaoNascimento 
GROUP BY m.PNOME, m.SNOME, c.PNOME, c.SNOME, e.PNOME, e.SNOME;


------------------------------------------------
--Consulta envolvendo Exames e Aparelho Médico
------------------------------------------------
--Recupere os nomes de Mães e Crianças que realizaram Exame físico que utilizavam algum 
--Aparelho Médico com estado de conservação 'muito bom'. Recupere também o tipo
--de Aparelho e seu número de série.

SELECT DISTINCT m.PNOME as pnome_mae, m.SNOME as snome_mae, 
        c.PNOME as pnome_crianca, c.SNOME as snome_crianca, 
        ap.numero_serie, ap.tipo
FROM (SELECT * FROM Mae NATURAL JOIN Pessoa) as m, 
     (SELECT * FROM Crianca NATURAL JOIN Pessoa) as c,
     Examina_crianca_pode_usar as ec, Examina_mae_pode_usar as em, 
     (SELECT * FROM Aparelho_medico WHERE estado_conservacao = 'muito bom') as ap
WHERE m.CPF = em.CPF_mae AND c.idCertidaoNascimento = ec.idCertidaoNascimento
      AND ec.numero_serie = ap.numero_serie AND em.numero_serie = ap.numero_serie;


------------------------------------------------
--Consulta envolvendo Exames e Enfermeiras
------------------------------------------------
--Busque os nomes de Enfermeiras que realizam pelo menos um Exame em 
--todas as suas Visitas. Esse Exame pode ser na Criança ou na Mãe.

--Cálculo de tuplas
--{e.PNOME, e.SNOME | Enfermeira(e) and Mae(m) and Crianca(c) and 
--(∀v) ( (Visita(v) and v.CPF_mae = m.CPF and v.CPF_enfermeira = e.CPF) =>
--((∃ em) (Examina_mae(em) and v.Data = em.Data and em.CPF_enfermeira = e.CPF AND em.CPF_mae = m.CPF) 
--union 
-- (∃ ec) (Examina_crianca(ec) and v.Data = ec.Data and ec.CPF_enfermeira = e.CPF and
--  ec.idCertidaoNascimento = c.idCertidaoNascimento and c.CPF_mae = v.CPF_mae)))}

--Cálculo de tuplas transformado
--{e.PNOME, e.SNOME | Enfermeira(e) and Mae(m) and Crianca(c) and 
--not (∃v) ((Visita(v) and v.CPF_mae = m.CPF and v.CPF_enfermeira = e.CPF) and
--not((∃ em) (Examina_mae(em) and v.Data = em.Data and em.CPF_enfermeira = e.CPF and em.CPF_mae = m.CPF) 
--union 
-- (∃ ec) (Examina_crianca(ec) and v.Data = ec.Data and ec.CPF_enfermeira = e.CPF and
--  ec.idCertidaoNascimento = c.idCertidaoNascimento and c.CPF_mae = v.CPF_mae)))}


--SQL

(SELECT e.RG, e.pnome, e.snome 
 FROM Enfermeira NATURAL JOIN Pessoa as e
 WHERE EXISTS (SELECT count(Num_visita) >= 1 
               FROM Visita_e_realizada as v 
               WHERE v.RG_enfermeira=e.RG) AND 
       NOT EXISTS (SELECT * 
                   FROM Visita_e_realizada as v, Mae as m
                   WHERE v.RG_enfermeira=e.RG AND v.RG_mae = m.RG AND 
                   NOT EXISTS (SELECT *
                               FROM Examina_mae as ex 
                               WHERE ex.RG_enfermeira=e.RG AND 
                                     ex.RG_mae = m.RG AND ex.Data=v.Data)))
UNION
(SELECT e.RG, e.pnome, e.snome 
    FROM Enfermeira NATURAL JOIN Pessoa as e, Crianca as c
    WHERE EXISTS (SELECT count(Num_visita) >= 1 
                  FROM Visita_e_realizada as v 
                  WHERE v.RG_enfermeira=e.RG) AND 
          NOT EXISTS (SELECT * 
                    FROM Visita_e_realizada as v, Crianca as c
                    WHERE v.RG_enfermeira=e.RG AND 
                    NOT EXISTS (SELECT * 
                                FROM Examina_crianca as ex 
                                WHERE ex.RG_enfermeira=e.RG AND 
                                      ex.idCertidaoNascimento = ex.idCertidaoNascimento AND
                                      ex.Data=v.Data)));

-------------------------------------
--Outras consultas
-------------------------------------

--Listar quantas mães estão no programa recebendo visitas e 
--agrupá-las por enfermeiras.
SELECT DISTINCT e.PNOME, e.SNOME, COUNT(m.CPF) as Qtde_maes
FROM Visita as v, 
     (SELECT * FROM Mae NATURAL JOIN Pessoa) as m, 
     (SELECT * FROM Enfermeira NATURAL JOIN Pessoa) as e
WHERE m.Ativa = true and v.CPF_mae = m.CPF and e.CPF = v.CPF_enfermeira
GROUP BY e.PNOME, e.SNOME;


--Contar quantos equipamentos (tablets e aparelhos médicos) no total estão em estado 'conservado'

SELECT count(equipamento.numero_serie) as Quantidade_total
FROM ((SELECT numero_serie FROM Tablet WHERE estado_conservacao = 'conservado') 
        union
     (SELECT numero_serie FROM Aparelho_medico WHERE estado_conservacao = 'conservado')) as equipamento;