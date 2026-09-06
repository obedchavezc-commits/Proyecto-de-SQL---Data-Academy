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

| Líneas de venta | Desde | Hasta | Días |
|---:|---|---|---:|
| 51,290 | 2011-01-01 | 2014-12-31 | 1,460 |

📊 **Conclusión:** la base cubre 4 años completos, un periodo suficiente para analizar tendencias.

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

| Indicador | Valor |
|---|---:|
| Ventas totales | $12,642,905 |
| Utilidad total | $1,467,457 |
| Costo de envío total | $1,352,816 |
| Unidades vendidas | 178,312 |
| Margen % sobre ventas | 11.61% |
| Venta promedio por línea | $246.50 |

📊 **Conclusión:** el margen es del 11.61%. Lo llamativo es comparar las dos primeras cifras de costo: **la empresa gasta $1.35 millones en envíos para ganar $1.47 millones**. El envío se lleva casi toda la utilidad.

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

| Año | Líneas | Ventas | Utilidad | Margen % |
|---|---:|---:|---:|---:|
| 2011 | 8,998 | $2,259,511 | $248,941 | 11.02% |
| 2012 | 10,962 | $2,677,493 | $307,415 | 11.48% |
| 2013 | 13,799 | $3,405,860 | $406,935 | 11.95% |
| 2014 | 17,531 | $4,300,041 | $504,166 | 11.72% |

📊 **Conclusión:** las ventas casi se duplican en cuatro años, un crecimiento fuerte y sostenido. Pero el margen se mantiene plano alrededor del 11.5% e incluso baja en 2014: **la empresa vende más, pero no gana más por cada dólar vendido**.

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

| Categoría | Líneas | Ventas | Utilidad | Margen % |
|---|---:|---:|---:|---:|
| Technology | 10,141 | $4,744,691 | $663,779 | 13.99% |
| Office Supplies | 31,273 | $3,787,330 | $518,474 | 13.69% |
| Furniture | 9,876 | $4,110,884 | $285,205 | **6.94%** |

📊 **Conclusión:** **Furniture es la categoría problemática.** Vende casi lo mismo que Technology ($4.11 M vs $4.74 M) pero genera menos de la mitad de utilidad. Su margen (6.94%) es la mitad del de las otras dos categorías.

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

| Categoría | Subcategoría | Líneas | Ventas | Utilidad |
|---|---|---:|---:|---:|
| Furniture | **Tables** | 861 | $757,034 | **−$64,083** |

Y clasificando todas las subcategorías con `CASE WHEN`:

| Subcategoría | Categoría | Ventas | Margen % | Clasificación |
|---|---|---:|---:|---|
| Tables | Furniture | $757,034 | −8.47% | 🔴 Pierde dinero |
| Machines | Technology | $779,071 | 7.56% | Margen bajo |
| Supplies | Office Supplies | $243,090 | 9.29% | Margen bajo |
| Chairs | Furniture | $1,501,682 | 9.35% | Margen bajo |
| Storage | Office Supplies | $1,127,124 | 9.62% | Margen bajo |
| Bookcases | Furniture | $1,466,559 | 11.04% | Margen medio |
| Furnishings | Furniture | $385,609 | 12.18% | Margen medio |
| Phones | Technology | $1,706,874 | 12.70% | Margen medio |
| Fasteners | Office Supplies | $83,254 | 13.84% | Margen medio |
| Appliances | Office Supplies | $1,011,081 | 14.01% | Margen medio |
| Art | Office Supplies | $372,163 | 15.57% | Margen alto |
| Binders | Office Supplies | $461,952 | 15.68% | Margen alto |
| Copiers | Technology | $1,509,439 | 17.13% | Margen alto |
| Accessories | Technology | $749,307 | 17.30% | Margen alto |
| Envelopes | Office Supplies | $170,926 | 17.32% | Margen alto |
| Labels | Office Supplies | $73,433 | 20.44% | Margen alto |
| Paper | Office Supplies | $244,307 | **24.23%** | Margen alto |

