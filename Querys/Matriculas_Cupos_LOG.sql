--Matriculas_Cupos_LOG
SELECT SSBSECT_TERM_CODE, SSBSECT_SUBJ_CODE||SSBSECT_CRSE_NUMB AS COD_CURSO, COALESCE(TITLE_LONG_DESC,TITLE_SHORT_DESC) AS CURSO, SSBSECT_CAMP_CODE, MAX(SSBSECT_MAX_ENRL-INSCRITOS) AS CUPOS
FROM (SELECT SSBSECT_TERM_CODE, SSBSECT_CRN, SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB, SSBSECT_SSTS_CODE, SSBSECT_CAMP_CODE, SSBSECT_MAX_ENRL, SSBSECT_ENRL, SSBSECT_SEATS_AVAIL
		, COUNT(B.PERSON_UID) AS INSCRITOS
	FROM ODSMGR.LOE_SSBSECT
			INNER JOIN (SELECT PERSON_UID, ID, NAME, ACADEMIC_PERIOD, SUBJECT, COURSE_NUMBER, COURSE_REFERENCE_NUMBER, SEQUENCE_NUMBER, REGISTRATION_STATUS
						FROM ODSMGR.STUDENT_COURSE_REG_AUDIT A
						WHERE REGISTRATION_SOURCE = 'BASE' AND ACADEMIC_PERIOD = '220435' AND (REGISTRATION_ERROR_FLAG <> 'D' OR REGISTRATION_ERROR_FLAG IS NULL)
							AND ((SUBJECT = 'PSGE' AND COURSE_NUMBER = '1205')
								OR (SUBJECT = 'LENG' AND COURSE_NUMBER = '1003')
								OR (SUBJECT = 'PSGE' AND COURSE_NUMBER = '1207A')
								OR (SUBJECT = 'PSOR' AND COURSE_NUMBER = '1301A')
								OR (SUBJECT = 'PSCL' AND COURSE_NUMBER = '1320')
								OR (SUBJECT = 'PSGE' AND COURSE_NUMBER = '1320')
								OR (SUBJECT = 'PSCL' AND COURSE_NUMBER = '1311A')
								OR (SUBJECT = 'INVE' AND COURSE_NUMBER = '1301')
								OR (SUBJECT = 'PSCL' AND COURSE_NUMBER = '1302A'))
							AND A.LAST_DATE_CHANGE < TO_DATE('2020/09/05','YYYY/MM/DD')
							AND A.SEQUENCE_NUMBER = (SELECT MAX(A1.SEQUENCE_NUMBER) FROM ODSMGR.STUDENT_COURSE_REG_AUDIT A1
													WHERE A1.PERSON_UID = A.PERSON_UID AND A1.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD AND A1.COURSE_REFERENCE_NUMBER = A.COURSE_REFERENCE_NUMBER
														AND A1.REGISTRATION_SOURCE = 'BASE' AND A1.LAST_DATE_CHANGE < TO_DATE('2020/09/05','YYYY/MM/DD'))
							) B ON SSBSECT_TERM_CODE = B.ACADEMIC_PERIOD AND SSBSECT_CRN = B.COURSE_REFERENCE_NUMBER
	WHERE SSBSECT_SSTS_CODE = 'A' AND SSBSECT_TERM_CODE = '220435' AND SSBSECT_CAMP_CODE IN ('LC0','VIR')
		AND ((SSBSECT_SUBJ_CODE = 'PSGE' AND SSBSECT_CRSE_NUMB = '1205')
			OR (SSBSECT_SUBJ_CODE = 'LENG' AND SSBSECT_CRSE_NUMB = '1003')
			OR (SSBSECT_SUBJ_CODE = 'PSGE' AND SSBSECT_CRSE_NUMB = '1207A')
			OR (SSBSECT_SUBJ_CODE = 'PSOR' AND SSBSECT_CRSE_NUMB = '1301A')
			OR (SSBSECT_SUBJ_CODE = 'PSCL' AND SSBSECT_CRSE_NUMB = '1320')
			OR (SSBSECT_SUBJ_CODE = 'PSGE' AND SSBSECT_CRSE_NUMB = '1320')
			OR (SSBSECT_SUBJ_CODE = 'PSCL' AND SSBSECT_CRSE_NUMB = '1311A')
			OR (SSBSECT_SUBJ_CODE = 'INVE' AND SSBSECT_CRSE_NUMB = '1301')
			OR (SSBSECT_SUBJ_CODE = 'PSCL' AND SSBSECT_CRSE_NUMB = '1302A'))
	GROUP BY SSBSECT_TERM_CODE, SSBSECT_CRN, SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB, SSBSECT_SSTS_CODE, SSBSECT_CAMP_CODE, SSBSECT_MAX_ENRL, SSBSECT_ENRL, SSBSECT_SEATS_AVAIL
	HAVING SSBSECT_MAX_ENRL > COUNT(B.PERSON_UID)
	) C
		LEFT JOIN ODSMGR.COURSE_CATALOG ON SSBSECT_TERM_CODE = ACADEMIC_PERIOD AND SSBSECT_SUBJ_CODE = SUBJECT AND SSBSECT_CRSE_NUMB = COURSE_NUMBER AND STATUS = 'A'
GROUP BY SSBSECT_TERM_CODE, SSBSECT_SUBJ_CODE||SSBSECT_CRSE_NUMB, COALESCE(TITLE_LONG_DESC,TITLE_SHORT_DESC), SSBSECT_CAMP_CODE
ORDER BY SSBSECT_TERM_CODE, SSBSECT_SUBJ_CODE||SSBSECT_CRSE_NUMB
;
