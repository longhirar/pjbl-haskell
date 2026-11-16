module Leitura where
import Data.Char (isSpace)
import Data.Either (lefts, rights)
import Data.List (dropWhileEnd, nub)
import Data.Maybe (listToMaybe)
import Text.Read (readMaybe)
import Tipos
import Classificacao (pontosLinha, saldo)

-- os tipos de erro que podem aparecer na leitura, funcao guarda onde teve e qual o erro
data Erro
  = CamposInvalidos Int String
  | NumeroInvalido Int String
  | PlacarNegativo Int
  | MesmoTime Int Time
  | TimeRepetidoNaRodada Int Time
  deriving (Show, Eq)

-- quebra uma linha nos separadores
separar :: Char -> String -> [String]
separar sep texto = foldr passo [""] texto
  where
    passo letra (atual : resto)
      | letra == sep = "" : atual : resto
      | otherwise = (letra : atual) : resto
    passo _ [] = [""]

--funcao para tirar os espacos do comeco e do fim de um texto
aparar :: String -> String
aparar = dropWhileEnd isSpace . dropWhile isSpace

--converter um texto em numero com readMaybe, se nao for numero, vira erro
lerNumero :: Int -> String -> Either Erro Int
lerNumero n s = maybe (Left (NumeroInvalido n s)) Right (readMaybe s)

-- se a condicao for falsa, devolve o erro
exigir :: Bool -> Erro -> Either Erro ()
exigir True _  = Right ()
exigir False erro = Left erro

-- confere se a linha tem exatamente 5 campos e se os times nao estao vazios
cincoCampos :: Int -> String -> Either Erro (String, String, String, String, String)
cincoCampos n texto = case map aparar (separar ';' texto) of
  [r, m, gm, gv, v] | not (null m), not (null v) -> Right (r, m, gm, gv, v)
  _ -> Left (CamposInvalidos n texto)

