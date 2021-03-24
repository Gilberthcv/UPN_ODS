--DescripcionEstadosInscripciones_yyyymmdd.csv
SELECT 'A' AS "id_estado_inscripcion"
	, 'A' AS "codigo_estado_inscripcion"
	, 'Aprobado' AS "nombre_estado_inscripcion"
	, 'El estudiante aprob� el curso.' AS "descripcion_estado_inscripcion"
	, 1 AS "indicador_aprobado"
	, 0 AS "indicador_pendiente"
	, 1 AS "numero_prioridad"
FROM DUAL
UNION SELECT 'C', 'C', 'Cursando', 'El estudiante est� actualmente dictando el curso.', 0, 1, 1 FROM DUAL
UNION SELECT 'D', 'D', 'Desaprobado', 'El estudiante ha desaprob� el curso y debe volver a dictarlo.', 0, 1, 1 FROM DUAL
UNION SELECT 'R', 'R', 'Retirado', 'El estudiante se retir� del curso.', 0, 1, 2 FROM DUAL
;