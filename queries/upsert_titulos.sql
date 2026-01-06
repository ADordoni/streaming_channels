/* Borramos la tabla y la cargamos con dim_titulos. En cierto modo, esto es un desglose.
De este modo, tambien nos asegurarnos la integridad referencial */

MERGE cur.dbo.dim_titulos AS destino
USING (
    SELECT 
        plataforma,
        show_id,
        type,
        director,
        cast_,
        country,
        title,
        FORMAT(CONVERT(date,date_added,107),'yyyy-MM-dd') AS fecha_incorporacion,
        CAST(release_year AS INT) AS anio_estreno,
        rating,
        CASE
            WHEN CHARINDEX(' ', duration) > 0 THEN CAST(LEFT(duration,CHARINDEX(' ', duration)-1) AS INT)
            ELSE 0
        END AS duracion,
        CASE
            WHEN type = 'TV SHOW' THEN 'Temporadas'
            WHEN type = 'Movie' THEN 'Minutos'
            ELSE ''
        END tipo_duracion,
        description,
        listed_in,
        fecha_carga
    FROM raw.dbo.titulos 
   WHERE plataforma = '$CANAL'
        AND fecha_carga = (SELECT MAX(fecha_carga) FROM raw.dbo.titulos WHERE plataforma='$CANAL')
        /* Preventavamente, volvemos a filtrar los show_id que no respete el forma s(NUMERO) */
        AND SUBSTRING(show_id,1,1) = 's'
        AND ISNUMERIC(SUBSTRING(show_id,2,LEN(show_id) - 1)) = 1
        AND ISDATE(date_added) = 1
) AS origen
ON destino.plataforma = origen.plataforma AND destino.show_id = origen.show_id
WHEN MATCHED THEN
    UPDATE SET 
        destino.tipo=origen.type,
        destino.director=origen.director,
        destino.elenco=origen.cast_,
        destino.pais=origen.country,
        destino.titulo=origen.title,
        destino.fecha_incorporacion=origen.fecha_incorporacion,
        destino.anio_estreno=origen.anio_estreno,
        destino.rating=origen.rating,
        destino.duracion=origen.duracion,
        destino.tipo_duracion=origen.tipo_duracion,
        destino.genero=origen.listed_in,
        destino.descripcion=origen.description,
        destino.fecha_carga=origen.fecha_carga
WHEN NOT MATCHED THEN
    INSERT (
        plataforma,
        show_id,
        tipo,
        director,
        elenco,
        pais,
        titulo,
        fecha_incorporacion,
        anio_estreno,
        rating,
        duracion,
        tipo_duracion,
        genero,
        descripcion,
        fecha_carga
    )
    VALUES( 
        origen.plataforma,
        origen.show_id,
        origen.type,
        origen.director,
        origen.cast_,
        origen.country,
        origen.title,
        origen.fecha_incorporacion,
        origen.anio_estreno,
        origen.rating,
        origen.duracion,
        origen.tipo_duracion,
        origen.listed_in,
        origen.description,
        origen.fecha_carga);