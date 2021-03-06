--AC039_Tipo_Estudiante_
SELECT --X.PERSON_UID, X.SPRIDEN_ID, X.NOMBRE_ESTUDIANTE, X.ACADEMIC_PERIOD, X.PROGRAM, X.PROGRAM_DESC, X.CAMPUS_DESC, X.FECHA_REGISTRO_CURSOS, X.TIPO_ESTUDIANTE AS TIPO_ESTUDIANTE_BANNER, X.CREDITOS, X.CURSOS
	--, Y.ACADEMIC_PERIOD_START AS COHORT_START, Y.ACADEMIC_PERIOD_END AS COHORT_END, X.TIPO_ESTUDIANTE_V2 AS TIPO_ESTUDIANTE_CALCULADO, X.MAX_PERIODO_HISTORIA, X.MAX_PERIODO_EGRESO, X.FLAG_INTERCAMBIO_OUT, 
	CASE WHEN Y.ACADEMIC_PERIOD_START IN ('221413','221513') THEN 'COHORT SEMESTRE ACTUAL' WHEN Y.PERSON_UID IS NOT NULL THEN 'COHORT SEMESTRE ANTERIOR' END AS COHORT
	, X.TIPO_ESTUDIANTE AS TIPO_ESTUDIANTE_BANNER, X.TIPO_ESTUDIANTE_V2 AS TIPO_ESTUDIANTE_CALCULADO, COUNT(DISTINCT X.PERSON_UID) AS ESTUDIANTES
FROM (
	SELECT DISTINCT
	    A.PERSON_UID, F.SPRIDEN_ID, CONCAT(F.SPRIDEN_LAST_NAME,CONCAT(', ',F.SPRIDEN_FIRST_NAME)) AS NOMBRE_ESTUDIANTE, A.ACADEMIC_PERIOD, A.PROGRAM, A.PROGRAM_DESC, A.CAMPUS_DESC
	    , MIN(B.SECTION_ADD_DATE) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD) AS FECHA_REGISTRO_CURSOS
		, CASE 
			WHEN A.ADMISSIONS_POPULATION <> 'RE' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Intercambio OUT'
			WHEN E.ACTIVITY = 'DTO' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Doble Titulacion OUT'
			WHEN E.ACTIVITY = 'ITO' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Intercambio OUT'
			WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'NEW_REING' THEN 'Nuevo Reingreso'
			WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'REINGRESO' THEN 'Reingreso'
			WHEN A.ADMISSIONS_POPULATION = 'II' THEN 'Intercambio IN'
			WHEN A.STUDENT_POPULATION = 'N' THEN 'Nuevo'
			WHEN A.STUDENT_POPULATION = 'C' THEN 'Continuo'
			ELSE A.STUDENT_POPULATION END AS TIPO_ESTUDIANTE
	    , SUM(B.COURSE_CREDITS) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD) AS CREDITOS
	    , COUNT(B.COURSE_REFERENCE_NUMBER) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD) AS CURSOS
	    , MAX(CASE WHEN SUBJECT = 'XSER' THEN SUBJECT END) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD) AS MATERIA_XSER
	    , CASE WHEN A.ADMISSIONS_POPULATION = 'II' THEN 'Intercambio IN' WHEN T.SHRTCKN_PIDM IS NULL THEN 'Nuevo' ELSE T.TIPO_ESTUDIANTE END AS TIPO_ESTUDIANTE_V2
	    , T.MAX_PERIODO_HISTORIA, T.MAX_PERIODO_EGRESO, T.FLAG_INTERCAMBIO_OUT
	FROM UPN_RPT_DM_PROD.ODSMGR.ACADEMIC_STUDY A
			INNER JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_COURSE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD AND B.TRANSFER_COURSE_IND = 'N' AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO','IA')
	     	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_COHORT C ON A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD AND C.COHORT_ACTIVE_IND = 'Y' AND C.COHORT IN ('NEW_REING','REINGRESO')
	     	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_ATTRIBUTE D ON A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD AND D.STUDENT_ATTRIBUTE IN ('TINT')
	     	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_ACTIVITY E ON A.PERSON_UID = E.PERSON_UID AND A.ACADEMIC_PERIOD = E.ACADEMIC_PERIOD AND E.ACTIVITY = 'ITO'
	     	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_SPRIDEN F ON A.PERSON_UID = F.SPRIDEN_PIDM AND F.SPRIDEN_CHANGE_IND IS NULL
	     	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_TIPO_ESTUDIANTE T ON A.PERSON_UID = T.SHRTCKN_PIDM AND A.ACADEMIC_PERIOD = T.PERIODO_ACTUAL
	WHERE A.ENROLLMENT_STATUS IN ('EL','RF','RO','SE') AND A.STUDENT_LEVEL = 'UG' AND A.ACADEMIC_PERIOD IN ('221413','221513')
	) X
		LEFT JOIN BI_CDW_PROD.UPN_STG_SIS_BNRODS_ODSMGR.MST_STUDENT_COHORT Y ON X.PERSON_UID = Y.PERSON_UID AND X.ACADEMIC_PERIOD BETWEEN Y.ACADEMIC_PERIOD_START AND Y.ACADEMIC_PERIOD_END AND Y.COHORT IN ('NEW_REING','REINGRESO')
WHERE X.MATERIA_XSER IS NULL
	AND X.TIPO_ESTUDIANTE <> CASE WHEN X.TIPO_ESTUDIANTE_V2 = 'Regular' THEN 'Continuo' ELSE X.TIPO_ESTUDIANTE_V2 END --AND X.TIPO_ESTUDIANTE_V2 = 'Nuevo Reingreso'
	--AND (X.MAX_PERIODO_HISTORIA IS NOT NULL OR X.MAX_PERIODO_EGRESO IS NOT NULL)
	--AND X.MAX_PERIODO_HISTORIA IS NULL AND X.MAX_PERIODO_EGRESO IS NULL
	--AND X.TIPO_ESTUDIANTE = 'Continuo' AND X.TIPO_ESTUDIANTE_V2 = 'Reingreso'
	--AND Y.ACADEMIC_PERIOD_START NOT IN ('221413','221513')
	--AND Y.ACADEMIC_PERIOD_START IN ('221413','221513')
GROUP BY CASE WHEN Y.ACADEMIC_PERIOD_START IN ('221413','221513') THEN 'COHORT SEMESTRE ACTUAL' WHEN Y.PERSON_UID IS NOT NULL THEN 'COHORT SEMESTRE ANTERIOR' END, X.TIPO_ESTUDIANTE, X.TIPO_ESTUDIANTE_V2
ORDER BY 1, X.TIPO_ESTUDIANTE_V2, X.TIPO_ESTUDIANTE DESC
;