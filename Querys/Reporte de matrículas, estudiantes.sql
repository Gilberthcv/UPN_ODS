SELECT DISTINCT
    a.PERSON_UID AS PIDM, 
    d.SPRIDEN_ID AS CODBANNER, 
    d.SPRIDEN_FIRST_NAME AS NOMBRES, 
    d.SPRIDEN_LAST_NAME AS APELLIDOS, 
    a.REGISTRATION_STATUS_DESC ESTADO, 
    a.ACADEMIC_PERIOD PERIODO, 
    a.CAMPUS_DESC AS CAMPUS, 
    a.SUBJECT AS MATER, 
    a.COURSE_NUMBER AS CURSO, 
    a.COURSE_REFERENCE_NUMBER AS NRC, 
    NVL(a.COURSE_TITLE_LONG,a.COURSE_TITLE_SHORT) AS NOMBRE_CURSO
FROM 
    ((STUDENT_COURSE a
        INNER JOIN MEETING_TIME b ON
            a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD AND
            a.COURSE_REFERENCE_NUMBER = b.COURSE_REFERENCE_NUMBER)
        INNER JOIN SCHEDULE_OFFERING c ON
            a.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD AND
            a.COURSE_REFERENCE_NUMBER = c.COURSE_REFERENCE_NUMBER)
        LEFT JOIN LOE_SPRIDEN d ON
            a.PERSON_UID = d.SPRIDEN_PIDM AND
            d.SPRIDEN_CHANGE_IND IS NULL
WHERE 
    b.SCHEDULE = 'VIR' AND
    c.STATUS = 'A'
    AND a.ACADEMIC_PERIOD IN ('218413','218512') --INGRESAR PERIODO
ORDER BY a.ACADEMIC_PERIOD DESC, a.PERSON_UID;