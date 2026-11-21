# Decisões de modelagem e limitações

## Camada 1: tipos

Partida e Linha como records: usamos records em vez de tuplas porque cada campo tem nome. Numa tupla como (Int, String, Int, Int, String), trocar os gols do mandante com os do visitante compila sem erro, porque os dois são Int. Com campos nomeados (golsMandante, golsVisitante) esse erro fica bem mais difícil.

Resultado como tipo soma: vitoria, Empate e Derrota são os únicos valores possíveis. Se fosse uma String ("V", "E", "D"), um "v" minúsculo passaria pelo compilador sem ninguém perceber.

resultadoPara devolve Maybe: Um time que não jogou a partida não tem resultado, então devolvemos Nothing. Assim quem chama a função é obrigado a tratar esse caso.

Função auxiliar comparar: a comparação de gols é sempre a mesma (os meus contra os do adversário). Por isso criamos a função comparar e o resultadoPara só inverte a ordem dos gols quando o time é o visitante. Isso evitou repetir as três comparações duas vezes.

times com foldr: usamos um foldr para juntar os nomes de todas as partidas e outro foldr com elem para tirar as repetições, que são conceitos vistos em aula. Para a ordem alfabética usamos o sort da Data.List, porque escrever uma ordenação à mão exigiria recursão.

Linha guarda só os dados brutos: linha tem jogos, vitórias, empates, derrotas, gols pró e gols contra. Pontos, saldo e aproveitamento não ficam guardados: são calculados por funções. Assim esses valores nunca ficam diferentes dos dados.

## Camada 2: classificação

linhaDoTime com foldl: a linha de um time é montada somando as partidas uma por uma, a partir de uma linha zerada (linhaVazia). Escolhemos o foldl porque ele lê a lista da primeira partida para a última, como quem vai preenchendo a tabela rodada a rodada, e a função somarPartida recebe primeiro o acumulado (a linha) e depois a partida, que é a ordem que o foldl usa. Antes do foldl, um filter deixa só as partidas em que o time jogou.

somarPartida usa o resultadoPara: com um case sobre o Maybe: se for Nothing a linha volta igual, se for Just res soma o jogo, o resultado e os gols. A função auxiliar contar devolve 1 ou 0 para somar na vitória, no empate ou na derrota.

pontosLinha usa a função pontos: em vez de escrever 3, 1 e 0 de novo, reaproveitamos a função pontos. Se o valor da vitória mudar, basta mudar um lugar. (a pontuação foi com base no sistema do Campeanato do Brasileirão)

aproveitamento com fromIntegral: usar div daria 0 em muitos casos, porque div corta a parte decimal. Por isso convertemos os inteiros com fromIntegral e dividimos com /. Se o time não jogou, o aproveitamento é 0, para não dividir por zero. (como indicado no doc)

Critérios de desempate: seguimos os critérios do Brasileirão: pontos, vitórias, saldo de gols e gols pró. Por último usamos o nome do time, só para a ordem nunca ficar indefinida. Os critérios estão numa função só (criterios), juntados com o operador <>: o segundo critério só é usado quando o primeiro empata. O Down inverte a ordem para o maior valor ficar primeiro.

O campeonato de teste mostra o desempate: flamengo, Palmeiras e Corinthians terminam com 8 pontos e 2 vitórias, e quem decide é o saldo de gols (+4, +3 e 0). Gremio e Sao Paulo terminam com 5 pontos e 1 vitória, e também são separados pelo saldo (-3 e -5).

Funções que não quebram com lista vazia: maiorGoleada usa um foldr com Maybe em vez de maximum, que dá erro com lista vazia. mediaGols trata a lista vazia primeiro e devolve Nothing. Assim um campeonato sem partidas não derruba o programa.

Sem recursão explícita: Toda a camada usa map, filter, foldl, foldr, composição com (.) e sortBy com comparing.

## Camada 3: leitura e validação

lerPartida com do na mônada Either: cada etapa (separar os campos, ler os números, conferir o placar e conferir os times) pode falhar com um Left, e o primeiro Left interrompe o resto. Isso evita vários case um dentro do outro.

readMaybe em vez de read: um placar como "dois" vira Nothing e depois um erro NumeroInvalido, em vez de derrubar o programa com uma exceção.

lerCampeonato com traverse: o traverse aplica o lerPartida em todas as linhas e para no primeiro erro. Depois disso conferimos se algum time jogou duas vezes na mesma rodada.

todosOsErros: Lê todas as linhas, junta os erros com lefts e confere as rodadas só com as partidas que foram lidas sem erro (rights).

Cada Erro guarda onde foi o problema: os erros de linha guardam o número da linha, e o TimeRepetidoNaRodada guarda a rodada, porque esse problema envolve mais de uma linha.

Só o main tem IO: os dados ficam numa String no Dados.hs e todas as outras funções são puras. Por isso o programa funciona sem teclado e os testes podem chamar as funções diretamente.

## Limitações conhecidas

- Não tem confronto direto. O Brasileirão usa o confronto direto como critério de desempate, mas ele precisa olhar as partidas entre dois times específicos, o que não cabe numa comparação simples entre duas Linhas. No lugar dele usamos a ordem alfabética.
- Os nomes são comparados exatamente como foram escritos. "Flamengo" e "flamengo" contam como times diferentes, e um nome digitado errado vira um time novo.
- Os nomes não têm acento (Sao Paulo, Gremio), para evitar problemas de codificação no terminal do Windows.
- O calendário não é conferido. O programa não verifica se todos os times jogaram o mesmo número de vezes nem se um confronto se repetiu em rodadas diferentes.
- Rodada zero ou negativa é tratada como NumeroInvalido, porque o enunciado não tem um erro específico para isso.
- Algumas funções comparam todos os itens entre si (tirar repetições no times e achar times repetidos na rodada). Para um campeonato pequeno isso é rápido, mas ficaria lento com milhares de partidas.