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
    FilePath.hx          # Leitura de arquivos
    InputManager.hx      # Leitura e filtragem de teclas
    MusicMetaData.hx     # Interfaçe para dados de musica .json
    Music.hx             # Instançia de uma musica, com seu contador de bpm
  objects/
    DefaultBar.hx        # Uma barra padrão
  states/
    DefaultState.hx      # FlxState extendido para funções adicionais
    PlayState.hx         # Lógica principal de gameplay
    GameOverState.hx     # Tela de fim de jogo
assets/
  imagens/
  videos/
  sons/
```