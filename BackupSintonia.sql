create schema sintonia_db;


CREATE TYPE nome_priorita AS ENUM ('Urgente', 'Breve', 'Differibile', 'Programmabile');
CREATE TABLE priorita(
nome nome_priorita primary key,
punteggio_inizio double precision not null,
punteggio_fine double precision not null,
finestra_temporale int not null 
);

CREATE TABLE psicologo(
cod_fiscale char(16) primary key,
nome varchar(64) not null,
cognome varchar(64) not null,
asl_appartenenza char(6) not null, 
stato boolean default true not null,
immagine_profilo varchar(256) not null
);


CREATE TABLE amministratore (
email varchar(64) primary key,
nome varchar(64) not null, 
cognome varchar(64) not null,
pw varchar(255) not null
);

CREATE TABLE tipologia_questionario(
nome varchar(32) primary key,
domande JSONB NOT NULL,
punteggio JSONB NOT NULL,
campi JSONB NOT NULL,
tempo_somministrazione INT NOT NULL
);

CREATE TABLE notifica(
id_notifica int generated always as identity primary key,
titolo varchar(128) not null,
tipologia varchar(32),
descrizione text not null
);

CREATE TABLE badge(
nome varchar(64) primary key,
descrizione text not null,
immagine_badge varchar(256)
);
-------------------------------------------

CREATE TYPE tipo_sesso AS ENUM ('M', 'F', 'Altro');
CREATE TABLE paziente (
    id_paziente INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(64) NOT NULL,
    cognome VARCHAR(64) NOT NULL,
    data_nascita DATE NOT NULL, 
    terms BOOLEAN NOT NULL DEFAULT FALSE, 
    email VARCHAR(64) NOT NULL, 
    cod_fiscale CHAR(16) NOT NULL UNIQUE,
    residenza VARCHAR(64) NOT NULL,
    sesso tipo_sesso NOT NULL,
    data_ingresso DATE NOT NULL,
    score DOUBLE PRECISION,

    id_priorita nome_priorita NOT NULL,  
    id_psicologo CHAR(16) NOT NULL, 
    
    CONSTRAINT fk_paziente_priorita 
        FOREIGN KEY (id_priorita) 
        REFERENCES priorita (nome),

    CONSTRAINT fk_paziente_psicologo 
        FOREIGN KEY (id_psicologo) 
        REFERENCES psicologo (cod_fiscale)
);

CREATE TABLE domanda_forum (
    id_domanda INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titolo VARCHAR(64) NOT NULL,
    testo TEXT NOT NULL,
    categoria VARCHAR(128) NOT NULL,
    data_inserimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

    id_paziente INT NOT NULL, 

    CONSTRAINT fk_paziente_domanda
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente)
);

CREATE TABLE stato_animo (
    id_stato_animo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    umore VARCHAR(16) NOT NULL,
    intensita INT, 
    note TEXT,
    data_inserimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    id_paziente INT NOT NULL, 

    CONSTRAINT fk_paziente_sa
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente)
);

CREATE TABLE pagina_diario (
    id_pagina_diario INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titolo VARCHAR(64) NOT NULL,
    testo TEXT NOT NULL,
    data_inserimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 

    id_paziente INT NOT NULL,

    CONSTRAINT fk_diario_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente)
);

CREATE TABLE acquisizione_badge (
    data_acquisizione TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    id_paziente INT NOT NULL,
    nome_badge VARCHAR(64) NOT NULL,

       CONSTRAINT fk_acquisizione_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente),

    CONSTRAINT fk_acquisizione_badge
        FOREIGN KEY (nome_badge)
        REFERENCES badge (nome), 

    CONSTRAINT pk_acquisizione_badge
        PRIMARY KEY (id_paziente, nome_badge, data_acquisizione)
);

CREATE TABLE ricezione_notifica_paziente (
    data_ricezione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_paziente INT NOT NULL,
    id_notifica INT NOT NULL,

    CONSTRAINT fk_ricezione_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente),

    CONSTRAINT fk_ricezione_notifica
        FOREIGN KEY (id_notifica)
        REFERENCES notifica (id_notifica), 
		
    CONSTRAINT pk_ricezione_notifica_paziente
        PRIMARY KEY (id_paziente, id_notifica, data_ricezione)
);

