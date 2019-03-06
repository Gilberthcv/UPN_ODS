SELECT DISTINCT
    b.PERSON_UID AS PIDM,  
    d.SPRIDEN_ID AS ID,
    CONCAT ( d.SPRIDEN_LAST_NAME, ', ' || d.SPRIDEN_FIRST_NAME ) AS ESTUDIANTE, 
    b.ACADEMIC_PERIOD AS PERIODO, 
    c.PROGRAM AS COD_PROGRAMA, 
    c.PROGRAM_DESC AS PROGRAMA, 
    c.CAMPUS AS COD_CAMPUS, 
    c.CAMPUS_DESC AS CAMPUS, 
    b.MAX_SECTION_ADD_DATE AS MAX_SECTION_ADD_DATE,
    SUM(e.BALANCE)
        OVER( PARTITION BY
              b.PERSON_UID, 
              b.ACADEMIC_PERIOD ) AS COSTO_PROGRAMA_NETO,
    h.MINIMUM_CHARGE + i.MINIMUM_CHARGE AS COSTO_PROGRAMA_BRUTO
FROM 
    ((((((( SELECT 
        PERSON_UID AS PERSON_UID, 
        ID AS ID, 
        ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
        MAX_SECTION_ADD_DATE AS MAX_SECTION_ADD_DATE,
        TOTAL_CREDITOS AS TOTAL_CREDITOS
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
            MAX(SECTION_ADD_DATE)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS MAX_SECTION_ADD_DATE, 
            COURSE_CREDITS AS COURSE_CREDITS,
            SUM(COURSE_CREDITS)
                OVER( PARTITION BY
                      PERSON_UID, 
                      ACADEMIC_PERIOD ) AS TOTAL_CREDITOS,
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
        PERSON_UID, 
        ID, 
        ACADEMIC_PERIOD, 
        MAX_SECTION_ADD_DATE,
        TOTAL_CREDITOS ) b
        INNER JOIN ACADEMIC_STUDY c ON
            b.PERSON_UID = c.PERSON_UID AND
            b.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD )
        LEFT JOIN LOE_SPRIDEN d ON 
            b.PERSON_UID = d.SPRIDEN_PIDM AND
            d.SPRIDEN_CHANGE_IND IS NULL )
        LEFT JOIN RECEIVABLE_ACCOUNT_DETAIL e ON 
            b.PERSON_UID = e.ACCOUNT_UID AND
            b.ACADEMIC_PERIOD = e.ACADEMIC_PERIOD AND
            SUBSTR(e.DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA','E1','E2') AND
            (SUBSTR(e.CROSSREF_DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA') OR e.CROSSREF_DETAIL_CODE is null) )
        LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV f ON 
            COALESCE( CASE
                        WHEN SUBSTR(e.DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA')
                        THEN SUBSTR(e.DETAIL_CODE, 3, 2)
                        ELSE NULL
                    END,
                    CASE
                        WHEN SUBSTR(e.DETAIL_CODE, 1, 1) = 'E'
                        THEN SUBSTR(e.CROSSREF_DETAIL_CODE, 3, 2)
                        ELSE NULL
                    END) = f.VALUE1 AND 
            f.ESTADO = 'Y' AND
            f.TABLE_PARENT_ID = 17 AND
            (c.PROGRAM = f.VALUE2 OR f.VALUE2 IS NULL ) )
        LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV g ON 
            CASE
                WHEN SUBSTR(e.DETAIL_CODE, 1, 1) = 'E'
                THEN SUBSTR(e.DETAIL_CODE, 3, 2)
                ELSE NULL
            END = g.VALUE1 AND 
            g.ESTADO = 'Y' AND
            g.TABLE_PARENT_ID = 158 AND
            (c.CAMPUS = g.VALUE2 OR g.VALUE2 IS NULL ) )
        LEFT JOIN LOE_REGISTRATION_FEES h ON
            b.ACADEMIC_PERIOD = h.REGISTRATION_TERM AND
            c.PROGRAM = h.PROGRAM AND
            c.CAMPUS = h.CAMP_CODE AND
            (c.STUDENT_POPULATION = h.CURRICULUM_LEARNER_TYPE OR h.CURRICULUM_LEARNER_TYPE IS NULL) AND
            substr(h.DETAIL_CODE, 1, 2) IN ('T1','X1','Y1','Z1') AND
            h.RATE_CODE_CURRICULUM IS NULL AND
            h.STUDENT_ATTRIBUTE_CODE IS NULL AND
            h.MINIMUM_CHARGE >= 0 AND
            h.FROM_CRED_HRS IS NULL AND
            h.TO_CRED_HRS IS NULL )
        LEFT JOIN LOE_REGISTRATION_FEES i ON
            b.ACADEMIC_PERIOD = i.REGISTRATION_TERM AND
            c.PROGRAM = i.PROGRAM AND
            c.CAMPUS = i.CAMP_CODE AND
            (c.STUDENT_POPULATION = i.CURRICULUM_LEARNER_TYPE OR i.CURRICULUM_LEARNER_TYPE IS NULL) AND
            substr(i.DETAIL_CODE, 1, 2) IN ('TA','XA','YA','ZA') AND
            i.RATE_CODE_CURRICULUM IS NULL AND
            i.STUDENT_ATTRIBUTE_CODE IS NULL AND
            i.MINIMUM_CHARGE >= 0 AND
            i.FROM_CRED_HRS = 13 AND
            i.TO_CRED_HRS = 22.999
WHERE 
    c.STUDENT_LEVEL = 'UG' AND --INGRESAR NIVEL
    b.ACADEMIC_PERIOD IN ( '218413', '218512' ); --INGRESAR PERIODO