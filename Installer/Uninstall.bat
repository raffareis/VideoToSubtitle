@echo off
:: Verificar privilégios de administrador
net session >nul 2>&1
if %errorlevel% == 0 (
    goto :runScript
) else (
    goto :getAdmin
)

:getAdmin
echo Solicitando privilegios de administrador...
powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
exit /b

:runScript
set "ffmpeg_path=%~dp0ffmpeg"
set "video_to_subtitle_path=%~dp0VideoToSubtitle.exe"

:: Remover itens de menu de contexto para arquivos de áudio e vídeo
for %%e in (mp3 mpga m4a wav) do (
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Transcrever\command" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Transcrever em EN\command" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Transcrever" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Transcrever em EN" /f
)
for %%e in (mp4 mpeg webm) do (
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Legendar\command" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Legendar em EN\command" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Legendar" /f
    reg delete "HKCR\SystemFileAssociations\.%%e\shell\Legendar em EN" /f
)

:: Verificar se o caminho atual do ffmpeg está na variável PATH
echo %path% | findstr /C:"%ffmpeg_path%">nul 2>&1
if not errorlevel 1 (
    echo Removendo caminho do ffmpeg...
    set "new_path=%path:;%ffmpeg_path%=%"
    setx path "%new_path%"
) else (
    echo Caminho do ffmpeg nao encontrado no diretorio atual.
)

:: Remover variável de ambiente WHISPER_API_KEY
reg delete "HKCU\Environment" /v WHISPER_API_KEY /f

echo Concluido.
pause