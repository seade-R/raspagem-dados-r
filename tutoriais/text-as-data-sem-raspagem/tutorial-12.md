# Tutorial 12 - Preparação de textos com o pacote `stringr`

Neste tutorial faremos uma rápida introdução ao pacote `stringr`. Nosso objetivo é saber transformar e identificar padrões em textos para que posssamos organizá-los e prepará-los para análise após a coleta via raspagem ou após a extração a partir de documentos de imagem/pdf.

## Pacotes e construção do _corpus_

Neste tutorial vamos utilizar os seguintes pacotes:

``` r
library(dplyr)
library(stringr)
library(stringi)
```

Além disso, utilizaremos um banco de dados de artigos científicos coletados na plataforma SciELO no âmbito do projeto SEADE-IA:

``` r
artigos_scielo <- readRDS('scielo_basefinal_coleta_202211.rds')
```

## Limpeza e preparação de textos com o pacote `stringr`

O pacote `stringr` é relativamente simples de utilizar. Todas as suas funções principais começam com o prefixo `str_` e têm nomes razoavelmente intuitivos (ainda que em inglês). O primeiro argumento da função é um vetor de texto (que pode ser um texto simples se for um vetor de tamanho 1) que sofrerá uma modificação ou sobre o qual extraíremos alguma informação.

Os vetores de texto podem ser objetos no seu environment ou variáveis dentro de um data frame. Neste tutorial, vamos preferir trabalhar com textos como variáveis em um data frame, que é uma situação usual na maioria dos projetos. Por esta razão, vamos utilizar as funções do pacote `stringr` dentro do verbo `mutate()` do pacote `dplyr`, pois estaremos modificando uma coluna ou criando uma nova variável.

A principal variável texto que vamos utilizar neste tutorial é a `abstract`. Ela contém os resumos dos artigos científicos em todas línguas fornecidas pelos autores (em geral, inglês, português e espanhol).

Antes de seguir para as funções do `stringr`, vamos utilizar uma função bastante útil do pacote `stringi` para trabalhar com textos em português: a função `stri_trans_general()`. Ela vai limpar nosso texto de acentos e caracteres especiais (como "ç"):

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(abstract = stri_trans_general(abstract, "Latin-ASCII"))
```

É particularmente conveniente remover os acentos ao trabalharmos com um _corpus_, em particular quando suspeitamos que uma parte dos textos já esteja sem acentuação e a outra não.

Como em R há diferenciação entre letras maiúsculas e minúsculas, convém também tornar o texto completo em minúsculo. Podemos utilizar a função `str_to_lower()` do pacote `stringr`. Ela é semelhante à função `tolower()` do pacote `base` de R.

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(abstract = str_to_lower(abstract))
```

`str_to_upper()`, por sua vez, transformaria todos os caracteres em maiúsculo e `str_to_title()` manteria em maiúsculo apenas o primeiro caracter de cada palavra e os demais em minúsculo.

Outra limpeza comum na preparação de textos é a remoção de toda a pontuação. A função `str_remove_all()` nos permite remover algum padrão de dentro de um texto. Por exemplo, para removermos todas as palavras "abstract" faríamos `str_remove_all(abstract, "abstract")`. Para remover pontuação, porém, precisamos de uma _expressão regular_ que represente "qualquer caracter de pontuação", como a expressão `[:punct:]`.

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(abstract = str_remove_all(abstract, '[:punct:]'))
```

Expressões regulares são grandes aliadas das funções do pacote `stringr`. Ao final do tutorial há uma indicação onde você pode aprender um pouco mais como escrever expressões regulares (no início, elas são bem difíceis de assimilar, mas são bastante poderosas).

Vejamos como ficou o texto do terceiro artigo depois de modificado:

``` r
artigos_scielo$abstract[3]
```

Qual dos abstracts do nosso _corpus_ é o mais longo? Vamos criar uma variável de tamanho (em caracteres) deles:

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(tamanho = str_length(abstract))

max(artigos_scielo$tamanho)
```

