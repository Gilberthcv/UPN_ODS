--POBLACION_INICIAL
WITH PERIODO_ACADEMICO AS (
SELECT P.PERIODO_ACTUAL, P.PERIODO_ACTUAL_LBL, P.PERIODO_ACTUAL_DESC, P.PC_FECHA_INICIO, P.PC_FECHA_FIN, P.PERIODO_ANTERIOR
    , D.STVTERM_DESC AS PERIODO_ANTERIOR_DESC, F.START_DATE AS PP_FECHA_INICIO, F.END_DATE AS PP_FECHA_FIN
FROM (SELECT PC.TERM_CODE AS PERIODO_ACTUAL, SUBSTR(STVTERM_DESC,1,6) AS PERIODO_ACTUAL_LBL, STVTERM_DESC AS PERIODO_ACTUAL_DESC
		  , PC.START_DATE AS PC_FECHA_INICIO, PC.END_DATE AS PC_FECHA_FIN, MAX(PP.TERM_CODE) AS PERIODO_ANTERIOR
      FROM ODSMGR.LOE_SECTION_PART_OF_TERM PC, ODSMGR.STVTERM, ODSMGR.LOE_SECTION_PART_OF_TERM PP
      WHERE PC.TERM_CODE = STVTERM_CODE
          AND PC.START_DATE > PP.START_DATE + INTERVAL '1 MONTH' AND SUBSTR(PP.TERM_CODE,4,1) = SUBSTR(PC.TERM_CODE,4,1)
          AND PP.TERM_CODE > 217430 AND PP.WEEKS > 15 AND PP.WEEKS < 18
          AND SUBSTR(PC.TERM_CODE,4,1) IN ('4','5') AND PC.TERM_CODE > 217430
          AND ((PC.WEEKS > 6 AND PC.WEEKS < 10) OR (PC.WEEKS > 15 AND PC.WEEKS < 18))
      GROUP BY PC.TERM_CODE, STVTERM_DESC, PC.START_DATE, PC.END_DATE) P
    , ODSMGR.STVTERM D, ODSMGR.LOE_SECTION_PART_OF_TERM F
WHERE P.PERIODO_ANTERIOR = D.STVTERM_CODE AND P.PERIODO_ANTERIOR = F.TERM_CODE
--ORDER BY P.PERIODO_ACTUAL_LBL DESC, P.PC_FECHA_INICIO DESC
)
SELECT HST.SHRTCKN_PIDM, HST.SPRIDEN_ID, TRM_CURR.PERIODO_ACTUAL, HST.MAX_PERIODO_HISTORIA, NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE) AS FECHA_INICIO
    , NVL(TERM1.END_DATE,TERM2.STVTERM_END_DATE) AS FECHA_FIN, EGR.MAX_PERIODO_EGRESO
    , CASE WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 1 ELSE 0 END AS FLAG_INTERCAMBIO_OUT
    , CASE 
        WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 'Regular'
        WHEN HST.MAX_PERIODO_HISTORIA = EGR.MAX_PERIODO_EGRESO THEN 'Nuevo'
        WHEN EGR.MAX_PERIODO_EGRESO > HST.MAX_PERIODO_HISTORIA THEN 'Nuevo'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 8 THEN 'Regular'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) > 8
                AND DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 25 THEN 'Reingreso'
        ELSE 'Nuevo Reingreso' END AS TIPO_ESTUDIANTE
