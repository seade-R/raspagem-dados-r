# Tutorial 13 - Análise de texto no R - pacote _tidytext_

## Apresentação

Neste tutorial vamos dar passos importantes na preparação de textos em R para análise. Utilizaremos o pacote _tidytext_, que organiza um _corpus_ como data frame e torna o trabalho de manipulação das informações relativamente simples.

O pacote _tidytext_ é acompanhado de um livro em formato digital aberto que contém exemplos interessantes e úteis de como analisar textos: [Text Mininig with R](http://tidytextmining.com/).

Depois de terminar este tutorial, sugiro a leitura de um dos seguintes capítulos do livro que, após este tutorial, podem ser lidos em qualquer ordem e de maneira independente:

- [Capítulo 2 - Análise de Sentimento (com textos em inglês)](http://tidytextmining.com/sentiment.html)

- [Capítulo 3 - Análise de frequência de palavras](http://tidytextmining.com/tfidf.html)

- [Capítulo 4 - Relacionamento entre palavras, n-gramas e correlação](http://tidytextmining.com/ngrams.html)

- [Capítulo 6 - Topic Modeling](http://tidytextmining.com/topicmodeling.html)

## Utilizando os dados coletados no Tutorial 12

Para seguir neste tutorial você precisará realizar o [Tutorial 12] até o final e ter em seu environment o data frame "artigos_scielo" ou reproduzir integralmente o código abaixo. Certifique-se que os pacotes utilizados no tutorial anterior estão carregados e carregue também o pacote _tidytext_ e o pacote _tm_, que também é usado para processamento de linguagem natural.

```{r}
library(tm)
library(tidytext)
library(stringr)
library(tidyverse)
library(rvest)
library(httr)

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

remove_acentos <- function(x) iconv(x, to = "ASCII//TRANSLIT")

artigos_scielo <- artigos_scielo %>% 
  mutate(texto = remove_acentos(texto))

artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_to_lower(texto))

artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_remove_all(texto, '[:punct:]'))

artigos_scielo <- artigos_scielo %>% 
  mutate(tamanho = str_length(texto))

artigos_scielo <- artigos_scielo %>% 
  mutate(brasileiro = str_detect(url, ".br"))

artigos_scielo <- artigos_scielo %>% 
  mutate(id = str_sub(url, str_length(url) - 30, str_length(url) - 8))

artigos_scielo <- artigos_scielo %>% 
  mutate(ordem = str_order(id)) %>% 
  arrange(ordem)

artigos_scielo <- artigos_scielo %>% 
  mutate(ia = str_detect(texto, "inteligencia artificial"))

artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem = str_count(texto, "inteligencia artificial"))

artigos_scielo <- artigos_scielo %>% 
  mutate(texto = str_replace_all(texto, " ia ", "inteligencia artificial"))

artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem_2 = str_count(texto, "inteligencia artificial"))
```

## Tokens

Neste exercício, vamos trabalhar apenas com os textos de artigos brasileiros (que contém url terminada em .br) e utilizaremos apenas duas variáveis, o id do artigo e o próprio texto:

artigos_scielo <- artigos_scielo %>% 
  filter(brasileiro == T) %>% 
  select(id, texto)

O primeiro passo para organizar um texto para análise com o pacote _tidytext_ é a tokenização da variável do conteúdo do texto. "tokenização" significa fragmentar o texto em unidades, que podem ser palavras, duplas, trios ou conjunto ainda maiores de palavras, setenças, etc. Vamos trabalhar inicialmente com palavras como tokens:

```{r}
artigos_token <- artigos_scielo %>%
  unnest_tokens(word, texto)

glimpse(artigos_token)
```

Note que a variável _id_, criada por nós, é mantida. "texto", porém, se torna "words", organizada ordenadamente na sequência prévia dos textos. Veja que o formato de um "tidytext" é completamnte diferente do data frame orignal, pois o conteúdo da variável de com a informação textual agora são os "tokens", que, neste caso, são palavras.

## Palavras comuns: stopwords

Quando analisamos textos podemos observar, entre outros aspectos, a frequência ou a co-ocorrência entre tokens. Entretanto, em todas as línguas há palavras que são muito mais frequentes que as demais e que trazem pouca informação sobre o conteúdo do texto. São as "stopwords".

O pacote _tm_ contém uma lista de stopwords em português. Veja:

```{r}
stopwords("pt")
```

Dependendo do propósito da análise, podemos ampliar manualmente a lista de stopwords acrescentando novos termos ao vetor.

Em nosso exemplo, boa parte dos textos está em inglês, apesar de termos selecionados apenas artigos em urls .br. Vamos, assim, também excluir stopwords da língua inglesa.

Como excluir stopwords nessa abordagem? Precisamos de um data frame com stopwords:

```{r}
stopwords_df <- data.frame(word = c(stopwords("pt"), stopwords("en")))
```

Com _anti\_join_, que é uma função para combinar data frames (você pode aprender um pouco sobre ela neste tutorial sobre bases relacionais [Tutorial]) mantemos em "discursos\_token" apenas as palavras que não estao em "stopwords\_pt\_df"

```{r}
artigos_token <- artigos_token %>%
  anti_join(stopwords_df, by = "word")
```

Pronto! Excluímos os termos mais comuns em português de nosso data frame e eles não influenciarão a análise. Note que o novo data frame tem menos linhas que associam as palavras aos seus respectivos textos.

Para observarmos a frequência de palavras nos discursos, usamos _count_, do pacote _dplyr_:


```{r}
artigos_token %>%
  count(word, sort = TRUE) %>% View
```

Opa! Há muitos tokens que são apenas caracteres soltos. Em artigos científicos é comum encontrar caracteres representando variáveis em modelos estatísticos ou outras medidas em modelos científicos. Vamos, assim, excluir todas as palavras com menos de 2 caracteres e rever a frequência dos tokens:

```{r}
artigos_token <- artigos_token %>%
  filter(str_length(word) > 2) 

artigos_token %>%
  count(word, sort = TRUE) %>% View
```{r}

Bem melhor. Ainda seria possível melhorar a limpeza do texto, mas podemos avançar.

Com _ggplot_, podemos construir um gráfico de barras dos temos mais frequêntes, por exemplo, com frequência maior do que 500. Neste ponto do curso, nada do que estamos fazendo abaixo deve ser novo a você:

```{r}
artigos_token %>%
  count(word, sort = TRUE) %>%
  filter(n > 200) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
    geom_col() +
    xlab(NULL) +
    coord_flip()
```

### Bigrams

Já produzimos duas vezes a tokenização do texto, sem, no entanto, refletir sobre esse procedimento. Tokens são precisam ser formados por palavras únicas. Se o objetivo for, por exemplo, observar a ocorrência conjunta de termos, convém trabalharmos com bigrams (tokens de 2 palavras) ou ngrams (tokens de n palavras). Vejamos como:

```{r}
artigos_bigram <- artigos_scielo %>%
  unnest_tokens(bigram, texto, token = "ngrams", n = 2)
```

Obs: ao tokenizar o texto, automaticamente foram excluídas as as pontuações e as palavras foram alteradas para minúscula (use o argumento "to_lower = FALSE" caso não queira a conversão). Não precisaríamos, assim, ter feito tais transformações anteriormente. Vamos contar os bigrams:

```{r}
artigos_bigram %>%
  count(bigram, sort = TRUE)
```

Como, porém, excluir as stopwords quando elas ocorrem em bigrams? Em primeiro, temos que separar os bigrams e duas palavras, uma em cada coluna:

```{r}
bigrams_separados <- artigos_bigram %>%
  separate(bigram, c("word1", "word2"), sep = " ")
```

E, a seguir, "filtrar" o data frame excluindo as stopwords (note que aproveitamos o data frame de stopwords\_df que criamos anteriormente):

```{r}
bigrams_filtrados <- bigrams_separados %>%
  anti_join(stopwords_df, by = c("word1" = "word")) %>%  
  anti_join(stopwords_df, by = c("word2" = "word"))
```

Produzindo a frequência de bigrams:

```{r}
bigrams_filtrados %>% 
  count(word1, word2, sort = TRUE)
```

Reunindo as palavras do bigram que foram separadas para excluirmos as stopwords:

```{r}
bigrams_filtrados %>%
  unite(bigram, word1, word2, sep = " ")
```

A abordagem "tidy" traz uma tremenda flexibilidade. Se, por exemplo, quisermos ver com quais palavras a palavra "learning" é antecedida:

```{r}
bigrams_filtrados %>%
  filter(word2 == "learning") %>%
  count(word1, sort = TRUE)
```

Ou precedida:

```{r}
bigrams_filtrados %>%
  filter(word1 == "learning") %>%
  count(word2, sort = TRUE)
```

Ou ambos:

```{r}
bind_rows(
  bigrams_filtrados %>%
    filter(word2 == "learning") %>%
    count(word1, sort = TRUE) %>%
    rename(word = word1),
  
  bigrams_filtrados %>%
    filter(word1 == "learning") %>%
    count(word2, sort = TRUE) %>%
    rename(word = word2)
) %>%
  arrange(-n)
```

Super simples e legal, não?

### Ngrams

Repetindo o procedimento para "trigrams":

```{r}
artigos_scielo %>%
  unnest_tokens(trigram, texto, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  anti_join(stopwords_df, by = c("word1" = "word")) %>%
  anti_join(stopwords_df, by = c("word2" = "word")) %>%
  anti_join(stopwords_df, by = c("word3" = "word")) %>%
  count(word1, word2, word3, sort = TRUE)
```

"convolutional neural networks" é o "trigram" mais frequente nos artigos capturados.
