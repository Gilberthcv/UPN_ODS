--Detalle del documento de venta
SELECT DISTINCT
    NULL AS n_deuda_id
    , NULL AS n_alumno_id
    , a.BILL_TO_CUST_ID AS s_alumno_codigo
    , a.BILL_TYPE_ID AS s_tipo_documento_id
    , a.INVOICE AS s_documento_nro
    , NULL AS s_concepto_id
    , b.DESCR AS s_deu_nombre
    , b.UNIT_AMT AS n_deu_precio
    , b.GROSS_EXTENDED_AMT AS n_deu_monto
    , b.QTY AS n_deu_cantidad
    , a.INVOICE_DT AS d_deu_fecha_programacion
    , a.DUE_DT AS d_deu_fecha_vencimiento
    , CASE WHEN a.PO_REF > '217000'
          THEN SUBSTR(a.PO_REF,1,1) ||'0'|| SUBSTR(a.PO_REF,2,2)
        ELSE SUBSTR(a.PO_REF,1,4) END AS s_deu_anho
    , a.PO_REF AS s_deu_semestre
    , d.INSTALL_NBR AS n_cuota
    , c.OPERATING_UNIT AS n_unidad_negocio_id
    , a.BILL_STATUS AS s_deuda_estado_bi_id
    , e.ITEM_STATUS AS s_deuda_estado_ar_id
    , f.DEPOSIT_ID AS n_deuda_recibo
    , a.CREATEOPRID AS s_creado_por
    , a.ADD_DTTM AS d_fecha_creacion
    , NULL AS s_actualizado_por
    , NULL AS d_fecha_actualizacion
FROM PS_BI_HDR a, PS_BI_LINE b, PS_BI_LINE_DST c, PS_BI_INSTALL_SCHE d, PS_ITEM e, PS_PAYMENT_ID_ITEM f
WHERE a.BUSINESS_UNIT = b.BUSINESS_UNIT AND a.INVOICE = b.INVOICE
    AND a.BUSINESS_UNIT = c.BUSINESS_UNIT AND a.INVOICE = c.INVOICE AND b.LINE_SEQ_NUM = c.LINE_SEQ_NUM
    AND a.BUSINESS_UNIT = d.BUSINESS_UNIT(+) AND a.INVOICE = d.GENERATED_INVOICE(+)
    AND a.BUSINESS_UNIT = e.BUSINESS_UNIT(+) AND a.INVOICE = e.ITEM(+)
    AND a.BUSINESS_UNIT = f.DEPOSIT_BU(+) AND e.ITEM = f.REF_VALUE(+)
    AND a.BUSINESS_UNIT = 'PER03'
    AND a.CREATEOPRID = 'OVRNITBATCH';
