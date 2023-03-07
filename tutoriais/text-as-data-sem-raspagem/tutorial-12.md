# Tutorial 12 - Preparação de textos com o pacote _stringr_

Neste tutorial faremos uma rápida introdução ao pacote _stringr_. Nosso objetivo é saber transformar e identificar padrões em textos para que posssamos organizá-los e prepará-los para análise após a coleta via raspagem ou após a extração a partir de documentos de imagem/pdf.

## Pacotes e construção do _corpus_

Neste tutorial vamos utilizar os seguintes pacotes: _stringr_, cujas funções básicas vamos explorar; _tidyverse_, pois faremos a manipulação de textos como variável em um data frame; e _rvest_ e _httr_ para obtermos dados de artigos científicos da plataforma Scielo para construir um _corpus_, ou seja, uma coleção de textos com o qual vamos trabalhar.

```{r}
library(stringr)
library(tidyverse)
library(rvest)
library(httr)
```

Sua primeira tarefa será revisitar uma versão modificada (e mais completa) código da raspagem de artigos científicos na plataforma Scielo. Faremos uma busca por artigos que contenham a expressão "deep learning". Copie o código abaixo em um script de R e comente-o passo a passo antes de avançar. Veja se consegue compreendê-lo totalmente. O código resume boa parte do que vimos no curso até agora.

```{r}
set_config(config(ssl_verifypeer = 0L))

scielo_url <- "https://search.scielo.org/"

scielo_session <- session(scielo_url)

scielo_pagina <- read_html(scielo_session)

scielo_form_list <- html_form(scielo_pagina)

scielo_form <- scielo_form_list[[2]]

scielo_form <- html_form_set(scielo_form,
                             'q' = '"deep learning"',
                             'count' = '500')

scielo_submission <- session_submit(x = scielo_session, 
                                    form = scielo_form)

scielo_resultado <- read_html(scielo_submission)

links_nodes <- html_nodes(scielo_resultado, xpath = '//div[@class = "line"]//a')
links <- html_attr(links_nodes, name = "href")
links <- str_subset(links, "sci_arttext")
links <- unique(links)

textos_scielo <- c()

for (link_artigo in links){
  
  print(link_artigo)

  texto_pagina <- read_html(GET(link_artigo))
  
  texto_nodes <- html_nodes(texto_pagina, xpath = '//article//p')
  
  if (length(texto_nodes) != 0) {
    
    texto <- html_text(texto_nodes) 
    
  } else {
    
    texto_nodes <- html_nodes(texto_pagina, xpath = '//div[@id = "article-body"]//p')
    
    if (length(texto_nodes) != 0) {
      
    texto <- html_text(texto_nodes)
    
      } else {
    
    texto_nodes <- html_nodes(texto_pagina, xpath = '//div[@class = "content"]//p')
    texto <- html_text(texto_nodes)    
      
      }
  }
  
  texto <- paste(texto, collapse = " ")
  textos_scielo <- c(textos_scielo, texto)
  
}


artigos_scielo <- tibble(
  url = links,
  texto = textos_scielo) 

View(artigos_scielo)

```

## Limpeza e preparação de textos com o pacote _stringr_

O pacote _stringr_ é relativamente simples de utilizar. Todas as suas funções principais começam com o prefixo "str\_" e têm nomes razoavelmente intuitivos. O primeiro argumento da função é um vetor de texto (que pode ser um texto simples se for um vetor de tamanho 1) que sofrerá uma modificação ou sobre o qual extraíremos alguma informação.

Os vetores de texto podem ser objetos no seu environment ou variáveis dentro de um data frame. Neste tutorial, vamos preferir trabalhar com textos como variáveis em um data frame, que é uma situação usual na maioria dos projetos. Por esta razão, vamos utilizar as funções do pacote _stringr_ dentro do verbo "mutate" do pacote _dplyr_, pois estaremos modificando uma coluna ou criando uma nova variável.

Antes de seguir para as funções do _stringr_, vamos criar uma função bastante útil para trabalhar com textos em português: a função _remove\_acentos_, que encontrei há vários anos em algum fórum ou código cuja autoria não me lembro:

```{r}
remove_acentos <- function(x) iconv(x, to = "ASCII//TRANSLIT")
```

Seu uso e resultado são elementares: o texto modificado perde todos os acentos e caracteres especiais, como ç, por exemplo:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(texto = remove_acentos(texto))
```

É particularmente conveniente remover os acentos ao trabalharmos com um _corpus_, em particular quando suspeitamos que uma parte dos textos já esteja sem acentuação e a outra não.

Como em R há diferenciação entre letras maiúsculas e minúsculas, convém também tornar o texto completo em minúsculo. Podemos utilizar a função "str\_to\_lower" do pacote _stringr_. Ela é semelhante à função "tolower" do pacote _base_ de R.

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_to_lower(texto))
```

"str\_to\_upper", por sua vez, transformaria todos os caracteres em maísculo e "str\_to\_title" manteria em maísculo apenas o primeiro caracter de cada palavra e os demais em minúsculo.

