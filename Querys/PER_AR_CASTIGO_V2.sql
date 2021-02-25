--PER_AR_CASTIGO_V2_
SELECT C.BILL_TO_CUST_ID AS ID_CLIENTE, CONCAT(CONCAT((REPLACE( D.NAME1,'/',' ')),' '), D.NAME2) AS NOMBRE_APELLIDO, A.ITEM AS INVOICE, B.INVOICE2 AS DOC_VENTA
	, C.BILL_TYPE_ID AS TIPO_FACSIS, F.DESCR AS DESCRIPCION, C.INVOICE_AMOUNT AS IMPORTE_ORIGINAL,  C.INVOICE_AMOUNT -  A.BAL_AMT AS PAGADO_CASTIGADO, A.BAL_AMT AS BALANCE_PENDIENTE
	, TO_CHAR(A.ACCOUNTING_DT,'YYYY-MM-DD') AS FECHA_EMISION, TO_CHAR(A.DUE_DT,'YYYY-MM-DD') AS FECHA_VENCIMIENTO, A.BAL_CURRENCY AS MONEDA, C.PO_REF AS PERIODO, E.OPERATING_UNIT AS UNIDAD_EXPLOTACION
	, CASE WHEN G.ENTRY_REASON = 'CASTI' THEN 'Castigo de Cuenta' ELSE ' ' END AS RAZON
	, CASE WHEN G.ENTRY_REASON = 'CASTI' THEN TO_CHAR(CAST((A.LAST_UPDATE_DTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') ELSE ' ' END AS FECHA_CASTIGO
	, CASE WHEN G.ENTRY_REASON = 'CASTI' THEN A.OPRID_LAST_UPDT ELSE ' ' END AS USUARIO_CASTIGO
	, CASE WHEN G.ENTRY_REASON = 'CASTI' THEN H.OPRDEFNDESC ELSE ' ' END AS NOMBRE_USUARIO_CASTIGO
	--, F.SETID,F.BILL_TYPE_ID,TO_CHAR(F.EFFDT,'YYYY-MM-DD')
FROM ODSMGR.PS_ITEM A, ODSMGR.PS_LI_GBL_BI_INV B, ODSMGR.PS_BI_HDR C, ODSMGR.PS_SP_BU_BI_CLSVW C1, ODSMGR.PS_CUSTOMER D, ODSMGR.PS_BI_LINE_DST E, ODSMGR.PS_BI_TYPE F, ODSMGR.PS_ITEM_ACTIVITY G, ODSMGR.PSOPRDEFN H
WHERE ( C.BUSINESS_UNIT = C1.BUSINESS_UNIT
    AND C1.OPRCLASS = 'LI_PPL_PER03_PER'
    AND ( A.DUE_DT BETWEEN TO_DATE(:1,'YYYY-MM-DD') AND TO_DATE(:2,'YYYY-MM-DD')
     AND A.BUSINESS_UNIT = B.BUSINESS_UNIT
     AND B.INVOICE = A.INVOICE
     AND A.BUSINESS_UNIT = C.BUSINESS_UNIT
     AND C.INVOICE = A.INVOICE
     AND C.BILL_TO_CUST_ID = D.CUST_ID
     AND C.BUSINESS_UNIT = E.BUSINESS_UNIT
     AND C.INVOICE = E.INVOICE
     AND F.BILL_TYPE_ID = C.BILL_TYPE_ID
     AND F.EFFDT =
        (SELECT MAX(F_ED.EFFDT) FROM ODSMGR.PS_BI_TYPE F_ED
        WHERE F.SETID = F_ED.SETID
          AND F.BILL_TYPE_ID = F_ED.BILL_TYPE_ID
          AND F_ED.EFFDT <= CURRENT_DATE)
     AND F.SETID = 'PER03'
     AND A.BUSINESS_UNIT = G.BUSINESS_UNIT
     AND A.CUST_ID = G.CUST_ID
     AND A.ITEM = G.ITEM
     AND A.ITEM_LINE = G.ITEM_LINE
     AND G.ITEM_SEQ_NUM = A.ITEM_SEQ_NUM
     AND H.OPRID = A.OPRID_LAST_UPDT
     AND ( CONCAT ( G.ENTRY_TYPE,  G.ENTRY_REASON ) = 'WOCASTI'
     OR A.ITEM_STATUS = 'O') ))
;