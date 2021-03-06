--NuevosEstudiantes_PlanEstudio_yyyymmdd.csv
SELECT DISTINCT SOBCURR_CAMP_CODE AS "id_campus"
	, STVTERM_CODE AS "id_periodo_academico"
	, 'JORNADA UNICA' AS "id_jornada"
	, PROGRAM  || '.'|| TERM_CODE_EFF AS "id_plan_estudio"
	, NULL AS "id_especialidad"
	, TO_NUMBER(SUBSTR(AREA,LENGTH(AREA)-1,2)) AS "numero_nivel"
	, NULL AS "numero_nuevos_estudiantes"
FROM ODSMGR.LOE_PROGRAM_AREA_PRIORITY A
		INNER JOIN ODSMGR.LOE_SOBCURR ON PROGRAM = SOBCURR_PROGRAM
		INNER JOIN ODSMGR.STVTERM ON CASE SUBSTR(PROGRAM,LENGTH(PROGRAM)-2) WHEN '-UG' THEN '4' WHEN '-WA' THEN '5' END = SUBSTR(STVTERM_CODE,4,1)
										AND STVTERM_CODE IN (:PERIODO_UG,:PERIODO_WA)
WHERE SUBSTR(AREA,LENGTH(AREA)-1,2) IN ('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14') AND SUBSTR(PROGRAM,LENGTH(PROGRAM)-2) IN ('-UG','-WA')
	AND A.TERM_CODE_EFF = (SELECT MAX(A1.TERM_CODE_EFF) FROM ODSMGR.LOE_PROGRAM_AREA_PRIORITY A1
							WHERE A1.PROGRAM = A.PROGRAM)
ORDER BY 1,2,4,6
;