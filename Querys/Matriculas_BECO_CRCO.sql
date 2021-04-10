--Matriculas_BECO_CRCO_
SELECT F.PERSON_UID, F.ID, F.NAME, I.ALTERNATIVE_ID AS DNI, F.ACADEMIC_PERIOD, F.PROGRAM, F.PROGRAM_DESC, F.CAMPUS_DESC, F.STUDENT_ATTRIBUTE, F.ATRIBUTO_2, F.SOVLCUR_RATE_CODE, H.BECA_1, H.BECA_2, H.DESCUENTO_1, H.DESCUENTO_2, H.DESCUENTO_3
	, F.CURSOS_1, F.CREDITOS_1, F.CURSOS_2, F.CREDITOS_2, F.CURSOS_3, F.CREDITOS_3, F.CURSOS_1 +F.CURSOS_2 +F.CURSOS_3 AS TOTAL_CURSOS, F.CREDITOS_1 +F.CREDITOS_2 +F.CREDITOS_3 AS TOTAL_CREDITOS
	, TO_CHAR(ROUND((F.CREDITOS_2 +F.CREDITOS_3) *100 / (F.CREDITOS_1 +F.CREDITOS_2 +F.CREDITOS_3),0),'999.90') || '%' AS P_CREDITOS_REPETIDOS
	, ROUND(SUM(CASE WHEN SOURCE IN ('R','E') AND (SUBSTR(DETAIL_CODE,1,2) = 'FM' OR SUBSTR(CROSSREF_DETAIL_CODE,1,2) = 'FM') THEN BALANCE ELSE 0 END),2) AS MATRICULA_ESTUDIANTE
	, ROUND(SUM(CASE WHEN SOURCE IN ('R','E') AND (SUBSTR(DETAIL_CODE,1,2) IN ('T1','X1','Y1','Z1') OR SUBSTR(CROSSREF_DETAIL_CODE,1,2) IN ('T1','X1','Y1','Z1')) THEN BALANCE ELSE 0 END),2) AS CUOTA_INICIAL_ESTUDIANTE
	, ROUND(SUM(CASE WHEN SOURCE IN ('R','E') AND (SUBSTR(DETAIL_CODE,1,2) IN ('TA','XA','YA','ZA','TB') OR SUBSTR(CROSSREF_DETAIL_CODE,1,2) IN ('TA','XA','YA','ZA','TB')) THEN BALANCE ELSE 0 END),2) AS ARANCEL_ESTUDIANTE
	, ROUND(SUM(CASE WHEN SOURCE = 'C' AND SUBSTR(CROSSREF_DETAIL_CODE,1,2) = 'FM' THEN AMOUNT ELSE 0 END),2) AS MATRICULA_CONTRATO
	, ROUND(SUM(CASE WHEN SOURCE = 'C' AND SUBSTR(CROSSREF_DETAIL_CODE,1,2) IN ('T1','X1','Y1','Z1') THEN AMOUNT ELSE 0 END),2) AS CUOTA_INICIAL_CONTRATO
	, ROUND(SUM(CASE WHEN SOURCE = 'C' AND SUBSTR(CROSSREF_DETAIL_CODE,1,2) IN ('TA','XA','YA','ZA','TB') THEN AMOUNT ELSE 0 END),2) AS ARANCEL_CONTRATO
	, ROUND(SUM(CASE WHEN SOURCE IN ('R','T') AND SUBSTR(DETAIL_CODE,1,2) IN ('T2') THEN BALANCE ELSE 0 END),2) AS PENALIDAD_2
	, ROUND(SUM(CASE WHEN SOURCE IN ('R','T') AND SUBSTR(DETAIL_CODE,1,2) IN ('T3') THEN BALANCE ELSE 0 END),2) AS PENALIDAD_3
