SELECT sfrstcr_pidm, 
       sfrstcr_term_code, 
       ssbsect_subj_code, 
       ssbsect_crse_numb, 
       COUNT(DISTINCT shrtckn_term_code) course_count 
FROM sfrstcr, 
     shrtckn, 
     screqiv, 
     ssbsect, 
     shrtckg 
WHERE shrtckn_pidm = sfrstcr_pidm 
      AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA','IA','RO')
      AND SSBSECT_SUBJ_CODE NOT IN ('TUTO','REPS','XSER','ACAD','TEST','XPEN')
      AND shrtckn_pidm = shrtckg_pidm 
      AND shrtckn_term_code = shrtckg_term_code 
      AND shrtckn_seq_no = shrtckg_tckn_seq_no 
      AND ( shrtckg_grde_code_final NOT IN (SELECT SHRGRDE_CODE
                                            FROM SHRGRDE
                                            WHERE SHRGRDE_PASSED_IND = 'Y')
              AND shrtckg_grde_code_final NOT LIKE 'R%' 
              AND ODSMGR.F_CRSE_EQIV_AP (SHRTCKN_PIDM,SHRTCKN_TERM_CODE, SHRTCKN_SUBJ_CODE,SHRTCKN_CRSE_NUMB) = 'N' )
      AND ( (shrtckn_subj_code = ssbsect_subj_code 
                  AND shrtckn_crse_numb = ssbsect_crse_numb) 
              OR (screqiv_subj_code = ssbsect_subj_code 
                  AND screqiv_crse_numb = ssbsect_crse_numb) ) 
      AND ( shrtckn_subj_code = screqiv_subj_code_eqiv(+) 
              AND shrtckn_crse_numb = screqiv_crse_numb_eqiv(+) 
              AND shrtckn_term_code BETWEEN screqiv_start_term(+) AND screqiv_end_term(+) ) 
      AND sfrstcr_term_code = ssbsect_term_code 
      AND sfrstcr_crn = ssbsect_crn 
GROUP BY sfrstcr_pidm, 
         sfrstcr_term_code, 
         ssbsect_subj_code, 
         ssbsect_crse_numb;