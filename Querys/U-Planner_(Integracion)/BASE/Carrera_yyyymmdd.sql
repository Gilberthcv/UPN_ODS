--Carrera_yyyymmdd.csv
SELECT SMRPRLE_PROGRAM AS "id_carrera"
    , NULL AS "codigo_carrera"
    , SMRPRLE_PROGRAM_DESC AS "nombre_carrera"
    , SMRPRLE_COLL_CODE AS "id_facultad"
    , 'TPO_CARR' AS "id_tipo_carrera"
    , NULL AS "codigo_tipo_carrera"
    , 'TIPO CARRERA GENÉRICO' AS "nombre_tipo_carrera"
FROM ODSMGR.LOE_SMRPRLE
WHERE SMRPRLE_PROGRAM <> 'UNDECLARED';