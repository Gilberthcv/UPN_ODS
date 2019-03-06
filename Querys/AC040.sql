SELECT DISTINCT
    a.PERSON_UID AS PIDM, a.ID AS ID_ESTUDIANTE, a.NAME AS NOMBRE_ESTUDIANTE, a.ACADEMIC_PERIOD AS PERIODO
    , CASE
          WHEN MIN(CASE WHEN b.ACADEMIC_PERIOD_ADMITTED IS NULL THEN '999999' ELSE b.ACADEMIC_PERIOD_ADMITTED END)
                  OVER(PARTITION BY b.PERSON_UID,b.STUDENT_LEVEL) = '999999' THEN NULL
      ELSE MIN(CASE WHEN b.ACADEMIC_PERIOD_ADMITTED IS NULL THEN '999999' ELSE b.ACADEMIC_PERIOD_ADMITTED END)
              OVER(PARTITION BY b.PERSON_UID,b.STUDENT_LEVEL) END AS PERIODO_INGRESO
    , b.PROGRAM AS COD_PROGRAMA, b.PROGRAM_DESC AS PROGRAMA, a.SUBJECT || a.COURSE_NUMBER AS COD_CURSO, a.COURSE_REFERENCE_NUMBER AS NRC
    , NVL(a.COURSE_TITLE_LONG,a.COURSE_TITLE_SHORT) AS CURSO, a.SECTION_ADD_DATE AS FECHA, a.CAMPUS AS COD_CAMPUS, a.CAMPUS_DESC AS CAMPUS
FROM STUDENT_COURSE a, ACADEMIC_STUDY b
WHERE a.PERSON_UID = b.PERSON_UID AND a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD AND b.STUDENT_LEVEL = 'UG'
    AND a.TRANSFER_COURSE_IND = 'N' AND a.REGISTRATION_STATUS IN ('RE','RW','RA') AND a.ACADEMIC_PERIOD IN ('218413','218434','218512','218533')
ORDER BY 4,6,1;
