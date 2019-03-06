
SELECT DISTINCT
    a.PERSON_UID, a.ID, a.NAME, a.ACADEMIC_PERIOD, a.PROGRAM, a.PROGRAM_DESC
    , a.STUDENT_LEVEL, a.CAMPUS_DESC, a.ENROLLMENT_STATUS
    , COUNT(b.SFRSTCR_CRN) OVER(PARTITION BY b.SFRSTCR_PIDM,b.SFRSTCR_TERM_CODE) AS CURSOS_PENDIENTES
FROM ACADEMIC_STUDY a, 
     SFRSTCR b
WHERE a.PERSON_UID = b.SFRSTCR_PIDM(+) AND a.ACADEMIC_PERIOD = b.SFRSTCR_TERM_CODE(+)
    AND a.STUDENT_LEVEL IN ('EC','MA') AND a.ENROLLMENT_STATUS = 'RF' AND b.SFRSTCR_RSTS_CODE(+) IN ('RF','IA');
