# English

Hi iBadCats! Thank you for bringing FlatOut 2 to ARM64 handhelds.

I was getting a black screen on my R36S running dArkOSen. After changing the launchers, the game now works on my device. I put together a small community fix with a Windows BAT installer, automatic launcher backups, and English/Portuguese instructions, including a manual method.

The working configuration forces SDL KMSDRM, ALSA audio, explicit GLES/EGL libraries and 640x480 rendering. It sets the video decoding defaults to three threads with fast decoding, leaves CPU boost disabled by default, reads stdin from tty1 when available, and temporarily releases vtconsole bindings before starting the game, restoring them on exit. It also adds startup diagnostics and preserves the game exit code.

The BAT changes only the two recognized launcher scripts. It checks their normalized text hashes before writing, skips already-fixed scripts and refuses unknown versions. It does not replace the ARM64 binary or include game files. The tested installation uses FlatOut 2 [RK3326 - 30 FPS].sh and FlatOut 2 [H700 - FPS Unlock].sh; both were modified and validated.

This has been confirmed on my device, but I have not isolated which individual adjustment solved the black screen or measured FPS. For upstream integration, I suggest applying this profile only after detecting the relevant R36S/dArkOSen environment, so other handheld profiles remain unaffected.

This fix targets my tested v2.0.0 installation: https://github.com/badcats72/flatout2-portmaster/releases#release-v2.0.0. The BAT validates the actual contents of the two scripts and refuses different launchers, including a package containing only FlatOut 2.sh.

The project credits you and links to your original port: https://github.com/badcats72/flatout2-portmaster

If useful, I can share these launcher changes for comparison with your current version. Thanks again for your work!

# Português

Olá, iBadCats! Obrigado por trazer o FlatOut 2 para os portáteis ARM64.

Eu estava tendo tela preta no meu R36S com dArkOSen. Após ajustar os launchers, o jogo passou a funcionar no meu aparelho. Preparei uma pequena correção comunitária com instalador BAT para Windows, backup automático dos launchers e instruções em inglês e português, incluindo aplicação manual.

A configuração que funcionou força SDL KMSDRM, áudio ALSA, bibliotecas GLES/EGL explícitas e renderização em 640x480. Define os padrões de decodificação de vídeo em três threads e modo rápido, deixa o boost de CPU desativado por padrão, lê a entrada padrão de tty1 quando disponível e libera temporariamente os vínculos vtconsole antes de iniciar o jogo, restaurando-os ao sair. Também adiciona diagnóstico de inicialização e preserva o código de saída do jogo.

O BAT altera somente os dois launchers reconhecidos. Verifica os hashes do texto normalizado antes de gravar, ignora scripts já corrigidos e recusa versões desconhecidas. Não substitui o binário ARM64 nem inclui arquivos do jogo. A versão exata do meu binário local não foi confirmada, e ainda não testei esta adaptação no launcher mais novo FlatOut 2.sh.

O funcionamento foi confirmado no meu aparelho, mas não isolei qual ajuste resolveu a tela preta nem medi FPS. Para incorporar ao projeto original, sugiro aplicar o perfil somente após detectar o ambiente R36S/dArkOSen correspondente, preservando os perfis dos outros portáteis.

A versão informada pelo usuário foi a v2.0.0: https://github.com/badcats72/flatout2-portmaster/releases#release-v2.0.0. Porém, o ZIP oficial usa somente FlatOut 2.sh, enquanto a instalação local que funcionou usava os dois launchers antigos. A documentação deixa essa diferença explícita; o BAT não suporta o launcher oficial da v2.0.0.

O projeto dá os créditos a você e aponta para o port original: https://github.com/badcats72/flatout2-portmaster

Se for útil, posso compartilhar essas alterações para comparação com sua versão atual. Obrigado pelo trabalho!
