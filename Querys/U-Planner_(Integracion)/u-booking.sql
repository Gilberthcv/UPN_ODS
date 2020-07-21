
--Seccion_yyyymmdd.csv
SELECT SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , SSBSECT_CRN AS "id_seccion"
    , NULL AS "codigo_seccion"
    , NULL AS "nombre_seccion"
    , NULL AS "codigo_grupo"
    , SSBSECT_ENRL AS "nro_inscritos"
    , NULL AS "id_lista_cruzada"
    , NULL AS "indicador_curso_principal"
    , SSBSECT_SUBJ_CODE || SSBSECT_CRSE_NUMB AS "id_curso"
    , NULL AS "nombre_curso"
    , 'HT' AS "id_actividad"
    , NULL AS "nombre_actividad"
    , NULL AS "id_liga"
    , NULL AS "indicador_seccion_padre"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM ODSMGR.LOE_SSBSECT, ODSMGR.SSRMEET, ODSMGR.COURSE_CATALOG
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE = SUBJECT AND SSBSECT_CRSE_NUMB = COURSE_NUMBER
    AND SSBSECT_TERM_CODE = ACADEMIC_PERIOD
    AND LECTURE_MIN IS NOT NULL AND LECTURE_MIN > 0
    AND STATUS = 'A' AND COLLEGE <> 'GR'
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSBSECT_TERM_CODE IN ('219435')
UNION
SELECT SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , SSBSECT_CRN AS "id_seccion"
    , NULL AS "codigo_seccion"
    , NULL AS "nombre_seccion"
    , NULL AS "codigo_grupo"
    , SSBSECT_ENRL AS "nro_inscritos"
    , NULL AS "id_lista_cruzada"
    , NULL AS "indicador_curso_principal"
    , SSBSECT_SUBJ_CODE || SSBSECT_CRSE_NUMB AS "id_curso"
    , NULL AS "nombre_curso"
    , 'HP' AS "id_actividad"
    , NULL AS "nombre_actividad"
    , NULL AS "id_liga"
    , NULL AS "indicador_seccion_padre"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM ODSMGR.LOE_SSBSECT, ODSMGR.SSRMEET, ODSMGR.COURSE_CATALOG
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE = SUBJECT AND SSBSECT_CRSE_NUMB = COURSE_NUMBER
    AND SSBSECT_TERM_CODE = ACADEMIC_PERIOD
    AND OTHER_MIN IS NOT NULL AND OTHER_MIN > 0
    AND STATUS = 'A' AND COLLEGE <> 'GR'
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSBSECT_TERM_CODE IN ('219435')
UNION
SELECT SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , SSBSECT_CRN AS "id_seccion"
    , NULL AS "codigo_seccion"
    , NULL AS "nombre_seccion"
    , NULL AS "codigo_grupo"
    , SSBSECT_ENRL AS "nro_inscritos"
    , NULL AS "id_lista_cruzada"
    , NULL AS "indicador_curso_principal"
    , SSBSECT_SUBJ_CODE || SSBSECT_CRSE_NUMB AS "id_curso"
    , NULL AS "nombre_curso"
    , 'HL' AS "id_actividad"
    , NULL AS "nombre_actividad"
    , NULL AS "id_liga"
    , NULL AS "indicador_seccion_padre"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM ODSMGR.LOE_SSBSECT, ODSMGR.SSRMEET, ODSMGR.COURSE_CATALOG
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE = SUBJECT AND SSBSECT_CRSE_NUMB = COURSE_NUMBER
    AND SSBSECT_TERM_CODE = ACADEMIC_PERIOD
    AND LAB_MIN IS NOT NULL AND LAB_MIN > 0
    AND STATUS = 'A' AND COLLEGE <> 'GR'
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSBSECT_TERM_CODE IN ('219435');

