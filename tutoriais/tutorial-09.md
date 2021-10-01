# Tutorial 9 - Formulários na web

Até agora trabalhamos com exemplos nos quais retiramos informação de páginas -- ou sequências de páginas -- em html, mas não enviamos nenhuma informação ao servidor com as quais estamos nos comunicando, exceto manualmente. Por exemplo, ao buscar notícias em um jornal, realizamos a busca manualmente e depois, com o url da busca construído, extraímos os resultados das buscas.

Entretanto, é muito comum nos depararmos com formulários em páginas que queremos raspar. Mecanismos de busca (Google, DuckDuckGo, etc) têm formulários nas suas páginas iniciais. Portais de notícia ou de Legislativos têm formulários de busca (como o que usamos manualmente no caso da Folha de São Paulo). Os campos de login e senha são formulários também. Formulários, na maioria das vezes, aparecerão como caixa(s) de consulta e botões acompanhados de um botão de submissão.

Neste tutorial vamos aprender a preencher um formulário, enviá-lo ao servidor da página e capturar sua resposta. Começaremos com um exemplo simples, como o buscador da Google, e depois faremos um exercício bastante mais complexo com o Scielo, portal de revistas científicas que congrega a maior parte das publicações brasileiras.

## _rvest_, formulários e Google 

Vamos começar carregando o pacotes _rvest_:

```{r}
library(rvest)
```

Nosso primeiro passo ao lidar com formulários será estabelecer uma conexão com o servidor, antes mesmo de capturar a página na qual o formulário está. Damos a essa conexão o nome de "session", e utilizamos a função _session_ para criá-la:

```{r}
google_url <- "https://www.google.com/"
google_session <- session(google_url)

```

Estabelecida a conexão, precisamos conhecer o formulário. Começamos, obviamente, obtendo o código HTML da página do formulário. Na sequência, vamos extrair do código da página os formulários -- é bastante comum que uma página contenha mais de um formulário. Como tabelas em HTML, tal qual vimos em tutoriais anteriores, formulários tem seus nodes próprias e contamos no pacote _rvest_ com uma função que extrai uma lista contendo todos os formulários da página:

```{r}
google_pagina <- read_html(google_session)

google_form_list <- html_form(google_pagina)

google_form_list
```

No caso do buscador da Google, há apenas um formulário na página. Com dois colchetes, extraímos o formulário que está na primeira posição da lista de formulários. Você verá que no caso do Scielo, obteremos mais de um formulário e precisaremos identificar qual queremos.

```{r}
google_form <- google_form_list[[1]]

class(google_form)

google_form
```

Examine o objeto que contém o formulário. Ele é um objeto da classe "rvest\_form" e podemos observar todos os parâmetros que o compõe, ou seja, tudo aquilo que pode ser preenchido para envio ao servidor, ademais dos botões de submissão.

Vá para o navegador e inspecione a caixa de busca da Google e os botões de busca e "Estou com sorte". Você observará que cada "campo" do formulário é um node "input". O atributo "type", define se será oculto ("hidden"), texto ("text") ou botão de submissão ("submit"). Por sua vez, o atributo "name" dá nome ao campo.

Alguns "inputs" já contêm valores pré-definidos (no atributo "values"). No nosso exemplo, é o caso dos botões e campos ocultos. Estes últimos já identificaram o idioma ("hl") e o enconding ("ie") com o qual trabalhamos.

O que nos interesse preencher, obviamente, é o "input" chamado "q". Em várias ferramentas de busca, "q" (acronismo para "query") é a caixa de texto onde fazemos a busca.

Vamos, então, preencher o campo "q" com a função "html\_form\_set":

```{r}
google_form <- html_form_set(google_form,
                          'q' = "seade")
```

Simples, não? Colocamos o objeto do formulário no primeiro parâmetro da função e os campos a serem preenchidos na sequência, tal como no exemplo.

Reexamine agora o formulário. Você verá que "q" está preenchido:

```{r}
google_form
```

Legal! Agora vamos fazer a submissão do formulário. No buscador da Google, há duas possibilidades de submissão. Vamos usar "Pesquisa Google" e não "Estou com sorte". Na "session\_submit", precismos informar a sessão que criamos (conexão com o servidor), o formulário que vamos submeter e o nome do botão de submissão -- se houver apenas um botão de submissão não precisamos desse parâmetro, que será identificado automaticamente. Veja o exemplo: 

```{r}
google_submission <- session_submit(x = google_session, 
                                    form = google_form, 
                                    submit = "btnG")
```

Pronto! Agora basta raspar o resultado como já haviámos feito antes. A página que queremos raspar é o objeto que resulta da função _session\_submit_. Abra o resultado de uma busca no Google e tente entender o código abaixo.

```{r}
titulos_nodes <- html_nodes(google_submission, xpath = "//h3")

titulos <- html_text(titulos_nodes)

links_nodes <- html_nodes(google_submission, xpath = "//a")

links <- html_attr(links_nodes, name = "href")

```

Obs: algumas coisas mudaram na busca do Google desde a última vez que testei este código. Os links do resultado vêm junto com diversas outros da página e poderíamos agora selecionar apenas os que interessam por alguns elementos em comum a eles. Mas, para descomplicar, vamos seguir para outro exemplo, pois já trabalhamos a extração de links em tutoriais anteriores e faremos novamente a seguir.


## Buscando artigos científicos na plataforma scielo

Vamos fazer um exemplo um pouco mais interessante e, ao mesmo tempo semelhante, ao do buscador da página principal da Google: buscar artigos científicos na plataforma Scielo.

Imagine uma situação em que em vez de um único termo de busca temos vários: "inteligência artificial", "aprendizado de máquina", "big data", etc. Ou, no contexto da PIESP, os termos "investimento", "empresas", "economia", etc. Se a lista for extensa, pode ser custoso demais construir o link da busca manualmente. Automatizar a submissão da busca é fundamental.

Antes de seguir, verifique se já carregou o pacote _rvest_. Carregue também o pacote _stringr_ que vamos utilizar para fazer limpeza e seleção de textos (no caso, dos textos dos links):

```{r}
library(rvest)
library(stringr)
```

