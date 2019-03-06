SELECT 
    c.PERSON_UID AS PIDM,  
    g.SPRIDEN_ID AS ID,
    CONCAT ( g.SPRIDEN_LAST_NAME, ', ' || g.SPRIDEN_FIRST_NAME ) AS ESTUDIANTE, 
    c.ACADEMIC_PERIOD AS PERIODO, 
    c.PROGRAM AS COD_PROGRAMA, 
    c.PROGRAM_DESC AS PROGRAMA, 
    c.CAMPUS AS COD_CAMPUS, 
    c.CAMPUS_DESC AS CAMPUS, 
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
    END AS TIPO_ESTUDIANTE
FROM 
    ((( ACADEMIC_STUDY c 
        LEFT JOIN 
        STUDENT_COHORT d ON 
            c.PERSON_UID = d.PERSON_UID AND 
            c.ACADEMIC_PERIOD = d.ACADEMIC_PERIOD AND 
            d.COHORT_ACTIVE_IND = 'Y' AND 
            d.COHORT in ( 'NEW_REING', 'REINGRESO' ) )
        LEFT JOIN 
        STUDENT_ATTRIBUTE e ON 
            c.PERSON_UID = e.PERSON_UID AND 
            c.ACADEMIC_PERIOD = e.ACADEMIC_PERIOD AND 
            e.STUDENT_ATTRIBUTE in ( 'TINT', 'ADOS', 'DDOS', 'DLEN', 'DMAT' ) )
        LEFT JOIN 
        STUDENT_ACTIVITY f ON 
            c.PERSON_UID = f.PERSON_UID AND 
            c.ACADEMIC_PERIOD = f.ACADEMIC_PERIOD AND 
            f.ACTIVITY = 'ITO')
        LEFT JOIN 
        LOE_SPRIDEN g ON 
            c.PERSON_UID = g.SPRIDEN_PIDM AND
            g.SPRIDEN_CHANGE_IND IS NULL
WHERE     
    c.STUDENT_LEVEL = 'UG' AND --INGRESAR NIVEL
    c.ACADEMIC_PERIOD IN ('218413','218512') --INGRESAR PERIODO
    --c.ID = 'N00001877'
GROUP BY 
    c.PERSON_UID,  
    g.SPRIDEN_ID,
    CONCAT ( g.SPRIDEN_LAST_NAME, ', ' || g.SPRIDEN_FIRST_NAME ), 
    c.ACADEMIC_PERIOD, 
    c.PROGRAM, 
    c.PROGRAM_DESC, 
    c.CAMPUS, 
    c.CAMPUS_DESC, 
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
    END;