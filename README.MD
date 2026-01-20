## 1. Visão Geral do Projeto
- **Objetivo:** Criar um jogo de ritimo no Haxe e Openfl/Haxeflixel
- **Plataformas:** Windows, Web e Android
- **Dependências:** Haxe, Openfl, Lime, Haxeflixel, Haxe-UI

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
    MainMenuState.hx     # Menu principal com navegação
    MetadataEditorState.hx # Editor de metadados com Haxe-UI
assets/
  imagens/
  videos/
  sons/
  music/               # Arquivos de música e metadados (.json)
```

## 3. Formato dos Metadados de Música (.json)
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

## 4. Editor de Metadados

O projeto inclui um **Editor de Metadados** visual construído com Haxe-UI que permite criar e editar arquivos de metadados de música de forma interativa.

### Recursos do Editor:
- Interface gráfica intuitiva com suporte a mouse, teclado e touch
- Criação e edição de todos os campos de metadados
- Gerenciamento visual de cue points e mudanças de tempo
- Salvar e carregar arquivos JSON
- Compatível com desktop, web e mobile

### Como Usar:
1. Execute o jogo e selecione "Metadata Editor" no menu principal
2. Use "New" para criar um novo arquivo ou "Load" para editar um existente
3. Preencha os campos desejados
4. Adicione cue points e tempo changes conforme necessário
5. Use "Save" ou "Save As" para salvar o arquivo

Para documentação completa, consulte [METADATA_EDITOR.md](METADATA_EDITOR.md).

### Navegação:
- **Teclado**: Setas/WASD para navegar, Enter/Espaço para selecionar, ESC para voltar
- **Mouse/Touch**: Clique em qualquer elemento para interagir
- **Scroll**: Role para ver todo o conteúdo do editor
