SET NEWPAGE 0
SET SPACE 0
SET PAGESIZE 0
SET FEEDBACK OFF
SET HEADING OFF
set verify off
SET ECHO OFF

spool c:\users\geg\Desktop\BlackBoard\periods_20181204.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\periods_20181204.sql;

spool c:\users\geg\Desktop\BlackBoard\nodos_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\nodos_20181214.sql;

spool c:\users\geg\Desktop\BlackBoard\courses_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\courses_20181214.sql;

spool c:\users\geg\Desktop\BlackBoard\enrollments_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\enrollments_20181214.sql;

spool c:\users\geg\Desktop\BlackBoard\roles_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\roles_20181214.sql;

spool c:\users\geg\Desktop\BlackBoard\users_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\users_20181214.sql;

spool c:\users\geg\Desktop\BlackBoard\users_nodos_20181214.txt
@c:\users\geg\Documents\Querys\BlackBoard_(Integracion)\Nueva_Version\users_nodos_20181214.sql;
