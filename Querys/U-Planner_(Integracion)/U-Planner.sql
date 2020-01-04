
--Institucion
SELECT 'UPN' AS "id_institucion"
    , 'Universidad Privada del Norte' AS "nombre_institucion"
FROM DUAL;

--Campus
SELECT STVCAMP_CODE AS "id_campus"
    , STVCAMP_CODE AS "codigo_campus"
    , STVCAMP_DESC AS "nombre_campus"
    , 'UPN' AS "id_institucion"
FROM LOE_STVCAMP
WHERE STVCAMP_CODE <> 'M';

--PeriodoAcademico
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

--Jornada
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

--Facultad
SELECT STVCOLL_CODE AS "id_facultad"
    , NULL AS "codigo_facultad"
    , STVCOLL_DESC AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM STVCOLL
WHERE STVCOLL_CODE NOT IN ('00','99')
UNION --FACULTAD GENERICA
SELECT 'GE' AS "id_facultad"
    , NULL AS "codigo_facultad"
    , 'Genérica' AS "nombre_facultad"
    , 'UPN' AS "id_institucion"
FROM DUAL;

--Departamento
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
    , 'Dpto. Genérico' AS "nombre_departamento"
    , 'GE' AS "id_facultad"
FROM DUAL;

--Carrera
SELECT SMRPRLE_PROGRAM AS "id_carrera"
    , NULL AS "codigo_carrera"
    , SMRPRLE_PROGRAM_DESC AS "nombre_carrera"
    , SMRPRLE_COLL_CODE AS "id_facultad"
    , 'TPO_CARR' AS "id_tipo_carrera"
    , NULL AS "codigo_tipo_carrera"
    , 'TIPO CARRERA GENÉRICO' AS "nombre_tipo_carrera"
FROM LOE_SMRPRLE
WHERE SMRPRLE_PROGRAM <> 'UNDECLARED';

--PlanEstudio
SELECT DISTINCT PROGRAM||'.'||TERM_CODE_EFF AS "id_plan_estudio"
    , NULL AS "codigo_plan_estudio"
    , SMRPRLE_PROGRAM_DESC||'.'||TERM_CODE_EFF AS "nombre_plan_estudio"
    , PROGRAM AS "id_carrera"
    , NULL AS "id_modalidad"
    , NULL AS "nombre_modalidad"
FROM LOE_PROGRAM_AREA_PRIORITY, LOE_SMRPRLE
WHERE PROGRAM = SMRPRLE_PROGRAM;

--Curso
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

--Docente
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

--PlanEstudio_Curso
SELECT DISTINCT A.PROGRAM||'.'||A.TERM_CODE_EFF AS "id_plan"
    , CASE WHEN AREA_RULE IS NULL
            THEN B.SUBJ_CODE||B.CRSE_NUMB_LOW/*||'.'||B.TERM_CODE_EFF*/
        ELSE C.SMRARUL_SUBJ_CODE||C.SMRARUL_CRSE_NUMB_LOW/*||'.'||C.SMRARUL_TERM_CODE_EFF*/ END AS "id_curso"
    , CASE WHEN SUBSTR(A.AREA,LENGTH(A.AREA)-1,2) IN ('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14')
            THEN TO_NUMBER(SUBSTR(A.AREA,LENGTH(A.AREA)-1,2))
        ELSE NULL END AS "numero_nivel"
FROM LOE_PROGRAM_AREA_PRIORITY A, LOE_AREA_COURSE B, LOE_SMRARUL C
WHERE A.TERM_CODE_EFF = B.TERM_CODE_EFF AND A.AREA = B.AREA_COURSE
    AND A.TERM_CODE_EFF = C.SMRARUL_TERM_CODE_EFF(+) AND A.AREA = C.SMRARUL_AREA(+) AND B.AREA_RULE = C.SMRARUL_KEY_RULE(+);

--Campus_Periodo_Jornada_Plan
SELECT DISTINCT SOBCURR_CAMP_CODE AS "id_campus"
    , STVTERM_CODE AS "id_periodo_academico"
    , 'JORNADA UNICA' AS "id_jornada"
    , PROGRAM  || '.'|| TERM_CODE_EFF AS "id_plan_estudio"
FROM LOE_SOBCURR , LOE_PROGRAM_AREA_PRIORITY, LOE_STVTERM
WHERE SOBCURR_PROGRAM = PROGRAM
    AND STVTERM_CODE IN ('219413','219513','219435','219534','220413','220513');

--DisponibilidadDocente
SELECT DISTINCT A.CAMPUS AS "id_campus"
    , C.INSTRUCTOR_ID AS "id_docente"
    , NULL AS "nombre_docente"
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
    AND A.ACADEMIC_PERIOD = '219435'
    AND A.STATUS = 'A'
    AND ((SUBSTR(D.STVMEET_CODE,1,1) IN ('1','2','3','4','5') AND SUBSTR(D.STVMEET_CODE,2,1) IN ('A','B','C','D','E','F','G','H','I'))
        OR D.STVMEET_CODE IN ('TC','VR') OR D.STVMEET_CODE IN ('6A','6B','6C','6D'))
ORDER BY 2,4;

--Recurso
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
    AND SLBRDEF_BLDG_CODE = STVBLDG_CODE;
