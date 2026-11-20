module Main where

import Tipos
import Classificacao
import Leitura
import Dados

-- funcao de teste 
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK " ++ nome)
  | otherwise = putStrLn ("FALHOU " ++ nome ++ ": " ++ show obtido)

-- o campeonato de teste ja lido (lista vazia se der erro)
partidas :: [Partida]
partidas = either (const []) id (lerCampeonato dadosCampeonato)

-- uma partida para os testes da camada 1
jogo :: Partida
jogo = Partida 1 "Flamengo" 2 1 "Internacional"

-- classificacao final, conferida a mao
tabelaFinal :: [Linha]
tabelaFinal =
  [ Linha "Flamengo" 5 2 2 1 9 5,
   Linha "Palmeiras" 5 2 2 1 8 5,
   Linha "Corinthians" 5 2 2 1 6 6,
   Linha "Internacional" 5 2 0 3 6 5,
   Linha "Gremio" 5 1 2 2 5 8,
   Linha "Sao Paulo" 5 1 2 2 3 8
  ]

-- classificacao depois da rodada 3, conferida a mao
tabelaRodada3 :: [Linha]
tabelaRodada3 =
  [ Linha "Flamengo" 3 2 1 0 7 2,
   Linha "Palmeiras" 3 2 0 1 5 2,
   Linha "Corinthians" 3 1 2 0 4 3,
   Linha "Internacional" 3 1 0 2 3 3,
   Linha "Gremio" 3 0 2 1 3 6,
   Linha "Sao Paulo" 3 0 1 2 0 6
  ]

camada1 :: IO ()
camada1 = do
  putStrLn "Camada 1\n"
  testar "resultadoPara do mandante" (resultadoPara "Flamengo" jogo) (Just Vitoria)
  testar "resultadoPara do visitante" (resultadoPara "Internacional" jogo) (Just Derrota)
  testar "resultadoPara de quem nao jogou" (resultadoPara "Gremio" jogo) Nothing
  testar "times sem repeticao e em ordem" (times partidas)
    ["Corinthians", "Flamengo", "Gremio", "Internacional", "Palmeiras", "Sao Paulo"]

camada2 :: IO ()
camada2 = do
  putStrLn "Camada 2\n"
  testar "pontos" (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "classificacao final" (classificacao partidas) tabelaFinal
  -- Flamengo, Palmeiras e Corinthians tem 8 pontos e 2 vitorias: decide o saldo
  testar "desempate por saldo (8 pontos)" (map time (take 3 (classificacao partidas)))
    ["Flamengo", "Palmeiras", "Corinthians"]
  -- Gremio e Sao Paulo tem 5 pontos e 1 vitoria: decide o saldo
  testar "desempate por saldo (5 pontos)" (map time (drop 4 (classificacao partidas)))
    ["Gremio", "Sao Paulo"]
  testar "classificacao ate a rodada 3" (classificacao (ateRodada 3 partidas)) tabelaRodada3
  testar "rodada 3 diferente da final" (classificacao (ateRodada 3 partidas) /= tabelaFinal) True
  testar "saldo do Flamengo" (saldo (linhaDoTime partidas "Flamengo")) 4
  testar "aproveitamento do Flamengo" (umaCasa (aproveitamento (linhaDoTime partidas "Flamengo"))) "53.3"
  testar "aproveitamento de quem nao jogou" (aproveitamento (linhaDoTime [] "Flamengo")) 0
  testar "maior goleada" (maiorGoleada partidas) (Just (Partida 3 "Flamengo" 4 0 "Sao Paulo"))
  testar "media de gols" (fmap umaCasa (mediaGols partidas)) (Just "2.5")
  testar "maiorGoleada vazia" (maiorGoleada []) Nothing
  testar "mediaGols vazia" (mediaGols []) Nothing
  testar "classificacao vazia" (classificacao []) []


main :: IO ()
main = do
  camada1
  camada2
