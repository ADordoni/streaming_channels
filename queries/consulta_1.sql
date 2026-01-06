/* Esta consulta responde la siguiente consigna:
- Considerando únicamente la plataforma de Netflix, ¿qué actor aparece
más veces? */

WITH apariciones_netflix AS (
  SELECT 
    actor, 
    COUNT(show_id) AS apariciones,
    RANK() OVER (ORDER BY COUNT(show_id) DESC) AS posicion
  FROM cur.dbo.rel_titulos_actores
    WHERE plataforma = 'netflix' AND actor!=''
    GROUP BY actor
)
SELECT 
  actor,
  apariciones,
  posicion
FROM apariciones_netflix
WHERE posicion = 1
;