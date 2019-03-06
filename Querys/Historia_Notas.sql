SELECT d.SPRIDEN_ID, c.*
FROM
    (SELECT a.SHRTCKN_PIDM, a.SHRTCKN_TERM_CODE, a.SHRTCKN_SEQ_NO, a.SHRTCKN_CRN, a.SHRTCKN_SUBJ_CODE, a.SHRTCKN_CRSE_NUMB, a.SHRTCKN_CRSE_TITLE, b.SHRTCKG_CREDIT_HOURS, b.SHRTCKG_GRDE_CODE_FINAL
    FROM SHRTCKN a
        INNER JOIN SHRTCKG b ON
            a.SHRTCKN_PIDM = b.SHRTCKG_PIDM
            AND a.SHRTCKN_TERM_CODE = b.SHRTCKG_TERM_CODE
            AND a.SHRTCKN_SEQ_NO = b.SHRTCKG_TCKN_SEQ_NO
            AND b.SHRTCKG_SEQ_NO = (SELECT MAX(b_max.SHRTCKG_SEQ_NO) FROM SHRTCKG b_max WHERE a.SHRTCKN_PIDM = b_max.SHRTCKG_PIDM AND a.SHRTCKN_TERM_CODE = b_max.SHRTCKG_TERM_CODE AND a.SHRTCKN_SEQ_NO = b_max.SHRTCKG_TCKN_SEQ_NO)
    UNION
    SELECT SHRTRCE_PIDM, SHRTRCE_TERM_CODE_EFF, SHRTRCE_SEQ_NO, SHRTRCE_TERM_CODE_EFF, SHRTRCE_SUBJ_CODE, SHRTRCE_CRSE_NUMB, SHRTRCE_CRSE_TITLE, SHRTRCE_CREDIT_HOURS, SHRTRCE_GRDE_CODE  FROM SHRTRCE) c
        INNER JOIN SPRIDEN d ON
            c.SHRTCKN_PIDM = d.SPRIDEN_PIDM
WHERE d.SPRIDEN_ID = 'N00158480'
ORDER BY 3 DESC,4,6;

SELECT * FROM SPRIDEN
WHERE SPRIDEN_LAST_NAME LIKE 'VELASQUEZ/SANDO%'