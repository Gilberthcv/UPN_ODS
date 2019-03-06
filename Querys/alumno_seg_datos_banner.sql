SELECT DISTINCT
    a.PERSON_UID AS PIDM,
    b.ID AS ID,
    CONCAT(CONCAT(b.LAST_NAME,', '),b.FIRST_NAME) AS NOMBRE_ESTUDIANTE,
    b.MARITAL_STATUS_DESC AS ESTADO_CIVIL,
    a.ACADEMIC_PERIOD AS PERIODO,
    a.CAMPUS AS CAMPUS,
    CAST(MONTHS_BETWEEN(sysdate,b.BIRTH_DATE)/12 AS INTEGER) AS EDAD,
    CASE a.STUDENT_POPULATION
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
    END AS TIPO_ESTUDIANTE,
    i.INST_CHARACTERISTIC AS COD_TIPO_COLEGIO,
    i.INST_CHARACTERISTIC_DESC AS TIPO_COLEGIO,
    h.INSTITUTION AS COD_COLEGIO,
    h.INSTITUTION_DESC AS COLEGIO,
    TO_CHAR(h.SECONDARY_SCHOOL_GRAD_DATE,'YYYY') AS ANHO_FIN_COLEGIO,
    a.ADMISSIONS_POPULATION AS COD_TIPO_ADMISION,
    f.TBBESTU_EXEMPTION_CODE AS COD_BECA,
    g.CHARGE_PERCENTAGE AS PORCENTAJE,
    CASE
        WHEN MIN(CASE
                    WHEN a.ACADEMIC_PERIOD_ADMITTED IS NULL THEN '999999'
                    ELSE a.ACADEMIC_PERIOD_ADMITTED
                END)
                OVER(PARTITION BY
                        a.PERSON_UID,
                        a.STUDENT_LEVEL
                ) = '999999' THEN NULL
        ELSE MIN(CASE
                    WHEN a.ACADEMIC_PERIOD_ADMITTED IS NULL THEN '999999'
                    ELSE a.ACADEMIC_PERIOD_ADMITTED
                END)
                OVER(PARTITION BY
                        a.PERSON_UID,
                        a.STUDENT_LEVEL
                )
    END AS PERIODO_ADMISION,
    CASE WHEN a.ENROLLMENT_STATUS IN ('RF','RO') THEN a.ENROLLMENT_STATUS
        ELSE NULL
    END AS RETIRO,
    CASE WHEN a.ENROLLMENT_STATUS IN ('RF','RO') THEN a.ENROLLMENT_STATUS_DATE
        ELSE NULL
    END AS FECHA_RETIRO,
    CASE WHEN a.ENROLLMENT_STATUS IN ('RF','RO') THEN a.REGISTRATION_REASON
        ELSE NULL
    END AS COD_MOTIVO_RETIRO,
    CASE WHEN a.ENROLLMENT_STATUS IN ('RF','RO') THEN a.REGISTRATION_REASON_DESC
        ELSE NULL
    END AS MOTIVO_RETIRO,
    MAX(j.ACADEMIC_PERIOD) 
        OVER(PARTITION BY
            a.PERSON_UID) AS PERIODO_EGRESO
FROM
    (((((((( ACADEMIC_STUDY a
        LEFT JOIN PERSON b ON
            a.PERSON_UID = b.PERSON_UID )
        LEFT JOIN STUDENT_COHORT c ON
            a.PERSON_UID = c.PERSON_UID AND
            a.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD AND
            c.COHORT_ACTIVE_IND = 'Y' AND
            c.COHORT IN ('NEW_REING','REINGRESO') )
        LEFT JOIN STUDENT_ATTRIBUTE d ON
            a.PERSON_UID = d.PERSON_UID AND
            a.ACADEMIC_PERIOD = d.ACADEMIC_PERIOD AND
            d.STUDENT_ATTRIBUTE = 'TINT' )
        LEFT JOIN STUDENT_ACTIVITY e ON 
            a.PERSON_UID = e.PERSON_UID AND 
            a.ACADEMIC_PERIOD = e.ACADEMIC_PERIOD AND 
            e.ACTIVITY = 'ITO')
        LEFT JOIN LOE_EXEMPTION_STU_AUTHOR f ON
            a.PERSON_UID = f.TBBESTU_PIDM AND
            a.ACADEMIC_PERIOD = f.TBBESTU_TERM_CODE AND
            f.TBBESTU_DEL_IND is NULL AND
            SUBSTR(f.TBBESTU_EXEMPTION_CODE,5,1) = '1' )
        LEFT JOIN LOE_EXEMPTION_DETAIL_LEVEL g ON
            a.ACADEMIC_PERIOD = g.EXEMPTION_TERM AND
            f.TBBESTU_EXEMPTION_CODE = g.EXEMPTION_CODE )
        LEFT JOIN PREVIOUS_EDUCATION h ON
            a.PERSON_UID = h.PERSON_UID AND
            h.INSTITUTION_TYPE = 'H')
        LEFT JOIN INSTITUTION_CHARACTERISTIC i ON
            h.INSTITUTION = i.INSTITUTION )
        LEFT JOIN ACADEMIC_OUTCOME j ON
            a.PERSON_UID = j.PERSON_UID AND
            a.STUDENT_LEVEL = j.STUDENT_LEVEL AND
            j.STATUS = 'EG'
WHERE
    a.STUDENT_LEVEL = 'UG' AND
    a.ENROLLMENT_STATUS in ('EL','RF','RO')/* AND
    CASE
        WHEN a.ACADEMIC_PERIOD < 217400 THEN 'Y'
        WHEN a.ACADEMIC_PERIOD > 217400 AND
            substr(a.ACADEMIC_PERIOD,4,1) IN ('4','5') THEN 'Y'
        ELSE 'N'
    END = 'Y' */
    AND a.ACADEMIC_PERIOD IN ('217434','217534','218413','218512')--INGRESAR PERIODO UG
ORDER BY a.PERSON_UID;