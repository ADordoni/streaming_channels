/* Esta consulta responde la siguiente consigna:
- Top 10 de actores participantes considerando ambas plataformas en el
año actual. Se aprecia flexibilidad. 
Para aportar flexibilidad, se opto por la función ventana RANK en vez de DENSE_RANK; de este modo,
si hay 5 actores que figuran 8vo, figurarán los 5 actores y no solo 3 */

WITH apariciones AS (
  SELECT 
    actor, 
    COUNT(show_id) AS apariciones,
    RANK() OVER (ORDER BY COUNT(show_id) DESC) AS posicion
  FROM cur.dbo.rel_titulos_actores
    WHERE actor!=''
    GROUP BY actor
)
SELECT 
  actor,
  apariciones,
  posicion
FROM apariciones
WHERE posicion <= 10
;