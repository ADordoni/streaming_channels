/* Borramos la tabla y la cargamos con dim_titulos. En cierto modo, esto es un desglose.
De este modo, tambien nos asegurarnos la integridad referencial */

DELETE FROM cur.dbo.rel_titulos_directores
WHERE plataforma = '$CANAL';

INSERT INTO cur.dbo.rel_titulos_directores (
        plataforma,
        show_id,
        tipo,
        director
    )
SELECT 
    plataforma, 
    show_id, 
    tipo, 
    LTRIM(RTRIM(value)) AS director 
FROM cur.dbo.dim_titulos 
CROSS APPLY STRING_SPLIT(director,',')
WHERE plataforma = '$CANAL';