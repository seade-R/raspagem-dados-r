# Aula 5 - Acessando APIs com R

## Objetivos gerais

Nos tutoriais anteriores vimos com fazer download de documentos e como extrair informações de páginas de internet em geral. Em particular no último caso, a informação é disponibilizada de maneira que dificulta sua coleta contínua, pois não foi planejada para tanto. No encontro de hoje veremos como utilizar APIs com R, que são interfaces desenhadas justamente para facilitar o acesso aos dados de um serviço na Web.

## Roteiro

0 - Faremos nosso encontro virtual às 9h30. Faremos um panomara do que vimos até agora no curso e conversaremos sobre formulários e sobre os exemplos do dia.

1 - Antes de começar a trabalhar, por favor, preencha o formulário sobre o interesse em participar dos encontros seguintes e aprender sobre tópicos extras do curso: (1) extração de informações de documentos de imagem e/ou pdf; e (2) mineração de textos com R.

1 - Comece às 9h do ponto onde tiver parado (links para os tutoriais anteriores: [Tutorial 1](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-01.md), [Tutorial 2](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-02.md), [Tutorial 3](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-03.md), [Tutorial 4](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-04.md), [Tutorial 5](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-05.md), [Tutorial 6](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-06.md), [Tutorial 7](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-07.md), [Tutorial 8](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-08.md), e [Tutorial 9](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-09.md))

2 - Quando tiver terminado o Tutorial 9, comece o e [Tutorial 10](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-10.md) para aprender sobre como acessar APis com R.

3 - Se tiver interesse em se aprofundar no tema, convém ler duas "vinhetas" do pacote _httr_: [Getting started with httr](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html) e [Best practices for API packages](https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html).

4 - Finalmente, se tiver interesse específico no Twitter, o [Tutorial 11](https://github.com/seade-R/raspagem-dados-r/blob/main/tutoriais/tutorial-11.md) apresenta o pacote twitteR para consulta de dados do Twitter via API. 

## Desafios

Ao final dos 5 encontros você pode se aventurar coletando conteúdo na internet. Deixo, assim, os desafios colocados na semana passada e também um novo desafio.

  - Buscar currículos lattes (os urls, não o conteúdo) de pesquisadores (por exemplo, a partir de um determinado tema de pesquisa) - [http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=apresentar](http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=apresentar)

- Realizar buscas de processos no STF [http://www.stf.jus.br/portal/peticaoInicial/pesquisarPeticaoInicial.asp](http://www.stf.jus.br/portal/peticaoInicial/pesquisarPeticaoInicial.asp)

- Raspar notícias em um jornal online

- Obter dados de uma API de seu interesse. Pode ser algo lúdico ou diretamente relacionado ao seu trabalho.

Comece conhecendo a página, os urls, os nodes dos conteúdos que interessam, etc. Reaproveite código de tutoriais anteriores. Quebre a cabeça, mas peça auxílio.