--Curso_yyyymmdd.csv
SELECT COURSE_IDENTIFICATION/*||'.'||ACADEMIC_PERIOD*/ AS "id_curso"
    , NULL AS "codigo_curso"
    , COALESCE(TITLE_LONG_DESC,TITLE_SHORT_DESC) AS "nombre_curso"
    , CASE WHEN DEPARTMENT IN ('DCIE','DHUM','IDIO') THEN DEPARTMENT ELSE 'GENE' END AS "id_departamento"
    , CREDIT_MIN AS "numero_creditos"
    , NULL AS "indicador_actividad_mismo_dia"
    , NULL AS "indicador_curso_generico"
FROM ODSMGR.COURSE_CATALOG
WHERE ((STATUS = 'A' AND ACADEMIC_PERIOD = '999999') OR STATUS = 'I') AND COLLEGE <> 'GR'
;