###### PRIMEIRA PARTE ######

#### INSTALAR/CARREGAR AS BIBLIOTECAS NECESSÁRIAS #### 
## REMOVA "#" E EXECUTE A LINHA (CTRL + ENTER)
## APÓS A INSTALAÇÃO, ADICIONE NOVAMENTE "#" PARA EVITAR REFAZER A INSTALAÇÃO

#install.packages(c("tidyverse", "readxl", "vctrs", 
#                   "scales", "stargazer", "psych",
#                   "kableExtra", "plm"))
#tinytex::install_tinytex()

#### CARREGAR OS DADOS #### 
# BASE FORNECIDA PELO ADHMIR R. V. GOMES
# MODIFICADA MANUALMENTE

# USE O CAMINHO:
# FILE -> IMPORT DATASET -> FROM EXCEL...

library(readxl)
exemplo <- read_excel("exemplo.xlsx")

# AJUSTAR A BASE PARA FORMATO EM PAINEL

library(tidyverse)

painel <- 
pivot_longer(exemplo, cols  = -c(1:5), names_to = c(".value", "ano"), 
             names_sep = "\\.") %>%
  arrange(`Company Name`)

names(painel)

painel <-
  rename(painel, nome = `Company Name`) %>%
  rename(hq = `Country of Headquarters`) %>%
  rename(exchange = `Country of Exchange`) %>%
  rename(setor = `TRBC Economic Sector Name`)

# AJUSTES DE FORMATAÇÃO DOS VALORES

library(scales)
painelmoeda <- painel %>%
  mutate_at(c("ATC", "PTC", "ATR", "EBITDA", "RT"), 
            label_dollar(prefix = "R$ ", 
                         decimal.mark = ",",
                         big.mark = "."))

# Média de RT por setor

mediasetor <- 
  group_by(painel, setor, ano) %>% 
  summarize(RT = mean(RT, na.rm = TRUE)) %>%
  mutate_at(c("RT"), 
            label_dollar(prefix = "R$ ", 
                         decimal.mark = ",",
                         big.mark = ".",
                         accuracy = 1))

mediasetorEBITDA <- 
  group_by(painel, setor, ano) %>% 
  summarize(EBITDA = mean(EBITDA, na.rm = TRUE)) %>%
  mutate_at(c("EBITDA"), 
            label_dollar(prefix = "R$ ", 
                         decimal.mark = ",",
                         big.mark = ".",
                         accuracy = 1))

mediasetorPTC <- 
  group_by(painel, setor, ano) %>% 
  summarize(PTC = mean(PTC, na.rm = TRUE)) %>%
  mutate_at(c("PTC"), 
            label_dollar(prefix = "R$ ", 
                         decimal.mark = ",",
                         big.mark = ".",
                         accuracy = 1))

#### ESTATÍSTICA DESCRITIVA #### 

library(stargazer)

painel.df <- 
  as.data.frame(painel) %>%
  stargazer(type = "text")
summary(painel)

#### CRIANDO NOVAS VARIÁVEIS ####

# Tamanho (TAM) e ROA
painelnovo <- painel %>%
  drop_na() %>%
  mutate(TAM = log(ATR)) %>%
  mutate(ROA = (EBITDA/ATR))

# Market share (MS) e grau de concentração do setor - Herfindahl-Hirschman Index (IHH) 
painelnovo <- painelnovo %>%
  group_by(ano, setor) %>% 
  mutate(MS = ATR/sum(ATR)) %>%
  mutate(IHH = (sum(((ATR/sum(ATR)*100)^2))))
  
