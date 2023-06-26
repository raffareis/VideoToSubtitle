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
set "ffmpeg_path=ffmpeg"
set "video_to_subtitle_path=%~dp0VideoToSubtitle.exe"

:: Verificar se o .NET 7 está instalado
reg query "HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost" /v Version | findstr /R "7\..*" >nul 2>&1
if errorlevel 1 (
    echo .NET 7 nao encontrado. Baixando e instalando...
    powershell -Command "Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/c4453ece-c90b-496a-b36b-600cec7d47d2/0f53119fe68f0ceef45e598b65c176f9/dotnet-sdk-7.0.305-win-x64.exe' -OutFile '%TEMP%\dotnet-sdk-7.0.305-win-x64.exe'"
    %TEMP%\dotnet-sdk-7.0.305-win-x64.exe /install /quiet /norestart
) else (
    echo .NET 7 ja esta instalado.
)

:: Verificar se o ffmpeg está na variável PATH
where %ffmpeg_path% >nul 2>&1
if errorlevel 1 (
    echo Adicionando caminho do ffmpeg...
    setx path "%path%;%~dp0%ffmpeg_path%"
) else (
    echo Caminho do ffmpeg ja existe.
)

:: Dar permissão permanente para executar VideoToSubtitle.exe (sem smartscreen)
powershell -Command "Unblock-File -Path '%video_to_subtitle_path%'"

:: Pedir a chave da API Whisper e armazená-la em uma variável de ambiente
set /p whisper_api_key="Digite sua chave da API Whisper: "
setx WHISPER_API_KEY "%whisper_api_key%"

:: Adicionar itens de menu de contexto para arquivos de áudio e vídeo
for %%e in (mp3 mpga m4a wav) do (
    reg add "HKCR\SystemFileAssociations\.%%e\shell\Transcrever\command" /ve /d "\"%video_to_subtitle_path%\" \"%%1\"" /f
    reg add "HKCR\SystemFileAssociations\.%%e\shell\Transcrever em EN\command" /ve /d "\"%video_to_subtitle_path%\" \"%%1\" --translate" /f
)
for %%e in (mp4 mpeg webm) do (
    reg add "HKCR\SystemFileAssociations\.%%e\shell\Legendar\command" /ve /d "\"%video_to_subtitle_path%\" \"%%1\"" /f
    reg add "HKCR\SystemFileAssociations\.%%e\shell\Legendar em EN\command" /ve /d "\"%video_to_subtitle_path%\" \"%%1\" --translate" /f
)

echo Concluido.
pause