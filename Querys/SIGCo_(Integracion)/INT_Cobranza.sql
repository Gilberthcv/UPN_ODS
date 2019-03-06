--Transacciones de cobranza
SELECT DISTINCT
    DEPOSIT_ID AS n_cobranza_id
    , STTLMNT_DT_ACTUAL AS d_cob_fch_prep
    , STTLMNT_DT_ACTUAL AS d_cob_fch_cob
    , OPRID AS s_creador_por
    , NULL AS s_cob_mot_anulacion
    , PAYMENT_STATUS AS s_cob_estado_id
    , ENTERED_DTTM AS d_fecha_creacion
    , NULL AS s_actualizado_por
    , NULL AS d_fecha_actualizacion
FROM PS_PAYMENT
WHERE DEPOSIT_BU = 'PER03';
