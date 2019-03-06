
SELECT DISTINCT
    SPRIDEN_ID AS SIS_STUDENT_KEY
    , TO_CHAR(SPBPERS_BIRTH_DATE,'YYYY-MM-DD') AS BIRTH_DATE
    , CASE SPBPERS_CITZ_CODE
          WHEN 'C' THEN 'Ciudadano'
          WHEN 'N' THEN 'Extranjero'
        ELSE NULL END AS CITIZENSHIP
    , CASE SPBPERS_SEX
          WHEN 'F' THEN 'Femenino'
          WHEN 'M' THEN 'Masculino'
        ELSE NULL END AS GENDER
    , SPBPERS_ETHN_CODE AS ETHNICITY_CODE
    , SPRIDEN_ID || '@upn.pe' AS EMAIL_ADDRESS
    , MAX(CASE WHEN SPRTELE_TELE_CODE = 'CP' THEN SPRTELE_PHONE_NUMBER ELSE NULL END)
        OVER(PARTITION BY SPRTELE_PIDM) AS PHONE_NUMBER
    , 'UPN' AS INSTITUTION
    , SFRSTCR_PIDM AS BATCHUID
FROM SFRSTCR,	
     SPRIDEN, 
     SPBPERS, 
     SPRTELE
WHERE SFRSTCR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SFRSTCR_PIDM = SPBPERS_PIDM
    AND SFRSTCR_PIDM = SPRTELE_PIDM(+) AND SPRTELE_TELE_CODE(+) = 'CP'
    AND SFRSTCR_TERM_CODE IN (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                            WHERE start_date <= SYSDATE +7 AND end_date >= SYSDATE -16);