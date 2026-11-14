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

