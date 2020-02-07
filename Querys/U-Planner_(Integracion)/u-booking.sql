
--Seccion_yyyymmdd.csv
SELECT '' AS "id_campus"
    , '' AS "id_periodo_academico"
    , '' AS "id_jornada"
    , '' AS "id_seccion"
    , NULL AS "codigo_seccion"
    , NULL AS "nombre_seccion"
    , NULL AS "codigo_grupo"
    , NULL AS "nro_inscritos"
    , NULL AS "id_lista_cruzada"
    , NULL AS "indicador_curso_principal"
    , '' AS "id_curso"
    , NULL AS "nombre_curso"
    , '' AS "id_actividad"
    , NULL AS "nombre_actividad"
    , NULL AS "id_liga"
    , NULL AS "indicador_seccion_padre"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM

--ProgramacionClases_yyyymmdd.csv
SELECT SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , NULL AS "id_categoria"
    , SSBSECT_CRN AS "id_seccion"
    , NULL AS "codigo_grupo"
    , NULL AS "id_actividad"
    , NULL AS "nombre_actividad"
    , '' AS "nro_dia"
    , SUBSTR(SSRMEET_BEGIN_TIME,1,2) || ':' || SUBSTR(SSRMEET_BEGIN_TIME,3,2) AS "hora_inicio"
    , SUBSTR(SSRMEET_END_TIME,1,2) || ':' || SUBSTR(SSRMEET_END_TIME,3,2) AS "hora_termino"
    , NULL AS "nro_modulo"
    , SSRMEET_BLDG_CODE || '-' || SSRMEET_ROOM_CODE AS "id_salon"
    , TO_CHAR(SSRMEET_START_DATE,'YYYY-MM-DD') AS "fecha_inicio"
    , TO_CHAR(SSRMEET_END_DATE,'YYYY-MM-DD') AS "fecha_termino"
FROM SSBSECT, SSRMEET
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSBSECT_TERM_CODE IN ('219435','219534');

--Estudiante_Seccion_yyyymmdd.csv
SELECT SFRSTCR_TERM_CODE AS "id_periodo_academico"
    , SFRSTCR_CRN AS "id_seccion"
    , NULL AS "codigo_grupo"
    , SPRIDEN_ID AS "id_estudiante"
    , NULL AS "id_plan_estudio"
    , NULL AS "indicador_sancionado"
FROM SFRSTCR, SPRIDEN
WHERE SFRSTCR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
    AND SFRSTCR_TERM_CODE IN ('219435','219534');

--Docente_Seccion_yyyymmdd.csv
SELECT DISTINCT SIRASGN_TERM_CODE AS "id_periodo"
    , SIRASGN_CRN AS "id_seccion"
    , SPRIDEN_ID AS "id_docente"
    , SIRASGN_CATEGORY AS "id_categoria"
    , CASE WHEN SIRASGN_PRIMARY_IND = 'Y' 
        THEN 1 ELSE 0 END AS "ind_principal"
FROM SIRASGN, SIBINST S, SPRIDEN
WHERE SIRASGN_PIDM = SIBINST_PIDM
    AND SIBINST_FCST_CODE = 'AC' AND SIBINST_SCHD_IND = 'Y' AND SPRIDEN_LAST_NAME NOT LIKE '%INACTIV%'
    AND S.SIBINST_TERM_CODE_EFF = (SELECT MAX(S1.SIBINST_TERM_CODE_EFF) FROM SIBINST S1
                                    WHERE S1.SIBINST_PIDM = S.SIBINST_PIDM
                                        AND S1.SIBINST_TERM_CODE_EFF < SIRASGN_TERM_CODE)
    AND SIRASGN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SIRASGN_TERM_CODE IN ('219435','219534');
