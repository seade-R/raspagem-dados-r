# Tutorial 8

## Apresentação

Nos atividades anteriores utilizamos as ferramentas básicas de captura de dados disponíveis na biblioteca _rvest. Em primeiro, aprendemos a capturar várias páginas contendo tabelas em formato html de uma só vez. Depois, aprendemos como um documento XML está estruturado e que podemos a extrair com precisão os conteúdos de nodes e os valores dos atributos dos nodes de páginas escritas em HTML.

Neste tutorial vamos colocar tudo em prática e construir um banco de dados de notícias. O nosso exemplo será o conjunto de notícias (725 na data da construção deste tutorial) publicadas sobre eleições no site do instituto de pesquisa DataFolha. Ainda que o DataFolha não seja um portal, por estar vinculado ao jornal Folha de São Paulo e ao portal UOL, a busca do DataFolha se assemelha muito às ferramentas de busca destes últimos.

Clique no [link](https://search.folha.uol.com.br/search?q=elei%C3%A7%C3%B5es&site=datafolha%2Feleicoes&skin=datafolha) e veja como está estruturada a busca do DataFolha sobre eleições:

## Raspando uma notícia no site DataFolha

Antes de começar, vamos carregar a biblioteca _rvest_ para tornar suas funções disponíveis em nossa sessão do R. Na carona, vamos carregar também o pacote _tidyverse_.

```{r}
library(rvest)
library(tidyverse)
```

Nossa primeira tarefa será escolher uma única notícia (a primeira da busca, por exemplo), e extrair dela 4 informações de interesse: o título da notícia; a data e hora da notícia; o link para a pesquisa completa em .pdf; e o texto da notícia.

O primeiro passo é criar um objeto com endereço URL da notícia e outro que contenha o código HTML da página:

```{r}
url_noticia <- "https://datafolha.folha.uol.com.br/eleicoes/2021/09/1989342-alckmin-e-haddad-lideram-cenarios-para-disputa-pelo-governo-de-sp.shtml"
pagina <- read_html(url_noticia)
```

Pronto! Agora temos um objeto adequadamente identificado como XML pelo R. Com o objeto XML preparado e representando a página com a qual estamos trabalhando, vamos à caça das informações que queremos.

Volte para a página da notícia. Procure o título da notícia e examine-o, inspencionando o código clicando com o botão direito do mouse e selecionando "Inspecionar". Note o que encontramos:

```{xml}
<h1 class="main_color main_title"><!--TITULO-->Alckmin e Haddad lideram cenários para disputa pelo governo de SP<!--/TITULO--></h1>
```

Tente sozinha ou sozinho e por aproximadamente 1~2 minutos construir o "xpath" (caminho em XML) que nos levaria a este elemento antes de avançar.

A resposta é:

```{xml}
//h1[@class = 'main_color main_title']
```

Usando agora as funções _html\_nodes_ e _html\_text_, como vimos no tutorial anterior, vamos capturar o título da notícia:

```{r}
node_titulo <- html_nodes(pagina, xpath = "//h1[@class = 'main_color main_title']")
titulo <- html_text(node_titulo)
print(titulo)
```

Simples, não? Repita agora o mesmo procedimento para data e hora (tente sozinha ou sozinho antes de copiar a resposta abaixo!):

```{r}
node_datahora <- html_nodes(pagina, xpath = "//time")
datahora <- html_text(node_datahora)
print(datahora)
```

E também para o link do .pdf disponibilizado pelo DataFolha com o conteúdo completo da pesquisa -- dica: o link é o valor do atributo "href" da tag "a" que encontramos ao inspecionar o botão para donwload:

```{r}
node_pdf <- html_nodes(pagina, xpath = "//p[@class = 'stamp download']/a")
link_pdf <- html_attr(node_pdf, name = "href")
print(link_pdf)
```

Finalmente, peguemos o texto. Note que o texto está dividido em vários parágrafos cujo conteúdo está inseridos no node "p", todas filhas do node "article". Se escolhemos o xpath sem especificar a tag "p" ao final, como abaixo, capturamos um monte de "sujeira", como os botões de twitter e facebook. Por esta razão, vamos especificar o node "p" ao final do xpath. Neste caso, recebemos um vetor contendo cada um dos parágrafos do texto. Precisaríamos "juntar" (concatenar) todos os parágrafos para formar um texto único. Faremos isso a seguir.

```{r}
node_texto <- html_nodes(pagina, xpath = "//article[@class = 'news']/p")
texto <- html_text(node_texto)
print(texto)
```

A função _paste_ (que é igual _paste0_, mas tem por padrão deixar espaço entre os textos "colados") permite juntarmos todos os textos de um vetor do tipo "character" em um só utilizando o argumento "collapse". Vamos, assim, juntar todos os parágrafos com _paste_ separando-os por um espaço simples:

```{r}
texto <- paste(texto, collapse = " ")
```

## A notícia seguinte na busca do DataFolha

Tente agora raspar a notícia seguinte usando a mesma estratégia. É fundamental notar que variamos a notícia, mas as informações continuam tendo o mesmo caminho. Essa é a propriedade fundamental do portal raspado que nos permite obter todas as notícias sem nos preocuparmos em abrir uma por uma. O link para a próxima notícia está no objeto "url" abaixo:

```{r}
url_noticia <- "https://datafolha.folha.uol.com.br/eleicoes/2021/09/1989339-a-um-ano-da-eleicao-disputa-presidencial-tem-lula-na-lideranca-e-bolsonaro-em-segundo.shtml"
```

## Download de arquivos

Por vezes, queremos fazer donwload de um arquivo cujo link encontramos na página raspada. Por exemplo, no datafolha seria interessante obter o relatório em .pdf da pesquisa (para extrair seu conteúdo no futuro, por exemplo). Vamos ver como fazer download de um arquivo online.

Em primeiro lugar, obtemos seu endereço url, como acabamos de fazer com a notícia que capturamos na busca do DataFolha (tente ler o código e veja se o entende por completo):

```{r}
library(rvest)
url_noticia <- "https://datafolha.folha.uol.com.br/eleicoes/2021/09/1989339-a-um-ano-da-eleicao-disputa-presidencial-tem-lula-na-lideranca-e-bolsonaro-em-segundo.shtml"
pagina <- read_html(url_noticia)
node_pdf <- html_nodes(pagina, xpath = "//p[@class = 'stamp download']/a")
link_pdf <- html_attr(node_pdf, name = "href")
```

O link está no objeto "pesquisa":

```{r}
print(link_pdf)
```

Usando a função _download.file_, rapidamente salvamos o link no "working directory" e com o nome "pesquisa.pdf", tal como fizemos no primeiro tutorial do curso:

```{r}
download.file(link_pdf, "pesquisa.pdf")
```

Sempre que estiver em posse de um conjunto de links que contém arquivos, você pode colocar a função "download.file" em loop e capturar todos os objetos ao mesmo tempo. Há uma dificuldade boba: nomear sem repetir os nomes diversos arquivos. Uma dica é usar o final do endereço URL como nome, mas você pode salvar os arquivos com nomes que sejam uma sequência numérica ou que provenham de um vetor que contenha os nomes todos. Use a criatividade!

Vamos voltar agora às notícias do DataFolha em html e ignorar o donwload de arquivos com os relatórios das pesquisas.

## Um código, duas etapas: raspando todas as notícias de eleições do DataFolha

Vamos fazer um breve roteiro do que precisamos fazer para criar um banco de dados que contenha todos os títulos, data e hora e texto de todas as notícias sobre eleições do DataFolha (Obs: por enquanto vamos ignorar os links de pesquisa, pois nem todas as notícias contêm os links e isso causa interrupção do código)

### Etapa 1
* Passo 1: conhecer a página de busca (e compreender como podemos "passar" de uma página para outra)
* Passo 2: raspar (em loop!) as páginas de busca para obter todos os links de notícia

Esta é a primeira etapa da captura. Em primeiro lugar temos que buscar todos os URLs que contêm as notícias buscadas. Em outras palavras, começamos obtendo "em loop" os links das notícias e, só depois de termos os links, obtemos o conteúdo destes links. Nossos passos seguintes, portanto, são:

### Etapa 2
* Passo 3: conhecer a página da notícia (e ser capaz de obter nela as informações desejadas). Já fizemos isso acima!
* Passo 4: raspar (em um novo loop!) o conteúdo dos links capturados no Passo 2.

Vamos construir o código da primeira etapa da captura e, uma vez resolvida a primeira etapa, faremos o código da segunda.

### Código da etapa 1

AVISO: Esse código é bastante semelhante ao código do tutorial anterior!

Comecemos criando o URL base sem a numeração de notícias:

```{r}
url_base <- "https://search.folha.uol.com.br/search?q=elei%C3%A7%C3%B5es&site=datafolha%2Feleicoes&periodo=todos&skin=datafolha&results_count=725&search_time=0%2C200&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Delei%25C3%25A7%25C3%25B5es%26site%3Ddatafolha%252Feleicoes%26periodo%3Dtodos%26skin%3Ddatafolha&sr="
```

Em segundo lugar, vamos observar o URL da página de busca (poderíamos buscar termos chave, mas, neste caso, vamos pegar todas as notícias relacionadas a eleições). Na página 2 da busca vemos que o final é "sr=26". Na página 3 o final é "sr=51". Há um padrão: as buscas são realizadas de 25 em 25. De fato, a 23a. é última página da busca. Para "passarmos" de página em página, portanto, temos que ter um "loop" que conte não mais de 1 até 23, mas na seguinte sequência numérica: {1, 26, 51, 76, ..., 676, 701}.

Precisamos, então, que "i" seja recalculado dentro do loop para coincidir com a numeração da primeira notícia de cada página. Parece difícil, mas é extremamente simples. Veja o loop abaixo, que imprime a sequência desejada multiplicando (i - 1) por 25 e somando 1 ao final:

```{r}
for (i in 1:29){
  i <- (i - 1) * 25 + 1
  print(i)
}
```

Precisamos agora é incluir nas "instruções do loop". Assim, construímos o url de cada página do resultado da busca:

```{r}
i = 26
url_pesquisa <- paste(url_base, i, sep = "")
```

A seguir, capturamos o código HTML da página:

```{r}
pagina <- read_html(url_pesquisa)
```

Escolhemos apenas os "nodes" que nos interessam:

```{r}
nodes_titulos <- html_nodes(pagina, xpath = "//h2/a")
```

Extraímos os títulos e os links com as funções apropriadas:

```{r}
titulos <- html_text(nodes_titulos)
links <- html_attr(nodes_titulos, name = "href")
```

Combinamos os dois vetores em um data frame:

```{r}
tabela_titulos <- data.frame(titulos, links)
```

Falta "empilhar" o que produziremos em cada iteração do loop de uma forma que facilite a visualização. Criamos um objeto vazio antes do loop. 

```{r}
dados_pesquisa <- NULL
```

E dentro do loop acrescentamos a este objeto o resultado de cada página de busca:

```{r}
dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
```

Chegou o momento de colocar dentro loop tudo o que queremos que execute em cada uma das vezes que ele ocorrer. Ou seja, que imprima na tela a página que está executando, que a url da página de resultados seja construída com a função paste, para todas elas o código html seja examinado, lido no R e transformado em objeto XML, colete todos os links e todos os títulos e que "empilhe". Lembrando que não podemos esquecer de definir a url que estamos usando e criar um data frame vazio para colocar todos os links e títulos coletados antes de iniciar o loop.

```{r}
library(tidyverse)
library(rvest)

url_base <- "https://search.folha.uol.com.br/search?q=elei%C3%A7%C3%B5es&site=datafolha%2Feleicoes&periodo=todos&skin=datafolha&results_count=725&search_time=0%2C200&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Delei%25C3%25A7%25C3%25B5es%26site%3Ddatafolha%252Feleicoes%26periodo%3Dtodos%26skin%3Ddatafolha&sr="

dados_pesquisa <- data_frame()

for (i in 1:29){
  
  print(i)

  i <- (i - 1) * 25 + 1
  
  url_pesquisa <- paste(url_base, i, sep = "")
  
  pagina <- read_html(url_pesquisa)
  
  nodes_titulos <- html_nodes(pagina, xpath = "//h2/a")
  
  titulos <- html_text(nodes_titulos)
  links <- html_attr(nodes_titulos, name = "href")
  
  tabela_titulos <- data.frame(titulos, links)
  
  dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
}

```
Pronto! Temos agora todos os títulos e links de todos os resultados de site do Data Folha para em um único banco de dados.

### Código da etapa 2

No começo do tutorial resolvemos a captura do título, data e hora, link para o relatório completo de pesquisa e texto para uma única notícia no portal do instituto DataFolha. Nos resta agora capturar, em loop, o conteúdo de cada uma das páginas cujos links estão guardados na coluna "links".

Vamos rever o procedimento, para uma url qualquer, da captura do título, data e hora e texto (vamos deixar o link para o relatório de pesquisa de lado por enquanto, posto que algumas notícias não contêm o link e esta pequena ausência interromperia o funcionamento do código).

```{r}
url_noticia <- "https://datafolha.folha.uol.com.br/eleicoes/2021/09/1989342-alckmin-e-haddad-lideram-cenarios-para-disputa-pelo-governo-de-sp.shtml"

pagina <- read_html(url_noticia)

node_titulo <- html_nodes(pagina, xpath = "//h1[@class = 'main_color main_title']")
titulo <- html_text(node_titulo)

node_datahora <- html_nodes(pagina, xpath = "//time")
datahora <- html_text(node_datahora)

node_texto <- html_nodes(pagina, xpath = "//article[@class = 'news']/p")
texto <- html_text(node_texto)
texto <- paste(texto, collapse = " ")
```

Observe o código abaixo, que imprime todos os 558 links cujo conteúdo queremos capturar. Note que a forma de utilizar o loop é ligeiramente diferente da que havíamos visto até então. No lugar de uma variável "i" que "percorre" um vetor numérico (1:23, por exemplo), temos uma variável "link" que recebe, a cada iteração, um endereço URL da notícia, em ordem.

Esses endereços estão armazenados na variável "links" do banco de dados que criamos na Etapa 1, "dados\_pesquisa". Assim, na primeira iteração temos que "link" será igual "dados\_pesquisa\$links[1]", na segunda "dados\_pesquisa\$link[2]" e assim por diante até a última posição do vetor "links_datafolha" -- no nosso caso a posição 558.

Obs: utilizamos o símbolo "\$" em R para identificar uma coluna em um data frame. Por exmplo, a coluna "links" em "dados\_pesquisa".

```{r}
for (link in dados_pesquisa$links){
  print(link)
}
```

Combinando os dois código, e criando um data frame "dados\_noticias" que é vazio antes do loop temos o código completo da captura. Tal como quando trabalhamos com tabelas, utilizando a função "bind_rows" para combinar o data frame que resultou da iteração anterior com a linha que combina o conteúdo armazenado em "titulo", "datahora" e "texto".

```{r}
dados_noticias <- data.frame()

for (link in dados_pesquisa$links){
  print(link)
  
  pagina <- read_html(link)
  
  node_titulo <- html_nodes(pagina, xpath = "//h1[@class = 'main_color main_title']")
  titulo <- html_text(node_titulo)
  
  node_datahora <- html_nodes(pagina, xpath = "//time")
  datahora <- html_text(node_datahora)
  
  node_texto <- html_nodes(pagina, xpath = "//article[@class = 'news']/p")
  texto <- html_text(node_texto)
  texto <- paste(texto, collapse = " ")
  
  tabela_noticia <- data_frame(titulo, datahora, link, texto)
  
  dados_noticias <- bind_rows(dados_noticias, tabela_noticia)

}
```

O resultado do código é um data frame ("dados\_noticias") que contém 4 variáveis em suas colunas: "titulo", "datahora", "link" e "texto". A partir de agora você poderia, por exemplo, usar as ferramentas de "text mining" para criar uma nuvem de palavras ("wordcloud"), fazer a contagem de termos, examinar a semelhança da linguagem usada pelo instituto DataFolha com a usada por outros institutos de opinião pública, fazer análise de sentimentos, etc.

Provavelmente o loop foi interrompido antes de concluirmos a raspagem das 725 notícias. Não tem problema para nosso exercício. Às vezes um url está com problema e não tem nada a ver com o código que construímos. Há maneiras de se lidar com isso, como veremos a seguir.

## Tarefa

Antes disso, sua tarefa é a seguinte: executar ambas as etapas do código e comentá-lo por completo (use # para inserir linhas de comentário). Comentar o código alheio é uma excelente maneira de ver se você conseguiu compreendê-lo por completo e serve para você voltar ao código no futuro quando for usá-lo de modelo para seus próprios projetos em R.

```{r}
library(tidyverse)
library(rvest)

url_base <- "https://search.folha.uol.com.br/search?q=elei%C3%A7%C3%B5es&site=datafolha%2Feleicoes&periodo=todos&skin=datafolha&results_count=725&search_time=0%2C200&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Delei%25C3%25A7%25C3%25B5es%26site%3Ddatafolha%252Feleicoes%26periodo%3Dtodos%26skin%3Ddatafolha&sr="

dados_pesquisa <- data_frame()

for (i in 1:29){
  
  print(i)
  
  i <- (i - 1) * 25 + 1
  
  url_pesquisa <- paste(url_base, i, sep = "")
  
  pagina <- read_html(url_pesquisa)
  
  nodes_titulos <- html_nodes(pagina, xpath = "//h2/a")
  
  titulos <- html_text(nodes_titulos)
  links <- html_attr(nodes_titulos, name = "href")
  
  tabela_titulos <- data.frame(titulos, links)
  
  dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
}

dados_noticias <- data.frame()

for (link in dados_pesquisa$links){
  print(link)
  
  pagina <- read_html(link)
  
  node_titulo <- html_nodes(pagina, xpath = "//h1[@class = 'main_color main_title']")
  titulo <- html_text(node_titulo)
  
  node_datahora <- html_nodes(pagina, xpath = "//time")
  datahora <- html_text(node_datahora)
  
  node_texto <- html_nodes(pagina, xpath = "//article[@class = 'news']/p")
  texto <- html_text(node_texto)
  texto <- paste(texto, collapse = " ")
  
  tabela_noticia <- data_frame(titulo, datahora, link, texto)
  
  dados_noticias <- bind_rows(dados_noticias, tabela_noticia)
  
}

View(dados_noticias)
```

## URL inexistente

Como vocês devem ter percebido, no momento do curso alguns urls de notícias do Data Folha estavam fora do ar ou deixaram de existir. Ao tentarmos capturar uma página inexistente, o código é interrompido. Como lidar com esse problema?

Vamos incluir uma cláusula de "tentativa" na captura da página com a função _try_. Veja um exemplo com um url inexistente:

```{r}
url_inexistente <- "http://datafolha.folha.uol.com.br/eleicoes/2018/10/42424242-leonardo-barone-e-eleito-senador-por-sao-paulo-com-record-de-votos.shtml"
pagina <- try(read_html(url_inexistente))
```

Quando o url não existe, com o uso da função "try" o código não é interrompido e o objeto "pagina", que deveria ser da classe "xml_document", passa a ser da classe "try-error"

```{r}
class(pagina)
```

Podemos, então, escrever uma cláusula condicional para evitar raspar esta página inexistente:

```{r}
if (!(class(pagina) %in% "try-error")){
  print("Página existente")
} else {
  print("Página inexistente")  
}
```

Pronto. Vamos adicionar uma cláusula condicional ao nosso programa completo e tentar novamente. Tente compreender como o código funciona. O resultado final, no momento da elaboração do tutorial, é de 725 notícias, das quais 717 são capturadas e 8 falham.

```{r}
library(tidyverse)
library(rvest)

url_base <- "https://search.folha.uol.com.br/search?q=elei%C3%A7%C3%B5es&site=datafolha%2Feleicoes&periodo=todos&skin=datafolha&results_count=725&search_time=0%2C200&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Delei%25C3%25A7%25C3%25B5es%26site%3Ddatafolha%252Feleicoes%26periodo%3Dtodos%26skin%3Ddatafolha&sr="

dados_pesquisa <- data_frame()

for (i in 1:29){
  
  print(i)
  
  i <- (i - 1) * 25 + 1
  
  url_pesquisa <- paste(url_base, i, sep = "")
  
  pagina <- read_html(url_pesquisa)
  
  nodes_titulos <- html_nodes(pagina, xpath = "//h2/a")
  
  titulos <- html_text(nodes_titulos)
  links <- html_attr(nodes_titulos, name = "href")
  
  tabela_titulos <- data.frame(titulos, links)
  
  dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
}

dados_noticias <- data.frame()

for (link in dados_pesquisa$links){
  print(link)
  
  pagina <- try(read_html(link))
  
  if (!(class(pagina) %in% "try-error")){
    node_titulo <- html_nodes(pagina, xpath = "//h1[@class = 'main_color main_title']")
    titulo <- html_text(node_titulo)
    
    node_datahora <- html_nodes(pagina, xpath = "//time")
    datahora <- html_text(node_datahora)
    
    node_texto <- html_nodes(pagina, xpath = "//article[@class = 'news']/p")
    texto <- html_text(node_texto)
    texto <- paste(texto, collapse = " ")
    
    tabela_noticia <- data_frame(titulo, datahora, link, texto)
    
    dados_noticias <- bind_rows(dados_noticias, tabela_noticia)
  } 
  
}

View(dados_noticias)
```