📊 **Conclusión:** **`Tables` es la única subcategoría del catálogo que pierde dinero**: vende $757 mil y pierde $64 mil. Esto explica el mal margen de Furniture visto en la pregunta anterior, porque tres de sus cuatro subcategorías (Tables, Chairs, Bookcases) están abajo del promedio. En el otro extremo, `Paper` rinde 24.23%, más de tres veces el margen de Furniture.

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

| Puesto | País | Mercado | Ventas | Utilidad | Margen % |
|---:|---|---|---:|---:|---:|
| 1 | United States | US | $2,297,354 | $286,397 | 12.47% |
| 2 | Australia | APAC | $925,257 | $103,907 | 11.23% |
| 3 | France | EU | $858,930 | $109,029 | 12.69% |
| 4 | China | APAC | $700,591 | $150,683 | **21.51%** |
| 5 | Germany | EU | $628,857 | $107,323 | 17.07% |
| 6 | Mexico | LATAM | $622,620 | $102,818 | 16.51% |
| 7 | India | APAC | $589,664 | $129,072 | **21.89%** |
| 8 | United Kingdom | EU | $528,570 | $111,900 | 21.17% |
| 9 | Indonesia | APAC | $404,887 | $15,609 | **3.86%** |
| 10 | Brazil | LATAM | $361,098 | $30,090 | 8.33% |

📊 **Conclusión:** Estados Unidos vende 2.5 veces más que el segundo país, pero **vender más no significa ganar más**. China e India venden menos de un tercio que EE.UU. y tienen casi el doble de margen (21.5% y 21.9% contra 12.5%). Indonesia es el caso contrario: está entre los 10 primeros en ventas pero su margen es de apenas 3.86%.

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

| Segmento | Líneas | Ventas | Utilidad | Venta promedio | Margen % | Comparación |
|---|---:|---:|---:|---:|---:|---|
| Consumer | 26,518 | $6,508,141 | $749,240 | $245.42 | 11.51% | Bajo el promedio |
| Corporate | 15,429 | $3,824,808 | $441,208 | $247.90 | 11.54% | Bajo el promedio |
| Home Office | 9,343 | $2,309,956 | $277,009 | $247.24 | 11.99% | Sobre el promedio |

📊 **Conclusión:** los tres segmentos se comportan **casi igual**: márgenes entre 11.51% y 11.99%, y ventas promedio prácticamente idénticas (~$246). Consumer aporta más de la mitad del negocio solo por volumen, no por rentabilidad. No hay un segmento que convenga priorizar sobre otro.

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

| Prioridad | Líneas | Días promedio | Mín | Máx | Margen % | Tipo |
|---|---:|---:|---:|---:|---:|---|
| Critical | 3,932 | 1.81 | 0 | 3 | 12.60% | Entrega rápida |
| High | 15,501 | 3.09 | 0 | 5 | 11.04% | Entrega normal |
| Medium | 29,433 | 4.52 | 0 | 7 | 11.87% | Entrega normal |
| Low | 2,424 | 6.48 | 6 | 7 | 10.33% | Entrega lenta |

📊 **Conclusión:** **la logística funciona correctamente.** Los tiempos siguen el orden esperado (1.81 → 3.09 → 4.52 → 6.48 días) y ningún pedido crítico demoró más de 3 días. Además, los pedidos críticos son los **más rentables** (12.60%), mientras que los de prioridad baja son los menos rentables (10.33%): la urgencia se cobra bien.

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

| Producto | Veces vendido | Ventas | Utilidad |
|---|---:|---:|---:|
| Cubify CubeX 3D Printer Triple Head Print | 1 | $8,000 | −$3,840 |
| Lesro Training Table, Rectangular | 5 | $2,712 | −$2,581 |
| Lesro Round Table, Adjustable Height | 5 | $3,961 | −$2,403 |
| Barricks Round Table, Adjustable Height | 3 | $3,232 | −$1,881 |
| Barricks Conference Table, with Bottom Storage | 5 | $6,502 | −$1,838 |
| Cisco TelePresence System EX90 Videoconf... | 1 | $22,638 | −$1,811 |
| BoxOffice By Design Rectangular and Half-M... | 3 | $1,707 | −$1,148 |
| Chromcraft Training Table, Rectangular | 3 | $2,142 | −$1,108 |

