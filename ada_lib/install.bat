set LIB=static
set ARCHITECTURE=windows
set GCC_ARCHITECTURE=windows
set TARGET=debug
set PROJECT=ada_lib_aunit_lib
set USER=wayne
set GPR_DIRECTORY="..\gpr"
SET HOUR=%time:~0,2%
SET BUILD_DATE=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
echo BUILD_DATE %BUILD_DATE%
echo PROJECT=%PROJECT%
echo GPR_DIRECTORY=%GPR_DIRECTORY%
t:\GNAT\2019\bin\gprinstall --uninstall -P %PROJECT% -aP. -aP..  -aP%GPR_DIRECTORY% -f -p -v
t:\GNAT\2019\bin\gprinstall -P %PROJECT% -aP. -aP..  -aP%GPR_DIRECTORY% -f -p -v
