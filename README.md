# 🛒 Análisis de ventas Superstore con SQL Server
Proyecto para el curso **SQL for Data Analyst **

---

## 📌 Resumen

Global Superstore es una tienda minorista con operación internacional que comercializa productos de oficina, mobiliario y tecnología en 147 países. El objetivo de este proyecto es construir un análisis de las ventas de esta tienda transformando un histórico de más de 51 mil órdenes en información accionable

---

## 🛠️ Herramientas

- **SQL Server 2019** — carga, transformación y análisis
- **SSMS** — ejecución de consultas
- **GitHub** — documentación

---

### 🔍 Pregunta 1: ¿Cuántos registros hay y qué periodo cubren?

```sql
SELECT
    COUNT(*)                                            AS lineas_de_venta,
    MIN(fecha_pedido)                                   AS desde,
    MAX(fecha_pedido)                                   AS hasta,
    DATEDIFF(DAY, MIN(fecha_pedido), MAX(fecha_pedido)) AS dias,
    YEAR(MIN(fecha_pedido))                             AS anio_inicial,
    YEAR(MAX(fecha_pedido))                             AS anio_final
FROM ventas;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen1.png)

**Conclusión:** la base cubre 4 años completos, un periodo suficiente para analizar tendencias.

---

### 🔍 Pregunta 2: ¿Cuánto vendió y cuánto ganó la empresa?

```sql
SELECT 'Ventas totales' AS indicador, CAST(SUM(ventas)     AS DECIMAL(14,2)) AS valor FROM ventas
UNION ALL
SELECT 'Utilidad total',             CAST(SUM(utilidad)    AS DECIMAL(14,2)) FROM ventas
UNION ALL
SELECT 'Costo de envio total',       CAST(SUM(costo_envio) AS DECIMAL(14,2)) FROM ventas
UNION ALL
SELECT 'Unidades vendidas',          CAST(SUM(cantidad)    AS DECIMAL(14,2)) FROM ventas
UNION ALL
SELECT 'Margen % sobre ventas',      CAST(SUM(utilidad) * 100.0 / SUM(ventas) AS DECIMAL(14,2)) FROM ventas
UNION ALL
SELECT 'Venta promedio por linea',   CAST(AVG(CAST(ventas AS DECIMAL(12,2))) AS DECIMAL(14,2)) FROM ventas;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen2.png)

 **Conclusión:** el margen es del 11.61%. Lo llamativo es comparar las dos primeras cifras de costo: la empresa gasta $1.35 millones en envíos para ganar $1.47 millones. El envío se lleva casi toda la utilidad.

---

### 🔍 Pregunta 3: ¿Cómo evolucionaron las ventas por año?

```sql
SELECT
    YEAR(fecha_pedido)                            AS anio,
    COUNT(*)                                      AS lineas,
    SUM(ventas)                                   AS ventas,
    ROUND(SUM(utilidad), 2)                       AS utilidad,
    ROUND(SUM(utilidad) * 100.0 / SUM(ventas), 2) AS margen_pct
FROM ventas
GROUP BY YEAR(fecha_pedido)
ORDER BY anio;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen3.png)

**Conclusión:** las ventas casi se duplican en cuatro años, un crecimiento fuerte y sostenido. Pero el margen se mantiene plano alrededor del 11.5% e incluso baja en 2014: la empresa vende más, pero no gana más por cada dólar vendido.

---

### 🔍 Pregunta 4: ¿Qué categorías generan más utilidad?

```sql
SELECT
    s.categoria,
    COUNT(*)                                          AS lineas,
    SUM(v.ventas)                                     AS ventas,
    ROUND(SUM(v.utilidad), 2)                         AS utilidad,
    ROUND(SUM(v.utilidad) * 100.0 / SUM(v.ventas), 2) AS margen_pct
FROM ventas AS v
INNER JOIN tb_subcategoria AS s
        ON s.subcategoria = v.subcategoria
GROUP BY s.categoria
ORDER BY utilidad DESC;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen4.png)

**Conclusión:** Furniture es la categoría problemática. Vende casi lo mismo que Technology ($4.11 M vs $4.74 M) pero genera menos de la mitad de utilidad. Su margen (6.94%) es la mitad del de las otras dos categorías.

