#ENUNCIADO 1: 
-- Creación de la base de datos denominada 

CREATE DATABASE TF_BASES

#ENUNCIADO 2: 
-- Importación de la bases de datos https://www.datos.gob.ar/dataset/turismo-previaje denominada DATASET

#ENUNCIADO 3: 
-- Se ejecuta el script 'script_tf_bases.sql'

USE TF_BASES;

-- TABLA DATOS_PREVIAJE: CREATE, INSERT 
CREATE TABLE DATOS_PREVIAJE (
	ID INT AUTO_INCREMENT,
	PERIODO TEXT,
	ID_PROVINCIA_ORIGEN TEXT,
	ID_PROVINCIA_DESTINO TEXT,
	CANT_VIAJES INT,
	CANT_VIAJEROS INT,
	ID_EDICION TEXT,
	CONSTRAINT PK_DATOS_PREVIAJE PRIMARY KEY (ID)
);

INSERT INTO DATOS_PREVIAJE (PERIODO, ID_PROVINCIA_ORIGEN, ID_PROVINCIA_DESTINO, CANT_VIAJES, CANT_VIAJEROS, ID_EDICION)
SELECT * 
FROM DATASET;
COMMIT;

-- TABLA DATOS_PREVIAJE: UPDATE
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Ciudad Autónoma de Buenos Aires' WHERE ID_PROVINCIA_ORIGEN like 'Ciudad Aut%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Ciudad Autónoma de Buenos Aires' WHERE ID_PROVINCIA_DESTINO like 'Ciudad Aut%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Río Negro' WHERE ID_PROVINCIA_ORIGEN like '%Negro';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Río Negro' WHERE ID_PROVINCIA_DESTINO like '%Negro';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Córdoba' WHERE ID_PROVINCIA_ORIGEN like '%rdoba';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Córdoba' WHERE ID_PROVINCIA_DESTINO like '%rdoba';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Entre Ríos' WHERE ID_PROVINCIA_ORIGEN like 'Entre R%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Entre Ríos' WHERE ID_PROVINCIA_DESTINO like 'Entre R%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Neuquén' WHERE ID_PROVINCIA_ORIGEN like 'Neuqu%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Neuquén' WHERE ID_PROVINCIA_DESTINO like 'Neuqu%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Tucumán' WHERE ID_PROVINCIA_ORIGEN like 'Tucum%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Tucumán' WHERE ID_PROVINCIA_DESTINO like 'Tucum%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_ORIGEN  = 'Tierra del Fuego, Antártida e Islas del Atlántico Sur' WHERE ID_PROVINCIA_ORIGEN like 'Tierra del Fuego%';
UPDATE DATOS_PREVIAJE SET ID_PROVINCIA_DESTINO  = 'Tierra del Fuego, Antártida e Islas del Atlántico Sur' WHERE ID_PROVINCIA_DESTINO like 'Tierra del Fuego%';
COMMIT;

-- TABLA EDICION_PREVIAJE: CREATE, INSERT
CREATE TABLE EDICION_PREVIAJE (
	ID_EDICION INT AUTO_INCREMENT,
	EDICION TEXT NOT NULL,
	CONSTRAINT PRIMARY KEY (ID_EDICION)
);

INSERT INTO EDICION_PREVIAJE (EDICION)
SELECT DISTINCT ID_EDICION 
FROM DATOS_PREVIAJE;

COMMIT; 

-- TABLA PROVINCIA_PREVIAJE: CREATE, INSERT
CREATE TABLE PROVINCIA_PREVIAJE (
	ID_PROVINCIA INT AUTO_INCREMENT,
	PROVINCIA TEXT NOT NULL,
	CONSTRAINT PRIMARY KEY (ID_PROVINCIA)
);

INSERT INTO PROVINCIA_PREVIAJE (PROVINCIA)
SELECT DISTINCT ID_PROVINCIA_ORIGEN 
FROM DATOS_PREVIAJE
ORDER BY 1;

