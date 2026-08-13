@echo off
rem 
rem Run AnyLogic Experiment
rem 
setlocal enabledelayedexpansion
chcp 1252 >nul
set DIR_BACKUP_XJAL=%cd%
cd /D "%~dp0"

rem ----------------------------------

rem echo 1.Check JAVA_HOME

if exist "%JAVA_HOME%\bin\java.exe" (
	set "PATH=%JAVA_HOME%\bin;%PATH%"
	goto javafound
)

rem echo 2.Check PATH

for /f %%j in ("java.exe") do (
	set JAVA_EXE=%%~$PATH:j
)

if defined JAVA_EXE (
	goto javafound
)

rem echo 3.Check AnyLogic registry

set KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\AnyLogic North America

FOR /F "usebackq delims=" %%A IN (`REG QUERY "%KEY_NAME%" 2^>nul`) DO (
	set ANYLOGIC_KEY=%%A
)

if defined ANYLOGIC_KEY (
	FOR /F "usebackq delims=" %%A IN (`REG QUERY "%ANYLOGIC_KEY%" 2^>nul`) DO (
		set ANYLOGIC_VERSION_KEY=%%A
	)
)

if defined ANYLOGIC_VERSION_KEY (
	FOR /F "usebackq skip=2 tokens=3*" %%A IN (`REG QUERY "%ANYLOGIC_VERSION_KEY%" /v Location 2^>nul`) DO (
		set ANYLOGIC_LOCATION=%%A %%B
	)
)

if exist "%ANYLOGIC_LOCATION%\jre\bin\java.exe" (
	set PATH=!ANYLOGIC_LOCATION!\jre\bin;!PATH!
	goto javafound
)

rem echo 4.Check java registry

set KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY "%KEY_NAME%" /v CurrentVersion 2^>nul`) DO (
    set JAVA_CURRENT_VERSION=%%A
)

if defined JAVA_CURRENT_VERSION (
	FOR /F "usebackq skip=2 tokens=3*" %%A IN (`REG QUERY "%KEY_NAME%\%JAVA_CURRENT_VERSION%" /v JavaHome 2^>nul`) DO (
		set JAVA_PATH=%%A %%B
	)
)

if exist "%JAVA_PATH%\bin\java.exe" (
	set PATH=!JAVA_PATH!\bin;!PATH!
	goto javafound
)

rem 32 bit
set KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\JavaSoft\Java Runtime Environment
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY "%KEY_NAME%" /v CurrentVersion 2^>nul`) DO (
    set JAVA_CURRENT_VERSION=%%A
)

if defined JAVA_CURRENT_VERSION (
	FOR /F "usebackq skip=2 tokens=3*" %%A IN (`REG QUERY "%KEY_NAME%\%JAVA_CURRENT_VERSION%" /v JavaHome 2^>nul`) DO (
		set JAVA_PATH=%%A %%B
	)
)

if exist "%JAVA_PATH%\bin\java.exe" (
	set PATH=!JAVA_PATH!\bin;!PATH!
	goto javafound
)

rem echo 5.Check Program Files
for /f "delims=" %%a in ('dir "%ProgramFiles%\Java\j*" /o-d /ad /b') do (
	set JAVA_PROGRAM_FILES="%ProgramFiles%\Java\%%a"
	if exist "%ProgramFiles%\Java\%%a\bin\java.exe" goto exitloop
)
for /f "delims=" %%a in ('dir "%ProgramFiles(x86)%\Java\j*" /o-d /ad /b') do (
	set JAVA_PROGRAM_FILES="%ProgramFiles(x86)%\Java\%%a"
	if exist "%ProgramFiles(x86)%\Java\%%a\bin\java.exe" goto exitloop
)

:exitloop

if defined JAVA_PROGRAM_FILES (
	set PATH=!JAVA_PROGRAM_FILES!\bin;!PATH!
	goto javafound
)

echo  Error: Java not found
pause
goto end

:javafound

FOR /F "usebackq tokens=4" %%A IN (`java -fullversion 2^>^&1`) DO (
	set VERSION=%%~A
)


set AL_OMNIVERSE_CONNECTOR_PATH=%~dp0\omniverse-connector\AnyLogicOmniverseConnector.exe

echo Java version: %VERSION%

rem ---------------------------

echo on

