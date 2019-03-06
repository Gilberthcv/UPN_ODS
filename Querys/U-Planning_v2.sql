
--programacion_grupos
--id_periodo_academico, codigo_tipo_periodo_academico, id_campus, id_jornada, id_grupo, id_curso, nombre_curso, id_actividad
--, nombre_actividad, id_tipo_impartir, id_recurso, id_tipo_recurso, cupo_academico, capacidad_recurso, dia_programacion, hora_inicio
--, hora_fin, fecha_evento, id_sesion*, desc_sesion*
SELECT DISTINCT
    a.ACADEMIC_PERIOD AS id_periodo_academico
    , CASE SUBSTR(a.ACADEMIC_PERIOD,4,1) 
          WHEN '3' THEN 'Trimestral' --PDN
          WHEN '4' THEN 'Semestral' --UG
          WHEN '5' THEN 'Semestral' --WA
          WHEN '7' THEN 'Cuatrimestral' --Inglés
          WHEN '8' THEN 'cada 18 meses' --Maestrías
          WHEN '9' THEN 'cada 9 meses' --Diplomados
      ELSE NULL END AS codigo_tipo_periodo_academico, a.CAMPUS AS id_campus
    , CASE b.INSTRUCTION_DELIVERY_MODE 
          WHEN 'P' THEN 'Unica' --Presencial
          WHEN 'V' THEN 'Virtual' --Virtual
      ELSE NULL END AS id_jornada
    , a.ACADEMIC_PERIOD || '.' || a.COURSE_REFERENCE_NUMBER AS id_grupo, a.SUBJECT || a.COURSE_NUMBER AS id_curso
    , NVL(a.TITLE_LONG_DESC,a.TITLE_SHORT_DESC) AS nombre_curso, a.SCHEDULE AS id_actividad, a.SCHEDULE_DESC AS nombre_actividad
    , CASE b.INSTRUCTION_DELIVERY_MODE 
          WHEN 'P' THEN 1 --Unica presencial
          WHEN 'V' THEN 2 --Virtual
      ELSE NULL END AS id_tipo_impartir, b.BUILDING || '.' || b.ROOM AS id_recurso
    , REPLACE(REPLACE(SUBSTR(c.SLBRDEF_DESC,1,INSTR(c.SLBRDEF_DESC,' ',1,1)),'.',''),',','') AS id_tipo_recurso
    , a.MAXIMUM_ENROLLMENT AS cupo_academico, c.SLBRDEF_CAPACITY AS capacidad_recurso
    , CASE 
          WHEN b.MONDAY_IND = 'M' THEN 1 --Lunes
          WHEN b.TUESDAY_IND = 'T' THEN 2 --Martes
          WHEN b.WEDNESDAY_IND = 'W' THEN 3 --Miercoles
          WHEN b.THURSDAY_IND = 'R' THEN 4 --Jueves
          WHEN b.FRIDAY_IND = 'F' THEN 5 --Viernes
          WHEN b.SATURDAY_IND = 'S' THEN 6 --Sabado
          WHEN b.SUNDAY_IND = 'U' THEN 7 --Domingo
      ELSE NULL END AS dia_programacion
    , SUBSTR(b.BEGIN_TIME,1,2) || ':' || SUBSTR(b.BEGIN_TIME,3,2) AS hora_inicio, SUBSTR(b.END_TIME,1,2) || ':' || SUBSTR(b.END_TIME,3,2) AS hora_fin
    , b.FECHA AS fecha_evento, NULL AS id_sesion, NULL AS desc_sesion