COMMIT; 

-- TABLA DATOS_PREVIAJE: UPDATE
UPDATE DATOS_PREVIAJE AS DP
INNER JOIN EDICION_PREVIAJE AS ED
	ON DP.ID_EDICION = ED.EDICION 
SET  DP.ID_EDICION = ED.ID_EDICION;

UPDATE DATOS_PREVIAJE AS DP
INNER JOIN PROVINCIA_PREVIAJE AS PR
	ON DP.ID_PROVINCIA_ORIGEN = PR.PROVINCIA
SET  DP.ID_PROVINCIA_ORIGEN = PR.ID_PROVINCIA;

UPDATE DATOS_PREVIAJE AS DP
INNER JOIN PROVINCIA_PREVIAJE AS PR
	ON DP.ID_PROVINCIA_DESTINO = PR.PROVINCIA
SET  DP.ID_PROVINCIA_DESTINO = PR.ID_PROVINCIA;

COMMIT;

-- TABLA DATOS_PREVIAJE: ALTER
ALTER TABLE DATOS_PREVIAJE 
MODIFY ID_PROVINCIA_ORIGEN INT,
MODIFY ID_PROVINCIA_DESTINO INT,
MODIFY ID_EDICION INT
;

ALTER TABLE DATOS_PREVIAJE ADD (
	CONSTRAINT FK_DATOS_PREVIAJE_EDICION FOREIGN KEY (ID_EDICION) REFERENCES EDICION_PREVIAJE (ID_EDICION),
    CONSTRAINT FK_DATOS_PREVIAJE_PROV_ORIGEN FOREIGN KEY (ID_PROVINCIA_ORIGEN) REFERENCES PROVINCIA_PREVIAJE (ID_PROVINCIA),
    CONSTRAINT FK_DATOS_PREVIAJE_PROV_DESTINO FOREIGN KEY (ID_PROVINCIA_DESTINO) REFERENCES PROVINCIA_PREVIAJE (ID_PROVINCIA)
 );
 
 -- TABLA DATASET: DROP
 DROP TABLE DATASET;
 
 -- COMPROBACIONES: las 3 consultas deben devolver "OK"
 SELECT CASE WHEN COUNT(1) = 7710 THEN 'OK' ELSE NULL END AS CANT FROM DATOS_PREVIAJE;
 SELECT CASE WHEN COUNT(1) = 24 THEN 'OK' ELSE NULL END AS CANT FROM PROVINCIA_PREVIAJE;
 SELECT CASE WHEN COUNT(1) = 3 THEN 'OK' ELSE NULL END AS CANT FROM EDICION_PREVIAJE;


#ENUNCIADO 4: 
-- Se obtiene el el diagrama del modelo lógico en el Workbench

#ENUNCIADO 5:

-- Apartado 5.a)

DELIMITER /
SELECT p.PROVINCIA AS Provincia, e.EDICION AS Edición, SUM(dp.CANT_VIAJES) AS Total_viajes, SUM(dp.CANT_VIAJEROS) AS Total_viajeros
FROM datos_previaje dp
JOIN provincia_previaje p ON dp.ID_PROVINCIA_DESTINO = p.ID_PROVINCIA
JOIN edicion_previaje e ON dp.ID_EDICION = e.ID_EDICION
GROUP BY Provincia, Edición
ORDER BY Total_viajes DESC
LIMIT 10;/
DELIMITER ; 

-- Apartado 5.b)

