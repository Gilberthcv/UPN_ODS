SELECT DISTINCT 
    --SORLCUR_TERM_CODE_END, 
    a.SORLCUR_PIDM, 
    b.SPRIDEN_ID,
    --SORLCUR_CACT_CODE, 
    --SORLCUR_KEY_SEQNO, 
    a.SORLCUR_PROGRAM, 
    --SORLCUR_ACYR_CODE, 
    --SORLCUR_LMOD_CODE, 
    --SORLCUR_TERM_CODE, 
    --SORLCUR_LEVL_CODE, 
    --SORLCUR_CAMP_CODE, 
    a.SORLCUR_RATE_CODE, 
    c.STVRATE_DESC
    --SORLCUR_USER_ID_UPDATE 
FROM 
    (SORLCUR a
        LEFT JOIN SPRIDEN b ON
            a.SORLCUR_PIDM = b.SPRIDEN_PIDM AND
            b.SPRIDEN_CHANGE_IND IS NULL)
        LEFT JOIN STVRATE c ON
            a.SORLCUR_RATE_CODE = c.STVRATE_CODE            
WHERE 
    a.SORLCUR_LMOD_CODE = 'LEARNER' AND 
    a.SORLCUR_CACT_CODE = 'ACTIVE' AND 
    a.SORLCUR_TERM_CODE_END IS NULL AND 
    a.SORLCUR_RATE_CODE IS NOT NULL AND
    SUBSTR(a.SORLCUR_RATE_CODE, 1, 2) IN ('TA', 'TS', 'TI')
ORDER BY 1;