--SIU_Ingresantes
/*TIPO_INGRESANTE, CODIGO_SEDE_FILIAL, TIPO_PROCESO, PROCESO_ADMISION_PERIODO_INGRESO, TIPO_DOCUMENTO, NRO_DOCUMENTO
	, NOMBRES, PRIMER_APELLIDO, SEGUNDO_APELLIDO, SOLO_UN_APELLIDO, SEXO, FECHA_NACIMIENTO, PAIS_NACIMIENTO, NACIONALIDAD
	, UBIGEO_NACIMIENTO, UBIGEO_DOMICILIO, LENGUA_NATIVA, IDIOMA_EXTRANJERO, CONDICION_DISCAPACIDAD, CODIGO_FACULTAD_UNIDAD
	, CODIGO_PROGRAMA, FECHA_INGRESO, MODALIDAD_INGRESO, OTRA_MODALIDAD_INGRESO, MODALIDAD_ESTUDIO, CODIGO_ORCID
*/
WITH PROGRAMA_ANTERIOR AS (
	SELECT *
	FROM (
		SELECT DISTINCT A.SOVLCUR_PIDM, A.SOVLCUR_SEQNO, A.SOVLCUR_TERM_CODE, A.SOVLCUR_LEVL_CODE, A.SOVLCUR_USER_ID, A.SOVLCUR_ACTIVITY_DATE
		    , A.SOVLCUR_PROGRAM AS PROGRAMA_DESTINO, B.SOVLCUR_TERM_CODE AS PERIODO_ORIGEN, B.SOVLCUR_PROGRAM AS PROGRAMA_ORIGEN
		FROM ODSMGR.LOE_SOVLCUR A, ODSMGR.LOE_SOVLCUR B
		WHERE A.SOVLCUR_LMOD_CODE = 'LEARNER' AND A.SOVLCUR_CACT_CODE = 'ACTIVE' AND A.SOVLCUR_LEVL_CODE = 'UG'
		    AND A.SOVLCUR_PIDM = B.SOVLCUR_PIDM
		    AND B.SOVLCUR_SEQNO = ( SELECT MAX(B1.SOVLCUR_SEQNO) FROM ODSMGR.LOE_SOVLCUR B1
		                            WHERE B1.SOVLCUR_PIDM = B.SOVLCUR_PIDM AND SUBSTR(B1.SOVLCUR_PROGRAM,1,3) <> SUBSTR(A.SOVLCUR_PROGRAM,1,3)
		                                AND B1.SOVLCUR_SEQNO < A.SOVLCUR_SEQNO AND B1.SOVLCUR_TERM_CODE_END = A.SOVLCUR_TERM_CODE
		                                AND B1.SOVLCUR_LMOD_CODE = 'LEARNER'
		                                AND B1.SOVLCUR_CACT_CODE = 'ACTIVE'
		                                AND B1.SOVLCUR_LEVL_CODE = 'UG'
		                                AND B1.SOVLCUR_PROGRAM NOT LIKE '%PDN%' )
		) C
	WHERE (SUBSTR(C.PERIODO_ORIGEN,4,1) <> '3' OR C.PERIODO_ORIGEN < '217300')
)
, DOCUMENTO_IDENTIDAD AS (
	SELECT ENTITY_UID, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'DNI' THEN ALTERNATIVE_ID END) AS DNI
		, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'PASS' THEN ALTERNATIVE_ID END) AS PASS
		, MAX(CASE WHEN ATERNATIVE_ID_TYPE = 'CNEX' THEN ALTERNATIVE_ID END) AS CNEX
	FROM ODSMGR.ALTERNATIVE_ID I
	WHERE ATERNATIVE_ID_TYPE IN ('DNI','PASS','CNEX')
		AND ALTERNATIVE_ID_ACTIVITY_DATE = (SELECT MAX(I1.ALTERNATIVE_ID_ACTIVITY_DATE) FROM ODSMGR.ALTERNATIVE_ID I1
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
SELECT DISTINCT A.PERSON_UID, A.ID, A.STUDENT_LEVEL
	, CASE
		WHEN O.MAESTRIA IS NOT NULL THEN A.PROGRAM ||' - '|| O.MAESTRIA
		WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_PROGRAM
		ELSE A.PROGRAM END AS PROGRAMA
	, CASE
		WHEN N.DNI IS NOT NULL THEN 'DNI - ' || N.DNI
		WHEN N.PASS IS NOT NULL THEN 'PASS - ' || N.PASS
		WHEN N.CNEX IS NOT NULL THEN 'CNEX - ' || N.CNEX
		ELSE NULL END AS DOCUMENTO_IDENTIDAD
	, CASE A.STUDENT_POPULATION
		WHEN 'N' THEN 
			CASE 
				WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'NEW_REING' THEN 'Nuevo Reingreso'
				WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'REINGRESO' THEN 'Reingreso'
				WHEN A.ADMISSIONS_POPULATION = 'II' THEN 'Intercambio IN'
				ELSE 'Nuevo' END
		WHEN 'C' THEN 
			CASE 
				WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'NEW_REING' THEN 'Nuevo Reingreso'
				WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT = 'REINGRESO' THEN 'Reingreso'
				WHEN A.ADMISSIONS_POPULATION = 'II' THEN 'Intercambio IN'
				WHEN A.ADMISSIONS_POPULATION <> 'RE' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Intercambio OUT'
				WHEN E.ACTIVITY = 'DTO' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Doble Titulacion OUT'
				WHEN E.ACTIVITY = 'ITO' AND D.STUDENT_ATTRIBUTE = 'TINT' THEN 'Intercambio OUT'
				ELSE 'Continuo' END
		ELSE A.STUDENT_POPULATION END AS TIPO_ESTUDIANTE, 
	CASE
		WHEN A.STUDENT_LEVEL = 'UG'
			THEN ( CASE
					WHEN A.ADMISSIONS_POPULATION = 'II'
						OR (A.ADMISSIONS_POPULATION <> 'RE' AND D.STUDENT_ATTRIBUTE = 'TINT')
						OR (E.ACTIVITY = 'DTO' AND D.STUDENT_ATTRIBUTE = 'TINT')
						OR (E.ACTIVITY = 'ITO' AND D.STUDENT_ATTRIBUTE = 'TINT') THEN 3
					WHEN SUBSTR(G.STVTERM_DESC,1,6) = SUBSTR(J.STVTERM_DESC,1,6) THEN 1
					ELSE 2 END )
		WHEN A.STUDENT_LEVEL IN ('EC','MA')
			THEN ( CASE WHEN SUBSTR(J.STVTERM_DESC,1,6) = '2020-1' THEN 1 ELSE 2 END )
		END AS TIPO_INGRESANTE
	, CASE (CASE WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_CAMP_CODE ELSE A.CAMPUS END)
		WHEN 'CAJ' THEN 'F01'
		WHEN 'LC0' THEN 'F02'
		WHEN 'LE0' THEN 'F02'
		WHEN 'LN0' THEN 'F02'
		WHEN 'LN1' THEN 'F02'
		WHEN 'LS0' THEN 'F02'
		WHEN 'TML' THEN 'S'
		WHEN 'TSI' THEN 'S'
		ELSE NULL END AS CODIGO_SEDE_FILIAL
	, CASE
		WHEN (A.STUDENT_LEVEL = 'UG' AND SUBSTR(G.STVTERM_DESC,1,6) = SUBSTR(J.STVTERM_DESC,1,6))
				OR (A.STUDENT_LEVEL IN ('EC','MA') AND SUBSTR(J.STVTERM_DESC,1,6) = '2020-1')
		THEN 1 END AS TIPO_PROCESO
	, SUBSTR(J.STVTERM_DESC,1,6) AS PROCESO_ADMISION_PERIODO_INGRESO
	, CASE
		WHEN N.DNI IS NOT NULL AND LENGTH(N.DNI) < 9 THEN 1
		WHEN N.PASS IS NOT NULL AND LENGTH(N.PASS) < 19 THEN 2
		WHEN N.CNEX IS NOT NULL AND LENGTH(N.CNEX) < 19 THEN 3
		ELSE NULL END AS TIPO_DOCUMENTO
	, CASE
		WHEN N.DNI IS NOT NULL AND LENGTH(N.DNI) < 9 THEN N.DNI
		WHEN N.PASS IS NOT NULL AND LENGTH(N.PASS) < 19 THEN N.PASS
		WHEN N.CNEX IS NOT NULL AND LENGTH(N.CNEX) < 19 THEN N.CNEX
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
	, CASE WHEN N.DNI IS NOT NULL AND LENGTH(N.DNI) < 9 THEN '9233' END AS PAIS_NACIMIENTO
	, CASE WHEN N.DNI IS NOT NULL AND LENGTH(N.DNI) < 9 THEN '85' END AS NACIONALIDAD
	, CASE WHEN N.DNI IS NOT NULL AND LENGTH(N.DNI) < 9 THEN '140101' END AS UBIGEO_NACIMIENTO
	, NULL AS UBIGEO_DOMICILIO, NULL AS LENGUA_NATIVA, NULL AS IDIOMA_EXTRANJERO, NULL AS CONDICION_DISCAPACIDAD
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN O.MAESTRIA WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_PROGRAM ELSE A.PROGRAM END)
		WHEN 'ADM-EA' THEN 3
		WHEN 'ADM-FS' THEN 3
		WHEN 'ADM-UG' THEN 3
		WHEN 'ADM-WA' THEN 3
		WHEN 'ABF-UG' THEN 3
		WHEN 'ABF-WA' THEN 3
		WHEN 'AGC-UG' THEN 3
		WHEN 'AGC-WA' THEN 3
		WHEN 'AGT-WA' THEN 3
		WHEN 'AGT-UG' THEN 3
		WHEN 'GPU-WA' THEN 3
		WHEN 'GPU-UG' THEN 3
		WHEN 'AMK-UG' THEN 3
		WHEN 'AMK-WA' THEN 3
		WHEN 'AST-UG' THEN 3
		WHEN 'AST-WA' THEN 3
		WHEN 'ADI-UG' THEN 15
		WHEN 'ADI-WA' THEN 15
		WHEN 'AUR-UG' THEN 15
		WHEN 'AUR-WA' THEN 15
		WHEN 'COM-UG' THEN 9
		WHEN 'COM-WA' THEN 9
		WHEN 'CAM-UG' THEN 9
		WHEN 'CAM-WA' THEN 9
		WHEN 'CCR-UG' THEN 9
		WHEN 'CCR-WA' THEN 9
		WHEN 'CDG-UG' THEN 9
		WHEN 'CDG-WA' THEN 9
		WHEN 'CPE-UG' THEN 9
		WHEN 'CPE-WA' THEN 9
		WHEN 'CPU-UG' THEN 9
		WHEN 'CPU-WA' THEN 9
		WHEN 'CON-UG' THEN 3
		WHEN 'CON-WA' THEN 3
		WHEN 'DEH-WA' THEN 8
		WHEN 'DEH-UG' THEN 8
		WHEN 'DIN-UG' THEN 15
		WHEN 'DIN-WA' THEN 15
		WHEN 'ECO-UG' THEN 3
		WHEN 'ECO-WA' THEN 3
		WHEN 'ENI-UG' THEN 3
		WHEN 'ENI-WA' THEN 3
		WHEN 'EDG-UG' THEN 9
		WHEN 'EDG-WA' THEN 9
		WHEN 'ENF-UG' THEN 11
		WHEN 'ENF-WA' THEN 11
		WHEN 'GGR-UG' THEN 3
		WHEN 'GGR-WA' THEN 3
		WHEN 'AGR-UG' THEN 5
		WHEN 'AGR-WA' THEN 5
		WHEN 'AMB-UG' THEN 5
		WHEN 'AMB-WA' THEN 5
		WHEN 'MIN-UG' THEN 5
		WHEN 'MIN-WA' THEN 5
		WHEN 'SIC-WA' THEN 5
		WHEN 'SIC-UG' THEN 5
		WHEN 'ELE-UG' THEN 5
		WHEN 'ELE-WA' THEN 5
		WHEN 'EMP-UG' THEN 5
		WHEN 'EMP-WA' THEN 5
		WHEN 'GEO-UG' THEN 5
		WHEN 'GEO-WA' THEN 5
		WHEN 'IND-FS' THEN 5
		WHEN 'IND-EA' THEN 5
		WHEN 'IND-UG' THEN 5
		WHEN 'IND-WA' THEN 5
		WHEN 'ILT-UG' THEN 5
		WHEN 'ILT-WA' THEN 5
		WHEN 'MCT-UG' THEN 5
		WHEN 'MCT-WA' THEN 5
		WHEN 'MEAEPM' THEN 18
		WHEN 'DEREPM' THEN 18
		WHEN 'DCGEPM' THEN 18
		WHEN 'DOCAPM' THEN 18
		WHEN 'DGIEPM' THEN 18
		WHEN 'DGTHPM' THEN 18
		WHEN 'FICOPM' THEN 18
		WHEN 'GMGCPM' THEN 18
		WHEN 'GARCPM' THEN 18
		WHEN 'GEPUPM' THEN 18
		WHEN 'INSIPM' THEN 18
		WHEN 'MKNIPM' THEN 18
		WHEN 'MIAEMI' THEN 18
		WHEN 'LMBAPM' THEN 18
		WHEN 'NUT-WA' THEN 11
		WHEN 'NUT-UG' THEN 11
		WHEN 'OBS-UG' THEN 11
		WHEN 'OBS-WA' THEN 11
		WHEN 'PSI-UG' THEN 11
		WHEN 'PSI-WA' THEN 11
		WHEN 'TFI-UG' THEN 11
		WHEN 'TFI-WA' THEN 11
		ELSE 1 END AS CODIGO_FACULTAD_UNIDAD
	, CASE (CASE WHEN A.PROGRAM = 'MOINTL' THEN O.MAESTRIA WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_PROGRAM ELSE A.PROGRAM END)
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
	, TO_CHAR(K.APPLICATION_DATE,'DD/MM/YYYY') AS FECHA_INGRESO
	, CASE (CASE WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_ADMT_CODE ELSE A.ADMISSIONS_POPULATION END)
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
		--WHEN 'MR' THEN 8
		WHEN 'PE' THEN 4
		WHEN 'WB' THEN 8
		WHEN 'IR' THEN 8
		WHEN 'RE' THEN 8
		WHEN 'TE' THEN 3
		WHEN 'UA' THEN 8
		WHEN 'MU' THEN 8	--No utilizar
		WHEN 'DM' THEN 8	--No utilizar
		WHEN 'MN' THEN 8	--No utilizar
		WHEN 'RM' THEN 8	--No utilizar
		WHEN 'PM' THEN 8	--No utilizar
		ELSE 10 END AS MODALIDAD_INGRESO
	, CASE WHEN (CASE WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_ADMT_CODE ELSE A.ADMISSIONS_POPULATION END) NOT IN ('WE','WA','DI','W1','IC','WC','IP','ID','IM','II'/*,'MR'*/,'PE','WB','IR','RE','TE','UA','MU','DM','MN','RM','PM')
		THEN (CASE WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_ADMT_CODE ELSE A.ADMISSIONS_POPULATION_DESC END) END AS OTRA_MODALIDAD_INGRESO
	, CASE WHEN (CASE WHEN L.SOVLCUR_PIDM IS NOT NULL THEN M.SOVLCUR_PROGRAM ELSE A.PROGRAM END) IN ('GPU-UG','GPU-WA') THEN 2 ELSE 1 END AS MODALIDAD_ESTUDIO
	, NULL AS CODIGO_ORCID
