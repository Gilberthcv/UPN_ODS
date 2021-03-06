SELECT
    a.PERSON_UID,
    b.SPRIDEN_ID,
    a.STUDENT_RATE,
    a.STUDENT_RATE_DESC
FROM
    ACADEMIC_STUDY a
        LEFT JOIN LOE_SPRIDEN b ON
            a.PERSON_UID = b.SPRIDEN_PIDM AND
            b.SPRIDEN_CHANGE_IND IS NULL
WHERE
    SUBSTR(a.STUDENT_RATE, 1, 2) IN ('TA', 'TS', 'TI')
GROUP BY
    a.PERSON_UID,
    b.SPRIDEN_ID,
    a.STUDENT_RATE,
    a.STUDENT_RATE_DESC;