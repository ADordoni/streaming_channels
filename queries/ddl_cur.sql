/* Creamos un tabla dim_titulos que almacene los títulos identificados por plataforma y show_id.
Por otro lado, dado que un título puede tener muchos actores en su elenco, muchos directores, 
proceder de muchos paises o abordar muchos géneros, se crearon tablas apartes en estos casos que almacenan
las relaciones entre estas dimensiones entre estas dimensiones y la dimensión títulos; en otras palabras,
se lo aborda ante una potencial tabla dim_actores, dim_directores, dim_paises y dim_generos */

CREATE TABLE cur.dbo.dim_titulos(
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NOT NULL,
  tipo VARCHAR(30) NULL,
  director NVARCHAR(500) NULL,
  elenco NVARCHAR(MAX) NULL,
  pais VARCHAR(200) NULL,
  titulo NVARCHAR(250) NULL,
  fecha_incorporacion DATE NULL,
  anio_estreno INT NULL,
  rating VARCHAR(40) NULL,
  duracion INT NULL,
  tipo_duracion VARCHAR(20) NULL,
  genero VARCHAR(150) NULL,
  descripcion NVARCHAR(MAX) NULL,
  fecha_carga VARCHAR(30) NULL,
  PRIMARY KEY(plataforma,show_id)
);

CREATE TABLE cur.dbo.rel_titulos_actores(
  id BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NOT NULL,
  tipo VARCHAR(30) NULL,
  actor VARCHAR(200) NULL,
  CONSTRAINT fk_rel_titulos_actores FOREIGN KEY (plataforma,show_id)
  REFERENCES cur.dbo.dim_titulos(plataforma,show_id)
);

CREATE TABLE cur.dbo.rel_titulos_directores(
  id BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NOT NULL,
  tipo VARCHAR(30) NULL,
  director VARCHAR(200) NULL,
  CONSTRAINT fk_rel_titulos_directores FOREIGN KEY (plataforma,show_id)
  REFERENCES cur.dbo.dim_titulos(plataforma,show_id)
);

CREATE TABLE cur.dbo.rel_titulos_generos(
  id BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NOT NULL,
  tipo VARCHAR(30) NULL,
  genero VARCHAR(200) NULL,
  CONSTRAINT fk_rel_titulos_generos FOREIGN KEY (plataforma,show_id)
  REFERENCES cur.dbo.dim_titulos(plataforma,show_id)
);

CREATE TABLE cur.dbo.rel_titulos_paises(
  id BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NOT NULL,
  tipo VARCHAR(30) NULL,
  pais VARCHAR(200) NULL,
  CONSTRAINT fk_rel_titulos_paises FOREIGN KEY (plataforma,show_id)
  REFERENCES cur.dbo.dim_titulos(plataforma,show_id)
);