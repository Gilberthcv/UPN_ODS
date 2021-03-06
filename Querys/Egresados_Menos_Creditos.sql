SELECT DISTINCT
	a.PERSON_UID, a.ID, a.NAME, MAX(a.ACADEMIC_PERIOD) OVER(PARTITION BY a.PERSON_UID,a.STUDENT_LEVEL,a.PROGRAM) AS PERIODO_EGRESO, a.CATALOG_ACADEMIC_PERIOD
    , a.STUDENT_LEVEL, a.CAMPUS, a.PROGRAM, a.PROGRAM_DESC, b.SEQUENCE_NUMBER, b.TERM_CODE_CATLG, b.ACT_CREDITS_OVERALL
	, b.ACTIVITY_DATE, d.USER_ID, c.SEQUENCE_NUMBER, c.TERM_CODE_CATLG, c.ACT_CREDITS_OVERALL, c.ACTIVITY_DATE, e.USER_ID
FROM FIELD_OF_STUDY a, LOE_PROGRAM_OVERALL_RESULTS b, LOE_PROGRAM_OVERALL_RESULTS c, LOE_COMPLIANCE_REQU_MANAGEMENT d, LOE_COMPLIANCE_REQU_MANAGEMENT e
WHERE a.PERSON_UID = b.PERSON_UID AND a.STUDENT_LEVEL = b.LEVL_CODE AND a.PROGRAM = b.PROGRAM
	AND b.ACT_CREDITS_OVERALL = (SELECT MAX(b1.ACT_CREDITS_OVERALL) FROM LOE_PROGRAM_OVERALL_RESULTS b1
									WHERE b.PERSON_UID = b1.PERSON_UID AND b.LEVL_CODE = b1.LEVL_CODE AND b.PROGRAM = b1.PROGRAM)
	AND a.PERSON_UID = c.PERSON_UID AND a.STUDENT_LEVEL = c.LEVL_CODE AND a.PROGRAM = c.PROGRAM
	AND c.SEQUENCE_NUMBER = (SELECT MAX(c1.SEQUENCE_NUMBER) FROM LOE_PROGRAM_OVERALL_RESULTS c1
									WHERE c.PERSON_UID = c1.PERSON_UID AND c.LEVL_CODE = c1.LEVL_CODE AND c.PROGRAM = c1.PROGRAM)
    AND b.PERSON_UID = d.PERSON_UID(+) AND b.SEQUENCE_NUMBER = d.REQUEST_NO(+)
    AND c.PERSON_UID = e.PERSON_UID(+) AND c.SEQUENCE_NUMBER = e.REQUEST_NO(+)
	AND a.SOURCE = 'OUTCOME' AND a.CURRICULUM_CHANGE_REASON = 'EGRESADO' AND b.ACT_CREDITS_OVERALL > c.ACT_CREDITS_OVERALL;