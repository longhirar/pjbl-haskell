module Main where

import Tipos
import Classificacao
import Leitura
import Dados

-- um titulo, pulando uma linha antes
titulo :: String -> String
titulo texto = "\n" ++ texto

-- uma linha do aproveitamento, ex.: "  Flamengo: 53.3%"
formatarAproveitamento :: Linha -> String
formatarAproveitamento l = "  " ++ time l ++ ": " ++ umaCasa (aproveitamento l) ++ "%"

-- texto com as camadas 1 e 2 a partir das partidas ja lidas
relatorioCampeonato :: [Partida] -> String
relatorioCampeonato partidas = unlines
  [ titulo "Times do campeonato",
    show (times partidas),
    titulo "Classificacao final",
    tabelaFormatada (classificacao partidas),
    titulo "Classificacao apos a rodada 3",
    tabelaFormatada (classificacao (ateRodada 3 partidas)),
    titulo "Estatisticas",
    "Maior goleada: " ++ maybe "nenhuma partida" descreverPartida (maiorGoleada partidas),
    "Media de gols por partida: " ++ maybe "sem partidas" umaCasa (mediaGols partidas),
    "Aproveitamento:",
    unlines (map formatarAproveitamento (classificacao partidas)),
    titulo "Campeonato vazio",
    "Maior goleada: " ++ maybe "nenhuma partida" descreverPartida (maiorGoleada []),
    "Media de gols: " ++ maybe "sem partidas" umaCasa (mediaGols [])
  ]


main :: IO ()
main = putStr (relatorioCampeonato [])
