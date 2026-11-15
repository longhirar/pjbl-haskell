module Classificacao where
import Tipos
import Data.List (sortBy)
import Data.Ord (comparing, Down (..))

-- funcao que define a pontuação
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

linhaVazia :: Time -> Linha
linhaVazia t = Linha t 0 0 0 0 0 0

somarPartida :: Time -> Linha -> Partida -> Linha
somarPartida t l p = case resultadoPara t p of
  Nothing  -> l
  Just res -> l { jogos      = jogos l + 1,
                 vitorias   = vitorias l + contar Vitoria res,
                 empates    = empates l + contar Empate res,
                 derrotas   = derrotas l + contar Derrota res,
                 golsPro    = golsPro l + feitos,
                 golsContra = golsContra l + sofridos
                }
        where
            feitos
                | mandante p == t = golsMandante p
                | otherwise       = golsVisitante p
            sofridos
                | mandante p == t = golsVisitante p
                | otherwise       = golsMandante p

contar :: Resultado -> Resultado -> Int
contar esperado res = if res == esperado then 1 else 0


linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t = foldl (somarPartida t) (linhaVazia t) (filter (participou t) partidas)


pontosLinha :: Linha -> Int
pontosLinha l = vitorias l * (pontos Vitoria) + empates l * (pontos Empate) +  derrotas l * (pontos Derrota)     

saldo :: Linha -> Int
saldo l =  golsPro l - golsContra l

-- funcao de aproveitamento quanto % dava  pra aproveitar e quando foi aproveitado 
-- pontos ganho / jogos * 3 (nao usar div)
aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise    =  100 * fromIntegral (pontosLinha l) / fromIntegral (jogos l * 3)

-- montar a tabelinha de classificacao
classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy criterios (map (linhaDoTime partidas) (times partidas))

-- criterios de desempate tomando como base o que tem no Brasileirão
criterios :: Linha -> Linha -> Ordering
criterios = comparing (Down . pontosLinha)
         <> comparing (Down . vitorias)
         <> comparing (Down . saldo)
         <> comparing (Down . golsPro)
         <> comparing (time)


-- so as partidas ate a rodada até um certo momento
ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n partidas = filter (\p -> rodada p <= n) partidas

-- diferenca de gols de uma partida (sempre positiva)
diferenca :: Partida -> Int
diferenca p = abs (golsMandante p - golsVisitante p)

-- a partida com a maior diferenca de gols usando o Nothing se nao tiver partidas
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada partidas = foldr maior Nothing partidas
  where
    maior p Nothing = Just p
    maior p (Just q)
      | diferenca p >= diferenca q = Just p
      | otherwise                  = Just q

-- media de gols por partida; Nothing se nao tiver partidas
mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols partidas = Just (fromIntegral totalGols / fromIntegral (length partidas))
  where
    totalGols = sum (map (\p -> golsMandante p + golsVisitante p) partidas)