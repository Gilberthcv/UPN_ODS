
/*
FILTROS
PERIODO:  219435
FECHA DE LLENADO DEL NRC:  20/08/2019
TIPO HORARIO:    VIR
MET. EDUCATIVO:  V
PERIODO    C�DIGO DE CURSO           NRC          TIPO HOR    MET. EDUC.    USUARIO CREADOR     FECHA CREACI�N     HORA CREACI�N   FECHA DE LLENADO DEL NRC    HORA DE LLENADO
El reto es saber si podemos obtener los siguientes datos:
FECHA Y HORA DE CREACI�N DEL NRC, este dato debe estar en el log.
FECHA Y HORA DEL LLENADO DEL NRC, la forma de obtener este dato es haciendo un barrido entre los estudiantes que se matricularon en el NRC 
y seleccionar al que se inscribi� al final (con estado de inscripci�n. RW, RE, RA) es decir al que tiene la �ltima fecha y hora de inscripci�n. 
Tenemos la forma  SFASTCA, Auditor�a de Inscripci�n de cursos en donde aparecen estos datos.
*/

SELECT DISTINCT 
    SSBSECT_TERM_CODE AS PERIODO, SSBSECT_SUBJ_CODE||SSBSECT_CRSE_NUMB AS CODIGO_CURSO, SSBSECT_CRN AS NRC, SSBSECT_SCHD_CODE AS TIP0_HOR, SSBSECT_INSM_CODE AS MET_EDUC
    , SSRMEET_USER_ID AS USUARIO_ACTIVIDAD, TO_CHAR(SSRMEET_ACTIVITY_DATE,'DD/MM/YYYY') AS FECHA_ACTIVIDAD, TO_CHAR(SSRMEET_ACTIVITY_DATE,'HH24:MI:SS') AS HORA_ACTIVIDAD
    , SSBSECT_MAX_ENRL AS CAPACIDAD, SSBSECT_ENRL AS INSCRITOS, TO_CHAR(SSRATTR_ACTIVITY_DATE,'DD/MM/YYYY') AS FECHA, TO_CHAR(SSRATTR_ACTIVITY_DATE,'HH24:MI:SS') AS HORA
    , CASE WHEN SSBSECT_MAX_ENRL > SSBSECT_ENRL THEN NULL ELSE TO_CHAR(MAX(SFRSTCR_RSTS_DATE) OVER(PARTITION BY SFRSTCR_TERM_CODE,SFRSTCR_CRN),'DD/MM/YYYY') END AS FECHA_LLENADO
    , CASE WHEN SSBSECT_MAX_ENRL > SSBSECT_ENRL THEN NULL ELSE TO_CHAR(MAX(SFRSTCR_RSTS_DATE) OVER(PARTITION BY SFRSTCR_TERM_CODE,SFRSTCR_CRN),'HH24:MI:SS') END AS HORA_LLENADO
FROM SSBSECT, SSRMEET, SSRATTR, SFRSTCR
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
    AND SSBSECT_TERM_CODE = SFRSTCR_TERM_CODE(+) AND SSBSECT_CRN = SFRSTCR_CRN(+)
    AND SSBSECT_TERM_CODE = '219435' AND SSBSECT_SCHD_CODE = 'VIR' AND SSBSECT_INSM_CODE = 'V'
    AND SFRSTCR_RSTS_CODE(+) IN ('RW','RE','RA')
ORDER BY 3;

SELECT DISTINCT
    SSBSECT_TERM_CODE AS PERIODO, SSBSECT_SUBJ_CODE||SSBSECT_CRSE_NUMB AS CODIGO_CURSO, SSBSECT_CRN AS NRC, SSBSECT_SCHD_CODE AS TIP0_HOR
    , SSBSECT_INSM_CODE AS MET_EDUC, SSBSECT_KEYWORD_INDEX_ID AS USUARIO_NRC, a.SPRIDEN_LAST_NAME ||' '|| a.SPRIDEN_FIRST_NAME AS NOMB_USUARIO_NRC
    , SSBSECT_CAMP_CODE AS CAMPUS, SSRMEET_USER_ID AS USUARIO_HORARIO, b.SPRIDEN_LAST_NAME ||' '|| b.SPRIDEN_FIRST_NAME AS NOMB_USUARIO_HORARIO
    , TO_CHAR(SSRMEET_ACTIVITY_DATE,'DD/MM/YYYY') AS FECHA_ACTIVIDAD, TO_CHAR(SSRMEET_ACTIVITY_DATE,'HH24:MI:SS') AS HORA_ACTIVIDAD
    , SSBSECT_MAX_ENRL AS CAPACIDAD, SSBSECT_ENRL AS INSCRITOS
FROM SSBSECT, SSRMEET, SPRIDEN a, SPRIDEN b
WHERE SSBSECT_TERM_CODE = SSRMEET_TERM_CODE AND SSBSECT_CRN = SSRMEET_CRN
    AND SUBSTR(SSBSECT_KEYWORD_INDEX_ID,2) = a.SPRIDEN_ID(+)
    AND SUBSTR(SSRMEET_USER_ID,2) = b.SPRIDEN_ID(+)
    AND SSBSECT_TERM_CODE = '219435' AND SSBSECT_CAMP_CODE = 'LN0';

SELECT * FROM  SSBSECT
WHERE SSBSECT_TERM_CODE = '219435'

SELECT * FROM SSRMEET
WHERE SSRMEET_TERM_CODE = '219435'

SELECT * FROM SSRATTR
WHERE SSRATTR_TERM_CODE = '219435'
