/*1) DATA PARA ALUMNOS CONTINUADORES INGL�S, de los periodos 220714 y 220715 los siguientes campos:
ID, NOMBRES, APELLIDOS, SEDE, CARRERA, CICLO, A�O DE INGRESO, UG � WA, CELULAR, TEL�FONO FIJO, CORREO PERSONAL, CORREO UPN, �LTIMO NIVEL DE INGL�S CURSADO
, NOTA �LTIMO NIVEL DE INGL�S CURSADO, RINDI� EXAMEN DE UBICACI�N?, UBIGEO, y FECHA EN LA QUE LLEV� EL �LTIMO NIVEL DE INGL�S CURSADO EN UPN.*/

SELECT A.SOVLCUR_PIDM, SPRIDEN_ID, SPRIDEN_FIRST_NAME, SPRIDEN_LAST_NAME, A.SOVLCUR_CAMP_CODE, A.SOVLCUR_PROGRAM, B.SMRPRLE_PROGRAM_DESC, C.SOVLCUR_PROGRAM, D.SMRPRLE_PROGRAM_DESC
    , CASE WHEN C.SOVLCUR_PROGRAM IS NULL THEN NULL ELSE ROUND(K.ACT_CREDITS_OVERALL/20,0) +1 END AS CICLO, C.SOVLCUR_TERM_CODE_ADMIT, SUBSTR(C.SOVLCUR_PROGRAM,5,2) AS NIVEL
    , CASE WHEN E.PERSON_UID IS NOT NULL THEN E.CURRICULUM_CHANGE_REASON WHEN C.SOVLCUR_PIDM IS NOT NULL THEN 'ACTIVO' END AS STATUS
    , MAX(F.PHONE_NUMBER) AS CELULAR, MAX(G.PHONE_NUMBER) AS TELEFONO, MAX(H.EMAIL_ADDRESS) AS CORREO_PERSONAL, SPRIDEN_ID ||'@upn.pe' AS CORREO_UPN
    , A.SHRTCKN_SUBJ_CODE || A.SHRTCKN_CRSE_NUMB ||' - '|| A.SHRTCKN_CRSE_TITLE AS ULTIMO_INGLES, SHRTCKG_GRDE_CODE_FINAL AS ULTIMO_INGLES_NOTA
    , MAX(I.TEST_DATE) AS EXAMEN_UBICACION, J.CITY AS UBIGEO, A.SHRTCKN_TERM_CODE AS ULTIMO_INGLES_PERIODO
