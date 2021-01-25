--Avance_Curricular_
WITH DETALLE_AVANCE_CURRICULAR AS (
	SELECT PROGRAM, TERM_CODE_EFF, CICLO, ROW_NUMBER() OVER(PARTITION BY PROGRAM, TERM_CODE_EFF, ID ORDER BY SEQ ASC) AS SEQ
		, REGLA, COD_CURSO_MALLA, CURSO_MALLA, CREDITOS, REQUISITOS, EQUIVALENCIAS, ID, ESTUDIANTE, SEQUENCE_NUMBER, REQ_CREDITS_OVERALL
		, COD_CURSO_CAPP, CURSO_CAPP, GRDE_CODE, NRO_VEZ, ACADEMIC_PERIOD, CUMPLIDO, MATRICULADO, HABILITADO, PENDIENTE, COMENTARIO
	FROM (
		SELECT PROGRAM, TERM_CODE_EFF, CAST(SUBSTR(AREA,LENGTH(AREA)-1) AS INT) AS CICLO, MIN(SEQ) AS SEQ, MAX(AREA_RULE_DESC) AS REGLA
            , CASE WHEN AREA IS NULL OR (AREA IS NOT NULL AND COD_CURSO_CAPP IS NULL) THEN COD_CURSO_MALLA ELSE COD_CURSO_CAPP END AS COD_CURSO_MALLA
            , CASE WHEN AREA IS NULL OR (AREA IS NOT NULL AND COD_CURSO_CAPP IS NULL) THEN CURSO_MALLA ELSE CURSO_CAPP END AS CURSO_MALLA
            , COALESCE(CREDIT_HOURS_USED,CREDITOS) AS CREDITOS, MAX(REQUISITOS) AS REQUISITOS, MAX(EQUIVALENCIAS) AS EQUIVALENCIAS
            , ID, ESTUDIANTE, SEQUENCE_NUMBER, REQ_CREDITS_OVERALL, COD_CURSO_CAPP, CURSO_CAPP, GRDE_CODE, NRO_VEZ, ACADEMIC_PERIOD
            , CUMPLIDO, CASE WHEN CT.TERM_CODE IS NULL THEN 0 ELSE MATRICULADO END AS MATRICULADO, HABILITADO, PENDIENTE
            , COALESCE(COMENTARIO,AREA_RULE_DESC) AS COMENTARIO
        FROM ODSMGR.LOE_AVANCE_CURRICULAR
        		LEFT JOIN ( SELECT T.TERM_CODE, S.STVTERM_DESC, R.START_DATE AS INICIO_CAMPANIA, T.END_DATE AS FIN_CLASES
							FROM ODSMGR.LOE_SECTION_PART_OF_TERM T
									INNER JOIN ODSMGR.LOE_STUDENT_REGIS_STATUS R ON T.TERM_CODE = R.ACADEMIC_PERIOD AND R.ESTS_CODE = 'EL'
									INNER JOIN ODSMGR.STVTERM S ON T.TERM_CODE = S.STVTERM_CODE
							WHERE CURRENT_DATE BETWEEN R.START_DATE AND (TO_DATE(T.END_DATE) +14)
							) CT ON ACADEMIC_PERIOD = CT.TERM_CODE
        --WHERE ID IN ('N00012261','N00103062','N00099523')
        WHERE ID = 'N00012261'
        --WHERE ID = 'N00099523'
        GROUP BY PROGRAM, TERM_CODE_EFF, CAST(SUBSTR(AREA,LENGTH(AREA)-1) AS INT)
            , CASE WHEN AREA IS NULL OR (AREA IS NOT NULL AND COD_CURSO_CAPP IS NULL) THEN COD_CURSO_MALLA ELSE COD_CURSO_CAPP END
            , CASE WHEN AREA IS NULL OR (AREA IS NOT NULL AND COD_CURSO_CAPP IS NULL) THEN CURSO_MALLA ELSE CURSO_CAPP END
            , COALESCE(CREDIT_HOURS_USED,CREDITOS), ID, ESTUDIANTE, SEQUENCE_NUMBER, REQ_CREDITS_OVERALL, COD_CURSO_CAPP, CURSO_CAPP, GRDE_CODE
            , NRO_VEZ, ACADEMIC_PERIOD, CUMPLIDO, CASE WHEN CT.TERM_CODE IS NULL THEN 0 ELSE MATRICULADO END, HABILITADO, PENDIENTE
            , COALESCE(COMENTARIO,AREA_RULE_DESC)
		)
	ORDER BY PROGRAM, TERM_CODE_EFF, ID, SEQ
)
, CURSOS_NO_RECONOCIDOS AS (
	SELECT A.PROGRAM, B.TERM_CODE_EFF, SPRIDEN_ID AS ID, SPRIDEN_LAST_NAME ||', '|| SPRIDEN_FIRST_NAME AS ESTUDIANTE, A.SEQUENCE_NUMBER
		, A.ACADEMIC_PERIOD, A.SUBJECT || A.COURSE_NUMBER AS COD_CURSO, A.COURSE_TITLE AS CURSO, A.LEVEL_CODE, A.GRADE_CODE, A.COURSE_CREDIT_HOURS
	FROM ODSMGR.LOE_DETAIL_COURSES A
			INNER JOIN ODSMGR.SHRGRDE ON A.GRADE_CODE = SHRGRDE_CODE AND SHRGRDE_PASSED_IND = 'Y' AND SHRGRDE_LEVL_CODE = 'UG'
			INNER JOIN ODSMGR.LOE_PROGRAM_OVERALL_RESULTS B ON A.PERSON_UID = B.PERSON_UID AND A.SEQUENCE_NUMBER = B.SEQUENCE_NUMBER AND A.PROGRAM = B.PROGRAM
			INNER JOIN ODSMGR.LOE_SPRIDEN ON A.PERSON_UID = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
			INNER JOIN ( SELECT SOVLCUR_PIDM, SOVLCUR_LEVL_CODE, SOVLCUR_PROGRAM
							, MIN(SOVLCUR_TERM_CODE) AS SOVLCUR_TERM_CODE
							, MAX(COALESCE(SOVLCUR_TERM_CODE_END,'999999')) AS SOVLCUR_TERM_CODE_END
						FROM ODSMGR.LOE_SOVLCUR
						WHERE SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE'
						GROUP BY SOVLCUR_PIDM, SOVLCUR_LEVL_CODE, SOVLCUR_PROGRAM
						) C ON A.PERSON_UID = C.SOVLCUR_PIDM AND A.PROGRAM = C.SOVLCUR_PROGRAM AND A.ACADEMIC_PERIOD BETWEEN C.SOVLCUR_TERM_CODE AND C.SOVLCUR_TERM_CODE_END
	WHERE A.SEQUENCE_NUMBER = (SELECT MAX(A1.SEQUENCE_NUMBER) FROM ODSMGR.LOE_DETAIL_COURSES A1
								WHERE A1.PERSON_UID = A.PERSON_UID AND A1.PROGRAM = A.PROGRAM)
)
SELECT AV.PROGRAM, AV.TERM_CODE_EFF, AV.ID, AV.ESTUDIANTE, AV.SEQUENCE_NUMBER, AV.REQ_CREDITS_OVERALL AS CREDITOS_REQUERIDOS
	, SUM(CASE WHEN AV.CUMPLIDO = 1 AND (AV.COMENTARIO IS NULL OR AV.COMENTARIO IN ('Equivalente',AV.REGLA)) THEN AV.CREDITOS ELSE 0 END) AS CREDITOS_APROBADOS
	, SUM(CASE WHEN AV.CUMPLIDO = 1 AND AV.COMENTARIO = 'Convalidado' THEN AV.CREDITOS ELSE 0 END) AS CREDITOS_CONVALIDADOS
	, SUM(CASE WHEN (AV.MATRICULADO = 1 OR AV.HABILITADO = 1) AND AV.NRO_VEZ > 1 THEN AV.CREDITOS ELSE 0 END) AS CREDITOS_REPROBADOS
	, SUM(CASE WHEN AV.PENDIENTE = 1 AND AV.REGLA IS NULL THEN AV.CREDITOS WHEN AV.PENDIENTE = 1 AND AV.REGLA IS NOT NULL THEN AV.CREDITOS_REGLA ELSE 0 END) AS CREDITOS_PENDIENTES
	, NR.ACADEMIC_PERIOD, NR.COD_CURSO, NR.CURSO, NR.GRADE_CODE, NR.COURSE_CREDIT_HOURS
