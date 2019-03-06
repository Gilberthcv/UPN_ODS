--Detalle de documentos de venta que han sido pagados
SELECT DISTINCT
    a.DEPOSIT_ID AS n_cobranza_id
    , b.BILL_TYPE_ID AS s_tipo_documento_id
    , a.REF_VALUE AS s_documento_nro
    , c.INVOICE2 AS s_documento_nro_gob
    , SUM(d.PAYMENT_AMT) OVER(PARTITION BY d.ITEM) AS n_monto_pagado
FROM PS_PAYMENT_ID_ITEM a, PS_BI_HDR b, PS_LI_GBL_BI_INV c, PS_ITEM_ACTIVITY d
WHERE a.DEPOSIT_BU = b.BUSINESS_UNIT AND a.REF_VALUE = b.INVOICE
    AND a.DEPOSIT_BU = c.BUSINESS_UNIT AND a.REF_VALUE = c.INVOICE
    AND a.DEPOSIT_BU = d.BUSINESS_UNIT AND a.REF_VALUE = d.ITEM
    AND a.DEPOSIT_BU = 'PER03';
