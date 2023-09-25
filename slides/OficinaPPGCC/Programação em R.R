###### PRIMEIRA PARTE ######

#### INSTALAR/CARREGAR AS BIBLIOTECAS NECESSÁRIAS
## REMOVA "#" E EXECUTE A LINHA (CTRL + ENTER)
## APÓS A INSTALAÇÃO, ADICIONE NOVAMENTE "#" PARA EVITAR REFAZER A INSTALAÇÃO

install.packages(c("tidyverse", "readxl", "vctrs", 
                   "scales"))

#tinytex::install_tinytex()

#### CARREGAR OS DADOS
# BASE FORNECIDA PELO ADHMIR R. V. GOMES
# MODIFICADA MANUALMENTE

# USE O CAMINHO:
# FILE -> IMPORT DATASET -> FROM EXCEL...

library(readxl)
#exemplo <- read_excel("exemplo.xlsx")

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