FROM ( SELECT A.PERSON_UID, A.ID, A.NAME, A.ACADEMIC_PERIOD, A.PROGRAM, A.PROGRAM_DESC, A.CAMPUS_DESC, B.STUDENT_ATTRIBUTE, B0.ATRIBUTO_2, A0.SOVLCUR_RATE_CODE--, COALESCE(E.COURSE_COUNT,0)+1 AS VEZ
			, COUNT(CASE WHEN E.COURSE_COUNT IS NULL THEN C.SFRSTCR_CRN ELSE NULL END) AS CURSOS_1, SUM(CASE WHEN E.COURSE_COUNT IS NULL THEN C.SFRSTCR_CREDIT_HR ELSE 0 END) AS CREDITOS_1
			, COUNT(CASE WHEN E.COURSE_COUNT = 1 THEN C.SFRSTCR_CRN ELSE NULL END) AS CURSOS_2, SUM(CASE WHEN E.COURSE_COUNT = 1 THEN C.SFRSTCR_CREDIT_HR ELSE 0 END) AS CREDITOS_2
			, COUNT(CASE WHEN E.COURSE_COUNT = 2 THEN C.SFRSTCR_CRN ELSE NULL END) AS CURSOS_3, SUM(CASE WHEN E.COURSE_COUNT = 2 THEN C.SFRSTCR_CREDIT_HR ELSE 0 END) AS CREDITOS_3
		FROM ODSMGR.ACADEMIC_STUDY A
				INNER JOIN ODSMGR.STUDENT_ATTRIBUTE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD AND B.STUDENT_ATTRIBUTE IN ('BECO','CRCO')
				INNER JOIN ODSMGR.SFRSTCR C ON B.PERSON_UID = C.SFRSTCR_PIDM AND B.ACADEMIC_PERIOD = C.SFRSTCR_TERM_CODE AND C.SFRSTCR_RSTS_CODE IN ('RE','RW','RA','WC','RF','RO','IA')
				INNER JOIN ODSMGR.LOE_SSBSECT D ON C.SFRSTCR_TERM_CODE = D.SSBSECT_TERM_CODE AND C.SFRSTCR_CRN = D.SSBSECT_CRN AND D.SSBSECT_SUBJ_CODE NOT IN ('REPS')
				LEFT JOIN ODSMGR.LOE_REPEAT_COURSE_CRN E ON C.SFRSTCR_PIDM = E.SFRSTCR_PIDM AND C.SFRSTCR_TERM_CODE = E.SFRSTCR_TERM_CODE AND D.SSBSECT_SUBJ_CODE = E.SSBSECT_SUBJ_CODE AND D.SSBSECT_CRSE_NUMB = E.SSBSECT_CRSE_NUMB
				LEFT JOIN (SELECT PERSON_UID, ACADEMIC_PERIOD, LISTAGG(STUDENT_ATTRIBUTE,', ') WITHIN GROUP (ORDER BY STUDENT_ATTRIBUTE) AS ATRIBUTO_2
							FROM ODSMGR.STUDENT_ATTRIBUTE
							WHERE STUDENT_ATTRIBUTE NOT IN ('BECO','CRCO','BECA')
							GROUP BY PERSON_UID, ACADEMIC_PERIOD
							) B0 ON A.PERSON_UID = B0.PERSON_UID AND A.ACADEMIC_PERIOD = B0.ACADEMIC_PERIOD
				LEFT JOIN ODSMGR.LOE_SOVLCUR A0 ON A.PERSON_UID = A0.SOVLCUR_PIDM AND A.STUDENT_LEVEL = A0.SOVLCUR_LEVL_CODE AND A0.SOVLCUR_LMOD_CODE = 'LEARNER' AND A0.SOVLCUR_CACT_CODE = 'ACTIVE'
													AND A0.SOVLCUR_SEQNO = (SELECT MAX(A1.SOVLCUR_SEQNO) FROM ODSMGR.LOE_SOVLCUR A1
																			WHERE A1.SOVLCUR_PIDM = A.PERSON_UID AND A1.SOVLCUR_LEVL_CODE = A.STUDENT_LEVEL
																				AND A.ACADEMIC_PERIOD BETWEEN A1.SOVLCUR_TERM_CODE AND COALESCE(A1.SOVLCUR_TERM_CODE_END,'999996')
																				AND A1.SOVLCUR_LMOD_CODE = 'LEARNER' AND A1.SOVLCUR_CACT_CODE = 'ACTIVE')
		WHERE A.ENROLLMENT_STATUS IN ('EL','RF','RO','SE') AND A.STUDENT_LEVEL = 'UG' AND A.ACADEMIC_PERIOD IN ('221413','221513') --AND A.PERSON_UID IN (21803,44488,190807)
		GROUP BY A.PERSON_UID, A.ID, A.NAME, A.ACADEMIC_PERIOD, A.PROGRAM, A.PROGRAM_DESC, A.CAMPUS_DESC, B.STUDENT_ATTRIBUTE, B0.ATRIBUTO_2, A0.SOVLCUR_RATE_CODE--, COALESCE(E.COURSE_COUNT,0)+1
		ORDER BY A.PERSON_UID, A.ACADEMIC_PERIOD
		) F
			LEFT JOIN ODSMGR.RECEIVABLE_ACCOUNT_DETAIL G ON F.PERSON_UID = G.ACCOUNT_UID AND F.ACADEMIC_PERIOD = G.ACADEMIC_PERIOD
			/*LEFT JOIN ( SELECT TBBESTU_PIDM, TBBESTU_TERM_CODE
							, LISTAGG(CASE WHEN SUBSTR(TBBESTU_EXEMPTION_CODE,5,1) = '1' THEN TBBEXPT_DESC END,', ') WITHIN GROUP (ORDER BY TBBEXPT_DESC) AS BECAS
							, LISTAGG(CASE WHEN SUBSTR(TBBESTU_EXEMPTION_CODE,5,1) IN ('2','3') THEN TBBEXPT_DESC END,', ') WITHIN GROUP (ORDER BY TBBEXPT_DESC) AS DESCUENTOS
						FROM ODSMGR.LOE_EXEMPTION_STU_AUTHOR, ODSMGR.LOE_TBBEXPT
						WHERE TBBESTU_EXEMPTION_CODE = TBBEXPT_EXEMPTION_CODE AND TBBESTU_TERM_CODE = TBBEXPT_TERM_CODE
							AND TBBESTU_DEL_IND IS NULL
						GROUP BY TBBESTU_PIDM, TBBESTU_TERM_CODE
						) H ON F.PERSON_UID = H.TBBESTU_PIDM AND F.ACADEMIC_PERIOD = H.TBBESTU_TERM_CODE*/
			LEFT JOIN ( SELECT H1.TBBESTU_PIDM, H1.TBBESTU_TERM_CODE, MAX(H1.BECA_1) AS BECA_1, MAX(H1.BECA_2) AS BECA_2, MAX(H1.DESCUENTO_1) AS DESCUENTO_1, MAX(H1.DESCUENTO_2) AS DESCUENTO_2, MAX(H1.DESCUENTO_3) AS DESCUENTO_3
						FROM ( SELECT H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE
									, CASE WHEN ROW_NUMBER() OVER(PARTITION BY H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE, H0.TIPO_EXENCION ORDER BY H0.TBBEXPT_DESC ASC) = 1 AND H0.TIPO_EXENCION = 'BECA' THEN H0.TBBEXPT_DESC END AS BECA_1
									, CASE WHEN ROW_NUMBER() OVER(PARTITION BY H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE, H0.TIPO_EXENCION ORDER BY H0.TBBEXPT_DESC ASC) = 2 AND H0.TIPO_EXENCION = 'BECA' THEN H0.TBBEXPT_DESC END AS BECA_2
									, CASE WHEN ROW_NUMBER() OVER(PARTITION BY H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE, H0.TIPO_EXENCION ORDER BY H0.TBBEXPT_DESC ASC) = 1 AND H0.TIPO_EXENCION = 'DESCUENTO' THEN H0.TBBEXPT_DESC END AS DESCUENTO_1
									, CASE WHEN ROW_NUMBER() OVER(PARTITION BY H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE, H0.TIPO_EXENCION ORDER BY H0.TBBEXPT_DESC ASC) = 2 AND H0.TIPO_EXENCION = 'DESCUENTO' THEN H0.TBBEXPT_DESC END AS DESCUENTO_2
									, CASE WHEN ROW_NUMBER() OVER(PARTITION BY H0.TBBESTU_PIDM, H0.TBBESTU_TERM_CODE, H0.TIPO_EXENCION ORDER BY H0.TBBEXPT_DESC ASC) = 3 AND H0.TIPO_EXENCION = 'DESCUENTO' THEN H0.TBBEXPT_DESC END AS DESCUENTO_3
								FROM ( SELECT TBBESTU_PIDM, TBBESTU_TERM_CODE, TBBEXPT_DESC
											, CASE WHEN SUBSTR(TBBESTU_EXEMPTION_CODE,5,1) = '1' THEN 'BECA' WHEN SUBSTR(TBBESTU_EXEMPTION_CODE,5,1) IN ('2','3') THEN 'DESCUENTO' END AS TIPO_EXENCION
										FROM ODSMGR.LOE_EXEMPTION_STU_AUTHOR, ODSMGR.LOE_TBBEXPT
										WHERE TBBESTU_EXEMPTION_CODE = TBBEXPT_EXEMPTION_CODE AND TBBESTU_TERM_CODE = TBBEXPT_TERM_CODE AND TBBESTU_DEL_IND IS NULL
										) H0
								) H1
						GROUP BY H1.TBBESTU_PIDM, H1.TBBESTU_TERM_CODE
						) H ON F.PERSON_UID = H.TBBESTU_PIDM AND F.ACADEMIC_PERIOD = H.TBBESTU_TERM_CODE
			LEFT JOIN ODSMGR.ALTERNATIVE_ID I ON F.PERSON_UID = I.ENTITY_UID AND I.ATERNATIVE_ID_TYPE = 'DNI'
												AND I.ALTERNATIVE_ID_ACTIVITY_DATE = (SELECT MAX(I1.ALTERNATIVE_ID_ACTIVITY_DATE) FROM ODSMGR.ALTERNATIVE_ID I1
																						WHERE I1.ENTITY_UID = I.ENTITY_UID AND I1.ATERNATIVE_ID_TYPE = 'DNI')
GROUP BY F.PERSON_UID, F.ID, F.NAME, I.ALTERNATIVE_ID, F.ACADEMIC_PERIOD, F.PROGRAM, F.PROGRAM_DESC, F.CAMPUS_DESC, F.STUDENT_ATTRIBUTE, F.ATRIBUTO_2, F.SOVLCUR_RATE_CODE, H.BECA_1, H.BECA_2, H.DESCUENTO_1, H.DESCUENTO_2, H.DESCUENTO_3
	, F.CURSOS_1, F.CREDITOS_1, F.CURSOS_2, F.CREDITOS_2, F.CURSOS_3, F.CREDITOS_3, F.CURSOS_1 +F.CURSOS_2 +F.CURSOS_3, F.CREDITOS_1 +F.CREDITOS_2 +F.CREDITOS_3
	, TO_CHAR(ROUND((F.CREDITOS_2 +F.CREDITOS_3) *100 / (F.CREDITOS_1 +F.CREDITOS_2 +F.CREDITOS_3),0),'999.90') || '%'
;
