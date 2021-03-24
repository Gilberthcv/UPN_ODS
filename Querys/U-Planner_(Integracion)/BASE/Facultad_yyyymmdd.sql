--Facultad_yyyymmdd.csv
SELECT STVCOLL_CODE AS "id_facultad"
    , NULL AS "codigo_facultad"
    , STVCOLL_DESC AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM ODSMGR.STVCOLL
WHERE STVCOLL_CODE NOT IN ('00','99')
UNION --FACULTAD GENERICA
SELECT 'GE' AS "id_facultad"
    , NULL AS "codigo_facultad"
    , 'Genérica' AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM DUAL;