FROM ( SELECT DISTINCT SOVLCUR_PIDM, SOVLCUR_CAMP_CODE, SOVLCUR_PROGRAM, SHRTCKN_TERM_CODE, SHRTCKN_SUBJ_CODE, SHRTCKN_CRSE_NUMB, SHRTCKN_CRSE_TITLE, SHRTCKG_GRDE_CODE_FINAL
        FROM ODSMGR.LOE_SOVLCUR, ODSMGR.SHRTCKN H, ODSMGR.SHRTCKG C
        WHERE SOVLCUR_PIDM = SHRTCKN_PIDM AND SHRTCKN_SUBJ_CODE = 'IDIO'
            AND H.SHRTCKN_TERM_CODE = (SELECT MAX(H1.SHRTCKN_TERM_CODE) FROM ODSMGR.SHRTCKN H1
                                        WHERE H1.SHRTCKN_PIDM = H.SHRTCKN_PIDM AND H1.SHRTCKN_SUBJ_CODE = 'IDIO')
            AND SHRTCKN_PIDM = SHRTCKG_PIDM AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
            AND C.SHRTCKG_SEQ_NO = (SELECT MAX(C1.SHRTCKG_SEQ_NO) FROM ODSMGR.SHRTCKG C1
                                    WHERE C1.SHRTCKG_PIDM = C.SHRTCKG_PIDM AND C1.SHRTCKG_TERM_CODE = C.SHRTCKG_TERM_CODE
                                        AND C1.SHRTCKG_TCKN_SEQ_NO = C.SHRTCKG_TCKN_SEQ_NO)
            AND SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE' AND SOVLCUR_CURRENT_IND = 'Y'
            AND SOVLCUR_LEVL_CODE = 'CR' AND SUBSTR(SOVLCUR_PROGRAM,1,4) = 'ING-' ) A
        LEFT JOIN ODSMGR.LOE_SPRIDEN ON A.SOVLCUR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
        LEFT JOIN ODSMGR.SMRPRLE B ON A.SOVLCUR_PROGRAM = B.SMRPRLE_PROGRAM
        LEFT JOIN ODSMGR.LOE_SOVLCUR C ON A.SOVLCUR_PIDM = C.SOVLCUR_PIDM
                                        AND C.SOVLCUR_LMOD_CODE = 'LEARNER' AND C.SOVLCUR_CACT_CODE = 'ACTIVE'
                                        AND C.SOVLCUR_CURRENT_IND = 'Y' AND C.SOVLCUR_LEVL_CODE = 'UG'
        LEFT JOIN ODSMGR.SMRPRLE D ON C.SOVLCUR_PROGRAM = D.SMRPRLE_PROGRAM
        LEFT JOIN (SELECT DISTINCT PERSON_UID, ID, NAME, STUDENT_LEVEL, PROGRAM, CURRICULUM_CHANGE_REASON
					FROM ODSMGR.FIELD_OF_STUDY
					WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON = 'BACHILLER' AND STUDENT_LEVEL = 'UG') E ON C.SOVLCUR_PIDM = E.PERSON_UID AND C.SOVLCUR_PROGRAM = E.PROGRAM
        LEFT JOIN ODSMGR.TELEPHONE F ON A.SOVLCUR_PIDM = F.ENTITY_UID AND F.PHONE_TYPE = 'CP'
        LEFT JOIN ODSMGR.TELEPHONE G ON A.SOVLCUR_PIDM = G.ENTITY_UID AND G.PHONE_TYPE = 'BI'
        LEFT JOIN (SELECT PERSON_UID, EMAIL_ADDRESS
                      FROM (SELECT PERSON_UID, EMAIL_ADDRESS, ACTIVITY_DATE, MAX(ACTIVITY_DATE) OVER(PARTITION BY PERSON_UID) AS MAX_DATE
                            FROM ODSMGR.LOE_EMAIL
                            WHERE STATUS_IND = 'A' AND EMAIL_TYPE = 'PERS')
                      WHERE ACTIVITY_DATE = MAX_DATE) H ON A.SOVLCUR_PIDM = H.PERSON_UID
        LEFT JOIN ODSMGR.TEST I ON A.SOVLCUR_PIDM = I.PERSON_UID AND I.TEST = 'EXUB'
        LEFT JOIN ODSMGR.ADDRESS J ON A.SOVLCUR_PIDM = J.ENTITY_UID AND J.ADDRESS_TYPE = 'BI'
                                        AND J.ADDRESS_END_DATE IS NULL AND J.ADDRESS_STATUS_IND IS NULL
        LEFT JOIN ODSMGR.LOE_PROGRAM_OVERALL_RESULTS K ON C.SOVLCUR_PIDM = K.PERSON_UID AND C.SOVLCUR_PROGRAM = K.PROGRAM AND K.LEVL_CODE = 'UG'
                                    AND K.SEQUENCE_NUMBER = (SELECT MAX(K1.SEQUENCE_NUMBER) FROM ODSMGR.LOE_PROGRAM_OVERALL_RESULTS K1
                                                            WHERE K1.PERSON_UID = K.PERSON_UID AND K1.PROGRAM = K.PROGRAM AND K1.LEVL_CODE = 'UG')