Outra limpeza comum na preparação de textos é a remoção de todo a pontuação. A função "str\_remove\_all" nos permite remover uma padrão de dentro de um texto. Por exemplo, para removermos todas as palavras "abstract" faríamos str\_remove\_all(texto, "abstract"). Para remover pontuação, porém, precisamo de uma _expressão regular_ que represente "qualquer caracter de pontuação", como a expressão "[:punct:]".

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_remove_all(texto, '[:punct:]'))
```

Expressões regulares são grandes aliadas das funções do pacote _stringr_. Ao final do tutorial há uma indicação onde você pode aprender um pouco mais como escrever expressões regulares.

Vejamos como ficou o texto do terceiro artigo depois de modificado:

```{r}
artigos_scielo$texto[3]
```

Qual dos textos do nosso _corpus_ é o mais longo? Vamos criar uma variável de tamanho (em caracteres) dos textos:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(tamanho = str_length(texto))

artigos_scielo
```

Vamos agora identificar padrões dentro de nossos textos. Há 3 funções muito úteis e similares para identificar padrões. Antes de utilizá-las dentro do data frame com os dados dos artigos científicos, vamos aplicá-las a um vetor de textos para entender seus resultados. Compare:

```{r}
str_detect(artigos_scielo$texto, 'inteligencia artificial')
```

"str\_detect" procura em cada um dos textos do vetor o padrão que está no segundo parâmetro da função e retorna um vetor lógico de mesmo tamanho indicando quais dos textos contêm o padrão.

```{r}
str_which(artigos_scielo$texto, 'inteligencia artificial')
```

"str\_which", por sua vez, também procura em cada um dos textos o padrão informado, mas seu resultado é um vetor com a posição dos textos que contêm o padrão.

```{r}
str_subset(artigos_scielo$texto, 'inteligencia artificial')
```

Finalmente, "str\_subset" faz uma seleção no vetor dos textos que contêm o padrão e retorna um vetor com os textos selecionados. 

"str\_detect" é bastante útil, por exemplo, para selecionar linhas em um data frame. Por exemplo, vamos criar um novo data frame que contenha apenas os artigos que tem pelo menos uma menção a "inteligencia artificial" aplicando "str\_detect" dentro do verbo "filter":

```{r}
artigos_ia <- artigos_scielo %>% 
  filter(str_detect(artigos_scielo$texto, 'inteligencia artificial'))
```

Ótimo! Mas vamos continuar trabalhando no data frame completo.

Usando uma regularidade dos urls dos artigos, vamos detectar quais são aqueles publicados em revistas nacionais e, portanto, tem ".br" como parte do url. Criaremos uma variável "brasileiro", do tipo lógico com a aplicação de "str\_detect" dentro de "mutate":

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(brasileiro = str_detect(url, ".br"))
```

Trabalhando ainda com os urls, podemos observar que em cada endereço existe um parâmetro "id", que é o número identificador do artigo na plataforma. Os urls tem tamanhos variados (pois alguns são ".br", outros ".org.co"), mas o final é sempre padrão "\&lang=pt" precedido de um código de 23 caracteres. 

"_str\_sub_" é de uso simples: informamos em primeiro lugar o texto de onde sairá a informação, a primeira posição e a última que estarão no resultado. Veja o exemplo:


```{r}
str_sub("deep learning", 6, 13)
```

Como a regularidade está na posição da informação dentro do texto, utilizamos "_str\_sub_" para extrair os 31 últimos caracteres do url. Mas o último caracter em cada url está numa posição diferente. Então utilizamos "str\_length" para identificar os caracteres que estão a 8 e 31 posições antes:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(id = str_sub(url, str_length(url) - 30, str_length(url) - 8))
```

"str\_order" retorna a ordem alfabética (que inclui números) de cada texto do vetor. Se combinarmos com o verbo "arrange" teremos o data frame reordenado pelo "id" do artigo na Scielo:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(ordem = str_order(id)) %>% 
  arrange(ordem)
```

Novamente com "str\_detect" vamos criar uma coluna para identificar (e não selecionar linhas como fizemos anteriormente) com o termo "inteligencia artificial":


```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(ia = str_detect(texto, "inteligencia artificial"))
```

E se quisermos saber quantas vezes o termo aparece em cada texto, e não apenas se sim ou se não? "str\_count" cumpre bem a tarefa:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem = str_count(texto, "inteligencia artificial"))
```

Mas temos um problema agora. Em muitos textos "inteligencia artificial" aparece abreviado por "ia". Vamos, então, substituir todas as ocorrências de " ia " (com os espaços para diferenciarmos de ocorrências no meio de palavras, como na palavra "ocorrência") por "inteligencia artificial". A função "str\_replace\_all" faz a substituição de um padrão por outro dentro do texto, como no exemplo a seguir:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_replace_all(texto, " ia ", "inteligencia artificial"))
```

E agora vamos recontar, armazenado na coluna "ia\_contagem\_2" a nova contagem:

```{r}
artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem_2 = str_count(texto, "inteligencia artificial"))
```

E selecionar apenas os artigos que tiveram contagens diferentes antes ou depois da modificação:


```{r}
artigos_scielo %>% 
  filter(ia_contagem != ia_contagem_2) %>%
  select(id, ia_contagem, ia_contagem_2)
```

Pronto! Fizemos uma rápida introdução ao pacote _stringr_.

## Onde aprender um pouco mais?

Ao terminar o tutorial, se quiser aprender sobre expressões regulares e algumas funções do pacote _stringr_ que não utilizamos recomendo duas leituras: a [sessão sobre o pacote _stringr_ do livro "Ciência de dados em R"](https://livro.curso-r.com/7-4-o-pacote-stringr.html) do curso-r, em português, e o [capítulo em inglês sobre manipulação de strings do livro "R for Data Science"](https://r4ds.had.co.nz/strings.html).
