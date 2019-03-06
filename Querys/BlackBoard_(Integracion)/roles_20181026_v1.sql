Select 'EXTERNAL_PERSON_KEY|ROLE_ID|DATA_SOURCE_KEY' from dual;
(SELECT distinct  a.gobsrid_pidm||
       '|PEPN01.UPN.Estudiante.' || CASE
         WHEN b.sorlcur_levl_code = 'UG'
              AND substr(b.sorlcur_program,
                         5,
                         6) = 'UG'
              AND b.sorlcur_program <> 'PDN-UG' THEN
          'UG'
         WHEN b.sorlcur_levl_code = 'UG'
              AND substr(b.sorlcur_program,
                         5,
                         6) = 'WA' THEN
          'WA'
         WHEN b.sorlcur_levl_code IN ('DO',
                                      'EC',
                                      'MA') THEN
          'EP'
       END || '.' || CASE
         WHEN b.sorlcur_camp_code IN ('TML',
                                      'TSI') THEN
          'TRU'
         ELSE
          b.sorlcur_camp_code
       END||
       '|Banner'
  FROM gobsrid a,
       sorlcur b,
       ssbsect e,
       sfrstcr  f
 WHERE a.gobsrid_pidm = b.sorlcur_pidm
   AND b.sorlcur_cact_code = 'ACTIVE'
   AND b.sorlcur_lmod_code = 'LEARNER'
   AND b.sorlcur_current_cde = 'Y'
   AND b.sorlcur_levl_code <> 'CR'
   AND e.ssbsect_term_code = f.sfrstcr_term_code
   AND f.sfrstcr_rsts_code IN ('RE','RW')
   AND e.ssbsect_crn = f.sfrstcr_crn
   AND f.sfrstcr_pidm=b.sorlcur_pidm
   minus
   SELECT distinct  a.gobsrid_pidm||
       '|PEPN01.UPN.Estudiante.' || CASE
         WHEN b.sorlcur_levl_code = 'UG'
              AND b.sorlcur_program='PDN-UG' THEN
          'PN'
       END || '.' || CASE
         WHEN b.sorlcur_camp_code IN ('TML',
                                      'TSI') THEN
          'TRU'
         ELSE
          b.sorlcur_camp_code
       END||
       '|Banner'
  FROM gobsrid a,
       sorlcur b,
       ssbsect e,
       sfrstcr  f
 WHERE a.gobsrid_pidm = b.sorlcur_pidm
   AND b.sorlcur_cact_code = 'ACTIVE'
   AND b.sorlcur_lmod_code = 'LEARNER'
   AND b.sorlcur_current_cde = 'Y'
   AND b.sorlcur_levl_code <> 'CR'
   AND e.ssbsect_term_code = f.sfrstcr_term_code
   AND f.sfrstcr_rsts_code IN ('RE','RW')
   AND e.ssbsect_crn = f.sfrstcr_crn
   AND f.sfrstcr_pidm=b.sorlcur_pidm)
union
SELECT distinct  a.gobsrid_pidm||'|'||
       'PEPN01.UPN.Docente.' || CASE
         WHEN instr(e.ssbsect_term_code,4,1,1)=4  THEN
          'UG'
         WHEN instr(e.ssbsect_term_code,5,1,1)=4 THEN
          'WA'
         WHEN instr(e.ssbsect_term_code,3,1,1)=4 THEN
          'PN'
          WHEN instr(e.ssbsect_term_code,8,1,1) =4 THEN 
          'EP'
          WHEN instr(e.ssbsect_term_code,9,1,1) =4 THEN 
          'EP'
          ELSE 'NA'
       END||
       '|Banner'
  FROM gobsrid a,
       ssbsect e,
       sfrstcr  f,
       sirasgn g
 WHERE 
     a.gobsrid_pidm=g.sirasgn_pidm
   AND a.gobsrid_pidm=f.sfrstcr_pidm
   AND e.ssbsect_term_code = f.sfrstcr_term_code
   AND f.sfrstcr_rsts_code IN ('RE','RW')
   AND e.ssbsect_crn = f.sfrstcr_crn
   and e.ssbsect_term_code LIKE ('218%');
    
   spool off