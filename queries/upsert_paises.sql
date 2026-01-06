/* Borramos la tabla y la cargamos con dim_titulos. En cierto modo, esto es un desglose.
De este modo, tambien nos asegurarnos la integridad referencial */

DELETE FROM cur.dbo.rel_titulos_paises
WHERE plataforma = '$CANAL';

INSERT INTO cur.dbo.rel_titulos_paises (
        plataforma,
        show_id,
        tipo,
        pais
    )
SELECT 
    plataforma, 
    show_id, 
    tipo, 
    LTRIM(RTRIM(value)) AS pais
FROM cur.dbo.dim_titulos 
CROSS APPLY STRING_SPLIT(pais,',')
WHERE plataforma = '$CANAL';