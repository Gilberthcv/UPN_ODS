SELECT p.SHRTCKN_PIDM, 
       p.SHRTCKN_TERM_CODE, 
       p.SHRTCKN_SUBJ_CODE, 
       p.SHRTCKN_CRSE_NUMB, 
       COUNT(DISTINCT h.SHRTCKN_TERM_CODE) COURSE_COUNT 
FROM SHRTCKN p, 
     SHRTCKN h, 
     SCREQIV, 
     --SHRTCKG gp, 
     SHRTCKG gh
WHERE p.SHRTCKN_PIDM = h.SHRTCKN_PIDM 
      AND p.SHRTCKN_TERM_CODE > h.SHRTCKN_TERM_CODE 
      /*AND p.SHRTCKN_PIDM = gp.SHRTCKG_PIDM 
      AND p.SHRTCKN_TERM_CODE = gp.SHRTCKG_TERM_CODE 
      AND p.SHRTCKN_SEQ_NO = gp.SHRTCKG_TCKN_SEQ_NO       
      AND gp.SHRTCKG_SEQ_NO = (SELECT MAX(G2.SHRTCKG_SEQ_NO) 
                               FROM SHRTCKG G2
                               WHERE gp.SHRTCKG_PIDM        = G2.SHRTCKG_PIDM
                                AND gp.SHRTCKG_TERM_CODE    = G2.SHRTCKG_TERM_CODE
                                AND gp.SHRTCKG_TCKN_SEQ_NO  = G2.SHRTCKG_TCKN_SEQ_NO) 
      AND gp.SHRTCKG_GRDE_CODE_FINAL NOT LIKE 'R%' */
      AND p.SHRTCKN_SUBJ_CODE NOT IN ('TUTO','REPS','XSER','ACAD','TEST','XPEN','IDIO')
      AND h.SHRTCKN_PIDM = gh.SHRTCKG_PIDM 
      AND h.SHRTCKN_TERM_CODE = gh.SHRTCKG_TERM_CODE 
      AND h.SHRTCKN_SEQ_NO = gh.SHRTCKG_TCKN_SEQ_NO 
      AND gh.SHRTCKG_SEQ_NO = (SELECT MAX(G1.SHRTCKG_SEQ_NO) 
                               FROM SHRTCKG G1
                               WHERE gh.SHRTCKG_PIDM        = G1.SHRTCKG_PIDM
                                AND gh.SHRTCKG_TERM_CODE    = G1.SHRTCKG_TERM_CODE
                                AND gh.SHRTCKG_TCKN_SEQ_NO  = G1.SHRTCKG_TCKN_SEQ_NO) 
      AND gh.SHRTCKG_GRDE_CODE_FINAL NOT LIKE 'R%' 
      AND ( (h.SHRTCKN_SUBJ_CODE = p.SHRTCKN_SUBJ_CODE 
                  AND h.SHRTCKN_CRSE_NUMB = p.SHRTCKN_CRSE_NUMB) 
              OR (SCREQIV_SUBJ_CODE = p.SHRTCKN_SUBJ_CODE 
                  AND SCREQIV_CRSE_NUMB = p.SHRTCKN_CRSE_NUMB) ) 
      AND ( h.SHRTCKN_SUBJ_CODE = SCREQIV_SUBJ_CODE_EQIV(+) 
              AND h.SHRTCKN_CRSE_NUMB = SCREQIV_CRSE_NUMB_EQIV(+) 
              AND h.SHRTCKN_TERM_CODE BETWEEN SCREQIV_START_TERM(+) AND SCREQIV_END_TERM(+) ) 
      --TEST
        --AND p.SHRTCKN_PIDM IN (188944,139706,72736)
        --AND p.SHRTCKN_PIDM IN (65731,55094,97876,181308)
        AND p.SHRTCKN_PIDM = 139706
      --TEST
GROUP BY p.SHRTCKN_PIDM, 
         p.SHRTCKN_TERM_CODE, 
         p.SHRTCKN_SUBJ_CODE, 
         p.SHRTCKN_CRSE_NUMB
         