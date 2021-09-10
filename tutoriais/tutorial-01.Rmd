# Tutorial 1 - Download automático de arquivos

## Apresentação

No trabalho cotidiano com dados é comum precisarmos fazer download de um mesmo arquivo que é atualizado com alguma periodicidade. Neste primeiro tutorial daremos nossos primeiros passos na linguagem R aprendendo a automatizar o download de arquivos de bases de dados e a carregá-los em R. No percurso, veremos alguns elementos e conceitos fundamentais da linguagem, como objeto e classe. Trabalharemos com dois exemplos simples: o dado de quantidade de alunos por escola na rede estadual de ensino em São Paulo, disponível no [repositório de dados da SEDUC-SP](https://dados.educacao.sp.gov.br/), e com os microdados de óbitos de 2019 disponibilizados no [repositório de dados do SEADE](https://repositorio.seade.gov.br/).

## Quantidade de alunos por tipo de ensino da rede estadual

A Secretaria Estadual de Educação do Estado de São Paulo disponibiliza dados sobre a rede estadual de ensino em um repositório CKAN no endereço [https://dados.educacao.sp.gov.br/](https://dados.educacao.sp.gov.br/), tal como utilizamos no SEADE. Você pode explorar o repositório antes de seguir com a atividade. Essa informação é atualizada duas vezes ao ano.

Em nosso exemplo vamos baixar os dados do primeiro semestre de 2019, que você pode acessar diretamente clicando [aqui](https://dados.educacao.sp.gov.br/dataset/quantidade-de-alunos-por-tipo-de-ensino-da-rede-estadual).

Se você clicar com o botão esquerdo do mouse em "Download", baixará o dado normalmente. Mas esse não é nosso objetivo. Queremos construir um pedaço de código que faça isso por nós. Há várias razões para que isso seja mais interessante. Por exemplo, se você quiser que alguém repita os mesmos passos de uma análise que começa com a coleta do arquivo na internet, ao "documentar em código" processo de coleta você permitirá que esse alguém replique com exatidão o seus passos. Cliques, por outro lado, são mais difíceis de se documentar.

É possível também que o arquivo sofra atualizações pontuais e/ou periódicas. Se você precisa fazer a ingestão regular desse arquivo, terá que repetir os cliques a cada nova versão publicada dos dados. Com a coleta feita via código, por outro lado, você só precisará reexecutar o script, tarefa cuja repetição pode ser agendada para execução automática (por exemplo, num servidor do SEADE).

Nosso primeiro passo para download automático do arquivo consiste em armazenar em um simples objeto de texto. Em R, diferentemente de outros softwares de estatística como SPSS ou Stata, podemos criar e armazenar _objetos_ de várias _classes_ e não apenas matrizes de dados. Por exemplo, vamos criar um _vetor_ de texto que contém apenas um elemento, que será o url dos dados que pretendemos baixar.

Para quem está se habituando à linguagem, para criar um objeto em R utilizamos um símbolo especial, o <- . Este é o símbolo de "atribuição". No nosso exemplo, copiaremos o url do arquivo e atribuiremos um nome a ele, ou seja, o armazenaremos na memória (RAM) do computador sob um nome arbitrário. No nosso caso, vamos chamá-lo de "url\_seduc", mas você poderia escolher qualauqer nome (sujeito a algumas regras e convenções).

Assim, vá ao botão "Download" na página dos dados que queremos obter (clique [aqui](https://dados.educacao.sp.gov.br/dataset/quantidade-de-alunos-por-tipo-de-ensino-da-rede-estadual) caso tenha perdido o endereço) e clique com o botão direito do mouse. A seguir, escolha "Copiar Link" ou opção equivalente em seu navegador. E vamos ao nosso primeiro pedaço de código:

```{r}
url_seduc <- 'https://dados.educacao.sp.gov.br/sites/default/files/VW_ALUNOS_POR_ESCOLA_20190517_0.csv'
```

Pronto. Temos um objeto em nosso "Environment" (que podemos vulgarmente pensar como sendo a memória temporária da nossa sessão de R) com o nome "url\_seduc" que contém o url do arquivo. Se executarmos um pedaço de código com esse nome veremos que o seu conteúdo será "impresso" no Console:

```{r}
url_seduc
```

Podemos examinar o conteúdo deste objeto com a função _class_.

```{r}
class(url_seduc)
```

Note que, como _class_ é um função, abrimos um parênteses e inserimos um _argumento_ ou _parâmetro_, um input. Como resultado temos a _classe_ do objeto, que, neste caso, é "character", pois se trata um vetor de texto.

Os dois elementos mais comuns na linguagem R são, assim, _objetos_ e _funções_. Objetos são, de maneira grosseira, os elementos que armazenam informações inseridas/importadas pelo usuário. Recebem nomes arbitrários e são criados quando utilizamos o símbolo de atribuição "<-". Funções, por outro lado, são comandos que, a partir de parâmetros (ou argumentos) inseridos pelo usuário (que pode ser objetos ou outras informações como veremos a seguir) produzem algum efeito. Para efeitos do curso, parâmetros e argumentos são sinônimos.

### Função para downnload

Neste nosso primeiro tópico, a função fundamental é _download.file_, cujo nome é auto-explicativo. A partir do url de um arquivo (primeiro parâmetro) a função fará o download e gravará o arquivo na pasta local do seu computador sob um nome (que inclui a extensão do arquivo) de seua escolha (segundo parâmetro). Veja seu uso:

```{r}
download.file(url_seduc, 'alunos_por_escola.csv')
```

Simples, não? A função recebeu o url, armazenado em "url\_seduc", e gravou o arquivo no computador sob o nome 'alunos_por_escola.csv'.

Note no código abaixo, equivalente, ao primeiro, que cada um dos parãmetros tem um nome. "url" é o nome do primeiro parâmetro e "destfile" do segundo.

```{r}
download.file(url = url_seduc, destfile = 'alunos_por_escola.csv')
```

Podemos omitir o "url =" e "desfile =" por que conhecemos suas posições. O uso do nome dos argumentos de uma função é opcional.

Note que o nome do arquivo que será gravado está entre aspas. Tanto "url" como "destfile" são parâmetros que recebem um texto. Mas, para "url" tinhamos um objeto que "representava" este texto. Para "destfile", inserimos o texto diretamente na função e, toda vez que trabalharmos com um texto em R, precisaremos mantê-lo dentro de aspas para que saibamos onde começa e onde termina (com números será diferente).

Em R, há várias maneiras e estilos de se construir para uma determinada tarefa. Por exemplo, em vez de armazenarmos o url em um objeto para depois utilizaá-lo na função de download, podemos colocá-lo diretamente, tal como fizemos para o argumento "destfile":

```{r}
download.file('https://dados.educacao.sp.gov.br/sites/default/files/VW_ALUNOS_POR_ESCOLA_20190517_0.csv', 'alunos_por_escola.csv')
```

Como o url é um texto grande, fica mais chato ler o código. O efeito, porém, é exatamente o mesmo.

Como podemos ter certeza que a função produziu o efeito desejado? O resultado da função "download.file" é baixar o arquivo no diretório de trabalho, que é uma pasta no computador no qual você está trabalho (no contexto do curso, dentro do seu usuário no servidor do Seade no qual o RStudio está instalado). Podemos examinar os arquivos do seu diretório de trabalho com a seguinte função:

```{r}
list.files()
```

Veja que ela é uma função (pois têm parênteses logo após seu nome) que não precisa de nenhum parâmetro obrigatório para funcionar. Veremos mais funções ao longo do curso e você se acostumará a investigar os parâmetros de uma função antes de utilizá-la.

Note o resultado da função no console. "list.files" imprime o nome de todos os documentos do seu diretório de trabalho (na forma de um vetor de texto) no console. O arquivo 'alunos_por_escola.csv' está lá, como queriamos.

O efeito da função download.file é exatamente o mesmo de um download manual no navegador. O arquivo, cujo conteúdo ainda desconhecemos, está baixado, mas não está disponível para análise em R ainda.

### Importando os dados para R

Para que fique disponível, precisamos importá-lo. Neste curso, evitaremos utilizar botões do RStudio. Em R, botões são pouco úteis e queremos aprender a construir códigos que, uma vez executados, realizem todas as etapas de coleta, preparação e análise dos dados sem que tenhamos processos manuais. Mas, por enquanto, você pode explorar o botão "Import Dataset" para carregar na sua sessão os dados que baixamos. Utilize a opção "From Text (readr)", pois arquivos em formato .csv são arquivos de texto que contém matrizes de dados cujas colunas estão separadas em cada linha por vírgulas ou ponto e vírgula (no nosso exemplo é ponto e vírgular).

Escolha também a opção que tem "readr" entre parênteses, pois este é o nome do _pacote_ para importação de dados que utilizaremos preferencialmente no curso. O outro, "base", é o pacote básico de R.

### Pacotes em R

O que são pacotes em R? Pacotes são coleções de funções (e também objetos, às vezes, mas sobretudo funções) que não estão disponíveis no conjunto básico de funcionalidades da linguagem. Pacotes são construídos pela comunidade de R e existem milhares deles. Todos os dias, algumas dezenas de novos pacotes são inseridos diariamente. Há pacotes complexos, como _dplyr_ e _ggplot2_ (protagonistas do nosso curso de introdução) que reescrevem a forma de manipularmos dados e construírmos gŕaficos, até pacotes banais, que servem para acessarmos os dados de alguma API de uma organização.

Neste curso, utilizaremos diversos pacotes que nos auxiliarão na aquisição de informações na web, na extração de informações de páginas de html, na preparação e limpeza de textos, etc. Para abertura de dados, utilizaremos o _readr_.

Obs: _dplyr_, _ggplot2_ e _readr_ são 3 dos pacotes que compõem o _tidyverse_, que é um "universo" de pacotes e parte de um movimento de reescrever a linguagem sobre o qual conversaremos em nossos encontros.

Pacotes precisam ser instalados para podermos trabalhar com eles em R. Discutiremos a instalação de pacotes em outro momento. Por enquanto, vamos trabalhar apenas com pacotes já instalados no nosso servidor.

Toda vez que precisarmos de uma pacote, temos que "carregá-lo". Para carregar um pacote, utilizamos a função "library":

```{r}
library(readr)
```

Pronto! Temos agora disponíveis as funções de importação de dados que fazem parte do pacote _readr_. Para os dados de alunos por escola, utilizaremos a função "read\_csv2", que faz a leitura de arquivos no formato .csv e cujo separado de colunas é ponto e vírgula.

O resultado de "read\_csv2" é a criação de um data frame, que é, em R, uma matriz de dados, tabela, banco de dados, ou conjunto de dados, dependendo de como você está habituada ou habituado a chamar. Data frames são os objetos mais utilizados em R e, basicamente, nossa tarefa nesse curso será automatizar a coleta de dados (em arquivos de dados ou "raspado" de páginas de html) para transformá-los em data frames em R e destiná-los à análise.

Para que o resultado da aplicação da função "read\_csv2" fique armazenado na memória da nossa sessão e disponível para uso, precisamos atribuí-lo a um objeto. Vamos escolher o nome "dados_seduc", arbitrário, para este objeto. Vamos examinar o uso de "read\_csv2":

```{r}
dados_seduc <- read_csv2('alunos_por_escola.csv', col_names = FALSE)
```

Como vamos criar um objeto (data frame), precisamos colocar o nome que atribuiremos a ele à esquerda e utilizar o símbolo de atribuição, "<-". A direita do símbolo de atribuição vem a função "read\_csv2". O prinicpal argumento para a função é o nome do arquivo de dados que será carregado.

Obs: Como o arquivo está no nosso diretório local, podemos apenas utilizar seu nome, 'alunos_por_escola.csv', sem colocar o caminho completo de pastas até o arquivo. Mas é perfeitamente possível carregar um arquivo que não esteja no diretório de trabalho utilizando o caminho completo, por exemplo, "C://Documentos//alunos_por_escola.csv". Em Windows é preciso duplicar as barras ou inverter as barras para que R leia corretamente o caminho.

O arquivo 'alunos_por_escola.csv' não contém na primeira linha o nome das colunas. Por essa razão, precisamos especificar um argumento auxiliar, "col\_names = FALSE", para que o conteúdo da primeira linha do arquivo não seja utilizado para nomear as variáveis do data frame.

Não se preocupe nesse momento em aprender a importar dados em R. Há um tutorial só sobre isso se você quiser fazer ao longo do curso.

Uma vez carregados, podemos examinar os dados. A função "head" imprime as primeiras linhas e colunas de um data frame no console para que possamos examiná-lo:

```{r}
head(dados_seduc)
```

Alternativamente, a função "View" (com V maiúsculo, algo raro em R), abre as 1000 primeiras linhas em uma janela na da área de scripts:

```{r}
View(dados_seduc)
```

Pronto! Baixamos nossos dados com um código simples e carregamos em nossa sessão. Paramos nosso exemplo aqui.

# Microdados de Óbitos

Vamos repetir os mesmos passos com um exemplo de dados do [repositório de dados do SEADE](https://repositorio.seade.gov.br/). Baixaremos e carregaremos os [Microdados de Óbitos de 2019](https://repositorio.seade.gov.br/dataset/microdados-obitos/resource/b7122d17-cffc-42ea-ae1f-579cc4cf4e21). 

Nosso primeiro passo será, como anteriormente, copiar o url do arquivo com o botão direito do mouse no botão "Baixar" guardá-lo no objeto:

```{r}
url_obitos_2019 <- "https://repositorio.seade.gov.br/dataset/30026c29-2237-4ee4-8650-ea3a9657dcd8/resource/b7122d17-cffc-42ea-ae1f-579cc4cf4e21/download/microdadosobitos2019.csv"
```

A seguir, faremos download dos dados:

```{r}
download.file(url_obitos_2019, 'obitos_2019.csv')
```

Ops! Deu erro!

O erro não está no código. O servidor do SEADE exige um tipo de certificação de identidade ao nos conectarmos a ele que impede o download com a função "download.file" por falha na conexão (o pessoal da SUTIN saberá explicar com muito mais competência que eu a razão disso).

Uma alternativa que temos à função "download.file" é utilizarmos a função "GET" do pacote _httr_ desativando a exigência de certificação. Não entraremos no detalhe do código abaixo. Mas teremos, desde já, um exemplo fácil de adaptar para quem consome com regularidade dados de nosso repositório. Adiante no curso veremos o pacote _ckanr_ que torna mais simples a aquisição de dados de repositórios baseados em CKAN, como o nosso no SEADE.

Em primeiro lugar, vamos carregar o pacote _httr_, que contém a função "GET":

```{r}
library(httr)
```

A seguir, vamos desabilitar a exigência de certificação:

```{r}
set_config(config(ssl_verifypeer = 0L))
```

Agora, em vez de "download.file", vamos utilizar função "GET", sem entrar em muito detalhes de sua sintaxe, que guarda alguma semelhança com "download.file":

```{r}
GET(url_obitos_2019, write_disk('obitos_2019.csv', overwrite=TRUE))
```

E vamos importar os dados baixados. Não é necessário carregar novamente o pacote _readr_, pois isso já foi feito anteriormente na mesma sessão de R:

```{r}
dados_obitos <- read_csv2('obitos_2019.csv')
```

Para finalizar, examine o resultado com as funções "head" ou "View"