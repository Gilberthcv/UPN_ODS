
SELECT DISTINCT
    a.PERSON_UID, f.ID, CONCAT(f.LAST_NAME,CONCAT(', ',f.FIRST_NAME)) AS NOMBRE_ESTUDIANTE
    , a.ACADEMIC_PERIOD, a.PROGRAM, a.PROGRAM_DESC, a.CAMPUS_DESC
    , MIN(b.SECTION_ADD_DATE) OVER(PARTITION BY b.PERSON_UID,b.ACADEMIC_PERIOD) AS FECHA_REGISTRO_CURSOS
    , CASE a.STUDENT_POPULATION
          WHEN 'N'
              THEN CASE 
                      WHEN a.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                      ELSE 'NUEVO'
                  END
          WHEN 'C'
              THEN CASE 
                      WHEN a.STUDENT_LEVEL = 'UG' AND
                          c.COHORT = 'NEW_REING'
                          THEN 'NUEVO REINGRESO'
                      WHEN a.STUDENT_LEVEL = 'UG' AND
                          c.COHORT = 'REINGRESO'
                          THEN 'REINGRESO'
                      WHEN a.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                      WHEN a.ADMISSIONS_POPULATION <> 'RE' AND
                          d.STUDENT_ATTRIBUTE = 'TINT'
                          THEN 'INTERCAMBIO OUT'
                      WHEN e.ACTIVITY = 'ITO' THEN 'INTERCAMBIO OUT'
                      ELSE 'CONTINUO'
                  END
          ELSE a.STUDENT_POPULATION
      END AS TIPO_ESTUDIANTE
    , SUM(b.COURSE_CREDITS) OVER(PARTITION BY b.PERSON_UID,b.ACADEMIC_PERIOD) AS CREDITOS
    , COUNT(b.COURSE_REFERENCE_NUMBER) OVER(PARTITION BY b.PERSON_UID,b.ACADEMIC_PERIOD) AS CURSOS
FROM ACADEMIC_STUDY a, 
     STUDENT_COURSE b, 
     STUDENT_COHORT c, 
     STUDENT_ATTRIBUTE d, 
     STUDENT_ACTIVITY e, 
     PERSON_DETAIL f
WHERE a.PERSON_UID = b.PERSON_UID AND a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD    
        AND b.TRANSFER_COURSE_IND = 'N' AND b.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF')
    AND a.PERSON_UID = c.PERSON_UID(+) AND a.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD(+)
        AND c.COHORT_ACTIVE_IND(+) = 'Y' AND c.COHORT(+) IN ('NEW_REING','REINGRESO')
    AND a.PERSON_UID = d.PERSON_UID(+) AND a.ACADEMIC_PERIOD = d.ACADEMIC_PERIOD(+)
        AND d.STUDENT_ATTRIBUTE(+) IN ('TINT','ADOS','DDOS','DLEN','DMAT')
    AND a.PERSON_UID = e.PERSON_UID(+) AND a.ACADEMIC_PERIOD = e.ACADEMIC_PERIOD(+)
        AND e.ACTIVITY(+) = 'ITO'
    AND a.PERSON_UID = f.PERSON_UID
    AND a.ENROLLMENT_STATUS IN ('EL','RF','RO','SE') AND a.STUDENT_LEVEL = 'UG' AND a.ACADEMIC_PERIOD IN ('219402','219501');