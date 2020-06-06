
/*TIPO_INGRESANTE, CODIGO_SEDE_FILIAL, TIPO_PROCESO, PROCESO_ADMISION_PERIODO_INGRESO, TIPO_DOCUMENTO, NRO_DOCUMENTO
	, NOMBRES, PRIMER_APELLIDO, SEGUNDO_APELLIDO, SOLO_UN_APELLIDO, SEXO, FECHA_NACIMIENTO, PAIS_NACIMIENTO, NACIONALIDAD
	, UBIGEO_NACIMIENTO, UBIGEO_DOMICILIO, LENGUA_NATIVA, IDIOMA_EXTRANJERO, CONDICION_DISCAPACIDAD, CODIGO_FACULTAD_UNIDAD
	, CODIGO_PROGRAMA, FECHA_INGRESO, MODALIDAD_INGRESO, OTRA_MODALIDAD_INGRESO, MODALIDAD_ESTUDIO, CODIGO_ORCID
*/

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

SELECT --A.PERSON_UID, A.ID, A.STUDENT_LEVEL, CASE WHEN I.MAESTRIA IS NOT NULL THEN A.PROGRAM ||' - '|| I.MAESTRIA ELSE A.PROGRAM END AS PROGRAMA, 
	CASE WHEN C.COHORT IN ('REINGRESO','NEW_REING') THEN 2
		WHEN A.STUDENT_POPULATION = 'N' THEN 1
		WHEN A.ADMISSIONS_POPULATION = 'II'
			OR (A.ADMISSIONS_POPULATION <> 'RE' AND D.STUDENT_ATTRIBUTE = 'TINT')
			OR (E.ACTIVITY = 'DTO' AND D.STUDENT_ATTRIBUTE = 'TINT')
			OR (E.ACTIVITY = 'ITO' AND D.STUDENT_ATTRIBUTE = 'TINT') THEN 3
		ELSE 2 END AS TIPO_INGRESANTE
	, CASE A.CAMPUS
		WHEN 'CAJ' THEN 'F01'
		WHEN 'LC0' THEN 'F02'
		WHEN 'LE0' THEN 'F02'
		WHEN 'LN0' THEN 'F02'
		WHEN 'LN1' THEN 'F02'
		WHEN 'LS0' THEN 'F02'
		WHEN 'TML' THEN 'S'
		WHEN 'TSI' THEN 'S'
		ELSE NULL END AS CODIGO_SEDE_FILIAL
	, '1' AS TIPO_PROCESO
	, MIN(CASE
		WHEN A.STUDENT_LEVEL IN ('EC','MA') THEN SUBSTR(G.STVTERM_DESC,1,4)
		ELSE SUBSTR(G.STVTERM_DESC,1,6) END) AS PROCESO_ADMISION_PERIODO_INGRESO
	, CASE
		WHEN H.DNI IS NOT NULL AND LENGTH(H.DNI) < 9 THEN 1
		WHEN H.PASS IS NOT NULL AND LENGTH(H.PASS) < 19 THEN 2
		WHEN H.CNEX IS NOT NULL AND LENGTH(H.CNEX) < 19 THEN 3
		ELSE NULL END AS TIPO_DOCUMENTO
	, CASE
		WHEN H.DNI IS NOT NULL AND LENGTH(H.DNI) < 9 THEN H.DNI
		WHEN H.PASS IS NOT NULL AND LENGTH(H.PASS) < 19 THEN H.PASS
		WHEN H.CNEX IS NOT NULL AND LENGTH(H.CNEX) < 19 THEN H.CNEX
		ELSE NULL END AS NRO_DOCUMENTO
	, SPRIDEN_FIRST_NAME AS NOMBRES
	, CASE
		WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
			THEN SPRIDEN_LAST_NAME
		ELSE SUBSTR(SPRIDEN_LAST_NAME,1,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)-1) END AS PRIMER_APELLIDO
	, CASE
		WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
			THEN NULL
		ELSE SUBSTR(SPRIDEN_LAST_NAME,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)+1) END AS SEGUNDO_APELLIDO
	, CASE WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0 THEN 1 ELSE 0 END AS SOLO_UN_APELLIDO
	, CASE SPBPERS_SEX WHEN 'M' THEN 1 WHEN 'F' THEN 2 END AS SEXO
	, TO_CHAR(SPBPERS_BIRTH_DATE,'DD/MM/YYYY') AS FECHA_NACIMIENTO
	, 'FALTA' AS PAIS_NACIMIENTO, 'FALTA' AS NACIONALIDAD, 'FALTA' AS UBIGEO_NACIMIENTO
	, NULL AS UBIGEO_DOMICILIO, NULL AS LENGUA_NATIVA, NULL AS IDIOMA_EXTRANJERO, NULL AS CONDICION_DISCAPACIDAD
	, CASE A.COLLEGE
		WHEN 'AR' THEN 15
		WHEN 'SA' THEN 11
		WHEN 'CO' THEN 9
		WHEN 'DE' THEN 8
		WHEN 'IN' THEN 5
		WHEN 'NE' THEN 3
		WHEN 'GR' THEN 18
		ELSE 1 END AS CODIGO_FACULTAD_UNIDAD
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN I.MAESTRIA ELSE A.PROGRAM END)
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
		ELSE 999999 END AS CODIGO_PROGRAMA
	, CASE A.ADMISSIONS_POPULATION
		WHEN 'WE' THEN 3
		WHEN 'WA' THEN 8
		WHEN 'DI' THEN 3
		WHEN 'W1' THEN 8
		WHEN 'IC' THEN 8
		WHEN 'WC' THEN 8
		WHEN 'IP' THEN 8
		WHEN 'ID' THEN 8
		WHEN 'IM' THEN 8
		WHEN 'II' THEN 3
		WHEN 'MR' THEN 8
		WHEN 'PE' THEN 4
		WHEN 'WB' THEN 8
		WHEN 'IR' THEN 8
		WHEN 'RE' THEN 8
		WHEN 'TE' THEN 3
		WHEN 'UA' THEN 8
		ELSE 10 END AS MODALIDAD_INGRESO
	, CASE WHEN A.ADMISSIONS_POPULATION NOT IN ('WE','WA','DI','W1','IC','WC','IP','ID','IM','II','MR','PE','WB','IR','RE','TE','UA')
		THEN A.ADMISSIONS_POPULATION_DESC END AS OTRA_MODALIDAD_INGRESO
	, 1 AS MODALIDAD_ESTUDIO, NULL AS CODIGO_ORCID

