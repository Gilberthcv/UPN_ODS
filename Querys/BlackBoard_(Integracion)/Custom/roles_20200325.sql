SELECT DISTINCT
    a.sfrstcr_pidm AS EXTERNAL_PERSON_KEY
    , 'PEPN01.UPN.Estudiante.' ||
    CASE substr(a.sfrstcr_term_code,4,1)
        WHEN '3' THEN 'PN'
        WHEN '4' THEN 'UG'
        WHEN '5' THEN 'WA'
        WHEN '7' THEN 'IN'
      ELSE 'EP' END ||'.'||
    CASE WHEN b.ssbsect_camp_code IN ('TML','TSI') THEN 'TRU' ELSE b.ssbsect_camp_code END AS ROLE_ID
    , CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
        WHEN '3' THEN 'UPN.Rol.Banner.PDN'
        WHEN '4' THEN 'UPN.Rol.Banner.UG'
        WHEN '5' THEN 'UPN.Rol.Banner.WA'
        WHEN '7' THEN 'UPN.Rol.Banner.Ingles'
      ELSE 'UPN.Rol.Banner.EPEC' END AS DATA_SOURCE_KEY
FROM sfrstcr a,
     ssbsect b,
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
          , MIN(SSRMEET_START_DATE) AS START_DATE
          , MAX(SSRMEET_END_DATE) AS END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) c
WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
    AND b.ssbsect_term_code = c.ssrmeet_term_code AND b.ssbsect_crn = c.ssrmeet_crn
    AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
    AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
    AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
    AND c.START_DATE <= CURRENT_DATE +7 AND c.END_DATE >= CURRENT_DATE -16
    AND b.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                WHERE start_date <= CURRENT_DATE +7 AND end_date >= CURRENT_DATE -16)
UNION
SELECT DISTINCT
    a.sfrstcr_pidm
    , 'PEPN01.UPN.Estudiante.VIRTUAL'
    , CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
        WHEN '3' THEN 'UPN.Rol.Banner.PDN'
        WHEN '4' THEN 'UPN.Rol.Banner.UG'
        WHEN '5' THEN 'UPN.Rol.Banner.WA'
        WHEN '7' THEN 'UPN.Rol.Banner.Ingles'
      ELSE 'UPN.Rol.Banner.EPEC' END
FROM sfrstcr a,
     ssbsect b,
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
          , MIN(SSRMEET_START_DATE) AS START_DATE
          , MAX(SSRMEET_END_DATE) AS END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) c
WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
    AND b.ssbsect_term_code = c.ssrmeet_term_code AND b.ssbsect_crn = c.ssrmeet_crn
    AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
    AND (b.SSBSECT_SCHD_CODE = 'VIR' OR b.ssbsect_insm_code = 'V')
    AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
    AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
    AND c.START_DATE <= CURRENT_DATE +7 AND c.END_DATE >= CURRENT_DATE -16
    AND b.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                WHERE start_date <= CURRENT_DATE +7 AND end_date >= CURRENT_DATE -16)
UNION
SELECT DISTINCT
    c.sirasgn_pidm
    , 'PEPN01.UPN.Docente.' ||
    CASE substr(c.sirasgn_term_code,4,1)
        WHEN '3' THEN 'PN'
        WHEN '4' THEN 'UG'
        WHEN '5' THEN 'WA'
        WHEN '7' THEN 'IN'
      ELSE 'EP' END
    , CASE SUBSTR(c.sirasgn_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
        WHEN '3' THEN 'UPN.Rol.Banner.PDN'
        WHEN '4' THEN 'UPN.Rol.Banner.UG'
        WHEN '5' THEN 'UPN.Rol.Banner.WA'
        WHEN '7' THEN 'UPN.Rol.Banner.Ingles'
      ELSE 'UPN.Rol.Banner.EPEC' END
FROM sirasgn c,
     ssbsect d,
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
          , MIN(SSRMEET_START_DATE) AS START_DATE
          , MAX(SSRMEET_END_DATE) AS END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
WHERE c.sirasgn_term_code = d.ssbsect_term_code AND c.sirasgn_crn = d.ssbsect_crn
    AND d.ssbsect_term_code = e.ssrmeet_term_code AND d.ssbsect_crn = e.ssrmeet_crn
    AND d.SSBSECT_SSTS_CODE = 'A' AND d.SSBSECT_MAX_ENRL > 0 AND d.SSBSECT_ENRL > 0
    AND d.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
    AND e.START_DATE <= CURRENT_DATE +7 AND e.END_DATE >= CURRENT_DATE -16
    and d.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                WHERE start_date <= CURRENT_DATE +7 AND end_date >= CURRENT_DATE -16)
UNION
SELECT DISTINCT
    c.sirasgn_pidm
    , 'PEPN01.UPN.Docente.VIRTUAL'
    , CASE SUBSTR(c.sirasgn_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
        WHEN '3' THEN 'UPN.Rol.Banner.PDN'
        WHEN '4' THEN 'UPN.Rol.Banner.UG'
        WHEN '5' THEN 'UPN.Rol.Banner.WA'
        WHEN '7' THEN 'UPN.Rol.Banner.Ingles'
      ELSE 'UPN.Rol.Banner.EPEC' END
FROM sirasgn c,
     ssbsect d,
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
          , MIN(SSRMEET_START_DATE) AS START_DATE
          , MAX(SSRMEET_END_DATE) AS END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
WHERE c.sirasgn_term_code = d.ssbsect_term_code AND c.sirasgn_crn = d.ssbsect_crn
    AND d.ssbsect_term_code = e.ssrmeet_term_code AND d.ssbsect_crn = e.ssrmeet_crn
    AND (d.SSBSECT_SCHD_CODE = 'VIR' OR d.ssbsect_insm_code = 'V')
    AND d.SSBSECT_SSTS_CODE = 'A' AND d.SSBSECT_MAX_ENRL > 0 AND d.SSBSECT_ENRL > 0
    AND d.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
    AND e.START_DATE <= CURRENT_DATE +7 AND e.END_DATE >= CURRENT_DATE -16
    and d.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                WHERE start_date <= CURRENT_DATE +7 AND end_date >= CURRENT_DATE -16);
