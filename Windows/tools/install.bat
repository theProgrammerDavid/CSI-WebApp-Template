@echo off

set CHECK_UPDATE=''

IF exist %temp%\.CSI-WebApp-Template (CALL :fn_dir_exists) ELSE (CALL :fn_dir_not_exist)


EXIT /B %ERRORLEVEL%


:fn_dir_exists
set CHECK_UPDATE='yes'
echo CSI-WebApp-Template is already installed.
set /p CHECK_UPDATE="Do you want to check for updates? (y/n) :"
IF "%CHECK_UPDATE%"=="y" (CALL :fn_check_updates)

EXIT /B 0

:fn_dir_not_exist
echo downloading stuff..
git clone https://github.com/csivitu/CSI-WebApp-Template.git --branch feat/windows --single-branch %temp%\.CSI-WebApp-Template

EXIT /B 0

:fn_check_updates
echo checking for updates..
EXIT /B 0

:fn_download_src

EXIT /B 0