FROM 
    SCHEDULE_OFFERING a
    , (SELECT COURSE_REFERENCE_NUMBER, ACADEMIC_PERIOD, START_DATE AS FECHA, SUBJECT, COURSE_NUMBER, TITLE_SHORT_DESC, TITLE_LONG_DESC, INSTRUCTION_DELIVERY_MODE, BEGIN_TIME, END_TIME
      , BUILDING, ROOM, COURSE_CAMPUS, SCHEDULE, SCHEDULE_DESC, MONDAY_IND, TUESDAY_IND, WEDNESDAY_IND, THURSDAY_IND, FRIDAY_IND, SATURDAY_IND, SUNDAY_IND FROM MEETING_TIME
      UNION
      SELECT COURSE_REFERENCE_NUMBER, ACADEMIC_PERIOD, END_DATE AS FECHA, SUBJECT, COURSE_NUMBER, TITLE_SHORT_DESC, TITLE_LONG_DESC, INSTRUCTION_DELIVERY_MODE, BEGIN_TIME, END_TIME
      , BUILDING, ROOM, COURSE_CAMPUS, SCHEDULE, SCHEDULE_DESC, MONDAY_IND, TUESDAY_IND, WEDNESDAY_IND, THURSDAY_IND, FRIDAY_IND, SATURDAY_IND, SUNDAY_IND FROM MEETING_TIME) b
    , SLBRDEF c
WHERE a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD(+) AND a.COURSE_REFERENCE_NUMBER = b.COURSE_REFERENCE_NUMBER(+)
    AND b.BUILDING = c.SLBRDEF_BLDG_CODE(+) AND b.ROOM = c.SLBRDEF_ROOM_NUMBER(+)
    AND a.ACADEMIC_PERIOD IN ('218413','218512') AND a.CAMPUS IN ('TML','TSI');


--Registros_Inscripciones
--id_plan, nm_nivel, id_curso, id_actividad, id_alumno, id_grupo
SELECT DISTINCT
    b.PROGRAM || '.' || b.CATALOG_ACADEMIC_PERIOD AS id_plan
    , NVL(f.CICLO,0) AS nm_nivel
    , a.SUBJECT || a.COURSE_NUMBER AS id_curso, a.SCHEDULE_TYPE AS id_actividad, a.ID AS id_alumno, a.ACADEMIC_PERIOD || '.' || a.COURSE_REFERENCE_NUMBER AS id_grupo
FROM
    (STUDENT_COURSE a
        INNER JOIN ACADEMIC_STUDY b ON
            a.PERSON_UID = b.PERSON_UID
            AND a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD)
        LEFT JOIN (SELECT DISTINCT
                      c.PROGRAM, c.TERM_CODE_EFF
                      , TO_NUMBER(CASE 
                                      WHEN SUBSTR(c.AREA,LENGTH(c.AREA)-1,1) IN ('0','1','2','3','4','5','6','7','8','9')
                                          AND SUBSTR(c.AREA,LENGTH(c.AREA),1) IN ('0','1','2','3','4','5','6','7','8','9')
                                      THEN SUBSTR(c.AREA,LENGTH(c.AREA)-1,2)
                                  ELSE '0' END) AS CICLO
                      , NVL(d.SUBJ_CODE,e.SMRARUL_SUBJ_CODE) AS SUBJ, NVL(d.CRSE_NUMB_LOW,e.SMRARUL_CRSE_NUMB_LOW) AS CRSE
                  FROM 
                      (LOE_PROGRAM_AREA_PRIORITY c
                          INNER JOIN LOE_AREA_COURSE d ON
                              c.TERM_CODE_EFF = d.TERM_CODE_EFF
                              AND c.AREA = d.AREA_COURSE)
                          LEFT JOIN ODSMGR.LOE_SMRARUL e ON
                              c.TERM_CODE_EFF = e.SMRARUL_TERM_CODE_EFF
                              AND c.AREA = e.SMRARUL_AREA
                              AND d.AREA_RULE = e.SMRARUL_KEY_RULE
                  WHERE NVL(d.SUBJ_CODE,e.SMRARUL_SUBJ_CODE) IS NOT NULL AND NVL(d.CRSE_NUMB_LOW,e.SMRARUL_CRSE_NUMB_LOW) IS NOT NULL) f ON
            b.PROGRAM = f.PROGRAM
            AND b.CATALOG_ACADEMIC_PERIOD = f.TERM_CODE_EFF
            AND a.SUBJECT = f.SUBJ
            AND a.COURSE_NUMBER = f.CRSE
