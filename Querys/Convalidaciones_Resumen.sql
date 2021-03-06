
SELECT C.SHRTRCE_PIDM, SPRIDEN_ID, CONCAT(CONCAT(SPRIDEN_LAST_NAME,', '),SPRIDEN_FIRST_NAME) AS ESTUDIANTE
    , C.SHRTRCE_LEVL_CODE, C.SHRTRCE_TERM_CODE_EFF, C.CURSOS, C.CREDITOS, C.SHRTRAM_USER_ID, C.FECHA, A.SOVLCUR_CAMP_CODE
    , A.SOVLCUR_PROGRAM, A.SOVLCUR_ADMT_CODE, MIN(B.SOVLCUR_TERM_CODE_ADMIT) AS PERIODO_ADMISION
    , C.COD_INSTITUCION, C.INSTITUCION, C.TIPO_INSTITUCION
FROM (SELECT SHRTRCE_PIDM, SHRTRCE_LEVL_CODE, SHRTRCE_TERM_CODE_EFF, COUNT(SHRTRCE_CREDIT_HOURS) AS CURSOS
          , SUM(SHRTRCE_CREDIT_HOURS) AS CREDITOS, SHRTRAM_USER_ID, MAX(SHRTRCE_ACTIVITY_DATE) AS FECHA
          , SHRTRIT_SBGI_CODE AS COD_INSTITUCION, STVSBGI_DESC AS INSTITUCION
          , CASE STVSBGI_TYPE_IND WHEN 'C' THEN 'UNIVERSIDAD' WHEN 'H' THEN 'INSTITUTO' ELSE STVSBGI_TYPE_IND END AS TIPO_INSTITUCION
      FROM ODSMGR.SHRTRCE, ODSMGR.SHRTRAM, ODSMGR.SHRTRIT, ODSMGR.STVSBGI
      WHERE SHRTRCE_PIDM = SHRTRAM_PIDM AND SHRTRCE_TRIT_SEQ_NO = SHRTRAM_TRIT_SEQ_NO AND SHRTRCE_TRAM_SEQ_NO = SHRTRAM_SEQ_NO
          AND SHRTRCE_TERM_CODE_EFF = SHRTRAM_TERM_CODE_ENTERED AND SHRTRCE_LEVL_CODE = SHRTRAM_LEVL_CODE AND SHRTRCE_LEVL_CODE = 'UG'
          AND SHRTRIT_PIDM = SHRTRAM_PIDM AND SHRTRIT_SEQ_NO = SHRTRAM_TRIT_SEQ_NO 
          AND SHRTRIT_PIDM = SHRTRCE_PIDM AND SHRTRIT_SEQ_NO = SHRTRCE_TRIT_SEQ_NO
          AND SHRTRIT_SBGI_CODE = STVSBGI_CODE(+)
          AND (TO_CHAR(SHRTRCE_ACTIVITY_DATE,'YYYY') >= '2018' AND TO_CHAR(SHRTRAM_ACCEPTANCE_DATE,'YYYY') >= '2018')
      GROUP BY SHRTRCE_PIDM, SHRTRCE_LEVL_CODE, SHRTRCE_TERM_CODE_EFF, SHRTRAM_USER_ID, SHRTRIT_SBGI_CODE, STVSBGI_DESC
          , CASE STVSBGI_TYPE_IND WHEN 'C' THEN 'UNIVERSIDAD' WHEN 'H' THEN 'INSTITUTO' ELSE STVSBGI_TYPE_IND END) C
    , ODSMGR.LOE_SPRIDEN, ODSMGR.LOE_SOVLCUR A, ODSMGR.LOE_SOVLCUR B
WHERE C.SHRTRCE_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND C.SHRTRCE_PIDM = A.SOVLCUR_PIDM(+) AND C.SHRTRCE_LEVL_CODE = A.SOVLCUR_LEVL_CODE(+)
    AND A.SOVLCUR_LMOD_CODE(+) = 'LEARNER' AND A.SOVLCUR_CACT_CODE(+) = 'ACTIVE' AND A.SOVLCUR_CURRENT_IND(+) = 'Y'
    AND C.SHRTRCE_PIDM = B.SOVLCUR_PIDM(+) AND C.SHRTRCE_LEVL_CODE = B.SOVLCUR_LEVL_CODE(+)
    AND B.SOVLCUR_TERM_CODE_ADMIT(+) <> '000000' AND B.SOVLCUR_TERM_CODE_ADMIT(+) IS NOT NULL
GROUP BY C.SHRTRCE_PIDM, SPRIDEN_ID, CONCAT(CONCAT(SPRIDEN_LAST_NAME,', '),SPRIDEN_FIRST_NAME), C.SHRTRCE_LEVL_CODE
    , C.SHRTRCE_TERM_CODE_EFF, C.CURSOS, C.CREDITOS, C.SHRTRAM_USER_ID, C.FECHA, A.SOVLCUR_CAMP_CODE
	, A.SOVLCUR_PROGRAM, A.SOVLCUR_ADMT_CODE, C.COD_INSTITUCION, C.INSTITUCION, C.TIPO_INSTITUCION;
