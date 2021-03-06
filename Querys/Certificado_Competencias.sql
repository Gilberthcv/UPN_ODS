--Certificado_Competencias_
WITH CUMPLIDOS AS (
	SELECT DISTINCT C.COLL_CODE, SMBAOGN_PROGRAM, SMBAOGN_TERM_CODE_EFF, C.CAMP_CODE, SMBAOGN_PIDM, SPRIDEN_ID, SPRIDEN_LAST_NAME, SPRIDEN_FIRST_NAME, SMBAOGN_REQUEST_NO
		, C.ACTIVITY_DATE, SMBAOGN_AREA, B.COMPLIANCE_ORDER, B.SUBJECT, B.COURSE_NUMBER, B.TITLE, B.GRDE_CODE, B.ACADEMIC_PERIOD
		, MIN(B.ACADEMIC_PERIOD) OVER(PARTITION BY B.PERSON_UID, B.REQUEST_NO, B.AREA) AS MIN_SMRDOUS_TERM_CODE
		, MAX(B.ACADEMIC_PERIOD) OVER(PARTITION BY B.PERSON_UID, B.REQUEST_NO, B.AREA) AS MAX_SMRDOUS_TERM_CODE
		, SCREQIV_SUBJ_CODE_EQIV, SCREQIV_CRSE_NUMB_EQIV, SMRSSUB_SUBJ_CODE_REQ, SMRSSUB_CRSE_NUMB_REQ
	FROM ODSMGR.SMBAOGN A
			INNER JOIN ODSMGR.LOE_COURSE_ATTRIBUTE_PROGRAM B ON SMBAOGN_PIDM = B.PERSON_UID AND SMBAOGN_REQUEST_NO = B.REQUEST_NO AND SMBAOGN_AREA = B.AREA
			INNER JOIN ODSMGR.LOE_PROGRAM_OVERALL_RESULTS C ON SMBAOGN_PIDM = C.PERSON_UID AND SMBAOGN_REQUEST_NO = C.SEQUENCE_NUMBER
									AND C.SEQUENCE_NUMBER = (SELECT MAX(C1.SEQUENCE_NUMBER) FROM ODSMGR.LOE_PROGRAM_OVERALL_RESULTS C1
																WHERE C1.PERSON_UID = C.PERSON_UID AND C1.PROGRAM = C.PROGRAM)
			INNER JOIN ODSMGR.LOE_SPRIDEN ON SMBAOGN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
			LEFT JOIN ( SELECT AREA_COURSE, TERM_CODE_EFF, SCREQIV_SUBJ_CODE, SCREQIV_CRSE_NUMB, SCREQIV_SUBJ_CODE_EQIV, SCREQIV_CRSE_NUMB_EQIV
						FROM ODSMGR.LOE_AREA_COURSE, ODSMGR.SCREQIV
						WHERE SUBJ_CODE = SCREQIV_SUBJ_CODE_EQIV AND CRSE_NUMB_LOW = SCREQIV_CRSE_NUMB_EQIV
							AND TERM_CODE_EFF BETWEEN SCREQIV_START_TERM AND SCREQIV_END_TERM AND AREA_COURSE LIKE '%-CERT'
						) F ON B.SUBJECT = F.SCREQIV_SUBJ_CODE AND B.COURSE_NUMBER = F.SCREQIV_CRSE_NUMB AND B.AREA = F.AREA_COURSE AND B.TERM_CODE_EFF = F.TERM_CODE_EFF
			LEFT JOIN ODSMGR.SMRSSUB ON B.PERSON_UID = SMRSSUB_PIDM AND B.SUBJECT = SMRSSUB_SUBJ_CODE_SUB AND B.COURSE_NUMBER = SMRSSUB_CRSE_NUMB_SUB
	WHERE SMBAOGN_MET_IND = 'Y' AND SMBAOGN_AREA LIKE '%-CERT'
		AND A.SMBAOGN_REQUEST_NO = (SELECT MAX(A1.SMBAOGN_REQUEST_NO) FROM ODSMGR.SMBAOGN A1
									WHERE A1.SMBAOGN_PIDM = A.SMBAOGN_PIDM AND A1.SMBAOGN_PROGRAM = A.SMBAOGN_PROGRAM AND A1.SMBAOGN_AREA LIKE '%-CERT')
)
SELECT DISTINCT C.COLL_CODE, C.SMBAOGN_PROGRAM, C.SMBAOGN_TERM_CODE_EFF, C.CAMP_CODE, C.SMBAOGN_PIDM, C.SPRIDEN_ID, C.SPRIDEN_LAST_NAME ||', '|| C.SPRIDEN_FIRST_NAME AS ESTUDIANTE
	, C.SMBAOGN_REQUEST_NO, C.ACTIVITY_DATE, C.SMBAOGN_AREA, C.COMPLIANCE_ORDER
	, ROW_NUMBER() OVER(PARTITION BY C.SMBAOGN_PROGRAM, C.SMBAOGN_TERM_CODE_EFF, C.SMBAOGN_PIDM ORDER BY D.SEQNO) AS ITEM
	, D.SUBJ_CODE, D.CRSE_NUMB_LOW, COALESCE(E.TITLE_SHORT_DESC, E.TITLE_LONG_DESC) AS CURSO_CERTIFICACION, C.SUBJECT, C.COURSE_NUMBER, C.TITLE AS CURSO_APROBADO
	, CASE 
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SUBJECT||C.COURSE_NUMBER AND SUBSTR(C.GRDE_CODE,1,1) = 'C' THEN 'EL MISMO CURSO, CONVALIDADO'
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SUBJECT||C.COURSE_NUMBER THEN 'EL MISMO CURSO'
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SCREQIV_SUBJ_CODE_EQIV||C.SCREQIV_CRSE_NUMB_EQIV AND SUBSTR(C.GRDE_CODE,1,1) = 'C' THEN 'CURSO EQUIVALENTE, CONVALIDADO'
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SCREQIV_SUBJ_CODE_EQIV||C.SCREQIV_CRSE_NUMB_EQIV THEN 'CURSO EQUIVALENTE'
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SMRSSUB_SUBJ_CODE_REQ||C.SMRSSUB_CRSE_NUMB_REQ AND SUBSTR(C.GRDE_CODE,1,1) = 'C' THEN 'CURSO SUSTITUTO, CONVALIDADO'
		WHEN D.SUBJ_CODE||D.CRSE_NUMB_LOW = C.SMRSSUB_SUBJ_CODE_REQ||C.SMRSSUB_CRSE_NUMB_REQ THEN 'CURSO SUSTITUTO'
		ELSE 'CURSO CUMPLIDO POR AJUSTE DE CAPP' END AS REFERENCIA
	, C.GRDE_CODE, C.ACADEMIC_PERIOD, C.MIN_SMRDOUS_TERM_CODE, C.MAX_SMRDOUS_TERM_CODE
	, MAX(CASE 
		WHEN D1.SUBJ_CODE||D1.CRSE_NUMB_LOW = C.SUBJECT||C.COURSE_NUMBER AND SUBSTR(C.GRDE_CODE,1,1) = 'C' THEN NULL
		WHEN D1.SUBJ_CODE||D1.CRSE_NUMB_LOW = C.SUBJECT||C.COURSE_NUMBER THEN 'EL MISMO CURSO'
		ELSE NULL END) OVER(PARTITION BY C.SMBAOGN_PROGRAM, C.SMBAOGN_TERM_CODE_EFF, C.SMBAOGN_PIDM) AS CURSO_CAPSTONE
	, TRIM(MAX(CASE WHEN SMRACMT_PRNT_CODE = 'LNAME1' THEN SMRACMT_TEXT END) OVER(PARTITION BY SMRACMT_AREA, SMRACMT_TERM_CODE_EFF)
			|| MAX(CASE WHEN SMRACMT_PRNT_CODE = 'LNAME2' THEN SMRACMT_TEXT ELSE ' ' END) OVER(PARTITION BY SMRACMT_AREA, SMRACMT_TERM_CODE_EFF)) AS NOMBRE_CERTIFICACION