FROM ODSMGR.ACADEMIC_STUDY A
		INNER JOIN ODSMGR.STUDENT_COURSE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD
												AND B.TRANSFER_COURSE_IND = 'N' AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF')
		INNER JOIN ODSMGR.LOE_SPRIDEN ON A.PERSON_UID = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
		LEFT JOIN ODSMGR.SPBPERS ON SPRIDEN_PIDM = SPBPERS_PIDM
		LEFT JOIN ODSMGR.STUDENT_COHORT C ON A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD AND C.COHORT IN ('REINGRESO','NEW_REING')
		LEFT JOIN ODSMGR.STUDENT_ATTRIBUTE D ON A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD AND D.STUDENT_ATTRIBUTE = 'TINT'
		LEFT JOIN ODSMGR.STUDENT_ACTIVITY E ON A.PERSON_UID = E.PERSON_UID AND A.ACADEMIC_PERIOD = E.ACADEMIC_PERIOD AND E.ACTIVITY IN ('DTO','ITO')
		LEFT JOIN ODSMGR.LOE_SOVLCUR F ON A.PERSON_UID = F.SOVLCUR_PIDM AND A.STUDENT_LEVEL = F.SOVLCUR_LEVL_CODE AND F.SOVLCUR_TERM_CODE_ADMIT IS NOT NULL
											AND F.SOVLCUR_LMOD_CODE = 'LEARNER' AND F.SOVLCUR_CACT_CODE = 'ACTIVE'
		LEFT JOIN ODSMGR.STVTERM G ON F.SOVLCUR_TERM_CODE_ADMIT = G.STVTERM_CODE
		LEFT JOIN DOCUMENTO_IDENTIDAD H ON SPRIDEN_PIDM = H.ENTITY_UID
		LEFT JOIN MAESTRIA_MOINTL I ON A.PERSON_UID = I.SOVLCUR_PIDM AND A.STUDENT_LEVEL = I.SOVLCUR_LEVL_CODE

WHERE A.ENROLLMENT_STATUS IN ('EL','RF','RO','SE')
	AND ((A.STUDENT_LEVEL ='UG' AND A.ACADEMIC_PERIOD IN ('220413','220513'))
		OR (A.STUDENT_LEVEL = 'EC' AND A.ACADEMIC_PERIOD = '220953' AND A.PROGRAM = 'MOINTL')
		OR (A.STUDENT_LEVEL = 'MA' AND A.ACADEMIC_PERIOD = '220813' AND (A.ACADEMIC_PERIOD = F.SOVLCUR_TERM_CODE_ADMIT OR F.SOVLCUR_TERM_CODE_ADMIT IS NULL)))

