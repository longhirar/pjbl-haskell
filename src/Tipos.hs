module Tipos where
import Data.List (sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)

data Partida = Partida{
     rodada        :: Int,
     mandante      :: Time,
     golsMandante  :: Int,
     golsVisitante :: Int,
     visitante     :: Time

}deriving (Show, Eq)  

data Linha = Linha{
    time :: Time,
    jogos :: Int,
    vitorias :: Int,
    empates :: Int,
    derrotas :: Int,
    golsPro :: Int,
    golsContra :: Int 
}deriving(Show, Eq)

-- funcao que verifica se um time participou de uma partida e retorna um Bool
-- time partida Bool

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

-- funcao que verifica a derrota, empate e Vitoria
comparar :: Int -> Int -> Resultado
comparar m v
        |m > v   = Vitoria
        |m == v   = Empate
        | otherwise = Derrota


-- Resultado da partida com um maybe para tratar de casos de times que não jogaram
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
         | t == mandante p  = Just (comparar (golsMandante p) (golsVisitante p))
         | t == visitante p = Just (comparar (golsVisitante p) (golsMandante p))
         | otherwise = Nothing 

times :: [Partida] -> [Time]
times partidas = sort semRepetir
  where
    nomes      = foldr (\partida juntados -> mandante partida : visitante partida : juntados) [] partidas
    semRepetir = foldr (\nome unicos -> if nome `elem` unicos then unicos else nome : unicos) [] nomes