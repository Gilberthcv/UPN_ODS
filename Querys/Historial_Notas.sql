SELECT SHRTCKN_PIDM, SPRIDEN_ID, SPRIDEN_LAST_NAME, SPRIDEN_FIRST_NAME, SORLCUR_PROGRAM, SHRTCKN_TERM_CODE
    , SHRTCKN_SEQ_NO, SHRTCKN_CRN, SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB
    , NVL(SHRTCKN_CRSE_TITLE,SHRTCKN_LONG_COURSE_TITLE) AS NOMBRE_CURSO, SHRTCKN_CAMP_CODE, SHRTCKG_GRDE_CODE_FINAL, SFRSTCR_RSTS_CODE
FROM SHRTCKN, 
     SHRTCKG g, 
     SHRTGPA, 
     SPRIDEN, 
     SFRSTCR, 
     SORLCUR
WHERE SHRTCKN_PIDM = SHRTCKG_PIDM 
      AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE 
      AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO 
      AND SHRTCKG_SEQ_NO = (SELECT MAX(G2.SHRTCKG_SEQ_NO) 
                            FROM SHRTCKG G2
                            WHERE g.SHRTCKG_PIDM            = G2.SHRTCKG_PIDM
                                AND g.SHRTCKG_TERM_CODE     = G2.SHRTCKG_TERM_CODE
                                AND g.SHRTCKG_TCKN_SEQ_NO   = G2.SHRTCKG_TCKN_SEQ_NO) 
      AND SHRTCKN_PIDM = SHRTGPA_PIDM
      AND SHRTCKN_TERM_CODE = SHRTGPA_TERM_CODE
      AND SHRTGPA_LEVL_CODE IN ('EC','MA')
      AND SHRTCKN_PIDM = SPRIDEN_PIDM
      AND SPRIDEN_CHANGE_IND IS NULL
      AND SHRTCKN_PIDM = SFRSTCR_PIDM(+)
      AND SHRTCKN_TERM_CODE = SFRSTCR_TERM_CODE(+)
      AND SHRTCKN_CRN = SFRSTCR_CRN(+)
      AND SHRTCKN_PIDM = SORLCUR_PIDM(+)
      AND SHRTCKN_TERM_CODE >= SORLCUR_TERM_CODE(+)
      AND SHRTCKN_TERM_CODE < NVL(SORLCUR_TERM_CODE_END(+),'999996')
      AND SORLCUR_LEVL_CODE(+) IN ('EC','MA')
      AND SORLCUR_LMOD_CODE(+) = 'LEARNER' AND SORLCUR_CACT_CODE(+) = 'ACTIVE'
ORDER BY SHRTCKN_TERM_CODE DESC, SHRTCKN_PIDM;