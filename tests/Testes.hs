module Main where

import Tipos
import Classificacao
import Leitura
import Dados
import Data.List (nub)

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

-- desempate por vitorias: Zeta e Alfa terminam com 3 pontos.
-- Zeta (1V 0E 1D, saldo -2) fica na frente de Alfa (0V 3E 0D, saldo 0) so pelas
-- vitorias; pelo saldo ou pela ordem alfabetica Alfa ficaria na frente.
-- Delta e Omega empatam em 1 ponto e 0 vitorias, e o saldo decide (0 contra -1).
desempateVitorias :: [Partida]
desempateVitorias =
  [ Partida 1 "Zeta" 1 0 "Omega",
    Partida 1 "Alfa" 0 0 "Beta",
    Partida 2 "Zeta" 0 3 "Beta",
    Partida 2 "Alfa" 1 1 "Omega",
    Partida 3 "Alfa" 0 0 "Delta"
  ]

-- desempate por gols pro: Kappa, Tau, Gama e Rho empatam em 1 ponto, 0 vitorias e
-- saldo 0. Kappa e Tau fazem 2 gols, Gama e Rho nenhum. Pela ordem alfabetica
-- Gama ficaria na frente; so os gols pro colocam Kappa primeiro.
desempateGolsPro :: [Partida]
desempateGolsPro =
  [ Partida 1 "Kappa" 2 2 "Tau",
    Partida 1 "Gama" 0 0 "Rho"
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
  testar "desempate por vitorias: pontos iguais"
    (map (pontosLinha . linhaDoTime desempateVitorias) ["Zeta", "Alfa"]) [3, 3]
  testar "desempate por vitorias (3 pontos)"
    (map time (classificacao desempateVitorias))
    ["Beta", "Zeta", "Alfa", "Delta", "Omega"]
  testar "desempate por saldo (1 ponto, 0 vitorias)"
    (map saldo (drop 3 (classificacao desempateVitorias))) [0, -1]
  testar "desempate por gols pro (1 ponto, 0 vitorias, saldo 0)"
    (map time (classificacao desempateGolsPro))
    ["Kappa", "Tau", "Gama", "Rho"]
  testar "tabela alinhada com nome longo"
    (length (nub (map length (lines (tabelaFormatada
      [Linha "Atletico Mineiro Futebol Clube" 1 1 0 0 1 0,
       Linha "Sao Paulo" 1 0 0 1 0 1])))))
    1

camada3 :: IO ()
camada3 = do
  putStrLn "Camada 3\n"
  testar "separar" (separar ';' "1;Flamengo;2;1;Gremio") ["1", "Flamengo", "2", "1", "Gremio"]
  testar "lerCampeonato valido devolve Right" (fmap length (lerCampeonato dadosCampeonato)) (Right 15)
  testar "lerPartida valida" (lerPartida 1 "1;Flamengo;2;1;Gremio")
    (Right (Partida 1 "Flamengo" 2 1 "Gremio"))
  testar "erro CamposInvalidos" (lerPartida 7 "1;Flamengo;2")
    (Left (CamposInvalidos 7 "1;Flamengo;2"))
  testar "erro NumeroInvalido" (lerPartida 8 "1;Flamengo;dois;1;Gremio")
    (Left (NumeroInvalido 8 "dois"))
  testar "erro PlacarNegativo" (lerPartida 9 "1;Flamengo;-2;1;Gremio")
    (Left (PlacarNegativo 9))
  testar "erro MesmoTime" (lerPartida 10 "1;Flamengo;1;1;Flamengo")
    (Left (MesmoTime 10 "Flamengo"))
  testar "erro TimeRepetidoNaRodada" (lerCampeonato "1;Flamengo;1;0;Gremio\n1;Flamengo;2;2;Palmeiras\n")
    (Left (TimeRepetidoNaRodada 1 "Flamengo"))
  testar "lerCampeonato para no primeiro erro" (lerCampeonato dadosComErros)
    (Left (CamposInvalidos 3 "1;Palmeiras;3"))
  testar "todosOsErros lista todos os erros" (todosOsErros dadosComErros)
    [ CamposInvalidos 3 "1;Palmeiras;3"
    , NumeroInvalido 4 "dois"
    , PlacarNegativo 5
    , MesmoTime 6 "Palmeiras"
    , TimeRepetidoNaRodada 2 "Flamengo"
    ]
  testar "texto vazio" (lerCampeonato "") (Right [])
  testar "placar hexadecimal" (lerPartida 11 "1;Flamengo;0x2;1;Gremio")
    (Left (NumeroInvalido 11 "0x2"))
  testar "placar entre parenteses" (lerPartida 12 "1;Flamengo;(2);1;Gremio")
    (Left (NumeroInvalido 12 "(2)"))
  testar "placar notacao cientifica" (lerPartida 13 "1;Flamengo;1e1;1;Gremio")
    (Left (NumeroInvalido 13 "1e1"))
  testar "placar grande demais para Int"
    (lerPartida 14 "1;Flamengo;99999999999999999999;1;Gremio")
    (Left (NumeroInvalido 14 "99999999999999999999"))
  testar "so o sinal de menos" (lerPartida 15 "1;Flamengo;-;1;Gremio")
    (Left (NumeroInvalido 15 "-"))

main :: IO ()
main = do
  camada1
  camada2
  camada3