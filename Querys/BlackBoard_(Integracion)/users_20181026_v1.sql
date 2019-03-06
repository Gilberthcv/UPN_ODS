select 'EXTERNAL_PERSON_KEY|USER_ID|FIRSTNAME|LASTNAME|EMAIL|ROW_STATUS|AVAILABLE_IND|DATA_SOURCE_KEY|M_PHONE' from dual;
SELECT DISTINCT a.gobsrid_pidm||'|'||
                b.spriden_id||'|'||
                b.spriden_first_name || b.spriden_mi||'|'||
                REPLACE(b.spriden_last_name,
                        '/',
                        ' ')||'|'||
                 b.spriden_id||'@upn.pe'||'|'||  --bannerID@upn.pe
                CASE
                  WHEN c.sgbstdn_stst_code = 'AS' THEN
                   'ENABLED'
                  ELSE
                   'DISABLED'
                END||'|'||
                CASE
                  WHEN c.sgbstdn_stst_code = 'AS' THEN
                   'Y'
                  ELSE
                   'N'
                END||
                '|Banner'||'|'||case when h.sprtele_tele_code='CP' then  h.sprtele_phone_number else null end
  FROM gobsrid a,
       spriden b,
       sgbstdn c,
       ssbsect e,
       sfrstcr f,
       stvrsts g,
       SPRTELE  h
 WHERE a.gobsrid_pidm = b.spriden_pidm
         AND b.spriden_pidm = c.sgbstdn_pidm
         AND b.spriden_change_ind IS NULL
         AND c.sgbstdn_stst_code = 'AS'
         AND f.sfrstcr_rsts_code = g.stvrsts_code
         AND e.ssbsect_term_code = f.sfrstcr_term_code
         AND e.ssbsect_crn = f.sfrstcr_crn
         AND f.sfrstcr_pidm = c.sgbstdn_pidm
        AND f.sfrstcr_rsts_code IN ('RE',
                                   'RW','RA')
       and e.ssbsect_term_code like '218%'
       and b.spriden_pidm=h.sprtele_pidm(+)
       and h.sprtele_tele_code(+)='CP'
         AND EXISTS (SELECT 1
                FROM sfbetrm b
               WHERE b.sfbetrm_pidm = c.sgbstdn_pidm
                 AND sfbetrm_ests_code = 'EL'
                )
UNION
SELECT DISTINCT a.gobsrid_pidm||'|'||
                b.spriden_id||'|'||
                b.spriden_first_name || b.spriden_mi||'|'||
                REPLACE(b.spriden_last_name,
                        '/',
                        ' ')||'|'||
                b.spriden_id || '@upn.pe'||'|'|| ----bannerID@upn.pe
                CASE
                  WHEN c1.sibinst_fcst_code = 'AC' THEN
                   'ENABLED'
                  ELSE
                   'DISABLED'
                END||'|'||
                CASE
                  WHEN c1.sibinst_fcst_code = 'AC' THEN
                   'Y'
                  ELSE
                   'N'
                END||
                '|Banner'||'|'||case when h.sprtele_tele_code='CP' then  h.sprtele_phone_number else null end
  FROM gobsrid a,
       spriden b,
       sibinst c1,
       ssbsect e,
       SPRTELE  h,
       sirasgn f
 WHERE a.gobsrid_pidm = b.spriden_pidm
   AND c1.sibinst_pidm = f.sirasgn_pidm
   AND b.spriden_pidm = f.sirasgn_pidm
   AND b.spriden_change_ind IS NULL
   AND c1.sibinst_fcst_code = 'AC'
   AND e.ssbsect_term_code = f.sirasgn_term_code
   AND f.sirasgn_pidm=h.sprtele_pidm(+)
   AND h.sprtele_tele_code(+)='CP'
   AND e.ssbsect_crn = f.sirasgn_crn
   AND e.ssbsect_term_code  like '218%';
   spool off