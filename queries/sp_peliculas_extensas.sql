CREATE PROCEDURE dbo.sp_peliculas_extensas
  @anio INT
AS
  WITH orden AS (
    SELECT 
      titulo,
      duracion,
      RANK() OVER(ORDER BY duracion DESC) posicion
    FROM cur.dbo.dim_titulos
    WHERE tipo = 'Movie'
    AND tipo_duracion = 'Minutos'
    AND anio_estreno = @anio
  )
  SELECT 
    titulo,
    duracion,
    posicion
  FROM orden
  WHERE posicion <= 5;

/* Para probar el correcto funcionamiento del stored procedures, dejamos los siguientes ejemplos */
EXEC dbo.sp_peliculas_extensas 2019;
EXEC dbo.sp_peliculas_extensas 2018;