 select 'EXTERNAL_NODE_KEY|NAME|PARENT_NODE_KEY|DATA_SOURCE_KEY' from dual;
       SELECT
           DISTINCT 'PEPN01.UPN'
           ||'|UPN'
           ||'|PEPN01'
           ||'|Banner'
       FROM sorlcur a
       WHERE a.sorlcur_cact_code = 'ACTIVE'
         AND a.sorlcur_lmod_code = 'LEARNER'
         AND a.sorlcur_current_cde = 'Y'
         AND a.sorlcur_levl_code <> 'CR'
         AND a.sorlcur_program NOT IN ('SIS-EA',
                                       'IND-EA',
                                       'IND-FS',
                                       'ADM-EA','SIS-FS',
                                       'ADM-FS')
       UNION 
      ( SELECT
           DISTINCT 'PEPN01.UPN.'
           || CASE
               WHEN b.sorlcur_levl_code = 'UG'
                   AND substr(b.sorlcur_program,
                                  5,
                                  6) = 'UG'
                   AND b.sorlcur_program <> 'PDN-UG'
               THEN
                   'UG'
               WHEN b.sorlcur_levl_code = 'UG'
                   AND substr(b.sorlcur_program,
                                  5,
                                  6) = 'WA'
               THEN
                   'WA'
               WHEN b.sorlcur_levl_code = 'UG'
                   AND b.sorlcur_program = 'PDN-UG'
               THEN
                   'PN'
               WHEN b.sorlcur_levl_code IN ('DO',
                                            'EC',
                                            'MA')
               THEN
                   'EP'
               END
           ||'|'|| CASE
               WHEN b.sorlcur_levl_code = 'UG'
                   AND substr(b.sorlcur_program,
                                  5,
                                  6) = 'UG'
                   AND b.sorlcur_program <> 'PDN-UG'
               THEN
                   'Pregrado Regular'
               WHEN b.sorlcur_levl_code = 'UG'
                   AND substr(b.sorlcur_program,
                                  5,
                                  6) = 'WA'
               THEN
                   'Working Adult'
               WHEN b.sorlcur_levl_code = 'UG'
                   AND b.sorlcur_program = 'PDN-UG'
               THEN
                   'Programa de Nivelacion'
               WHEN b.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA')
               THEN
                   'Escuela de Posgrado'
               END
           ||'|PEPN01.UPN'
           ||'|Banner'
       FROM sorlcur b
       WHERE b.sorlcur_cact_code = 'ACTIVE'
         AND b.sorlcur_lmod_code = 'LEARNER'
         AND b.sorlcur_current_cde = 'Y'
         AND b.sorlcur_levl_code <> 'CR'
         AND b.sorlcur_program NOT IN ('SIS-EA',
                                       'IND-EA',
                                       'IND-FS',
                                       'ADM-EA','SIS-FS',
                                       'ADM-FS')
       minus                             
    SELECT
           DISTINCT 'PEPN01.UPN.'
           || CASE
               WHEN b.sorlcur_levl_code = 'UG'
                   AND b.sorlcur_program ='PDN-UG'
               THEN
                   'PN'
               END
           ||'|'|| CASE
               WHEN b.sorlcur_levl_code = 'UG'
                   AND b.sorlcur_program = 'PDN-UG'
               THEN
                  'Programa de Nivelacion'
               END
           ||'|PEPN01.UPN'
           ||'|Banner'
       FROM sorlcur b
       WHERE b.sorlcur_cact_code = 'ACTIVE'
         AND b.sorlcur_lmod_code = 'LEARNER'
         AND b.sorlcur_current_cde = 'Y'
         AND b.sorlcur_levl_code <> 'CR'
         AND b.sorlcur_program NOT IN ('SIS-EA',
                                       'IND-EA',
                                       'IND-FS',
                                       'ADM-EA','SIS-FS',
                                       'ADM-FS'))                            
       UNION     
       (SELECT DISTINCT 'PEPN01.UPN.'
       || CASE
           WHEN d.sorlcur_levl_code = 'UG'
               AND substr(d.sorlcur_program,
                                  5,
                                  6) = 'UG'
               AND d.sorlcur_program <> 'PDN-UG'
           THEN
               'UG'
           WHEN d.sorlcur_levl_code = 'UG'
                       AND substr(d.sorlcur_program,
                                  5,
                                  6) = 'WA'
           THEN
                   'WA'
           WHEN d.sorlcur_levl_code = 'UG'
                       AND d.sorlcur_program = 'PDN-UG'
           THEN
                   'PN'
           WHEN d.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA')
           THEN
                   'EP'
           END
       || '.' || CASE
                  WHEN d.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   d.sorlcur_camp_code
                END||'|'||
                case when d1.stvcamp_desc like 'Trujillo%' then 'Trujillo' else d1.stvcamp_desc end||
                '|PEPN01.UPN.' || CASE
                  WHEN d.sorlcur_levl_code = 'UG'
                       AND substr(d.sorlcur_program,
                                  5,
                                  6) = 'UG'
                       AND d.sorlcur_program <> 'PDN-UG' THEN
                   'UG'
                  WHEN d.sorlcur_levl_code = 'UG'
                       AND substr(d.sorlcur_program,
                                  5,
                                  6) = 'WA' THEN
                   'WA'
                  WHEN d.sorlcur_levl_code = 'UG'
                       AND d.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                  WHEN d.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA') THEN
                   'EP'
                END ||
                '|Banner'
  FROM sorlcur d,
       stvcamp d1
 WHERE d.sorlcur_camp_code = d1.stvcamp_code
   AND d.sorlcur_cact_code = 'ACTIVE'
   AND d.sorlcur_lmod_code = 'LEARNER'
   AND d.sorlcur_current_cde = 'Y'
   AND d.sorlcur_levl_code <> 'CR'
   AND d.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS')
minus
SELECT DISTINCT 'PEPN01.UPN.'
       || CASE
           WHEN d.sorlcur_levl_code = 'UG'
               AND d.sorlcur_program ='PDN-UG'
           THEN
               'PN'
           END
       || '.' || CASE
                  WHEN d.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   d.sorlcur_camp_code
                END||'|'||
                case when d1.stvcamp_desc like 'Trujillo%' then 'Trujillo' else d1.stvcamp_desc end||
                '|PEPN01.UPN.' || CASE
                  WHEN d.sorlcur_levl_code = 'UG'
                       AND d.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                END ||
                '|Banner'
  FROM sorlcur d,
       stvcamp d1
 WHERE d.sorlcur_camp_code = d1.stvcamp_code
   AND d.sorlcur_cact_code = 'ACTIVE'
   AND d.sorlcur_lmod_code = 'LEARNER'
   AND d.sorlcur_current_cde = 'Y'
   AND d.sorlcur_levl_code <> 'CR'
   AND d.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS'))
UNION     
(SELECT DISTINCT 'PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'UG'
                       AND e.sorlcur_program <> 'PDN-UG' THEN
                   'UG'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'WA' THEN
                   'WA'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                  WHEN e.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA') THEN
                   'EP'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||'|'||
                e1.smrprle_program_desc||
                '|PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'UG'
                       AND e.sorlcur_program <> 'PDN-UG' THEN
                   'UG'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'WA' THEN
                   'WA'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                  WHEN e.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA') THEN
                   'EP'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END||
                '|Banner'
  FROM sorlcur e,
       smrprle e1
 WHERE e.sorlcur_program = e1.smrprle_program
   AND e.sorlcur_cact_code = 'ACTIVE'
   AND e.sorlcur_lmod_code = 'LEARNER'
   AND e.sorlcur_current_cde = 'Y'
   AND e.sorlcur_levl_code <> 'CR'
   AND e.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS')       
 minus                
SELECT DISTINCT 'PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||'|'||
                e1.smrprle_program_desc||
                '|PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END||
                '|Banner'
  FROM sorlcur e,
       smrprle e1
 WHERE e.sorlcur_program = e1.smrprle_program
   AND e.sorlcur_cact_code = 'ACTIVE'
   AND e.sorlcur_lmod_code = 'LEARNER'
   AND e.sorlcur_current_cde = 'Y'
   AND e.sorlcur_levl_code <> 'CR'
   AND e.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS'))                          
UNION
(SELECT DISTINCT 'PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'UG'
                       AND e.sorlcur_program <> 'PDN-UG' THEN
                   'UG'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'WA' THEN
                   'WA'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                  WHEN e.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA') THEN
                   'EP'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||'.'||e.sorlcur_term_code||'|'||
                e.sorlcur_term_code||
                '|PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'UG'
                       AND e.sorlcur_program <> 'PDN-UG' THEN
                   'UG'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND substr(e.sorlcur_program,
                                  5,
                                  6) = 'WA' THEN
                   'WA'
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                  WHEN e.sorlcur_levl_code IN ('DO',
                                               'EC',
                                               'MA') THEN
                   'EP'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||
                '|Banner'
  FROM sorlcur e
 WHERE e.sorlcur_cact_code = 'ACTIVE'
   AND e.sorlcur_lmod_code = 'LEARNER'
   AND e.sorlcur_current_cde = 'Y'
   AND e.sorlcur_levl_code <> 'CR'
   AND e.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS')
   AND e.sorlcur_term_code like '218%'
   minus---------------------------
  SELECT DISTINCT 'PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||'.'||e.sorlcur_term_code||'|'||
                e.sorlcur_term_code||
                '|PEPN01.UPN.' || CASE
                  WHEN e.sorlcur_levl_code = 'UG'
                       AND e.sorlcur_program = 'PDN-UG' THEN
                   'PN'
                END || '.' || CASE
                  WHEN e.sorlcur_camp_code IN ('TML',
                                               'TSI') THEN
                   'TRU'
                  ELSE
                   e.sorlcur_camp_code
                END || '.' || e.sorlcur_program||
                '|Banner'
  FROM sorlcur e
 WHERE e.sorlcur_cact_code = 'ACTIVE'
   AND e.sorlcur_lmod_code = 'LEARNER'
   AND e.sorlcur_current_cde = 'Y'
   AND e.sorlcur_levl_code <> 'CR'
   AND e.sorlcur_program NOT IN ('SIS-EA',
                                 'IND-EA',
                                 'IND-FS',
                                 'ADM-EA','SIS-FS',
                                 'ADM-FS')
   AND e.sorlcur_term_code like '218%' );                                                                                            
  spool off 