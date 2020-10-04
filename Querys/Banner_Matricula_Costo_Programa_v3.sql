--Banner_Matricula_Costo_Programa_
SELECT
	H.PERSON_UID AS PIDM,  
    H.SPRIDEN_ID AS ID,
    H.ESTUDIANTE, 
    H.ACADEMIC_PERIOD AS PERIODO, 
    H.PROGRAM AS COD_PROGRAMA, 
    H.PROGRAM_DESC AS PROGRAMA, 
    H.CAMPUS AS COD_CAMPUS, 
    H.CAMPUS_DESC AS CAMPUS, 
    H.MAX_SECTION_ADD_DATE AS MAX_SECTION_ADD_DATE, 
    SUM(I.BALANCE) AS COSTO_PROGRAMA_NETO, 
    H.COSTO_PROGRAMA_BRUTO
FROM ( SELECT DISTINCT
		    B.PERSON_UID, E.SPRIDEN_ID, CONCAT(E.SPRIDEN_LAST_NAME,', '||E.SPRIDEN_FIRST_NAME) AS ESTUDIANTE, 
		    B.ACADEMIC_PERIOD, C.PROGRAM, C.PROGRAM_DESC, C.CAMPUS, C.CAMPUS_DESC, B.MAX_SECTION_ADD_DATE,
		    COALESCE(F.MINIMUM_CHARGE,F0.MINIMUM_CHARGE) + COALESCE(g.MINIMUM_CHARGE,G0.MINIMUM_CHARGE) AS COSTO_PROGRAMA_BRUTO
		FROM 
		    ( SELECT PERSON_UID, ID, ACADEMIC_PERIOD
		            , MAX(SECTION_ADD_DATE) AS MAX_SECTION_ADD_DATE
		            , SUM(COURSE_CREDITS) AS TOTAL_CREDITOS
		            , MAX(CASE WHEN SUBJECT = 'XSER' THEN 'XSER' ELSE NULL END) AS MATERIA_XSER
				FROM UPN_RPT_DM_PROD.ODSMGR.STUDENT_COURSE a
		        WHERE TRANSFER_COURSE_IND = 'N' AND REGISTRATION_STATUS IN ('RW','RE','RA','WC','RF','RO','IA','SE') AND COURSE_CREDITS > 0
		        	AND EXISTS (SELECT 1 
								FROM UPN_RPT_DM_PROD.ODSMGR.LOE_Student_Regis_Status TRM 
								WHERE TRM.academic_period = A.ACADEMIC_PERIOD
								AND CURRENT_DATE BETWEEN start_date AND end_date
								AND TRM.ests_code = 'EL'
								AND substr(TRM.academic_period,4,1) in (4,5)
								)
		        GROUP BY PERSON_UID, ID, ACADEMIC_PERIOD
			) b
		        INNER JOIN UPN_RPT_DM_PROD.ODSMGR.ACADEMIC_STUDY c ON B.PERSON_UID = C.PERSON_UID AND B.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD AND C.STUDENT_LEVEL = 'UG'
		        LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.STUDENT_COHORT d ON B.PERSON_UID = D.PERSON_UID AND B.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD AND D.COHORT_ACTIVE_IND = 'Y' AND D.COHORT IN ('REINGRESO','NEW_REING')
		        LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_SPRIDEN e ON B.PERSON_UID = E.SPRIDEN_PIDM AND E.SPRIDEN_CHANGE_IND IS NULL        
		        LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_REGISTRATION_FEES f ON B.ACADEMIC_PERIOD = F.REGISTRATION_TERM AND C.PROGRAM = F.PROGRAM AND C.CAMPUS = F.CAMP_CODE AND
					            (C.STUDENT_POPULATION = F.CURRICULUM_LEARNER_TYPE OR F.CURRICULUM_LEARNER_TYPE IS NULL) AND D.COHORT = F.COHORT_CODE AND
					            substr(F.DETAIL_CODE, 1, 2) IN ('T1','X1','Y1','Z1') AND F.RATE_CODE_CURRICULUM IS NULL AND F.STUDENT_ATTRIBUTE_CODE IS NULL AND F.MINIMUM_CHARGE >= 0 AND
					            F.FROM_CRED_HRS IS NULL AND F.TO_CRED_HRS IS NULL
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_REGISTRATION_FEES f0 ON B.ACADEMIC_PERIOD = F0.REGISTRATION_TERM AND C.PROGRAM = F0.PROGRAM AND C.CAMPUS = F0.CAMP_CODE AND
					            (C.STUDENT_POPULATION = F0.CURRICULUM_LEARNER_TYPE OR F0.CURRICULUM_LEARNER_TYPE IS NULL) AND
					            substr(F0.DETAIL_CODE, 1, 2) IN ('T1','X1','Y1','Z1') AND F0.RATE_CODE_CURRICULUM IS NULL AND F0.STUDENT_ATTRIBUTE_CODE IS NULL AND F0.MINIMUM_CHARGE >= 0 AND
					            F0.FROM_CRED_HRS IS NULL AND F0.TO_CRED_HRS IS NULL
		        LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_REGISTRATION_FEES g ON B.ACADEMIC_PERIOD = g.REGISTRATION_TERM AND C.PROGRAM = g.PROGRAM AND C.CAMPUS = g.CAMP_CODE AND
					            (C.STUDENT_POPULATION = g.CURRICULUM_LEARNER_TYPE OR g.CURRICULUM_LEARNER_TYPE IS NULL) AND D.COHORT = g.COHORT_CODE AND
					            substr(g.DETAIL_CODE, 1, 2) IN ('TA','XA','YA','ZA') AND g.RATE_CODE_CURRICULUM IS NULL AND g.STUDENT_ATTRIBUTE_CODE IS NULL AND g.MINIMUM_CHARGE >= 0 AND
					            g.FROM_CRED_HRS = 13 AND g.TO_CRED_HRS = 22.999 AND g.VISA_TYPE_CODE IS NULL
				LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_REGISTRATION_FEES g0 ON B.ACADEMIC_PERIOD = G0.REGISTRATION_TERM AND C.PROGRAM = G0.PROGRAM AND C.CAMPUS = G0.CAMP_CODE AND
					            (C.STUDENT_POPULATION = G0.CURRICULUM_LEARNER_TYPE OR G0.CURRICULUM_LEARNER_TYPE IS NULL) AND
					            substr(G0.DETAIL_CODE, 1, 2) IN ('TA','XA','YA','ZA') AND G0.RATE_CODE_CURRICULUM IS NULL AND G0.STUDENT_ATTRIBUTE_CODE IS NULL AND G0.MINIMUM_CHARGE >= 0 AND
					            G0.FROM_CRED_HRS = 13 AND G0.TO_CRED_HRS = 22.999 AND G0.VISA_TYPE_CODE IS NULL
	) H
		LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.RECEIVABLE_ACCOUNT_DETAIL I ON H.PERSON_UID = I.ACCOUNT_UID AND H.ACADEMIC_PERIOD = I.ACADEMIC_PERIOD AND
			            SUBSTR(I.DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA','TB','E1','E2') AND
			            (SUBSTR(I.CROSSREF_DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA','TB') OR I.CROSSREF_DETAIL_CODE IS NULL)
        LEFT JOIN (SELECT DETAIL_CODE, PROGRAM
                    FROM (SELECT DETAIL_CODE, PROGRAM, COUNT, MAX(COUNT) OVER(PARTITION BY PROGRAM) MAX_COUNT
                          FROM (SELECT SUBSTR(DETAIL_CODE,3,2) AS DETAIL_CODE, PROGRAM, COUNT(DETAIL_CODE) AS COUNT FROM UPN_RPT_DM_PROD.ODSMGR.LOE_REGISTRATION_FEES GROUP BY SUBSTR(DETAIL_CODE,3,2), PROGRAM))
                    WHERE COUNT = MAX_COUNT
					) J ON (H.PROGRAM = J.PROGRAM OR J.PROGRAM IS NULL ) AND
		            	COALESCE( CASE WHEN SUBSTR(I.DETAIL_CODE, 1, 2) IN ('T1','TA','X1','XA','Y1','YA','Z1','ZA') THEN SUBSTR(I.DETAIL_CODE, 3, 2) ELSE NULL END
								, CASE WHEN SUBSTR(I.DETAIL_CODE, 1, 1) = 'E' THEN SUBSTR(I.CROSSREF_DETAIL_CODE, 3, 2) ELSE NULL END) = J.DETAIL_CODE
        LEFT JOIN UPN_RPT_DM_PROD.ODSMGR.LOE_BASE_TABLE_EQUIV K ON K.ESTADO = 'Y' AND K.TABLE_PARENT_ID = 158 AND (H.CAMPUS = K.VALUE2 OR K.VALUE2 IS NULL ) AND 
            			CASE WHEN SUBSTR(I.DETAIL_CODE, 1, 1) = 'E' THEN SUBSTR(I.DETAIL_CODE, 3, 2) ELSE NULL END = K.VALUE1
--WHERE H.SPRIDEN_ID = 'N00232447'
GROUP BY H.PERSON_UID,  
    H.SPRIDEN_ID,
    H.ESTUDIANTE, 
    H.ACADEMIC_PERIOD, 
    H.PROGRAM, 
    H.PROGRAM_DESC, 
    H.CAMPUS, 
    H.CAMPUS_DESC, 
    H.MAX_SECTION_ADD_DATE, 
    H.COSTO_PROGRAMA_BRUTO
;