---

### 🔍 Pregunta 5: ¿Qué subcategorías pierden dinero?

```sql
-- HAVING filtra los grupos ya sumados, a diferencia de WHERE
-- que filtra las filas antes de agrupar
SELECT
    s.categoria,
    v.subcategoria,
    COUNT(*)                  AS lineas,
    SUM(v.ventas)             AS ventas,
    ROUND(SUM(v.utilidad), 2) AS utilidad
FROM ventas AS v
INNER JOIN tb_subcategoria AS s
        ON s.subcategoria = v.subcategoria
GROUP BY s.categoria, v.subcategoria
HAVING SUM(v.utilidad) < 0;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen5.png)

**Conclusión:** `Tables` es la única subcategoría del catálogo que pierde dinero: vende $757 mil y pierde $64 mil. Esto explica el mal margen de Furniture visto en la pregunta anterior.

---

### 🔍 Pregunta 6: ¿Cuáles son los 10 países con más ventas?

```sql
SELECT TOP 10
    RANK() OVER (ORDER BY SUM(v.ventas) DESC)         AS puesto,
    v.pais,
    p.mercado,
    COUNT(*)                                          AS lineas,
    SUM(v.ventas)                                     AS ventas,
    ROUND(SUM(v.utilidad), 2)                         AS utilidad,
    ROUND(SUM(v.utilidad) * 100.0 / SUM(v.ventas), 2) AS margen_pct
FROM ventas AS v
INNER JOIN tb_pais AS p
        ON p.pais = v.pais
GROUP BY v.pais, p.mercado
ORDER BY ventas DESC;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen6.png)

**Conclusión:** Estados Unidos vende 2.5 veces más que el segundo país, pero vender más no significa ganar más. China e India venden menos de un tercio que EE.UU. y tienen casi el doble de margen (21.5% y 21.9% contra 12.5%). Indonesia es el caso contrario: está entre los 10 primeros en ventas pero su margen es de apenas 3.86%.

---

### 🔍 Pregunta 7: ¿Qué segmento de cliente es más rentable?

```sql
SELECT
    segmento,
    COUNT(*)                                      AS lineas,
    SUM(ventas)                                   AS ventas,
    ROUND(SUM(utilidad), 2)                       AS utilidad,
    ROUND(AVG(CAST(ventas AS DECIMAL(12,2))), 2)  AS venta_promedio,
    ROUND(SUM(utilidad) * 100.0 / SUM(ventas), 2) AS margen_pct,
    CASE
        WHEN SUM(utilidad) * 100.0 / SUM(ventas) > 11.61 THEN 'Sobre el promedio'
        ELSE 'Bajo el promedio'
    END                                           AS comparacion
FROM ventas
GROUP BY segmento
ORDER BY ventas DESC;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen7.png)

**Conclusión:** los tres segmentos se comportan casi igual: márgenes entre 11.51% y 11.99%, y ventas promedio prácticamente idénticas (~$246). Consumer aporta más de la mitad del negocio solo por volumen, no por rentabilidad. No hay un segmento que convenga priorizar sobre otro.

---

### 🔍 Pregunta 8: ¿Cuánto demora la entrega según la prioridad?

```sql
SELECT
    prioridad,
    COUNT(*)                                        AS lineas,
    ROUND(AVG(CAST(dias_envio AS DECIMAL(6,2))), 2) AS dias_promedio,
    MIN(dias_envio)                                 AS dias_minimo,
    MAX(dias_envio)                                 AS dias_maximo,
    ROUND(SUM(utilidad) * 100.0 / SUM(ventas), 2)   AS margen_pct,
    CASE
        WHEN AVG(CAST(dias_envio AS DECIMAL(6,2))) <= 2 THEN 'Entrega rapida'
        WHEN AVG(CAST(dias_envio AS DECIMAL(6,2))) <= 5 THEN 'Entrega normal'
        ELSE 'Entrega lenta'
    END                                             AS tipo_entrega
FROM ventas
GROUP BY prioridad
ORDER BY dias_promedio;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen8.png)

