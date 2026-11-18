# FlatOut 2 — R36S / dArkOSen fix

[English page](index.html) · [Página em português](pt-br/index.html) · [Download BAT](downloads/fix-flatout2-r36s-darkosen.bat) · [SHA-256](downloads/SHA256SUMS.txt) · [Message to the author / Mensagem ao autor](MESSAGE-TO-AUTHOR.md)

![FlatOut 2 fix for R36S running dArkOSen](assets/fix-r36s-flatout2-8a07fe076b5b5745.png)

[Live site / Site público](https://coreilabs.github.io/flatout2-fix-r36s-darkosEN/)

## English

## Port version: v2.0.0

Fix for the user-tested installation of [FlatOut 2 ARM64 port v2.0.0](https://github.com/badcats72/flatout2-portmaster/releases#release-v2.0.0).

The tested installation uses FlatOut 2 [RK3326 - 30 FPS].sh and FlatOut 2 [H700 - FPS Unlock].sh. Both were modified and validated. The BAT checks the actual script contents, not just the release number, and refuses a different launcher layout.

## Before you start

Community launcher fix for FlatOut 2 on R36S running dArkOSen. The modified launchers worked on one user-tested device on November 18, 2026. No FPS benchmark or compatibility with other systems is claimed. The individual change responsible for the fix has not been isolated.

Original port author: [iBadCats / u/Green-Marzipan-8810](https://www.reddit.com/user/Green-Marzipan-8810/). Original port: [badcats72/flatout2-portmaster](https://github.com/badcats72/flatout2-portmaster). This independent compatibility fix is not an official upstream release. No game files or ARM64 binaries are included.

Use the two-launcher layout below. A package with only FlatOut 2.sh is not supported by this BAT; do not rename a different script to bypass the content check.

```text
ports/
  fix-flatout2-r36s-darkosen.bat
  FlatOut 2 [RK3326 - 30 FPS].sh
  FlatOut 2 [H700 - FPS Unlock].sh
  flatout2/
    fo2.aarch64
    gamedata/
```

## Automatic fix on Windows

1. Shut down the handheld and connect its game card to a Windows PC. Find the ports folder containing flatout2/fo2.aarch64.
2. Download fix-flatout2-r36s-darkosen.bat using the button above. Copy the actual BAT file into ports, beside the flatout2 folder. Do not run it inside flatout2.
3. Double-click the BAT. It uses the Windows PowerShell already installed on Windows; it needs no downloads or administrator rights. Read the result before closing the window.
4. Both recognized launchers are patched if present; one is enough. All present target files are checked before any launcher is changed. Unknown or edited files are refused. Already-fixed files are skipped.
5. Originals are backed up byte for byte under ports/flatout2/backup-r36s-fix-DATE-TIME-ID/. Patched scripts are written as UTF-8 without BOM, with Unix LF line endings. A repeated run makes no changes.
6. Safely eject the card and test FlatOut 2 [RK3326 - 30 FPS] first. The launcher name retains the original 30/60 FPS cap selection; this is not a promise of sustained FPS.

The BAT modifies only the recognized .sh launchers and creates their backup. It does not change the binary, game data or saves. When the game runs, the existing launcher still updates display/settings files as it did before; FO2_RENDER now selects 640x480.

## Apply manually

Use this method with the tested two-launcher layout and matching sections. Back up your .sh files first. Apply the following steps to each launcher you use, preserving the rest of the script. With a different launcher revision, compare the code rather than pasting blindly.

### 1. Set the console and sudo fallback

Immediately before the SCRIPT_DIR= line, insert:

```bash
ESUDO="${ESUDO:-sudo}"
CUR_TTY="/dev/tty1"
```

### 2. Add the device profile

After the complete block that reads fo2.env (after its closing fi), and before the Savegame/device.cfg comment, insert:

```bash
# R36S / dArkOSen diagnostic profile. fo2.env can override these values.
export SDL_VIDEODRIVER="${FO2_TEST_VIDEO_DRIVER:-kmsdrm}"
export SDL_AUDIODRIVER="${FO2_TEST_AUDIO_DRIVER:-alsa}"
export ALSOFT_DRIVERS=alsa
export SDL_VIDEO_GL_DRIVER=libGLESv2.so
export SDL_VIDEO_EGL_DRIVER=libEGL.so
export FO2_RENDER="${FO2_TEST_RENDER:-640x480}"
export FO2_VIDEO_THREADS="${FO2_VIDEO_THREADS:-3}"
export FO2_VIDEO_FAST="${FO2_VIDEO_FAST:-1}"
# Keep the configured CPU maximum for this first diagnostic run.
export FO2_CPU_BOOST="${FO2_CPU_BOOST:-0}"
echo "[launcher] R36S dArkOSen test profile"
echo "[launcher] video=$SDL_VIDEODRIVER audio=$SDL_AUDIODRIVER render=$FO2_RENDER cap=${FO2_CAP:-$DEFAULT_CAP}"
echo "[launcher] CFW=${CFW_NAME:-unknown} user=$(id)"
[ -r /proc/device-tree/model ] && { tr -d '\000' < /proc/device-tree/model; echo; }
ls -l /dev/dri /dev/tty1 2>/dev/null
free -m
command -v ldd >/dev/null 2>&1 && ldd ./fo2.aarch64
if [ -r "$CUR_TTY" ]; then
  exec < "$CUR_TTY"
else
  echo "[launcher] Cannot read $CUR_TTY"
fi
```

### 3. Replace the final cleanup and launch section

Replace everything from cleanup() { to the end of the file with this block. Keep WATCH_PID=$! and everything above it:

```bash
VT_STATE=""
cleanup() {
  kill "$WATCH_PID" 2>/dev/null
  for entry in $CLOCK_STATE; do wsys "${entry%%=*}" "${entry#*=}"; done
  for entry in $VT_STATE; do wsys "${entry%%=*}" "${entry#*=}"; done
  if [ -w "$CUR_TTY" ]; then printf '\033c\033[?25h' > "$CUR_TTY"; fi
  sync
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Give SDL/KMSDRM access to the display, restoring original bindings on exit.
if [ "$SDL_VIDEODRIVER" = "kmsdrm" ]; then
  if [ -w "$CUR_TTY" ]; then printf '\033c\033[?25l' > "$CUR_TTY"; fi
  for bind in /sys/class/vtconsole/vtcon*/bind; do
    [ -r "$bind" ] || continue
    oldbind=$(cat "$bind")
    if wsys "$bind" 0; then
      VT_STATE="$VT_STATE $bind=$oldbind"
    else
      echo "[launcher] Cannot release $bind"
    fi
  done
fi
sync
chmod +x ./fo2.aarch64
# FO2_CAP (fo2.env): the frame rate limit. 60 lets frames alternate between one and two panel refreshes when the game
# cannot hold 60, felt as stutter; 30 gives even frames.
echo "[launcher] Starting fo2.aarch64"
# Line buffering keeps the startup diagnostics when the console freezes.
if command -v stdbuf >/dev/null 2>&1; then
  stdbuf -oL -eL ./fo2.aarch64 --cap="${FO2_CAP:-$DEFAULT_CAP}"
else
  ./fo2.aarch64 --cap="${FO2_CAP:-$DEFAULT_CAP}"
fi
GAME_STATUS=$?
echo "[launcher] exit code $GAME_STATUS"
exit "$GAME_STATUS"
```

### 4. Save and test

Save as UTF-8 without BOM, with Unix LF line endings. On Windows, Notepad++ lets you select both settings. Safely eject the card and test the 30 FPS launcher. These blocks reproduce the tested runtime changes, including diagnostic logging.

## What changes

The profile selects SDL KMSDRM, ALSA for SDL/OpenAL, explicit GLES/EGL libraries, 640x480 rendering and video decoding defaults of three threads with fast decoding enabled. CPU boost defaults to disabled, preserving the configured CPU maximum; this is not an overclock. The original GPU governor logic remains.

It opens stdin from /dev/tty1 when readable, temporarily releases vtconsole bindings for KMSDRM and restores successful changes on exit. Cleanup also restores the cursor, handles INT/TERM and retains the game exit status. stdbuf is used when available to improve startup logging. Forced power-off cannot run cleanup.

The tested profile is forced for these launchers. Keep these modified files for R36S/dArkOSen. For upstream integration, add appropriate device/system detection instead of applying this profile to every handheld.

Optional overrides in ports/flatout2/fo2.env: FO2_TEST_VIDEO_DRIVER, FO2_TEST_AUDIO_DRIVER and FO2_TEST_RENDER. FO2_CPU_BOOST, FO2_VIDEO_THREADS and FO2_VIDEO_FAST retain their existing override behavior. These overrides are for troubleshooting; defaults match the tested setup.

## Restore or troubleshoot

To undo, copy the original .sh files from your backup folder back into ports, replacing the patched copies. The BAT creates backups only when it actually patches files.

If the game still fails, keep ports/flatout2/log.txt and mem.txt, plus log.prev.txt and mem.prev.txt if present. If no log appears, check that you launched the correct shortcut and that the port folder is in the expected location. Do not replace FlatOut2.exe without evidence: the tested executable MD5 is 1f8cae2b47276ca134750ba438aa35ca.

The BAT validates normalized launcher text with SHA-256, ignoring BOM and CRLF/LF differences. Original text hash: a842432657cb3c9053d042b3570cbb8f8ba10fb11b4d49db7808577dd6858fa6. Fixed text hash: 44e130170dc0f34039a32abc1f175252a0b331edc0c3d5e92592586e05a0b270. This compatibility check does not authenticate the downloaded BAT. SHA256SUMS.txt provides its release checksum.

## Português

## Versão do port e compatibilidade dos launchers

Versão do port informada pelo usuário que testou: [FlatOut 2 ARM64 port v2.0.0](https://github.com/badcats72/flatout2-portmaster/releases#release-v2.0.0).

Atenção: o ZIP oficial da v2.0.0 contém um launcher diferente, chamado FlatOut 2.sh. Esta correção foi testada com a estrutura de dois launchers abaixo. O BAT aceita somente esses scripts exatos reconhecidos e não altera o launcher oficial da v2.0.0. A versão do binário ARM64 local não foi verificada de forma independente. A referência à release não significa que o pacote oficial intacto da v2.0.0 foi testado com este fix.

## Antes de começar

Correção comunitária dos launchers do FlatOut 2 para R36S com dArkOSen. Os launchers modificados funcionaram no aparelho testado pelo usuário em 18/11/2026. Não houve medição de FPS nem validação em outros sistemas. Ainda não foi isolado qual ajuste resolveu a tela preta.

Autor do port original: [iBadCats / u/Green-Marzipan-8810](https://www.reddit.com/user/Green-Marzipan-8810/). Port original: [badcats72/flatout2-portmaster](https://github.com/badcats72/flatout2-portmaster). Esta adaptação independente não é uma versão oficial do autor. Não inclui arquivos do jogo nem binários ARM64.

A correção atende à estrutura antiga com os dois launchers abaixo. A versão exata do binário local não foi confirmada. Releases atuais com FlatOut 2.sh não são suportadas pelo BAT; não renomeie esse launcher para contornar a verificação.

```text
ports/
  fix-flatout2-r36s-darkosen.bat
  FlatOut 2 [RK3326 - 30 FPS].sh
  FlatOut 2 [H700 - FPS Unlock].sh
  flatout2/
    fo2.aarch64
    gamedata/
```

## Correção automática no Windows

1. Desligue o portátil e conecte o cartão de jogos a um computador Windows. Localize a pasta ports que contém flatout2/fo2.aarch64.
2. Baixe fix-flatout2-r36s-darkosen.bat pelo botão acima. Copie o arquivo BAT para dentro de ports, ao lado da pasta flatout2. Não execute dentro de flatout2.
3. Dê dois cliques no BAT. Ele usa o Windows PowerShell já instalado; não baixa dependências nem exige administrador. Leia o resultado antes de fechar a janela.
4. Os dois launchers reconhecidos são corrigidos se estiverem presentes; basta um deles. Todos os arquivos-alvo presentes são verificados antes de alterar qualquer launcher. Arquivos diferentes ou editados são recusados. Arquivos já corrigidos são ignorados.
5. Os originais são copiados integralmente para ports/flatout2/backup-r36s-fix-DATA-HORA-ID/. Os scripts corrigidos são gravados em UTF-8 sem BOM e com finais Unix LF. Executar novamente não reaplica a correção.
6. Ejete o cartão com segurança e teste primeiro FlatOut 2 [RK3326 - 30 FPS]. O nome do launcher mantém a seleção original do limite de 30/60 FPS; isso não garante FPS constante.

O BAT altera somente os launchers .sh reconhecidos e cria o backup deles. Não modifica o binário, os dados do jogo ou os saves. Ao executar o jogo, o launcher existente continua atualizando os arquivos de vídeo/configurações como já fazia; FO2_RENDER agora seleciona 640x480.

## Aplicação manual

Use este método apenas na estrutura antiga e com trechos correspondentes. Faça backup dos .sh primeiro. Aplique os passos em cada launcher que utiliza, preservando o restante do script. Se a revisão for diferente, compare o código antes de colar os blocos.

### 1. Defina o console e o fallback de sudo

Imediatamente antes da linha SCRIPT_DIR=, insira:

```bash
ESUDO="${ESUDO:-sudo}"
CUR_TTY="/dev/tty1"
```

### 2. Adicione o perfil do aparelho

Após o bloco completo que lê fo2.env (depois do fi que encerra esse bloco), e antes do comentário Savegame/device.cfg, insira:

```bash
# R36S / dArkOSen diagnostic profile. fo2.env can override these values.
export SDL_VIDEODRIVER="${FO2_TEST_VIDEO_DRIVER:-kmsdrm}"
export SDL_AUDIODRIVER="${FO2_TEST_AUDIO_DRIVER:-alsa}"
export ALSOFT_DRIVERS=alsa
export SDL_VIDEO_GL_DRIVER=libGLESv2.so
export SDL_VIDEO_EGL_DRIVER=libEGL.so
export FO2_RENDER="${FO2_TEST_RENDER:-640x480}"
export FO2_VIDEO_THREADS="${FO2_VIDEO_THREADS:-3}"
export FO2_VIDEO_FAST="${FO2_VIDEO_FAST:-1}"
# Keep the configured CPU maximum for this first diagnostic run.
export FO2_CPU_BOOST="${FO2_CPU_BOOST:-0}"
echo "[launcher] R36S dArkOSen test profile"
echo "[launcher] video=$SDL_VIDEODRIVER audio=$SDL_AUDIODRIVER render=$FO2_RENDER cap=${FO2_CAP:-$DEFAULT_CAP}"
echo "[launcher] CFW=${CFW_NAME:-unknown} user=$(id)"
[ -r /proc/device-tree/model ] && { tr -d '\000' < /proc/device-tree/model; echo; }
ls -l /dev/dri /dev/tty1 2>/dev/null
free -m
command -v ldd >/dev/null 2>&1 && ldd ./fo2.aarch64
if [ -r "$CUR_TTY" ]; then
  exec < "$CUR_TTY"
else
  echo "[launcher] Cannot read $CUR_TTY"
fi
```

### 3. Substitua o trecho final de limpeza e execução

Substitua tudo a partir de cleanup() { até o fim do arquivo pelo bloco abaixo. Preserve WATCH_PID=$! e tudo que vem antes dele:

```bash
VT_STATE=""
cleanup() {
  kill "$WATCH_PID" 2>/dev/null
  for entry in $CLOCK_STATE; do wsys "${entry%%=*}" "${entry#*=}"; done
  for entry in $VT_STATE; do wsys "${entry%%=*}" "${entry#*=}"; done
  if [ -w "$CUR_TTY" ]; then printf '\033c\033[?25h' > "$CUR_TTY"; fi
  sync
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Give SDL/KMSDRM access to the display, restoring original bindings on exit.
if [ "$SDL_VIDEODRIVER" = "kmsdrm" ]; then
  if [ -w "$CUR_TTY" ]; then printf '\033c\033[?25l' > "$CUR_TTY"; fi
  for bind in /sys/class/vtconsole/vtcon*/bind; do
    [ -r "$bind" ] || continue
    oldbind=$(cat "$bind")
    if wsys "$bind" 0; then
      VT_STATE="$VT_STATE $bind=$oldbind"
    else
      echo "[launcher] Cannot release $bind"
    fi
  done
fi
sync
chmod +x ./fo2.aarch64
# FO2_CAP (fo2.env): the frame rate limit. 60 lets frames alternate between one and two panel refreshes when the game
# cannot hold 60, felt as stutter; 30 gives even frames.
echo "[launcher] Starting fo2.aarch64"
# Line buffering keeps the startup diagnostics when the console freezes.
if command -v stdbuf >/dev/null 2>&1; then
  stdbuf -oL -eL ./fo2.aarch64 --cap="${FO2_CAP:-$DEFAULT_CAP}"
else
  ./fo2.aarch64 --cap="${FO2_CAP:-$DEFAULT_CAP}"
fi
GAME_STATUS=$?
echo "[launcher] exit code $GAME_STATUS"
exit "$GAME_STATUS"
```

### 4. Salve e teste

Salve em UTF-8 sem BOM e com finais de linha Unix LF. No Windows, o Notepad++ permite escolher as duas opções. Ejete o cartão com segurança e teste o launcher de 30 FPS. Estes blocos reproduzem os ajustes de execução testados, incluindo os logs de diagnóstico.

## O que muda

O perfil seleciona SDL KMSDRM, áudio ALSA no SDL/OpenAL, bibliotecas GLES/EGL explícitas, renderização em 640x480 e padrões de decodificação de vídeo com três threads e modo rápido. O boost de CPU fica desativado por padrão, preservando o máximo configurado; não é overclock. A lógica original do governor da GPU permanece.

Abre a entrada padrão em /dev/tty1 quando há permissão de leitura, libera temporariamente os vínculos vtconsole para KMSDRM e restaura os vínculos alterados ao sair. A limpeza restaura o cursor, trata INT/TERM e preserva o código de saída do jogo. Usa stdbuf quando disponível para melhorar o registro da inicialização. Desligar à força impede a execução da limpeza.

O perfil testado é forçado nesses launchers. Use os arquivos modificados no R36S/dArkOSen. Para incorporar ao port original, adicione detecção apropriada de aparelho/sistema em vez de aplicar o perfil a todos os portáteis.

Overrides opcionais em ports/flatout2/fo2.env: FO2_TEST_VIDEO_DRIVER, FO2_TEST_AUDIO_DRIVER e FO2_TEST_RENDER. FO2_CPU_BOOST, FO2_VIDEO_THREADS e FO2_VIDEO_FAST mantêm o comportamento existente de override. Esses ajustes servem para diagnóstico; os padrões correspondem à configuração testada.

## Restaurar ou investigar

Para desfazer, copie os .sh originais da pasta de backup de volta para ports, substituindo as cópias corrigidas. O BAT só cria backup quando realmente altera algum arquivo.

Se o jogo continuar falhando, guarde ports/flatout2/log.txt e mem.txt, além de log.prev.txt e mem.prev.txt, se existirem. Se nenhum log aparecer, confira o atalho executado e a localização do port. Não substitua FlatOut2.exe sem evidência: o MD5 do executável testado é 1f8cae2b47276ca134750ba438aa35ca.

O BAT verifica o texto normalizado dos launchers com SHA-256, desconsiderando BOM e diferenças CRLF/LF. Hash do texto original: a842432657cb3c9053d042b3570cbb8f8ba10fb11b4d49db7808577dd6858fa6. Hash do texto corrigido: 44e130170dc0f34039a32abc1f175252a0b331edc0c3d5e92592586e05a0b270. Essa verificação de compatibilidade não autentica o BAT baixado. SHA256SUMS.txt contém o checksum da distribuição.

## GitHub Pages / Publicação

EN: Create a repository named flatout2-fix-r36s-darkosEN and upload this project. In Settings → Pages, choose Deploy from a branch, main and /(root), then Save. The committed HTML is ready to serve; no build or dependencies are needed. See [GitHub documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). English lives at index.html and Portuguese at pt-br/index.html. Relative links support repository subpaths. This local delivery does not create or publish a GitHub repository.

PT: Crie um repositório chamado flatout2-fix-r36s-darkosEN e envie este projeto. Em Settings → Pages, selecione Deploy from a branch, main e /(root), depois Save. O HTML já está pronto; não exige build nem dependências. Consulte a [documentação do GitHub](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site). Inglês em index.html; português em pt-br/index.html. Os links relativos funcionam em subpastas do GitHub Pages. Esta entrega local não cria nem publica um repositório GitHub.

## Maintenance / Manutenção

Public URLs are configured in site.json: https://coreilabs.github.io/flatout2-fix-r36s-darkosEN/ (English) and its pt-br/ path (Portuguese). Change this setting before regenerating pages if the repository name changes. Canonical, Open Graph and Twitter metadata use absolute HTTPS URLs. / Os endereços públicos ficam em site.json. Ajuste essa configuração antes de regenerar as páginas se o nome do repositório mudar.

The supplied 1672×941 PNG is preserved in assets/fix-r36s-flatout2.png. To refresh the social image, run python scripts/renew-preview.py then python scripts/build-docs.py. This creates a fresh random-versioned filename and updates og:image, og:image:secure_url and twitter:image together. Publish the new image and HTML together. CSS-only changes do not renew the image. / O PNG original foi preservado. Para renovar a imagem social, execute os dois comandos acima e publique a imagem com o HTML; edições apenas no CSS não renovam a imagem.

Preview copy stays within editorial budgets of 50 title and 90 description characters. This is not a verified WhatsApp rendering or an official character limit. After publication, request a new scrape with the platform's preview debugger when needed; a new URL does not update old posts or guarantee immediate cache refresh. / Os textos seguem os orçamentos editoriais de 50 caracteres no título e 90 na descrição. Não são limites oficiais nem uma prévia validada no WhatsApp. Após publicar, use o depurador da plataforma para solicitar nova leitura quando necessário; a URL nova não atualiza posts antigos nem garante renovação imediata de cache.

Use Python 3: python scripts/build.py regenerates the BAT and checksum from scripts/patch.ps1 and scripts/patch.json. python scripts/build-docs.py regenerates both pages and README. After CSS edits or page regeneration, run python scripts/renew-assets.py once to renew the random CSS publication token consistently. Commit downloads, HTML and CSS together. Scripts contain no telemetry, remote downloads or game files.

Use Python 3: python scripts/build.py regenera o BAT e o checksum a partir de scripts/patch.ps1 e scripts/patch.json. python scripts/build-docs.py regenera as páginas e o README. Após editar CSS ou regenerar páginas, execute python scripts/renew-assets.py uma vez para renovar o token aleatório do CSS. Envie downloads, HTML e CSS juntos. Os scripts não incluem telemetria, downloads remotos ou arquivos do jogo.

## Credits and license / Créditos e licença

Original port: [badcats72/flatout2-portmaster](https://github.com/badcats72/flatout2-portmaster). Original author: [iBadCats / u/Green-Marzipan-8810](https://www.reddit.com/user/Green-Marzipan-8810/). Launcher-derived code retains the upstream MIT license in [LICENSE-UPSTREAM](LICENSE-UPSTREAM). Project source is also available under [MIT](LICENSE). This project distributes only the compatibility changes and documentation. / O código derivado dos launchers mantém a licença MIT original; o projeto também usa MIT e distribui somente os ajustes de compatibilidade e documentação.