Vamos agora identificar padrões dentro de nossos textos. Há 3 funções muito úteis e similares para identificar padrões. Antes de utilizá-las dentro do data frame com os dados dos artigos científicos, vamos aplicá-las a um vetor de textos para entender seus resultados. Compare:

``` r
str_detect(artigos_scielo$abstract, 'inteligencia artificial')
```

`str_detect()` procura em cada um dos textos do vetor o padrão que está no segundo parâmetro da função e retorna um vetor lógico de mesmo tamanho indicando quais dos textos contêm o padrão.

``` r
str_which(artigos_scielo$abstract, 'inteligencia artificial')
```

`str_which()`, por sua vez, também procura em cada um dos textos o padrão informado, mas seu resultado é um vetor com a posição dos textos que contêm o padrão.

``` r
str_subset(artigos_scielo$abstract, 'inteligencia artificial')
```

Finalmente, `str_subset()` faz uma seleção no vetor dos textos que contêm o padrão e retorna um vetor com os textos selecionados. 

`str_detect()` é bastante útil, por exemplo, para selecionar linhas em um data frame. Por exemplo, vamos criar um novo data frame que contenha apenas os artigos que tem pelo menos uma menção a "inteligencia artificial" aplicando `str_detect()` dentro do verbo `filter()`:

``` r
artigos_ia <- artigos_scielo %>% 
  filter(str_detect(abstract, 'inteligencia artificial'))
```

Ótimo! Mas vamos continuar trabalhando no data frame completo.

Já a função `str_sub()` é de uso simples: informamos em primeiro lugar o texto de onde sairá a informação, a primeira posição e a última que estarão no resultado. Veja o exemplo:

``` r
str_sub("deep learning", 6, 13)
```

Como a regularidade está na posição da informação dentro do texto, utilizamos `str_sub()` para extrair os 2 últimos caracteres da variável `year`. Porém, como não sabemos se todas as entradas do banco realmente têm quatro caracteres, vamos usar a função `str_length()` para encontrar o tamanho desse texto que estamos manuseando (e que será a última posição do nosso `str_sub()`).

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(year_reduced = str_sub(year, str_length(year) - 1, str_length(year)))
```

Novamente com `str_detect()` vamos criar uma coluna para identificar linhas (e não selecionar, como fizemos anteriormente) com o termo "inteligencia artificial":


``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(ia = str_detect(abstract, "inteligencia artificial"))
```

E se quisermos saber quantas vezes o termo aparece em cada abstract, e não apenas se sim ou se não? `str_count()` cumpre bem a tarefa:

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem = str_count(abstract, "inteligencia artificial"))
```

Mas temos um problema agora. Em muitos textos "inteligencia artificial" aparece abreviado por "ia". Vamos, então, substituir todas as ocorrências de " ia " (com os espaços para diferenciarmos de ocorrências no meio de palavras, como na palavra "ocorrência") por "inteligencia artificial". A função `str_replace_all()` faz a substituição de um padrão por outro dentro do texto, como no exemplo a seguir:

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(abstract = str_replace_all(abstract, " ia ", "inteligencia artificial"))
```

E agora vamos recontar, armazenado na coluna `ia_contagem_2` a nova contagem:

``` r
artigos_scielo <- artigos_scielo %>% 
  mutate(ia_contagem_2 = str_count(abstract, "inteligencia artificial"))
```

E selecionar apenas os artigos que tiveram contagens diferentes antes ou depois da modificação:

``` r
artigos_scielo %>% 
  filter(ia_contagem != ia_contagem_2) %>%
  select(id_final, ia_contagem, ia_contagem_2)
```

Pronto! Fizemos uma rápida introdução ao pacote `stringr`.

## Onde aprender um pouco mais?

Ao terminar o tutorial, se quiser aprender sobre expressões regulares e algumas funções do pacote `stringr` que não utilizamos recomendo duas leituras: a [sessão sobre o pacote `stringr` do livro "Ciência de dados em R"](https://livro.curso-r.com/7-4-o-pacote-stringr.html) do curso-r, em português, e o [capítulo em inglês sobre manipulação de strings do livro "R for Data Science"](https://r4ds.had.co.nz/strings.html).