📊 **Conclusión:** **59 productos no han generado ganancia en ninguna venta.** La mayoría son mesas, lo que refuerza el hallazgo de la Pregunta 5. Destaca el caso del sistema Cisco TelePresence: se vendió una sola vez por $22,638 —la venta más grande de toda la base— y aun así dejó pérdida.

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

| Cliente | Compras | Ventas | Utilidad | Promedio general | Situación |
|---|---:|---:|---:|---:|---|
| Tom Ashbrook | 80 | $40,489 | $6,312 | $15,903 | Cliente rentable |
| Tamara Chand | 88 | $37,453 | $8,673 | $15,903 | Cliente rentable |
| Greg Tran | 87 | $35,552 | $5,214 | $15,903 | Cliente rentable |
| Christopher Conant | 73 | $35,187 | $5,603 | $15,903 | Cliente rentable |
| **Sean Miller** | 50 | $35,170 | **−$410** | $15,903 | 🔴 **Cliente NO rentable** |
| Bart Watters | 96 | $32,315 | $3,596 | $15,903 | Cliente rentable |
| Natalie Fritzler | 95 | $31,778 | $1,543 | $15,903 | Cliente rentable |
| Fred Hopkins | 82 | $30,404 | $4,609 | $15,903 | Cliente rentable |
| Jane Waco | 75 | $30,288 | $6,266 | $15,903 | Cliente rentable |
| Hunter Lopez | 53 | $30,246 | $7,817 | $15,903 | Cliente rentable |

📊 **Conclusión:** el mejor cliente compra $40,489, apenas 2.5 veces el promedio general ($15,903). **La facturación está muy repartida**, no depende de unas pocas cuentas grandes.

El caso interesante es **Sean Miller**: es el quinto cliente en ventas pero **deja pérdida** (−$410). Compró mucho en pocas operaciones (50 compras, el número más bajo del top 10), lo que sugiere ventas grandes cerradas con precios demasiado bajos.

---

## 📈 Conclusiones generales

1. **El negocio crece pero no mejora su rentabilidad.** Las ventas casi se duplican entre 2011 y 2014, pero el margen se queda en ~11.5% e incluso baja el último año.

2. **El problema está concentrado en Furniture.** Es la categoría con peor margen (6.94%, la mitad de las otras dos) y contiene la única subcategoría que pierde dinero: `Tables`, con −$64,083.

3. **El costo de envío se lleva casi toda la utilidad.** $1.35 millones de envíos contra $1.47 millones de ganancia. Es el gasto más grande del negocio.

4. **Vender más no significa ganar más.** Estados Unidos lidera en ventas con un margen de 12.47%, mientras China e India venden mucho menos con márgenes de casi 22%.

5. **Los segmentos de cliente son prácticamente iguales.** Márgenes entre 11.5% y 12.0%: no hay un tipo de cliente que convenga priorizar.

6. **La logística es lo que mejor funciona.** Los tiempos de entrega respetan la prioridad del pedido sin excepciones, y los pedidos urgentes son además los más rentables.

---

## 🚀 Recomendaciones

| Prioridad | Recomendación | Basado en |
|---|---|---|
| 🔴 Alta | **Revisar los precios de `Tables`** o dejar de venderla. Es la única subcategoría con pérdida. | P5 |
| 🔴 Alta | **Retirar los 59 productos que nunca dieron ganancia.** Ninguna de sus ventas fue rentable. | P9 |
| 🟡 Media | **Negociar el costo de envío**, que hoy equivale al 92% de la utilidad. | P2 |
| 🟡 Media | **Estudiar qué se hace bien en China e India** (margen ~22%) para replicarlo en mercados de bajo margen como Indonesia (3.86%). | P6 |
| 🟢 Baja | **Impulsar `Paper`, `Labels` y `Envelopes`**, con márgenes de 17% a 24% pero poca participación en las ventas. | P5 |
| 🟢 Baja | **Revisar los precios otorgados a Sean Miller** y otros clientes de venta alta y utilidad baja. | P10 |
