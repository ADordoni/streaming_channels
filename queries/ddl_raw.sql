/* En la capa raw solo buscamos reflejar fielmente los datos que vienien del repositorio de aws.
Solo agregamos la plataforma y el momento en el que se cargó; esto último con el fin de aportar trazabilidad al proceso */

CREATE TABLE raw.dbo.titulos(
  id BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
  plataforma VARCHAR(12) NOT NULL,
  show_id VARCHAR(30) NULL,
  type VARCHAR(20) NULL,
  title NVARCHAR(250) NULL,
  director NVARCHAR(500) NULL,
  cast_ NVARCHAR(MAX) NULL,
  country VARCHAR(200) NULL,
  date_added VARCHAR(25) NULL,
  release_year VARCHAR(8) NULL,
  rating VARCHAR(40) NULL,
  duration VARCHAR(200) NULL,
  listed_in VARCHAR(150) NULL,
  description NVARCHAR(MAX) NULL,
  fecha_carga VARCHAR(30) NULL
);