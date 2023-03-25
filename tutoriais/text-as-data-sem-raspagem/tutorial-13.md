# Tutorial 13 - Análise de texto no R - pacote `tidytext`

## Apresentação

Neste tutorial vamos dar passos importantes na preparação de textos em R para análise. Utilizaremos o pacote `tidytext`, que organiza um _corpus_ como data frame e torna o trabalho de manipulação das informações relativamente simples.

O pacote `tidytext` é acompanhado de um livro (em inglês) em formato digital aberto que contém exemplos interessantes e úteis de como analisar textos: [Text Mininig with R](http://tidytextmining.com/).

Depois de terminar este tutorial, sugiro a leitura de um dos seguintes capítulos do livro que, após este tutorial, podem ser lidos em qualquer ordem e de maneira independente:

- [Capítulo 2 - Análise de Sentimento (com textos em inglês)](http://tidytextmining.com/sentiment.html)

- [Capítulo 3 - Análise de frequência de palavras](http://tidytextmining.com/tfidf.html)

- [Capítulo 4 - Relacionamento entre palavras, n-gramas e correlação](http://tidytextmining.com/ngrams.html)

- [Capítulo 6 - Topic Modeling](http://tidytextmining.com/topicmodeling.html)

Para além de pacotes que já conhecemos, nesse tutorial carregaremos também os pacotes `tidytext` e `tm`, que também é usado para processamento de linguagem natural.

``` r
library(dplyr)
library(stringr)
library(stringi)
library(tidytext)
library(tm)
library(ggplot2)
library(tidyr)
```

Além disso, utilizaremos o mesmo banco de dados que usamos no tutorial 12 (artigos científicos coletados da plataforma SciELO no âmbito do projeto SEADE-IA). A seguir, carregamos este banco e fazemos o seu pré-processamento e criamos algumas variáveis:

``` r
artigos_scielo <- readRDS('scielo_basefinal_coleta_202211.rds')

artigos_scielo <- artigos_scielo %>% 
  mutate(abstract = stri_trans_general(abstract, "Latin-ASCII"),
         abstract = str_to_lower(abstract),
         abstract = str_remove_all(abstract, '[:punct:]'),
         tamanho = str_length(abstract),
         ia = str_detect(abstract, "inteligencia artificial"),
         ia_contagem = str_count(abstract, "inteligencia artificial"),
         abstract = str_replace_all(abstract, " ia ", "inteligencia artificial"),
         ia_contagem_2 = str_count(abstract, "inteligencia artificial"))
```

## Tokens

Neste exercício, utilizaremos apenas duas variáveis, o id do artigo e o texto do abstract:

``` r
artigos_scielo <- artigos_scielo %>% 
  select(id_final, abstract)
```

O primeiro passo para organizar um texto para análise com o pacote `tidytext` é a tokenização da variável do conteúdo do texto. "tokenização" significa fragmentar o texto em unidades, que podem ser palavras, duplas, trios ou conjuntos ainda maiores de palavras, sentenças, etc. Vamos trabalhar inicialmente com palavras como tokens:

``` r
artigos_token <- artigos_scielo %>%
  unnest_tokens(word, abstract)

glimpse(artigos_token)
```

Note que a variável `id_final` é mantida. `abstract`, porém, se torna `word`, organizada ordenadamente na sequência prévia dos textos. Veja que o formato de um `tidytext` é completamnte diferente do data frame original, pois o conteúdo da variável de com a informação textual agora são os "tokens", que, neste caso, são palavras.

## Palavras comuns: stopwords

Quando analisamos textos, podemos observar a frequência ou a co-ocorrência entre tokens, entre outros aspectos. Entretanto, em todas as línguas há palavras que são muito mais frequentes que as demais e que trazem pouca informação sobre o conteúdo do texto. São as chamadas "stopwords".

O pacote `tm` contém uma lista de stopwords em português. Veja:

``` r
stopwords("pt")
```

Dependendo do propósito da análise, podemos ampliar manualmente a lista de stopwords acrescentando novos termos ao vetor.

Em nosso exemplo, boa parte dos textos está em inglês e em espanhol. Vamos, assim, também excluir stopwords dessas duas línguas.

Como excluir stopwords nessa abordagem? Precisamos de um data frame com stopwords:

``` r
stopwords_df <- data.frame(word = c(stopwords("pt"), 
                                    stopwords("en"),
                                    stopwords("es")))
```

Com `anti_join()`, que é uma função para combinar data frames (se precisar, recorra à ajuda!) mantemos em `artigos_token` apenas as palavras que não estao em `stopwords_pt_df`. 

``` r
artigos_token <- artigos_token %>%
  anti_join(stopwords_df, by = "word")
```

Pronto! Excluímos os termos mais comuns dessas três línguas de nosso data frame e eles não influenciarão a análise. Note que o novo data frame tem menos linhas que associam as palavras aos seus respectivos textos.

Para observarmos a frequência de palavras nos discursos, usamos `count()`, do pacote `dplyr`:

``` r
artigos_token %>%
  count(word, sort = TRUE) %>% 
  View()
```

Opa! Há muitos tokens que são apenas caracteres soltos. Em artigos científicos é comum encontrar caracteres representando variáveis em modelos estatísticos ou outras medidas em modelos científicos. Vamos, assim, excluir todas as palavras com menos de 2 caracteres e rever a frequência dos tokens:

``` r
artigos_token <- artigos_token %>%
  filter(str_length(word) > 2) 

artigos_token %>%
  count(word, sort = TRUE) %>% 
  View()
```

Bem melhor. Ainda seria possível melhorar a limpeza do texto, mas podemos avançar.

Com `ggplot()`, podemos construir um gráfico de barras dos temos mais frequentes, por exemplo, com frequência maior do que 6000. Neste ponto do curso, nada do que estamos fazendo abaixo deve ser novo a você:

``` r
artigos_token %>%
  count(word, sort = TRUE) %>%
  filter(n > 6000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
    geom_col() +
    xlab(NULL) +
    coord_flip()
```

### Bigrams

Já produzimos duas vezes a tokenização do texto, sem, no entanto, refletir sobre esse procedimento. Tokens são precisam ser formados por palavras únicas. Se o objetivo for, por exemplo, observar a ocorrência conjunta de termos, convém trabalharmos com bigrams (tokens de 2 palavras) ou ngrams (tokens de n palavras). Vejamos como:

``` r
artigos_bigram <- artigos_scielo %>%
  unnest_tokens(bigram, abstract, token = "ngrams", n = 2)
```

Vamos contar os bigrams:

``` r
artigos_bigram %>%
  count(bigram, sort = TRUE)
```

Como, porém, excluir as stopwords quando elas ocorrem em bigrams? Em primeiro, temos que separar os bigrams e duas palavras, uma em cada coluna:

``` r
bigrams_separados <- artigos_bigram %>%
  separate(bigram, c("word1", "word2"), sep = " ")
```

E, a seguir, "filtrar" o data frame excluindo as stopwords (note que aproveitamos o data frame de `stopwords_df` criado anteriormente):

``` r
bigrams_filtrados <- bigrams_separados %>%
  anti_join(stopwords_df, by = c("word1" = "word")) %>%  
  anti_join(stopwords_df, by = c("word2" = "word"))
```

Produzindo a frequência de bigrams:

``` r
bigrams_filtrados %>% 
  count(word1, word2, sort = TRUE)
```

Reunindo as palavras do bigram que foram separadas para excluirmos as stopwords:

``` r
bigrams_filtrados %>%
  unite(bigram, word1, word2, sep = " ")
```

A abordagem "tidy" traz uma tremenda flexibilidade. Se, por exemplo, quisermos ver com quais palavras a palavra "learning" é antecedida:

``` r
bigrams_filtrados %>%
  filter(word2 == "learning") %>%
  count(word1, sort = TRUE)
```

Ou precedida:

``` r
bigrams_filtrados %>%
  filter(word1 == "learning") %>%
  count(word2, sort = TRUE)
```

Ou ambos:

``` r
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

``` r
artigos_scielo %>%
  unnest_tokens(trigram, abstract, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  anti_join(stopwords_df, by = c("word1" = "word")) %>%
  anti_join(stopwords_df, by = c("word2" = "word")) %>%
  anti_join(stopwords_df, by = c("word3" = "word")) %>%
  count(word1, word2, word3, sort = TRUE)
```

"principal component analysis" é o "trigram" mais frequente nos artigos capturados.
