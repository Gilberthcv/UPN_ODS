
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
SELECT '' AS "id_campus"
    , '' AS "id_periodo_academico"
    , '' AS "id_jornada"
    , NULL AS "id_categoria"
    , '' AS "id_seccion"
    , NULL AS "codigo_grupo"
    , NULL AS "id_actividad"
    , NULL AS "nombre_actividad"
    , '' AS "nro_dia"
    , '' AS "hora_inicio"
    , '' AS "hora_termino"
    , NULL AS "nro_modulo"
    , '' AS "id_salon"
    , '' AS "fecha_inicio"
    , '' AS "fecha_termino"
FROM

--Estudiante_Seccion_yyyymmdd.csv
SELECT '' AS "id_periodo_academico"
    , '' AS "id_seccion"
    , NULL AS "codigo_grupo"
    , '' AS "id_estudiante"
    , NULL AS "id_plan_estudio"
    , NULL AS "indicador_sancionado"
FROM

--Docente_Seccion_yyyymmdd.csv
SELECT '' AS "id_periodo"
    , '' AS "id_seccion"
    , '' AS "id_docente"
    , '' AS "id_categoria"
    , '' AS "ind_principal"
FROM

