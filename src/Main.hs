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

-- texto da leitura do campeonato de teste (camada 3)
relatorioLeitura :: String
relatorioLeitura = case lerCampeonato dadosCampeonato of
  Left erro -> "Erro: " ++ descreverErro erro ++ "\n"
  Right partidas -> show (length partidas) ++ " partidas lidas sem erro\n" ++ relatorioCampeonato partidas

-- texto do tratamento de uma entrada com erros (camada 3)
relatorioErros :: String
relatorioErros = unlines (cabecalho ++ erros)
  where
    cabecalho =
      [ titulo "Entrada com erros",
        "lerCampeonato para no primeiro erro -> " ++ either descreverErro (const "nenhum erro") (lerCampeonato dadosComErros),
        "todosOsErros lista todos:"
      ]
    erros = map (("  - " ++) . descreverErro) (todosOsErros dadosComErros)

-- a unica funcao com IO: imprime os textos montados acima
main :: IO ()
main = do
  putStrLn (titulo "Lendo o campeonato de teste")
  putStr relatorioLeitura
  putStr relatorioErros