GROUP BY A.SOVLCUR_PIDM, SPRIDEN_ID, SPRIDEN_FIRST_NAME, SPRIDEN_LAST_NAME, A.SOVLCUR_CAMP_CODE, A.SOVLCUR_PROGRAM, B.SMRPRLE_PROGRAM_DESC, C.SOVLCUR_PROGRAM, D.SMRPRLE_PROGRAM_DESC
    , CASE WHEN C.SOVLCUR_PROGRAM IS NULL THEN NULL ELSE ROUND(K.ACT_CREDITS_OVERALL/20,0) +1 END, C.SOVLCUR_TERM_CODE_ADMIT, SUBSTR(C.SOVLCUR_PROGRAM,5,2)
    , CASE WHEN E.PERSON_UID IS NOT NULL THEN E.CURRICULUM_CHANGE_REASON WHEN C.SOVLCUR_PIDM IS NOT NULL THEN 'ACTIVO' END
    , SPRIDEN_ID ||'@upn.pe', A.SHRTCKN_SUBJ_CODE || A.SHRTCKN_CRSE_NUMB ||' - '|| A.SHRTCKN_CRSE_TITLE, SHRTCKG_GRDE_CODE_FINAL, J.CITY, A.SHRTCKN_TERM_CODE
;


/*2) DATA PARA ALUNNOS QUE NUNCA HAN LLEVADO INGL�S, de los periodos 220413 y 220513, los siguientes campos:
ID,	NOMBRES, APELLIDOS, SEDE, CARRERA, CICLO, A�O DE INGRESO, UG � WA, CELULAR, TEL�FONO FIJO, CORREO PERSONAL, CORREO UPN, RINDI� EXAMEN DE UBICACI�N?, NOTA EXAMEN DE UBICACI�N, y UBIGEO.*/

SELECT SOVLCUR_PIDM, SPRIDEN_ID, SPRIDEN_FIRST_NAME, SPRIDEN_LAST_NAME, SOVLCUR_CAMP_CODE, SOVLCUR_PROGRAM, SMRPRLE_PROGRAM_DESC
    , CASE WHEN SOVLCUR_PROGRAM IS NULL THEN NULL ELSE ROUND(K.ACT_CREDITS_OVERALL/20,0) +1 END AS CICLO, SOVLCUR_TERM_CODE_ADMIT, SUBSTR(SOVLCUR_PROGRAM,5,2) AS NIVEL
    , CASE WHEN E.PERSON_UID IS NOT NULL THEN E.CURRICULUM_CHANGE_REASON WHEN SOVLCUR_PIDM IS NOT NULL THEN 'ACTIVO' END AS CONDICION_ESTUDIANTE
    , MAX(F.PHONE_NUMBER) AS CELULAR, MAX(G.PHONE_NUMBER) AS TELEFONO, MAX(H.EMAIL_ADDRESS) AS CORREO_PERSONAL
    , SPRIDEN_ID ||'@upn.pe' AS CORREO_UPN, I.TEST_DATE AS EXAMEN_UBICACION, I.TEST_SCORE AS EXAMEN_UBICACION_NOTA, J.CITY AS UBIGEO
    , CASE WHEN C.PERSON_UID IS NULL THEN 'N' ELSE 'C' END AS ESTADO
