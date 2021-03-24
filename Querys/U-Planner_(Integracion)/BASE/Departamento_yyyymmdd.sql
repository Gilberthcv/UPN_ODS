--Departamento_yyyymmdd.csv
SELECT STVDEPT_CODE AS "id_departamento"
    , NULL AS "codigo_departamento"
    , STVDEPT_DESC AS "nombre_departamento"
    , CASE STVDEPT_CODE
            WHEN 'DCIE' THEN 'IN'
            WHEN 'DHUM' THEN 'CO'
            WHEN 'IDIO' THEN 'ID'
        ELSE 'GE' END AS "id_facultad"
FROM ODSMGR.STVDEPT
WHERE STVDEPT_CODE NOT IN ('0000','ART')
UNION --DEPARTAMENTO GENERICO
SELECT 'GENE' AS "id_departamento"
    , NULL AS "codigo_departamento"
    , 'Dpto. Genérico' AS "nombre_departamento"
    , 'GE' AS "id_facultad"
FROM DUAL;