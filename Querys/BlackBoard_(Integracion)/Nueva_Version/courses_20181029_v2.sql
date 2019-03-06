select 'EXTERNAL_COURSE_KEY|COURSE_ID|COURSE_NAME|AVAILABLE_IND|ROW_STATUS|DURATION|START_DATE|END_DATE|TERM_KEY|DATA_SOURCE_KEY|PRIMARY_EXTERNAL_NODE_KEY|EXTERNAL_ASSOCIATION_KEY' from dual;
SELECT distinct a.external_course_key||'|'||
       a.course_id||'|'||
       a.course_name||'|'||
       a.available_ind||'|'||
       a.row_status||'|'||
       a.duration||'|'||
       a.start_date||'|'||
       a.end_date||'|'||
       a.term_key||'|'||
       a.data_source_key||'|'||
       a.ssbsect_camp_code||'.'||b.primary_external_node_key||'|'||
       b.primary_external_node_key ||'.'|| a.ssbsect_crn
  FROM (SELECT DISTINCT a.ssbsect_term_code,
                        a.ssbsect_crn,
                        a.ssbsect_camp_code,
                        case when a.ssbsect_insm_code='V' then a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                        a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V' else 
                        a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                        a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' end  AS external_course_key,
                        case when a.ssbsect_insm_code='V' then a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                        a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V' else
                        a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                        a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' end AS course_id,
                        case when a.ssbsect_insm_code='V' then b.scbcrse_title||'(Virtual)' else b.scbcrse_title||'(Presencial)' end AS course_name,
                        CASE
                          WHEN a.ssbsect_ssts_code = 'A' THEN
                           'Y'
                          ELSE
                           'N'
                        END AS available_ind,
                        CASE
                          WHEN a.ssbsect_ssts_code = 'A' THEN
                           'ENABLED'
                          ELSE
                           'DISABLED'
                        END AS row_status,
                        'R' AS duration,
                        to_char(a.ssbsect_ptrm_start_date,
                                'YYYYMMDD') AS start_date,
                        to_char(a.ssbsect_ptrm_end_date,
                                'YYYYMMDD') AS end_date,
                        a.ssbsect_term_code AS term_key,
                        'Banner' AS data_source_key
          FROM ssbsect a,
               scbcrse b
         WHERE a.ssbsect_crse_numb = b.scbcrse_crse_numb
           AND a.ssbsect_subj_code = b.scbcrse_subj_code
           and a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
           --AND a.ssbsect_insm_code = 'V'
           AND a.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                                      WHERE sobptrm_start_date <= SYSDATE AND sobptrm_end_date >= SYSDATE)) a,

       (SELECT DISTINCT a.ssrattr_term_code,
                        a.ssrattr_crn,
                        CASE
                          WHEN a.ssrattr_attr_code = 'DHUM' THEN
                           'DHUM'
                          WHEN a.ssrattr_attr_code = 'DCIE' THEN
                           'DCIE'
                          ELSE
                           d.sobcurr_program
                        END AS primary_external_node_key
          FROM ssrattr a,
               stvmajr b,
               sorcmjr c,
               sobcurr d
         WHERE a.ssrattr_attr_code = b.stvmajr_code(+)
           AND c.sorcmjr_majr_code(+) = b.stvmajr_code
           AND d.sobcurr_curr_rule(+) = c.sorcmjr_curr_rule
           AND a.ssrattr_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                                      WHERE sobptrm_start_date <= SYSDATE AND sobptrm_end_date >= SYSDATE)) b
       
 WHERE a.ssbsect_term_code = b.ssrattr_term_code
   AND a.ssbsect_crn = b.ssrattr_crn;
   spool off