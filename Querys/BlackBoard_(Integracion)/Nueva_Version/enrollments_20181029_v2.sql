select 'EXTERNAL_COURSE_KEY|EXTERNAL_PERSON_KEY|ROLE|DATA_SOURCE_KEY' from dual;
SELECT DISTINCT case when a.ssbsect_insm_code='V' then a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V' else
                a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' end||'|'||
                b.sfrstcr_pidm||
                '|S'||
                '|Banner'
  FROM ssbsect a,
       sfrstcr b,
       stvrsts c,
       sgbstdn d
 WHERE b.sfrstcr_rsts_code = c.stvrsts_code
   AND a.ssbsect_term_code = b.sfrstcr_term_code
   AND a.ssbsect_crn = b.sfrstcr_crn
   AND b.sfrstcr_pidm = d.sgbstdn_pidm
   AND b.sfrstcr_rsts_code IN ('RE',
                               'RW','RA')
   AND a.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                              WHERE sobptrm_start_date <= SYSDATE AND sobptrm_end_date >= SYSDATE)
   AND    a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
   UNION
 SELECT DISTINCT case when a.ssbsect_insm_code='V' then a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V'
                else a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' end||'|'||
                b.sirasgn_pidm||'|'||
                Case when a.ssbsect_insm_code = 'V' then  'PV' else 'PP' end||'|'||
                'Banner' AS data_source_key
  FROM ssbsect a,
       sirasgn b
 WHERE a.ssbsect_term_code = b.sirasgn_term_code
   AND a.ssbsect_crn = b.sirasgn_crn
   AND a.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                              WHERE sobptrm_start_date <= SYSDATE AND sobptrm_end_date >= SYSDATE)
   AND a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER');
   spool off