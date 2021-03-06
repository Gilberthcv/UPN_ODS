--SIU_Ocurrencias_
--TIPO_OCURRENCIA	FECHA_OCURRENCIA	TIPO_DOCUMENTO	NRO_DOCUMENTO	CODIGO_PROGRAMA
WITH DOCUMENTO_IDENTIDAD AS (
	SELECT ENTITY_UID, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'DNI' THEN ALTERNATIVE_ID END) AS DNI
		, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'PASS' THEN ALTERNATIVE_ID END) AS PASS
		, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'CNEX' THEN ALTERNATIVE_ID END) AS CNEX
	FROM ODSMGR.ALTERNATIVE_ID I
	WHERE ATERNATIVE_ID_TYPE IN ('DNI','PASS','CNEX')
		AND I.ALTERNATIVE_ID_ACTIVITY_DATE = (SELECT MAX(I1.ALTERNATIVE_ID_ACTIVITY_DATE) FROM ODSMGR.ALTERNATIVE_ID I1
												WHERE I1.ENTITY_UID = I.ENTITY_UID AND I1.ATERNATIVE_ID_TYPE IN ('DNI','PASS','CNEX'))
	GROUP BY ENTITY_UID
)
, MAESTRIA_MOINTL AS (
	SELECT STUD.SOVLCUR_PIDM, SOVLCUR_LEVL_CODE, REGLA.MAESTRIA
	FROM ( SELECT DISTINCT SOVLCUR_PIDM, SOVLCUR_LEVL_CODE, SOVLCUR_PROGRAM
			FROM ODSMGR.LOE_SOVLCUR 
			WHERE SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE'
				AND SOVLCUR_LEVL_CODE = 'EC'/* AND SOVLCUR_CURRENT_IND = 'N'*/ ) STUD
		, ( SELECT N.MAESTRIA, N.TERM_CODE_EFF, SUBSTR(O.AREA,1,6) AS DIPLOMADO
			FROM ( SELECT PROGRAM AS MAESTRIA, TERM_CODE_EFF
					FROM ODSMGR.LOE_PROGRAM_AREA_PRIORITY M
					WHERE PROGRAM <> SUBSTR(AREA,1,6) AND SUBSTR(PROGRAM,1,5) <> 'ING-C'
						AND M.TERM_CODE_EFF = (SELECT MAX(M1.TERM_CODE_EFF) FROM ODSMGR.LOE_PROGRAM_AREA_PRIORITY M1
												WHERE M1.PROGRAM = M.PROGRAM)
					GROUP BY PROGRAM, TERM_CODE_EFF
					HAVING COUNT(SUBSTR(AREA,1,6)) = 2 ) N
				, ODSMGR.LOE_PROGRAM_AREA_PRIORITY O
			WHERE N.MAESTRIA = O.PROGRAM AND N.TERM_CODE_EFF = O.TERM_CODE_EFF AND N.MAESTRIA <> SUBSTR(O.AREA,1,6) ) REGLA
	WHERE STUD.SOVLCUR_PROGRAM = REGLA.DIPLOMADO
	GROUP BY STUD.SOVLCUR_PIDM, SOVLCUR_LEVL_CODE, REGLA.MAESTRIA
	HAVING COUNT(STUD.SOVLCUR_PROGRAM) = 2
)
SELECT A.PERSON_UID, A.ID, 
	CASE
		WHEN A.ENROLLMENT_STATUS IN ('RM','TP') THEN 1
		WHEN A.ENROLLMENT_STATUS = 'RO' THEN 4
		WHEN A.ENROLLMENT_STATUS = 'RF' THEN 5
		END AS TIPO_OCURRENCIA
	, TO_CHAR(A.ENROLLMENT_STATUS_DATE,'DD/MM/YYYY')AS FECHA_OCURRENCIA
	, CASE
		WHEN K.DNI IS NOT NULL AND LENGTH(K.DNI) < 9 THEN 1
		WHEN K.PASS IS NOT NULL AND LENGTH(K.PASS) < 19 THEN 2
		WHEN K.CNEX IS NOT NULL AND LENGTH(K.CNEX) < 19 THEN 3
		ELSE NULL END AS TIPO_DOCUMENTO
	, CASE
		WHEN K.DNI IS NOT NULL AND LENGTH(K.DNI) < 9 THEN K.DNI
		WHEN K.PASS IS NOT NULL AND LENGTH(K.PASS) < 19 THEN K.PASS
		WHEN K.CNEX IS NOT NULL AND LENGTH(K.CNEX) < 19 THEN K.CNEX
		ELSE NULL END AS NRO_DOCUMENTO
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN L.MAESTRIA ELSE A.PROGRAM END)
		WHEN 'ADM-EA' THEN 1
		WHEN 'ADM-FS' THEN 1
		WHEN 'ADM-UG' THEN 1
		WHEN 'ADM-WA' THEN 1
		WHEN 'ABF-UG' THEN 20
		WHEN 'ABF-WA' THEN 20
		WHEN 'AGC-UG' THEN 2
		WHEN 'AGC-WA' THEN 2
		WHEN 'AGT-WA' THEN 21
		WHEN 'AGT-UG' THEN 21
		WHEN 'GPU-WA' THEN 22
		WHEN 'GPU-UG' THEN 22
		WHEN 'AMK-UG' THEN 3
		WHEN 'AMK-WA' THEN 3
		WHEN 'ANI-UG' THEN 4
		WHEN 'ANI-WA' THEN 4
		WHEN 'AST-UG' THEN 5
		WHEN 'AST-WA' THEN 5
		WHEN 'ARQ-UG' THEN 58
		WHEN 'ARQ-WA' THEN 58
		WHEN 'ADI-UG' THEN 6
		WHEN 'ADI-WA' THEN 6
		WHEN 'AGP-UG' THEN 59
		WHEN 'AGP-WA' THEN 59
		WHEN 'AUR-UG' THEN 7
		WHEN 'AUR-WA' THEN 7
		WHEN 'CCO-UG' THEN 60
		WHEN 'CCO-WA' THEN 60
		WHEN 'COM-UG' THEN 23
		WHEN 'COM-WA' THEN 23
		WHEN 'CAM-UG' THEN 8
		WHEN 'CAM-WA' THEN 8
		WHEN 'CCR-UG' THEN 24
		WHEN 'CCR-WA' THEN 24
		WHEN 'CDG-UG' THEN 25
		WHEN 'CDG-WA' THEN 25
		WHEN 'CPE-UG' THEN 9
		WHEN 'CPE-WA' THEN 9
		WHEN 'CPU-UG' THEN 10
		WHEN 'CPU-WA' THEN 10
		WHEN 'CON-UG' THEN 11
		WHEN 'CON-WA' THEN 11
		WHEN 'DEH-WA' THEN 12
		WHEN 'DEH-UG' THEN 12
		WHEN 'DER-WA' THEN 62
		WHEN 'DER-UG' THEN 62
		WHEN 'DIN-UG' THEN 26
		WHEN 'DIN-WA' THEN 26
		WHEN 'DEREPD' THEN 28
		WHEN 'ECO-UG' THEN 29
		WHEN 'ECO-WA' THEN 29
		WHEN 'ENI-UG' THEN 30
		WHEN 'ENI-WA' THEN 30
		WHEN 'EDG-UG' THEN 31
		WHEN 'EDG-WA' THEN 31
		WHEN 'ENF-UG' THEN 32
		WHEN 'ENF-WA' THEN 32
		WHEN 'GGR-UG' THEN 33
		WHEN 'GGR-WA' THEN 33
		WHEN 'AGR-UG' THEN 34
		WHEN 'AGR-WA' THEN 34
		WHEN 'AMB-UG' THEN 13
		WHEN 'AMB-WA' THEN 13
		WHEN 'CIV-UG' THEN 14
		WHEN 'CIV-WA' THEN 14
		WHEN 'MIN-UG' THEN 35
		WHEN 'MIN-WA' THEN 35
		WHEN 'SIS-EA' THEN 63
		WHEN 'SIS-FS' THEN 63
		WHEN 'SIS-UG' THEN 63
		WHEN 'SIS-WA' THEN 63
		WHEN 'SIC-WA' THEN 15
		WHEN 'SIC-UG' THEN 15
		WHEN 'ELE-UG' THEN 36
		WHEN 'ELE-WA' THEN 36
		WHEN 'EMP-UG' THEN 16
		WHEN 'EMP-WA' THEN 16
		WHEN 'GEO-UG' THEN 38
		WHEN 'GEO-WA' THEN 38
		WHEN 'IND-FS' THEN 17
		WHEN 'IND-EA' THEN 17
		WHEN 'IND-UG' THEN 17
		WHEN 'IND-WA' THEN 17
		WHEN 'ILT-UG' THEN 37
		WHEN 'ILT-WA' THEN 37
		WHEN 'MCT-UG' THEN 39
		WHEN 'MCT-WA' THEN 39
		WHEN 'MEAEPM' THEN 40
		WHEN 'DEREPM' THEN 43
		WHEN 'DCGEPM' THEN 43
		WHEN 'DOCAPM' THEN 44
		WHEN 'DGIEPM' THEN 45
		WHEN 'DGTHPM' THEN 46
		WHEN 'FICOPM' THEN 49
		WHEN 'GMGCPM' THEN 50
		WHEN 'GARCPM' THEN 51
		WHEN 'GEPUPM' THEN 53
		WHEN 'INSIPM' THEN 54
		WHEN 'MKNIPM' THEN 55
		WHEN 'MIAEMI' THEN 42
		WHEN 'LMBAPM' THEN 41
		WHEN 'NUT-WA' THEN 18
		WHEN 'NUT-UG' THEN 18
		WHEN 'OBS-UG' THEN 56
		WHEN 'OBS-WA' THEN 56
		WHEN 'PSI-UG' THEN 19
		WHEN 'PSI-WA' THEN 19
		WHEN 'TFI-UG' THEN 57
		WHEN 'TFI-WA' THEN 57
		WHEN 'MKT-UG' THEN 64
		WHEN 'MKT-WA' THEN 64
		ELSE 999999 END AS CODIGO_PROGRAMA
