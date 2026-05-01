


devtools::install_github("GGLuca/apa.cor")

# Data insertion and prep -------------------------------------------------

library(tidyverse)
library(readr)
library(psych)

# Special function available at:
# https://github.com/GGLuca/apa.cor

library(apa.cor)

dataset <- read_csv("C:/Users/Daniel/Desktop/ADA Code/dataset.csv", na = c("-9", "NA")) %>% 
  filter(FINISHED == 1 | TIME_RSI > 2)

# Data plausibility check --------------------------------------------------

dataset = dataset %>% 
  mutate(SE01_02 = 5 - SE01_02, 
         SE01_05 = 5 - SE01_05, 
         SE01_06 = 5 - SE01_06, 
         SE01_08 = 5 - SE01_08, 
         SE01_09 = 5 - SE01_09)
  
dataset %>% 
  select(starts_with("SE01")) %>% 
  apa.cor()

# Internal consistency 

dataset %>% 
  select(starts_with("SE01")) %>% 
  psych::alpha()

# Compute means

dataset <- dataset %>%
  rowwise() %>%  # Process row-wise
  mutate(self.esteem = mean(c_across(starts_with("SE01")), na.rm = TRUE),
         narcissism = mean(c_across(starts_with("NA01")), na.rm = TRUE),
         narq_adm = mean(c_across(c("NA01_01", "NA01_02", "NA01_03", "NA01_05", "NA01_07", 
                                    "NA01_08", "NA01_15", "NA01_16", "NA01_18")), na.rm = TRUE)) %>%
  ungroup()


m.cor = dataset %>% 
  select(self.esteem, narcissism, narq_adm) %>% 
  apa.cor()

install.packages("flextable")

library(flextable)
flextable(m.cor) %>%
  theme_vanilla() %>%
  save_as_docx(path = "correlations.docx")

#save_as_docx pentru proiect si licenta ca sa scrii ce inseamna fiecare variabila
# mock regression

fit = lm(narcissism ~ self.esteem, data = dataset)

install.packages("sjPlot")
summary(fit)

library(sjPlot)
tab_model(fit, show.std = TRUE)




