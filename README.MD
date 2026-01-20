# 🎵 HaxeFlixel Rhythm Game

> Um jogo de ritmo moderno inspirado em Guitar Hero e Friday Night Funkin', desenvolvido com Haxe e HaxeFlixel.

[![Haxe](https://img.shields.io/badge/Haxe-4.0+-orange.svg)](https://haxe.org/)
[![HaxeFlixel](https://img.shields.io/badge/HaxeFlixel-5.0+-green.svg)](https://haxeflixel.com/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## 📋 Sobre o Projeto

Um jogo de ritmo multiplataforma onde o jogador pressiona teclas direcionais sincronizadas com a música. O gameplay apresenta uma barra central com barras vindas dos lados da tela, lembrando a batalha contra Undyne de Undertale, mas em formato de jogo de ritmo.

### ✨ Características

- 🎮 **Sistema de Ritmo Avançado**: Engine precisa com suporte a BPM variável e mudanças de tempo
- 🎵 **Sistema de Música Completo**: Metadados JSON com cue points e mudanças de tempo
- 🎨 **Visual Customizável**: Temas e cores personalizáveis
- 🔧 **Ferramentas de Debug**: Debugger visual do Conductor e testador de utilitários
- 🌐 **Multiplataforma**: Windows, Web (HTML5) e Android

### 🎯 Recursos Implementados

- ✅ Sistema Conductor para controle de ritmo e música
- ✅ Carregamento e parsing de metadados de música (JSON)
- ✅ Sistema de cache de assets otimizado
- ✅ Gerenciador de input configurável
- ✅ Ferramentas de debug visual (ConductorDebugger, UtilTester)
- ✅ Utilitários matemáticos, de string e arrays
- ✅ Sistema de arquitetura modular e escalável

### 🚧 Em Desenvolvimento

- ⏳ Sistema de gameplay completo (barras, pontuação, combo)
- ⏳ Interface de seleção de músicas
- ⏳ Sistema de dificuldade
- ⏳ Menu principal e configurações

## 🚀 Começando

### Pré-requisitos

Antes de começar, você precisa ter instalado:

- [Haxe](https://haxe.org/download/) (4.0 ou superior)
- [HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) (instale via haxelib)

### 📦 Instalação

1. **Clone o repositório**

   ```bash
   git clone https://github.com/Luisinhi010/rhythm-haxeflixel-game.git
   cd rhythm-haxeflixel-game
   ```

2. **Instale as dependências do Haxe**

   ```bash
   haxelib install lime
   haxelib install openfl
   haxelib install flixel
   ```

3. **Configure o HaxeFlixel** (primeira vez apenas)

   ```bash
   haxelib run lime setup
   haxelib run flixel-tools setup
   ```

### ▶️ Como Executar

#### Windows (Debug)

```bash
lime test windows -debug
```

#### Web/HTML5 (Debug)

```bash
lime test html5 -debug
```

#### Android (Requer Android SDK configurado)

```bash
lime test android
```

#### Modo Release

```bash
lime test windows -release
```

### 🎮 Controles de Debug

No **DebugState** (estado inicial em debug):

- **SPACE**: Play/Pause da música
- **R**: Reiniciar música
- **Q**: Pular para cue point "test"
- **T**: Abrir/Fechar UtilTester (demonstrações visuais)
- **F5**: Recarregar estado atual (disponível em todos os estados)
- **Setas**: Navegar entre seções no UtilTester

## 📁 Estrutura do Projeto

```text
rhythm-haxeflixel-game/
├── source/
│   ├── Main.hx                    # Ponto de entrada
│   ├── Util.hx                    # Utilitários de plataforma
│   ├── backend/                   # Utilitários e sistemas core
│   │   ├── Paths.hx               # Sistema de cache de assets
│   │   ├── InputManager.hx        # Gerenciador de input
│   │   ├── FilePath.hx            # Gerenciamento de caminhos
│   │   ├── FlxGroupContainer.hx   # Container posicionável
│   │   ├── BeatEvent.hx           # Typedef de eventos de batida
│   │   └── MusicMetaData.hx       # Typedef de metadados
│   ├── core/
│   │   └── utils/                 # Utilitários gerais
│   │       ├── MathUtil.hx        # Funções matemáticas
│   │       ├── StringUtil.hx      # Formatação de strings
│   │       └── ArrayUtil.hx       # Manipulação de arrays
│   ├── objects/                   # Objetos do jogo
│   │   ├── Conductor.hx           # Sistema de ritmo e música
│   │   ├── Song.hx                # Container de dados musicais
│   │   ├── DefaultBar.hx          # Barra base do jogo
│   │   ├── ConductorDebugger.hx   # Debug visual do Conductor
│   │   ├── Metronome.hx           # Sons de metrônomo
│   │   └── UtilTester.hx          # Tester visual de utilitários
│   └── states/                    # Estados do jogo
│       ├── DefaultState.hx        # Estado base
│       ├── PlayState.hx           # Estado de gameplay
│       └── DebugState.hx          # Estado de testes
├── assets/
│   ├── images/                    # Imagens e sprites
│   ├── music/                     # Arquivos de música + JSON
│   ├── sounds/                    # Efeitos sonoros
│   └── ui/                        # Assets de UI
├── Project.xml                    # Configuração do projeto
├── hxformat.json                  # Configuração de formatação
└── README.MD                      # Este arquivo
```

## 🎵 Formato de Metadados de Música

Coloque arquivos `.json` na pasta `assets/music/` com o mesmo nome do arquivo de áudio:

```json
{
    "title": "Nome da Música",
    "artist": "Nome do Artista",
    "bpm": 120,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "verse": 15000,
        "chorus": 30000
    },
    "tempoChanges": [
        { "time": 60000, "bpm": 125 },
        { "time": 90000, "bpm": 130 }
    ],
    "looped": false
}
```

**Campos:**

- `title`: Nome da música
- `artist`: Nome do artista
- `bpm`: Batidas por minuto (inicial)
- `offset`: Delay inicial em milissegundos (opcional)
- `timeSignature`: Fórmula de compasso (opcional, padrão: "4/4")
- `cuePoints`: Pontos de referência nomeados em ms (opcional)
- `tempoChanges`: Mudanças de BPM durante a música (opcional)
- `looped`: Se deve tocar em loop (opcional)

## 🏗️ Arquitetura

### Padrões de Design

- **State Pattern**: Estados do jogo (PlayState, DebugState)
- **Singleton**: Gerenciadores globais (InputManager, Paths cache)
- **Observer Pattern**: Sistema de callbacks de batidas do Conductor
- **Facade Pattern**: Paths.hx simplifica acesso a assets

### Sistemas Principais

#### 1. Sistema Conductor

Gerencia reprodução de música e tracking de ritmo:

- Cálculo preciso de beats, steps, bars e sections
- Suporte a mudanças de BPM
- Callbacks para eventos de ritmo
- Sistema de cue points

#### 2. Sistema de Assets (Paths)

- Cache automático de recursos
- Carregamento síncrono e assíncrono
- Suporte multiplataforma
- Gerenciamento de memória

#### 3. Utilitários Core

- **MathUtil**: Funções matemáticas (lerp, clamp, mapRange, etc.)
- **StringUtil**: Formatação de texto e tempo
- **ArrayUtil**: Manipulação de arrays com segurança

## 🛠️ Desenvolvimento

### Estilo de Código

- Indentação: **Tabs** (convenção HaxeFlixel)
- Chaves: Linha nova para abertura/fechamento (exceto object literals)
- Nomenclatura:
  - Classes: `PascalCase`
  - Variáveis/Funções: `camelCase`
  - Constantes: `UPPER_CASE`
- Type annotations obrigatórias
- Veja `hxformat.json` para detalhes

### Build Targets

```bash
# Desktop
lime build windows
lime build linux
lime build mac

# Web
lime build html5

# Mobile
lime build android
lime build ios
```

### Testes

Use o **DebugState** para:

- Testar o sistema Conductor com músicas diferentes
- Visualizar beats e cue points no ConductorDebugger
- Testar utilitários com o UtilTester (pressione T)

## 📝 Documentação

Documentação detalhada disponível em:

- `.github/copilot-instructions.md` - Guia completo para desenvolvedores
- `plano.txt` - Design document em português

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona NovaFeature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é open source e está disponível sob a [MIT License](LICENSE).

## 👤 Autor

### Luisinhi010

- GitHub: [@Luisinhi010](https://github.com/Luisinhi010)

## 🙏 Agradecimentos

- Comunidade HaxeFlixel
- Inspiração: Guitar Hero, Friday Night Funkin', Undertale
- Todos os contribuidores do projeto

---

⭐ Se este projeto foi útil, considere dar uma estrela!
