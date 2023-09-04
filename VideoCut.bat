@echo off
set k=
set start=
set end=

:getfile
set dialog="about:<input type=file id=FILE><script language=vbscript>FILE.Click:
set dialog=%dialog%CreateObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(FILE.value):
set dialog=%dialog%Close:resizeTo 0,0</script>"

:: ファイル選択ダイアログを呼び出す
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do (
    set "f=%%p"
    set "f_n=%%~np"
    set "f_e=%%~xp"
)
echo 選択されたファイル: "%f%"

:input
echo 1:30秒間を切り抜く  2:指定した時間切り抜く
set /p k= 
if "%k%"=="1" (
    goto :exe1
) else if "%k%"=="2" (
    goto :exe2
) else (
    echo 正しい数字を入力してください
    goto :input
)


:exe1
echo 開始時間(秒)を入力してください
set /p start= 
ffmpeg -ss %start% -t 30 -i "%f%" -c copy "%f_n%_cut%f_e%"
exit

:exe2
echo 開始時間(秒)を入力してください
set /p start= 
echo 終了時間(秒)を入力してください
set /p end= 
ffmpeg -ss %start% -to %end% -i "%f%" -c copy "%f_n%_cut%f_e%"
exit