FROM (((SELECT SHRTCKN_PIDM, SPRIDEN_ID, MAX(MAX_PERIODO_HISTORIA) AS MAX_PERIODO_HISTORIA, PERIODO_ACTUAL_LBL
       FROM (SELECT SHRTCKN_PIDM, SPRIDEN_ID, MAX(SHRTCKN_TERM_CODE) AS MAX_PERIODO_HISTORIA, PERIODO_ACTUAL_LBL
            FROM ODSMGR.SHRTCKN, ODSMGR.SHRTCKL, ODSMGR.SHRTCKG G, ODSMGR.LOE_SPRIDEN, PERIODO_ACADEMICO
            WHERE SHRTCKN_PIDM = SHRTCKL_PIDM AND SHRTCKN_TERM_CODE = SHRTCKL_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO
                AND SHRTCKN_PIDM = SHRTCKG_PIDM AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
                AND G.SHRTCKG_SEQ_NO = (SELECT MAX(G1.SHRTCKG_SEQ_NO) FROM ODSMGR.SHRTCKG G1
                                        WHERE G.SHRTCKG_PIDM = G1.SHRTCKG_PIDM AND G.SHRTCKG_TERM_CODE = G1.SHRTCKG_TERM_CODE
                                            AND G.SHRTCKG_TCKN_SEQ_NO = G1.SHRTCKG_TCKN_SEQ_NO)
                AND SHRTCKN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
                AND SHRTCKN_TERM_CODE < PERIODO_ANTERIOR
                AND SHRTCKL_LEVL_CODE = 'UG' AND SUBSTR(SHRTCKG_GRDE_CODE_FINAL,1,1) <> 'C'
                AND SUBSTR(SHRTCKN_TERM_CODE,5,2) NOT IN ('00','09','01','02','03') AND SHRTCKN_TERM_CODE NOT IN ('201730','201830') AND SUBSTR(SHRTCKN_TERM_CODE,6,1) NOT IN ('1')
                AND ((SUBSTR(SHRTCKN_TERM_CODE,4,1) NOT IN ('3','7','9') AND SUBSTR(SHRTCKN_TERM_CODE,2,1) NOT IN ('0')) OR SUBSTR(SHRTCKN_TERM_CODE,2,1) IN ('0'))
            GROUP BY SHRTCKN_PIDM, SPRIDEN_ID, PERIODO_ACTUAL_LBL
            UNION
            SELECT DISTINCT PERSON_UID, ID, ACADEMIC_PERIOD, PERIODO_ACTUAL_LBL
            FROM ODSMGR.STUDENT_COURSE, PERIODO_ACADEMICO
            WHERE ACADEMIC_PERIOD = PERIODO_ANTERIOR AND REGISTRATION_STATUS IN ('RW','RE','RA','WC','RF','RO','IA','SE'))      --PERIODOS_ANTERIORES
        GROUP BY SHRTCKN_PIDM, SPRIDEN_ID, PERIODO_ACTUAL_LBL) HST        
        LEFT JOIN (SELECT PERSON_UID, ID, MAX_PERIODO_EGRESO, PERIODO_ACTUAL_LBL
                    FROM (SELECT PERSON_UID, ID, MAX(ACADEMIC_PERIOD) AS MAX_PERIODO_EGRESO
                            FROM ODSMGR.FIELD_OF_STUDY
                            WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON IN ('EGRESADO'/*,'BACHILLER','TITULADO'*/) AND STUDENT_LEVEL = 'UG'   --EVALUAR
                            GROUP BY PERSON_UID, ID), PERIODO_ACADEMICO
                    WHERE MAX_PERIODO_EGRESO <= PERIODO_ANTERIOR) EGR ON
                HST.SHRTCKN_PIDM = EGR.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = EGR.PERIODO_ACTUAL_LBL)        
        LEFT JOIN ODSMGR.LOE_SECTION_PART_OF_TERM TERM1 ON HST.MAX_PERIODO_HISTORIA = TERM1.TERM_CODE        
        LEFT JOIN ODSMGR.STVTERM TERM2 ON HST.MAX_PERIODO_HISTORIA = TERM2.STVTERM_CODE)        
        INNER JOIN PERIODO_ACADEMICO TRM_CURR ON HST.PERIODO_ACTUAL_LBL = TRM_CURR.PERIODO_ACTUAL_LBL		--PERIODOS_ACTUALES
        LEFT JOIN (SELECT A.PERSON_UID, A.ID, A.ACADEMIC_PERIOD, 'INTERCAMBIO OUT' AS TIPO_ESTUDIANTE, PERIODO_ACTUAL_LBL
                    FROM (ODSMGR.ACADEMIC_STUDY A 
                            LEFT JOIN ODSMGR.STUDENT_ATTRIBUTE C ON 
                                A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD
                                AND C.STUDENT_ATTRIBUTE = 'TINT' 
                            LEFT JOIN ODSMGR.STUDENT_ACTIVITY D ON 
                                A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD
                                AND D.ACTIVITY = 'ITO'), PERIODO_ACADEMICO
                    WHERE A.ACADEMIC_PERIOD = PERIODO_ANTERIOR AND A.STUDENT_POPULATION = 'C'       --PERIODOS_ANTERIORES
                        AND ((A.ADMISSIONS_POPULATION <> 'RE' AND C.STUDENT_ATTRIBUTE = 'TINT')
                                OR D.ACTIVITY = 'ITO')) INT_OUT ON
                HST.SHRTCKN_PIDM = INT_OUT.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = INT_OUT.PERIODO_ACTUAL_LBL                
