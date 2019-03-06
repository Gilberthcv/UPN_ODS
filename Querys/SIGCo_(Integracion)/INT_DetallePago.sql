--Detalle de la forma de pago
SELECT DISTINCT
    a.DEPOSIT_ID AS n_cobranza_id
    , NULL AS n_cobranza_linea
    , a.PAYMENT_METHOD AS s_tipo_pago_id
    , a.PAYMENT_CURRENCY AS s_det_pago_moneda
    , NULL AS n_det_pago_monto_MN
    , NULL AS n_det_pago_monto_ME    
    , a.PYMT_RATE_MULT AS n_det_pago_tipo_cambio
    , c.PAYMENT_AMT AS s_det_pago_cuenta
    , a.PAYMENT_STATUS AS s_detalle_pago_estado_id
    , a.OPRID AS s_creado_por
    , a.ENTERED_DTTM AS d_fecha_creacion
    , NULL AS s_actualizado_por
    , NULL AS d_fecha_actualizacion
FROM PS_PAYMENT a, PS_PAYMENT_ID_ITEM b, PS_ITEM_ACTIVITY c
WHERE a.DEPOSIT_BU = b.DEPOSIT_BU AND a.DEPOSIT_ID = b.DEPOSIT_ID
    AND a.DEPOSIT_BU = c.BUSINESS_UNIT(+) AND b.REF_VALUE = c.ITEM(+) AND c.ENTRY_TYPE(+) = 'PY'
    AND a.DEPOSIT_BU = 'PER03';