GROUP BY --A.PERSON_UID, A.ID, A.STUDENT_LEVEL, CASE WHEN I.MAESTRIA IS NOT NULL THEN A.PROGRAM ||' - '|| I.MAESTRIA ELSE A.PROGRAM END, 
	CASE WHEN C.COHORT IN ('REINGRESO','NEW_REING') THEN 2
		WHEN A.STUDENT_POPULATION = 'N' THEN 1
		WHEN A.ADMISSIONS_POPULATION = 'II'
			OR (A.ADMISSIONS_POPULATION <> 'RE' AND D.STUDENT_ATTRIBUTE = 'TINT')
			OR (E.ACTIVITY = 'DTO' AND D.STUDENT_ATTRIBUTE = 'TINT')
			OR (E.ACTIVITY = 'ITO' AND D.STUDENT_ATTRIBUTE = 'TINT') THEN 3
		ELSE 2 END
	, CASE A.CAMPUS
		WHEN 'CAJ' THEN 'F01'
		WHEN 'LC0' THEN 'F02'
		WHEN 'LE0' THEN 'F02'
		WHEN 'LN0' THEN 'F02'
		WHEN 'LN1' THEN 'F02'
		WHEN 'LS0' THEN 'F02'
		WHEN 'TML' THEN 'S'
		WHEN 'TSI' THEN 'S'
		ELSE NULL END
	, '1'
	, CASE
		WHEN H.DNI IS NOT NULL AND LENGTH(H.DNI) < 9 THEN 1
		WHEN H.PASS IS NOT NULL AND LENGTH(H.PASS) < 19 THEN 2
		WHEN H.CNEX IS NOT NULL AND LENGTH(H.CNEX) < 19 THEN 3
		ELSE NULL END
	, CASE
		WHEN H.DNI IS NOT NULL AND LENGTH(H.DNI) < 9 THEN H.DNI
		WHEN H.PASS IS NOT NULL AND LENGTH(H.PASS) < 19 THEN H.PASS
		WHEN H.CNEX IS NOT NULL AND LENGTH(H.CNEX) < 19 THEN H.CNEX
		ELSE NULL END
	, SPRIDEN_FIRST_NAME
	, CASE
		WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
			THEN SPRIDEN_LAST_NAME
		ELSE SUBSTR(SPRIDEN_LAST_NAME,1,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)-1) END
	, CASE
		WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
			THEN NULL
		ELSE SUBSTR(SPRIDEN_LAST_NAME,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)+1) END
	, CASE WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0 THEN 1 ELSE 0 END
	, CASE SPBPERS_SEX WHEN 'M' THEN 1 WHEN 'F' THEN 2 END
	, TO_CHAR(SPBPERS_BIRTH_DATE,'DD/MM/YYYY')
	, 'FALTA', 'FALTA', 'FALTA'
	, NULL, NULL, NULL, NULL
	, CASE A.COLLEGE
		WHEN 'AR' THEN 15
		WHEN 'SA' THEN 11
		WHEN 'CO' THEN 9
		WHEN 'DE' THEN 8
		WHEN 'IN' THEN 5
		WHEN 'NE' THEN 3
		WHEN 'GR' THEN 18
		ELSE 1 END
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN I.MAESTRIA ELSE A.PROGRAM END)
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
		ELSE 999999 END
	, CASE A.ADMISSIONS_POPULATION
		WHEN 'WE' THEN 3
		WHEN 'WA' THEN 8
		WHEN 'DI' THEN 3
		WHEN 'W1' THEN 8
		WHEN 'IC' THEN 8
		WHEN 'WC' THEN 8
		WHEN 'IP' THEN 8
		WHEN 'ID' THEN 8
		WHEN 'IM' THEN 8
		WHEN 'II' THEN 3
		WHEN 'MR' THEN 8
		WHEN 'PE' THEN 4
		WHEN 'WB' THEN 8
		WHEN 'IR' THEN 8
		WHEN 'RE' THEN 8
		WHEN 'TE' THEN 3
		WHEN 'UA' THEN 8
		ELSE 10 END
	, CASE WHEN A.ADMISSIONS_POPULATION NOT IN ('WE','WA','DI','W1','IC','WC','IP','ID','IM','II','MR','PE','WB','IR','RE','TE','UA')
		THEN A.ADMISSIONS_POPULATION_DESC END
	, 1, NULL;
