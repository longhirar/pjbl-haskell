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

-- largura de cada coluna da tabela
larguras :: [Int]
larguras = [5, 15, 5, 4, 4, 4, 4, 5]

-- completa um texto com espacos ate a largura da coluna
alinhar :: Int -> String -> String
alinhar n s = s ++ replicate (n - length s) ' '

juntarColunas :: [String] -> String
juntarColunas colunas = concat (zipWith alinhar larguras colunas)

-- a tabela pronta para imprimir
tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (cabecalho : zipWith formatar [1 :: Int ..] linhas)
  where
    cabecalho = juntarColunas ["Pos", "Time", "P", "J", "V", "E", "D", "SG"]
    formatar pos l =
      juntarColunas
        [ show pos ++ ".",
         time l,
         show (pontosLinha l),
         show (jogos l),
         show (vitorias l),
         show (empates l),
         show (derrotas l),
         show (saldo l)
        ]

-- uma partida em texto, ex.: "rodada 3: Flamengo 4 x 0 Sao Paulo"
descreverPartida :: Partida -> String
descreverPartida p =
  "rodada " ++ show (rodada p) ++ ": " ++ mandante p ++ " "
    ++ show (golsMandante p) ++ " x " ++ show (golsVisitante p) ++ " " ++ visitante p

-- mensagem legivel para cada erro
descreverErro :: Erro -> String
descreverErro (CamposInvalidos n texto) =
  "linha " ++ show n ++ ": esperava 5 campos separados por ';', veio \"" ++ texto ++ "\""
descreverErro (NumeroInvalido n texto) =
  "linha " ++ show n ++ ": \"" ++ texto ++ "\" nao e um numero valido"
descreverErro (PlacarNegativo n) =
  "linha " ++ show n ++ ": o placar nao pode ser negativo"
descreverErro (MesmoTime n t) =
  "linha " ++ show n ++ ": " ++ t ++ " nao pode jogar contra si mesmo"
descreverErro (TimeRepetidoNaRodada r t) =
  "rodada " ++ show r ++ ": " ++ t ++ " jogou mais de uma vez"

-- mostra um Double com uma casa decimal (ex.: 66.7)
umaCasa :: Double -> String
umaCasa x = show (fromIntegral (round (x * 10) :: Integer) / 10 :: Double)