**Conclusión:** la logística funciona correctamente. Los tiempos siguen el orden esperado (1.81 → 3.09 → 4.52 → 6.48 días) y ningún pedido crítico demoró más de 3 días. Además, los pedidos críticos son los más rentables (12.60%), mientras que los de prioridad baja son los menos rentables (10.33%): la urgencia se cobra bien.

---

### 🔍 Pregunta 9: ¿Qué productos nunca generaron ganancia?

```sql
-- La subconsulta arma la lista de productos que SI tuvieron al menos
-- una venta con ganancia. NOT IN devuelve los que no estan en esa lista.
SELECT
    CASE
        WHEN LEN(producto) > 45 THEN LEFT(producto, 42) + '...'
        ELSE producto
    END                       AS producto,
    COUNT(*)                  AS veces_vendido,
    SUM(ventas)               AS ventas,
    ROUND(SUM(utilidad), 2)   AS utilidad
FROM ventas
WHERE producto NOT IN (
        SELECT producto
        FROM ventas
        WHERE utilidad >= 0
      )
GROUP BY producto
ORDER BY utilidad ASC;
```

**Resultado: 59 productos.** Los 8 peores:

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen9.png)
![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen10.png)



**Conclusión:** 59 productos no han generado ganancia en ninguna venta. La mayoría son mesas, lo que refuerza el hallazgo de la Pregunta 5. Destaca el caso del sistema Cisco TelePresence: se vendió una sola vez por $22,638 —la venta más grande de toda la base— y aun así dejó pérdida.

---

### 🔍 Pregunta 10: ¿Quiénes son los 10 clientes que más compran?

```sql
-- La subconsulta escalar devuelve un solo valor (el promedio de ventas
-- por cliente) y se usa directamente dentro del SELECT para comparar
SELECT TOP 10
    cliente,
    COUNT(*)                AS compras,
    SUM(ventas)             AS ventas,
    ROUND(SUM(utilidad), 2) AS utilidad,

    (SELECT ROUND(AVG(total), 2)
     FROM (SELECT SUM(ventas) AS total FROM ventas GROUP BY cliente) AS t)
                            AS promedio_por_cliente,

    CASE
        WHEN SUM(utilidad) < 0 THEN 'Cliente NO rentable'
        ELSE 'Cliente rentable'
    END                     AS situacion
FROM ventas
GROUP BY cliente
ORDER BY ventas DESC;
```

![image alt](https://github.com/obedchavezc-commits/Proyecto-de-SQL---Data-Academy/blob/e8f9196ab7d41d549876797a012e88c22a7783f6/imagenes/imagen11.png)

**Conclusión:** el mejor cliente compra $40,489, apenas 2.5 veces el promedio general ($15,903). La facturación está muy repartida, no depende de unas pocas cuentas grandes.

El caso interesante es Sean Miller**: es el quinto cliente en ventas pero deja pérdida (−$410). Compró mucho en pocas operaciones (50 compras, el número más bajo del top 10), lo que sugiere ventas grandes cerradas con precios demasiado bajos.

---

## 📈 Conclusiones generales

1. El negocio crece pero no mejora su rentabilidad. Las ventas casi se duplican entre 2011 y 2014, pero el margen se queda en ~11.5% e incluso baja el último año.

2. El problema está concentrado en Furniture. Es la categoría con peor margen (6.94%, la mitad de las otras dos) y contiene la única subcategoría que pierde dinero: `Tables`, con −$64,083.

3. El costo de envío se lleva casi toda la utilidad. $1.35 millones de envíos contra $1.47 millones de ganancia. Es el gasto más grande del negocio.

4. Vender más no significa ganar más. Estados Unidos lidera en ventas con un margen de 12.47%, mientras China e India venden mucho menos con márgenes de casi 22%.

5. Los segmentos de cliente son prácticamente iguales. Márgenes entre 11.5% y 12.0%: no hay un tipo de cliente que convenga priorizar.

6. La logística es lo que mejor funciona. Los tiempos de entrega respetan la prioridad del pedido sin excepciones, y los pedidos urgentes son además los más rentables.

---
