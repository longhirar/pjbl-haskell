module Dados where 

dadosCampeonato :: String 
dadosCampeonato = unlines  -- unlines várias linhas em um testo só
  [ "# rodada;mandante;gols mandante;gols visitante;visitante",
   "1;Flamengo;2;1;Internacional",
    "1;Palmeiras;3;0;Gremio",
    "1;Corinthians;0;0;Sao Paulo",
    "",
    "2;Flamengo;1;1;Gremio",
    "2;Internacional;2;0;Sao Paulo",
    "2;Palmeiras;1;2;Corinthians",
    "",
    "3;Flamengo;4;0;Sao Paulo",
    "3;Gremio;2;2;Corinthians",
    "3;Internacional;0;1;Palmeiras",
    "",
    "4;Flamengo;0;1;Corinthians",
    "4;Sao Paulo;1;1;Palmeiras",
    "4;Gremio;1;0;Internacional",
    "",
    "5;Flamengo;2;2;Palmeiras",
    "5;Corinthians;1;3;Internacional",
    "5;Sao Paulo;2;1;Gremio"
  ]
