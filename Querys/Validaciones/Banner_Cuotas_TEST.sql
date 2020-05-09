USE BDTest

SELECT * FROM Banner_Cuotas

SELECT S_SEM_CODIGO, S_ALU_CODIGO, S_CUO_CONCEPTO, SUM(CAST(N_CUO_MONTO AS numeric(10,2))) AS N_CUO_MONTO
	, SUM(CAST(N_CUO_DESCUENTO AS numeric(10,2))) AS N_CUO_DESCUENTO, SUM(CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_BECA
	, SUM(CAST(N_CUO_MONTO AS numeric(10,2)) +CAST(N_CUO_DESCUENTO AS numeric(10,2)) +CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_MONTO_NETO
FROM Banner_Cuotas C
WHERE (ENTRY_REASON <> 'A-DIR' OR ENTRY_REASON IS NULL)
	AND (C.D_CUO_FECHA_PAGO = (SELECT MAX(C1.D_CUO_FECHA_PAGO) FROM Banner_Cuotas C1
								WHERE C1.S_CUO_INVOICE = C.S_CUO_INVOICE) OR C.D_CUO_FECHA_PAGO IS NULL)
GROUP BY S_SEM_CODIGO, S_ALU_CODIGO, S_CUO_CONCEPTO
ORDER BY S_SEM_CODIGO DESC, S_ALU_CODIGO, S_CUO_CONCEPTO DESC

--ANALISIS
SELECT A.S_SEM_CODIGO, A.S_ALU_CODIGO, A.S_CUO_INVOICE, A.N_CUO_INVOICE_AMOUNT, SUM(A.N_CUO_MONTO_NETO) AS MONTO
FROM (
SELECT S_SEM_CODIGO, S_ALU_CODIGO, S_CUO_INVOICE, N_CUO_INVOICE_AMOUNT, S_CUO_CONCEPTO, SUM(CAST(N_CUO_MONTO AS numeric(10,2))) AS N_CUO_MONTO
	, SUM(CAST(N_CUO_DESCUENTO AS numeric(10,2))) AS N_CUO_DESCUENTO, SUM(CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_BECA
	, SUM(CAST(N_CUO_MONTO AS numeric(10,2)) +CAST(N_CUO_DESCUENTO AS numeric(10,2)) +CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_MONTO_NETO
FROM Banner_Cuotas C
WHERE (ENTRY_REASON <> 'A-DIR' OR ENTRY_REASON IS NULL)
	AND (C.D_CUO_FECHA_PAGO = (SELECT MAX(C1.D_CUO_FECHA_PAGO) FROM Banner_Cuotas C1
								WHERE C1.S_CUO_INVOICE = C.S_CUO_INVOICE) OR C.D_CUO_FECHA_PAGO IS NULL)
GROUP BY S_SEM_CODIGO, S_ALU_CODIGO, S_CUO_INVOICE, N_CUO_INVOICE_AMOUNT, S_CUO_CONCEPTO
--ORDER BY S_SEM_CODIGO DESC, S_ALU_CODIGO, S_CUO_CONCEPTO DESC
) A
GROUP BY A.S_SEM_CODIGO, A.S_ALU_CODIGO, A.S_CUO_INVOICE, A.N_CUO_INVOICE_AMOUNT
HAVING A.N_CUO_INVOICE_AMOUNT <> SUM(A.N_CUO_MONTO_NETO)
ORDER BY S_SEM_CODIGO DESC, S_ALU_CODIGO

--TEST
SELECT S_SEM_CODIGO, S_ALU_CODIGO, N_CUO_INVOICE_AMOUNT, S_CUO_CONCEPTO, SUM(CAST(N_CUO_MONTO AS numeric(10,2))) AS N_CUO_MONTO
	, SUM(CAST(N_CUO_DESCUENTO AS numeric(10,2))) AS N_CUO_DESCUENTO, SUM(CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_BECA
	, SUM(CAST(N_CUO_MONTO AS numeric(10,2)) +CAST(N_CUO_DESCUENTO AS numeric(10,2)) +CAST(N_CUO_BECA AS numeric(10,2))) AS N_CUO_MONTO_NETO
FROM Banner_Cuotas
WHERE S_SEM_CODIGO = '220513' AND S_ALU_CODIGO = 'N00093786'
GROUP BY S_SEM_CODIGO, S_ALU_CODIGO, N_CUO_INVOICE_AMOUNT, S_CUO_CONCEPTO
ORDER BY S_SEM_CODIGO DESC, S_ALU_CODIGO, S_CUO_CONCEPTO DESC

SELECT * FROM Banner_Cuotas
WHERE S_SEM_CODIGO = '220513' AND S_ALU_CODIGO = 'N00001283'
ORDER BY S_SEM_CODIGO DESC, S_ALU_CODIGO, S_CUO_CONCEPTO DESC