GROUP BY HST.SHRTCKN_PIDM, HST.SPRIDEN_ID, TRM_CURR.PERIODO_ACTUAL, HST.MAX_PERIODO_HISTORIA, NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE)
    , NVL(TERM1.END_DATE,TERM2.STVTERM_END_DATE), EGR.MAX_PERIODO_EGRESO
    , CASE WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 1 ELSE 0 END
    , CASE 
        WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 'Regular'
        WHEN HST.MAX_PERIODO_HISTORIA = EGR.MAX_PERIODO_EGRESO THEN 'Nuevo'
        WHEN EGR.MAX_PERIODO_EGRESO > HST.MAX_PERIODO_HISTORIA THEN 'Nuevo'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 8 THEN 'Regular'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) > 8
                AND DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 25 THEN 'Reingreso'
        ELSE 'Nuevo Reingreso' END
;
-------------------------------------------------
--MERGE
MERGE INTO LOE_TIPO_ESTUDIANTE USING (
WITH PERIODO_ACADEMICO AS (
SELECT P.PERIODO_ACTUAL, P.PERIODO_ACTUAL_LBL, P.PERIODO_ACTUAL_DESC, P.PC_FECHA_INICIO, P.PC_FECHA_FIN, P.PERIODO_ANTERIOR
    , D.STVTERM_DESC AS PERIODO_ANTERIOR_DESC, F.START_DATE AS PP_FECHA_INICIO, F.END_DATE AS PP_FECHA_FIN
FROM (SELECT PC.TERM_CODE AS PERIODO_ACTUAL, SUBSTR(STVTERM_DESC,1,6) AS PERIODO_ACTUAL_LBL, STVTERM_DESC AS PERIODO_ACTUAL_DESC
		  , PC.START_DATE AS PC_FECHA_INICIO, PC.END_DATE AS PC_FECHA_FIN, PC.CENSUS_2_DATE, MAX(PP.TERM_CODE) AS PERIODO_ANTERIOR
      FROM ODSMGR.LOE_SECTION_PART_OF_TERM PC, ODSMGR.STVTERM, ODSMGR.LOE_SECTION_PART_OF_TERM PP
      WHERE PC.TERM_CODE = STVTERM_CODE
          AND PC.START_DATE > PP.START_DATE + INTERVAL '1 MONTH' AND SUBSTR(PP.TERM_CODE,4,1) = SUBSTR(PC.TERM_CODE,4,1)
          AND PP.TERM_CODE > 217430 AND PP.WEEKS > 15 AND PP.WEEKS < 18
          AND SUBSTR(PC.TERM_CODE,4,1) IN ('4','5') AND PC.TERM_CODE > 217430
          AND ((PC.WEEKS > 6 AND PC.WEEKS < 10) OR (PC.WEEKS > 15 AND PC.WEEKS < 18))
      GROUP BY PC.TERM_CODE, STVTERM_DESC, PC.START_DATE, PC.END_DATE, PC.CENSUS_2_DATE) P
    , ODSMGR.STVTERM D, ODSMGR.LOE_SECTION_PART_OF_TERM F
WHERE P.PERIODO_ANTERIOR = D.STVTERM_CODE AND P.PERIODO_ANTERIOR = F.TERM_CODE
    AND CURRENT_DATE BETWEEN (F.CENSUS_2_DATE + INTERVAL '10 DAYS') AND (P.CENSUS_2_DATE + INTERVAL '10 DAYS')
--ORDER BY P.PERIODO_ACTUAL_LBL DESC, P.PC_FECHA_INICIO DESC
)
SELECT HST.SHRTCKN_PIDM, HST.SPRIDEN_ID, TRM_CURR.PERIODO_ACTUAL, HST.MAX_PERIODO_HISTORIA, NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE) AS FECHA_INICIO
    , NVL(TERM1.END_DATE,TERM2.STVTERM_END_DATE) AS FECHA_FIN, EGR.MAX_PERIODO_EGRESO
    , CASE WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 1 ELSE 0 END AS FLAG_INTERCAMBIO_OUT
    , CASE 
        WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 'Regular'
        WHEN HST.MAX_PERIODO_HISTORIA = EGR.MAX_PERIODO_EGRESO THEN 'Nuevo'
        WHEN EGR.MAX_PERIODO_EGRESO > HST.MAX_PERIODO_HISTORIA THEN 'Nuevo'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 8 THEN 'Regular'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) > 8
                AND DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 25 THEN 'Reingreso'
        ELSE 'Nuevo Reingreso' END AS TIPO_ESTUDIANTE