FROM CUMPLIDOS C
		LEFT JOIN ODSMGR.LOE_AREA_COURSE D ON C.SMBAOGN_AREA = D.AREA_COURSE AND C.SMBAOGN_TERM_CODE_EFF = D.TERM_CODE_EFF
												AND (C.SUBJECT||C.COURSE_NUMBER = D.SUBJ_CODE||D.CRSE_NUMB_LOW
														OR C.SCREQIV_SUBJ_CODE_EQIV||C.SCREQIV_CRSE_NUMB_EQIV = D.SUBJ_CODE||D.CRSE_NUMB_LOW
														OR C.SMRSSUB_SUBJ_CODE_REQ||C.SMRSSUB_CRSE_NUMB_REQ = D.SUBJ_CODE||D.CRSE_NUMB_LOW)
		LEFT JOIN ODSMGR.LOE_AREA_COURSE D1 ON C.SMBAOGN_AREA = D1.AREA_COURSE AND C.SMBAOGN_TERM_CODE_EFF = D1.TERM_CODE_EFF AND C.SUBJECT||C.COURSE_NUMBER = D1.SUBJ_CODE||D1.CRSE_NUMB_LOW
												AND D1.SEQNO = (SELECT MAX(D2.SEQNO) FROM ODSMGR.LOE_AREA_COURSE D2
																WHERE D2.AREA_COURSE = D1.AREA_COURSE AND D2.TERM_CODE_EFF = D1.TERM_CODE_EFF)
		LEFT JOIN ODSMGR.COURSE_CATALOG E ON D.SUBJ_CODE||D.CRSE_NUMB_LOW = E.SUBJECT||E.COURSE_NUMBER AND D.TERM_CODE_EFF = E.ACADEMIC_PERIOD
		LEFT JOIN ODSMGR.LOE_SMRACMT ON C.SMBAOGN_AREA = SMRACMT_AREA AND C.SMBAOGN_TERM_CODE_EFF = SMRACMT_TERM_CODE_EFF AND SMRACMT_PRNT_CODE IN ('LNAME1','LNAME2')
;
