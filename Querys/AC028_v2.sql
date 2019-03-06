SELECT DISTINCT C.*,  SUM(CASE WHEN g.DUE_DT < SYSDATE THEN g.BAL_AMT ELSE 0 END) OVER(PARTITION BY g.CUST_ID) AS DEUDA
FROM
(
SELECT DISTINCT A.*, B.SHRTGPA_GPA, B.SHRTGPA_GPA_HOURS, MAX(B.SHRTGPA_GPA) OVER (PARTITION BY A.PROGRAM, A.CAMPUS) AS GPA_PROGRAM
FROM
(
SELECT DISTINCT 
    "Consulta1"."PERSON_UID" AS "PERSON_UID", 
    "Consulta1"."ID" AS "ID", 
    "Consulta1"."NAME" AS "NAME", 
    "Consulta1"."STUDENT_LEVEL" AS "STUDENT_LEVEL", 
    "Consulta1"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
    "Consulta1"."CAMPUS" AS "CAMPUS", 
    "Consulta1"."PROGRAM" AS "PROGRAM", 
    "Consulta1"."PROGRAM_DESC" AS "PROGRAM_DESC", 
    "Consulta1"."TOTAL_CREDITOS_INSCRITOS" AS "TOTAL_CREDITOS_INSCRITOS"
FROM
    (
    SELECT DISTINCT 
        "Academic_Study_P"."PERSON_UID" AS "PERSON_UID", 
        "Academic_Study_P"."ID" AS "ID", 
        "Academic_Study_P"."NAME" AS "NAME", 
        "Academic_Study_P"."STUDENT_LEVEL" AS "STUDENT_LEVEL", 
        "Academic_Study_P"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
        "Academic_Study_P"."CAMPUS" AS "CAMPUS", 
        "Academic_Study_P"."PROGRAM" AS "PROGRAM", 
        "Academic_Study_P"."PROGRAM_DESC" AS "PROGRAM_DESC", 
        "STU_COURSE_P1"."TOTAL_CREDITOS_INSCRITOS" AS "TOTAL_CREDITOS_INSCRITOS"
    FROM
        (
        SELECT DISTINCT
            "RSF_Academic_Study_P"."PERSON_UID" AS "PERSON_UID", 
            "RSF_Academic_Study_P"."ID" AS "ID", 
            "RSF_Academic_Study_P"."NAME" AS "NAME", 
            "RSF_Academic_Study_P"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
            "RSF_Academic_Study_P"."PROGRAM" AS "PROGRAM", 
            "RSF_Academic_Study_P"."PROGRAM_DESC" AS "PROGRAM_DESC", 
            "RSF_Academic_Study_P"."CAMPUS" AS "CAMPUS", 
            "RSF_Academic_Study_P"."STUDENT_LEVEL" AS "STUDENT_LEVEL"
        FROM
            (
            SELECT DISTINCT
                "ACADEMIC_STUDY"."PERSON_UID" AS "PERSON_UID", 
                "ACADEMIC_STUDY"."ID" AS "ID", 
                "ACADEMIC_STUDY"."NAME" AS "NAME", 
                "ACADEMIC_STUDY"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
                "ACADEMIC_STUDY"."PROGRAM" AS "PROGRAM", 
                "ACADEMIC_STUDY"."PROGRAM_DESC" AS "PROGRAM_DESC", 
                "ACADEMIC_STUDY"."CAMPUS" AS "CAMPUS", 
                "ACADEMIC_STUDY"."STUDENT_LEVEL" AS "STUDENT_LEVEL", 
                MIN("ACADEMIC_STUDY"."STUDENT_LEVEL") AS "Min1", 
                MIN("ACADEMIC_STUDY"."ACADEMIC_PERIOD") AS "Min11"
            FROM
                "ODSMGR"."ACADEMIC_STUDY" "ACADEMIC_STUDY" 
            GROUP BY 
                "ACADEMIC_STUDY"."PERSON_UID", 
                "ACADEMIC_STUDY"."ID", 
                "ACADEMIC_STUDY"."NAME", 
                "ACADEMIC_STUDY"."ACADEMIC_PERIOD", 
                "ACADEMIC_STUDY"."PROGRAM", 
                "ACADEMIC_STUDY"."PROGRAM_DESC", 
                "ACADEMIC_STUDY"."CAMPUS", 
                "ACADEMIC_STUDY"."STUDENT_LEVEL"
            ) "RSF_Academic_Study_P" 
        WHERE 
            "RSF_Academic_Study_P"."Min1" = 'UG' AND
            "RSF_Academic_Study_P"."Min11" = '218512'
        ) "Academic_Study_P"
            INNER JOIN 
            (
            SELECT DISTINCT
                "RSF_STU_COURSE_P1"."PERSON_UID" AS "PERSON_UID", 
                "RSF_STU_COURSE_P1"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
                "RSF_STU_COURSE_P1"."COURSE_REFERENCE_NUMBER" AS "COURSE_REFERENCE_NUMBER", 
                "RSF_STU_COURSE_P1"."REGISTRATION_STATUS" AS "REGISTRATION_STATUS", 
                "RSF_STU_COURSE_P1"."DD" AS "DD", 
                "RSF_STU_COURSE_P1"."COURSE_CREDITS" AS "COURSE_CREDITS", 
                "RSF_STU_COURSE_P1"."TOTAL_CREDITOS_INSCRITOS" AS "TOTAL_CREDITOS_INSCRITOS", 
                "RSF_STU_COURSE_P1"."MATERIA_XSER" AS "MATERIA_XSER", 
                "RSF_STU_COURSE_P1"."SUBJECT" AS "SUBJECT", 
                "RSF_STU_COURSE_P1"."TRANSFER_COURSE_IND" AS "TRANSFER_COURSE_IND"
            FROM
                (
                SELECT DISTINCT
                    "SQ0_STU_COURSE_P1"."PERSON_UID" AS "PERSON_UID", 
                    "SQ0_STU_COURSE_P1"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
                    "SQ0_STU_COURSE_P1"."COURSE_REFERENCE_NUMBER" AS "COURSE_REFERENCE_NUMBER", 
                    "SQ0_STU_COURSE_P1"."REGISTRATION_STATUS" AS "REGISTRATION_STATUS", 
                    "SQ0_STU_COURSE_P1"."DD" AS "DD", 
                    "SQ0_STU_COURSE_P1"."COURSE_CREDITS" AS "COURSE_CREDITS", 
                    "SQ0_STU_COURSE_P1"."TOTAL_CREDITOS_INSCRITOS" AS "TOTAL_CREDITOS_INSCRITOS", 
                    "SQ0_STU_COURSE_P1"."MATERIA_XSER" AS "MATERIA_XSER", 
                    "SQ0_STU_COURSE_P1"."SUBJECT" AS "SUBJECT", 
                    "SQ0_STU_COURSE_P1"."TRANSFER_COURSE_IND" AS "TRANSFER_COURSE_IND", 
                    "SQ0_STU_COURSE_P1"."Min1" AS "Min1", 
                    MAX("SQ0_STU_COURSE_P1"."Max1")
                        OVER(
                            PARTITION BY
                                "SQ0_STU_COURSE_P1"."PERSON_UID", 
                                "SQ0_STU_COURSE_P1"."ACADEMIC_PERIOD"
                        ) AS "Max1", 
                    "SQ0_STU_COURSE_P1"."Max1" AS "Max11"
                FROM
                    (
                    SELECT DISTINCT
                        "D1"."C0" AS "PERSON_UID", 
                        "D1"."C1" AS "ACADEMIC_PERIOD", 
                        "D1"."C2" AS "COURSE_REFERENCE_NUMBER", 
                        "D1"."C3" AS "REGISTRATION_STATUS", 
                        "D1"."C4" AS "DD", 
                        "D1"."C5" AS "COURSE_CREDITS", 
                        "D1"."C6" AS "TOTAL_CREDITOS_INSCRITOS", 
                        "D1"."C7" AS "MATERIA_XSER", 
                        "D1"."C8" AS "SUBJECT", 
                        "D1"."C9" AS "TRANSFER_COURSE_IND", 
                        MIN("D1"."C1") AS "Min1", 
                        MAX("D1"."C10") AS "Max1"
                    FROM
                        (
                        SELECT DISTINCT
                            "STUDENT_COURSE"."PERSON_UID" AS "C0", 
                            "STUDENT_COURSE"."ACADEMIC_PERIOD" AS "C1", 
                            "STUDENT_COURSE"."COURSE_REFERENCE_NUMBER" AS "C2", 
                            "STUDENT_COURSE"."REGISTRATION_STATUS" AS "C3", 
                            CASE 
                                WHEN 
                                    "STUDENT_COURSE"."REGISTRATION_STATUS" IN ( 
                                        'DD', 
                                        'DW' )
                                    THEN
                                        'N'
                                ELSE 'Y'
                            END AS "C4", 
                            "STUDENT_COURSE"."COURSE_CREDITS" AS "C5", 
                            SUM("STUDENT_COURSE"."COURSE_CREDITS")
                                OVER(
                                    PARTITION BY
                                        "STUDENT_COURSE"."PERSON_UID", 
                                        "STUDENT_COURSE"."ACADEMIC_PERIOD"
                                ) AS "C6", 
                            MAX(
                                CASE 
                                    WHEN "STUDENT_COURSE"."SUBJECT" = 'XSER' THEN 'XSER'
                                    ELSE NULL
                                END)
                                OVER(
                                    PARTITION BY
                                        "STUDENT_COURSE"."PERSON_UID", 
                                        "STUDENT_COURSE"."ACADEMIC_PERIOD"
                                ) AS "C7", 
                            "STUDENT_COURSE"."SUBJECT" AS "C8", 
                            "STUDENT_COURSE"."TRANSFER_COURSE_IND" AS "C9", 
                            CASE 
                                WHEN "STUDENT_COURSE"."SUBJECT" = 'XSER' THEN 'XSER'
                                ELSE NULL
                            END AS "C10"
                        FROM
                            "ODSMGR"."STUDENT_COURSE" "STUDENT_COURSE" 
                        WHERE 
                            CASE 
                                WHEN 
                                    "STUDENT_COURSE"."REGISTRATION_STATUS" IN ( 
                                        'DD', 
                                        'DW' )
                                    THEN
                                        'N'
                                ELSE 'Y'
                            END = 'Y' AND
                            "STUDENT_COURSE"."REGISTRATION_STATUS" IN ( 
                                'RE', 
                                'RW', 
                                'WC', 
                                'RF', 
                                'IA', 
                                'RA', 
                                'RO' ) AND
                            "STUDENT_COURSE"."TRANSFER_COURSE_IND" = 'N'
                        ) "D1" 
                    GROUP BY 
                        "D1"."C0", 
                        "D1"."C1", 
                        "D1"."C2", 
                        "D1"."C3", 
                        "D1"."C4", 
                        "D1"."C5", 
                        "D1"."C6", 
                        "D1"."C7", 
                        "D1"."C8", 
                        "D1"."C9"
                    ) "SQ0_STU_COURSE_P1"
                ) "RSF_STU_COURSE_P1" 
            WHERE 
                "RSF_STU_COURSE_P1"."Min1" = '218512' AND
                "RSF_STU_COURSE_P1"."Max1" IS NULL
            ) "STU_COURSE_P1"
            ON 
                "Academic_Study_P"."PERSON_UID" = "STU_COURSE_P1"."PERSON_UID" AND
                "Academic_Study_P"."ACADEMIC_PERIOD" = "STU_COURSE_P1"."ACADEMIC_PERIOD"
    ) "Consulta1"
        LEFT OUTER JOIN 
        (
        SELECT DISTINCT 
            "FIELD_OF_STUDY"."PERSON_UID" AS "PERSON_UID", 
            "FIELD_OF_STUDY"."ID" AS "ID", 
            "FIELD_OF_STUDY"."SOURCE" AS "SOURCE", 
            "FIELD_OF_STUDY"."CURRICULUM_PRIORITY" AS "CURRICULUM_PRIORITY", 
            "FIELD_OF_STUDY"."STUDENT_LEVEL" AS "STUDENT_LEVEL", 
            "FIELD_OF_STUDY"."STUDENT_LEVEL_DESC" AS "STUDENT_LEVEL_DESC", 
            "FIELD_OF_STUDY"."PROGRAM" AS "PROGRAM", 
            "FIELD_OF_STUDY"."PROGRAM_DESC" AS "PROGRAM_DESC", 
            "FIELD_OF_STUDY"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
            "FIELD_OF_STUDY"."CAMPUS" AS "CAMPUS", 
            "FIELD_OF_STUDY"."CAMPUS_DESC" AS "CAMPUS_DESC", 
            "FIELD_OF_STUDY"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD_EGRESO", 
            "FIELD_OF_STUDY"."NAME" AS "NAME", 
            "FIELD_OF_STUDY"."CURRICULUM_CURRENT_IND" AS "CURRICULUM_CURRENT_IND", 
            "FIELD_OF_STUDY"."CURRICULUM_ACTIVE_IND" AS "CURRICULUM_ACTIVE_IND", 
            "FIELD_OF_STUDY"."CURRICULUM_CHANGE_REASON" AS "CURRICULUM_CHANGE_REASON", 
            MAX("FIELD_OF_STUDY"."ACADEMIC_PERIOD")
                OVER(
                    PARTITION BY
                        "FIELD_OF_STUDY"."PERSON_UID", 
                        "FIELD_OF_STUDY"."PROGRAM", 
                        "FIELD_OF_STUDY"."CURRICULUM_CHANGE_REASON"
                ) AS "PERIODO_CALCULADO"
        FROM
            "ODSMGR"."FIELD_OF_STUDY" "FIELD_OF_STUDY" 
        WHERE 
            "FIELD_OF_STUDY"."SOURCE" = 'OUTCOME' AND
            "FIELD_OF_STUDY"."CURRICULUM_CHANGE_REASON" = 'EGRESADO' AND
            "FIELD_OF_STUDY"."STUDENT_LEVEL" = 'UG'
        ) "FOS_EGRESADO"
        ON 
            "Consulta1"."PERSON_UID" = "FOS_EGRESADO"."PERSON_UID" AND
            "Consulta1"."PROGRAM" = "FOS_EGRESADO"."PROGRAM" 
WHERE 
    CASE 
        WHEN "FOS_EGRESADO"."PERSON_UID" IS NULL THEN 'Y'
        ELSE 'N'
    END = 'Y'

)A
INNER JOIN 
(
SELECT
    "RSF_LOE_SHRTGPA2"."SHRTGPA_TERM_CODE" AS "SHRTGPA_TERM_CODE", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_PIDM" AS "SHRTGPA_PIDM", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_ACTIVITY_DATE" AS "SHRTGPA_ACTIVITY_DATE", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_LEVL_CODE" AS "SHRTGPA_LEVL_CODE", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_TRIT_SEQ_NO" AS "SHRTGPA_TRIT_SEQ_NO", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_TRAM_SEQ_NO" AS "SHRTGPA_TRAM_SEQ_NO", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_GPA_TYPE_IND" AS "SHRTGPA_GPA_TYPE_IND", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_HOURS_ATTEMPTED" AS "SHRTGPA_HOURS_ATTEMPTED", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_HOURS_EARNED" AS "SHRTGPA_HOURS_EARNED", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_QUALITY_POINTS" AS "SHRTGPA_QUALITY_POINTS", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_HOURS_PASSED" AS "SHRTGPA_HOURS_PASSED", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_GPA_HOURS" AS "SHRTGPA_GPA_HOURS", 
    "RSF_LOE_SHRTGPA2"."SHRTGPA_GPA" AS "SHRTGPA_GPA"
FROM
    (
    SELECT
        "LOE_SHRTGPA"."SHRTGPA_TERM_CODE" AS "SHRTGPA_TERM_CODE", 
        "LOE_SHRTGPA"."SHRTGPA_PIDM" AS "SHRTGPA_PIDM", 
        "LOE_SHRTGPA"."SHRTGPA_ACTIVITY_DATE" AS "SHRTGPA_ACTIVITY_DATE", 
        "LOE_SHRTGPA"."SHRTGPA_LEVL_CODE" AS "SHRTGPA_LEVL_CODE", 
        "LOE_SHRTGPA"."SHRTGPA_TRIT_SEQ_NO" AS "SHRTGPA_TRIT_SEQ_NO", 
        "LOE_SHRTGPA"."SHRTGPA_TRAM_SEQ_NO" AS "SHRTGPA_TRAM_SEQ_NO", 
        "LOE_SHRTGPA"."SHRTGPA_GPA_TYPE_IND" AS "SHRTGPA_GPA_TYPE_IND", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_ATTEMPTED" AS "SHRTGPA_HOURS_ATTEMPTED", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_EARNED" AS "SHRTGPA_HOURS_EARNED", 
        "LOE_SHRTGPA"."SHRTGPA_QUALITY_POINTS" AS "SHRTGPA_QUALITY_POINTS", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_PASSED" AS "SHRTGPA_HOURS_PASSED", 
        "LOE_SHRTGPA"."SHRTGPA_GPA_HOURS" AS "SHRTGPA_GPA_HOURS", 
        ROUND("LOE_SHRTGPA"."SHRTGPA_GPA", 2) AS "SHRTGPA_GPA", 
        MIN("LOE_SHRTGPA"."SHRTGPA_GPA_TYPE_IND") AS "Min1"
    FROM
        "ODSMGR"."LOE_SHRTGPA" "LOE_SHRTGPA" 
    WHERE 
        "LOE_SHRTGPA"."SHRTGPA_TERM_CODE" = '218512' AND
        "LOE_SHRTGPA"."SHRTGPA_GPA_HOURS" >= 20 AND
        ROUND("LOE_SHRTGPA"."SHRTGPA_GPA", 2) >= 12 
    GROUP BY 
        "LOE_SHRTGPA"."SHRTGPA_TERM_CODE", 
        "LOE_SHRTGPA"."SHRTGPA_PIDM", 
        "LOE_SHRTGPA"."SHRTGPA_ACTIVITY_DATE", 
        "LOE_SHRTGPA"."SHRTGPA_LEVL_CODE", 
        "LOE_SHRTGPA"."SHRTGPA_TRIT_SEQ_NO", 
        "LOE_SHRTGPA"."SHRTGPA_TRAM_SEQ_NO", 
        "LOE_SHRTGPA"."SHRTGPA_GPA_TYPE_IND", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_ATTEMPTED", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_EARNED", 
        "LOE_SHRTGPA"."SHRTGPA_QUALITY_POINTS", 
        "LOE_SHRTGPA"."SHRTGPA_HOURS_PASSED", 
        "LOE_SHRTGPA"."SHRTGPA_GPA_HOURS", 
        ROUND("LOE_SHRTGPA"."SHRTGPA_GPA", 2)
    ) "RSF_LOE_SHRTGPA2" 
WHERE 
    "RSF_LOE_SHRTGPA2"."Min1" = 'I' 
)B ON A.PERSON_UID = B.SHRTGPA_PIDM AND A.ACADEMIC_PERIOD = B.SHRTGPA_TERM_CODE
)C 
LEFT JOIN PS_ITEM g ON
 C.ID = g.CUST_ID
 AND g.BUSINESS_UNIT = 'PER03'
where C.SHRTGPA_GPA = C.GPA_PROGRAM
ORDER BY 6,7;