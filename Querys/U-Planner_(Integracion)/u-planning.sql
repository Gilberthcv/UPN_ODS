
--Institucion_yyyymmdd.csv
SELECT 'UPN' AS "id_institucion"
    , 'Universidad Privada del Norte' AS "nombre_institucion"
FROM DUAL;

--Campus_yyyymmdd.csv
SELECT STVCAMP_CODE AS "id_campus"
    , STVCAMP_CODE AS "codigo_campus"
    , STVCAMP_DESC AS "nombre_campus"
    , 'UPN' AS "id_institucion"
FROM LOE_STVCAMP
WHERE STVCAMP_CODE <> 'M';

--PeriodoAcademico_yyyymmdd.csv
SELECT STVTERM_CODE AS "id_periodo_academico"
    , NULL AS "codigo_periodo_academico"
    , STVTERM_DESC AS "nombre_periodo_academico"
    , NULL AS "codigo_tipo_periodo_academico"
    , CASE SUBSTR(STVTERM_CODE,4,1)
            WHEN '3' THEN 'trimestre'
            WHEN '4' THEN 'cuatrimestre UG'
            WHEN '5' THEN 'cuatrimestre WA'
            WHEN '7' THEN 'cuatrimestre INGLES'
            WHEN '8' THEN 'periodo MAESTRIAS'
            WHEN '9' THEN 'periodo DIPLOMADOS'
        ELSE NULL END AS "nombre_tipo_periodo_academico"
    , CASE
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '00' AND SUBSTR(STVTERM_CODE,5,2) < '09' THEN 0
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '08' AND SUBSTR(STVTERM_CODE,5,2) < '26' THEN 1
            WHEN SUBSTR(STVTERM_CODE,4,1) IN ('4','5') AND SUBSTR(STVTERM_CODE,5,2) > '25' AND SUBSTR(STVTERM_CODE,5,2) < '46' THEN 2
        ELSE 9 END AS "numero_periodo_academico"
    , STVTERM_ACYR_CODE AS "agno_periodo_academico"
    , NULL AS "indicador_periodo_regular"
    , NULL AS "numero_semanas"
    , STVTERM_START_DATE AS "fecha_inicio_periodo"
    , STVTERM_END_DATE AS "fecha_fin_periodo"
    , NULL AS "indicador_actual"
    , 1 AS "indicador_programable"
FROM LOE_STVTERM
WHERE SUBSTR(STVTERM_CODE,1,3) >= '219' AND SUBSTR(STVTERM_CODE,4,1) IN ('4','5');

--Jornada_yyyymmdd.csv
SELECT 'JORNADA UNICA' AS "id_jornada"
    , NULL AS "codigo_jornada"
    , 'JORNADA UNICA' AS "nombre_jornada"
    , CASE WHEN SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7')
        THEN TO_NUMBER(SUBSTR(STVMEET_CODE,1,1))
        ELSE 9 END AS "numero_dia"
    , SUBSTR(STVMEET_CODE,2,1) AS "id_bloque_hora_clase"
    , NULL AS "codigo_bloque_hora_clase"
    , STVMEET_CODE AS "nombre_bloque_hora_clase"
    , CASE WHEN SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7')
        THEN (CASE SUBSTR(STVMEET_CODE,2,1)
                    WHEN 'A' THEN 1
                    WHEN 'B' THEN 2
                    WHEN 'C' THEN 3
                    WHEN 'D' THEN 4
                    WHEN 'E' THEN 5
                    WHEN 'F' THEN 6
                    WHEN 'G' THEN 7
                    WHEN 'H' THEN 8
                    WHEN 'I' THEN 9
                ELSE NULL END)
        ELSE NULL END AS "orden_bloque_hora_clase"
    , SUBSTR(STVMEET_BEGIN_TIME,1,2)||':'||SUBSTR(STVMEET_BEGIN_TIME,3,2) AS "hora_inicio"
    , SUBSTR(STVMEET_END_TIME,1,2)||':'||SUBSTR(STVMEET_END_TIME,3,2) AS "hora_fin"
FROM STVMEET
WHERE (SUBSTR(STVMEET_CODE,1,1) IN ('1','2','3','4','5','6','7') AND SUBSTR(STVMEET_CODE,2,1) IN ('A','B','C','D','E','F','G','H','I'))
    OR STVMEET_CODE IN ('TC','VR');

