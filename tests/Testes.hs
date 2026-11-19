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


main :: IO ()
main = camada1
