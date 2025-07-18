## 1. Visão Geral do Projeto
- **Objetivo:** Criar um jogo de ritimo no Haxe e Openfl/Haxeflixel
- **Plataformas:** Windows, Web e Android
- **Dependências:** Haxe, Openfl, Lime e Haxeflixel

## 2. Estrutura de Pastas e Arquivos
```
Project.xml
src/
  Main.hx
  states/
    DefaultState.hx      # FlxState extendido para funções adicionais
    PlayState.hx         # Lógica principal de gameplay
    GameOverState.hx     # Tela de fim de jogo
  objects/
    DefaultObject.hx     # FlxObject extendido para funções adicionais
    DefaultSprite.hx     # FlxSprite extendido para funções adicionais
    DefaultBar.hx        # Uma barra padrão
    HealthBar.hx         # Barra de vida
    ComboBar.hx          # Barra de combo
    ScoreBar.hx          # Barra de pontuação
  audio/
    MusicManager.hx      # Carregamento e sincronização de áudio
  utils/
    InputManager.hx      # Leitura e filtragem de teclas
    DifficultyConfig.hx  # Configurações por nível de dificuldade
    ThemeConfig.hx       # Definições de cores e backgrounds
assets/
  imagens/
  videos/
  sons/
```