# Tutorial 11 - twitteR

Este tutorial é um rápido guia de como obter dados diretamente da API do Twitter e manipulá-los

## Twitter Apps

Uma das grandes facilidades ao trabalharmos com o twitter é a possibildiade de capturar os dados via API. Isso significa que, diferentemente de quando raspamos páginas de internet, não precisamos capturar o códido HTML de um página do twitter para obter dados sobre tweets, usuários, etc. Basta enviarmos um "request" especifico via API e recebemos de volta os dados desejados (o processo é muito semelhante ao do Web Service da Câmara dos Deputados).

Antes de enviar requisições de dados, porém, precisamos informar ao Twitter quem somos e conectarnos à API. Nosso primeiro passo, portanto, é criar uma conta no twitter. Você pode usar sua conta pessoal se desejar.

Uma vez criada a conta no Twitter, precisamos "criar um APP" específico para podermos nos conectar. Vá para o endereço https://apps.twitter.com/ e selecione "Create New App".

Preencha os dados. Note que o campo "Website" precisa ser informado, mas você pode usar uma página pessoal (por exemplo, seu github). Para o bom funcionamento da conexão, o campo "Callback URL" deve ser preenchido com "http://127.0.0.1:1410".

Volte para a página inicial do seu Twitter Apps. Escolha seu novo App. Clique na aba "Keys and Access Tokens". As chaves "Consumer Key (API Key)", "Consumer Secret (API Secret)", "Access Token" e "Access Token Secret" são as informações que precisaremos para estabelecer uma conexão com o Twitter via R.

## Pacote twitteR - preparando o ambiente

Algumas das funções que vamos utilizar nesta atividade não estão na biblioteca básica do R. Temos, dessa forma, que começar instalando uma biblioteca chamada _twitteR_. Esta biblioteca depende de outras duas, chamadas _ROAuth_ (para autenticar conexões na web) e _httr_ (para fazer requisições http, "http requests"). Vamos, assim, instalar as 3 bibliotecas:

```{r}
install.packages("ROAuth")
install.packages("httr")
install.packages("twitteR")
```

Uma vez instaladas as bibliotecas, as funções não estão automaticamente disponíveis. Para torná-las disponíveis é preciso carregar as bibliotecas:

```{r}
library(ROAuth)
library(httr)
library(twitteR)
```

## Estabelecendo uma conexão Twitter - R

Para conectar-se ao Twitter via R, utilizaremos a função _setup\_twitter\_oauth_. Esta função recebe como parâmetros as "chaves" que você encontrará na página do App que você criou, "Consumer Key (API Key)", "Consumer Secret (API Secret)", "Access Token" e "Access Token Secret". É conveniente armazenar ambas em objetos de texto, como abaixo:

```{r}
consumer_key <- "Dei4fs0CoWVj4xHwmEg6vCaKK"
consumer_secret <- "4enUvutc6X59lptYMjxYl8zJuSb35phrrKcqQGnQA3q5O2x6fF"
access_token <- "47187333-8JRk8bDwWzfk1wlkCF5ZLf5QNa04M3EHN2o5M2rp6"
access_secret <- "vCsLaFZMOQLv3EHJPh0MrNXJD0rJOHI11EELgWbKWN2TZ"
```

Substitua corretamente cada umas das informações pelas de sua conta. Usamos agora a função "setup_twitter_oauth" e nos conectamos ao Twitter via R:

```{r}
setup_twitter_oauth(consumer_key,
                    consumer_secret,
                    access_token,
                    access_secret)
```

Escolher a opção (1). Você será redirecionada(o) ao browser para concluir a autenticação.

# Procurando tweets com #hashtags e termos de busca

Um dos nossos interesses será procurar tweets utilizando hashtags ou termos chave. A função "searchTwitter" faz isso com facilidade. Por exemplo, um dos assuntos nos "trending topics" de hoje é "Ministério da Economia". Vamos buscar os 300 últimos tweets com o termo:

```{r}
tweets <- searchTwitter("Ministério da Economia", n = 300)
head(tweets)  
```

O resultado da busca é uma lista com 300 informações sobre os 300 tweets. Vamos olhar o tweet na primeira posição:

```{r}
class(tweets)
tweets[[1]]
```

Aparentemente recebemos apenas o texto do tweet. Porém, se examinamos com cuidado, vemos que a lista retornada contém elementos de uma classe de objetos bastante específica e pertencente ao pacote "twitteR":

```{r}
class(tweets[[1]])
```

Examinando sua estrutura com a função "str", encontramos as demais informações que nos interessam, tal como texto, data e hora, se é retweet, contagem de retweets, o "nome de tela" do usuário, o id do usuário, etc.

```{r}
str(tweets[[1]])
```

É incoveniente, porém, trabalharmos com o formato de lista. Considerando que todos os elementos da lista são da mesma classe de objetos, podemos reorganizá-los como uma matriz de dados, ou data frame. A função "twListToDF" faz isso automaticamente:

```{r}
df.tweets <- twListToDF(tweets)
```

O novo data frame contém 16 variáveis, cada um com uma das informações que visualizamos com o comando "str"

```{r}
names(df.tweets)
```

Fica fácil observar os 300 tweets do data frame:

```{r}
View(df.tweets)
```

Ou obter um vetor com a contagem de retweets:

```{r}
df.tweets$retweetCount
```

Voltando à função "searchTwitter", convém inspecionar os parâmetros que podemos informar na busca:

```{r}
?searchTwitter
```

Além do número máximo de tweets a serem capturados, podemos "filtrar" a busca por idioma (lang), data inicial (since), data final (until), localidade ou proximidade radial a uma lat/long(geocode), entre outros parâmetros.

Finalmente, uma função útil para a análise de tweets é "strip_retweets", que remove todos os retweets da lista de tweets:

```{r}
tweets_noret <- strip_retweets(tweets, strip_manual=TRUE, strip_mt=TRUE)
```

# Usuários e timeline de usuários

Além de obtermos os tweets de uma busca por hashtag ou termo-chave, podemos obter informações dos usuários com a função "getUser". Por exemplo, obtemos o usuário MichelTemer e examinamos com "str" o conteúdo do resultado.

```{r}
seade_user <- getUser('fundacaoseade')
str(temer_user)
```

Explorando os dados deste usuário

```{r}
seade_user$description      #descricao
seade_user$statusesCount    #tweets
seade_user$followersCount   #seguidores
seade_user$friendsCount     #amigos seguidos
seade_user$favoritesCount   #curtidas
seade_user$location         #localidade
seade_user$id               #id do usuario
```

Para obter a timeline de um usuário fazemos:

```{r}
seade_timeline <- userTimeline('fundacaoseade', n = 100)
```

A timeline também pode ser transformada em data frame:

```{r}
df.timeline <- twListToDF(seade_timeline)
View(df.timeline)
```

# Trends

Por fim, podemos obter os trending topics do Twitter. Em primeiro lugar, observamos quais são as localidades para os quais trending topics são classificados:

```{r}
avail_trends <- availableTrendLocations()
head(avail_trends)
avail_trends[avail_trends$country == "Brazil",]
```

Com o código "woeid", obtemos os trends de Guarulhos, por exemplo:

```{r}
trends <- getTrends(455827)
head(trends)

```
