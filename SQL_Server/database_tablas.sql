-- CREACION DE BASE DE DATOS
CREATE DATABASE SuperstoreDB;
GO

USE SuperstoreDB;
GO
-- CREACION DE TABLA
CREATE TABLE ventas (
    ciudad          VARCHAR(100),
    estado          VARCHAR(100),
    pais            VARCHAR(100),
    region          VARCHAR(50),
    mercado         VARCHAR(50),
    mercado2        VARCHAR(50),
    producto        VARCHAR(200),
    subcategoria    VARCHAR(50),
    categoria       VARCHAR(50),
    cliente         VARCHAR(100),
    segmento        VARCHAR(50),
    fecha_pedido_tx VARCHAR(20),
    fecha_envio_tx  VARCHAR(20),
    prioridad       VARCHAR(20),
    modo_envio      VARCHAR(50),
    ventas          INT,
    utilidad        DECIMAL(12,4),
    costo_envio     DECIMAL(12,4),
    cantidad        INT,
    descuento       VARCHAR(10),
    id              INT
);
GO
-- CARGADO DE LOS DATOS
BULK INSERT ventas
FROM 'C:\SQL\base_datos_superstore.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIELDTERMINATOR = ';',
    ROWTERMINATOR   = '0x0d0a',
    FIRSTROW        = 2,
    CODEPAGE        = '65001'
);
GO

SELECT COUNT(*) AS filas_cargadas FROM ventas;
GO


/* ---------------------------------------------------------------------------
   Se agregan columnas nuevas con ALTER TABLE, se llenan con UPDATE y luego
   se eliminan las columnas de texto que ya no sirven.

   El estilo 103 de CONVERT corresponde al formato dd/mm/yyyy.
--------------------------------------------------------------------------- */
ALTER TABLE ventas ADD fecha_pedido DATE;
ALTER TABLE ventas ADD fecha_envio  DATE;
ALTER TABLE ventas ADD dias_envio   INT;
GO

UPDATE ventas
SET fecha_pedido = CONVERT(DATE, fecha_pedido_tx, 103),
    fecha_envio  = CONVERT(DATE, fecha_envio_tx,  103);
GO

UPDATE ventas
SET dias_envio = DATEDIFF(DAY, fecha_pedido, fecha_envio);
GO

-- Ya no necesitamos las fechas en texto
ALTER TABLE ventas DROP COLUMN fecha_pedido_tx;
ALTER TABLE ventas DROP COLUMN fecha_envio_tx;
GO

-- Tabla de subcategorias (17 filas)
SELECT DISTINCT subcategoria, categoria
INTO tb_subcategoria
FROM ventas;
GO

-- Tabla de paises (147 filas).
-- Se usa MIN(mercado) porque Austria y Mongolia aparecen en dos mercados
-- distintos en el archivo original; con MIN cada pais queda con uno solo.
SELECT pais, MIN(mercado) AS mercado
INTO tb_pais
FROM ventas
GROUP BY pais;
GO

-- Se agregan las llaves primarias
ALTER TABLE tb_subcategoria ALTER COLUMN subcategoria VARCHAR(50) NOT NULL;
ALTER TABLE tb_pais         ALTER COLUMN pais         VARCHAR(100) NOT NULL;
GO

ALTER TABLE tb_subcategoria ADD PRIMARY KEY (subcategoria);
ALTER TABLE tb_pais         ADD PRIMARY KEY (pais);
GO

ALTER TABLE ventas DROP COLUMN categoria;
ALTER TABLE ventas DROP COLUMN mercado;
ALTER TABLE ventas DROP COLUMN mercado2;
GO

--VERIFICACION FINAL
SELECT 'ventas'          AS tabla, COUNT(*) AS filas FROM ventas          -- 51290
UNION ALL
SELECT 'tb_subcategoria', COUNT(*) FROM tb_subcategoria                   --    17
UNION ALL
SELECT 'tb_pais',         COUNT(*) FROM tb_pais;                          --   147
GO

SELECT TOP 10 * FROM ventas;
GO