(SELECT DATE_FORMAT(dp.PERIODO, '%Y-%m') AS Periodo, e.EDICION AS Edición,  SUM(dp.CANT_VIAJES) AS Total_Viajes,
       CONCAT(ROUND(100*SUM(dp.CANT_VIAJES)/SUM(SUM(dp.CANT_VIAJES)) OVER(PARTITION BY dp.ID_EDICION),2),'%') AS Porcentaje_sobre_Edición,
       CONCAT(ROUND(100*SUM(dp.CANT_VIAJES)/(SELECT SUM(CANT_VIAJES) FROM datos_previaje),2), '%') AS Porcentaje_sobre_Total
FROM datos_previaje dp
JOIN edicion_previaje e ON dp.ID_EDICION = e.ID_EDICION
GROUP BY  dp.ID_EDICION, dp.PERIODO
ORDER BY dp.ID_EDICION ASC,dp.PERIODO ASC)
UNION
(SELECT 'Subtotales por edición', e.EDICION AS Edición, SUM(dp.CANT_VIAJES) AS Total_Viajes,
       CONCAT(ROUND(100*SUM(dp.CANT_VIAJES)/SUM(SUM(dp.CANT_VIAJES)) OVER(PARTITION BY dp.ID_EDICION),2),'%') AS Porcentaje_sobre_Edición,
       CONCAT(ROUND(100*SUM(dp.CANT_VIAJES)/(SELECT SUM(CANT_VIAJES) FROM datos_previaje),2), '%') AS Porcentaje_sobre_Total
FROM datos_previaje dp
JOIN edicion_previaje e ON dp.ID_EDICION = e.ID_EDICION
GROUP BY dp.ID_EDICION
ORDER BY dp.ID_EDICION ASC);

-- Apartado 5.c)

SELECT  p.PROVINCIA AS Provincia, SUM(dp.CANT_VIAJES) AS Viajes_misma_provincia
FROM datos_previaje dp
     JOIN provincia_previaje p ON dp.ID_PROVINCIA_ORIGEN = p.ID_PROVINCIA
     WHERE dp.ID_PROVINCIA_ORIGEN = dp.ID_PROVINCIA_DESTINO
     GROUP BY Provincia
	 ORDER BY Viajes_misma_provincia DESC
LIMIT 5;

-- Apartado 5.d)

SELECT
    Región_Destino,
    CASE WHEN Edición IS NULL THEN 'Subtotales' ELSE Edición END AS Edición,
    CONCAT(ROUND(SUM(Porcentaje_sobre_Total), 2), '%') AS Total_Porcentaje_sobre_Total,
    CONCAT(ROUND(SUM(Porcentaje_Región_Destino), 2), '%') AS Total_Porcentaje_Región_Destino
FROM (
    SELECT
        CASE 
            WHEN p.PROVINCIA IN ("Mendoza", "San Juan", "San Luis") THEN "Cuyo"
            WHEN p.PROVINCIA IN ("La Rioja", "Catamarca", "Jujuy", "Tucumán", "Salta", "Santiago del Estero") THEN "NOA"
            WHEN p.PROVINCIA IN ("Misiones", "Corrientes", "Entre Rios", "Formosa", "Chaco") THEN "NEA"
            WHEN p.PROVINCIA IN ("Buenos Aires", "Córdoba", "Santa Fe", "Ciudad Autónoma de Buenos Aires", "La Pampa") THEN "Centro"
            WHEN p.PROVINCIA IN ("Chubut", "Neuquén", "Rio Negro", "Santa Cruz") THEN "Patagonia"
            WHEN p.PROVINCIA IN ('Tierra del Fuego, Antártida e Islas del Atlántico Sur') THEN "Extremo Austral"
        END AS Región_Destino,
        e.EDICION AS Edición,
        SUM(CANT_VIAJES / (SELECT SUM(CANT_VIAJES) FROM datos_previaje ) * 100) AS Porcentaje_sobre_Total,
        SUM(CANT_VIAJES) * 100 / SUM(SUM(CANT_VIAJES)) OVER (PARTITION BY CASE 
            WHEN p.PROVINCIA IN ("Mendoza", "San Juan", "San Luis") THEN "Cuyo"
            WHEN p.PROVINCIA IN ("La Rioja", "Catamarca", "Jujuy", "Tucumán", "Salta", "Santiago del Estero") THEN "NOA"
            WHEN p.PROVINCIA IN ("Misiones", "Corrientes", "Entre Rios", "Formosa", "Chaco") THEN "NEA"
            WHEN p.PROVINCIA IN ("Buenos Aires", "Córdoba", "Santa Fe", "Ciudad Autónoma de Buenos Aires", "La Pampa") THEN "Centro"
            WHEN p.PROVINCIA IN ("Chubut", "Neuquén", "Rio Negro", "Santa Cruz") THEN "Patagonia"
            WHEN p.PROVINCIA IN ('Tierra del Fuego, Antártida e Islas del Atlántico Sur') THEN "Extremo Austral"
        END) AS Porcentaje_Región_Destino
    FROM datos_previaje dp
    LEFT JOIN provincia_previaje p ON p.ID_PROVINCIA = dp.ID_PROVINCIA_DESTINO
    LEFT JOIN edicion_previaje e ON e.ID_EDICION = dp.ID_EDICION 
    GROUP BY 1, 2
) AS subconsulta
GROUP BY Región_Destino, Edición WITH ROLLUP
ORDER BY Región_Destino, Edición;

