library(readxl)
cv_entries <- read_excel("data/cv_entries.xlsx")
View(cv_entries)

cv_entries[1,5] <- "Univ. Grenoble Alpes, France | **[<i class=\"fab falink0 fa-github\"></i>](https://github.com/bttomio/UGA_thesisdown)[Reproducibility repository]{.smaller-font}**"

cv_entries <- cv_entries[c(1:3,4,4:10),]

cv_entries[4,2] <- "Since 1/2022"
cv_entries[4,3] <- ""
cv_entries[4,4] <- "Ph.D. Intern"
cv_entries[4,5] <- "Bank of England, United Kingdom"

cv_entries[2,4] <- "M.A. in Int. Economics"

cv_entries[5,2] <- "Since 6/2012"

cv_entries[3,4] <- "B.Sc. in Economics"

library(openxlsx)
write.xlsx(cv_entries, 'data/cv_entries.xlsx',
           overwrite = T)


###########

library(readxl)
pubs_entries <- read_excel("data/pubs.xlsx")

#pubs_entries[] <- pubs_entries[c(1:10, 12, 11, 14, 15, 13),]

pubs_entries[11,2] <- 2 
pubs_entries[12,2] <- 3 
pubs_entries[13,2] <- 4 
pubs_entries[14,2] <- 5
pubs_entries[15,2] <- 6

pubs_entries[10,5] <- "Carry Trade and Negative Policy Rates in Switzerland"
 
library(openxlsx)
write.xlsx(pubs_entries, 'data/pubs.xlsx',
           overwrite = T)
