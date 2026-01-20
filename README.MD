## 1. Visão Geral do Projeto
- **Objetivo:** Criar um jogo de ritimo no Haxe e Openfl/Haxeflixel
- **Plataformas:** Windows, Web e Android
- **Dependências:** Haxe, Openfl, Lime, Haxeflixel e Flixel-UI

## 2. Estrutura de Pastas e Arquivos
```
Project.xml
source/
  Main.hx
  backend/
    BeatEvent.hx         # Typedef para um evento de batida
    FilePath.hx          # Utilitários para caminhos de arquivos
    InputManager.hx      # Gerenciador de entrada para teclado
    MusicMetaData.hx     # Typedef para os metadados de uma música (.json)
    Paths.hx             # Gerencia os caminhos para os assets
  objects/
    Conductor.hx         # Toca a música e gerencia o ritmo (BPM, batidas, etc.)
    Song.hx              # Contêiner de dados para uma música (metadados e áudio)
    DefaultBar.hx        # Uma barra padrão
  states/
    DefaultState.hx      # FlxState extendido para funções adicionais
    DebugState.hx        # Estado para testes e debug
    PlayState.hx         # Lógica principal de gameplay
    MetadataEditorState.hx  # Editor visual de metadados de música
assets/
  imagens/
  videos/
  sons/
```

## 3. Editor de Metadados de Música
O projeto inclui um editor visual de metadados acessível pressionando a tecla **M** durante o jogo.

**Recursos:**
- Interface touch-friendly para dispositivos móveis
- Suporte completo a mouse/teclado para desktop
- Carregar e salvar arquivos JSON de metadados
- Validação em tempo real dos campos
- Atalhos de teclado (Ctrl+S para salvar, Ctrl+O para abrir, etc.)

Para mais informações, consulte [METADATA_EDITOR.md](METADATA_EDITOR.md).

## 4. Formato dos Metadados de Música (.json)
Os arquivos JSON de metadados de música devem seguir a seguinte estrutura:
```json
{
    "title": "Nome da Música",
    "artist": "Artista",
    "bpm": 120,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "chorus": 30000
    },
    "tempoChanges": [
        { "time": 60000, "bpm": 125 },
        { "time": 90000, "bpm": 130 }
    ],
    "looped": false
}
```
- `offset`: Atraso inicial da música em milissegundos.
- `cuePoints`: Pontos de referência na música (em milissegundos).
- `tempoChanges`: Mudanças de BPM ao longo da música (em milissegundos).
- `looped`: Se a música deve tocar em loop.