--Facultad_yyyymmdd.csv
SELECT STVCOLL_CODE AS "id_facultad"
    , NULL AS "codigo_facultad"
    , STVCOLL_DESC AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM STVCOLL
WHERE STVCOLL_CODE NOT IN ('00','99')
UNION --FACULTAD GENERICA
SELECT 'GE' AS "id_facultad"
    , NULL AS "codigo_facultad"
    , 'Gen�rica' AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM DUAL;

--Departamento_yyyymmdd.csv
SELECT STVDEPT_CODE AS "id_departamento"
    , NULL AS "codigo_departamento"
    , STVDEPT_DESC AS "nombre_departamento"
    , CASE STVDEPT_CODE
            WHEN 'DCIE' THEN 'IN'
            WHEN 'DHUM' THEN 'CO'
            WHEN 'IDIO' THEN 'ID'
        ELSE 'GE' END AS "id_facultad"
FROM STVDEPT
WHERE STVDEPT_CODE NOT IN ('0000','ART')
UNION --DEPARTAMENTO GENERICO
SELECT 'GENE' AS "id_departamento"
    , NULL AS "codigo_departamento"
    , 'Dpto. Gen�rico' AS "nombre_departamento"
    , 'GE' AS "id_facultad"
FROM DUAL;

--Carrera_yyyymmdd.csv
SELECT SMRPRLE_PROGRAM AS "id_carrera"
    , NULL AS "codigo_carrera"
    , SMRPRLE_PROGRAM_DESC AS "nombre_carrera"
    , SMRPRLE_COLL_CODE AS "id_facultad"
    , 'TPO_CARR' AS "id_tipo_carrera"
    , NULL AS "codigo_tipo_carrera"
    , 'TIPO CARRERA GEN�RICO' AS "nombre_tipo_carrera"
FROM LOE_SMRPRLE
WHERE SMRPRLE_PROGRAM <> 'UNDECLARED';

--PlanEstudio_yyyymmdd.csv
SELECT DISTINCT PROGRAM||'.'||TERM_CODE_EFF AS "id_plan_estudio"
    , NULL AS "codigo_plan_estudio"
    , SMRPRLE_PROGRAM_DESC||'.'||TERM_CODE_EFF AS "nombre_plan_estudio"
    , PROGRAM AS "id_carrera"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM LOE_PROGRAM_AREA_PRIORITY, LOE_SMRPRLE
WHERE PROGRAM = SMRPRLE_PROGRAM;

--Curso_yyyymmdd.csv
SELECT COURSE_IDENTIFICATION/*||'.'||ACADEMIC_PERIOD*/ AS "id_curso"
    , NULL AS "codigo_curso"
    , NVL(TITLE_LONG_DESC,TITLE_SHORT_DESC) AS "nombre_curso"
    , CASE WHEN DEPARTMENT IN ('DCIE','DHUM','IDIO')
            THEN DEPARTMENT
        ELSE 'GENE' END AS "id_departamento"
    , NULL AS "numero_creditos"
    , NULL AS "indicador_actividad_mismo_dia"
    , NULL AS "indicador_curso_generico"
FROM COURSE_CATALOG
WHERE STATUS = 'A' AND ACADEMIC_PERIOD = '999999' AND COLLEGE <> 'GR';

--Docente_yyyymmdd.csv
SELECT DISTINCT SIBINST_PIDM AS "id_docente"
    , SPRIDEN_ID AS "codigo_docente"
    , NULL AS "username"
    , SPRIDEN_FIRST_NAME AS "nombres_docente"
    , CASE WHEN INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
            THEN SPRIDEN_LAST_NAME
        ELSE SUBSTR(SPRIDEN_LAST_NAME,1,INSTR(SPRIDEN_LAST_NAME,'/',1,1)-1) END AS "apellido_paterno"
    , CASE WHEN INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
            THEN NULL
        ELSE SUBSTR(SPRIDEN_LAST_NAME,INSTR(SPRIDEN_LAST_NAME,'/',1,1)+1) END AS "apellido_materno"
    , NULL AS "correo_electronico_docente"
    , NULL AS "telefono_docente"