FROM (
	SELECT PROGRAM, TERM_CODE_EFF, CICLO, SEQ , REGLA, COD_CURSO_MALLA, CURSO_MALLA, CREDITOS
		, CASE WHEN ROW_NUMBER() OVER(PARTITION BY PROGRAM, TERM_CODE_EFF, REGLA ORDER BY SEQ ASC) = 1 THEN CREDITOS ELSE 0 END AS CREDITOS_REGLA
		, REQUISITOS, EQUIVALENCIAS, ID, ESTUDIANTE, SEQUENCE_NUMBER, REQ_CREDITS_OVERALL, COD_CURSO_CAPP, CURSO_CAPP
		, GRDE_CODE, NRO_VEZ, ACADEMIC_PERIOD, CUMPLIDO, MATRICULADO, HABILITADO, PENDIENTE, COMENTARIO
	FROM DETALLE_AVANCE_CURRICULAR
	) AV
		LEFT JOIN CURSOS_NO_RECONOCIDOS NR ON AV.PROGRAM = NR.PROGRAM AND AV.TERM_CODE_EFF = NR.TERM_CODE_EFF AND AV.ID = NR.ID AND AV.SEQUENCE_NUMBER = NR.SEQUENCE_NUMBER
GROUP BY AV.PROGRAM, AV.TERM_CODE_EFF, AV.ID, AV.ESTUDIANTE, AV.SEQUENCE_NUMBER, AV.REQ_CREDITS_OVERALL, NR.ACADEMIC_PERIOD, NR.COD_CURSO, NR.CURSO, NR.GRADE_CODE, NR.COURSE_CREDIT_HOURS
;
