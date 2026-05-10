# NSwitch Presence

App de Discord Rich Presence pra Nintendo Switch e Switch 2 — mostra automaticamente o jogo que você tá jogando, com tempo de sessão ao vivo, capa do jogo, e suporte a Switch 2.

> ⚠️ **Status:** distribuição apenas binária. O código-fonte original (TypeScript / React / Electron com build pipeline) não está incluído — este repositório contém o output bundled do build, modificado e mantido manualmente.

## Recursos

- **Rich Presence automático** no Discord: nome do jogo, plataforma (Switch / Switch 2), tempo de sessão ao vivo, capa, botão "Ver na eShop"
- **Histórico de sessões** com top jogos por tempo (usando o total oficial da Nintendo), busca, streak de dias seguidos, modal de detalhe por jogo
- **Integração HowLongToBeat** — botão direto pra busca do jogo
- **Marcos de jogo** — notificação Windows ao bater 1h, 10h, 100h etc num jogo
- **Modo privado** ("Um jogo no Switch") e lista de jogos ocultos
- **Auto-reconnect** do Discord RPC com backoff exponencial
- **Inicia escondido na bandeja** quando autostart com Windows está ligado
- **Onboarding 3-passos** com diagnóstico pós-conexão
- **Export do histórico** em JSON ou CSV
- Tema Nintendo (vermelho `#E60012` + Joy-Con accents)

## Como funciona

O Switch não expõe presença local — só a **Coral API privada da Nintendo** (a mesma usada pelo app NSO). Este app consulta o serviço **[nxapi-presence](https://nxapi-presence.fancy.org.uk/)** do Samuel Elliott (proxy público gratuito do nxapi), que faz a ponte com a API da Nintendo.

```
Switch → API Coral (Nintendo) → nxapi-presence (proxy) → NSwitch Presence → Discord RPC
```

## Pré-requisitos

- Windows 10 ou 11
- Discord Desktop instalado e logado
- Conta **Nintendo Switch Online** ativa
- No console: *Perfil → Configurações de Compartilhamento de Presença Online → "Amigos"* (sem isso, sua presença fica oculta)

## Instalação

1. Baixe a última versão em [Releases](../../releases)
2. Extraia o ZIP em qualquer pasta
3. Execute `NSwitch Presence.exe`
4. Siga o onboarding de 3 passos:
   - Login com sua conta Nintendo no nxapi-presence
   - Cole o link do seu perfil
   - O app valida e começa a monitorar

## Estrutura do projeto

```
resources/app/
├── package.json          # Dependências do Electron + discord-rpc
├── assets/               # Ícones (PNG, ICO, tray icons)
└── out/
    ├── main/index.js     # Processo principal Electron (bundled)
    ├── preload/index.cjs # Bridge IPC pro renderer
    └── renderer/         # UI single-file (HTML + CSS + vanilla JS)
        └── index.html
```

## Configuração

Settings ficam em `%APPDATA%\nswitch-presence\config.json`. Chaves principais:

- `monitorNsaId` — ID Nintendo Service Account (16 hex)
- `externalApiUrl` — URL do servidor nxapi-presence (padrão: `https://nxapi-presence.fancy.org.uk`)
- `pollingInterval` — segundos entre checagens (padrão: 20)
- `privateMode`, `hiddenGames`, `notifyGameChange` — privacidade
- `discordClientId` — Application ID custom (opcional, pra capa de jogo customizada)
- `gameTotals`, `progressSnapshots` — dados acumulados localmente

## Privacidade

- O app **não envia** seu token Nintendo pra nenhum servidor além do nxapi-presence (que você escolhe — pode self-host)
- Seu nome de usuário e capa de jogo aparecem no seu Discord conforme as configurações que você fizer
- Histórico de jogos fica **só localmente** no seu PC (`%APPDATA%`)
- Quando ativa Modo Privado, o Discord só vê "Um jogo no Switch" + plataforma

## Self-hosting (opcional)

Se preferir não depender do servidor público:

```bash
npm i -g nxapi
nxapi nso auth
nxapi presence-server --listen 127.0.0.1:12345
```

Depois, em Configurações → Fonte de dados, troque `externalApiUrl` para `http://127.0.0.1:12345`.

## Créditos

- **[nxapi](https://github.com/samuelthomas2774/nxapi)** por Samuel Elliott — biblioteca e serviço de presença que torna tudo isso possível
- **[discord-rpc](https://github.com/discordjs/RPC)** — cliente Discord RPC pro Node
- **Electron** + Chromium — runtime
- Ícone Switch: design custom (Joy-Cons em gradiente vermelho `#E60012` → `#960009`)

## Licença

O arquivo `LICENSE` neste repo é o **MIT da Electron** (vinculado ao runtime). Pra aplicar uma licença ao código deste app, adicione um `LICENSE.app.md` separado.

Sugestão: MIT.

## Roadmap

Veja [`FUTURE_IMPROVEMENTS.md`](./FUTURE_IMPROVEMENTS.md) — 18 itens priorizados por impacto/esforço, do "pausar RPC por 1h" até "auto-update via electron-builder".

## Limitações conhecidas

- Switch comum: sem homebrew, dependência da API Coral é inevitável (a Nintendo é a única fonte de "qual jogo está rodando")
- Self-signed: SmartScreen mostra aviso na primeira execução. Clique em "Mais informações → Executar mesmo assim". Após reputação local, o aviso some
- Rebuild: sem o source TS/React, alterações na UI são feitas direto no HTML/JS bundled
