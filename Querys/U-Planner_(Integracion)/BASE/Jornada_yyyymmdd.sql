--Jornada_yyyymmdd.csv
SELECT 'JORNADA UNICA' AS "id_jornada"
    , NULL AS "codigo_jornada"
    , 'JORNADA UNICA' AS "nombre_jornada"
    , CASE WHEN SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7')
        THEN TO_NUMBER(SUBSTR(STVMEET_CODE,1,1))
        ELSE 9 END AS "numero_dia"
    , SUBSTR(STVMEET_CODE,2,1) AS "id_bloque_hora_clase"
    , NULL AS "codigo_bloque_hora_clase"
    , STVMEET_CODE AS "nombre_bloque_hora_clase"
    , CASE WHEN SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7')
        THEN (CASE SUBSTR(STVMEET_CODE,2,1)
                    WHEN 'A' THEN 1
                    WHEN 'B' THEN 2
                    WHEN 'C' THEN 3
                    WHEN 'D' THEN 4
                    WHEN 'E' THEN 5
                    WHEN 'F' THEN 6
                    WHEN 'G' THEN 7
                    WHEN 'H' THEN 8
                    WHEN 'I' THEN 9
                ELSE NULL END)
        ELSE NULL END AS "orden_bloque_hora_clase"
    , SUBSTR(STVMEET_BEGIN_TIME,1,2)||':'||SUBSTR(STVMEET_BEGIN_TIME,3,2) AS "hora_inicio"
    , SUBSTR(STVMEET_END_TIME,1,2)||':'||SUBSTR(STVMEET_END_TIME,3,2) AS "hora_fin"
FROM ODSMGR.STVMEET
WHERE (SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7') AND SUBSTR(STVMEET_CODE,2,1) IN ('A','B','C','D','E','F','G','H','I'))
    OR STVMEET_CODE IN ('TC','VR');