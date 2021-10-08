# Tutorial 10 - APIs em R

Até este momento do curso aprendemos como adquirir dados na web em páginas que não foram desenhadas para facilitar o processo de coleta de dados automatizada, mas sim para uso convencional no navegador. Entretanto, nem todas as aquisições de dados na internet são assim complexas. Na última década a popularização de APIs -- Application Programming Interface, ou Interface para Programaçao de Aplicativos -- desenhadas para o consumo de dados de serviços web contribuiu bastante tornou o trabalho de coleta de dados bastante mais simples

Adquirir dados de uma API é diferente de fazer download de um arquivo de dados (na maioria das vezes). Quando fazemos download de um arquivo de .csv, ou outro formato, obtemos o arquivo integralmente. Em uma API, por outro lado, podemos fazer consultas (queries) nos dados. Em R, fazer consultas em APIs é bastante semelhante -- do ponto de vista da sintaxe do código -- ao que vimos no tutorial anterior com formulários, pois, tal como os últimos, APIs dispõem de parâmetros que facilitam a requisição de informações. APIs oferecem, assim, uma alternativa para que o usuário não precise fazer download completo dos dados desnecessariamente (como no caso de grandes bases de dados em formatos de texto), o que seria oneroso para o servidor e para o usuário e inviabilizaria a construção de aplicações em tempo real baseada nos dados.

Neste tutorial vamos aprender a acessar algumas APIs com R. Em primeiro lugar, aprenderemos a utilizar a documentação da API para construir consultas. Há diversos tipos de API, mas o tratamento a todas em geral é bastante semelhante.

## Moedas comemorativas no Banco Central

