--Documentos de venta generadados (Boletas & Facturas)
SELECT DISTINCT
    NULL AS n_alumno_id
    , e.s_alumno_codigo
    , e.s_tipo_documento_id
    , e.s_documento_nro
    , MAX(e.n_unidad_negocio_id)
        OVER(PARTITION BY e.s_alumno_codigo,e.s_tipo_documento_id) AS n_unidad_negocio_id
    , e.n_doc_monto_total
    , e.n_doc_monto_pagado
    , e.d_doc_fch
    , e.d_doc_fch_ven
    , e.s_doc_moneda
    , e.s_documento_estado_bi_id
    , e.s_documento_estado_ar_id
    , e.s_doc_semestre
    , e.s_creado_por
    , e.d_fecha_creacion
    , NULL AS s_actualizado_por
    , NULL AS d_fecha_actualizacion
    , NULL AS ClienteNumero
    , NULL AS ClienteCobrarA
    , NULL AS s_tipo_venta
FROM (SELECT DISTINCT
          a.BILL_TO_CUST_ID AS s_alumno_codigo
          , a.BILL_TYPE_ID AS s_tipo_documento_id
          , a.INVOICE AS s_documento_nro
          , CASE WHEN MAX(b.LINE_SEQ_NUM) OVER(PARTITION BY b.INVOICE) = b.LINE_SEQ_NUM
              THEN b.OPERATING_UNIT ELSE NULL END AS n_unidad_negocio_id
          , a.INVOICE_AMOUNT + d.USER_AMT3 AS n_doc_monto_total
          , c.ORIG_ITEM_AMT - c.BAL_AMT AS n_doc_monto_pagado
          , a.INVOICE_DT AS d_doc_fch
          , a.DUE_DT AS d_doc_fch_ven
          , a.BI_CURRENCY_CD AS s_doc_moneda
          , a.BILL_STATUS AS s_documento_estado_bi_id
          , c.ITEM_STATUS AS s_documento_estado_ar_id
          , a.PO_REF AS s_doc_semestre
          , a.CREATEOPRID AS s_creado_por
          , a.ADD_DTTM AS d_fecha_creacion         
      FROM PS_BI_HDR a, PS_BI_LINE_DST b, PS_ITEM c, PS_ITEM_ACTIVITY d
      WHERE a.BUSINESS_UNIT = b.BUSINESS_UNIT AND a.INVOICE = b.INVOICE
          AND a.BUSINESS_UNIT = c.BUSINESS_UNIT(+) AND a.INVOICE = c.ITEM(+)
          AND c.BUSINESS_UNIT = d.BUSINESS_UNIT(+) AND c.ITEM = d.ITEM(+) AND d.ITEM_SEQ_NUM(+) = 1
          AND a.BUSINESS_UNIT = 'PER03') e;