--ProgramacionClases_yyyymmdd.csv
SELECT SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , SSRMEET_CATAGORY AS "id_categoria"
    , SSBSECT_CRN AS "id_seccion"
    , NULL AS "codigo_grupo"
    , NULL AS "id_actividad"
    , NULL AS "nombre_actividad"
    , CASE SUBSTR(SSRMEET_SUN_DAY||SSRMEET_MON_DAY||SSRMEET_TUE_DAY||SSRMEET_WED_DAY||SSRMEET_THU_DAY||SSRMEET_FRI_DAY||SSRMEET_SAT_DAY,1,1)         
        WHEN 'M' THEN 1 --LUNES 
        WHEN 'T' THEN 2 --MARTES 
        WHEN 'W' THEN 3 --MIERCOLES 
        WHEN 'R' THEN 4 --JUEVES 
        WHEN 'F' THEN 5 --VIERNES 
        WHEN 'S' THEN 6 --SABADO 
        WHEN 'U' THEN 7 --DOMINGO 
        ELSE NULL END AS "nro_dia"
    , SUBSTR(SSRMEET_BEGIN_TIME,1,2) ||':'|| SUBSTR(SSRMEET_BEGIN_TIME,3,2) AS "hora_inicio"
    , SUBSTR(SSRMEET_END_TIME,1,2) ||':'|| SUBSTR(SSRMEET_END_TIME,3,2) AS "hora_termino"
    , NULL AS "nro_modulo"
    , SSRMEET_BLDG_CODE ||'-'|| SSRMEET_ROOM_CODE AS "id_salon"
    , TO_CHAR(SSRMEET_START_DATE,'YYYY-MM-DD') AS "fecha_inicio"
    , TO_CHAR(SSRMEET_END_DATE,'YYYY-MM-DD') AS "fecha_termino"
FROM ODSMGR.LOE_SSBSECT, ODSMGR.SSRMEET
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
    AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
    AND SSBSECT_TERM_CODE IN ('219435');

--Estudiante_Seccion_yyyymmdd.csv
SELECT SFRSTCR_TERM_CODE AS "id_periodo_academico"
    , SFRSTCR_CRN AS "id_seccion"
    , NULL AS "codigo_grupo"
    , SFRSTCR_PIDM AS "id_estudiante"
    , NULL AS "id_plan_estudio"
    , NULL AS "indicador_sancionado"
FROM ODSMGR.SFRSTCR
WHERE SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
    AND SFRSTCR_TERM_CODE IN ('219435');

--Docente_Seccion_yyyymmdd.csv
SELECT DISTINCT SIRASGN_TERM_CODE AS "id_periodo"
    , SIRASGN_CRN AS "id_seccion"
    , SIRASGN_PIDM AS "id_docente"
    , SIRASGN_CATEGORY AS "id_categoria"
    , CASE WHEN SIRASGN_PRIMARY_IND = 'Y' 
        THEN 1 ELSE 0 END AS "ind_principal"
FROM ODSMGR.SIRASGN, ODSMGR.LOE_SIBINST S, ODSMGR.LOE_SPRIDEN
WHERE SIRASGN_PIDM = SIBINST_PIDM
    AND SIBINST_FCST_CODE = 'AC' AND SIBINST_SCHD_IND = 'Y' AND SPRIDEN_LAST_NAME NOT LIKE '%INACTIV%'
    AND S.SIBINST_TERM_CODE_EFF = (SELECT MAX(S1.SIBINST_TERM_CODE_EFF) FROM ODSMGR.LOE_SIBINST S1
                                    WHERE S1.SIBINST_PIDM = S.SIBINST_PIDM
                                        AND S1.SIBINST_TERM_CODE_EFF < SIRASGN_TERM_CODE)
    AND SIRASGN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SIRASGN_TERM_CODE IN ('219435');

--Estudiante_yyyymmdd.csv
SELECT SPRIDEN_PIDM AS "id_estudiante"
    , SPRIDEN_ID AS "codigo_estudiante"
    , SPRIDEN_ID AS "username"
    , SPRIDEN_FIRST_NAME AS "nombres_estudiante"
    , CASE WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0 
            THEN SPRIDEN_LAST_NAME 
        ELSE SUBSTR(SPRIDEN_LAST_NAME,1,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)-1) END AS "apellido_paterno"
    , CASE WHEN REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0 
            THEN NULL 
        ELSE SUBSTR(SPRIDEN_LAST_NAME,REGEXP_INSTR(SPRIDEN_LAST_NAME,'/',1,1)+1) END AS "apellido_materno"
    , SPRIDEN_ID || '@upn.pe' AS "correo_electronico_estudiante"
    , NULL AS "foto"
FROM ODSMGR.LOE_SPRIDEN
WHERE SPRIDEN_CHANGE_IND IS NULL
    AND SPRIDEN_PIDM IN (SELECT DISTINCT SFRSTCR_PIDM FROM ODSMGR.SFRSTCR
                        WHERE SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
                            AND SFRSTCR_TERM_CODE IN ('219435'));
