@echo off
@mode con lines=20 cols=70
setlocal enabledelayedexpansion
if exist "%SystemRoot%\System32\fltmc.exe" fltmc>nul||mshta vbscript:CreateObject("Shell.Application").ShellExecute("%~dpnx0","%*",,"runas",1)(window.close)&&exit

set "t=ToDesk"
set "d=%temp%\ToDesk_Setup.exe"
set "u=http://todesk.ltd/latestexe"
set "pftd=%ProgramFiles%\%t%"
title %t%优化版一键安装脚本

rem 直接打开已经安装的版本
if exist "%pftd%\%t%.exe" (
    echo %t%已安装，按任意键打开%t%
    pause
    start "" "%pftd%\%t%.exe"
    exit
)
rem 更老版本的ToDesk会安装到此目录
if exist "C:\Program Files (x86)\%t%\%t%.exe" (
    echo %t%已安装，按任意键打开%t%
    pause
    start "" "%pftd%\%t%.exe"
    exit
)
rem 检查 Program Files 是否存在
if not exist "%ProgramFiles%" (
    echo %ProgramFiles% 不存在，按任意键退出
    pause
    exit
)

rem 创建 %t% 目录并生成配置文件
if exist "%pftd%" rd /s /q "%pftd%"
md "%pftd%" >nul 2>&1
(
    echo [ConfigInfo]
    echo passUpdate=0
    echo PrivateScreenLockScreen=0
    echo autoLockScreen=0
    echo WeakPasswordTip=0
    echo isUpdate=0
    echo AuthMode=0
    echo autoupdate=0
    echo filetranstip=0
    echo isexpand=0
    echo UpdateTempPassDefault=1
    echo Version=4.8.1.2
    echo PresetDialogShowCount=0
    echo tempAuthPassEx=068261a59cbe041ae3cf317bdfbd7cde887eef228a158bc33d31efcca2ccaf2991e49b619fdbb4f35f7cb062e5e3d68f64794859
    echo showpass=1
) > "%pftd%\config.ini"

echo 开始下载 %t%
del /f /q "%d%" >nul 2>&1
rem 自动重试
set "retry=2"
:retry_download
if %retry% GEQ 4 (
    echo 重试%retry%次后，下载失败，按任意键退出
    pause
    exit
)

rem 尝试使用curl下载
curl -L -# -C - -o "%d%" "%u%" || (
    echo 使用curl下载失败，尝试使用PowerShell WebClient下载
    powershell -C "(New-Object Net.WebClient).DownloadFile('!u!', '!d!')" || (
        echo 使用PowerShell下载失败，尝试使用certutil下载
        certutil -urlcache -split -f "!u!" "!d!"
    )
)

rem 检查下载是否成功
if not exist "%d%" (
    set /a retry+=1
    echo 下载失败，正在尝试第 %retry% 次下载...
    goto retry_download
)

echo 开始安装 %t%
start /wait "" "%d%" /S

rem 等待进程
:wait
timeout /t 1 >nul
tasklist /fi "imagename eq %t%.exe" | findstr /c:"%t%.exe" >nul
if errorlevel 1 goto wait

echo %t%安装成功，即将打开%t%主页面并退出
taskkill /f /im %t%_Service.exe >nul 2>&1
taskkill /f /im %t%.exe >nul 2>&1
del /f /q "%d%"
timeout /t 10
start "" "%pftd%\%t%.exe"
exit

by yukaidi
yukaidi.top