java %OPTIONS_XJAL% -cp model.jar;lib/MarkupDescriptors.jar;lib/ProcessModelingLibrary.jar;lib/com.anylogic.engine.jar;lib/com.anylogic.engine.database.jar;lib/com.anylogic.engine.datautil.jar;lib/com.anylogic.engine.editorapi.jar;lib/com.anylogic.engine.gis.jar;lib/com.anylogic.engine.sa.jar;lib/sa/com.anylogic.engine.sa.web.jar;lib/al-spark-core-2.9.4-with-jetty-9.4.57.jar;lib/jackson-annotations-2.16.2.jar;lib/jackson-core-2.16.2.jar;lib/jackson-databind-2.16.2.jar;lib/javax.servlet-api-3.1.0.jar;lib/jetty-client-9.4.57.v20241219.jar;lib/jetty-continuation-9.4.57.v20241219.jar;lib/jetty-http-9.4.57.v20241219.jar;lib/jetty-io-9.4.57.v20241219.jar;lib/jetty-security-9.4.57.v20241219.jar;lib/jetty-server-9.4.57.v20241219.jar;lib/jetty-servlet-9.4.57.v20241219.jar;lib/jetty-servlets-9.4.57.v20241219.jar;lib/jetty-util-9.4.57.v20241219.jar;lib/jetty-util-ajax-9.4.57.v20241219.jar;lib/jetty-webapp-9.4.57.v20241219.jar;lib/jetty-xml-9.4.57.v20241219.jar;lib/sa/executor-basic-8.3.jar;lib/sa/ioutil-8.3.jar;lib/sa/util-8.3.jar;lib/slf4j-api-1.7.25.jar;lib/websocket-api-9.4.57.v20241219.jar;lib/websocket-client-9.4.57.v20241219.jar;lib/websocket-common-9.4.57.v20241219.jar;lib/websocket-server-9.4.57.v20241219.jar;lib/websocket-servlet-9.4.57.v20241219.jar;lib/querydsl-core-5.1.0.jar;lib/querydsl-sql-5.1.0.jar;lib/querydsl-sql-codegen-5.1.0.jar;lib/commons-codec-1.16.0.jar;lib/commons-collections4-4.4.jar;lib/commons-compress-1.27.1.jar;lib/commons-io-2.18.0.jar;lib/commons-lang3-3.20.0.jar;lib/commons-math3-3.6.1.jar;lib/commons-pool-1.5.4.jar;lib/commons-text-1.12.0.jar;lib/log4j-api-2.26.0.jar;lib/log4j-core-2.26.0.jar;lib/poi-5.4.1.jar;lib/poi-examples-5.4.1.jar;lib/poi-excelant-5.4.1.jar;lib/poi-ooxml-5.4.1.jar;lib/poi-ooxml-lite-5.4.1.jar;lib/poi-scratchpad-5.4.1.jar;lib/xmlbeans-5.3.0.jar;lib/joml-1.10.6.jar;lib/ac2shp-202009171739.jar;lib/al-ecj-4.27.jar;lib/al-profiler-converter-3.0-ea-53b8a8ad.jar;lib/al-sqlsheet-7.2-2c2d836_poi_5.4.1.jar;lib/al-ucanaccess-5.0.1.jar;lib/annotations-13.0.jar;lib/apiguardian-api-1.1.2.jar;lib/bcprov-jdk18on-1.83.jar;lib/classgraph-4.8.146.jar;lib/codegen-utils-5.1.0.jar;lib/crypt-codec-opener-1.0.1.jar;lib/curvesapi-1.08.jar;lib/ejml-core-0.33.jar;lib/ejml-ddense-0.33.jar;lib/GeographicLib-Java-1.49.jar;lib/glob-0.9.0.jar;lib/graphhopper-al-0.10.1-without-commons-io-jackson-annotations.jar;lib/gt-api-32.2.jar;lib/gt-epsg-hsql-32.2.jar;lib/gt-http-32.2.jar;lib/gt-main-32.2.jar;lib/gt-metadata-32.2.jar;lib/gt-referencing-32.2.jar;lib/gt-shapefile-32.2.jar;lib/hsqldb-2.7.1.jar;lib/indriya-2.2.jar;lib/jackcess-4.0.2.jar;lib/jackcess-encrypt-4.0.2.jar;lib/jackson-annotations-2.16.2.jar;lib/jackson-core-2.16.2.jar;lib/jackson-databind-2.16.2.jar;lib/jai_core-1.1.3.jar;lib/jakarta.activation-1.2.2.jar;lib/jakarta.annotation-api-1.3.4.jar;lib/jakarta.inject-api-2.0.1.jar;lib/jakarta.xml.bind-api-2.3.3.jar;lib/javax.annotation-api-1.3.2.jar;lib/javax.inject-1.jar;lib/jaxb-api-2.3.0.jar;lib/jaxb-impl-2.3.8.jar;lib/jcl-over-slf4j-1.7.25.jar;lib/jgltf-impl-v1-2.0.4.jar;lib/jgltf-impl-v2-2.0.4.jar;lib/jgltf-model-2.0.4.jar;lib/jgridshift-core-1.3.jar;lib/json-simple-1.1.1.jar;lib/jsqlparser-4.6.jar;lib/jsr-275-1.0-beta-2.jar;lib/jtds-1.3.1.jar;lib/jts-core-1.20.0.jar;lib/jul-to-slf4j-1.7.25.jar;lib/kotlin-stdlib-1.8.20.jar;lib/kotlin-stdlib-common-1.8.20.jar;lib/kotlin-stdlib-jdk7-1.8.20.jar;lib/kotlin-stdlib-jdk8-1.8.20.jar;lib/log4j-over-slf4j-1.7.25.jar;lib/mapdb-1.0.9-al-6088d6f1.jar;lib/mariadb-java-client-3.2.0.jar;lib/mssql-jdbc-13.2.1.jre11.jar;lib/mysema-commons-lang-0.2.4.jar;lib/net.opengis.ows-32.2.jar;lib/obj-0.4.0.jar;lib/ojdbc11-23.2.0.0.jar;lib/openmap-5.1.15.jar;lib/org.eclipse.emf.common-2.15.0.jar;lib/org.eclipse.emf.ecore-2.15.0.jar;lib/org.eclipse.emf.ecore.xmi-2.15.0.jar;lib/org.w3.xlink-32.2.jar;lib/postgresql-42.6.0.jar;lib/querydsl-codegen-5.1.0.jar;lib/re2j-1.6.jar;lib/si-quantity-2.1.jar;lib/si-units-2.1.jar;lib/slf4j-api-1.7.25.jar;lib/SparseBitSet-1.3.jar;lib/systems-common-2.1.jar;lib/unit-api-2.2.jar;lib/uom-lib-common-2.2.jar -Xmx4096m ny_state_v5.Simulation %*

if defined XJAL_UseOmniversePresentation (
	exit 0
)
@echo off
if %ERRORLEVEL% neq 0 pause
:end
echo on
@cd /D "%DIR_BACKUP_XJAL%"