O Banco Central do Brasil utiliza o framework CKAN (tal com o SEADE) para disponibilizar dados em formatos abertos: [https://dadosabertos.bcb.gov.br/](https://dadosabertos.bcb.gov.br/). É possível selecionar no serviço do BCB apenas os recursos que são publicados, dentre outros formatos, via API [https://dadosabertos.bcb.gov.br/dataset?res_format=API](https://dadosabertos.bcb.gov.br/dataset?res_format=API).

Vamos começar trabalhando com um exemplo simples, que praticamente não nos oferece parâmetros para consultar os dados, que é o recurso de Moedas comemorativas do Banco Central. Mas que nos será útil para entender um aspecto fundamental das APIs: é possível, em inúmeros casos, definir o formato da resposta do servidor (mas nem sempre). E os formatos mais comuns são: "text/csv"; "xml"; ou "json".

Texto (csv) é um formato com o qual analista de dados já costumam trabalhar. XML, por sua vez, já não é novidade para nós neste curso. Em tutoriais anteriores vimos como é possível organizar uma base de dados em XML. Este é o formato utilizado, por exemplo, para transporte de dados de Notas Fiscais eletrônicas no Estado de São Paulo.

Finalmente, JSON é um formato para transporte de dados alternativo ao XML. Convém dar uma olhada no verbete da Wikipedia sobre o assunto, que contém um exemplo em JSON e sua representação também em XML [https://pt.wikipedia.org/wiki/JSON](https://pt.wikipedia.org/wiki/JSON).

Em R, podemos ler facilmente qualquer um destes formatos em transformá-los rapidamente em data frame.

Antes de avançarmos ao exemplo, convém também examinarmos a estrutura do url de uma requisição em uma API. Em geral, podemos dividir a url de uma API em 3 partes: a url base do servidor da API; o recurso que será consultado; e os parâmetros da query que pretendemos enviar à API.

No exemplo do BCB, a url para consultar em JSON os dados da Moedas Comemorativas é:

```{r}
https://olinda.bcb.gov.br/olinda/servico/mecir_moedas_comemorativas/versao/v1/odata/informacoes_diarias?$format=text/csv
```

A url base, neste exemplo, é:

```{r}
https://olinda.bcb.gov.br/
```

O recurso a ser consultado é:

```{r}
olinda/servico/mecir_moedas_comemorativas/versao/v1/odata/informacoes_diarias
```

Em conjunto essas duas informações formam o endereço padrão ("endpoint") do recurso, ou seja, a url que será consultada.

Neste caso, temos um único parâmetro, que é o formato que desejamos do resultado (na nossa escolha será csv:

```{r}
format=text/csv
```

Os parâmetros são as informações que seguem o cifrão.

Notem que o exame da url é algo bastante semelhante ao que fizemos quando trabalhamos com buscas em um portal de notícias. Isso ocorre por que nas duas situações estamos fazendo uma consulta (com parâmetros) a um servidor. No portal de notícias, o parâmetro que nos interessava era a página do resultado da busca, que alterávamos em loop. No uso de APIs, nos interessam todos os parâmetros que definirão o conteúdo dos dados que receberemos.

Vamos utilizar neste tutorial um pacote que vimos logo no início do curso, o _httr_, que contém a função "GET". Por favor, carregue-o. Aproveite e carregue também o pacote _tidyverse_, pois precisaremos das função de abertura de dados contidas no _readr_ (que é parte do _tidyverse_) e o pacote _jsonlite_  para lidarmos com dados em JSON.

```{r}
library(tidyverse)
library(httr)
library(jsonlite)
```

Na nossa primeira tentativa utilizaremos o url já construído com o único parâmetro que precisamos (formato dos dados):

```{r}
moedas_endpoint_com_parametros <- "https://olinda.bcb.gov.br/olinda/servico/mecir_moedas_comemorativas/versao/v1/odata/informacoes_diarias?$format=text/csv"
```

Se você colar esse url no seu navegador fará o download dos dados (atenção, o arquivo será baixado sem extensão e você precisará alterar o formato).

Uma forma de trabalharmos com API seria, assim, construir o url com todos os parâmetros e utilizarmos a função "download.file", como fizemos no primeiro tutorial.

```{r}
download.file(moedas_endpoint_com_parametros, 'moedas.csv')
moedas <- read_csv("moedas.csv")
```

Funciona perfeitamente bem e você pode seguir este caminho quando você nunca tiver que alterar os parâmetros da consulta.

Com APIs, porém, vamos evitar o uso desta função. Utilizaremos em substituição a função GET, do pacote _httr_. Seu uso mais simples seria com a url completa, com todos os parâmetros já preenchido:

```{r}
moedas_requisicao <- GET(moedas_endpoint_com_parametros)
```

O resultado é um objeto da classe "response", pois é uma resposta de um servidor web. Há várias informações úteis neste objeto -- por exemplo, o código da resposta (200, 400, 404, etc) que indicam o sucesso ou não da requisição. No nosso exemplo bem sucedido temos:

```{r}
moedas_requisicao$status_code
```

Mas nos interessa por enquanto apenas o "content". É ali que estão os dados que precisamos:

```{r}
moedas <- read_csv(moedas_requisicao$content)
```

Vamos agora fazer uma pequena modificação no uso da função GET. Vamos retirar da url os parâmetros (criando um novo objeto de texto com a url) da requisição e deixá-los como argumentos dentro da função GET. Veja:

```{r}
moedas_endpoint <- "https://olinda.bcb.gov.br/olinda/servico/mecir_moedas_comemorativas/versao/v1/odata/informacoes_diarias"

moedas_requisicao <- GET(moedas_endpoint,
                         query = list(
                           `$format` = 'text/csv'))

moedas <- read_csv(moedas_requisicao$content)
```

Agora a função GET tem um argumento "query" onde inserimos todos os parâmetros da consulta. Em recursos mais complexos dessa mesma API, ou em outras APIs, podemos inserir mais parâmetros e consultálos de forma variada.

Obs: o símbolo do acento grave antes e depois de "$format" é necessário para incluir o cifrão sem que R leia o cifrão como parte da sintaxe.

## Resposta em JSON

Antes de partimos para outras APIs, porém, vamos ver como lidar com um dos outros dois formatos de dados, JSON. É muito comum que a resposta de APIs venha neste (ou somente neste formato). Em primeiro lugar, vamos repetir a requisição alterando o parâmetro do formato:

```{r}
moedas_requisicao <- GET(moedas_endpoint,
                         query = list(
                           `$format` = 'json'))
```

Se seguir, precisamos extrair sem conteúdo para texto.

```{r}
moedas_json <- content(moedas_requisicao, "text")
```

E, com auxílio da função "fromJSON" do pacote _jsonlite_ transformamos o conteúdo em data frames. É possível, como neste exemplo, que os dados em json carreguem mais informações do que seria razoável organizar em uma tabela. Nestes casos, o resultado é uma lista.

```{r}
moedas_lista <- fromJSON(moedas_json)
```

Examinando a lista é fácil ver que os dados estão na segunda posição (na primeira posição havia um url).

```{r}
moedas <- moedas_lista[[2]]
```

Pronto. Temos exatamente o mesmo resultado.

## Consulta à API do SIDRA

Vamos a um exemplo diferente de outra organização. O IBGE disponibiliza diversos dados que produz no SIDRA, Sistema IBGE de Recuperação Automática. Navegando pela página, chegamos podemos ir em Pesquisa > Indicadores e escolher algum indicador. Utilizaremos como exemplo a [Pesquisa Industrial Mensal - Produção Física - PIM-PF-Brasil](https://sidra.ibge.gov.br/pesquisa/pim-pf-brasil/tabelas), em particular a tabela [Produção Física Industrial, por seções e atividades industriais](https://sidra.ibge.gov.br/tabela/3653)

Chegamos a um formulário. Poderíamos, tal como no tutorial anterior, preencher o formulário, submetê-lo e recuperar suas resposta. Entrentanto, o SIDRA oferece a possibilidade, após preenchido o formulário manualmente, clicarmos num botão ao pé do formulário (ícone de link, entre o ícone de disquete e de engrenagem) que nos permite ver como seria feita a mesma consulta utilizando a API em vez do formulário. No exemplo, selecionaremos todos os períodos para obter a seguinte url:

```{r}
https://apisidra.ibge.gov.br/values/t/3653/n1/all/v/3135/p/all/c544/129314/d/v3135%201
```

Mas você pode alterá-la completamente a consultar se quiser experimentar com os dados: 

Repetindo o que fizemos com a API do BCB

```{r}
sidra_3653_endpoint <- GET("https://apisidra.ibge.gov.br/values/t/3653/n1/all/v/3135/p/all/c544/129314/d/v3135%201")
sidra_3653_json <- rawToChar(sidra_3653_endpoint$content)
sidra_3653 <- fromJSON(sidra_3653_json, flatten=TRUE)
View(sidra_3653)
```
