
SELECT DISTINCT SHRTRCE_PIDM, SPRIDEN_ID, SPRIDEN_LAST_NAME, SPRIDEN_FIRST_NAME, SOVLCUR_CAMP_CODE, SOVLCUR_PROGRAM
    , MIN(SOVLCUR_TERM_CODE_ADMIT) OVER(PARTITION BY SOVLCUR_PIDM, SOVLCUR_LEVL_CODE) AS PERIODO_INGRESO
    , SOVLCUR_ADMT_CODE, SHRTRCE_TERM_CODE_EFF, SHRTRCE_SUBJ_CODE, SHRTRCE_CRSE_NUMB, SHRTRCE_CRSE_TITLE
    , SHRTCKN_TERM_CODE, SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB, SHRTCKN_CRSE_TITLE, SHRTCKG_GRDE_CODE_FINAL
FROM SHRTRCE, SHRTCKN, SHRTCKG g, LOE_SOVLCUR, SPRIDEN
WHERE SHRTRCE_PIDM = SHRTCKN_PIDM AND SHRTRCE_SUBJ_CODE = SHRTCKN_SUBJ_CODE AND SHRTRCE_CRSE_NUMB = SHRTCKN_CRSE_NUMB
    AND SHRTCKN_PIDM = SHRTCKG_PIDM AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
    AND g.SHRTCKG_SEQ_NO = (SELECT MAX(G1.SHRTCKG_SEQ_NO) 
                              FROM SHRTCKG G1
                              WHERE g.SHRTCKG_PIDM        = G1.SHRTCKG_PIDM
                                AND g.SHRTCKG_TERM_CODE   = G1.SHRTCKG_TERM_CODE
                                AND g.SHRTCKG_TCKN_SEQ_NO = G1.SHRTCKG_TCKN_SEQ_NO)
    AND SUBSTR(SHRTCKG_GRDE_CODE_FINAL,1,1) <> 'C'
    AND SHRTRCE_PIDM = SOVLCUR_PIDM(+) AND SHRTRCE_LEVL_CODE = SOVLCUR_LEVL_CODE(+)
    AND SOVLCUR_LMOD_CODE(+) = 'LEARNER' AND SOVLCUR_CACT_CODE(+) = 'ACTIVE' AND SOVLCUR_TERM_CODE_END(+) IS NULL
    AND SHRTRCE_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SHRTRCE_LEVL_CODE = 'UG';