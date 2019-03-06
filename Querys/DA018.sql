SELECT
    Consulta3.PERSON_UID AS PERSON_UID, 
    Consulta3.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
    Consulta3.SEQUENCE_NUMBER AS SEQUENCE_NUMBER, 
    Consulta3.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
    Consulta3.SUBJECT AS SUBJECT, 
    Consulta3.COURSE_NUMBER AS COURSE_NUMBER, 
    Consulta3.MATERIA AS MATERIA, 
    Consulta3.CAMP AS CAMP, 
    Consulta3.ACTIVITY_DATE AS ACTIVITY_DATE, 
    Consulta3.COURSE_TITLE AS COURSE_TITLE, 
    Consulta3.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
    Consulta3.CREDITS_PASSED AS CREDITS_PASSED, 
    Consulta3.CREDITOS_CONV AS CREDITOS_CONV, 
    Consulta3.FINAL_GRADE AS FINAL_GRADE, 
    Consulta3.QUALITY_POINTS AS QUALITY_POINTS, 
    LOE_SHRTGPA2.SHRTGPA_LEVL_CODE AS SHRTGPA_LEVL_CODE, 
    LOE_SHRTGPA2.SHRTGPA_GPA_HOURS AS SHRTGPA_GPA_HOURS, 
    LOE_SHRTGPA2.SHRTGPA_HOURS_PASSED AS SHRTGPA_HOURS_PASSED, 
    SUM(Consulta3.CREDITOS_CONV)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE, 
                Consulta3.ACADEMIC_PERIOD
        ) AS SHRTGPA_CONV, 
    LOE_SHRTGPA2.SHRTGPA_GPA AS SHRTGPA_GPA, 
    SUM(Consulta3.CREDITS_FOR_GPA)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ) AS CREDITOS_CURSADOS, 
    SUM(Consulta3.CREDITS_PASSED)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ) AS CREDITOS_APROBADOS, 
    SUM(Consulta3.CREDITOS_CONV)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ) AS CREDITOS_CONVALIDADOS, 
    (SUM(Consulta3.QUALITY_POINTS)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        )) / (SUM(Consulta3.CREDITS_FOR_GPA)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        )) AS PROMEDIO_PONDERADO
