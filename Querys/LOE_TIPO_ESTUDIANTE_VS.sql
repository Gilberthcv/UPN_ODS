--LOE_TIPO_ESTUDIANTE_
USE DATABASE BI_CDW_PROD;
USE SCHEMA UPN_STG_SIS_BNRODS_ODSMGR;

WITH PERIODO_ACADEMICO AS (
	SELECT P.PERIODO_ACTUAL, P.PERIODO_ACTUAL_LBL, P.PERIODO_ACTUAL_DESC, P.PC_FECHA_INICIO, P.PC_FECHA_FIN, P.PERIODO_ANTERIOR
	    , SUBSTR(D.STVTERM_DESC,1,6) AS PERIODO_ANTERIOR_LBL, D.STVTERM_DESC AS PERIODO_ANTERIOR_DESC, F.START_DATE AS PP_FECHA_INICIO, F.END_DATE AS PP_FECHA_FIN
	FROM (SELECT PC.TERM_CODE AS PERIODO_ACTUAL, SUBSTR(STVTERM_DESC,1,6) AS PERIODO_ACTUAL_LBL, STVTERM_DESC AS PERIODO_ACTUAL_DESC
	    , PC.START_DATE AS PC_FECHA_INICIO, PC.END_DATE AS PC_FECHA_FIN, PC.CENSUS_2_DATE, MAX(PP.TERM_CODE) AS PERIODO_ANTERIOR
	    FROM LOE_SECTION_PART_OF_TERM PC, LOE_STVTERM, LOE_SECTION_PART_OF_TERM PP
	    WHERE PC.TERM_CODE = STVTERM_CODE
	        AND PC.START_DATE > PP.START_DATE + INTERVAL '1 MONTH' AND SUBSTR(PP.TERM_CODE,4,1) = SUBSTR(PC.TERM_CODE,4,1)
	        AND PP.TERM_CODE > 217430 AND PP.WEEKS > 15 AND PP.WEEKS < 18
	        AND SUBSTR(PC.TERM_CODE,4,1) IN ('4','5') AND PC.TERM_CODE > 217430
	        AND ((PC.WEEKS > 6 AND PC.WEEKS < 10) OR (PC.WEEKS > 15 AND PC.WEEKS < 18))
	    GROUP BY PC.TERM_CODE, SUBSTR(STVTERM_DESC,1,6), STVTERM_DESC, PC.START_DATE, PC.END_DATE, PC.CENSUS_2_DATE) P
	    , LOE_STVTERM D, LOE_SECTION_PART_OF_TERM F
	WHERE P.PERIODO_ANTERIOR = D.STVTERM_CODE AND P.PERIODO_ANTERIOR = F.TERM_CODE AND P.PERIODO_ACTUAL IN ('220435','220534','221402','221502','221413','221513')
	    --AND CURRENT_DATE BETWEEN (F.CENSUS_2_DATE + INTERVAL '10 DAYS') AND (P.CENSUS_2_DATE + INTERVAL '10 DAYS')
	--ORDER BY P.PERIODO_ACTUAL_LBL DESC, P.PC_FECHA_INICIO DESC
)
, SOATERM AS (
	SELECT STVTERM_CODE, SUBSTR(STVTERM_DESC,1,6) AS PERIODO_LBL, STVTERM_DESC, COALESCE(START_DATE,STVTERM_START_DATE) AS FECHA_INICIO, COALESCE(END_DATE,STVTERM_END_DATE) AS FECHA_FIN
	FROM LOE_STVTERM LEFT JOIN LOE_SECTION_PART_OF_TERM ON STVTERM_CODE = TERM_CODE
)
SELECT DISTINCT HST.SHRTCKN_PIDM, CAST(HST.SPRIDEN_ID AS VARCHAR(16)) AS SPRIDEN_ID, CAST(TRM_CURR.PERIODO_ACTUAL AS VARCHAR(16)) AS PERIODO_ACTUAL, CAST(HST.SHRTCKN_TERM_CODE AS VARCHAR(16)) AS MAX_PERIODO_HISTORIA
	, HST.FECHA_INICIO, HST.FECHA_FIN, CAST(EGR.MAX_PERIODO_EGRESO AS VARCHAR(16)) AS MAX_PERIODO_EGRESO
    , CASE WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 1 ELSE 0 END AS FLAG_INTERCAMBIO_OUT
    , CASE 
        WHEN INT_OUT.TIPO_ESTUDIANTE = 'INTERCAMBIO OUT' THEN 'Regular'
        WHEN HST.PERIODO_LBL = EGR.PERIODO_LBL THEN 'Nuevo'
        WHEN EGR.FECHA_INICIO > HST.FECHA_INICIO THEN 'Nuevo'
        WHEN DATEDIFF(month,HST.FECHA_INICIO,TRM_CURR.PC_FECHA_INICIO) <= 7 THEN 'Regular'
        WHEN DATEDIFF(month,HST.FECHA_INICIO,TRM_CURR.PC_FECHA_INICIO) >= 8
                AND DATEDIFF(month,HST.FECHA_INICIO,TRM_CURR.PC_FECHA_INICIO) <= 24 THEN 'Reingreso'
        ELSE 'Nuevo Reingreso' END AS TIPO_ESTUDIANTE
