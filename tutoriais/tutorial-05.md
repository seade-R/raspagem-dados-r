# Tutorial 5 - Capturando sequências de páginas

## Pacote _rvest_

Antes de começar, vamos carregar o pacote _rvest_, que utilizamos no Tutorial 2:

```{r}
library(rvest) 
```

## For loop e links com numeração de página

Vamos começar visitando o site da ALESP e entrar na ferramenta de pesquisa de proposições. Clique [aqui](http://www.al.sp.gov.br/alesp/pesquisa-proposicoes/) para acessar a página.

No site, vamos elaborar uma pesquisa qualquer que retorne uma quantidade de respostas que manualmente seria no mínimo ineficiente coletarmos. Por exemplo, podemos pesquisar por todas as proposições relacionados ao termo "seade".

O resultado da pesquisa é dividido em diversas páginas com 10 observações em cada uma. Há 4 informações sobre as proposições: data, título (e número do projeto/documento), autor e etapa.

Podemos prosseguir, clicando nos botões de navegação ao final da página, para as demais páginas da pesquisa. Por exemplo, podemos ir para a página 2 clicando uma vez na seta indicando à direita.

OBS: Há uma razão importante para começarmos nosso teste com a segunda página da busca. Em diversos servidores web, como este da ALESP, o link (endereço url) da primeira página é "diferente" dos demais. Em geral, os links são semelhantes da segunda página em diante.

Nossa primeira tarefa consiste em capturar estas informações. Vamos, no decorrer da atividade aprender bastante sobre R, objetos, estruturas de dados, loops e captura de tabelas em HTML.

Vamos armazenar a URL em um objeto ("url_base", mas você pode dar qualquer nome que quiser).

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=1&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="
```

Há muitas informações nesse link, basicamente todos os campos que poderiam ter sido especificados na busca são apresentados no endereço. Como preenchemos apenas com o termo ("seade"), esse será o único parametro definido na URL ("text=seade").

Também podemos observar que a pesquisa retornou 91 páginas ("lastPage=91") e que a página atual, que é a segunda página, é a de número 1 ("currentPage=1") -- a primeira página da pesquisa é numerada como 0 nesta ferramenta de busca, mas o padrão muda de página para página.

Podemos ver que há muitas páginas de resultado para a palavra-chave que utilizamos. Nosso desafio é conseguir "passar" de forma eficiente por elas, ou seja, acessar os 91 links e "raspar" o seu conteúdo. Para isso, usaremos uma função essencial na programação, o "for loop".

Loops são processos iterativos e são extremamente úteis para instruir o computador a repetir uma tarefa por um número finito de vezes. Por exemplo, vamos começar "imprimindo" na tela os números de 1 a 9:

```{r}
for (i in 1:9) {
  print(i)
}
```

Simples, não? Vamos ler esta instrução da seguinte maneira: "para cada número i no conjunto que vai de 1 até 9 (essa é a parte no parênteses) imprimir o número i (instrução entre chaves)". E se quisermos imprimir o número i multiplicado por 7 (o que nos dá a tabuada do 7!!!), como devemos fazer?

```{r}
for (i in 1:9) {
  print(i * 7)
}
```

Tente agora construir um exemplo de loop que imprima na tela os números de 3 a 15 multiplicados por 10 como exerício.

## Substituição com _gsub_

Ótimo! Já temos alguma intuição sobre como loops funcionam. Podemos agora fazer "passar" pelas páginas que contêm a informação que nos interessa. Temos que escrever uma pequena instrução que indique ao programa que queremos passar pelas páginas de 1 a 91, substituindo apenas o número da página atual -- "currentPage" -- no endereço URL que guardamos no objeto url_base.

Nos falta, porém, uma função que nos permita substituir no texto básico do URL ("url_base") os números das páginas.

Há mais de uma opção para realizar essa tarefa, mas aqui usaremos a função _gsub_. Com esta função podemos substituir um pedaço de um objeto de texto por outro, de acordo com o critério especificado.

Os argumentos (o que vai entre os parenteses) da função são, em ordem, o termo a ser substituído, o termo a ser colocado no lugar e o objeto no qual a substituição ocorrerá.

Na prática, ela funciona da seguinte forma:

```{r}
o_que_procuro_para_susbtituir <- "palavra"
o_que_quero_substituir_por <- "batata"
meu_texto <- "quero substituir essa palavra"

texto_final <- gsub(o_que_procuro_para_susbtituir, o_que_quero_substituir_por, meu_texto)

print(texto_final)
```

Agora que sabemos substituir partes de textos e fazer loops, podemos mudar o número da página do nosso endereço de pesquisa.

Descobrimos que na URL, o que varia ao clicar na próxima página é o "currentPage=1" que vai para "currentPage=2". Nesse caso é o "1" como segunda página e o "2" como terceira e assim por diante. Note que as páginas têm peculiaridades e, por isso, é importante conhecer a página que queremos "raspar". Captura de informações em páginas de internet, por esta razão, tem sempre um caráter "artesanal".

Vamos substituir na URL da página 2 da nossa busca o número por algo que "guarde o lugar" do número de página. Esse algo é um "placeholder" e pode ser qualquer texto arbitrário. No caso, escolheremos "NUMPAG", termo inventado por nós para ocupar o espaço do número da página. Veja abaixo onde "NUMPAG" foi introduzido no endereço URL. 

Obs: Lembremos que ao colocar na URL, não devemos usar as aspas. Ainda assim devemos usar aspas ao escrever "NUMPAG" como argumento de uma função, pois queremos dizer que procuramos a palavra "NUMPAG" e não o objeto chamado NUMPAG.

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="
```

Por exemplo, se quisermos gerar o link da página 6, podemos escrever:

```{r}
url_pagina <- gsub("NUMPAG", 6, url_base)

print(url_pagina)
```

Ou, em vez de usar um número diretamente na substituição, podemos usar uma variável que represente um número -- por exemplo a variável i, que já usamos no loop anteriormente.

```{r}
i = 6

url_pagina <- gsub("NUMPAG", i, url_base)

print(url_pagina)
```

Agora que temos o código substituindo funcionando, vamos implementar um loop para que as URLs das páginas sejam geradas automaticamente. Por exemplo, se quisermos "imprimir" na tela as páginas 0 a 5, podemos usar o seguinte código:

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="

for(i in 0:5){
  url_pagina <- gsub("NUMPAG", i, url_base)
  print(url_pagina)
}
```

## Capturando o conteúdo de uma página com _rvest_

Muito mais simples do que parece, não? Mas veja bem, até agora tudo que fizemos foi produzir um texto que, propositalmente, é igual ao endereço das páginas cujo conteúdo nos interessa. Porém, ainda não acessamos o seu conteúdo. Precisamos, agora, de funções que façam algo semelhante a um navegador de internet, ou seja, que se comuniquem com o servidor da página e recebam o seu conteúdo.

Para capturar uma página, ou melhor, o código HTML no qual a página está escrita, utilizamos a função _read\_html_, do pacote _rvest_, como vimos no Tutorial 2. Vamos repetir nosso exemplo da Wikipedia.

```{r}
url_wikipedia_regioes <- 'https://pt.wikipedia.org/wiki/Lista_de_regi%C3%B5es_metropolitanas_de_S%C3%A3o_Paulo_por_popula%C3%A7%C3%A3o'
pagina <- read_html(url_wikipedia_regioes)
class(pagina)
```

O resultado é um documento "xml_document" que contém o código html que podemos inspecionar usando o navegador. Vamos entender nos próximos tutoriais o que é um documento XML, por que páginas em HTML são documentos XML e como navegar por eles. Por enquanto, basta saber que ao utilizarmos _read\_html_, capturamos o conteúdo de uma página e o armezenamos em um objeto bastante específico.

## Função read_table

Nosso objetivo, uma vez que capturamos o conteúdo da página, é extrair de lá a tabela com as informações que nos interessam. Podemos fazer isso usando a função _read\_table_, contida no pacote _rvest_. Esta função serve bem ao nosso caso: ela recebe uma página capturada como argumento (ou melhor, um "xml\_document", como acabamos de ver), extrai todas (sim, todas) as tabelas da url, escritas em HTML, e retorna uma lista contendo as tabelas.

Vamos ver como ela funciona para a página 2 (ou seja, currentPage=1) contendo a tabela com os resultados em que aparecem o nosso termo pesquisado:

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="

i <- 1
url_pagina <- gsub("NUMPAG", i, url_base)

pagina <- read_html(url_pagina)

lista_tabelas <- html_table(pagina, header = TRUE)

print(lista_tabelas)
```

Simples não? Um pouco bagunçado, mas intuitivo. Geramos um endereço de URL e, com o endereço em mãos, capturamos o conteúdo da página usando o link como argumento da função _read\_html_ para, a seguir, extraírmos uma lista das tabelas da página. Antes de avançar, vamos falar um pouco sobre listas no R (pois o resultado da função _html\_table_ é uma lista).

Note que a função _html\_table_ tem um segundo argumento, "header = TRUE". Esse argumento serve para indicarmos ao nosso "extrator de tabelas HTML" que a primeira linha da tabela deve ser considerada cabeçalho e, portanto, servirá de nome às colunas da tabela.

## Listas

Um detalhe fundamental do resultado da função _html\_table_ é que o resultado dela é uma lista. Por que uma lista? Porque pode haver mais de uma tabela na página e cada tabela ocupará uma posição na lista. Para o R, uma lista pode combinar objetos de diversas classes: vetores, data frames, matrizes, etc.

Ao rasparmos o site da ALESP, a função _html\_table_ retorna várias tabelas e não apenas a dos resultados das proposições, que é o que queremos.

Como acessar objetos em uma lista? Podemos ulitizar colchetes. Porém, se utilizarmos apenas um colchete, obteremos uma sublista. Por exemplo, vamos criar diferentes objetos e combiná-los em uma lista:

```{r}
# Objetos variados
matriz <- matrix(c(1:6), nrow=2)
vetor_inteiros <- c(42:1)
vetor_texto <- c("a", "b", "c", "d", "e")
vetor_logico <- c(T, F, T, T, T, T, T, T, F)
texto <- "meu texto aleatorio"
resposta <- 42

minha_lista <- list(matriz, vetor_inteiros, vetor_texto, vetor_logico, texto, resposta)
print(minha_lista)
```

Para produzirmos uma sublista, usamos um colchete (mesmo que a lista só tenha um elemento!):

```{r}
print(minha_lista[1:3])
class(minha_lista[1:3])

print(minha_lista[4])
class(minha_lista[4])
```

Se quisermos usar o objeto de uma lista, ou seja, extraí-lo da lista, devemos usar dois colchetes:

```{r}
print(minha_lista[[4]])
class(minha_lista[[4]])
```

Ao obtermos uma lista de tabelas de uma página (nem sempre vai parecer que todos os elementos são tabelas, mas são, pelo menos para um computador que "lê" HTML), devemos utilizar dois colchetes para extrair a tabela que queremos. Exemplo (no nosso caso já sabemos que a tabela que queremos ocupa a posição 1 da lista, mas é necessário examinar sempre):

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="

i <- 1
url_pagina <- gsub("NUMPAG", i, url_base)

pagina <- read_html(url_pagina)

lista_tabelas <- html_table(pagina)

tabela <- lista_tabelas[[1]]

class(tabela)

View(tabela)
```

Bem mais bonito, não?

## Captura das tabelas

Podemos juntar tudo que vimos até agora: loop com a função "for", substituição com "gsub", captura de tabelas em HTML, listas e seus elementos.

Vamos tentar capturar as cinco primeiras páginas do resultado da pesquisa de proposições por meio da palavra-chave "seade". Para podermos saber que estamos capturando, vamos usar a função "head", que retorna as 6 primeiras linhas de um data frame, e a função "print".

Avance devagar neste ponto. Leia o código abaixo com calma e veja se entendeu o que acontece em cada linha. Já temos um primeiro script de captura de dados quase pronto e é importante estarmos seguros para avançar.

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="

for (i in 0:4) {
  
  url_pagina <- gsub("NUMPAG", i, url_base)
  
  pagina <- read_html(url_pagina)
  
  lista_tabelas <- html_table(pagina, header = TRUE)
  
  tabela <- lista_tabelas[[1]]
  
  print(head(tabela))
}
```

Vamos traduzir o que estamos fazendo: "para cada i de 0 a 4, vamos criar um link que é a combinação da URL base ('url_base') com i, vamos usar esta combinação ('url') como argumento da função _read\_html_ para capturar a página (e criar o objeto 'página'), vamos extrair a lista de tabelas da página com _html\_table_ (e criar a 'lista_tabelas'), vamos escolher a primeira tabela da lista (e criar 'tabela') e imprimir as 6 primeiras linhas da tabela de cada página".

Ufa! Leia de nova. Veja se entendeu o que aconteceu.

## Data Frames

Excelente, não? Mas e aí? Cadê os dados? O problema é que até agora ainda não fizemos nada com os dados, ou seja, ainda não guardamos eles em novos objetos para depois podermos utilizá-los na análise. 

Neste último passo, vamos fazer o seguinte: precisamos de uma estrutura que armazene as informações, então criamos um data frame vazio (chamado "dados") e, para cada iteração no nosso loop (ou seja, para cada "i"), vamos inserir a tabela da página i como novas linhas no nosso data frame. A função nova que precisamos se chama _bind\_rows_, que é parte do pacote _dplyr_, protagonista do _tidyverse_. Ela serve para unir diferentes data frames (ou vetores ou matrizes), colocando suas linhas uma debaixo da outra. Vamos carregar o pacote _tidyverse_ e vejamos um exemplo antes de avançar:

```{r}
library(tidyverse)
```


```{r}
# Criando 2 data frames separados
meus_dados1 <- data.frame("id" = 1:10, "Experimento" = rep(c("Tratamento"), 10))
print(meus_dados1)

meus_dados2 <- data.frame("id" = 11:20, "Experimento" = rep(c("Controle"), 10))
print(meus_dados2)

# Combinando os dois data.frames
meus_dados_completos <- bind_rows(meus_dados1, meus_dados2)
print(meus_dados_completos)
```

## Captura das tabelas com armazenamento em data frames

Pronto. Podemos agora criar um data frame vazio ("dados") e preenchê-lo com os dados capturados em cada iteração. O resultado final será um objeto com todas as tabelas de todas as páginas capturadas, que é o nosso objetivo central. Para rasparmos todas as páginas, faremos o loop de 0 a 90, pois são 91 páginas;

Obs: vamos inserir um "contador" das páginas capturadas com "print(i)". Isso será muito útil quando quisermos capturar um número grande de páginas, pois o contador nos dirá em qual iteração (sic, é sem "n" mesmo) do loop estamos.

```{r}
url_base <- "https://www.al.sp.gov.br/alesp/pesquisa-proposicoes/?direction=acima&lastPage=91&currentPage=NUMPAG&act=detalhe&idDocumento=&rowsPerPage=20&currentPageDetalhe=1&tpDocumento=&method=search&text=seade&natureId=&legislativeNumber=&legislativeYear=&natureIdMainDoc=&anoDeExercicio=&strInitialDate=&strFinalDate=&author=&supporter=&politicalPartyId=&stageId="

dados <- data.frame()

for (i in 0:90) {

  print(i)
  
  url_pagina <- gsub("NUMPAG", i, url_base)
  
  pagina <- read_html(url_pagina)
  
  lista_tabelas <- html_table(pagina, header = TRUE)
  
  tabela <- lista_tabelas[[1]]
  
  dados <- bind_rows(dados, tabela)
}
```

Vamos observar o resultado com a função View:

```{r}
View(dados)
```

São 3640 linhas, aproximadamente metade delas vazia, e 2 variáveis (título, autor). As 2 variáveis são do tipo "character" contêm as informações corretas. Poderíamos, agora, selecionar apenas as linhas com conteúdo:

```{r}
dados <- dados %>% filter(Autor != "")
```

Pronto! Conseguimos fazer nossa primeira captura de dados em uma sequência de páginas.