FROM ODSMGR.ACADEMIC_STUDY A
		LEFT JOIN ODSMGR.STUDENT_COURSE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD
												AND B.TRANSFER_COURSE_IND = 'N' AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO','SC')
		LEFT JOIN DOCUMENTO_IDENTIDAD K ON A.PERSON_UID = K.ENTITY_UID
		LEFT JOIN MAESTRIA_MOINTL L ON A.PERSON_UID = L.SOVLCUR_PIDM AND A.STUDENT_LEVEL = L.SOVLCUR_LEVL_CODE
WHERE ((A.ENROLLMENT_STATUS IN ('RF','RO') AND B.PERSON_UID IS NOT NULL) OR A.ENROLLMENT_STATUS NOT IN ('CM') /*OR A.ENROLLMENT_STATUS IN ('RM','TP')*/)
	AND ((A.STUDENT_LEVEL ='UG' AND A.ACADEMIC_PERIOD IN ('221413','221513'))
		OR (A.STUDENT_LEVEL = 'EC' AND A.ACADEMIC_PERIOD = '221953' AND A.PROGRAM = 'MOINTL')/*
		OR (A.STUDENT_LEVEL = 'MA' AND A.ACADEMIC_PERIOD IN ('221813') AND (A.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD_ADMITTED OR A.ACADEMIC_PERIOD_ADMITTED IS NULL))*/)
