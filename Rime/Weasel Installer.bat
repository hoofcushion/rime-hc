@echo off
if "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) else (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' neq '0' (
  echo Requesting administrative privileges （请求管理员权限）...
  goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
  echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
  set params= %*
  echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
  "%temp%\getadmin.vbs"
  del "%temp%\getadmin.vbs"
  exit /B
:gotAdmin
  pushd "%CD%"
  cd /d "%~dp0"
:check_dir
echo 正在查找本目录是否包含weasel文件夹
set WEASEL=%~dp0weasel
if exist "%~dp0weasel" (goto main_menu)
echo 正在检查本目录是否为weasel文件夹
set WEASEL=%~dp0
set WEASEL=%WEASEL:~0,-1%
if "%WEASEL:~-6%"=="weasel" (goto main_menu) else (
  echo 未找到安装目录，将在3秒后重试
  timeout /t 3 /nobreak >nul
  goto check_dir
)
:main_menu
cls
echo 成功找到安装目录！
echo Weasel目录为%WEASEL%
echo ===================
echo 请选择一个主模式：
echo 【1】安装模式（首次使用）
echo 【2】卸载模式
echo ===================
:main_menu_retry
set /p main_choice=
if "%main_choice%"=="1" (
  goto :install_mode
) else if "%main_choice%"=="2" (
  goto :uninstall_mode
) else (
  echo 无效的选择，请重新选择.
  pause >nul
  goto main_menu_retry
)
:install_mode
cls
echo 您已选择安装模式。
echo ===================
echo 请选择一个次模式：
echo 【1】危险安装（删除Weasel用户数据）
echo 【2】安全安装（保留Weasel用户数据）
echo 【M】跳转到主目录
echo ===================
:install_mode_retry
set /p install_choice=
if "%install_choice%"=="1" (
  echo 您已选择危险安装，将会删除用户数据。
  echo 即将开始危险安装。
  timeout /t 1 /nobreak >nul
  goto :uninstall
) else if "%install_choice%"=="2" (
  echo 您已选择安全安装，将会保留用户数据。
  echo 即将开始安全安装。
  timeout /t 1 /nobreak >nul
  goto :uninstall
) else if /i "%install_choice%"=="m" (
  goto main_menu
) else (
  echo 无效的选择，请重新选择.
  pause >nul
  goto install_mode_retry
)
pause >nul
goto main_menu
:uninstall_mode
cls
echo ===================
echo 您已选择卸载模式。
echo 请选择一个次模式：
echo 【1】危险卸载（删除Weasel用户数据）
echo 【2】安全卸载（保留Weasel用户数据）
echo 【M】跳转到主目录
echo ===================
:uninstall_mode_retry
set /p uninstall_choice=
if "%uninstall_choice%"=="1" (
  echo 您已选择危险卸载，将会删除用户数据。
  echo 即将开始危险卸载。
  timeout /t 1 /nobreak >nul
  goto :uninstall
) else if "%uninstall_choice%"=="2" (
  echo 您已选择安全卸载，将会保留用户数据。
  echo 即将开始安全卸载。
  timeout /t 1 /nobreak >nul
  goto :uninstall
) else if /i "%install_choice%"=="m" (
  goto main_menu
) else (
  echo 无效的选择，请重新选择.
  pause >nul
  goto uninstall_mode_retry
)
pause >nul
goto main_menu
:uninstall
cls
echo ===================
echo 正在卸载
"%WEASEL%\WeaselServer.exe" /quit
"%WEASEL%\WeaselSetup.exe" /u
reg DELETE HKEY_CURRENT_USER\Software\Rime /f >nul 2>nul
reg DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run\ /v WeaselServer /f >nul 2>nul
del /q "%WEASEL%\user\installation.yaml" >nul 2>nul
del /q "%WEASEL%\user\user.yaml" >nul 2>nul
timeout /t 1 /nobreak >nul
if "%uninstall_choice%"=="1" (
  goto :dangerous
) else if "%install_choice%"=="1" (
  goto :dangerous
) else (
  goto :safe
)
:safe
echo 安全卸载完成！
if "%main_choice%"=="1" (
  goto :install
) else (
  goto :goback
)
:dangerous
"%WEASEL%\WeaselServer.exe" /quit
"%WEASEL%\WeaselSetup.exe" /u
reg DELETE HKEY_CURRENT_USER\Software\Rime /f >nul 2>nul
reg DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run\ /v WeaselServer /f >nul 2>nul
rmdir  /s /q  "%WEASEL%\user"
md "%WEASEL%\user"
xcopy /E "%WEASEL%\user_default\*" "%WEASEL%\user" >nul 2>nul
echo 危险卸载完成！
if "%main_choice%"=="1" (
  goto :install
) else (
  goto :goback
)
:install
echo ===================
echo 正在安装
"%WEASEL%\WeaselServer.exe" /quit
"%WEASEL%\WeaselSetup.exe" /u
reg DELETE HKEY_CURRENT_USER\Software\Rime /f >nul 2>nul
reg DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run\ /v WeaselServer /f >nul 2>nul
del /q "%WEASEL%\user\installation.yaml" >nul 2>nul
del /q "%WEASEL%\user\user.yaml" >nul 2>nul
reg ADD HKEY_CURRENT_USER\Software\Rime\Weasel /v RimeUserDir /d "%WEASEL%\user" >nul 2>nul
reg ADD HKEY_CURRENT_USER\Software\Rime\Weasel /v Hant /t REG_DWORD /d 0 >nul 2>nul
reg ADD HKEY_CURRENT_USER\Software\Rime\Weasel\Updates /v CheckForUpdates /d 0 >nul 2>nul
"%WEASEL%\WeaselSetup.exe" /i
"%WEASEL%\WeaselDeployer.exe" /install
reg ADD HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v WeaselServer /d "%WEASEL%\WeaselServer.exe" /f >nul 2>nul
start "" "%WEASEL%\WeaselServer.exe"
echo 安装完成
goto :goback
:goback
echo ===================
echo 按任意键回到主目录。
pause >nul
goto :main_menu