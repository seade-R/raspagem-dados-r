# Tutorial 7

## Apresentação do problema

No tutorial anterior vimos como raspar da página de buscas de um portal de notícias todos os títulos e todos os links dos resultados da busca. Utilzamos, para tanto, os "caminhos" em html de cada um dos elementos na página.

No caso dos títulos, que são elementos visíveis na página, extraímos o conteúdo de um "node" utilizando a função _html\_text_. Para o url da notícia, por sua vez, precisamos da função _html\_attr_, pois o url é um atributo do título visível na página.

Vamos agora tentar repetir o que fizemos no Tutorial 5 com o exemplo da ALESP e, em vez de pegar apenas a primeira página do portal de notícias, vamos extrair todos os resultados da busca. Entretanto, em vez de utilizarmos a função _html\_table_ para pegar os resultados da tabela, vamos aproveitar o código que já construímos para extrair os títulos e urls do portal de notícias para para pegar o conteúdo de cada página de busca.

O primeiro passo é, mais uma vez, ter o nosso link da pesquisa que queremos coletar armazenado em um objeto. 

```{r}
url_folha <- "https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr=26&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"
```

## Função Paste

No exemplo da ALESP, o número da página era parte do url de busca. No caso de Folha de São Paulo, algo curioso acontece. Como o resultado é dado a cada 25 notícias, sabemos em qual página estamos pela posição da primeira notícia. No caso da página 1, vemos o texto 'sr=1' no meio do texto:

```{r}
"https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr=1&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"
```

Na página 2, por sua vez, "sr" é 26, pois a 26a notícia é a primeira da segunda página:

```{r}
"https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr=26&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"
```

No Tutorial 5 utilizamos a função "gsub" para construir o url de cada páginga de resultado da busca. Neste tutorial vamos fazer um pouco diferente e utilizar a função "paste0", que é semelhante à função "concatenar" de alguns editores de planilha.

Em primeiro lugar, vamos separar o url da busca em duas partes, uma antes e outra após o número

```{r}
url_base1 <- "https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr="

url_base2 <- "&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"
```

Dividimos o url em 2 partes e retiramos totalmente o número que identifica a primeira notícia. Agora vamos construir, como exemplo, o url da primeira página da busca com a função "paste0"

```{r}
i <- 1
url_folha <- paste0(url_base1, i, url_base2)
```

Para a página 2 teríamos:


```{r}
i <- 26
url_folha <- paste0(url_base1, i, url_base2)
```

Note que estamos sobrescrevendo os objetos "i" e "url_pesquisa" quando repetimos a operação.

## Coletando o conteúdo e o atributo de todos os links

A lógica de coleta do atributo e do conteúdo de um node continua o mesma. A única diferença é que precisamos aplicar isso para todas as páginas. Agora que sabemos constuir a url, podemos montar um "for loop" que fará isso para nós.

Antes de prosseguir, vamos observar o url da página de busca. Na página 2 da busca vemos que o final é "sr=26". Na página 3 o final é "sr=51". Há um padrão: as buscas são realizadas de 25 em 25. São 3161 resultados e, portanto, 127 páginas de busca. Para "passarmos" de página em página, portanto, temos que ter um "loop" que conte não mais de 1 até 127, mas na seguinte sequência numérica: {1, 26, 51, 76, ..., 3126, 3151}.

Precisamos, então, que "i" seja recalculado dentro do loop para coincidir com a numeração da primeira notícia de cada página. Parece difícil, mas é extremamente simples. Veja o loop abaixo, que imprime a sequência desejada multiplicando (i - 1) por 25 e somando 1 ao final:

```{r}
for (i in 1:127){
  i <- (i - 1) * 25 + 1
  print(i)
}
```

O que precisamos agora é incluir nas "instruções do loop" o que foi discutido no tutorial 6. 

Em primeiro lugar, construímos o url de cada página do resultado da busca:

```{r}
url_base1 <- "https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr="

url_base2 <- "&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"

url_folha <- paste0(url_base1, i, url_base2)
```

A seguir, capturamos o código HTML da página:

```{r}
pagina <- read_html(url_folha)
```

Escolhemos apenas os "nodes" que nos interessam:

```{r}
nodes_titulos <- html_nodes(pagina, xpath = "//ol/li/div/div/a/h2")
nodes_links <- html_nodes(pagina, xpath = "//ol/li/div/div[@class='c-headline__content']/a")
```

Extraímos os títulos e os links com as funções apropriadas:

```{r}
titulos <- html_text(nodes_titulos)
links <- html_attr(nodes_links, name = "href")
```

Combinamos os dois vetores em um data frame:

```{r}
tabela_titulos <- data.frame(titulos, links)
```

Falta "empilhar" o que produziremos em cada iteração do loop de uma forma que facilite a visualização. Criamos um objeto vazio antes do loop. 

Usaremos a função _bind\_rows_ do pacote _tidyverse_ (nosso conhecido dos tutoriais 3 e 4) para combinar data frames. A cada página agora, teremos 25 resultados em uma tabela com duas variáveis. O que queremos é a junção dos 25 resultados de cada uma das 151 páginas. Vamos também chamar a biblioteca _dplyr_ para usar sua função _bind\_rows_.

```{r}
library(tidyverse)
dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
```

Chegou o momento de colocar dentro loop tudo o que queremos que execute em cada uma das vezes que ele ocorrer. Ou seja, que imprima na tela a página que está executando, que a url da página de resultados seja construída com a função paste, para todas elas o código html seja examinado, lido no R e transformado em objeto XML, colete todos os links e todos os títulos e que "empilhe". Lembrando que não podemos esquecer de definir a url que estamos usando e criar um data frame vazio para colocar todos os links e títulos coletados antes de iniciar o loop.

```{r}
library(tidyverse)
library(rvest)

url_base1 <- "https://search.folha.uol.com.br/search?q=seade&site=todos&periodo=todos&sr="

url_base2 <- "&results_count=3161&search_time=0%2C239&url=https%3A%2F%2Fsearch.folha.uol.com.br%2Fsearch%3Fq%3Dseade%26site%3Dtodos%26periodo%3Dtodos%26sr%3D1"

dados_pesquisa <- data_frame()

for (i in 1:127){
  
  print(i)
  i <- (i - 1) * 25 + 1
  
  url_folha <- paste0(url_base1, i, url_base2)
  
  pagina <- read_html(url_folha)
 
  nodes_titulos <- html_nodes(pagina, xpath = "//ol/li/div/div/a/h2")
  nodes_links <- html_nodes(pagina, xpath = "//ol/li/div/div[@class='c-headline__content']/a")

  titulos <- html_text(nodes_titulos)
  links <- html_attr(nodes_links, name = "href")

  tabela_titulos <- data.frame(titulos, links)
  
  dados_pesquisa <- bind_rows(dados_pesquisa, tabela_titulos)
}
```

Pronto! Tudo em um único pedaço de código! Use a função "View" para examinar o resultado;

Temos agora todos os títulos e links de todos os resultados do site da Folha de São Paulo para o termo "seade" em um único banco de dados.