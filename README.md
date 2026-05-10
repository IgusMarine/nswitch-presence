# NSwitch Presence

App de Discord Rich Presence para o console Switch — mostra automaticamente o jogo que você está jogando, com tempo de sessão ao vivo e capa do jogo.

> ⚠️ **Disclaimer**
>
> Este projeto **não é afiliado, endossado ou patrocinado pela Nintendo**. "Nintendo", "Nintendo Switch" e marcas relacionadas são propriedade da Nintendo Co., Ltd. Este app utiliza APIs **não-oficiais e reverse-engineered pela comunidade** para fins educacionais e de uso pessoal. Use por sua conta e risco — o uso de APIs não-oficiais pode violar os Termos de Serviço da plataforma e levar a banimento de conta.
>
> Este projeto é **não-comercial**, não vende nada, não distribui jogos ou conteúdo protegido por direitos autorais.

> ℹ️ **Status:** distribuição apenas binária. O código-fonte original (TypeScript / React / Electron com build pipeline) não está incluído — este repositório contém o output bundled do build, modificado e mantido manualmente.

## Recursos

- **Rich Presence automático** no Discord: nome do jogo, plataforma (Switch / Switch 2), tempo de sessão ao vivo, capa, botão "Ver na eShop"
- **Histórico de sessões** com top jogos por tempo (usando o total oficial fornecido pelo serviço), busca, streak de dias seguidos, modal de detalhe por jogo
- **Integração HowLongToBeat** — botão direto pra busca do jogo
- **Marcos de jogo** — notificação Windows ao bater 1h, 10h, 100h etc num jogo
- **Modo privado** ("Um jogo no Switch") e lista de jogos ocultos
- **Auto-reconnect** do Discord RPC com backoff exponencial
- **Inicia escondido na bandeja** quando autostart com Windows está ligado
- **Onboarding 3-passos** com diagnóstico pós-conexão
- **Export do histórico** em JSON ou CSV
- Tema Nintendo (vermelho `#E60012` + Joy-Con accents)

## Como funciona

O console não expõe presença localmente — apenas via uma API privada do fabricante (a mesma usada pelo app oficial Switch Online). Este app consulta o serviço **[nxapi-presence](https://nxapi-presence.fancy.org.uk/)** do Samuel Elliott (proxy público gratuito do nxapi), que faz a ponte com essa API.

```
Console → API privada → nxapi-presence (proxy) → NSwitch Presence → Discord RPC
```

## Pré-requisitos

- Windows 10 ou 11
- Discord Desktop instalado e logado
- Assinatura **Switch Online** ativa
- No console: *Perfil → Configurações de Compartilhamento de Presença Online → "Amigos"* (sem isso, sua presença fica oculta)

## Instalação

1. Baixe a última versão em [Releases](../../releases)
2. Extraia o ZIP em qualquer pasta
3. Execute `NSwitch Presence.exe`
4. Siga o onboarding de 3 passos:
   - Login com sua conta no nxapi-presence
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

- `monitorNsaId` — identificador da conta de serviço (16 hex)
- `externalApiUrl` — URL do servidor nxapi-presence (padrão: `https://nxapi-presence.fancy.org.uk`)
- `pollingInterval` — segundos entre checagens (padrão: 20)
- `privateMode`, `hiddenGames`, `notifyGameChange` — privacidade
- `discordClientId` — Application ID custom (opcional, pra capa de jogo customizada)
- `gameTotals`, `progressSnapshots` — dados acumulados localmente

## Privacidade

- O app **não envia** seu token de sessão pra nenhum servidor além do nxapi-presence (que você escolhe — pode self-host)
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

- Console comum: sem homebrew, dependência da API privada do fabricante é inevitável (única fonte de "qual jogo está rodando")
- Self-signed: SmartScreen mostra aviso na primeira execução. Clique em "Mais informações → Executar mesmo assim". Após reputação local, o aviso some
- Rebuild: sem o source TS/React, alterações na UI são feitas direto no HTML/JS bundled

## Riscos de uso

- O uso de APIs não-oficiais pode violar os Termos de Serviço do fabricante
- Em casos raros, o acesso pode ser detectado e levar a limitações na conta
- Considere usar uma conta secundária se quer ser conservador
- O serviço público nxapi-presence pode sair do ar a qualquer momento — opte por self-host se precisa de garantias
