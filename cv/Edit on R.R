library(readxl)
cv_entries <- read_excel("data/cv_entries.xlsx")
View(cv_entries)

cv_entries[1,5] <- "Université Grenoble Alpes, France"

cv_entries <- cv_entries[c(1:3,4,4:10),]

cv_entries[4,2] <- "Since 1/2022"
cv_entries[4,3] <- ""
cv_entries[4,4] <- "PhD Intern"
cv_entries[4,5] <- "Bank of England, United Kingdom"

cv_entries[2,4] <- "M.A. in Int. Economics"

cv_entries[5,2] <- "Since 6/2012"

library(openxlsx)
write.xlsx(cv_entries, 'data/cv_entries.xlsx',
           overwrite = T)
