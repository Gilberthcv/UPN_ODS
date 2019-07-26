SELECT
    "SQ0_Q1__BNR_BASE"."C_______Academic_Study_______" AS "C_______Academic_Study_", 
    "SQ0_Q1__BNR_BASE"."PERSON_UID" AS "PERSON_UID", 
    "SQ0_Q1__BNR_BASE"."ID" AS "ID", 
    "SQ0_Q1__BNR_BASE"."NAME" AS "NAME", 
    "SQ0_Q1__BNR_BASE"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD", 
    "SQ0_Q1__BNR_BASE"."CAMPUS" AS "CAMPUS", 
    "SQ0_Q1__BNR_BASE"."STUDENT_LEVEL" AS "STUDENT_LEVEL", 
    "SQ0_Q1__BNR_BASE"."PROGRAM" AS "PROGRAM", 
    "SQ0_Q1__BNR_BASE"."PROGRAM_DESC" AS "PROGRAM_DESC", 
    "SQ0_Q1__BNR_BASE"."ENROLLMENT_STATUS" AS "ENROLLMENT_STATUS", 
    "SQ0_Q1__BNR_BASE"."ADMISSIONS_POPULATION" AS "ADMISSIONS_POPULATION", 
    "SQ0_Q1__BNR_BASE"."ADMISSIONS_POPULATION_DESC" AS "ADMISSIONS_POPULATION_DESC", 
    "SQ0_Q1__BNR_BASE"."ACADEMIC_PERIOD_ADMITTED" AS "ACADEMIC_PERIOD_ADMITTED", 
    "SQ0_Q1__BNR_BASE"."STUDENT_POPULATION" AS "STUDENT_POPULATION", 
    "SQ0_Q1__BNR_BASE"."c__ADMISSIONS_POPULATION" AS "c__ADMISSIONS_POPULATION", 
    "SQ0_Q1__BNR_BASE"."C_______Academic_Study_______" AS "C_Student_Activity_", 
    "SQ0_Q1__BNR_BASE"."ACTIVITY" AS "ACTIVITY", 
    "SQ0_Q1__BNR_BASE"."ACTIVITY_DESC" AS "ACTIVITY_DESC", 
    "SQ0_Q1__BNR_BASE"."C_______Academic_Study_______" AS "C_Student_Course_", 
    COALESCE(
        SUM("SQ0_Q1__BNR_BASE"."Sum1")
            OVER(
                PARTITION BY
                    "SQ0_Q1__BNR_BASE"."PERSON_UID"
            ), 
        0) AS "c__BILLING_CREDITS", 
    MIN("SQ0_Q1__BNR_BASE"."Min1")
        OVER(
            PARTITION BY
                "SQ0_Q1__BNR_BASE"."PERSON_UID"
        ) AS "c__REGISTRATION_STATUS_DATE", 
    "SQ0_Q1__BNR_BASE"."C_______Academic_Study_______" AS "C_Student_Course_reg_audit_", 
    "SQ0_Q1__BNR_BASE"."C_______Academic_Study_______" AS "C_Enrollment_", 
    "SQ0_Q1__BNR_BASE"."TOTAL_CREDITS" AS "TOTAL_CREDITS", 
    "SQ0_Q1__BNR_BASE"."ENROLLMENT_ADD_DATE" AS "ENROLLMENT_ADD_DATE", 
    "SQ0_Q1__BNR_BASE"."ENROLLMENT_STATUS1" AS "ENROLLMENT_STATUS1", 
    "SQ0_Q1__BNR_BASE"."ENROLLMENT_STATUS_DATE" AS "ENROLLMENT_STATUS_DATE", 
    "SQ0_Q1__BNR_BASE"."c__REGISTERED_IND" AS "c__REGISTERED_IND"
