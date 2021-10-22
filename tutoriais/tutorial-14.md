# Tutorial 14 - Extraindo informações de pdfs

OBSERVAÇÃO - este exemplo tem data de validade e pode deixar de funcionar após algum tempo da preparação do tutorial.

Neste tutorial vamos ver uma forma simples de extrair informações de pdfs utilizando o pacote _pdftools_ em combinação com o pacote _stringr_. Diferentemente páginas de HTML, quando lidamos com pdfs não temos garantia que podemos extrair a informação do arquivo com precisa e por isso precisamos de ferramentes de limpeza e preparação de texto.

## Boletins do CVE

Nosso objetivo será construir a série de óbitos por coronavírus do Estado de São Paulo a partir dos Boletins publicados diariamente pelo Centro de Vigilância Epidemiológica. Os boletins diários são idênticos entre si (pelo menos para o período mais recente) e publicados em .pdf. Os caracteres do boletim já estão reconhecidos como tal e não são apenas imagem, o que nos poupa uma parte do trabalho.

Antes de aprendermos sobre o pacote _pdftools_, vamos raspar os boletins da [página do CVE](http://www.saude.sp.gov.br/cve-centro-de-vigilancia-epidemiologica-prof.-alexandre-vranjac/areas-de-vigilancia/doencas-de-transmissao-respiratoria/coronavirus-covid-19/situacao-epidemiologica). Os arquivos todos estão em uma página única e precisamos extrair desta página os urls de cada um dos boletins para podermos fazer o download dos arquivos.

Leia o código abaixo e tente entender sozinha ou sozinho o seu funcionamento. Utilize o que aprendeu nos tutoriais anteriores:

```{r}
library(rvest)
library(stringr)
library(pdftools)

pagina <- read_html("http://www.saude.sp.gov.br/cve-centro-de-vigilancia-epidemiologica-prof.-alexandre-vranjac/areas-de-vigilancia/doencas-de-transmissao-respiratoria/coronavirus-covid-19/situacao-epidemiologica")

nodes_urls_pagina <- html_nodes(pagina, xpath = '//article//a')

urls_boletins <- html_attr(nodes_urls_pagina, name = 'href')
urls_boletins <- str_subset(urls_boletins, '.pdf')
urls_boletins <- str_subset(urls_boletins, 'coronavirus')
urls_boletins <- str_subset(urls_boletins, 'attach=true', negate = T)
urls_boletins <- unique(urls_boletins)
urls_boletins <- paste0("http://www.saude.sp.gov.br", urls_boletins)
```

Pronto! Temos os urls de todos os boletins. Precisamos agora fazer download de todos para podermos ler os documentos. Vamos, assim criar um diretório com a função "dir.create" e, em loop, vamos baixar os 9 últimos boletins (que são os primeiros 10 urls de nosso vetor de urls). Novamente, use o que já aprendeu da linguagem para compreender o código abaixo:

```{r}
dir.create("boletins_cve")

j <- 1
for (url_boletim in urls_boletins[1:9]){
  download.file(url_boletim, paste0("boletins_cve/boletim", j, ".pdf"))  
  j <- j + 1
}
```

Na pasta boletins\_cve temos os 9 documentos em .pdf com os quais vamos trabalhar.

```{r}
list.files('boletins_cve')
```

## Extraindo informação de 1 boletim

Nosso objetivo é extrair uma única informação do boletim, que é o número de óbitos confirmados e notificados no dia da publicação do documento. Nossa estratégia para extrair essa informação do documento será tentar encontrar regularidades no texto que nos permitam extrair apenas essa informação. Vamos procurar por caracteres que antecedem e sucedem o número desejado e que não variem entre os arquivos do boletim.

Vamos começar trabalhando com um único boletim (o último) com a função "pdf\_text", que transforma em um vetor de texto um documento em pdf, tendo em cada posição do vetor o conteúdo de uma página. Nosso exemplo contém apenas 1 página. Faça download para o seu computador e abra o documento antes de começar. Veja que a informação que nos interesse está no canto superior direito do documento. Agora, transforme-o em texto:

```{r}
texto_boletim <- pdf_text('boletins_cve/boletim1.pdf')
```

E examine o conteúdo:

```{r}
texto_boletim
```

Há diversos espaços e caracteres indesejáveis no conteúdo. Vamos retirar todos os espaços, tabs ("/t") e quebras de linha ("\n") e colocar todos os carecteres em minúsculo:

```{r}
texto_boletim <- str_replace_all(texto_boletim, " ", "")
texto_boletim <- str_replace_all(texto_boletim, "/t", "")
texto_boletim <- str_replace_all(texto_boletim, "\n", "")
texto_boletim <- str_to_lower(texto_boletim)
```

É difícil encontrar a informação que nos interesse num texto tão sem estutura. Vamos começar, dessa forma, examinando os caracteres que estão ao redor do número de óbitos do último boletim.

OBS: certifique-se de que está trabalhando com o mesmo boletim. Caso contrário, o número de óbitos do dia será diferente:

```{r}
str_locate(texto_boletim, '151.386')
```

Com "str\_locate" localizamos a posição do primeiro e do último digítido da informação que buscamos (use "str\_locate\_all" se houver mais de uma ocorrência do padrão buscado no texto).

Vamos usar a função "str\_sub" para examinar o trecho ao redor do número de óbitos no estado naquele dia:

```{r}
str_sub(texto_boletim, 100, 350)
```

Note que há um padrão, pois a informação vem precedidade de um caracter especial e sucedida por outro. Vamos, assim novamente com "str\_locate" vamos delimitir onde começa e onde termina a informação desejada SEM depender da própria informação, que varia a cada versão do documento:

```{r}
inicio <- str_locate(texto_boletim, '¥')[1] + 1
fim <- str_locate(texto_boletim, '¥*fonte')[1] - 3
obitos <- str_sub(texto_boletim, inicio, fim)
```

Pronto. Vamos agora aplica a mesma regra de busca do número de óbitos a mais documentos e ver se funciona.

## Documentos pdf em loop

Aproveitando a regra que criamos acima, vamos extrair a informação dos nove documentos que baixamos. Veja a construção do código abaixo e tente compreendê-lo:

```{r}
serie_obitos <- c()

for(boletim in list.files('boletins_cve')){
  texto_boletim <- pdf_text(paste0('boletins_cve/', boletim))
  texto_boletim <- str_replace_all(texto_boletim, " ", "")
  texto_boletim <- str_replace_all(texto_boletim, "/t", "")
  texto_boletim <- str_replace_all(texto_boletim, "\n", "")
  texto_boletim <- str_to_lower(texto_boletim)
  inicio <- str_locate(texto_boletim, '¥')[1] + 1
  fim <- str_locate(texto_boletim, '¥*fonte')[1] - 3
  serie_obitos <- c(serie_obitos, str_sub(texto_boletim, inicio, fim))
}

serie_obitos <- rev(serie_obitos)
serie_obitos <- as.numeric(serie_obitos)
```

Pronto! Temos agora uma série de 9 dias do número acumulado de óbitos por coronavírus confirmados e notificados no Estado de São Paulo extraída dos boletins diários!