FROM (( SELECT SHRTCKN_PIDM, SPRIDEN_ID, SHRTCKN_TERM_CODE, PERIODO_LBL, FECHA_INICIO, FECHA_FIN, PERIODO_ACTUAL_LBL
			, MAX(SHRTCKN_TERM_CODE) OVER(PARTITION BY SHRTCKN_PIDM,PERIODO_ACTUAL_LBL) AS MAX_SHRTCKN_TERM_CODE
		FROM ( SELECT DISTINCT SHRTCKN_PIDM, SPRIDEN_ID, SHRTCKN_TERM_CODE, PERIODO_LBL, FECHA_INICIO, FECHA_FIN, PERIODO_ACTUAL_LBL
					, MAX(FECHA_INICIO) OVER(PARTITION BY SHRTCKN_PIDM,PERIODO_ACTUAL_LBL) AS MAX_FECHA_INICIO
				FROM ( SELECT DISTINCT SHRTCKN_PIDM, SPRIDEN_ID, SHRTCKN_TERM_CODE, PERIODO_LBL, FECHA_INICIO, FECHA_FIN, PERIODO_ACTUAL_LBL
						FROM SHRTCKN, SHRTCKL, LOE_SHRTCKG G, LOE_SPRIDEN, SOATERM, PERIODO_ACADEMICO
						WHERE SHRTCKN_PIDM = SHRTCKL_PIDM AND SHRTCKN_TERM_CODE = SHRTCKL_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKL_TCKN_SEQ_NO
							AND SHRTCKN_PIDM = SHRTCKG_PIDM AND SHRTCKN_TERM_CODE = SHRTCKG_TERM_CODE AND SHRTCKN_SEQ_NO = SHRTCKG_TCKN_SEQ_NO
							AND G.SHRTCKG_SEQ_NO = (SELECT MAX(G1.SHRTCKG_SEQ_NO) FROM LOE_SHRTCKG G1
							                        WHERE G.SHRTCKG_PIDM = G1.SHRTCKG_PIDM AND G.SHRTCKG_TERM_CODE = G1.SHRTCKG_TERM_CODE AND G.SHRTCKG_TCKN_SEQ_NO = G1.SHRTCKG_TCKN_SEQ_NO)
			                AND SHRTCKN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
			                AND SHRTCKN_TERM_CODE = STVTERM_CODE
			                AND FECHA_INICIO < PP_FECHA_INICIO
			                AND SHRTCKL_LEVL_CODE = 'UG' AND SUBSTR(SHRTCKG_GRDE_CODE_FINAL,1,1) <> 'C'
			                AND SUBSTR(SHRTCKN_TERM_CODE,5,2) NOT IN ('00','09','01','02','03') AND SHRTCKN_TERM_CODE NOT IN ('201730','201830') AND SUBSTR(SHRTCKN_TERM_CODE,6,1) NOT IN ('1')
			                AND ((SUBSTR(SHRTCKN_TERM_CODE,4,1) NOT IN ('3','7','9') AND SUBSTR(SHRTCKN_TERM_CODE,2,1) NOT IN ('0')) OR SUBSTR(SHRTCKN_TERM_CODE,2,1) IN ('0'))
			            UNION
			            SELECT DISTINCT SFRSTCR_PIDM, SPRIDEN_ID, SFRSTCR_TERM_CODE, PERIODO_ANTERIOR_LBL, PP_FECHA_INICIO, PP_FECHA_FIN, PERIODO_ACTUAL_LBL
			            FROM SFRSTCR, LOE_SPRIDEN, PERIODO_ACADEMICO
			            WHERE SFRSTCR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
			            	AND SFRSTCR_TERM_CODE = PERIODO_ANTERIOR
			            	AND SFRSTCR_RSTS_CODE IN ('RW','RE','RA','WC','RF','RO','IA','SE') ) )	--PERIODOS_ANTERIORES
		WHERE FECHA_INICIO = MAX_FECHA_INICIO
		) HST
        	LEFT JOIN ( SELECT PERSON_UID, ID, MAX_PERIODO_EGRESO, PERIODO_LBL, FECHA_INICIO, PERIODO_ACTUAL_LBL
						FROM ( SELECT PERSON_UID, ID, MAX(ACADEMIC_PERIOD) AS MAX_PERIODO_EGRESO
								FROM UPN_RPT_DM_PROD.ODSMGR.FIELD_OF_STUDY
	                            WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON IN ('EGRESADO'/*,'BACHILLER','TITULADO'*/) AND STUDENT_LEVEL = 'UG'
	                            GROUP BY PERSON_UID, ID), SOATERM, PERIODO_ACADEMICO
						WHERE MAX_PERIODO_EGRESO = STVTERM_CODE AND FECHA_INICIO < PP_FECHA_INICIO
						) EGR ON HST.SHRTCKN_PIDM = EGR.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = EGR.PERIODO_ACTUAL_LBL)
			INNER JOIN PERIODO_ACADEMICO TRM_CURR ON HST.PERIODO_ACTUAL_LBL = TRM_CURR.PERIODO_ACTUAL_LBL   --PERIODOS_ACTUALES
			LEFT JOIN ( SELECT A.PERSON_UID, A.ID, A.ACADEMIC_PERIOD, 'INTERCAMBIO OUT' AS TIPO_ESTUDIANTE, PERIODO_ACTUAL_LBL
            			FROM (UPN_RPT_DM_PROD.ODSMGR.ACADEMIC_STUDY A 
	                        	LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_ATTRIBUTE C ON 
	                                A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD
	                                AND C.STUDENT_ATTRIBUTE = 'TINT' 
	                            LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_ACTIVITY D ON 
	                                A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD
	                                AND D.ACTIVITY = 'ITO'), PERIODO_ACADEMICO
						WHERE A.ACADEMIC_PERIOD = PERIODO_ANTERIOR AND A.STUDENT_POPULATION = 'C'	--PERIODOS_ANTERIORES
                        	AND ((A.ADMISSIONS_POPULATION <> 'RE' AND C.STUDENT_ATTRIBUTE = 'TINT') OR D.ACTIVITY = 'ITO')
                        ) INT_OUT ON HST.SHRTCKN_PIDM = INT_OUT.PERSON_UID AND HST.PERIODO_ACTUAL_LBL = INT_OUT.PERIODO_ACTUAL_LBL
WHERE HST.SHRTCKN_TERM_CODE = HST.MAX_SHRTCKN_TERM_CODE
;