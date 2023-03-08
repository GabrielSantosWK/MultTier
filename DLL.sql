CREATE TABLE public.pessoa (
	idpessoa bigserial NOT NULL,
	flnatureza int2 NOT NULL,
	dsdocumento varchar(20) NOT NULL,
	nmprimeiro varchar(20) NOT NULL,
	nmsegundo varchar(100) NOT NULL,
	dtregistro date NULL,
	CONSTRAINT pessoa_pk PRIMARY KEY (idpessoa)
);

CREATE TABLE public.endereco (
	idendereco bigserial NOT NULL,
	idpessoa int8 NOT NULL,
	dscep varchar(15) NULL,
	CONSTRAINT endereco_pk PRIMARY KEY (idendereco),
	CONSTRAINT endereco_fk FOREIGN KEY (idpessoa) REFERENCES public.pessoa(idpessoa) ON DELETE CASCADE
);

CREATE TABLE public.endereco_integracao (
	idendereco int8 NOT NULL,
	dsuf varchar(50) NULL,
	nmcidade varchar(100) NULL,
	nmbairro varchar(50) NULL,
	nmlogradouro varchar(100) NULL,
	dscomplemento varchar(100) NULL,
	CONSTRAINT enderecointegracao_pk PRIMARY KEY (idendereco),
	CONSTRAINT enderecointegracao_fk_endereco FOREIGN KEY (idendereco) REFERENCES public.endereco(idendereco) ON DELETE CASCADE
);