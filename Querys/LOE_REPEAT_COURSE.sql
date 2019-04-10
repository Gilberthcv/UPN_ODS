SELECT SFRREGP_PIDM, 
       SFRREGP_SUBJ_CODE,
       SFRREGP_CRSE_NUMB_LOW,
       sfrregp_term_code,
       COUNT(distinct SHRTCKN_TERM_CODE) course_count
FROM SFRREGP, 
     SHRTCKN, 
     SCREQIV, 
     SHRTCKG
WHERE shrtckn_pidm = sfrregp_pidm
      and shrtckn_pidm = shrtckg_pidm 
      and shrtckn_term_code = shrtckg_term_code
      and shrtckn_seq_no = shrtckg_tckn_seq_no
      and shrtckg_grde_code_final IN (SELECT SHRGRDE_CODE
                                      FROM  SHRGRDE
                                      WHERE SHRGRDE_PASSED_IND = 'Y'
                                            AND  SHRGRDE_LEVL_CODE = 'UG'
                                            OR shrtckg_grde_code_final not like 'R%')
      and ((shrtckn_subj_code = sfrregp_subj_code and shrtckn_crse_numb = sfrregp_crse_numb_low)
            or (screqiv_subj_code = sfrregp_subj_code and screqiv_crse_numb = sfrregp_crse_numb_low))
      and (shrtckn_subj_code = screqiv_subj_code_eqiv(+) 
      and shrtckn_crse_numb = screqiv_crse_numb_eqiv(+)
      and shrtckn_term_code between screqiv_start_term(+) and screqiv_end_term(+))
GROUP BY SFRREGP_PIDM, 
         SFRREGP_SUBJ_CODE,
         SFRREGP_CRSE_NUMB_LOW,
         sfrregp_term_code
         