UNION
SELECT A.PERSON_UID, A.ID, 
	CASE
		WHEN H.HOLD IN ('PD','SP','ST') THEN 2
		WHEN H.HOLD IN ('BA','SD') THEN 3
		END AS TIPO_OCURRENCIA
	, TO_CHAR(H.HOLD_FROM_DATE,'DD/MM/YYYY')AS FECHA_OCURRENCIA
	, CASE
		WHEN K.DNI IS NOT NULL AND LENGTH(K.DNI) < 9 THEN 1
		WHEN K.PASS IS NOT NULL AND LENGTH(K.PASS) < 19 THEN 2
		WHEN K.CNEX IS NOT NULL AND LENGTH(K.CNEX) < 19 THEN 3
		ELSE NULL END AS TIPO_DOCUMENTO
	, CASE
		WHEN K.DNI IS NOT NULL AND LENGTH(K.DNI) < 9 THEN K.DNI
		WHEN K.PASS IS NOT NULL AND LENGTH(K.PASS) < 19 THEN K.PASS
		WHEN K.CNEX IS NOT NULL AND LENGTH(K.CNEX) < 19 THEN K.CNEX
		ELSE NULL END AS NRO_DOCUMENTO
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN L.MAESTRIA ELSE A.PROGRAM END)
		WHEN 'ADM-EA' THEN 1
		WHEN 'ADM-FS' THEN 1
		WHEN 'ADM-UG' THEN 1
		WHEN 'ADM-WA' THEN 1
		WHEN 'ABF-UG' THEN 20
		WHEN 'ABF-WA' THEN 20
		WHEN 'AGC-UG' THEN 2
		WHEN 'AGC-WA' THEN 2
		WHEN 'AGT-WA' THEN 21
		WHEN 'AGT-UG' THEN 21
		WHEN 'GPU-WA' THEN 22
		WHEN 'GPU-UG' THEN 22
		WHEN 'AMK-UG' THEN 3
		WHEN 'AMK-WA' THEN 3
		WHEN 'ANI-UG' THEN 4
		WHEN 'ANI-WA' THEN 4
		WHEN 'AST-UG' THEN 5
		WHEN 'AST-WA' THEN 5
		WHEN 'ARQ-UG' THEN 58
		WHEN 'ARQ-WA' THEN 58
		WHEN 'ADI-UG' THEN 6
		WHEN 'ADI-WA' THEN 6
		WHEN 'AGP-UG' THEN 59
		WHEN 'AGP-WA' THEN 59
		WHEN 'AUR-UG' THEN 7
		WHEN 'AUR-WA' THEN 7
		WHEN 'CCO-UG' THEN 60
		WHEN 'CCO-WA' THEN 60
		WHEN 'COM-UG' THEN 23
		WHEN 'COM-WA' THEN 23
		WHEN 'CAM-UG' THEN 8
		WHEN 'CAM-WA' THEN 8
		WHEN 'CCR-UG' THEN 24
		WHEN 'CCR-WA' THEN 24
		WHEN 'CDG-UG' THEN 25
		WHEN 'CDG-WA' THEN 25
		WHEN 'CPE-UG' THEN 9
		WHEN 'CPE-WA' THEN 9
		WHEN 'CPU-UG' THEN 10
		WHEN 'CPU-WA' THEN 10
		WHEN 'CON-UG' THEN 11
		WHEN 'CON-WA' THEN 11
		WHEN 'DEH-WA' THEN 12
		WHEN 'DEH-UG' THEN 12
		WHEN 'DER-WA' THEN 62
		WHEN 'DER-UG' THEN 62
		WHEN 'DIN-UG' THEN 26
		WHEN 'DIN-WA' THEN 26
		WHEN 'DEREPD' THEN 28
		WHEN 'ECO-UG' THEN 29
		WHEN 'ECO-WA' THEN 29
		WHEN 'ENI-UG' THEN 30
		WHEN 'ENI-WA' THEN 30
		WHEN 'EDG-UG' THEN 31
		WHEN 'EDG-WA' THEN 31
		WHEN 'ENF-UG' THEN 32
		WHEN 'ENF-WA' THEN 32
		WHEN 'GGR-UG' THEN 33
		WHEN 'GGR-WA' THEN 33
		WHEN 'AGR-UG' THEN 34
		WHEN 'AGR-WA' THEN 34
		WHEN 'AMB-UG' THEN 13
		WHEN 'AMB-WA' THEN 13
		WHEN 'CIV-UG' THEN 14
		WHEN 'CIV-WA' THEN 14
		WHEN 'MIN-UG' THEN 35
		WHEN 'MIN-WA' THEN 35
		WHEN 'SIS-EA' THEN 63
		WHEN 'SIS-FS' THEN 63
		WHEN 'SIS-UG' THEN 63
		WHEN 'SIS-WA' THEN 63
		WHEN 'SIC-WA' THEN 15
		WHEN 'SIC-UG' THEN 15
		WHEN 'ELE-UG' THEN 36
		WHEN 'ELE-WA' THEN 36
		WHEN 'EMP-UG' THEN 16
		WHEN 'EMP-WA' THEN 16
		WHEN 'GEO-UG' THEN 38
		WHEN 'GEO-WA' THEN 38
		WHEN 'IND-FS' THEN 17
		WHEN 'IND-EA' THEN 17
		WHEN 'IND-UG' THEN 17
		WHEN 'IND-WA' THEN 17
		WHEN 'ILT-UG' THEN 37
		WHEN 'ILT-WA' THEN 37
		WHEN 'MCT-UG' THEN 39
		WHEN 'MCT-WA' THEN 39
		WHEN 'MEAEPM' THEN 40
		WHEN 'DEREPM' THEN 43
		WHEN 'DCGEPM' THEN 43
		WHEN 'DOCAPM' THEN 44
		WHEN 'DGIEPM' THEN 45
		WHEN 'DGTHPM' THEN 46
		WHEN 'FICOPM' THEN 49
		WHEN 'GMGCPM' THEN 50
		WHEN 'GARCPM' THEN 51
		WHEN 'GEPUPM' THEN 53
		WHEN 'INSIPM' THEN 54
		WHEN 'MKNIPM' THEN 55
		WHEN 'MIAEMI' THEN 42
		WHEN 'LMBAPM' THEN 41
		WHEN 'NUT-WA' THEN 18
		WHEN 'NUT-UG' THEN 18
		WHEN 'OBS-UG' THEN 56
		WHEN 'OBS-WA' THEN 56
		WHEN 'PSI-UG' THEN 19
		WHEN 'PSI-WA' THEN 19
		WHEN 'TFI-UG' THEN 57
		WHEN 'TFI-WA' THEN 57
		WHEN 'MKT-UG' THEN 64
		WHEN 'MKT-WA' THEN 64
		ELSE 999999 END AS CODIGO_PROGRAMA