FROM ODSMGR.LOE_SOVLCUR
        INNER JOIN ODSMGR.STUDENT_COURSE B ON SOVLCUR_PIDM = B.PERSON_UID AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO') AND B.ACADEMIC_PERIOD IN ('220413','220513')
        LEFT JOIN ODSMGR.STUDENT_COURSE C ON SOVLCUR_PIDM = C.PERSON_UID AND C.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO') AND C.ACADEMIC_PERIOD IN ('220714','220715')
        LEFT JOIN ODSMGR.SHRTCKN ON SOVLCUR_PIDM = SHRTCKN_PIDM AND SHRTCKN_SUBJ_CODE = 'IDIO'
        LEFT JOIN ODSMGR.LOE_SPRIDEN ON SOVLCUR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
        LEFT JOIN ODSMGR.SMRPRLE ON SOVLCUR_PROGRAM = SMRPRLE_PROGRAM
        LEFT JOIN (SELECT DISTINCT PERSON_UID, ID, NAME, STUDENT_LEVEL, PROGRAM, CURRICULUM_CHANGE_REASON
					FROM ODSMGR.FIELD_OF_STUDY
					WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON = 'BACHILLER' AND STUDENT_LEVEL = 'UG') E ON SOVLCUR_PIDM = E.PERSON_UID AND SOVLCUR_PROGRAM = E.PROGRAM
        LEFT JOIN ODSMGR.TELEPHONE F ON SOVLCUR_PIDM = F.ENTITY_UID AND F.PHONE_TYPE = 'CP'
        LEFT JOIN ODSMGR.TELEPHONE G ON SOVLCUR_PIDM = G.ENTITY_UID AND G.PHONE_TYPE = 'BI'
        LEFT JOIN (SELECT PERSON_UID, EMAIL_ADDRESS
                      FROM (SELECT PERSON_UID, EMAIL_ADDRESS, ACTIVITY_DATE, MAX(ACTIVITY_DATE) OVER(PARTITION BY PERSON_UID) AS MAX_DATE
                            FROM ODSMGR.LOE_EMAIL
                            WHERE STATUS_IND = 'A' AND EMAIL_TYPE = 'PERS')
                      WHERE ACTIVITY_DATE = MAX_DATE) H ON SOVLCUR_PIDM = H.PERSON_UID
        LEFT JOIN ODSMGR.TEST I ON SOVLCUR_PIDM = I.PERSON_UID AND I.TEST = 'EXUB'
                                    AND I.TEST_DATE = (SELECT MAX(H1.TEST_DATE) FROM ODSMGR.TEST H1
                                                        WHERE H1.PERSON_UID = I.PERSON_UID AND H1.TEST = 'EXUB')
        LEFT JOIN ODSMGR.ADDRESS J ON SOVLCUR_PIDM = J.ENTITY_UID AND J.ADDRESS_TYPE = 'BI' AND J.ADDRESS_END_DATE IS NULL AND J.ADDRESS_STATUS_IND IS NULL
        LEFT JOIN ODSMGR.LOE_PROGRAM_OVERALL_RESULTS K ON SOVLCUR_PIDM = K.PERSON_UID AND SOVLCUR_PROGRAM = K.PROGRAM AND K.LEVL_CODE = 'UG'
                                    AND K.SEQUENCE_NUMBER = (SELECT MAX(K1.SEQUENCE_NUMBER) FROM ODSMGR.LOE_PROGRAM_OVERALL_RESULTS K1
                                                            WHERE K1.PERSON_UID = K.PERSON_UID AND K1.PROGRAM = K.PROGRAM AND K1.LEVL_CODE = 'UG')
WHERE SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE' AND SOVLCUR_CURRENT_IND = 'Y'
    AND SOVLCUR_LEVL_CODE = 'UG' AND SHRTCKN_PIDM IS NULL
GROUP BY SOVLCUR_PIDM, SPRIDEN_ID, SPRIDEN_FIRST_NAME, SPRIDEN_LAST_NAME, SOVLCUR_CAMP_CODE, SOVLCUR_PROGRAM, SMRPRLE_PROGRAM_DESC
    , CASE WHEN SOVLCUR_PROGRAM IS NULL THEN NULL ELSE ROUND(K.ACT_CREDITS_OVERALL/20,0) +1 END, SOVLCUR_TERM_CODE_ADMIT, SUBSTR(SOVLCUR_PROGRAM,5,2)
    , CASE WHEN E.PERSON_UID IS NOT NULL THEN E.CURRICULUM_CHANGE_REASON WHEN SOVLCUR_PIDM IS NOT NULL THEN 'ACTIVO' END
    , SPRIDEN_ID ||'@upn.pe', I.TEST_DATE, I.TEST_SCORE, J.CITY, CASE WHEN C.PERSON_UID IS NULL THEN 'N' ELSE 'C' END
;