FROM SIBINST S, SPRIDEN
WHERE SIBINST_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND SIBINST_FCST_CODE = 'AC' AND SIBINST_SCHD_IND = 'Y' AND SPRIDEN_LAST_NAME NOT LIKE '%INACTIV%'
    AND S.SIBINST_TERM_CODE_EFF = (SELECT MAX(S1.SIBINST_TERM_CODE_EFF) FROM SIBINST S1
                                    WHERE S1.SIBINST_PIDM = S.SIBINST_PIDM);

--PlanEstudio_Curso_yyyymmdd.csv
SELECT DISTINCT A.PROGRAM||'.'||A.TERM_CODE_EFF AS "id_plan"
    , CASE WHEN AREA_RULE IS NULL
            THEN B.SUBJ_CODE||B.CRSE_NUMB_LOW/*||'.'||B.TERM_CODE_EFF*/
        ELSE C.SMRARUL_SUBJ_CODE||C.SMRARUL_CRSE_NUMB_LOW/*||'.'||C.SMRARUL_TERM_CODE_EFF*/ END AS "id_curso"
    , TO_NUMBER(SUBSTR(A.AREA,LENGTH(A.AREA)-1,2)) AS "numero_nivel"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    AND SUBSTR(A.AREA,LENGTH(A.AREA)-1,2) IN ('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14');

--Curso_Actividad_yyyymmdd.csv
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HT' AS "id_actividad"
    , NULL AS "codigo_actividad"
    , 'Teor�a' AS "nombre_actividad"
    , ROUND(D.LECTURE_MIN/2,0) AS "numero_bloques_semana"
    , ROUND(D.LECTURE_MIN/2,0) AS "numero_bloques_consecutivos"
    , 60 AS "cupo_academico"
    , 1 AS "indicador_horario_requerido"
    , 1 AS "indicador_sala_requerido"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.LECTURE_MIN IS NOT NULL AND D.LECTURE_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR'
UNION
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HP' AS "id_actividad"
    , NULL AS "codigo_actividad"
    , 'Pr�ctica' AS "nombre_actividad"
    , ROUND(D.OTHER_MIN/2,0) AS "numero_bloques_semana"
    , ROUND(D.OTHER_MIN/2,0) AS "numero_bloques_consecutivos"
    , 60 AS "cupo_academico"
    , 1 AS "indicador_horario_requerido"
    , 1 AS "indicador_sala_requerido"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.OTHER_MIN IS NOT NULL AND D.OTHER_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR'
UNION
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HL' AS "id_actividad"
    , NULL AS "codigo_actividad"
    , 'Laboratorio' AS "nombre_actividad"
    , ROUND(D.LAB_MIN/2,0) AS "numero_bloques_semana"
    , ROUND(D.LAB_MIN/2,0) AS "numero_bloques_consecutivos"
    , 60 AS "cupo_academico"
    , 1 AS "indicador_horario_requerido"
    , 1 AS "indicador_sala_requerido"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.LAB_MIN IS NOT NULL AND D.LAB_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR';

--Curso_Actividad_TipoUso_yyyymmdd.csv
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HT' AS "id_actividad"
    , '' AS "id_tipo_uso"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.LECTURE_MIN IS NOT NULL AND D.LECTURE_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR'
UNION
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HP' AS "id_actividad"
    , '' AS "id_tipo_uso"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.OTHER_MIN IS NOT NULL AND D.OTHER_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR'
UNION
SELECT DISTINCT
    CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , 'HL' AS "id_actividad"
    , '' AS "id_tipo_uso"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND D.LAB_MIN IS NOT NULL AND D.LAB_MIN > 0
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR';
    
--Campus_Periodo_Jornada_Plan_yyyymmdd.csv
SELECT DISTINCT SOBCURR_CAMP_CODE AS "id_campus"
    , STVTERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , PROGRAM  || '.'|| TERM_CODE_EFF AS "id_plan_estudio"