FROM ODSMGR.ACADEMIC_STUDY A
		INNER JOIN ODSMGR.STUDENT_COURSE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD
												AND B.TRANSFER_COURSE_IND = 'N' AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO','SC')
		INNER JOIN ODSMGR.LOE_SECTION_PART_OF_TERM T ON A.ACADEMIC_PERIOD = T.TERM_CODE
		INNER JOIN ODSMGR.HOLD H ON A.PERSON_UID = H.PERSON_UID /*AND H.HOLD_FROM_DATE BETWEEN T.START_DATE AND T.END_DATE */AND H.HOLD IN ('BA','PD','SD','SP','ST') AND H.ACTIVE_HOLD_IND = 'Y'
		LEFT JOIN DOCUMENTO_IDENTIDAD K ON A.PERSON_UID = K.ENTITY_UID
		LEFT JOIN MAESTRIA_MOINTL L ON A.PERSON_UID = L.SOVLCUR_PIDM AND A.STUDENT_LEVEL = L.SOVLCUR_LEVL_CODE
WHERE A.ENROLLMENT_STATUS IN ('EL','RF','RO','SE')
	AND ((A.STUDENT_LEVEL ='UG' AND A.ACADEMIC_PERIOD IN ('221413','221513'))
		OR (A.STUDENT_LEVEL = 'EC' AND A.ACADEMIC_PERIOD = '221953' AND A.PROGRAM = 'MOINTL')/*
		OR (A.STUDENT_LEVEL = 'MA' AND A.ACADEMIC_PERIOD IN ('221813') AND (A.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD_ADMITTED OR A.ACADEMIC_PERIOD_ADMITTED IS NULL))*/)
;