## ENUNCIADO 6:

DELIMITER //
CREATE FUNCTION Funcion_Total_Viajes(
    ID_PROVINCIA_DESTINO VARCHAR(100), 
    PERIODO VARCHAR(100), 
    ID_EDICION VARCHAR(100) 
) RETURNS INT
READS SQL DATA
BEGIN 
    DECLARE Funcion_Total_Viajes INT;
    SET Funcion_Total_Viajes = 
    (
        SELECT SUM(dp.CANT_VIAJES) 
        FROM datos_previaje dp
        WHERE 
            (ID_PROVINCIA_DESTINO  IS NULL OR ID_PROVINCIA_DESTINO = dp.ID_PROVINCIA_DESTINO) AND
            (PERIODO IS NULL OR PERIODO = DATE_FORMAT(dp.PERIODO, '%Y-%m')) AND
            (ID_EDICION IS NULL OR ID_EDICION = dp.ID_EDICION)
    );
    
    RETURN Funcion_Total_Viajes;
END//
DELIMITER ;

-- Visualización del código de la funcion "Funcion_Total_Viajes"
SHOW CREATE FUNCTION Funcion_Total_Viajes;

-- Comprobación:
-- CONSULTAS 5.a)
-- CONSULTA 1: Cantidad de viajes a Buenos Aires como destino y en previaje 2
SELECT ID_PROVINCIA, PROVINCIA FROM provincia_previaje;
SELECT Funcion_Total_Viajes ('1', NULL, '2') AS Total_viajes_BuenosAires_Previaje2; 

-- CONSULTA 2: Cantidad de viajes a Río Negro como destino y en previaje 2
SELECT ID_PROVINCIA, PROVINCIA FROM provincia_previaje;
SELECT Funcion_Total_Viajes ('16', NULL, '2') AS Total_viajes_RíoNegro_Previaje2;

-- CONSULTAS 5.b)
-- CONSULTA 3: Cantidad de viajes para Previaje 1 y 2021/01
SELECT PERIODO FROM datos_previaje;
SELECT Funcion_Total_Viajes (NULL, '2021-01', '1') AS Total_viajes_Previaje1_2021_01;

-- CONSULTA 4: Cantidad de viajes para Previaje 1 y 2021/02
SELECT PERIODO FROM datos_previaje;
SELECT Funcion_Total_Viajes (NULL, '2021-02', '1') AS Total_viajes_Previaje1_2021_02;

-- CONSULTA 5: Cantidad de viajes para Previaje 2
SELECT PERIODO FROM datos_previaje;
SELECT Funcion_Total_Viajes (NULL, NULL, '2') AS Total_Previaje2;

-- Utilizar para eliminar la función "Funcion_Total_Viajes"
-- DROP FUNCTION Funcion_Total_Viajes;

