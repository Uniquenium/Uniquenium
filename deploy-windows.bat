@echo off
chcp 65001 >nul
echo ================================================
echo          Uniquenium Deploy Script
echo ================================================

:: 配置参数
set "PROJECT_DIR=%~dp0"
set "BUILD_DIR=%PROJECT_DIR%build"
set "DEPLOY_DIR=%BUILD_DIR%\deploy"
set "QML_DIR=%DEPLOY_DIR%\qml"
set "EXE_NAME=Uniquenium.exe"

:: 查找Uniquenium.exe（在build目录下搜索）
set "EXE_PATH="
for /r "%BUILD_DIR%/Qt_MSVC2022_64bit-Release" %%f in (%EXE_NAME%) do (
    if not "%%f"=="%DEPLOY_DIR%\%EXE_NAME%" (
        set "EXE_PATH=%%f"
        goto :found_exe
    )
)
:found_exe

if not defined EXE_PATH (
    echo ERROR: %EXE_NAME% not found in build directory!
    pause
    exit /b 1
)

echo Found: %EXE_PATH%
echo.

:: 1. 清空deploy文件夹
echo [1/5] Clearing deploy directory...
if exist "%DEPLOY_DIR%" (
    rmdir /s /q "%DEPLOY_DIR%"
)
mkdir "%DEPLOY_DIR%"
echo Done.

:: 2. 复制Uniquenium.exe到deploy
echo [2/5] Copying %EXE_NAME% to deploy...
copy "%EXE_PATH%" "%DEPLOY_DIR%\"
echo Done.

:: 3. 使用windeployqt
echo [3/5] Running windeployqt...
cd "%DEPLOY_DIR%"
windeployqt "%EXE_NAME%" --qmldir ../..
echo Done.

:: 4. 创建qml目录并复制UniDesk
echo [4/5] Copying UniDesk to qml directory...
xcopy /e /i "%BUILD_DIR%/Qt_MSVC2022_64bit-Release/temp/UniDesk" "%QML_DIR%/UniDesk"
echo Done.



echo.
echo ================================================
echo          Deployment Complete!
echo ================================================
echo Deploy directory: %DEPLOY_DIR%
