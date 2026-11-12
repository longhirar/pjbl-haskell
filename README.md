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