FROM LOE_SOBCURR , LOE_PROGRAM_AREA_PRIORITY, LOE_STVTERM
WHERE SOBCURR_PROGRAM = PROGRAM
    AND SUBSTR(PROGRAM,5,2) = CASE SUBSTR(STVTERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' ELSE NULL END
    AND STVTERM_CODE IN ('220413');    --INGRESAR_PERIODO_NUEVO

--Recurso_yyyymmdd.csv
SELECT SLBBLDG_CAMP_CODE AS "id_campus"
    , SLBRDEF_BLDG_CODE AS "id_edificio"
    , NULL AS "codigo_edificio"
    , STVBLDG_DESC AS "nombre_edificio"
    , SLBBLDG_CAMP_CODE || '-' || SUBSTR(SLBRDEF_ROOM_NUMBER,1,2) AS "id_piso"
    , NULL AS "codigo_piso"
    , SLBBLDG_CAMP_CODE || '-' || SUBSTR(SLBRDEF_ROOM_NUMBER,1,2) AS "nombre_piso"
    , SLBRDEF_BLDG_CODE || '-' || SLBRDEF_ROOM_NUMBER AS "id_recurso"
    , NULL AS "codigo_recurso"
    , SLBRDEF_DESC AS "nombre_recurso"
    , SLBRDEF_CAPACITY AS "numero_capacidad"
    , NULL AS "nm_alto"
    , NULL AS "nm_largo"
    , NULL AS "nm_ancho"
    , NULL AS "numero_metros_cuadrados"
    , NULL AS "indicador_apto_necesidad_espec"
    --, NULL AS "indicador_apto_necesidad_especial"
FROM SLBRDEF, SLBBLDG, STVBLDG
WHERE SLBRDEF_BLDG_CODE = SLBBLDG_BLDG_CODE
    AND SLBRDEF_BLDG_CODE = STVBLDG_CODE
    AND SLBRDEF_RMST_CODE = 'AC' AND SLBBLDG_CAMP_CODE <> 'VIR';

--Recurso_TipoUso_yyyymmdd.csv
SELECT SLBRDEF_BLDG_CODE || '-' || SLBRDEF_ROOM_NUMBER AS "id_recurso"
    , '' AS "id_tipo_recurso"
    , '' AS "nombre_tipo_recurso"
    , SLRRDEF_RDEF_CODE AS "id_tipo_uso"
    , STVRDEF_DESC AS "nombre_tipo_uso"
    , NULL AS "numero_capacidad"
FROM SLBRDEF, SLBBLDG, LOE_SLRRDEF, STVRDEF
WHERE SLBRDEF_BLDG_CODE = SLBBLDG_BLDG_CODE
	AND SLBRDEF_BLDG_CODE = SLRRDEF_BLDG_CODE(+) AND SLBRDEF_ROOM_NUMBER = SLRRDEF_ROOM_NUMBER(+)
	AND SLRRDEF_RDEF_CODE = STVRDEF_CODE(+)
    AND SLBRDEF_RMST_CODE = 'AC' AND SLBBLDG_CAMP_CODE <> 'VIR';

--Demanda_yyyymmdd.csv
SELECT DISTINCT 'UPN' AS "id_institucion"
    , STVCAMP_CODE AS "id_campus"
    , STVTERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , A.PROGRAM AS "id_carrera"
    , NULL AS "nombre_carrera"
    , A.PROGRAM || '.' || A.TERM_CODE_EFF AS "id_plan_estudio"
    , NULL AS "nombre_plan_estudio"
    , NULL AS "numero_nivel"
    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , NULL AS "nombre_curso"
    , '' AS "anio_cohorte_estudiantes"
    , '' AS "inscripciones_estimadas"
    , NULL AS "nota_clase"
    , NULL AS "modalidad"
    , NULL AS "sesion"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, COURSE_CATALOG D, STVCAMP, STVTERM
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND B.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND B.AREA_COURSE = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = D.SUBJECT
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = D.COURSE_NUMBER
    AND STVCAMP_CODE <> 'M'
    AND SUBSTR(A.PROGRAM,5,2) = CASE SUBSTR(STVTERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' ELSE NULL END
    AND D.STATUS = 'A' AND D.ACADEMIC_PERIOD = '999999' AND D.COLLEGE <> 'GR'
    AND STVTERM_CODE IN ('220413');     --INGRESAR_PERIODO_NUEVO

--------------------
--SOLO PARA SIMULACIONES

--Demanda_yyyymmdd.csv
SELECT /* DISTINCT*/'UPN' AS "id_institucion"
    , SSBSECT_CAMP_CODE AS "id_campus"
    , SSBSECT_TERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , A.PROGRAM AS "id_carrera"
    , NULL AS "nombre_carrera"
    , A.PROGRAM || '.' || A.TERM_CODE_EFF AS "id_plan_estudio"
    , NULL AS "nombre_plan_estudio"
    , NULL AS "numero_nivel"
    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/ AS "id_curso"
    , NULL AS "nombre_curso"
    , '' AS "anio_cohorte_estudiantes"
    , SUM(SSBSECT_MAX_ENRL) AS "inscripciones_estimadas"
    , NULL AS "nota_clase"
    , NULL AS "modalidad"
    , NULL AS "sesion"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, SSBSECT
    --, COURSE_CATALOG D, STVCAMP, STVTERM
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND A.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND A.AREA = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = SSBSECT_SUBJ_CODE
    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = SSBSECT_CRSE_NUMB
    --AND STVCAMP_CODE <> 'M'
    AND SUBSTR(A.PROGRAM,5,2) = CASE SUBSTR(SSBSECT_TERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' ELSE NULL END
    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_TERM_CODE = '220413'    --INGRESAR_PERIODO
GROUP BY 'UPN', SSBSECT_CAMP_CODE, SSBSECT_TERM_CODE, 'JORNADA UNICA', A.PROGRAM, NULL, A.PROGRAM || '.' || A.TERM_CODE_EFF, NULL, NULL
    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
        || A.TERM_CODE_EFF*/, NULL, '', NULL, NULL, NULL;

--Demanda_yyyymmdd.csv
SELECT DISTINCT "id_institucion"
    , "id_campus"
    , "id_periodo_academico"
    , "id_jornada"
    , "id_carrera"
    , "nombre_carrera"
    , MAX("id_plan_estudio") OVER(PARTITION BY "id_carrera","id_curso") AS "id_plan_estudio"
    , "nombre_plan_estudio"
    , "numero_nivel"
    , "id_curso"
    , "nombre_curso"
    , "anio_cohorte_estudiantes"
    , "inscripciones_estimadas"
    , "nota_clase"
    , "modalidad"
    , "sesion"
FROM (
		SELECT /* DISTINCT*/'UPN' AS "id_institucion"
		    , SSBSECT_CAMP_CODE AS "id_campus"
		    , SSBSECT_TERM_CODE AS "id_periodo_academico"
		    , 'JORNADA UNICA' AS "id_jornada"
		    , A.PROGRAM AS "id_carrera"
		    , NULL AS "nombre_carrera"
		    , A.PROGRAM || '.' || A.TERM_CODE_EFF AS "id_plan_estudio"
		    , NULL AS "nombre_plan_estudio"
		    , NULL AS "numero_nivel"
		    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
		        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
		        || A.TERM_CODE_EFF*/ AS "id_curso"
		    , NULL AS "nombre_curso"
		    , '' AS "anio_cohorte_estudiantes"
		    , SUM(ROUND(SSBSECT_MAX_ENRL/P.CANT_PROGRAMAS,0)) AS "inscripciones_estimadas"
		    , NULL AS "nota_clase"
		    , NULL AS "modalidad"
		    , NULL AS "sesion"
		FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C, SSBSECT, 
		    (SELECT DISTINCT SSRRPRG_TERM_CODE, SSRRPRG_CRN, SSRRPRG_PROGRAM
		        , COUNT(SSRRPRG_PROGRAM) OVER(PARTITION BY SSRRPRG_TERM_CODE, SSRRPRG_CRN) AS CANT_PROGRAMAS
		    FROM LOE_SSRRPRG
		    WHERE SSRRPRG_REC_TYPE = 2 AND SSRRPRG_TERM_CODE = '220413') P	--INGRESAR_PERIODO
		    --, COURSE_CATALOG D, STVCAMP, STVTERM
		WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
		    AND A.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND A.AREA = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+)
		    --AND A.TERM_CODE_EFF = D.ACADEMIC_PERIOD
		    AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = SSBSECT_SUBJ_CODE
		    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = SSBSECT_CRSE_NUMB
		    AND SSBSECT_TERM_CODE = P.SSRRPRG_TERM_CODE AND SSBSECT_CRN = P.SSRRPRG_CRN
		    AND A.PROGRAM = P.SSRRPRG_PROGRAM
		    AND SUBSTR(A.PROGRAM,5,2) = CASE SUBSTR(SSBSECT_TERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' ELSE NULL END
		    AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_TERM_CODE = '220413'    --INGRESAR_PERIODO
		    /*AND CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END = 'HUMA'
		    AND CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END = '1111'*/
		GROUP BY 'UPN', SSBSECT_CAMP_CODE, SSBSECT_TERM_CODE, 'JORNADA UNICA', A.PROGRAM, NULL, A.PROGRAM || '.' || A.TERM_CODE_EFF, NULL, NULL
		    , CASE WHEN B.AREA_RULE IS NULL THEN B.SUBJ_CODE ELSE C.SMRARUL_SUBJ_CODE END
		        || CASE WHEN B.AREA_RULE IS NULL THEN B.CRSE_NUMB_LOW ELSE C.SMRARUL_CRSE_NUMB_LOW END/*
		        || A.TERM_CODE_EFF*/, NULL, '', NULL, NULL, NULL
       );

--DisponibilidadDocente_yyyymmdd.csv
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , C.PERSON_UID AS "id_docente"
    , C.INSTRUCTOR_NAME AS "nombre_docente" --OPCIONAL
    , D.STVMEET_CODE AS "bloque_horario"
    , NULL AS "hora_inicio"
    , NULL AS "hora_fin"
    , NULL AS "lunes"
    , NULL AS "martes"
    , NULL AS "miercoles"
    , NULL AS "jueves"
    , NULL AS "viernes"
    , NULL AS "sabado"
    , NULL AS "domingo"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C, STVMEET D
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY (+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
    AND ((SUBSTR(D.STVMEET_CODE,1,1) IN ('1','2','3','4','5') AND SUBSTR(D.STVMEET_CODE,2,1) IN ('A','B','C','D','E','F','G','H','I'))
        OR D.STVMEET_CODE IN ('TC','VR') OR D.STVMEET_CODE IN ('6A','6B','6C','6D'))
ORDER BY 2,4;

--Docente_Curso_Actividad_yyyymmdd.csv
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HT' AS "id_actividad"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
    AND A.MIN_LECTURE_HOURS IS NOT NULL AND A.MIN_LECTURE_HOURS > 0
UNION
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HP' AS "id_actividad"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
     AND A.MIN_OTHER_HOURS IS NOT NULL AND A.MIN_OTHER_HOURS > 0
UNION
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HL' AS "id_actividad"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
     AND A.MIN_LAB_HOURS IS NOT NULL AND A.MIN_LAB_HOURS > 0
ORDER BY 6;

--Docente_ValorHora_Evaluacion_yyyymmdd.csv
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HT' AS "id_actividad"
    , NULL AS "valor_hora"
    , NULL AS "evaluacion_academica"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
    AND A.MIN_LECTURE_HOURS IS NOT NULL AND A.MIN_LECTURE_HOURS > 0
UNION
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HP' AS "id_actividad"
    , NULL AS "valor_hora"
    , NULL AS "evaluacion_academica"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
     AND A.MIN_OTHER_HOURS IS NOT NULL AND A.MIN_OTHER_HOURS > 0
UNION
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , A.ACADEMIC_PERIOD AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , C.PERSON_UID AS "id_docente"
    , NULL AS "nombre_docente"
    , A.COURSE_IDENTIFICATION AS "id_curso"
    , 'HL' AS "id_actividad"
    , NULL AS "valor_hora"
    , NULL AS "evaluacion_academica"
FROM SCHEDULE_OFFERING A, MEETING_TIME B, INSTRUCTIONAL_ASSIGNMENT C
WHERE A.COURSE_REFERENCE_NUMBER = B.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+)
    AND A.COURSE_REFERENCE_NUMBER = C.COURSE_REFERENCE_NUMBER (+)
    AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
    AND B.CATEGORY = C.CATEGORY(+)
    AND A.ACADEMIC_PERIOD = '219435'    --INGRESAR_PERIODO_HISTORIA
    AND A.STATUS = 'A'
     AND A.MIN_LAB_HOURS IS NOT NULL AND A.MIN_LAB_HOURS > 0
ORDER BY 6;
