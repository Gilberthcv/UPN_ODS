--SISCOURSESCHEDULE
/*SISCourseKey
WeekDay
Hour
Building
Classroom*/
SELECT DISTINCT
    CASE WHEN SSBSECT_SCHD_CODE = 'VIR' OR SSBSECT_INSM_CODE = 'V'
        THEN SSBSECT_SUBJ_CODE ||'.'|| SSBSECT_CRSE_NUMB ||'.'|| SSBSECT_TERM_CODE ||'.'|| SSBSECT_CRN ||'.'|| 'V'
      ELSE SSBSECT_SUBJ_CODE ||'.'|| SSBSECT_CRSE_NUMB ||'.'|| SSBSECT_TERM_CODE ||'.'|| SSBSECT_CRN ||'.'|| 'P' END AS SISCourseKey
    , SUBSTR(SSRMEET_SUN_DAY || SSRMEET_MON_DAY || SSRMEET_TUE_DAY || SSRMEET_WED_DAY || SSRMEET_THU_DAY || SSRMEET_FRI_DAY || SSRMEET_SAT_DAY,1,1) AS WeekDay
    , SSRMEET_BEGIN_TIME ||' - '|| SSRMEET_END_TIME AS Hour
    , SSRMEET_BLDG_CODE AS Building
    , SSRMEET_ROOM_CODE AS Classroom
FROM SSBSECT, 
     (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN, SSRMEET_BEGIN_TIME, SSRMEET_END_TIME, SSRMEET_BLDG_CODE, SSRMEET_ROOM_CODE
          , SSRMEET_SUN_DAY, SSRMEET_MON_DAY, SSRMEET_TUE_DAY, SSRMEET_WED_DAY, SSRMEET_THU_DAY, SSRMEET_FRI_DAY, SSRMEET_SAT_DAY
          , MAX(SSRMEET_END_DATE) AS SSRMEET_END_DATE
      FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN, SSRMEET_BEGIN_TIME, SSRMEET_END_TIME, SSRMEET_BLDG_CODE, SSRMEET_ROOM_CODE
          , SSRMEET_SUN_DAY, SSRMEET_MON_DAY, SSRMEET_TUE_DAY, SSRMEET_WED_DAY, SSRMEET_THU_DAY, SSRMEET_FRI_DAY, SSRMEET_SAT_DAY)
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSRMEET_END_DATE >= '01/01/2018'
    AND SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                    WHERE END_DATE >= '01/01/2018');