FROM (((SELECT SHRTCKN_PIDM, SPRIDEN_ID, MAX(MAX_PERIODO_HISTORIA) AS MAX_PERIODO_HISTORIA, PERIODO_ACTUAL_LBL
       FROM (SELECT SHRTCKN_PIDM, SPRIDEN_ID, MAX(SHRTCKN_TERM_CODE) AS MAX_PERIODO_HISTORIA, PERIODO_ACTUAL_LBL
            FROM ODSMGR.SHRTCKN, ODSMGR.SHRTCKL, ODSMGR.SHRTCKG G, ODSMGR.LOE_SPRIDEN, PERIODO_ACADEMICO
            WHERE SHRTCKN_PIDM = SHRTCKL_PIDM AND SHRTCKN_TERM_CODE = SHRTCKL_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO
                AND SHRTCKN_PIDM = SHRTCKG_PIDM AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
                AND G.SHRTCKG_SEQ_NO = (SELECT MAX(G1.SHRTCKG_SEQ_NO) FROM ODSMGR.SHRTCKG G1
                                        WHERE G.SHRTCKG_PIDM = G1.SHRTCKG_PIDM AND G.SHRTCKG_TERM_CODE = G1.SHRTCKG_TERM_CODE
                                            AND G.SHRTCKG_TCKN_SEQ_NO = G1.SHRTCKG_TCKN_SEQ_NO)
                AND SHRTCKN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
                AND SHRTCKN_TERM_CODE < PERIODO_ANTERIOR
                AND SHRTCKL_LEVL_CODE = 'UG' AND SUBSTR(SHRTCKG_GRDE_CODE_FINAL,1,1) <> 'C'
                AND SUBSTR(SHRTCKN_TERM_CODE,5,2) NOT IN ('00','09','01','02','03') AND SHRTCKN_TERM_CODE NOT IN ('201730','201830') AND SUBSTR(SHRTCKN_TERM_CODE,6,1) NOT IN ('1')
                AND ((SUBSTR(SHRTCKN_TERM_CODE,4,1) NOT IN ('3','7','9') AND SUBSTR(SHRTCKN_TERM_CODE,2,1) NOT IN ('0')) OR SUBSTR(SHRTCKN_TERM_CODE,2,1) IN ('0'))
            GROUP BY SHRTCKN_PIDM, SPRIDEN_ID, PERIODO_ACTUAL_LBL
            UNION
            SELECT DISTINCT PERSON_UID, ID, ACADEMIC_PERIOD, PERIODO_ACTUAL_LBL
            FROM ODSMGR.STUDENT_COURSE, PERIODO_ACADEMICO
            WHERE ACADEMIC_PERIOD = PERIODO_ANTERIOR AND REGISTRATION_STATUS IN ('RW','RE','RA','WC','RF','RO','IA','SE'))      --PERIODOS_ANTERIORES
        GROUP BY SHRTCKN_PIDM, SPRIDEN_ID, PERIODO_ACTUAL_LBL) HST        
        LEFT JOIN (SELECT PERSON_UID, ID, MAX_PERIODO_EGRESO, PERIODO_ACTUAL_LBL
                    FROM (SELECT PERSON_UID, ID, MAX(ACADEMIC_PERIOD) AS MAX_PERIODO_EGRESO
                            FROM ODSMGR.FIELD_OF_STUDY
                            WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON IN ('EGRESADO'/*,'BACHILLER','TITULADO'*/) AND STUDENT_LEVEL = 'UG'   --EVALUAR
                            GROUP BY PERSON_UID, ID), PERIODO_ACADEMICO
                    WHERE MAX_PERIODO_EGRESO <= PERIODO_ANTERIOR) EGR ON
                HST.SHRTCKN_PIDM = EGR.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = EGR.PERIODO_ACTUAL_LBL)        
        LEFT JOIN ODSMGR.LOE_SECTION_PART_OF_TERM TERM1 ON HST.MAX_PERIODO_HISTORIA = TERM1.TERM_CODE        
        LEFT JOIN ODSMGR.STVTERM TERM2 ON HST.MAX_PERIODO_HISTORIA = TERM2.STVTERM_CODE)        
        INNER JOIN PERIODO_ACADEMICO TRM_CURR ON HST.PERIODO_ACTUAL_LBL = TRM_CURR.PERIODO_ACTUAL_LBL		--PERIODOS_ACTUALES
        LEFT JOIN (SELECT A.PERSON_UID, A.ID, A.ACADEMIC_PERIOD, 'INTERCAMBIO OUT' AS TIPO_ESTUDIANTE, PERIODO_ACTUAL_LBL
                    FROM (ODSMGR.ACADEMIC_STUDY A 
                            LEFT JOIN ODSMGR.STUDENT_ATTRIBUTE C ON 
                                A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD
                                AND C.STUDENT_ATTRIBUTE = 'TINT' 
                            LEFT JOIN ODSMGR.STUDENT_ACTIVITY D ON 
                                A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD
                                AND D.ACTIVITY = 'ITO'), PERIODO_ACADEMICO
                    WHERE A.ACADEMIC_PERIOD = PERIODO_ANTERIOR AND A.STUDENT_POPULATION = 'C'       --PERIODOS_ANTERIORES
                        AND ((A.ADMISSIONS_POPULATION <> 'RE' AND C.STUDENT_ATTRIBUTE = 'TINT')
                                OR D.ACTIVITY = 'ITO')) INT_OUT ON
                HST.SHRTCKN_PIDM = INT_OUT.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = INT_OUT.PERIODO_ACTUAL_LBL                