FROM
    (
    SELECT
        Union3.PERSON_UID AS PERSON_UID, 
        Union3.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
        Union3.SEQUENCE_NUMBER AS SEQUENCE_NUMBER, 
        Union3.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
        Union3.SUBJECT AS SUBJECT, 
        Union3.COURSE_NUMBER AS COURSE_NUMBER, 
        Union3.SUBJECT || Union3.COURSE_NUMBER AS MATERIA, 
        Union3.CAMP AS CAMP, 
        Union3.ACTIVITY_DATE AS ACTIVITY_DATE, 
        Union3.COURSE_TITLE AS COURSE_TITLE, 
        Union3.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
        Union3.CREDITS_PASSED AS CREDITS_PASSED, 
        Union3.CREDITOS_CONV AS CREDITOS_CONV, 
        Union3.FINAL_GRADE AS FINAL_GRADE, 
        Union3.QUALITY_POINTS AS QUALITY_POINTS
    FROM
        (
        SELECT
            *
        FROM
            (
            SELECT
                Consulta1.PERSON_UID AS PERSON_UID, 
                Consulta1.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                Consulta1.SEQUENCE_NUMBER AS SEQUENCE_NUMBER, 
                Consulta1.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                Consulta1.SUBJECT AS SUBJECT, 
                Consulta1.COURSE_NUMBER AS COURSE_NUMBER, 
                COALESCE(
                    Consulta1.CAMP, 
                    Academic_Study0.CAMPUS, 
                    ' ') AS CAMP, 
                Consulta1.ACTIVITY_DATE AS ACTIVITY_DATE, 
                Consulta1.COURSE_TITLE AS COURSE_TITLE, 
                Consulta1.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
                Consulta1.CREDITS_PASSED AS CREDITS_PASSED, 
                Consulta1.CREDITOS_CONV AS CREDITOS_CONV, 
                Consulta1.FINAL_GRADE AS FINAL_GRADE, 
                Consulta1.QUALITY_POINTS AS QUALITY_POINTS
            FROM
                (
                SELECT
                    LOE_STUDENT_COURSE4.PERSON_UID AS PERSON_UID, 
                    LOE_STUDENT_COURSE4.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                    LOE_STUDENT_COURSE4.SEQUENCE_NUMBER AS SEQUENCE_NUMBER, 
                    LOE_STUDENT_COURSE4.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                    LOE_STUDENT_COURSE4.SUBJECT AS SUBJECT, 
                    LOE_STUDENT_COURSE4.COURSE_NUMBER AS COURSE_NUMBER, 
                    LOE_STUDENT_COURSE4.CAMP AS CAMP, 
                    LOE_STUDENT_COURSE4.ACTIVITY_DATE AS ACTIVITY_DATE, 
                    LOE_STUDENT_COURSE4.COURSE_TITLE AS COURSE_TITLE, 
                    Student_Course_Grade_Change.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
                    Student_Course_Grade_Change.CREDITS_PASSED AS CREDITS_PASSED, 
                    CASE 
                        WHEN SUBSTR(Student_Course_Grade_Change.FINAL_GRADE,1,1) = 'C' THEN Student_Course_Grade_Change.CREDITS_PASSED
                        ELSE 0
                    END AS CREDITOS_CONV, 
                    Student_Course_Grade_Change.FINAL_GRADE AS FINAL_GRADE, 
                    Student_Course_Grade_Change.QUALITY_POINTS AS QUALITY_POINTS
                FROM
                    (
                    SELECT
                        LOE_STUDENT_COURSE.PERSON_UID AS PERSON_UID, 
                        LOE_STUDENT_COURSE.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                        LOE_STUDENT_COURSE.SEQUENCE_NUMBER AS SEQUENCE_NUMBER, 
                        LOE_STUDENT_COURSE.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                        LOE_STUDENT_COURSE.SUBJECT AS SUBJECT, 
                        LOE_STUDENT_COURSE.COURSE_NUMBER AS COURSE_NUMBER, 
                        LOE_STUDENT_COURSE.CAMP AS CAMP, 
                        LOE_STUDENT_COURSE.COURSE_TITLE_SHORT AS COURSE_TITLE_SHORT, 
                        LOE_STUDENT_COURSE.ACTIVITY_DATE AS ACTIVITY_DATE, 
                        LOE_STUDENT_COURSE.COURSE_TITLE_LONG AS COURSE_TITLE_LONG, 
                        COALESCE(
                            LOE_STUDENT_COURSE.COURSE_TITLE_LONG, 
                            LOE_STUDENT_COURSE.COURSE_TITLE_SHORT) AS COURSE_TITLE
                    FROM
                        ODSMGR.LOE_STUDENT_COURSE LOE_STUDENT_COURSE 
                    GROUP BY 
                        LOE_STUDENT_COURSE.PERSON_UID, 
                        LOE_STUDENT_COURSE.ACADEMIC_PERIOD, 
                        LOE_STUDENT_COURSE.SEQUENCE_NUMBER, 
                        LOE_STUDENT_COURSE.COURSE_REFERENCE_NUMBER, 
                        LOE_STUDENT_COURSE.SUBJECT, 
                        LOE_STUDENT_COURSE.COURSE_NUMBER, 
                        LOE_STUDENT_COURSE.CAMP, 
                        LOE_STUDENT_COURSE.COURSE_TITLE_SHORT, 
                        LOE_STUDENT_COURSE.ACTIVITY_DATE, 
                        LOE_STUDENT_COURSE.COURSE_TITLE_LONG, 
                        COALESCE(
                            LOE_STUDENT_COURSE.COURSE_TITLE_LONG, 
                            LOE_STUDENT_COURSE.COURSE_TITLE_SHORT)
                    ) LOE_STUDENT_COURSE4
                        LEFT OUTER JOIN 
                        (
                        SELECT
                            T8.PERSON_UID AS PERSON_UID, 
                            T8.SUBJECT AS SUBJECT, 
                            T8.COURSE_NUMBER AS COURSE_NUMBER, 
                            T8.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                            T8.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                            T8.FINAL_GRADE AS FINAL_GRADE, 
                            T8.FINAL_GRADE_SEQUENCE_NUMBER AS FINAL_GRADE_SEQUENCE_NUMBER, 
                            T8.GRADE_CHANGE_DATE AS GRADE_CHANGE_DATE, 
                            T8.CREDITS_PASSED AS CREDITS_PASSED, 
                            T8.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
                            T8.QUALITY_POINTS AS QUALITY_POINTS
                        FROM
                            (
                            SELECT
                                STUDENT_COURSE_GRADE_CHANGE.PERSON_UID AS PERSON_UID, 
                                STUDENT_COURSE_GRADE_CHANGE.SUBJECT AS SUBJECT, 
                                STUDENT_COURSE_GRADE_CHANGE.COURSE_NUMBER AS COURSE_NUMBER, 
                                STUDENT_COURSE_GRADE_CHANGE.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                                STUDENT_COURSE_GRADE_CHANGE.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                                STUDENT_COURSE_GRADE_CHANGE.FINAL_GRADE AS FINAL_GRADE, 
                                STUDENT_COURSE_GRADE_CHANGE.FINAL_GRADE_SEQUENCE_NUMBER AS FINAL_GRADE_SEQUENCE_NUMBER, 
                                STUDENT_COURSE_GRADE_CHANGE.GRADE_CHANGE_DATE AS GRADE_CHANGE_DATE, 
                                STUDENT_COURSE_GRADE_CHANGE.CREDITS_PASSED AS CREDITS_PASSED, 
                                STUDENT_COURSE_GRADE_CHANGE.CREDITS_FOR_GPA AS CREDITS_FOR_GPA, 
                                STUDENT_COURSE_GRADE_CHANGE.QUALITY_POINTS AS QUALITY_POINTS, 
                                MAX(STUDENT_COURSE_GRADE_CHANGE.FINAL_GRADE_SEQUENCE_NUMBER)
                                    OVER(
                                        PARTITION BY
                                            STUDENT_COURSE_GRADE_CHANGE.PERSON_UID, 
                                            STUDENT_COURSE_GRADE_CHANGE.SUBJECT, 
                                            STUDENT_COURSE_GRADE_CHANGE.COURSE_NUMBER, 
                                            STUDENT_COURSE_GRADE_CHANGE.ACADEMIC_PERIOD
                                    ) AS Max1
                            FROM
                                ODSMGR.STUDENT_COURSE_GRADE_CHANGE STUDENT_COURSE_GRADE_CHANGE
                            ) T8 
                        WHERE 
                            T8.FINAL_GRADE_SEQUENCE_NUMBER = T8.Max1 
                        GROUP BY 
                            T8.PERSON_UID, 
                            T8.SUBJECT, 
                            T8.COURSE_NUMBER, 
                            T8.ACADEMIC_PERIOD, 
                            T8.COURSE_REFERENCE_NUMBER, 
                            T8.FINAL_GRADE, 
                            T8.FINAL_GRADE_SEQUENCE_NUMBER, 
                            T8.GRADE_CHANGE_DATE, 
                            T8.CREDITS_PASSED, 
                            T8.CREDITS_FOR_GPA, 
                            T8.QUALITY_POINTS
                        ) Student_Course_Grade_Change
                        ON 
                            LOE_STUDENT_COURSE4.PERSON_UID = Student_Course_Grade_Change.PERSON_UID AND
                            LOE_STUDENT_COURSE4.ACADEMIC_PERIOD = Student_Course_Grade_Change.ACADEMIC_PERIOD AND
                            LOE_STUDENT_COURSE4.SUBJECT = Student_Course_Grade_Change.SUBJECT AND
                            LOE_STUDENT_COURSE4.COURSE_NUMBER = Student_Course_Grade_Change.COURSE_NUMBER AND
                            LOE_STUDENT_COURSE4.COURSE_REFERENCE_NUMBER = Student_Course_Grade_Change.COURSE_REFERENCE_NUMBER 
                GROUP BY 
                    LOE_STUDENT_COURSE4.PERSON_UID, 
                    LOE_STUDENT_COURSE4.ACADEMIC_PERIOD, 
                    LOE_STUDENT_COURSE4.SEQUENCE_NUMBER, 
                    LOE_STUDENT_COURSE4.COURSE_REFERENCE_NUMBER, 
                    LOE_STUDENT_COURSE4.SUBJECT, 
                    LOE_STUDENT_COURSE4.COURSE_NUMBER, 
                    LOE_STUDENT_COURSE4.CAMP, 
                    LOE_STUDENT_COURSE4.ACTIVITY_DATE, 
                    LOE_STUDENT_COURSE4.COURSE_TITLE, 
                    Student_Course_Grade_Change.CREDITS_FOR_GPA, 
                    Student_Course_Grade_Change.CREDITS_PASSED, 
                    CASE 
                        WHEN SUBSTR(Student_Course_Grade_Change.FINAL_GRADE,1,1) = 'C' THEN Student_Course_Grade_Change.CREDITS_PASSED
                        ELSE 0
                    END, 
                    Student_Course_Grade_Change.FINAL_GRADE, 
                    Student_Course_Grade_Change.QUALITY_POINTS
                ) Consulta1
                    LEFT OUTER JOIN 
                    (
                    SELECT
                        ACADEMIC_STUDY.PERSON_UID AS PERSON_UID, 
                        ACADEMIC_STUDY.ID AS ID, 
                        ACADEMIC_STUDY.NAME AS NAME, 
                        ACADEMIC_STUDY.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                        ACADEMIC_STUDY.CAMPUS AS CAMPUS
                    FROM
                        ODSMGR.ACADEMIC_STUDY ACADEMIC_STUDY 
                    GROUP BY 
                        ACADEMIC_STUDY.PERSON_UID, 
                        ACADEMIC_STUDY.ID, 
                        ACADEMIC_STUDY.NAME, 
                        ACADEMIC_STUDY.ACADEMIC_PERIOD, 
                        ACADEMIC_STUDY.CAMPUS
                    ) Academic_Study0
                    ON 
                        Consulta1.PERSON_UID = Academic_Study0.PERSON_UID AND
                        Consulta1.ACADEMIC_PERIOD = Academic_Study0.ACADEMIC_PERIOD 
            GROUP BY 
                Consulta1.PERSON_UID, 
                Consulta1.ACADEMIC_PERIOD, 
                Consulta1.SEQUENCE_NUMBER, 
                Consulta1.COURSE_REFERENCE_NUMBER, 
                Consulta1.SUBJECT, 
                Consulta1.COURSE_NUMBER, 
                COALESCE(
                    Consulta1.CAMP, 
                    Academic_Study0.CAMPUS, 
                    ' '), 
                Consulta1.ACTIVITY_DATE, 
                Consulta1.COURSE_TITLE, 
                Consulta1.CREDITS_FOR_GPA, 
                Consulta1.CREDITS_PASSED, 
                Consulta1.CREDITOS_CONV, 
                Consulta1.FINAL_GRADE, 
                Consulta1.QUALITY_POINTS
            ) Consulta2
        
        UNION
        
        SELECT
            *
        FROM
            (
            SELECT
                STUDENT_TRANSFERRED_COURSE.PERSON_UID AS PERSON_UID, 
                STUDENT_TRANSFERRED_COURSE.ACADEMIC_PERIOD AS ACADEMIC_PERIOD, 
                STUDENT_TRANSFERRED_COURSE.COURSE_SEQ_NO AS COURSE_SEQ_NO, 
                STUDENT_TRANSFERRED_COURSE.COURSE_REFERENCE_NUMBER AS COURSE_REFERENCE_NUMBER, 
                STUDENT_TRANSFERRED_COURSE.SUBJECT AS SUBJECT, 
                STUDENT_TRANSFERRED_COURSE.COURSE_NUMBER AS COURSE_NUMBER, 
                CAST(NULL AS VARCHAR(252)) AS CAMP, 
                STUDENT_TRANSFERRED_COURSE.TRANSFER_COURSE_ACTIVITY_DATE AS TRANSFER_COURSE_ACTIVITY_DATE, 
                STUDENT_TRANSFERRED_COURSE.COURSE_TITLE_SHORT AS COURSE_TITLE_SHORT, 
                0 AS CREDITOS_GPA, 
                0 AS CREDITS_PASSED, 
                STUDENT_TRANSFERRED_COURSE.COURSE_CREDITS AS COURSE_CREDITS, 
                STUDENT_TRANSFERRED_COURSE.FINAL_GRADE AS FINAL_GRADE, 
                0 AS QUALITY_POINTS
            FROM
                ODSMGR.STUDENT_TRANSFERRED_COURSE STUDENT_TRANSFERRED_COURSE 
            GROUP BY 
                STUDENT_TRANSFERRED_COURSE.PERSON_UID, 
                STUDENT_TRANSFERRED_COURSE.ACADEMIC_PERIOD, 
                STUDENT_TRANSFERRED_COURSE.COURSE_SEQ_NO, 
                STUDENT_TRANSFERRED_COURSE.COURSE_REFERENCE_NUMBER, 
                STUDENT_TRANSFERRED_COURSE.SUBJECT, 
                STUDENT_TRANSFERRED_COURSE.COURSE_NUMBER, 
                CAST(NULL AS VARCHAR(252)), 
                STUDENT_TRANSFERRED_COURSE.TRANSFER_COURSE_ACTIVITY_DATE, 
                STUDENT_TRANSFERRED_COURSE.COURSE_TITLE_SHORT, 
                0, 
                0, 
                STUDENT_TRANSFERRED_COURSE.COURSE_CREDITS, 
                STUDENT_TRANSFERRED_COURSE.FINAL_GRADE, 
                0
            ) STUDENT_TRANSFERRED_COURSE6
        ) Union3--(PERSON_UID, ACADEMIC_PERIOD, SEQUENCE_NUMBER, COURSE_REFERENCE_NUMBER, SUBJECT, COURSE_NUMBER, CAMP, ACTIVITY_DATE, COURSE_TITLE, CREDITS_FOR_GPA, CREDITS_PASSED, CREDITOS_CONV, FINAL_GRADE, QUALITY_POINTS) 
    GROUP BY 
        Union3.PERSON_UID, 
        Union3.ACADEMIC_PERIOD, 
        Union3.SEQUENCE_NUMBER, 
        Union3.COURSE_REFERENCE_NUMBER, 
        Union3.SUBJECT, 
        Union3.COURSE_NUMBER, 
        Union3.SUBJECT || Union3.COURSE_NUMBER, 
        Union3.CAMP, 
        Union3.ACTIVITY_DATE, 
        Union3.COURSE_TITLE, 
        Union3.CREDITS_FOR_GPA, 
        Union3.CREDITS_PASSED, 
        Union3.CREDITOS_CONV, 
        Union3.FINAL_GRADE, 
        Union3.QUALITY_POINTS
    ) Consulta3
        INNER JOIN 
        (
        SELECT
            LOE_SHRTGPA.SHRTGPA_PIDM AS SHRTGPA_PIDM, 
            LOE_SHRTGPA.SHRTGPA_TERM_CODE AS SHRTGPA_TERM_CODE, 
            LOE_SHRTGPA.SHRTGPA_LEVL_CODE AS SHRTGPA_LEVL_CODE, 
            LOE_SHRTGPA.SHRTGPA_GPA_TYPE_IND AS SHRTGPA_GPA_TYPE_IND, 
            LOE_SHRTGPA.SHRTGPA_GPA_HOURS AS SHRTGPA_GPA_HOURS, 
            LOE_SHRTGPA.SHRTGPA_QUALITY_POINTS AS SHRTGPA_QUALITY_POINTS, 
            ROUND(LOE_SHRTGPA.SHRTGPA_GPA, 2) AS SHRTGPA_GPA, 
            LOE_SHRTGPA.SHRTGPA_ACTIVITY_DATE AS SHRTGPA_ACTIVITY_DATE, 
            LOE_SHRTGPA.SHRTGPA_HOURS_PASSED AS SHRTGPA_HOURS_PASSED
        FROM
            ODSMGR.LOE_SHRTGPA LOE_SHRTGPA 
        WHERE 
            LOE_SHRTGPA.SHRTGPA_GPA_TYPE_IND = 'I' 
        GROUP BY 
            LOE_SHRTGPA.SHRTGPA_PIDM, 
            LOE_SHRTGPA.SHRTGPA_TERM_CODE, 
            LOE_SHRTGPA.SHRTGPA_LEVL_CODE, 
            LOE_SHRTGPA.SHRTGPA_GPA_TYPE_IND, 
            LOE_SHRTGPA.SHRTGPA_GPA_HOURS, 
            LOE_SHRTGPA.SHRTGPA_QUALITY_POINTS, 
            ROUND(LOE_SHRTGPA.SHRTGPA_GPA, 2), 
            LOE_SHRTGPA.SHRTGPA_ACTIVITY_DATE, 
            LOE_SHRTGPA.SHRTGPA_HOURS_PASSED
        ) LOE_SHRTGPA2
        ON 
            Consulta3.PERSON_UID = LOE_SHRTGPA2.SHRTGPA_PIDM AND
            Consulta3.ACADEMIC_PERIOD = LOE_SHRTGPA2.SHRTGPA_TERM_CODE 
