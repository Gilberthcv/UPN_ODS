--Matriculas_Pagos
--codigo	fecha_pago	monto	periodo	pre_matr	fecha_pre	confi_matr	fecha_conf	reg_cursos	credit	cant_cursos
SELECT P.PIDM, P.ID, P.PERIODO
	, CASE WHEN (FECHA_PAGO_FM <= FECHA_PAGO_T1 AND FECHA_PAGO_FM IS NOT NULL) OR FECHA_PAGO_T1 IS NULL THEN FECHA_PAGO_FM ELSE FECHA_PAGO_T1 END FECHA_PAGO
	, CASE WHEN (FECHA_PAGO_FM <= FECHA_PAGO_T1 AND FECHA_PAGO_FM IS NOT NULL) OR FECHA_PAGO_T1 IS NULL THEN MONTO_FM ELSE MONTO_T1 END MONTO
	, P.FECHA_PAGO_FM
	, CASE WHEN P.FECHA_PAGO_FM IS NOT NULL THEN P.MONTO_FM END MONTO_FM
	, P.FECHA_PAGO_T1
	, CASE WHEN P.FECHA_PAGO_T1 IS NOT NULL THEN P.MONTO_T1 END MONTO_T1
	, CASE WHEN I.SFRSTCR_PIDM IS NOT NULL THEN 'Y' ELSE 'N' END AS REG_CURSO
	, I.CREDITOS, I.CURSOS
	, CASE WHEN T.SHRTCKN_PIDM IS NULL THEN 'Nuevo' ELSE T.TIPO_ESTUDIANTE END AS TIPO_ESTUDIANTE
FROM (
	SELECT PIDM, ID, PERIODO
		, MAX(CASE 
			WHEN CARGO = 'MATRICULA' AND INVOICE_AMOUNT = 0 THEN FECHA_EMISION
			WHEN CARGO = 'MATRICULA' AND ESTADO_AR = 'O' AND INVOICE_AMOUNT <> SALDO THEN COALESCE(FECHA_PAGO,FECHA_CONTABLE)
			WHEN CARGO = 'MATRICULA' THEN FECHA_PAGO
			END) AS FECHA_PAGO_FM
		, MAX(CASE WHEN (CARGO = 'MATRICULA' AND INVOICE_AMOUNT = 0) OR (CARGO = 'MATRICULA' AND ESTADO_AR = 'O' AND INVOICE_AMOUNT <> SALDO) OR CARGO = 'MATRICULA' THEN CARGO_MONTO END) AS MONTO_FM
		, MAX(CASE 
			WHEN CARGO = 'CUOTA INICIAL' AND INVOICE_AMOUNT = 0 THEN FECHA_EMISION
			WHEN CARGO = 'CUOTA INICIAL' AND ESTADO_AR = 'O' AND INVOICE_AMOUNT <> SALDO THEN COALESCE(FECHA_PAGO,FECHA_CONTABLE)
			WHEN CARGO = 'CUOTA INICIAL' THEN FECHA_PAGO
			END) AS FECHA_PAGO_T1
		, MAX(CASE WHEN (CARGO = 'CUOTA INICIAL' AND INVOICE_AMOUNT = 0) OR (CARGO = 'CUOTA INICIAL' AND ESTADO_AR = 'O' AND INVOICE_AMOUNT <> SALDO) OR CARGO = 'CUOTA INICIAL' THEN CARGO_MONTO END) AS MONTO_T1
	FROM ODSMGR.PS_MATRICULA_CUOTAINICIAL
	WHERE PERIODO IN ('220435','220534')
	GROUP BY PIDM, ID, PERIODO
	) P LEFT JOIN (
				SELECT SFRSTCR_PIDM, SFRSTCR_TERM_CODE, SUM(SFRSTCR_CREDIT_HR) AS CREDITOS, COUNT(SFRSTCR_CRN) AS CURSOS
				FROM ODSMGR.SFRSTCR
				WHERE SFRSTCR_RSTS_CODE IN ('RE','RW','RA','WC','RF')
					AND SFRSTCR_TERM_CODE IN ('220435','220534')
				GROUP BY SFRSTCR_PIDM, SFRSTCR_TERM_CODE
				) I ON P.PIDM = I.SFRSTCR_PIDM AND P.PERIODO = I.SFRSTCR_TERM_CODE
		LEFT JOIN ODSMGR.LOE_TIPO_ESTUDIANTE T ON P.PIDM = T.SHRTCKN_PIDM AND P.PERIODO = T.PERIODO_ACTUAL
WHERE NOT(FECHA_PAGO_FM IS NULL AND FECHA_PAGO_T1 IS NULL)
;