WHERE b.STUDENT_LEVEL = 'UG' AND a.ACADEMIC_PERIOD IN ('218413','218512') AND a.CAMPUS IN ('TML','TSI');


--Alumno_PlanEstudio
--id_alumno, id_carrera, nombre_carrera, id_plan, nombre_plan, codigo_tipo_periodo_academico, anio_ingreso, num_periodo_ingreso
SELECT DISTINCT
    ID AS id_alumno, PROGRAM AS id_carrera, PROGRAM_DESC AS nombre_carrera, PROGRAM || '.' || CATALOG_ACADEMIC_PERIOD AS id_plan
    , PROGRAM_DESC || '. Plan ' || CATALOG_ACADEMIC_PERIOD AS nombre_plan
    , CASE SUBSTR(ACADEMIC_PERIOD,4,1) 
          WHEN '3' THEN 'Trimestral' --PDN
          WHEN '4' THEN 'Semestral' --UG
          WHEN '5' THEN 'Semestral' --WA
          WHEN '7' THEN 'Cuatrimestral' --Inglés
          WHEN '8' THEN 'cada 18 meses' --Maestrías
          WHEN '9' THEN 'cada 9 meses' --Diplomados
      ELSE NULL END AS codigo_tipo_periodo_academico, YEAR_ADMITTED AS anio_ingreso
    , CASE
          WHEN ACADEMIC_PERIOD_ADMITTED < 201800 AND SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2) IN ('10','30') THEN 1 
          WHEN ACADEMIC_PERIOD_ADMITTED < 201800 AND SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2) IN ('20','40','50','60') THEN 2 
          WHEN ACADEMIC_PERIOD_ADMITTED > 201800 AND SUBSTR(ACADEMIC_PERIOD_ADMITTED,4,1) IN ('4','5','7') 
              AND TO_NUMBER(SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2)) > 11 AND TO_NUMBER(SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2)) < 16 THEN 1 
          WHEN ACADEMIC_PERIOD_ADMITTED > 201800 AND SUBSTR(ACADEMIC_PERIOD_ADMITTED,4,1) IN ('4','5','7') 
              AND TO_NUMBER(SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2)) > 32 AND TO_NUMBER(SUBSTR(ACADEMIC_PERIOD_ADMITTED,5,2)) < 37 THEN 2 
          WHEN ACADEMIC_PERIOD_ADMITTED > 201800 AND SUBSTR(ACADEMIC_PERIOD_ADMITTED,4,1) IN ('8','9') THEN 1 
      ELSE 0 END AS num_periodo_ingreso
FROM ACADEMIC_STUDY
WHERE STUDENT_LEVEL = 'UG' AND ACADEMIC_PERIOD IN ('218413','218512') AND CAMPUS IN ('TML','TSI');


--Asignación_Docente
--id_docente, nombre_docente, id_grupo, id_curso, id_actividad, docente_principal
SELECT DISTINCT
    a.INSTRUCTOR_ID AS id_docente, a.INSTRUCTOR_FIRST_NAME || ' ' || REPLACE(a.INSTRUCTOR_LAST_NAME,'/',' ') AS nombre_docente
    , a.ACADEMIC_PERIOD || '.' || a.COURSE_REFERENCE_NUMBER AS id_grupo, b.SUBJECT || b.COURSE_NUMBER AS id_curso, b.SCHEDULE AS id_actividad
    , CASE WHEN a.PRIMARY_IND = 'Y' THEN 1 ELSE 0 END AS docente_principal
FROM INSTRUCTIONAL_ASSIGNMENT a, MEETING_TIME b
WHERE a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD AND a.COURSE_REFERENCE_NUMBER = b.COURSE_REFERENCE_NUMBER AND a.CATEGORY = b.CATEGORY
    AND a.ACADEMIC_PERIOD IN ('218413','218512') AND b.COURSE_CAMPUS IN ('TML','TSI');
