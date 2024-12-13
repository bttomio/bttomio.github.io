# Carregar as bibliotecas necessárias
library(shiny)
library(DT)
library(dplyr)
library(ggplot2)

# Definir a interface do usuário
ui <- navbarPage(
  title = "Dashboard Cesta de Produtos",
  
  # Página inicial (Capa) sem seleção de página
  tabPanel("Início",
           fluidPage(
             titlePanel("Bem-vindo ao Dashboard"),
             
             mainPanel(
               h4("Este é um painel de informações sobre a Cesta de Produtos com variação mensal."),
               p("Escolha uma das opções acima para acessar as páginas de dados filtrados.")
             )
           )),
  
  # Página de "Cesta de Produtos - Variação Mensal"
  tabPanel("Cesta de Produtos - Variação Mensal",
           fluidPage(
             # Texto destacado
             tags$div(style = "font-size: 20px; font-weight: bold; color: #1a1a1a; margin-bottom: 20px;", 
                      "Para visualizar um gráfico, selecione: Cidade."),
             
             titlePanel("Cesta de Produtos - Variação Mensal"),
             
             sidebarLayout(
               sidebarPanel(
                 selectInput("cidade", "Selecione a Cidade", choices = c("Todos", unique(CT$Cidade)), selected = "Todos"),
                 selectInput("mes", "Selecione o Mês", choices = c("Todos", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", 
                                                                   "Junho", "Julho", "Agosto", "Setembro", "Outubro", 
                                                                   "Novembro", "Dezembro"), selected = "Todos"),
                 selectInput("ano", "Selecione o Ano", choices = c("Todos", unique(CT$Ano)), selected = "Todos")
               ),
               mainPanel(
                 h3("Tabela de Dados"),
                 DTOutput("tabela_cesta"),
                 
                 # Gráfico da variação da Cesta de Produtos
                 conditionalPanel(
                   condition = "input.cidade != 'Todos'",
                   plotOutput("grafico_cesta")
                 )
               )
             )
           )),
  
  # Página de "Dados dos Produtos"
  tabPanel("Dados dos Produtos",
           fluidPage(
             # Texto destacado
             tags$div(style = "font-size: 20px; font-weight: bold; color: #1a1a1a; margin-bottom: 20px;", 
                      "Para visualizar um gráfico, selecione: Produto e Cidade."),
             
             titlePanel("Dados dos Produtos - Variação Mensal"),
             
             sidebarLayout(
               sidebarPanel(
                 selectInput("produto", "Selecione o Produto", choices = c("Todos", unique(VAR_PROD$Produto)), selected = "Todos"),
                 selectInput("cidade_produto", "Selecione a Cidade", choices = c("Todos", unique(VAR_PROD$Cidade)), selected = "Todos"),
                 selectInput("mes_produto", "Selecione o Mês", choices = c("Todos", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", 
                                                                           "Junho", "Julho", "Agosto", "Setembro", "Outubro", 
                                                                           "Novembro", "Dezembro"), selected = "Todos"),
                 selectInput("ano_produto", "Selecione o Ano", choices = c("Todos", unique(VAR_PROD$Ano)), selected = "Todos")
               ),
               mainPanel(
                 h3("Tabela de Dados dos Produtos"),
                 DTOutput("tabela_produtos"),
                 
                 # Gráfico da variação dos produtos
                 conditionalPanel(
                   condition = "input.produto != 'Todos' && input.cidade_produto != 'Todos'",
                   plotOutput("grafico_produtos")
                 )
               )
             )
           ))
)

