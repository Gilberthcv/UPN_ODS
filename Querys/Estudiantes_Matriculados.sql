SELECT 
    b.PERSON_UID AS PIDM,  
    g.SPRIDEN_ID AS ID,
    CONCAT ( g.SPRIDEN_LAST_NAME, ', ' || g.SPRIDEN_FIRST_NAME ) AS ESTUDIANTE, 
    b.ACADEMIC_PERIOD AS PERIODO, 
    c.PROGRAM AS COD_PROGRAMA, 
    c.PROGRAM_DESC AS PROGRAMA, 
    c.CAMPUS AS COD_CAMPUS, 
    c.CAMPUS_DESC AS CAMPUS, 
    b.FECHA_REGISTRO_CURSOS AS FECHA_REGISTRO_CURSOS, 
    b.TOTAL_CREDITOS AS TOTAL_CREDITOS, 
    b.NRO_CURSOS AS NRO_CURSOS,
    CASE c.STUDENT_POPULATION
        WHEN 'N'
            THEN CASE 
                    WHEN c.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    ELSE 'NUEVO'
                END
        WHEN 'C'
            THEN CASE 
                    WHEN c.STUDENT_LEVEL = 'UG' AND
                        d.COHORT = 'NEW_REING'
                        THEN 'NUEVO REINGRESO'
                    WHEN c.STUDENT_LEVEL = 'UG' AND
                        d.COHORT = 'REINGRESO'
                        THEN 'REINGRESO'
                    WHEN c.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    WHEN c.ADMISSIONS_POPULATION <> 'RE' AND
                        e.STUDENT_ATTRIBUTE = 'TINT'
                        THEN 'INTERCAMBIO OUT'
                    WHEN f.ACTIVITY = 'ITO' THEN 'INTERCAMBIO OUT'
                    ELSE 'CONTINUO'
                END
        ELSE c.STUDENT_POPULATION
    END AS TIPO_ESTUDIANTE,
    CASE 
        WHEN e.STUDENT_ATTRIBUTE = 'BK18' THEN 'BECA 18'
        ELSE NULL
    END AS BECA_18
FROM 
    ((((( SELECT 
        PERSON_UID AS PERSON_UID, 
        ID AS ID, 
        ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
        FECHA_REGISTRO_CURSOS AS FECHA_REGISTRO_CURSOS,
        TOTAL_CREDITOS AS TOTAL_CREDITOS,
        NRO_CURSOS AS NRO_CURSOS
    FROM 
        ( SELECT
            PERSON_UID AS PERSON_UID, 
            ID AS ID, 
            ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
            COURSE_IDENTIFICATION AS COURSE_IDENTIFICATION, 
            SUBJECT AS SUBJECT, 
            COURSE_NUMBER AS COURSE_NUMBER, 
            COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
            TRANSFER_COURSE_IND AS TRANSFER_COURSE_IND, 
            REGISTRATION_STATUS AS REGISTRATION_STATUS, 
            COURSE_LEVEL AS COURSE_LEVEL, 
            COURSE_TITLE_SHORT AS COURSE_TITLE_SHORT, 
            COURSE_TITLE_LONG AS COURSE_TITLE_LONG, 
            CAMPUS AS CAMPUS, 
            MIN(SECTION_ADD_DATE)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS FECHA_REGISTRO_CURSOS, 
            COURSE_CREDITS AS COURSE_CREDITS,
            SUM(COURSE_CREDITS)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS TOTAL_CREDITOS,
            COUNT(COURSE_REFERENCE_NUMBER)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS NRO_CURSOS,
            MAX( CASE 
                    WHEN SUBJECT = 'XSER' THEN 'XSER'
                    ELSE NULL
                END)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS MATERIA_XSER
        FROM
            STUDENT_COURSE 
        WHERE 
            TRANSFER_COURSE_IND = 'N' AND
            REGISTRATION_STATUS IN ( 
                'RE', 
                'RW', 
                'WC', 
                'RF' ) AND
            COURSE_CREDITS > 0 ) a
    WHERE 
        a.MATERIA_XSER IS NULL 
    GROUP BY 
        a.PERSON_UID, 
        a.ID, 
        a.ACADEMIC_PERIOD, 
        a.FECHA_REGISTRO_CURSOS,
        a.TOTAL_CREDITOS,
        a.NRO_CURSOS) b
        INNER JOIN 
        ACADEMIC_STUDY c ON
            b.PERSON_UID = c.PERSON_UID AND
            b.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD )
        LEFT JOIN 
        STUDENT_COHORT d ON 
            b.PERSON_UID = d.PERSON_UID AND 
            b.ACADEMIC_PERIOD = d.ACADEMIC_PERIOD AND 
            d.COHORT_ACTIVE_IND = 'Y' AND 
            d.COHORT in ( 'NEW_REING', 'REINGRESO' ) )
        LEFT JOIN 
        STUDENT_ATTRIBUTE e ON 
            b.PERSON_UID = e.PERSON_UID AND 
            b.ACADEMIC_PERIOD = e.ACADEMIC_PERIOD AND 
            e.STUDENT_ATTRIBUTE in ( 'TINT', 'BK18', 'ADOS', 'DDOS', 'DLEN', 'DMAT' ) )
        LEFT JOIN 
        STUDENT_ACTIVITY f ON 
            b.PERSON_UID = f.PERSON_UID AND 
            b.ACADEMIC_PERIOD = f.ACADEMIC_PERIOD AND 
            f.ACTIVITY = 'ITO')
        LEFT JOIN 
        LOE_SPRIDEN g ON 
            b.PERSON_UID = g.SPRIDEN_PIDM AND
            g.SPRIDEN_CHANGE_IND IS NULL
WHERE 
    c.STUDENT_LEVEL = 'UG' AND --INGRESAR NIVEL
    b.ACADEMIC_PERIOD IN ('218413') --INGRESAR PERIODO
GROUP BY 
    b.PERSON_UID,  
    g.SPRIDEN_ID,
    CONCAT ( g.SPRIDEN_LAST_NAME, ', ' || g.SPRIDEN_FIRST_NAME ), 
    b.ACADEMIC_PERIOD, 
    c.PROGRAM, 
    c.PROGRAM_DESC, 
    c.CAMPUS, 
    c.CAMPUS_DESC, 
    b.FECHA_REGISTRO_CURSOS, 
    b.TOTAL_CREDITOS, 
    b.NRO_CURSOS,
    CASE c.STUDENT_POPULATION
        WHEN 'N'
            THEN CASE 
                    WHEN c.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    ELSE 'NUEVO'
                END
        WHEN 'C'
            THEN CASE 
                    WHEN c.STUDENT_LEVEL = 'UG' AND
                        d.COHORT = 'NEW_REING'
                        THEN 'NUEVO REINGRESO'
                    WHEN c.STUDENT_LEVEL = 'UG' AND
                        d.COHORT = 'REINGRESO'
                        THEN 'REINGRESO'
                    WHEN c.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    WHEN c.ADMISSIONS_POPULATION <> 'RE' AND
                        e.STUDENT_ATTRIBUTE = 'TINT'
                        THEN 'INTERCAMBIO OUT'
                    WHEN f.ACTIVITY = 'ITO' THEN 'INTERCAMBIO OUT'
                    ELSE 'CONTINUO'
                END
        ELSE c.STUDENT_POPULATION
    END,
    CASE 
        WHEN e.STUDENT_ATTRIBUTE = 'BK18' THEN 'BECA 18'
        ELSE NULL
    END;