FROM ODSMGR.ACADEMIC_STUDY A
		INNER JOIN ODSMGR.STUDENT_COURSE B ON A.PERSON_UID = B.PERSON_UID AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD
												AND B.TRANSFER_COURSE_IND = 'N' AND B.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO','SC')
		INNER JOIN ODSMGR.LOE_SPRIDEN ON A.PERSON_UID = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
		LEFT JOIN ODSMGR.SPBPERS ON SPRIDEN_PIDM = SPBPERS_PIDM
		LEFT JOIN ODSMGR.STUDENT_COHORT C ON A.PERSON_UID = C.PERSON_UID AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD AND C.COHORT IN ('REINGRESO','NEW_REING')
		LEFT JOIN ODSMGR.STUDENT_ATTRIBUTE D ON A.PERSON_UID = D.PERSON_UID AND A.ACADEMIC_PERIOD = D.ACADEMIC_PERIOD AND D.STUDENT_ATTRIBUTE = 'TINT'
		LEFT JOIN ODSMGR.STUDENT_ACTIVITY E ON A.PERSON_UID = E.PERSON_UID AND A.ACADEMIC_PERIOD = E.ACADEMIC_PERIOD AND E.ACTIVITY IN ('DTO','ITO')
		LEFT JOIN ( SELECT DISTINCT PERSON_UID, ID, NAME, CURRICULUM_CHANGE_REASON FROM ODSMGR.FIELD_OF_STUDY
					WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON = 'EGRESADO' AND STUDENT_LEVEL = 'UG'
					) F ON A.PERSON_UID = F.PERSON_UID
		LEFT JOIN ODSMGR.STVTERM G ON A.ACADEMIC_PERIOD = G.STVTERM_CODE
		LEFT JOIN ODSMGR.LOE_SOVLCUR H ON A.PERSON_UID = H.SOVLCUR_PIDM AND A.STUDENT_LEVEL = H.SOVLCUR_LEVL_CODE AND H.SOVLCUR_PROGRAM <> 'PDN-UG'
											AND H.SOVLCUR_TERM_CODE_ADMIT = (SELECT MIN(H1.SOVLCUR_TERM_CODE_ADMIT) FROM ODSMGR.LOE_SOVLCUR H1
																			WHERE H1.SOVLCUR_PIDM = H.SOVLCUR_PIDM AND H1.SOVLCUR_LEVL_CODE = H.SOVLCUR_LEVL_CODE AND H1.SOVLCUR_TERM_CODE_ADMIT IS NOT NULL
																				AND (SUBSTR(H1.SOVLCUR_TERM_CODE_ADMIT,4,1) <> '3' OR H1.SOVLCUR_TERM_CODE_ADMIT < '217300') AND H1.SOVLCUR_PROGRAM <> 'PDN-UG'
																				AND H1.SOVLCUR_LMOD_CODE = 'LEARNER' AND H1.SOVLCUR_CACT_CODE = 'ACTIVE')
		LEFT JOIN ODSMGR.LOE_SOVLCUR I ON A.PERSON_UID = I.SOVLCUR_PIDM AND A.STUDENT_LEVEL = I.SOVLCUR_LEVL_CODE AND A.PROGRAM = I.SOVLCUR_PROGRAM
											AND I.SOVLCUR_TERM_CODE_ADMIT = (SELECT MIN(I1.SOVLCUR_TERM_CODE_ADMIT) FROM ODSMGR.LOE_SOVLCUR I1
																			WHERE I1.SOVLCUR_PIDM = I.SOVLCUR_PIDM AND I1.SOVLCUR_LEVL_CODE = I.SOVLCUR_LEVL_CODE
																				AND I1.SOVLCUR_PROGRAM = I.SOVLCUR_PROGRAM AND I1.SOVLCUR_TERM_CODE_ADMIT IS NOT NULL
																				AND (SUBSTR(I1.SOVLCUR_TERM_CODE_ADMIT,4,1) <> '3' OR I1.SOVLCUR_TERM_CODE_ADMIT < '217300') AND I1.SOVLCUR_PROGRAM <> 'PDN-UG'
																				AND I1.SOVLCUR_LMOD_CODE = 'LEARNER' AND I1.SOVLCUR_CACT_CODE = 'ACTIVE')
		LEFT JOIN ODSMGR.STVTERM J ON CASE
										WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT IN ('REINGRESO','NEW_REING') AND F.PERSON_UID IS NULL THEN H.SOVLCUR_TERM_CODE_ADMIT
										WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT IN ('REINGRESO','NEW_REING') AND F.PERSON_UID IS NOT NULL THEN I.SOVLCUR_TERM_CODE_ADMIT
										WHEN A.STUDENT_POPULATION = 'N' OR A.ADMISSIONS_POPULATION = 'II' OR D.STUDENT_ATTRIBUTE = 'TINT' THEN A.ACADEMIC_PERIOD_ADMITTED
										WHEN A.STUDENT_LEVEL = 'UG' AND A.STUDENT_POPULATION = 'C' AND F.PERSON_UID IS NULL THEN H.SOVLCUR_TERM_CODE_ADMIT
										WHEN A.STUDENT_LEVEL = 'UG' AND A.STUDENT_POPULATION = 'C' AND F.PERSON_UID IS NOT NULL THEN I.SOVLCUR_TERM_CODE_ADMIT
										ELSE A.ACADEMIC_PERIOD_ADMITTED END = J.STVTERM_CODE
		LEFT JOIN ODSMGR.ADMISSIONS_APPLICATION K ON H.SOVLCUR_PIDM = K.PERSON_UID AND H.SOVLCUR_LEVL_CODE = K.STUDENT_LEVEL
													AND CASE
														WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT IN ('REINGRESO','NEW_REING') AND F.PERSON_UID IS NULL THEN H.SOVLCUR_TERM_CODE_ADMIT
														WHEN A.STUDENT_LEVEL = 'UG' AND C.COHORT IN ('REINGRESO','NEW_REING') AND F.PERSON_UID IS NOT NULL THEN I.SOVLCUR_TERM_CODE_ADMIT
														WHEN A.STUDENT_POPULATION = 'N' OR A.ADMISSIONS_POPULATION = 'II' OR D.STUDENT_ATTRIBUTE = 'TINT' THEN A.ACADEMIC_PERIOD_ADMITTED
														WHEN A.STUDENT_LEVEL = 'UG' AND A.STUDENT_POPULATION = 'C' AND F.PERSON_UID IS NULL THEN H.SOVLCUR_TERM_CODE_ADMIT
														WHEN A.STUDENT_LEVEL = 'UG' AND A.STUDENT_POPULATION = 'C' AND F.PERSON_UID IS NOT NULL THEN I.SOVLCUR_TERM_CODE_ADMIT
														ELSE A.ACADEMIC_PERIOD_ADMITTED END = K.ACADEMIC_PERIOD
													AND K.APPLICATION_NUMBER = (SELECT MIN(K1.APPLICATION_NUMBER) FROM ODSMGR.ADMISSIONS_APPLICATION K1
																				WHERE K1.PERSON_UID = K.PERSON_UID AND K1.STUDENT_LEVEL = K.STUDENT_LEVEL
																					AND K1.ACADEMIC_PERIOD = K.ACADEMIC_PERIOD)
		LEFT JOIN PROGRAMA_ANTERIOR L ON A.PERSON_UID = L.SOVLCUR_PIDM AND A.STUDENT_LEVEL = L.SOVLCUR_LEVL_CODE AND A.PROGRAM = L.PROGRAMA_DESTINO
											AND L.SOVLCUR_SEQNO = (SELECT MAX(L1.SOVLCUR_SEQNO) FROM PROGRAMA_ANTERIOR L1
																	WHERE L1.SOVLCUR_PIDM = L.SOVLCUR_PIDM AND L1.SOVLCUR_LEVL_CODE = L.SOVLCUR_LEVL_CODE
																		AND ((SUBSTR(L1.PROGRAMA_DESTINO,4,3) = '-UG' AND L1.SOVLCUR_TERM_CODE <= '220413')
																				OR (SUBSTR(L1.PROGRAMA_DESTINO,4,3) = '-WA' AND L1.SOVLCUR_TERM_CODE <= '220513'))
																		AND L1.PROGRAMA_DESTINO = L.PROGRAMA_DESTINO)
		LEFT JOIN ODSMGR.LOE_SOVLCUR M ON L.SOVLCUR_PIDM = M.SOVLCUR_PIDM AND L.SOVLCUR_LEVL_CODE = M.SOVLCUR_LEVL_CODE AND J.STVTERM_CODE = M.SOVLCUR_TERM_CODE_ADMIT
											AND M.SOVLCUR_SEQNO = (SELECT MIN(M1.SOVLCUR_SEQNO) FROM ODSMGR.LOE_SOVLCUR M1
																			WHERE M1.SOVLCUR_PIDM = M.SOVLCUR_PIDM AND M1.SOVLCUR_LEVL_CODE = M.SOVLCUR_LEVL_CODE
																				AND M1.SOVLCUR_TERM_CODE_ADMIT = M.SOVLCUR_TERM_CODE_ADMIT AND M1.SOVLCUR_PROGRAM <> 'PDN-UG'
																				AND M1.SOVLCUR_LMOD_CODE = 'LEARNER' AND M1.SOVLCUR_CACT_CODE = 'ACTIVE')
		LEFT JOIN DOCUMENTO_IDENTIDAD N ON SPRIDEN_PIDM = N.ENTITY_UID
		LEFT JOIN MAESTRIA_MOINTL O ON A.PERSON_UID = O.SOVLCUR_PIDM AND A.STUDENT_LEVEL = O.SOVLCUR_LEVL_CODE
WHERE A.ENROLLMENT_STATUS IN ('EL','RF','RO','SE')
	AND ((A.STUDENT_LEVEL ='UG' AND A.ACADEMIC_PERIOD IN ('220413','220513'))
		OR (A.STUDENT_LEVEL = 'EC' AND A.ACADEMIC_PERIOD = '220953' AND A.PROGRAM = 'MOINTL')
		OR (A.STUDENT_LEVEL = 'MA' AND A.ACADEMIC_PERIOD IN ('219813','219839','220813') AND (A.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD_ADMITTED OR A.ACADEMIC_PERIOD_ADMITTED IS NULL)))
;
