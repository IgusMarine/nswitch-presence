# NSwitch Presence — Roadmap futuro

Lista priorizada de melhorias identificadas. Ordem por impacto/esforço.

## Prioridade alta — UX direta

### 1. Pausar RPC temporariamente
Botão "Pausar por 1h / 4h / até amanhã" no card do Discord. Hoje o toggle é binário (on/off).
**Onde:** card "Discord Rich Presence" na aba Agora.
**Como:** novo store key `rpcPausedUntil` (timestamp). `setGame` checa antes de aplicar. Timer no renderer mostra countdown.

### 2. Modo "Não perturbar" por horário
Desabilitar RPC automaticamente em janela horária definida (ex: 23h–7h).
**Onde:** card Privacidade em Configurações.
**Como:** stores `dndStart`, `dndEnd` (HH:MM). Check no `setGame` e a cada minuto via `setInterval`.

### 3. Empty state melhor quando Switch offline
Hoje mostra "Sem jogo agora". Substituir por:
- Top 3 jogos recentes do `gameTotals`
- Botões "Continuar X" → abre eShop / HLTB
**Onde:** `renderNow()` quando `!isOnline`.

### 4. Header de datas no histórico
Agrupar sessões por "Hoje / Ontem / Esta semana / Mais antigo" com headers visuais.
**Onde:** lista de sessões em `renderHistory()`.

### 5. Tooltips contextuais
Hover em campos técnicos (NSA ID, Application ID, Modo Privado) abre tooltip explicando.
**Como:** atributo `title` HTML ou tooltip custom CSS. CSS `[data-tip]:hover::after`.

## Prioridade média

### 6. Test Notification button
Botão em Privacidade que dispara uma notificação de teste — confirma que o Windows não tá silenciando.
**Como:** novo IPC `app:test-notification` que faz `new Notification({...}).show()`.

### 7. Janela redimensionável + memória de posição
- `resizable: true` + `minWidth: 720, minHeight: 520`
- Salvar `windowBounds` no store, restaurar no boot
**Como:** listeners `move`, `resize`, persist debounced.

### 8. Card "Sobre" com versão e changelog
- Mostrar `app.getVersion()` na UI
- Link "Novidades" abre changelog (markdown rendered ou GitHub releases)

## Distribuição (se compartilhar publicamente)

### 9. Installer NSIS ou Inno Setup
Empacotar como `.exe` instalador único — cria atalho no menu iniciar, registra no Programas e Recursos, opção de iniciar com Windows no instalador.
**Recomendado:** `electron-builder` com target `nsis`.

### 10. Auto-update via Electron autoUpdater
Verificar releases do GitHub em background, baixar diff, aplicar no próximo boot.
**Pré-requisito:** ter GitHub releases públicos com installers assinados.

## Reliability invisível

### 11. Timeout nos fetch
`AbortController` com 8s nos calls pra `nxapi-presence`. Hoje pode pendurar até o sistema cortar (~2min) se a conexão travar metade-aberta.

### 12. Recovery de config corrompido
Detectar `JSON.parse` error no boot, fazer backup do arquivo quebrado, fallback pra defaults com toast informando.

### 13. Backoff exponencial no poller
Hoje tenta a cada 20s independente de quantos erros consecutivos. Adicionar backoff até 5min se >3 falhas seguidas.

### 14. Cache local de capas
Download dos `.jpeg` em `userData/covers/` no primeiro encontro. Histórico fica visualmente preservado mesmo se a API morrer.

## Funcionalidade extra

### 15. Múltiplas contas Nintendo
Suporte a 2+ NSA IDs simultâneos com troca rápida na sidebar. Útil pra quem tem perfis primário/família.

### 16. Atalho global Ctrl+Shift+P
Toggle do RPC sem precisar focar a janela. Via `globalShortcut.register`.

### 17. Stats avançadas
- Heatmap "quando você joga" (hora × dia da semana)
- Média de sessão / dia
- Streak máximo histórico
- Exportável

### 18. Botão segundo no Rich Presence
Discord aceita 2 buttons. Hoje só uso eShop. Adicionar HLTB ou outro.
**Status:** parcialmente coberto pela adição manual no UI; falta no Discord activity.

## Notas

- Manter compatibilidade backward com `electron-store` — qualquer key nova deve ter default sensato
- Pra Win11, `roundedCorners: true` já entrega cantos arredondados nativos sem `transparent: true`
- Self-signed cert atual: `CN=Igus, O=Igus, C=BR`, válido por 3 anos. Renovar antes de expirar