# Definir a lógica do servidor
server <- function(input, output, session) {
  
  # Garantir que a coluna 'Mês' esteja como texto
  CT$Mês <- as.character(CT$Mês)
  VAR_PROD$Mês <- as.character(VAR_PROD$Mês)
  
  # Filtrar dados da Cesta de Produtos com base nas seleções do usuário
  dados_filtrados <- reactive({
    CT %>%
      filter(
        (input$cidade == "Todos" | Cidade == input$cidade),
        (input$mes == "Todos" | Mês == input$mes),
        (input$ano == "Todos" | Ano == input$ano)
      )
  })
  
  # Filtrar dados dos Produtos com base nas seleções do usuário
  dados_produtos_filtrados <- reactive({
    VAR_PROD %>%
      filter(
        (input$produto == "Todos" | Produto == input$produto),
        (input$cidade_produto == "Todos" | Cidade == input$cidade_produto),
        (input$mes_produto == "Todos" | Mês == input$mes_produto),
        (input$ano_produto == "Todos" | Ano == input$ano_produto)
      )
  })
  
  # Renderizar a tabela de Cesta de Produtos
  output$tabela_cesta <- renderDT({
    datatable(dados_filtrados(), 
              options = list(
                scrollY = "300px",  # Define a altura da barra de rolagem
                scrollCollapse = TRUE,  # Colapsa a tabela se houver poucos dados
                paging = FALSE  # Desabilita a paginação
              )) %>%
      formatStyle(
        'Variação (%)',  # Aplica o estilo na coluna 'Variação (%)'
        color = styleInterval(0, c('red', 'black'))  # Colore os números negativos de vermelho e os positivos de preto
      ) %>%
      formatRound(
        c("Cesta", "Variação (%)"),  # As colunas a serem formatadas
        digits = 2  # Número de casas decimais
      )
  })
  
  # Renderizar a tabela de Dados dos Produtos
  output$tabela_produtos <- renderDT({
    datatable(dados_produtos_filtrados(), 
              options = list(
                scrollY = "300px",  # Define a altura da barra de rolagem
                scrollCollapse = TRUE,  # Colapsa a tabela se houver poucos dados
                paging = FALSE  # Desabilita a paginação
              )) %>%
      formatStyle(
        'Variação (%)',  # Aplica o estilo na coluna 'Variação (%)'
        color = styleInterval(0, c('red', 'black'))  # Colore os números negativos de vermelho e os positivos de preto
      ) %>%
      formatRound(
        c("Média (produto)", "Variação (%)"),  # As colunas a serem formatadas
        digits = 2  # Número de casas decimais
      )
  })
  
  # Renderizar o gráfico de Variação Mensal da Cesta de Produtos
  output$grafico_cesta <- renderPlot({
    dados <- dados_filtrados()
    
    # Verifica se os dados estão vazios antes de tentar criar o gráfico
    req(nrow(dados) > 0)
    
    # Garantir que o eixo Mês seja tratado como uma variável temporal
    dados$Mês <- factor(dados$Mês, levels = c("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", 
                                              "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"))
    
    ggplot(dados, aes(x = Mês, y = `Variação (%)`, group = Cidade, color = Cidade)) +
      geom_line() +
      geom_point() +
      labs(title = paste("Variação da Cesta de Produtos em", input$cidade), x = "Mês", y = "Variação (%)") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 0, hjust = 0.5, size = 14),  # Eixo X horizontal com tamanho de fonte aumentado
        axis.text.y = element_text(size = 14),  # Tamanho do texto do eixo Y
        axis.title = element_text(size = 16),  # Tamanho do título dos eixos
        plot.title = element_text(size = 18, face = "bold"),  # Tamanho do título do gráfico
        legend.position = "none"  # Remove a legenda
      )
  })
  
  # Renderizar o gráfico de Variação Mensal dos Produtos
  output$grafico_produtos <- renderPlot({
    dados_produtos <- dados_produtos_filtrados()
    
    # Verifica se os dados dos produtos estão vazios antes de tentar criar o gráfico
    req(nrow(dados_produtos) > 0)
    
    # Garantir que o eixo Mês seja tratado como uma variável temporal
    dados_produtos$Mês <- factor(dados_produtos$Mês, levels = c("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", 
                                                                "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"))
    
    ggplot(dados_produtos, aes(x = Mês, y = `Variação (%)`, group = Produto, color = Produto)) +
      geom_line() +
      geom_point() +
      labs(title = paste("Variação do Produto:", input$produto), x = "Mês", y = "Variação (%)") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 0, hjust = 0.5, size = 14),  # Eixo X horizontal com tamanho de fonte aumentado
        axis.text.y = element_text(size = 14),  # Tamanho do texto do eixo Y
        axis.title = element_text(size = 16),  # Tamanho do título dos eixos
        plot.title = element_text(size = 18, face = "bold"),  # Tamanho do título do gráfico
        legend.position = "none"  # Remove a legenda
      )
  })
}

# Executar o aplicativo Shiny
shinyApp(ui = ui, server = server)

