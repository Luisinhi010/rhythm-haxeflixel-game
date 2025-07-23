## 1. Visão Geral do Projeto
- **Objetivo:** Criar um jogo de ritimo no Haxe e Openfl/Haxeflixel
- **Plataformas:** Windows, Web e Android
- **Dependências:** Haxe, Openfl, Lime e Haxeflixel

## 2. Estrutura de Pastas e Arquivos
```
Project.xml
source/
  Main.hx
  backend/
    FilePath.hx
    InputManager.hx      # Leitura e filtragem de teclas
    MetaData.hx
    Music.hx
    MusicLoader.hx       # Carregamento e sincronização de áudio
  objects/
    DefaultBar.hx        # Uma barra padrão
    DefaultObject.hx     # FlxObject extendido para funções adicionais
    DefaultSprite.hx     # FlxSprite extendido para funções adicionais
    HealthBar.hx         # Barra de vida
  states/
    DefaultState.hx      # FlxState extendido para funções adicionais
    PlayState.hx         # Lógica principal de gameplay
    GameOverState.hx     # Tela de fim de jogo
  utils/
    ThemeConfig.hx       # Definições de cores e backgrounds
assets/
  imagens/
  videos/
  sons/
```