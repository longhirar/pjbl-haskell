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




-- transforma uma linha em partida. O primeiro passo que falhar interrompe o resto
lerPartida :: Int -> String -> Either Erro Partida
lerPartida n texto = do
  (r, m, gm, gv, v) <- cincoCampos n texto
  rod   <- lerNumero n r
  exigir (rod > 0) (NumeroInvalido n r)
  golsM <- lerNumero n gm
  golsV <- lerNumero n gv
  exigir (golsM >= 0 && golsV >= 0) (PlacarNegativo n)
  exigir (m /= v) (MesmoTime n m)
  return (Partida rod m golsM golsV v)

-- numera as linhas e tira as vazias e os comentarios (#)
linhasUteis :: String -> [(Int, String)]
linhasUteis texto = filter (util . snd) (zip [1 ..] (lines texto))
  where
    util linha = case aparar linha of
      ""  -> False
      ('#' : _) -> False
      _  -> True

-- times que aparecem mais de uma vez na mesma rodada
repetidosNaRodada :: [Partida] -> [Erro]
repetidosNaRodada partidas = map virarErro (filter repetido (nub escalados))
  where
    escalados = foldr (\p juntados -> (rodada p, mandante p) : (rodada p, visitante p) : juntados) [] partidas
    repetido par = length (filter (== par) escalados) > 1
    virarErro (r, t) = TimeRepetidoNaRodada r t

-- le o texto inteiro, parando no primeiro erro
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasUteis texto)
  maybe (Right partidas) Left (listToMaybe (repetidosNaRodada partidas))

-- lista todos os erros do texto, nao so o primeiro
todosOsErros :: String -> [Erro]
todosOsErros texto = lefts leituras ++ repetidosNaRodada (rights leituras)
  where
    leituras = map (uncurry lerPartida) (linhasUteis texto)

