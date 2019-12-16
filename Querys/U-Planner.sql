
--Institucion
SELECT 'UPN' AS id_institucion
    , 'Universidad Privada del Norte' AS nombre_institucion
FROM DUAL;

--Campus
SELECT STVCAMP_CODE AS id_campus
    , STVCAMP_CODE AS codigo_campus
    , STVCAMP_DESC AS nombre_campus
    , 'UPN' AS id_institucion
FROM LOE_STVCAMP;

--Facultad
SELECT STVCOLL_CODE AS id_facultad
    , NULL AS codigo_facultad
    , STVCOLL_DESC AS nombre_facultad
    , 'UPN' AS id_institucion
FROM STVCOLL
WHERE STVCOLL_CODE NOT IN ('00','99');

--Departamento
SELECT STVDEPT_CODE AS id_departamento
    , NULL AS codigo_departamento
    , STVDEPT_DESC AS nombre_departamento
    , '' AS id_facultad
FROM STVDEPT
UNION --DEPARTAMENTO GENERICO
SELECT '' AS id_departamento
    , NULL AS codigo_departamento
    , '' AS nombre_departamento
    , '' AS id_facultad
FROM DUAL;

--PlanEstudio
SELECT PROGRAM||'.'||TERM_CODE_EFF AS id_plan_estudio
    , NULL AS codigo_plan_estudio
    , SMRPRLE_PROGRAM_DESC||'.'||TERM_CODE_EFF AS nombre_plan_estudio
    , PROGRAM AS id_carrera
    , NULL AS id_modalidad
    , NULL AS nombre_modalidad
FROM LOE_PROGRAM_AREA_PRIORITY, LOE_SMRPRLE
WHERE PROGRAM = SMRPRLE_PROGRAM;

--Curso
SELECT COURSE_IDENTIFICATION||'.'||ACADEMIC_PERIOD AS id_curso
    , NULL AS codigo_curso
    , NVL(TITLE_LONG_DESC,TITLE_SHORT_DESC) AS nombre_curso
    , '' AS id_departamento
    , NULL AS numero_creditos
    , NULL AS indicador_actividad_mismo_dia
    , NULL AS indicador_curso_generico
FROM COURSE_CATALOG;

--Docente
SELECT DISTINCT SIBINST_PIDM AS id_docente
    , SPRIDEN_ID AS codigo_docente
    , NULL AS username
    , SPRIDEN_FIRST_NAME AS nombres_docente
    , CASE WHEN INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
            THEN SPRIDEN_LAST_NAME
        ELSE SUBSTR(SPRIDEN_LAST_NAME,1,INSTR(SPRIDEN_LAST_NAME,'/',1,1)-1) END AS apellido_paterno
    , CASE WHEN INSTR(SPRIDEN_LAST_NAME,'/',1,1) = 0
            THEN NULL
        ELSE SUBSTR(SPRIDEN_LAST_NAME,INSTR(SPRIDEN_LAST_NAME,'/',1,1)+1) END AS apellido_materno
    , NULL AS correo_electronico_docente
    , NULL AS telefono_docente
FROM SIBINST, SPRIDEN
WHERE SIBINST_PIDM = SPRIDEN_PIDM
    AND SPRIDEN_CHANGE_IND IS NULL;
