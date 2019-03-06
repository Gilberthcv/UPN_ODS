SELECT sfrstcr_pidm, 
       sfrstcr_term_code, 
       ssbsect_subj_code, 
       ssbsect_crse_numb, 
       COUNT (DISTINCT shrtckn_term_code) course_count 
FROM   sfrstcr, --historial inscripcion
       shrtckn, --historia
       screqiv, --equivalencias
       ssbsect, --clases
       shrtckg  --calificaciones historia
WHERE  shrtckn_pidm = sfrstcr_pidm 
       AND shrtckn_pidm = shrtckg_pidm 
       AND shrtckn_term_code = shrtckg_term_code 
       AND shrtckn_seq_no = shrtckg_tckn_seq_no 
       AND shrtckg_grde_code_final IN (SELECT shrgrde_code 
                                       FROM   shrgrde 
                                       WHERE  shrgrde_passed_ind = 'Y' 
                                              AND shrgrde_levl_code = 'UG' 
                                               OR shrtckg_grde_code_final NOT 
                                                  LIKE 'R%' 
                                      ) 
       AND ( ( shrtckn_subj_code = ssbsect_subj_code 
               AND shrtckn_crse_numb = ssbsect_crse_numb ) 
              OR ( screqiv_subj_code = ssbsect_subj_code 
                   AND screqiv_crse_numb = ssbsect_crse_numb ) ) 
       AND ( shrtckn_subj_code = screqiv_subj_code_eqiv(+) 
             AND shrtckn_crse_numb = screqiv_crse_numb_eqiv(+) 
             AND shrtckn_term_code BETWEEN screqiv_start_term(+) AND 
                                           screqiv_end_term(+) ) 
       AND sfrstcr_term_code = ssbsect_term_code 
       AND sfrstcr_crn = ssbsect_crn 
        AND sfrstcr_pidm = 158481
GROUP BY sfrstcr_pidm, 
          ssbsect_subj_code, 
          ssbsect_crse_numb, 
          sfrstcr_term_code;
          
SELECT * FROM sfrstcr; --historial inscripcion
SELECT * FROM shrtckn; --historia
SELECT * FROM screqiv; --equivalencias
SELECT * FROM ssbsect; --clases
SELECT * FROM shrtckg; --calificaciones historia

SELECT * FROM LOE_REPEAT_ATTR;
SELECT * FROM LOE_REPEAT_COURSE;
SELECT * FROM LOE_REPEAT_COURSE_CRN;
