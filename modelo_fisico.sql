CREATE DATABASE modelagem OWNER nanda;
DROP SCHEMA jovens_maes CASCADE;
CREATE SCHEMA IF NOT EXISTS jovens_maes;
SET SCHEMA 'jovens_maes';

-- -----------------------------------------------------
-- Table Pessoa
-- -----------------------------------------------------
CREATE TABLE Pessoa (
  RG NUMERIC(9) NOT NULL,
  PNOME VARCHAR(20),
  MNOME VARCHAR(30),
  SNOME VARCHAR(20),
  Data_nascimento DATE,
  Ativa BOOLEAN,
  PRIMARY KEY (RG));



-- -----------------------------------------------------
-- Table Adulta
-- -----------------------------------------------------
CREATE TABLE Adulta (
  CPF NUMERIC(11) NOT NULL,
  RG NUMERIC(9) NOT NULL,
  Endereco VARCHAR(45),
  PRIMARY KEY (CPF, RG),
  CONSTRAINT fk_Adulta_Pessoa
    FOREIGN KEY (RG) REFERENCES Pessoa (RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Enfermeira
-- -----------------------------------------------------
CREATE TABLE Enfermeira (
  CPF NUMERIC(11) NOT NULL,
  RG NUMERIC(9) NOT NULL,
  Email VARCHAR(30),
  NomeHospital VARCHAR(45),
  PRIMARY KEY (CPF, RG),
  CONSTRAINT fk_Enfermeira_Adulta
    FOREIGN KEY (CPF , RG) REFERENCES Adulta (CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Mae
-- -----------------------------------------------------
CREATE TABLE  Mae (
  CPF NUMERIC(11) NOT NULL,
  RG NUMERIC(9) NOT NULL,
  Data_inicio DATE,
  Historico_familiar VARCHAR(256),
  Condicao_emocional VARCHAR(256),
  Condicao_economica VARCHAR(256),
  Antecedente_obstetrico VARCHAR(256),
  PRIMARY KEY (CPF, RG),
  CONSTRAINT fk_Mae_Adulta
    FOREIGN KEY (CPF, RG) REFERENCES Adulta (CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Vacina
-- -----------------------------------------------------
CREATE TABLE  Vacina (
  Cod_vacina VARCHAR(20) NOT NULL,
  Nome VARCHAR(45),
  Idade_recomendada INT,
  Numero_doses INT,
  Tipo_aplicacao VARCHAR(20) check (Tipo_aplicacao = 'oral' or Tipo_aplicacao = 'intravenosa'),
  Validade DATE,
  PRIMARY KEY (Cod_vacina));



-- -----------------------------------------------------
-- Table Crianca
-- -----------------------------------------------------
CREATE TABLE  Crianca (
  idCertidaoNascimento INT NOT NULL,
  RG NUMERIC(9) NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  Doenca_congenita VARCHAR(45),
  Peso VARCHAR(5),
  Tipo_parto VARCHAR(10) check (Tipo_parto = 'normal' or Tipo_parto = 'cesária'),
  Nasceu_prematuro BOOLEAN,
  Sexo VARCHAR(1) check (Sexo = 'F' or Sexo = 'M'),
  Cor VARCHAR(11) check (Cor = 'Branco' or Cor = 'Pardo' or Cor = 'Negro'),
  Presenca_do_pai BOOLEAN,
  PRIMARY KEY (idCertidaoNascimento, RG),
  CONSTRAINT fk_Crianca_Mae 
    FOREIGN KEY (CPF_mae , RG_mae) REFERENCES Mae (CPF , RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_Crianca_Pessoa
    FOREIGN KEY (RG) REFERENCES Pessoa (RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Toma
-- -----------------------------------------------------
CREATE TABLE  Toma (
  Cod_vacina VARCHAR(20) NOT NULL,
  idCertidaoNascimento INT NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_crianca NUMERIC(9) NOT NULL,
  Data DATE NOT NULL,
  PRIMARY KEY (Cod_vacina, idCertidaoNascimento, RG_mae, CPF_mae, RG_crianca),
  CONSTRAINT fk_Toma_Vacina
    FOREIGN KEY (Cod_vacina) REFERENCES Vacina (Cod_vacina)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_Crianca_Toma
    FOREIGN KEY (idCertidaoNascimento, RG_crianca) REFERENCES Crianca (idCertidaoNascimento, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Tablet
-- -----------------------------------------------------
CREATE TABLE  Tablet (
  Numero_serie INT NOT NULL,
  Modelo VARCHAR(45),
  Marca VARCHAR(45),
  Data_aquisicao DATE,
  Estado_conservacao VARCHAR(45) check (Estado_conservacao = 'muito bom' or 
                                       Estado_conservacao = 'conservado' or
                                       Estado_conservacao = 'regular' or
                                       Estado_conservacao = 'parcialmente quebrado'),
  PRIMARY KEY (Numero_serie));



-- -----------------------------------------------------
-- Table Visita
-- -----------------------------------------------------
CREATE TABLE  Visita (
  Num_visita INT NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  idCertidaoNascimento INT NOT NULL,
  RG_crianca NUMERIC(9) NOT NULL,
  Numero_serie_tablet INT,
  Duracao TIME,
  Nota INT check (Nota >= 0 and Nota <= 10),
  Descricao VARCHAR(256),
  PRIMARY KEY (Num_visita, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira, idCertidaoNascimento, RG_crianca),
  CONSTRAINT fk_Visita_mae
    FOREIGN KEY (CPF_mae , RG_mae) REFERENCES Mae (CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_Visita_tablet
    FOREIGN KEY (Numero_serie_tablet) REFERENCES Tablet (Numero_serie) 
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_Visita_enfermeira
    FOREIGN KEY (CPF_enfermeira , RG_enfermeira) REFERENCES Enfermeira (CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_Visita_crianca
    FOREIGN KEY (RG_crianca , idCertidaoNascimento) REFERENCES Crianca (RG, idCertidaoNascimento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Relato
-- -----------------------------------------------------
CREATE TABLE  Relato (
  idRelato INT NOT NULL,
  Data_visita DATE,
  Queixa VARCHAR(256),
  Medicamentos_em_uso VARCHAR(256),
  Consome_drogas BOOLEAN,
  Consumo_cigarros INT,
  Consumo_alcool REAL,
  Habitos_alimentares VARCHAR(256),
  Exposicao_a_agentes_quimicos VARCHAR(256),
  Nota_disposicao INT check (Nota_disposicao >= 0 and Nota_disposicao <= 10),
  Nota_evolucao INT check (Nota_evolucao >= 0 and Nota_evolucao <= 10),
  Nota_cuidado_com_crianca INT check (Nota_cuidado_com_crianca >= 0 and Nota_cuidado_com_crianca <= 10),
  Num_visita INT NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  idCertidaoNascimento INT NOT NULL,
  RG_crianca NUMERIC(9) NOT NULL,
  Fatores_estressantes VARCHAR(256),
  PRIMARY KEY (idRelato),  
  CONSTRAINT fk_Relato_Visita
    FOREIGN KEY (Num_visita, RG_crianca, idCertidaoNascimento, RG_enfermeira , CPF_enfermeira , RG_mae , CPF_mae)
    REFERENCES Visita (Num_visita, RG_crianca, idCertidaoNascimento, RG_enfermeira , CPF_enfermeira , RG_mae , CPF_mae)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Examina_crianca
-- -----------------------------------------------------
CREATE TABLE  Examina_crianca (
  Numero_exame INT NOT NULL,
  idCertidaoNascimento INT NOT NULL,
  RG_crianca NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  Temperatura REAL check (Temperatura > 30 and Temperatura < 45),
  Peso REAL,
  Comprimento REAL,
  Idade INT check (Idade >= 0 and Idade <= 6),
  Presenca_cabelo BOOLEAN,
  Presenca_lesoes BOOLEAN,
  Lesao_pele VARCHAR(256),
  Descamacao_pele BOOLEAN,
  Lesao_boca VARCHAR(45),
  Mucosa_corada BOOLEAN,
  Reflexo_olhos VARCHAR(45),
  Reflexo_audicao VARCHAR(45),
  Coto_umbilical VARCHAR(45) check (Coto_umbilical = 'limpo' or 
                                   Coto_umbilical = 'secretivo' or  Coto_umbilical = 'inflamado'),
  Tipo_respiracao VARCHAR(45) check (Tipo_respiracao = 'abdominal' or Tipo_respiracao = 'torácica'),
  Data DATE,
  PRIMARY KEY (Numero_exame, idCertidaoNascimento, RG_crianca, CPF_enfermeira, RG_enfermeira),
  CONSTRAINT fk_Examina_crianca
    FOREIGN KEY (RG_crianca, idCertidaoNascimento)
    REFERENCES Crianca (RG, idCertidaoNascimento)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_enfermeira_Examina_crianca
    FOREIGN KEY (RG_enfermeira, CPF_enfermeira)
    REFERENCES Enfermeira (RG, CPF)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Examina_mae
-- -----------------------------------------------------
-- 'Altura em metros, peso em Kg e temperatura em Celsius'
CREATE TABLE  Examina_mae (
  Numero_exame INT NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  Data DATE,
  Temperatura REAL check (Temperatura > 30 and Temperatura < 45),
  Peso REAL check (Peso > 0),
  Altura REAL NULL check (Altura > 0),
  Pressao_arterial REAL,
  IMC VARCHAR(45),
  Mama_esq_inflamada BOOLEAN,
  Mama_dir_inflamada BOOLEAN,
  Mama_simetrica BOOLEAN,
  Presenca_colostro BOOLEAN,
  Alteracao_urinaria VARCHAR(256),
  Presenca_sangramento VARCHAR(256),
  Resultado VARCHAR(256),
  PRIMARY KEY (Numero_exame, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira),
  CONSTRAINT fk_Examina_ch_mae
    FOREIGN KEY (CPF_mae , RG_mae)
    REFERENCES Mae (CPF , RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_Examina_ch_enfermeira
    FOREIGN KEY (CPF_enfermeira , RG_enfermeira)
    REFERENCES Enfermeira (CPF , RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Aparelho_medico
-- -----------------------------------------------------
CREATE TABLE  Aparelho_medico (
  Numero_serie INT NOT NULL,
  Livre BOOLEAN,
  Tipo VARCHAR(45),
  Fabricante VARCHAR(45),
  Estado_conservacao VARCHAR(45) check (Estado_conservacao = 'muito bom' or 
                                       Estado_conservacao = 'conservado' or
                                       Estado_conservacao = 'regular' or
                                       Estado_conservacao = 'parcialmente quebrado'),
  PRIMARY KEY (Numero_serie));



-- -----------------------------------------------------
-- Table Telefone
-- -----------------------------------------------------
CREATE TABLE  Telefone (
  DDD INT NOT NULL DEFAULT 11,
  Numero VARCHAR(15) NOT NULL,
  CPF_adulta NUMERIC(11) NOT NULL,
  RG_adulta NUMERIC(9) NOT NULL,
  PRIMARY KEY (DDD, Numero, CPF_adulta, RG_adulta),
  CONSTRAINT fk_Telefone_Adulta
    FOREIGN KEY (CPF_adulta , RG_adulta)
    REFERENCES Adulta (CPF , RG)
    ON DELETE CASCADE
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Visita_e_realizada
-- -----------------------------------------------------
CREATE TABLE  Visita_e_realizada (
  Num_visita INT NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  idCertidaoNascimento INT NOT NULL,
  RG_crianca NUMERIC(9) NOT NULL,
  Data DATE NOT NULL,
  Horario TIME,
  PRIMARY KEY (Num_visita, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira, idCertidaoNascimento, RG_crianca),
  --CONSTRAINT fk_Visita_e_realizada_visita
    FOREIGN KEY (Num_visita, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira, idCertidaoNascimento, RG_crianca) 
    REFERENCES Visita(Num_visita, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira, idCertidaoNascimento, RG_crianca)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  --CONSTRAINT fk_Visita_e_realizada_mae 
    FOREIGN KEY (CPF_mae, RG_mae) REFERENCES Mae(CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  --CONSTRAINT fk_Visita_e_realizada_enfermeira
    FOREIGN KEY (CPF_enfermeira, RG_enfermeira) REFERENCES Enfermeira(CPF, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  --CONSTRAINT fk_Visita_e_realizada_crianca
    FOREIGN KEY (idCertidaoNascimento, RG_crianca) REFERENCES Crianca(idCertidaoNascimento, RG)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Examina_crianca_pode_usar
-- -----------------------------------------------------
  CREATE TABLE  Examina_crianca_pode_usar (
    Numero_exame INT NOT NULL,
    idCertidaoNascimento INT NOT NULL,
    RG_crianca NUMERIC(9) NOT NULL,
    CPF_enfermeira NUMERIC(11) NOT NULL,
    RG_enfermeira NUMERIC(9) NOT NULL,
    Numero_serie INT NOT NULL,
    PRIMARY KEY (RG_crianca, Numero_exame, idCertidaoNascimento, CPF_enfermeira, RG_enfermeira, Numero_serie),
    CONSTRAINT fk_Examina
      FOREIGN KEY (RG_crianca, Numero_exame , idCertidaoNascimento , CPF_enfermeira , RG_enfermeira)
      REFERENCES Examina_crianca (RG_crianca , Numero_exame , idCertidaoNascimento , CPF_enfermeira , RG_enfermeira)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    CONSTRAINT fk_Aparelho_examina
      FOREIGN KEY (Numero_serie) REFERENCES Aparelho_medico (Numero_serie)
      ON DELETE SET NULL
      ON UPDATE CASCADE);



-- -----------------------------------------------------
-- Table Examina_mae_pode_usar
-- -----------------------------------------------------
CREATE TABLE  Examina_mae_pode_usar (
  Numero_exame INT NOT NULL,
  CPF_mae NUMERIC(11) NOT NULL,
  RG_mae NUMERIC(9) NOT NULL,
  CPF_enfermeira NUMERIC(11) NOT NULL,
  RG_enfermeira NUMERIC(9) NOT NULL,
  Numero_serie INT NOT NULL,
  PRIMARY KEY (Numero_exame, CPF_mae, RG_mae, CPF_enfermeira, RG_enfermeira, Numero_serie),
  CONSTRAINT fk_Examina_mae
    FOREIGN KEY (Numero_exame , CPF_mae , RG_mae , CPF_enfermeira , RG_enfermeira)
    REFERENCES Examina_mae (Numero_exame , CPF_mae , RG_mae , CPF_enfermeira , RG_enfermeira)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_Aparelho_Examina_mae
    FOREIGN KEY (Numero_serie)
    REFERENCES Aparelho_medico (Numero_serie)
    ON DELETE SET NULL
    ON UPDATE CASCADE);