FROM
    (
    SELECT
        '' AS "C_______Academic_Study_______", 
        "D1"."C0" AS "PERSON_UID", 
        "D1"."C1" AS "ID", 
        "D1"."C2" AS "NAME", 
        "D1"."C3" AS "ACADEMIC_PERIOD", 
        "D1"."C4" AS "CAMPUS", 
        "D1"."C5" AS "STUDENT_LEVEL", 
        "D1"."C6" AS "PROGRAM", 
        "D1"."C7" AS "PROGRAM_DESC", 
        "D1"."C8" AS "ENROLLMENT_STATUS", 
        "D1"."C9" AS "ADMISSIONS_POPULATION", 
        "D1"."C10" AS "ADMISSIONS_POPULATION_DESC", 
        "D1"."C11" AS "ACADEMIC_PERIOD_ADMITTED", 
        "D1"."C12" AS "STUDENT_POPULATION", 
        "D1"."C13" AS "c__ADMISSIONS_POPULATION", 
        "D1"."C14" AS "ACTIVITY", 
        "D1"."C15" AS "ACTIVITY_DESC", 
        "D1"."C16" AS "TOTAL_CREDITS", 
        "D1"."C17" AS "ENROLLMENT_ADD_DATE", 
        "D1"."C18" AS "ENROLLMENT_STATUS1", 
        "D1"."C19" AS "ENROLLMENT_STATUS_DATE", 
        "D1"."C20" AS "c__REGISTERED_IND", 
        SUM("D1"."C21") AS "Sum1", 
        MIN("D1"."C22") AS "Min1"
    FROM
        (
        SELECT
            "Academic_Study"."PERSON_UID" AS "C0", 
            "Academic_Study"."ID" AS "C1", 
            "Academic_Study"."NAME" AS "C2", 
            "Academic_Study"."ACADEMIC_PERIOD" AS "C3", 
            "Academic_Study"."CAMPUS" AS "C4", 
            "Academic_Study"."STUDENT_LEVEL" AS "C5", 
            "Academic_Study"."PROGRAM" AS "C6", 
            "Academic_Study"."PROGRAM_DESC" AS "C7", 
            "Academic_Study"."ENROLLMENT_STATUS" AS "C8", 
            "Academic_Study"."ADMISSIONS_POPULATION" AS "C9", 
            "Academic_Study"."ADMISSIONS_POPULATION_DESC" AS "C10", 
            "Academic_Study"."ACADEMIC_PERIOD_ADMITTED" AS "C11", 
            "Academic_Study"."STUDENT_POPULATION" AS "C12", 
            "Academic_Study"."ADMISSIONS_POPULATION_DESC" || '(' || "Academic_Study"."ADMISSIONS_POPULATION" || ')' AS "C13", 
            "Student_Activity"."ACTIVITY" AS "C14", 
            "Student_Activity"."ACTIVITY_DESC" AS "C15", 
            "Enrollment"."TOTAL_CREDITS" AS "C16", 
            "Enrollment"."ENROLLMENT_ADD_DATE" AS "C17", 
            "Enrollment"."ENROLLMENT_STATUS" AS "C18", 
            "Enrollment"."ENROLLMENT_STATUS_DATE" AS "C19", 
            CASE 
                WHEN "Enrollment"."REGISTERED_IND" = 'Y' THEN 'S'
                ELSE 'N'
            END AS "C20", 
            "Student_Course"."COURSE_BILLING_CREDITS" AS "C21", 
            "Student_Course"."SECTION_ADD_DATE" AS "C22"
        FROM
            (
            SELECT
                "STUDENT"."PERSON_UID" AS "PERSON_UID", 
                "STUDENT"."ACADEMIC_PERIOD" AS "ACADEMIC_PERIOD"
            FROM
                "ODSMGR"."STUDENT" "STUDENT" 
            GROUP BY 
                "STUDENT"."PERSON_UID", 
                "STUDENT"."ACADEMIC_PERIOD"
            ) "Student0"
                INNER JOIN "ODSMGR"."ACADEMIC_STUDY" "Academic_Study"
                ON 
                    "Student0"."PERSON_UID" = "Academic_Study"."PERSON_UID" AND
                    "Student0"."ACADEMIC_PERIOD" = "Academic_Study"."ACADEMIC_PERIOD"
                    LEFT OUTER JOIN "ODSMGR"."STUDENT_COURSE" "Student_Course"
                    ON 
                        "Student0"."PERSON_UID" = "Student_Course"."PERSON_UID" AND
                        "Student0"."ACADEMIC_PERIOD" = "Student_Course"."ACADEMIC_PERIOD"
                        LEFT OUTER JOIN "ODSMGR"."ENROLLMENT" "Enrollment"
                        ON 
                            "Student0"."PERSON_UID" = "Enrollment"."PERSON_UID" AND
                            "Student0"."ACADEMIC_PERIOD" = "Enrollment"."ACADEMIC_PERIOD"
                            LEFT OUTER JOIN "ODSMGR"."STUDENT_ACTIVITY" "Student_Activity"
                            ON 
                                "Student0"."PERSON_UID" = "Student_Activity"."PERSON_UID" AND
                                "Student0"."ACADEMIC_PERIOD" = "Student_Activity"."ACADEMIC_PERIOD" 
        WHERE 
            "Academic_Study"."ACADEMIC_PERIOD" = '219413' AND --INGRESAR PERIODO
            "Academic_Study"."STUDENT_LEVEL" = 'UG' AND
            "Academic_Study"."ENROLLMENT_STATUS" IN ( 
                'EL', 
                'RF', 
                'RO', 
                'SE' ) AND
            "Academic_Study"."PRIMARY_PROGRAM_IND" = 'Y'
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
        "D1"."C9", 
        "D1"."C10", 
        "D1"."C11", 
        "D1"."C12", 
        "D1"."C13", 
        "D1"."C14", 
        "D1"."C15", 
        "D1"."C16", 
        "D1"."C17", 
        "D1"."C18", 
        "D1"."C19", 
        "D1"."C20"
    ) "SQ0_Q1__BNR_BASE";