GROUP BY HST.SHRTCKN_PIDM, HST.SPRIDEN_ID, TRM_CURR.PERIODO_ACTUAL, HST.MAX_PERIODO_HISTORIA, NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE)
    , NVL(TERM1.END_DATE,TERM2.STVTERM_END_DATE), EGR.MAX_PERIODO_EGRESO
    , CASE WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 1 ELSE 0 END
    , CASE 
        WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 'Regular'
        WHEN HST.MAX_PERIODO_HISTORIA = EGR.MAX_PERIODO_EGRESO THEN 'Nuevo'
        WHEN EGR.MAX_PERIODO_EGRESO > HST.MAX_PERIODO_HISTORIA THEN 'Nuevo'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 8 THEN 'Regular'
        WHEN DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) > 8
                AND DATEDIFF(month,NVL(TERM1.START_DATE,TERM2.STVTERM_START_DATE),TRM_CURR.PC_FECHA_INICIO) <= 25 THEN 'Reingreso'
        ELSE 'Nuevo Reingreso' END
) DIF ON LOE_TIPO_ESTUDIANTE.SHRTCKN_PIDM = DIF.SHRTCKN_PIDM AND LOE_TIPO_ESTUDIANTE.PERIODO_ACTUAL = DIF.PERIODO_ACTUAL
WHEN MATCHED THEN
    UPDATE SET LOE_TIPO_ESTUDIANTE.SPRIDEN_ID = DIF.SPRIDEN_ID
        , LOE_TIPO_ESTUDIANTE.MAX_PERIODO_HISTORIA = DIF.MAX_PERIODO_HISTORIA
        , LOE_TIPO_ESTUDIANTE.FECHA_INICIO = DIF.FECHA_INICIO
        , LOE_TIPO_ESTUDIANTE.FECHA_FIN = DIF.FECHA_FIN
        , LOE_TIPO_ESTUDIANTE.MAX_PERIODO_EGRESO = DIF.MAX_PERIODO_EGRESO
        , LOE_TIPO_ESTUDIANTE.FLAG_INTERCAMBIO_OUT = DIF.FLAG_INTERCAMBIO_OUT
        , LOE_TIPO_ESTUDIANTE.TIPO_ESTUDIANTE = DIF.TIPO_ESTUDIANTE
WHEN NOT MATCHED THEN
    INSERT (SHRTCKN_PIDM, SPRIDEN_ID, PERIODO_ACTUAL, MAX_PERIODO_HISTORIA, FECHA_INICIO, FECHA_FIN, MAX_PERIODO_EGRESO, FLAG_INTERCAMBIO_OUT, TIPO_ESTUDIANTE)
    VALUES (DIF.SHRTCKN_PIDM, DIF.SPRIDEN_ID, DIF.PERIODO_ACTUAL, DIF.MAX_PERIODO_HISTORIA, DIF.FECHA_INICIO, DIF.FECHA_FIN, DIF.MAX_PERIODO_EGRESO, DIF.FLAG_INTERCAMBIO_OUT, DIF.TIPO_ESTUDIANTE)
;
