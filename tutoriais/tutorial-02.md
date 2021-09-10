# tutorial 2 - Raspando uma tabela de uma página html

## Apresentação

No primeiro tutorial vimos com fazer o download automático de arquivos de dados em formato .csv. Em geral, quando trabalhamos com fontes oficiais de dados, as informações são disponibilizadas em formato aberto ou, pelo menos, em arquivos de fácil manipulação, como .xlsx. Entretanto, boa parte (talvez a maior parte?) da informação que encontramos na internet não está disponível dessa forma, mas no corpo de páginas em formato html.

Neste segundo tutorial, veremos o caso mais simples de extração de informação de um documento html na web: a raspagem de tabelas. O alvo da nossa coleta de dados será a tabela com informações sobre as regiões metropolitanas do Estado de São Paulo que faz parte do verbete [Lista de regiões metropolitanas de São Paulo por população](https://pt.wikipedia.org/wiki/Lista_de_regi%C3%B5es_metropolitanas_de_S%C3%A3o_Paulo_por_popula%C3%A7%C3%A3o) da Wikipedia.

Raspar uma tabela de uma página é o primeiro passo para raspagens mais complexas, como extrair o conteúdo de texto de um conjunto de notícias no portal de um jornal ou consultar sequencialmente um formulário (por exemplo, do STF ou outro tribunal), temas de nosso próximos encontros.

## "rvest", o pacote para "colheita" de dados

Para raspagem de páginas de internet utilizaremos primordialmente as funções do pacote _rvest_, que, tal como _readr_, _dplyr_ e _ggplot2_, é resultado do movimento ligado à empresa RStudio de "reescrever" a linguagen R. Ao longo dos próximos tutoriais utilizaremos diversas funções do pacote _rvest_. Vamos carregá-lo em nossa sessão:

```{r}
library('rvest')
```

## Extraindo uma tabela do Wikipedia

O documento do qual extrairemos a informação que desejamos é a própria página do verbete da Wikipedia. Assim, em vez de copiar e armazenar o url de um arquivo, vamos fazer isso com o url do verbete. Como estamos criando um objeto, precisamos escolher um nome arbitrário e usar o símbolo de atribuição ("<-").

```{r}
url_wikipedia_rm_sp <- 'https://pt.wikipedia.org/wiki/Lista_de_regi%C3%B5es_metropolitanas_de_S%C3%A3o_Paulo_por_popula%C3%A7%C3%A3o'
```

Nosso primeiro passo armazenar todo o conteúdo do url em um objeto em R. Mas qual é o conteúdo de uma página de internet, ou seja, o que é um documento html? Vá novamente ao verbete da Wikipedia, clique com o botão direito do mouse e escolha "View Page Source" (ou algo similar). Você verá o código html, a estrutura do documento que seu navegador interpreta e transforma na página que é confortável para navegarmos -- seria horrível navegar só pelo código!

Todo documento html é um tipo particular de XML, que quer dizer "Extensible Markup Language", ou seja um documento escrito em uma linguagem com "marcação" As "marcações" em documentos html/xml organizam seu conteúdo. Em nosso curso, utilizaremos essas "marcações" para nos guiarmos pelo documento e extraírmos a informação dele. No nosso segundo encontro conversaremos coletivamente sobre este assunto.

Para extrair informação de uma página de html precisamos, assim, "importar" o seu código fonte. O pacote _readr_ tem uma função simples que faz isso: "read\_html". No código a seguir, vamos criar um objeto, que por falta de criatividade chamaremos de "pagina", que conterá o código do verbete que nos interessa:

```{r}
pagina <- read_html(url_wikipedia_rm_sp)
```

"pagina" é um objeto de R (tal como um vetor ou um data frame) que pertence às classes "xml_document" e "xml_node":

```{r}
class(pagina)
```

Não é muito agradável examiná-lo diretamente em R. A linguagem R não foi desenhada originalmente para trabalhar com objetos dessa classe, ainda que agora tenhamos diversos métodos para fazê-lo. Utilzaremos o próprio navegador para entender o conteúdo da página para, na sequência, extraí-lo em R. Entraremos em detalhe nos próximos encontros tutoriais.

A extração de tabelas de um documento html é certamente o caso mais simples. Se há uma tabela evidente na página, como no caso do verbete das Regiões Metropolitanas de São Paulo, podemos extraí-la com a função "html\_table". Antes de discutí-la vamos examinar o resultado de sua aplicação:

```{r}
tabelas <- html_table(pagina)
```

Execute o objeto para vermos seu conteúdo:

```{r}
tabelas
```

O objeto "tabelas" (com nome propositalmente no plural) contém 4 tabelas extraídas da página do verbete. A que víamos no centro da página é a 3a, apenas. "html\_table" identifica tudo que é "tabela" na página, mesmo que não pareça uma tabela para um ser humano, e constrói uma lista que contém uma tabela em cada posição. Antes de extraírmos a lista de tabelas da página, não tínhamos como saber quantas tabelas havia lá sem examinar minuciosamente o código fonte. Mas sabíamos, por que parecia evidente, que a tabela que desejamos extrair estaria lá.

```{r}
class(tabelas)
```

"tabelas" pertence à classe de objetos lista. Listas em R são objetos muito importantes e, sobretudo, extremamente flexíveis. Por exemplo, a nossa lista de tabelas contém 4 tabelas de dimensões e conteúdos bastante variados. Veremos mais sobre listas no curso.


Para extraírmos um elemento de uma lista podemos usar a sua posição. A tabela que nos interessa está na posição 3 e, com auxílio do símbolo [[]], fazemos uma cópia da terceira posição da lista para um novo objeto, que chamaremos de "tabela_rm". Note-se que é uma atribuição e que o objeto tabelas permanece inalterado após a "extração" (na verdade é uma cópia) do elemento na sua 3a posição:

```{r}
tabela_rm <- tabelas[[3]]
```

Diferentemente de "tabelas", o objeto "tabelas_rm" é um data frame (uma matriz dde dados). Em poucos passos conseguimos converter uma tabela de uma página de internet em um objeto de R pronto para ser transformado e analisado.

```{r}
class(tabela_rm)
```

Além da classe "data.frame", "tabela_rm" pertence a outras duas classes que, por enquanto, podemos ignorar. Basta saber que tudo que pode ser feito a um data frame vale para nosso novo objeto.

## Exportando um data frame

Da mesma forma que importamos conjuntos de dados a partir de arquivos .csv, podemos exportar um data frame para um arquivo em diversos formatos. O pacote _readr_ contém, além das funções de prefixo "read", funções de prefixo "write". Vamos, assim, carregá-lo (se ainda não tivermos carregado nesta sessão):

```{r}
library(readr)
```

E exportar o objeto "tabela_rm" como um arquivo em formato .csv (com ponto e vírgula como separador) e com nome 'tabelas_rm.csv': 

```{r}
write_csv2(tabela_rm, 'tabelas_rm.csv')
```

Pronto! Paramos por aqui