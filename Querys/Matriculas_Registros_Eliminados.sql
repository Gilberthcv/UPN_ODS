--Matriculas_Registros_Eliminados_
SELECT --X.SFBETRM_PIDM, 
	CAST(X.SPRIDEN_ID AS VARCHAR(20)) AS CODIGO, CAST(X.NOMBRE AS VARCHAR(100)) AS NOMBRE, CAST(X.SFBETRM_TERM_CODE AS VARCHAR(20)) AS SEMESTRE
	, CAST(X.SFBETRM_ESTS_CODE AS VARCHAR(20)) AS ENROLLMENTSTATUS, X.SFBETRM_ESTS_DATE AS FECHAENROLLMENTSTATUS
	, X.REGISTRATION_STATUS_DATE AS FECHAELIMINACIONCURSO, CAST(X.REGISTRATION_USER_ID AS VARCHAR(20)) AS USERIDELIMINACION
	, CAST(U.SPRIDEN_LAST_NAME ||' '|| U.SPRIDEN_FIRST_NAME AS VARCHAR(100)) AS USUARIOELIMINACION
	, X.FECHA_PAGO_FM	--PRE MATRICULA / MATRICULA
	, X.FECHA_PAGO_T1	--CONFIRMACION MATRICULA / CUOTA INICIAL
FROM (
	SELECT SFBETRM_PIDM, SPRIDEN_ID, S.SPRIDEN_LAST_NAME ||' '|| S.SPRIDEN_FIRST_NAME AS NOMBRE, SFBETRM_TERM_CODE, SFBETRM_ESTS_CODE, SFBETRM_ESTS_DATE
		, MIN(D.REGISTRATION_STATUS_DATE) AS REGISTRATION_STATUS_DATE
		, MAX(D.REGISTRATION_USER_ID) AS REGISTRATION_USER_ID
		, MAX(CASE 
			WHEN P.CARGO = 'MATRICULA' AND P.INVOICE_AMOUNT = 0 THEN FECHA_EMISION
			WHEN P.CARGO = 'MATRICULA' AND P.ESTADO_AR = 'O' AND P.INVOICE_AMOUNT <> P.SALDO THEN COALESCE(P.FECHA_PAGO,P.FECHA_CONTABLE)
			WHEN P.CARGO = 'MATRICULA' THEN P.FECHA_PAGO
			END) AS FECHA_PAGO_FM
		, MAX(CASE 
			WHEN P.CARGO = 'CUOTA INICIAL' AND P.INVOICE_AMOUNT = 0 THEN P.FECHA_EMISION
			WHEN P.CARGO = 'CUOTA INICIAL' AND P.ESTADO_AR = 'O' AND P.INVOICE_AMOUNT <> P.SALDO THEN COALESCE(P.FECHA_PAGO,P.FECHA_CONTABLE)
			WHEN P.CARGO = 'CUOTA INICIAL' THEN P.FECHA_PAGO
			END) AS FECHA_PAGO_T1
	FROM ODSMGR.SFBETRM
			INNER JOIN ODSMGR.LOE_SPRIDEN S ON SFBETRM_PIDM = S.SPRIDEN_PIDM AND S.SPRIDEN_CHANGE_IND IS NULL
			INNER JOIN ODSMGR.PS_MATRICULA_CUOTAINICIAL P ON SFBETRM_PIDM = P.PIDM AND SFBETRM_TERM_CODE = P.PERIODO AND P.CARGO IN ('MATRICULA','CUOTA INICIAL')
			INNER JOIN ODSMGR.STUDENT_COURSE_REG_AUDIT D ON SFBETRM_PIDM = D.PERSON_UID AND SFBETRM_TERM_CODE = D.ACADEMIC_PERIOD AND D.REGISTRATION_SOURCE = 'BASE' AND D.REGISTRATION_STATUS IN ('DW','DD')
			LEFT JOIN ODSMGR.SFRSTCR R ON SFBETRM_PIDM = R.SFRSTCR_PIDM AND SFBETRM_TERM_CODE = R.SFRSTCR_TERM_CODE AND R.SFRSTCR_RSTS_CODE NOT IN ('DW','DD')
	WHERE SFBETRM_TERM_CODE IN ('221413','221513') AND SFBETRM_ESTS_CODE = 'EL'
		AND R.SFRSTCR_PIDM IS NULL
	GROUP BY SFBETRM_PIDM, SPRIDEN_ID, SPRIDEN_LAST_NAME ||' '|| SPRIDEN_FIRST_NAME, SFBETRM_TERM_CODE, SFBETRM_ESTS_CODE, SFBETRM_ESTS_DATE
	) X
		LEFT JOIN ODSMGR.LOE_SPRIDEN U ON CASE WHEN SUBSTR(X.REGISTRATION_USER_ID,1,3) = 'BXE' THEN SUBSTR(X.REGISTRATION_USER_ID,5)
											WHEN SUBSTR(X.REGISTRATION_USER_ID,1,1) IN ('U','S') THEN SUBSTR(X.REGISTRATION_USER_ID,2)
											END = U.SPRIDEN_ID AND U.SPRIDEN_CHANGE_IND IS NULL
;
