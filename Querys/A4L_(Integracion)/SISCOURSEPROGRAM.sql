--SISCOURSEPROGRAM
/*SISCourseKey
ProgramCode
Program*/
SELECT DISTINCT
    CASE WHEN SSBSECT_SCHD_CODE = 'VIR' OR SSBSECT_INSM_CODE = 'V'
        THEN SSBSECT_SUBJ_CODE ||'.'|| SSBSECT_CRSE_NUMB ||'.'|| SSBSECT_TERM_CODE ||'.'|| SSBSECT_CRN ||'.'|| 'V'
      ELSE SSBSECT_SUBJ_CODE ||'.'|| SSBSECT_CRSE_NUMB ||'.'|| SSBSECT_TERM_CODE ||'.'|| SSBSECT_CRN ||'.'|| 'P' END AS SISCourseKey
    , SSRATTR_ATTR_CODE AS ProgramCode
    , STVATTR_DESC AS Program
FROM SSBSECT, 
     SSRATTR, 
     STVATTR, 
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
          , MAX(SSRMEET_END_DATE) AS SSRMEET_END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN)
WHERE SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
    AND SSRATTR_ATTR_CODE = STVATTR_CODE
    AND SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSRMEET_END_DATE >= '01/01/2018'
    AND SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                    WHERE END_DATE >= '01/01/2018');
