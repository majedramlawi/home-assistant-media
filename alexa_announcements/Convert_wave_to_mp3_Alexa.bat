
@echo off
setlocal EnableExtensions DisableDelayedExpansion

title Alexa-Compatible Audio Converter

echo ==========================================
echo    Alexa-Compatible Audio Converter
echo    WAV and MP3 to Alexa-Compatible MP3
echo ==========================================
echo.

rem Change to the folder containing this batch file
cd /d "%~dp0"

rem Check whether FFmpeg is available
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo ERROR: FFmpeg was not found.
    echo Install FFmpeg or add it to your Windows PATH.
    echo.
    pause
    exit /b 1
)

set "FOUND=0"
set "CONVERTED=0"
set "FAILED=0"
set "DELETED=0"

rem Process WAV files
for %%F in (*.wav) do (
    if exist "%%~fF" call :ConvertFile "%%~fF" WAV
)

rem Process MP3 files
for %%F in (*.mp3) do (
    if exist "%%~fF" call :ConvertFile "%%~fF" MP3
)

echo.
echo ==========================================
if "%FOUND%"=="0" (
    echo No WAV or MP3 files found in:
    echo %CD%
) else (
    echo Conversion finished.
    echo Converted: %CONVERTED%
    echo Failed: %FAILED%
    echo WAV files deleted: %DELETED%
)
echo ==========================================

echo.
pause
exit /b 0


:ConvertFile

set "FOUND=1"
set "INPUT=%~1"
set "FILE_TYPE=%~2"
set "FILENAME=%~n1"
set "OUTPUT_FOLDER=%~dpn1"
set "OUTPUT_FILE=%~dpn1\%~n1.mp3"

echo.
echo ==========================================
echo Processing: %~nx1
echo Type: %FILE_TYPE%
echo Output folder: %FILENAME%
echo ==========================================

rem Create a folder using the original filename
if not exist "%OUTPUT_FOLDER%\" mkdir "%OUTPUT_FOLDER%"

if not exist "%OUTPUT_FOLDER%\" (
    echo ERROR: Could not create output folder.
    set /a FAILED+=1
    exit /b 0
)

rem Convert audio to Alexa-compatible MP3
ffmpeg -hide_banner -y -i "%INPUT%" -vn -ac 2 -codec:a libmp3lame -b:a 48k -ar 24000 "%OUTPUT_FILE%"

if errorlevel 1 (
    echo ERROR: Conversion failed for %~nx1
    set /a FAILED+=1
    exit /b 0
)

echo SUCCESS: %FILENAME%\%FILENAME%.mp3
set /a CONVERTED+=1

rem Delete original WAV only after successful conversion
if /I "%FILE_TYPE%"=="WAV" (
    del "%INPUT%"
    if not exist "%INPUT%" (
        echo Original WAV deleted.
        set /a DELETED+=1
    ) else (
        echo WARNING: Could not delete original WAV.
    )
)

exit /b 0
