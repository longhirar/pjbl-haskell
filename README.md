# PjBL2 - Tabela de Classificação em Haskell

Programa que calcula a tabela de classificação de um campeonato de futebol a partir dos resultados das partidas, escritos em texto. O programa valida a entrada, mostra a classificação final, a classificação depois de uma rodada intermediária e algumas estatísticas.

O campeonato de teste tem 6 times do Brasileirão (Flamengo, Palmeiras, Corinthians, Sao Paulo, Gremio e Internacional) em 5 rodadas.

## Ambiente

GHC local (instalado pelo GHCup), versão 9.10.

## Estrutura

    src/Tipos.hs          Camada 1: tipos e consultas básicas
    src/Classificacao.hs  Camada 2: classificação com funções de ordem superior
    src/Leitura.hs        Camada 3: leitura, validação e formatação
    src/Dados.hs          campeonato de teste (como String)
    src/Main.hs           demonstração das três camadas
    tests/Testes.hs       testes com o resultado esperado
    docs/decisoes.md      decisões de modelagem e limitações

## Como rodar

Abra o terminal dentro da pasta do projeto.

Para rodar o programa:

    runghc -isrc src/Main.hs

Para rodar os testes:

    runghc -isrc tests/Testes.hs

Para conferir se o código compila sem avisos:

    ghc -Wall -isrc -fno-code src/Main.hs

O `-isrc` indica ao GHC que os módulos ficam dentro da pasta `src`.

## Formato da entrada

Cada linha descreve uma partida, com os campos separados por ponto e vírgula. Linhas em branco e linhas que começam com `#` são ignoradas.

    # rodada;mandante;gols mandante;gols visitante;visitante
    1;Flamengo;2;1;Internacional

Os dados ficam em `src/Dados.hs`, então o programa não precisa de entrada pelo teclado.