A página de busca do Scielo é [https://search.scielo.org/](https://search.scielo.org/). Vamos guardá-la em um objeto de texto:

```{r}
scielo_url <- "https://search.scielo.org/"
```

E iniciar uma sessão:

```{r}
scielo_session <- session(scielo_url)
```

Vamos ler o conteúdo da página:

```{r}
scielo_pagina <- read_html(scielo_session)
```

E criar uma lista com todos os formulários:

```{r}
scielo_form_list <- html_form(scielo_pagina)

scielo_form_list
```

Examinando o resultado da lista, vemos que há 7 formulários na página. Precisamos decidir qual é o que nos interessa. Um primeiro formulário -- que para nós que vemos a página não parece formulário -- contém apenas uma parâmetro para o idioma da página (o Scielo tem versões em espanho e inglês). São, portanto, as bandeirinhas na parte superior direita da página. Clique com o botão direito e inspecione para encontrar um node "form" cujo atributo "name" é "language".


Os dois últimos formulários correspondem aos botões "Enviar por e-mail" e "Exportar" que vemos no topo da busca. Examine-os se quiser. Os demais 4 são formulários de busca por artigos, cada um correspondendo a um tipo de busca -- busca básica, busca com vários campos (booleana) ("Adicionar outro campo +") e outros 2 com filtros na barra lateral esquerda.

Vamos usar a busca básica, do formulário 2. Em primeiro lugar, criamos um objeto fora da lista que corresponde a apenas esse formulário e examinamos:

```{r}
scielo_form <- scielo_form_list[[2]]

scielo_form
```{r}

O campo principal de busca, tal como no formulário da Google, tem nome "q" (é comum os nomes se repetirem internet afora, mas não é necessário que sejam sempre os mesmos). Além deste campo, podemos definir um parâmetro de número de resultados por página com o parâmetro "count".

Como saber tudo isso? Bem, faça uma busca, observe o url, observe os campos do formulário e faça diversas tentativas. Um bocado do trabalho de construção de ferramentas raspagem e coleta de dados é feito dessa forma, tentando, errando, ajustando e repetindo. Antes de avançar, faça esse exercício: conheça o formulário, faça buscas, observe os campos visíveis, os nodes e o url dos resultados (lembre-se de sempre ir para a segunda página).

Pronto, se já gastou um tempo conhecendo o formulário podemos avançar. Vamos preencher dois campos do formulário: a busca ("q"), com o termo "seade"; e o número de resultados por página ("count"). Por padrão, a pesquisa do Scielo retorna 15 resultados. Vamos colocar 100 para poder pegar mais (na data da confecção do tutorial eram 79 resultados.


```{r}
scielo_form <- html_form_set(scielo_form,
                             'q' = "seade",
                             'count' = '100')
scielo_form
```

Veja que agora os campos estão preenchidos. Podemos, assim, submeter o formulário:


```{r}
scielo_submission <- session_submit(x = scielo_session, 
                                    form = scielo_form)
```

Note que omitimos o parâmetro "submit" no formulário acima. Não tinhamos conhecimento de qual era o nome dele, pois não aparecia nos campos do formulário. Ele é compartilhado com o 3o formulário da lista. Ainda assim, a submissão é feita normalmente.

Podemos agora pegar os resultados da busca:

```{r}
scielo_resultado <- read_html(scielo_submission)
```

Vamos pegar os títulos dos artigos como fizemos anteriormente. Veja se conseque entender o xpath:

```{r}
titulos_nodes <- html_nodes(scielo_resultado, xpath = '//div[@class = "line"]//a/strong')
titulos <- html_text(titulos_nodes)
titulos
```

E os links:

```{r}
links_nodes <- html_nodes(scielo_resultado, xpath = '//div[@class = "line"]//a')

links <- html_attr(links_nodes, name = "href")

links
```

Ops! Vieram muitos mais links do que desejávamos com o xpath. Nosso xpath não foi suficientemente preciso para chegarmos apenas nos 79 links dos artigos. Além disso, os urls se repetem.

Uma solução é vermos se os urls dos artigos têm alguma regularidade que os diferencia dos demais. Com auxílio do pacote _stringr_, que carregamos acima, podemos selecionar elementos de um vetor de texto, tal como é o vetor que contém os urls, a partir de uma expressão. Novamente, fazemos isso por inspeção e tentativa e erro. Note que todos os urls dos artigos contém os caracteres "sci_arttext". Fazemos a seleção:

```{r}
links <- str_subset(links, "sci_arttext")

links
```

Sobrarm ainda centenas urls e não somente os que desejávamos. Mas, observando o resultado, vemos que são repetições. Podemos eliminar as repetições de um vetor com a função "unique":

```{r}
links <- unique(links)

links
```

Pronto! Restaram apenas os urls do resultado! Vamos utilizá-los no próximo passo.


## Coleta do texto de um artigo científico


Vamos escolher um artigo qualquer (pode ser o primeiro) para examinar seu conteúdo. Com um colchete (e não dois, pois temos um vetor e não uma lista) observamos o primeiro url:

```{r}
links[1]
```

Copie o resultado e cole no navegador. Antes de avançar, gaste um tempo inspecionando a página para pensar e como podemos coletar todo o texto do artigo e sua referências bibliográficas (ou outra informação que desejar).

Textos em páginas de internet costumam ter seus parágrafos inseridos dentro de nodes "p". Este é o caso também nos artigos do Scielo. Fazendo rapidamente todos os passos temos:


```{r}
texto_url <- links[1]
texto_pagina <- read_html(texto_url)
texto_nodes <- html_nodes(texto_pagina, xpath = '//article//p')
texto <- html_text(texto_nodes)
```

O resultado é um vetor em que cada parágrafo do artigo está em uma posição:

```{r}
texto
```

Essa é uma maneira possível de organizar o conteúdo por artigo. Mas, como não nos interesse analisar parágrafos separadamente, vamos juntar todo o texto do artigo em um vetor de tamanho 1 usando parâmetro "collapse" da função "paste". Manteremos os textos separados por uma quebra de linha, representada pelo símbolo "\n"


```{r}
texto <- paste(texto, collapse = "\n")

texto
```

Aproveitando o código acima podemos pegar as referências do texto:


```{r}
referencias_nodes <- html_nodes(texto_pagina, xpath = '//div[@class = "ref-list"]//li//div')
referencias <- html_text(referencias_nodes)
```

Neste caso, parace conveniente deixar as referências como vetor em vez de juntá-las em um pedaço único de texto.

## Repetindo o procedimento para todos os artigos do resultado da busca:

Vamos coletar todos os parágrafos de todos os artigos e juntá-los em um único vetor. Vamos utilizar um "for loop". Em primeiro lugar, criamos um vetor vazio para receber todos os resultados:

```{r}
textos_scielo <- c()
```

E aproveitando o código da seção anterior fazemos o loop. Observe que o objeto _texto\_url_ agora recebe um url diferente a cada ciclo do loop e não mais o primeiro link. O resto do código é essencialmente o mesmo:

```{r}
for (link_artigo in links){

  texto_url <- link_artigo
  texto_pagina <- read_html(texto_url)
  texto_nodes <- html_nodes(texto_pagina, xpath = '//article//p')
  texto <- html_text(texto_nodes)
  texto <- paste(texto, collapse = "\n\n")
  
  textos_scielo <- c(textos_scielo, texto)
  
}
```

O resultado é o objeto textos_scielo, que contém um texto (grande) em cada posição. Este vetor tem o mesmo tamanho do vetor de links e de títulos. Não recomendo visualizá-lo no console, pois o RStudio fica lento quando "imprimimos" muito texto.

```{r}
length(textos_scielo)
```

Finalmente, vamos construir um data frame com os títulos, urls e textos:

```{r}
artigos_scielo <- data.frame(titulos, links, textos_scielo)
View(artigos_scielo)
```

O código completo da raspagem é, que utilizaremos possivelmente em um tutorial futuro é:

```{r}
library(rvest)
library(stringr)

scielo_url <- "https://search.scielo.org/"

scielo_session <- session(scielo_url)

scielo_pagina <- read_html(scielo_session)

scielo_form_list <- html_form(scielo_pagina)

scielo_form_list

scielo_form <- scielo_form_list[[2]]

scielo_form

scielo_form <- html_form_set(scielo_form,
                             'q' = "seade",
                             'count' = '100')

scielo_form

scielo_submission <- session_submit(x = scielo_session, 
                                    form = scielo_form)

scielo_resultado <- read_html(scielo_submission)

titulos_nodes <- html_nodes(scielo_resultado, xpath = "//h3")
titulos <- html_text(titulos_nodes)

links_nodes <- html_nodes(scielo_resultado, xpath = '//div[@class = "line"]//a')
links <- html_attr(links_nodes, name = "href")
links <- str_subset(links, "sci_arttext")
links <- unique(links)

textos_scielo <- c()

for (link_artigo in links){
  
  texto_url <- link_artigo
  texto_pagina <- read_html(texto_url)
  texto_nodes <- html_nodes(texto_pagina, xpath = '//article//p')
  texto <- html_text(texto_nodes)
  texto <- paste(texto, collapse = "\n\n")
  
  textos_scielo <- c(textos_scielo, texto)
  
}

artigos_scielo <- data.frame(titulos, links, textos_scielo)
View(artigos_scielo)
```

