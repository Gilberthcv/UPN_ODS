--LOE_AVANCE_CURRICULAR_

USE ROLE ETL_PROD;

USE DATABASE BI_CDW_PROD;
USE SCHEMA UPN_STG_SIS_BNRODS_ODSMGR;

CREATE OR REPLACE PROCEDURE "UPDATE_LOE_AVANCE_CURRICULAR"()
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
    var rs = snowflake.execute( { sqlText: 
        `
	INSERT INTO LOE_AVANCE_CURRICULAR (PROGRAM, TERM_CODE_EFF, AREA, AREA_RULE, AREA_RULE_DESC, SEQ, COD_CURSO_MALLA, CURSO_MALLA, CREDITOS, REQUISITOS, EQUIVALENCIAS, PERSON_UID, ID, ESTUDIANTE
										, SEQUENCE_NUMBER, ACTIVITY_DATE, TERM_CODE_CATLG, REQ_CREDITS_OVERALL, ACT_CREDITS_OVERALL, SMBAOGN_MET_IND, COD_CURSO_CAPP, CURSO_CAPP, GRDE_CODE, CREDIT_HOURS_USED
										, NRO_VEZ, ACADEMIC_PERIOD, CUMPLIDO, MATRICULADO, HABILITADO, PENDIENTE, COMENTARIO)
	WITH SOATERM AS (
		SELECT S.STVTERM_CODE, SUBSTR(S.STVTERM_DESC,1,6) AS PERIODO_LBL, S.STVTERM_DESC, COALESCE(T.START_DATE,S.STVTERM_START_DATE) AS INICIO_CLASES, COALESCE(T.END_DATE,S.STVTERM_END_DATE) AS FIN_CLASES
			, TO_CHAR(COALESCE(T.START_DATE,S.STVTERM_START_DATE),''YYYYMMDD'') AS INICIO_CLASES_NRO, TO_CHAR(COALESCE(T.END_DATE,S.STVTERM_END_DATE),''YYYYMMDD'') AS FIN_CLASES_NRO
			, R.START_DATE AS INICIO_CAMPANIA--, TO_CHAR(R.START_DATE,''YYYYMMDD'') AS INICIO_CAMPANIA_NRO
		FROM LOE_STVTERM S
				LEFT JOIN LOE_SECTION_PART_OF_TERM T ON S.STVTERM_CODE = T.TERM_CODE
				LEFT JOIN LOE_STUDENT_REGIS_STATUS R ON S.STVTERM_CODE = R.ACADEMIC_PERIOD AND R.ESTS_CODE = ''EL''
		)
	, REQUISITOS AS (
		SELECT SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB
	        , LISTAGG(TRIM(COALESCE(SCRRTST_CONNECTOR,'''') ||'' ''|| COALESCE(SCRRTST_LPAREN,'''') || COALESCE(SCRRTST_TESC_CODE,'''') || COALESCE(SCRRTST_TEST_SCORE,'''')
	        		|| COALESCE(SCRRTST_SUBJ_CODE_PREQ,'''') || COALESCE(SCRRTST_CRSE_NUMB_PREQ,'''') || COALESCE(SCRRTST_RPAREN,'''')),'' '')
	            WITHIN GROUP (ORDER BY SCRRTST_SEQNO) AS REQUISITOS/*
			, CASE WHEN SCRRTST_TERM_CODE_EFF >= ''220000'' THEN
				LISTAGG(TRIM(COALESCE(SCRRTST_CONNECTOR,'''') ||'' ''|| COALESCE(SCRRTST_LPAREN,'''') || COALESCE(SCRRTST_TESC_CODE,'''') || COALESCE(SCRRTST_TEST_SCORE,'''')
	        		|| COALESCE(TITLE_LONG_DESC,TITLE_SHORT_DESC,'''') || COALESCE(SCRRTST_RPAREN,'''')),'' '')
	            WITHIN GROUP (ORDER BY SCRRTST_SEQNO)
	            ELSE NULL END AS REQUISITOS_DESC*/
	    FROM LOE_SCRRTST
	    		--LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.COURSE_CATALOG ON SCRRTST_TERM_CODE_EFF = ACADEMIC_PERIOD AND SCRRTST_SUBJ_CODE_PREQ = SUBJECT AND SCRRTST_CRSE_NUMB_PREQ = COURSE_NUMBER
	    GROUP BY SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB
		)
	, EQUIVALENCIAS AS (
		SELECT EFF_TERM, SUBJECT, COURSE_NUMBER
	        , LISTAGG(SUBJECT_CODE_EQUIV || COURSE_NUMBER_EQUIV,'', '') WITHIN GROUP (ORDER BY SURROGATE_ID) AS EQUIVALENCIAS
	    FROM LOE_EQUIV_COURSE_REPEATING
	    GROUP BY EFF_TERM, SUBJECT, COURSE_NUMBER
		)
	, PLAN_ESTUDIOS AS (
		SELECT A.PROGRAM, A.TERM_CODE_EFF, A.AREA, B.AREA_RULE, SMBARUL_DESC, B.SEQNO, SMRARUL_SEQNO
			, ROW_NUMBER() OVER(PARTITION BY A.PROGRAM, A.TERM_CODE_EFF ORDER BY A.AREA, B.SEQNO, SMRARUL_SEQNO) AS SEQ
		    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END AS COD_CURSO
		    , COALESCE(D.TITLE_LONG_DESC, D.TITLE_SHORT_DESC) AS CURSO, COALESCE(D.CREDIT_MIN,0) AS CREDITOS , E.REQUISITOS, F.EQUIVALENCIAS
		FROM LOE_PROGRAM_AREA_PRIORITY A
				INNER JOIN LOE_AREA_COURSE B ON A.AREA = B.AREA_COURSE AND A.TERM_CODE_EFF = B.TERM_CODE_EFF
				LEFT JOIN LOE_SMRARUL ON B.AREA_COURSE = SMRARUL_AREA AND B.TERM_CODE_EFF = SMRARUL_TERM_CODE_EFF AND B.AREA_RULE = SMRARUL_KEY_RULE
				LEFT JOIN LOE_SMBARUL ON B.AREA_COURSE = SMBARUL_AREA AND B.TERM_CODE_EFF = SMBARUL_TERM_CODE_EFF AND B.AREA_RULE = SMBARUL_KEY_RULE
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.COURSE_CATALOG D ON B.TERM_CODE_EFF = D.ACADEMIC_PERIOD AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END = D.SUBJECT
																	AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
				LEFT JOIN REQUISITOS E ON CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END = E.SCRRTST_SUBJ_CODE
											AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END = E.SCRRTST_CRSE_NUMB
											AND E.SCRRTST_TERM_CODE_EFF = (SELECT MAX(E1.SCRRTST_TERM_CODE_EFF) FROM REQUISITOS E1
																			WHERE E1.SCRRTST_SUBJ_CODE = CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END
																				AND E1.SCRRTST_CRSE_NUMB = CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END
																				AND E1.SCRRTST_TERM_CODE_EFF <= B.TERM_CODE_EFF)
				LEFT JOIN EQUIVALENCIAS F ON CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END = F.SUBJECT
											AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END = F.COURSE_NUMBER
											AND F.EFF_TERM = (SELECT MAX(F1.EFF_TERM) FROM EQUIVALENCIAS F1
																WHERE F1.SUBJECT = CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE SMRARUL_SUBJ_CODE END
																	AND F1.COURSE_NUMBER = CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE SMRARUL_CRSE_NUMB_LOW END
																	AND F1.EFF_TERM <= B.TERM_CODE_EFF)
		WHERE SUBSTR(A.AREA,LENGTH(A.AREA)-1) IN (''01'',''02'',''03'',''04'',''05'',''06'',''07'',''08'',''09'',''10'',''11'',''12'')
		)
	, CUMPLIDOS AS (
		SELECT A.PERSON_UID, A.SEQUENCE_NUMBER, A.PROGRAM, A.TERM_CODE_EFF, A.TERM_CODE_CATLG, A.REQ_CREDITS_OVERALL, A.REQ_COURSES_OVERALL, A.ACT_CREDITS_OVERALL, A.ACT_COURSES_OVERALL
			, SMBAOGN_AREA, SMBAOGN_MET_IND, B.KEY_RULE, B.SUBJECT || B.COURSE_NUMBER AS COD_CURSO, B.COURSE_REFERENCE_NUMBER, B.TITLE, B.GRDE_CODE, B.CREDIT_HOURS_USED, B.ACADEMIC_PERIOD
			, B.COURSE_SOURCE, SMRSSUB_SUBJ_CODE_REQ || SMRSSUB_CRSE_NUMB_REQ AS CURSO_SUSTITUIDO
		FROM LOE_PROGRAM_OVERALL_RESULTS A
				INNER JOIN SMBAOGN ON A.PERSON_UID = SMBAOGN_PIDM AND A.SEQUENCE_NUMBER = SMBAOGN_REQUEST_NO AND A.PROGRAM = SMBAOGN_PROGRAM AND A.TERM_CODE_EFF = SMBAOGN_TERM_CODE_EFF
				INNER JOIN LOE_COURSE_ATTRIBUTE_PROGRAM B ON SMBAOGN_PIDM = B.PERSON_UID AND SMBAOGN_REQUEST_NO = B.REQUEST_NO AND SMBAOGN_TERM_CODE_EFF = B.TERM_CODE_EFF
																	AND SMBAOGN_AREA = B.AREA AND SMBAOGN_PROGRAM = B.PROGRAM
				INNER JOIN LOE_SOVLCUR ON A.PERSON_UID = SOVLCUR_PIDM AND A.PROGRAM = SOVLCUR_PROGRAM AND SOVLCUR_LEVL_CODE = ''UG''
												AND SOVLCUR_LMOD_CODE = ''LEARNER'' AND SOVLCUR_CACT_CODE = ''ACTIVE'' AND SOVLCUR_CURRENT_IND = ''Y''
				LEFT JOIN SMRSSUB ON B.PERSON_UID = SMRSSUB_PIDM AND B.TERM_CODE_EFF = SMRSSUB_TERM_CODE_EFF AND B.SUBJECT = SMRSSUB_SUBJ_CODE_SUB AND B.COURSE_NUMBER = SMRSSUB_CRSE_NUMB_SUB
		WHERE SUBSTR(SMBAOGN_AREA,LENGTH(SMBAOGN_AREA)-1) IN (''01'',''02'',''03'',''04'',''05'',''06'',''07'',''08'',''09'',''10'',''11'',''12'') AND B.COURSE_SOURCE <> ''R''
			AND A.SEQUENCE_NUMBER = (SELECT MAX(A1.SEQUENCE_NUMBER) FROM LOE_PROGRAM_OVERALL_RESULTS A1
										WHERE A1.PERSON_UID = A.PERSON_UID AND A1.PROGRAM = A.PROGRAM)
		)
	, MATRICULADOS AS (
		SELECT DISTINCT SFRSTCR_PIDM, SOVLCUR_PROGRAM, COALESCE(C.TERM_CODE_EFF, D.TERM_CODE_EFF) AS TERM_CODE_EFF, SSBSECT_SUBJ_CODE || SSBSECT_CRSE_NUMB AS COD_CURSO, SFRSTCR_CRN
			, COALESCE(E.TITLE_LONG_DESC, E.TITLE_SHORT_DESC) AS CURSO, SFRSTCR_RSTS_CODE, SFRSTCR_TERM_CODE, B.INICIO_CLASES
		FROM SFRSTCR A
				INNER JOIN LOE_SSBSECT ON SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
				INNER JOIN LOE_SOVLCUR ON SFRSTCR_PIDM = SOVLCUR_PIDM AND SOVLCUR_LMOD_CODE = ''LEARNER'' AND SOVLCUR_CACT_CODE = ''ACTIVE'' AND SOVLCUR_CURRENT_IND = ''Y'' AND SOVLCUR_LEVL_CODE = ''UG''
				INNER JOIN SOATERM B ON SFRSTCR_TERM_CODE = B.STVTERM_CODE
				LEFT JOIN LOE_PROGRAM_OVERALL_RESULTS C ON SOVLCUR_PIDM = C.PERSON_UID AND SOVLCUR_PROGRAM = C.PROGRAM
																AND C.SEQUENCE_NUMBER = (SELECT MAX(C1.SEQUENCE_NUMBER) FROM LOE_PROGRAM_OVERALL_RESULTS C1
																						WHERE C1.PERSON_UID = C.PERSON_UID AND C1.PROGRAM = C.PROGRAM)
				LEFT JOIN LOE_PROGRAM_AREA_PRIORITY D ON SOVLCUR_PROGRAM = D.PROGRAM
																AND D.TERM_CODE_EFF = (SELECT MAX(D1.TERM_CODE_EFF) FROM LOE_PROGRAM_AREA_PRIORITY D1
																						WHERE D1.PROGRAM = SOVLCUR_PROGRAM AND D1.TERM_CODE_EFF <= SOVLCUR_TERM_CODE_CTLG)
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.COURSE_CATALOG E ON SSBSECT_TERM_CODE = E.ACADEMIC_PERIOD AND SSBSECT_SUBJ_CODE = E.SUBJECT AND SSBSECT_CRSE_NUMB = E.COURSE_NUMBER
		WHERE SFRSTCR_RSTS_CODE NOT IN (''DD'',''DW'') AND SSBSECT_SUBJ_CODE NOT IN (''TUTO'',''REPS'',''XSER'',''ACAD'',''TEST'',''XPEN'') AND (SSBSECT_SUBJ_CODE <> ''IDIO'' OR SFRSTCR_LEVL_CODE <> ''CR'')		
			AND CURRENT_DATE BETWEEN B.INICIO_CAMPANIA AND (TO_DATE(B.FIN_CLASES) +14) AND SUBSTR(B.STVTERM_CODE,4,1) IN (''4'',''5'')
		)
	, PROYECCIONES AS (
		SELECT SFRREGP_PIDM, SFRREGP_PROGRAM, C.TERM_CODE_EFF, SFRREGP_AREA, SFRREGP_SUBJ_CODE || SFRREGP_CRSE_NUMB_LOW AS COD_CURSO
			, COALESCE(D.TITLE_LONG_DESC, D.TITLE_SHORT_DESC) AS CURSO, SFRREGP_TERM_CODE
		FROM SFRREGP A
				INNER JOIN SOATERM B ON SFRREGP_TERM_CODE = B.STVTERM_CODE
				INNER JOIN LOE_PROGRAM_OVERALL_RESULTS C ON SFRREGP_PIDM = C.PERSON_UID AND SFRREGP_PROGRAM = C.PROGRAM
																AND C.SEQUENCE_NUMBER = (SELECT MAX(C1.SEQUENCE_NUMBER) FROM LOE_PROGRAM_OVERALL_RESULTS C1
																						WHERE C1.PERSON_UID = C.PERSON_UID AND C1.PROGRAM = C.PROGRAM)
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.COURSE_CATALOG D ON SFRREGP_TERM_CODE = D.ACADEMIC_PERIOD AND SFRREGP_SUBJ_CODE = D.SUBJECT AND SFRREGP_CRSE_NUMB_LOW = D.COURSE_NUMBER
		WHERE B.INICIO_CLASES = (SELECT MAX(B1.START_DATE) FROM SFRREGP A1 INNER JOIN LOE_SECTION_PART_OF_TERM B1 ON A1.SFRREGP_TERM_CODE = B1.TERM_CODE WHERE A1.SFRREGP_PIDM = A.SFRREGP_PIDM)
		)
	SELECT X.PROGRAM, X.TERM_CODE_EFF, X.AREA, X.AREA_RULE, X.SMBARUL_DESC AS AREA_RULE_DESC, X.SEQ, X.COD_CURSO AS COD_CURSO_MALLA, X.CURSO AS CURSO_MALLA, X.CREDITOS, X.REQUISITOS, X.EQUIVALENCIAS
		, X.PERSON_UID, X.SPRIDEN_ID AS ID, X.SPRIDEN_LAST_NAME ||'', ''|| X.SPRIDEN_FIRST_NAME AS ESTUDIANTE, X.SEQUENCE_NUMBER, X.ACTIVITY_DATE, X.TERM_CODE_CATLG, X.REQ_CREDITS_OVERALL, X.ACT_CREDITS_OVERALL
		, X.SMBAOGN_MET_IND, X.COD_CURSO_CAPP, X.CURSO_CAPP, X.GRDE_CODE, X.CREDIT_HOURS_USED, X.NRO_VEZ, X.ACADEMIC_PERIOD, X.CUMPLIDO, X.MATRICULADO, X.HABILITADO, X.PENDIENTE
		--, COALESCE(X.CURSO_RULE_CUMPLIDO, X.CURSO_RULE_EQUIVALENTE, X.CURSO_RULE_SUSTITUTO) AS CURSO_RULE
		, CASE
			WHEN X.AREA_RULE IS NOT NULL AND X.COURSE_SOURCE = ''T'' OR SUBSTR(X.GRDE_CODE,1,1) = ''C'' THEN ''Convalidado''
			WHEN X.AREA_RULE IS NOT NULL AND X.CURSO_RULE_CUMPLIDO IS NULL AND X.CURSO_RULE_EQUIVALENTE IS NOT NULL THEN ''Equivalente''
			WHEN X.AREA_RULE IS NOT NULL AND X.CURSO_RULE_SUSTITUTO IS NOT NULL THEN ''Sustituto''
			WHEN X.AREA_RULE IS NULL THEN X.COMENTARIO
			ELSE NULL END AS COMENTARIO
	FROM (SELECT A.PROGRAM, A.TERM_CODE_EFF, A.AREA, A.AREA_RULE, A.SMBARUL_DESC, A.SEQ, A.COD_CURSO, A.CURSO, A.CREDITOS, A.REQUISITOS, A.EQUIVALENCIAS
			, B.PERSON_UID, SPRIDEN_ID, SPRIDEN_LAST_NAME, SPRIDEN_FIRST_NAME, B.SEQUENCE_NUMBER, B.ACTIVITY_DATE, B.TERM_CODE_CATLG, B.REQ_CREDITS_OVERALL, B.ACT_CREDITS_OVERALL
			, MAX(C.SMBAOGN_MET_IND) OVER(PARTITION BY A.PROGRAM, A.TERM_CODE_EFF, A.AREA, B.PERSON_UID) AS SMBAOGN_MET_IND
			, COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO) AS COD_CURSO_CAPP, COALESCE(C.TITLE, D.CURSO, E.CURSO) AS CURSO_CAPP, C.GRDE_CODE, C.CREDIT_HOURS_USED, C.COURSE_SOURCE
			, CASE WHEN COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO) IS NOT NULL THEN COALESCE(R.COURSE_COUNT, 0) +1 END AS NRO_VEZ
			, COALESCE(C.ACADEMIC_PERIOD, D.SFRSTCR_TERM_CODE, E.SFRREGP_TERM_CODE) AS ACADEMIC_PERIOD
			, CASE WHEN C.PERSON_UID IS NOT NULL THEN 1 ELSE 0 END AS CUMPLIDO
			, CASE WHEN C.PERSON_UID IS NULL AND D.SFRSTCR_PIDM IS NOT NULL THEN 1 ELSE 0 END AS MATRICULADO
			, CASE WHEN C.PERSON_UID IS NULL AND D.SFRSTCR_PIDM IS NULL AND E.SFRREGP_PIDM IS NOT NULL THEN 1 ELSE 0 END AS HABILITADO
			, CASE WHEN C.PERSON_UID IS NULL AND D.SFRSTCR_PIDM IS NULL AND E.SFRREGP_PIDM IS NULL THEN 1 ELSE 0 END AS PENDIENTE
			, MAX(CASE WHEN A.AREA_RULE IS NOT NULL AND A.COD_CURSO = COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO) THEN COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO) END)
						OVER (PARTITION BY A.PROGRAM, A.TERM_CODE_EFF, A.AREA, A.AREA_RULE, B.PERSON_UID) AS CURSO_RULE_CUMPLIDO
			, MAX(CASE WHEN A.AREA_RULE IS NOT NULL AND A.EQUIVALENCIAS LIKE ''%''||COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO)||''%'' THEN A.COD_CURSO END)
						OVER (PARTITION BY A.PROGRAM, A.TERM_CODE_EFF, A.AREA, A.AREA_RULE, B.PERSON_UID) AS CURSO_RULE_EQUIVALENTE
			, MAX(CASE WHEN A.AREA_RULE IS NOT NULL AND A.COD_CURSO = C.CURSO_SUSTITUIDO THEN C.CURSO_SUSTITUIDO END)
						OVER (PARTITION BY A.PROGRAM, A.TERM_CODE_EFF, A.AREA, A.AREA_RULE, B.PERSON_UID) AS CURSO_RULE_SUSTITUTO
			, CASE
				WHEN C.COURSE_SOURCE = ''T'' OR SUBSTR(C.GRDE_CODE,1,1) = ''C'' THEN ''Convalidado''
				WHEN A.COD_CURSO <> C.COD_CURSO AND A.EQUIVALENCIAS LIKE ''%''||C.COD_CURSO||''%'' THEN ''Equivalente''
				WHEN A.COD_CURSO = C.CURSO_SUSTITUIDO THEN ''Sustituto''
				WHEN D.INICIO_CLASES > CURRENT_DATE THEN NULL
				WHEN D.SFRSTCR_RSTS_CODE IN (''WC'',''RF'') THEN ''Retirado''
				WHEN D.SFRSTCR_RSTS_CODE IN (''RO'',''IA'') THEN ''Inhabilitado''
				WHEN D.SFRSTCR_RSTS_CODE IN (''RW'',''RE'',''RA'') THEN ''En curso''
				ELSE NULL END AS COMENTARIO
		FROM PLAN_ESTUDIOS A
				INNER JOIN LOE_PROGRAM_OVERALL_RESULTS B ON A.PROGRAM = B.PROGRAM AND A.TERM_CODE_EFF = B.TERM_CODE_EFF
																	AND B.SEQUENCE_NUMBER = (SELECT MAX(B1.SEQUENCE_NUMBER) FROM LOE_PROGRAM_OVERALL_RESULTS B1
																							WHERE B1.PERSON_UID = B.PERSON_UID AND B1.PROGRAM = B.PROGRAM)
				INNER JOIN LOE_SOVLCUR ON B.PERSON_UID = SOVLCUR_PIDM AND B.PROGRAM = SOVLCUR_PROGRAM AND SOVLCUR_LEVL_CODE = ''UG''
													AND SOVLCUR_LMOD_CODE = ''LEARNER'' AND SOVLCUR_CACT_CODE = ''ACTIVE'' AND SOVLCUR_CURRENT_IND = ''Y''
				INNER JOIN LOE_SPRIDEN ON B.PERSON_UID = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
				LEFT JOIN CUMPLIDOS C ON B.PERSON_UID = C.PERSON_UID AND B.SEQUENCE_NUMBER = C.SEQUENCE_NUMBER AND B.PROGRAM = C.PROGRAM AND A.AREA = C.SMBAOGN_AREA
										AND (A.COD_CURSO = C.COD_CURSO OR A.EQUIVALENCIAS LIKE ''%''||C.COD_CURSO||''%'' OR A.AREA_RULE = C.KEY_RULE OR A.COD_CURSO = C.CURSO_SUSTITUIDO)
				LEFT JOIN MATRICULADOS D ON B.PERSON_UID = D.SFRSTCR_PIDM AND B.PROGRAM = D.SOVLCUR_PROGRAM AND B.TERM_CODE_EFF = D.TERM_CODE_EFF
										AND (A.COD_CURSO = D.COD_CURSO OR A.EQUIVALENCIAS LIKE ''%''||D.COD_CURSO||''%'')
				LEFT JOIN PROYECCIONES E ON B.PERSON_UID = E.SFRREGP_PIDM AND B.PROGRAM = E.SFRREGP_PROGRAM AND B.TERM_CODE_EFF = E.TERM_CODE_EFF
											AND ((A.AREA = E.SFRREGP_AREA AND A.COD_CURSO = E.COD_CURSO) OR A.COD_CURSO = E.COD_CURSO)
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_REPEAT_COURSE_LCUR R ON B.PROGRAM = R.PROGRAM AND B.TERM_CODE_EFF = R.TERM_CODE_EFF AND B.PERSON_UID = R.PERSON_UID
																AND COALESCE(C.ACADEMIC_PERIOD, D.SFRSTCR_TERM_CODE, E.SFRREGP_TERM_CODE) = R.ACADEMIC_PERIOD
																AND COALESCE(C.COD_CURSO, D.COD_CURSO, E.COD_CURSO) = R.SUBJECT || R.COURSE_NUMBER
		) X
	--ORDER BY X.PROGRAM, X.TERM_CODE_EFF, X.SPRIDEN_ID, X.SEQ
	;
		`
        } );
    return ''Done.'';
    ';
	