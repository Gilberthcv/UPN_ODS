--PeriodoAcademico_yyyymmdd.csv
SELECT STVTERM_CODE AS "id_periodo_academico"
    , NULL AS "codigo_periodo_academico"
    , STVTERM_DESC AS "nombre_periodo_academico"
    , STVTERM_CODE AS "codigo_tipo_periodo_academico"
    , CASE SUBSTR(STVTERM_CODE,4,1)
    		WHEN '2' THEN 'periodo CURSOS LIBRES'
            WHEN '3' THEN 'trimestre'
            WHEN '4' THEN 'cuatrimestre UG'
            WHEN '5' THEN 'cuatrimestre WA'
            WHEN '6' THEN 'periodo INCOMPANY'
            WHEN '7' THEN 'cuatrimestre INGLES'
            WHEN '8' THEN 'periodo MAESTRIAS'
            WHEN '9' THEN 'periodo DIPLOMADOS'
        ELSE NULL END AS "nombre_tipo_periodo_academico"
    , CASE
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '00' AND SUBSTR(STVTERM_CODE,5,2) < '09' THEN 0
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '08' AND SUBSTR(STVTERM_CODE,5,2) < '26' THEN 1
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '25' AND SUBSTR(STVTERM_CODE,5,2) < '46' THEN 2
        ELSE 9 END AS "numero_periodo_academico"
    , STVTERM_ACYR_CODE AS "agno_periodo_academico"
    , 1 AS "indicador_periodo_regular"
    , NULL AS "numero_semanas"
    , TO_CHAR(COALESCE(START_DATE,STVTERM_START_DATE),'YYYY-MM-DD') AS "fecha_inicio_periodo"
    , TO_CHAR(COALESCE(END_DATE,STVTERM_END_DATE),'YYYY-MM-DD') AS "fecha_fin_periodo"
    , CASE WHEN CURRENT_DATE BETWEEN COALESCE(START_DATE,STVTERM_START_DATE) AND COALESCE(END_DATE,STVTERM_END_DATE) THEN 1 ELSE 0 END AS "indicador_actual"
    , CASE WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_DESC,5,1) = '-' AND COALESCE(START_DATE,STVTERM_START_DATE) > CURRENT_DATE
    	THEN 1 ELSE 0 END AS "indicador_programable"
FROM ODSMGR.LOE_STVTERM
		LEFT JOIN ODSMGR.LOE_SECTION_PART_OF_TERM ON STVTERM_CODE = TERM_CODE
;