CREATE TABLE ricezione_notifica_psicologo (
    data_ricezione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_notifica INT NOT NULL,
    id_psicologo CHAR(16) NOT NULL, 
    
    CONSTRAINT fk_ricezione_notifica_psi
        FOREIGN KEY (id_notifica)
        REFERENCES notifica (id_notifica),

    CONSTRAINT fk_ricezione_psicologo
        FOREIGN KEY (id_psicologo)
        REFERENCES psicologo (cod_fiscale), 
		
    CONSTRAINT pk_ricezione_notifica_psicologo
        PRIMARY KEY (id_psicologo, id_notifica, data_ricezione)
);


CREATE TYPE stato_ticket AS ENUM ('Aperto', 'Chiuso', 'In elaborazione');

CREATE TABLE ticket (
    id_ticket INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    risolto stato_ticket DEFAULT 'Aperto',
    oggetto VARCHAR(64) NOT NULL,
    descrizione TEXT NOT NULL,
    data_invio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    
    id_amministratore VARCHAR(64), 
    id_paziente INT,               
    id_psicologo CHAR(16),         

    
    CONSTRAINT fk_ticket_admin 
        FOREIGN KEY (id_amministratore) REFERENCES amministratore(email),
    
    CONSTRAINT fk_ticket_paziente 
        FOREIGN KEY (id_paziente) REFERENCES paziente(id_paziente),
        
    CONSTRAINT fk_ticket_psicologo 
        FOREIGN KEY (id_psicologo) REFERENCES psicologo(cod_fiscale),

    CONSTRAINT chk_solo_un_utente 
        CHECK (num_nonnulls(id_paziente, id_psicologo) = 1)
);

create table alert_clinico(
id_alert INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
data_alert TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
accettato boolean default false not null,

	id_paziente INT NOT NULL,
    id_psicologo CHAR(16) NOT NULL,

	CONSTRAINT fk_alert_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente),

    CONSTRAINT fk_alert_psicologo
        FOREIGN KEY (id_psicologo)
        REFERENCES psicologo (cod_fiscale)
);

create table report(
id_report INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
data_report TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
contenuto text not null,

	id_paziente INT NOT NULL,
    id_psicologo CHAR(16) NOT NULL,

	CONSTRAINT fk_report_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente),

    CONSTRAINT fk_report_psicologo
        FOREIGN KEY (id_psicologo)
        REFERENCES psicologo (cod_fiscale)
);

create table risposta_forum(
id_risposta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
data_risposta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
testo text NOT NULL,

    id_psicologo CHAR(16) NOT NULL,
	id_domanda int NOT NULL,

	CONSTRAINT fk_risposta_psicologo
    FOREIGN KEY (id_psicologo)
    REFERENCES psicologo (cod_fiscale),

    CONSTRAINT fk_risposta_domanda
	FOREIGN KEY (id_domanda)
    REFERENCES domanda_forum (id_domanda)
	
);

CREATE TABLE questionario (
    id_questionario INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    score DOUBLE PRECISION,
    risposte JSONB,
    cambiamento BOOLEAN DEFAULT FALSE,
    data_compilazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revisionato BOOLEAN DEFAULT FALSE,
    
    invalidato BOOLEAN DEFAULT FALSE,
    note_invalidazione TEXT,
    data_invalidazione TIMESTAMP,
    
    id_paziente INT NOT NULL,
    nome_tipologia VARCHAR(32) NOT NULL,
    id_psicologo_revisione CHAR(16),
    
    id_psicologo_richiedente CHAR(16),       
    id_amministratore_conferma VARCHAR(64),  

	CONSTRAINT fk_questionario_paziente
        FOREIGN KEY (id_paziente)
        REFERENCES paziente (id_paziente),

    CONSTRAINT fk_questionario_tipologia
        FOREIGN KEY (nome_tipologia)
        REFERENCES tipologia_questionario (nome),

    CONSTRAINT fk_questionario_revisione
        FOREIGN KEY (id_psicologo_revisione)
        REFERENCES psicologo (cod_fiscale),

    CONSTRAINT fk_questionario_richiesta_psi
        FOREIGN KEY (id_psicologo_richiedente)
        REFERENCES psicologo (cod_fiscale),

    CONSTRAINT fk_questionario_conferma_admin
        FOREIGN KEY (id_amministratore_conferma)
        REFERENCES amministratore (email)
);
