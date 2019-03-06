
SELECT DISTINCT
    c.SPRIDEN_ID AS SIS_INSTRUCTOR_KEY
    , CASE d.SPBPERS_CITZ_CODE
          WHEN 'C' THEN 'Ciudadano'
          WHEN 'N' THEN 'Extranjero'
        ELSE NULL END AS CURRENT_CITIZENSHIP
    , CASE d.SPBPERS_SEX
          WHEN 'F' THEN 'Femenino'
          WHEN 'M' THEN 'Masculino'
        ELSE NULL END AS GENDER
    , f.GOREMAL_EMAIL_ADDRESS AS EMAIL_ADDRESS
    , MAX(CASE WHEN e.SPRTELE_TELE_CODE = 'CP' THEN e.SPRTELE_PHONE_NUMBER ELSE NULL END)
        OVER(PARTITION BY e.SPRTELE_PIDM) AS PHONE_NUMBER
    , TO_CHAR(d.SPBPERS_BIRTH_DATE,'YYYY-MM-DD') AS BIRTH_DATE
    , CASE b.SIBINST_WKLD_CODE
          WHEN 'FT' THEN 'DTC'
          WHEN 'PT' THEN 'DTP'
        ELSE NULL END AS FACULTY_RANK
    , 'UPN' AS INSTITUTION
    , a.SIRASGN_PIDM AS BATCHUID
FROM SIRASGN a,	
     (SELECT SIBINST_PIDM, SIBINST_TERM_CODE_EFF, SIBINST_FCST_CODE, SIBINST_WKLD_CODE, MAX(SIBINST_TERM_CODE_EFF) OVER(PARTITION BY SIBINST_PIDM) AS MAX_PERIOD
      FROM SIBINST WHERE SIBINST_TERM_CODE_EFF <> '999996') b, 
     SPRIDEN c, 
     SPBPERS d, 
     SPRTELE e, 
     (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS
      FROM (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS, GOREMAL_ACTIVITY_DATE, MAX(GOREMAL_ACTIVITY_DATE) OVER(PARTITION BY GOREMAL_PIDM) AS MAX_DATE FROM GOREMAL
            WHERE GOREMAL_STATUS_IND = 'A' AND GOREMAL_EMAL_CODE = 'UNIV')
      WHERE GOREMAL_ACTIVITY_DATE = MAX_DATE) f
WHERE a.SIRASGN_PIDM = b.SIBINST_PIDM AND b.SIBINST_TERM_CODE_EFF = b.MAX_PERIOD
    AND a.SIRASGN_PIDM = c.SPRIDEN_PIDM AND c.SPRIDEN_CHANGE_IND IS NULL
    AND a.SIRASGN_PIDM = d.SPBPERS_PIDM
    AND a.SIRASGN_PIDM = e.SPRTELE_PIDM(+) AND e.SPRTELE_TELE_CODE(+) = 'CP'
    AND a.SIRASGN_PIDM = f.GOREMAL_PIDM(+)
    AND a.SIRASGN_TERM_CODE IN (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                            WHERE start_date <= SYSDATE +7 AND end_date >= SYSDATE -16);