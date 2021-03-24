--Campus_yyyymmdd.csv
SELECT STVCAMP_CODE AS "id_campus"
    , STVCAMP_CODE AS "codigo_campus"
    , STVCAMP_DESC AS "nombre_campus"
    , 'UPN' AS "id_institucion"
FROM ODSMGR.LOE_STVCAMP
WHERE STVCAMP_CODE <> 'M';