WHERE Consulta3.PERSON_UID = 32531 AND LOE_SHRTGPA2.SHRTGPA_LEVL_CODE = 'UG' 
GROUP BY 
    Consulta3.PERSON_UID, 
    Consulta3.ACADEMIC_PERIOD, 
    Consulta3.SEQUENCE_NUMBER, 
    Consulta3.COURSE_REFERENCE_NUMBER, 
    Consulta3.SUBJECT, 
    Consulta3.COURSE_NUMBER, 
    Consulta3.MATERIA, 
    Consulta3.CAMP, 
    Consulta3.ACTIVITY_DATE, 
    Consulta3.COURSE_TITLE, 
    Consulta3.CREDITS_FOR_GPA, 
    Consulta3.CREDITS_PASSED, 
    Consulta3.CREDITOS_CONV, 
    Consulta3.FINAL_GRADE, 
    Consulta3.QUALITY_POINTS, 
    LOE_SHRTGPA2.SHRTGPA_LEVL_CODE, 
    LOE_SHRTGPA2.SHRTGPA_GPA_HOURS, 
    LOE_SHRTGPA2.SHRTGPA_HOURS_PASSED, 
    /*SUM(Consulta3.CREDITOS_CONV)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE, 
                Consulta3.ACADEMIC_PERIOD
        ), */
    LOE_SHRTGPA2.SHRTGPA_GPA/*, 
    SUM(Consulta3.CREDITS_FOR_GPA)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ), 
    SUM(Consulta3.CREDITS_PASSED)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ), 
    SUM(Consulta3.CREDITOS_CONV)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ), 
    (SUM(Consulta3.QUALITY_POINTS)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        )) / (SUM(Consulta3.CREDITS_FOR_GPA)
        OVER(
            PARTITION BY
                Consulta3.PERSON_UID, 
                LOE_SHRTGPA2.SHRTGPA_LEVL_CODE
        ))*/
ORDER BY 2,8,3;