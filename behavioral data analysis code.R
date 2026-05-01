# Behavioral Data Analysis & Personality Insights - Stancu Daniel Cristian

# Install Libraries and Packages ----------------------------------------------
install.packages("ggcorrplot")
install.packages("sjPlot")
install.packages("ggplot2")

# Loading libraries & packages ------------------------------------------------
library(tidyverse)
library(readr)
library(psych)
library(apa.cor)
library(ggcorrplot)
library(sjPlot)
library(ggplot2)
library(flextable)

# Loading data (always use"/" for absolute paths)------------------------------
dataset <- read_csv("", na = c("-9", "NA")) %>% 
  filter(FINISHED == 1 | TIME_RSI > 2)

# Participant Demographics ----------------------------------------------------

# Number of participants
nrow(dataset)

# Average Age
averageAge <- mean(dataset$DD01_01, na.rm = TRUE) # mean age: 28.76 

deviationAge <- sd(dataset$DD01_01, na.rm = TRUE) # SD = 11.94 of age

# Percentage of biological sex among participants

bsex_counts <- table(dataset$DD02)

bsex_percentages <- prop.table(bsex_counts) * 100

print(bsex_percentages)

# Percentage of residential status

area_counts <- table(dataset$DD03)

area_percentages <- prop.table(area_counts) * 100

print(area_percentages)

# Percentage for education level

studylevel_counts <- table(dataset$DD04)

studylevel_percentages <- prop.table(studylevel_counts) * 100

print(studylevel_percentages)



# Reverse Items in Big Five ---------------------------------------------------
dataset <- dataset %>% mutate(across(matches("BF01_01"), ~ 6 - .)) 
dataset <- dataset %>% mutate(across(matches("BF01_07"), ~ 6 - .))
dataset <- dataset %>% mutate(across(matches("BF01_03"), ~ 6 - .))
dataset <- dataset %>% mutate(across(matches("BF01_03"), ~ 6 - .))
dataset <- dataset %>% mutate(across(matches("BF01_08"), ~ 6 - .))
dataset <- dataset %>% mutate(across(matches("BF01_14"), ~ 6 - .))
dataset <- dataset %>% mutate(across(matches("BF01_10"), ~ 6 - .))

# Descriptive Statistics ------------------------------------------------------

dataset <- dataset %>%
  rowwise() %>%  # Process row-wise
  mutate(self.esteem = mean(c_across(starts_with("SE01")), na.rm = TRUE),
         narcissism = mean(c_across(starts_with("NA01")), na.rm = TRUE),
         extraversion = mean(c_across(c("BF01_01", "BF01_06", "BF01_11")), na.rm = TRUE),
         agreableness = mean(c_across(c("BF01_02", "BF01_07", "BF01_12")), na.rm = TRUE),
         conscientiousness = mean(c_across(c("BF01_03", "BF01_08", "BF01_13")), na.rm = TRUE),
         negativeEmo = mean(c_across(c("BF01_04", "BF01_09", "BF01_14")), na.rm = TRUE),
         openness = mean(c_across(c("BF01_05", "BF01_10", "BF01_15")), na.rm = TRUE),
         dominance = mean(c_across(starts_with("CP01")), na.rm = TRUE),
         narq_adm = mean(c_across(c("NA01_01", "NA01_02", "NA01_03", "NA01_05",
                                              "NA01_07", "NA01_08", "NA01_15", "NA01_16", "NA01_18")), na.rm = TRUE),
         narq_riv = mean(c_across(c("NA01_04", "NA01_06", "NA01_09", "NA01_10",
                                              "NA01_11", "NA01_12", "NA01_13", "NA01_14", "NA01_17")), na.rm = TRUE)) %>%
  ungroup()

cor_matrix <- dataset %>% # Correlation matrix for narcissism, self-esteem and Big Five
  select(self.esteem, narcissism, extraversion, agreableness, conscientiousness, negativeEmo, openness, dominance,
         narq_adm, narq_riv) %>%
  mutate(across(everything(), as.numeric)) %>% 
  apa.cor()  

print(cor_matrix)

flextable(cor_matrix) %>%
  theme_vanilla() %>%
  save_as_docx(path = "correlations.docx")

# H1 Narcissism will be positively related to extraversion and negatively to agreableness
# Heat map corr_matrix
cor_matrix_heat <- dataset %>%
  select(self.esteem, narcissism, extraversion, agreableness, conscientiousness, negativeEmo, openness, dominance,
         narq_adm, narq_riv) %>%
  mutate(across(everything(), as.numeric)) %>%
  cor(use = "pairwise.complete.obs")  

heatmap_plot <- ggcorrplot(cor_matrix_heat, 
           method = "square",    # Use squares for correlation values
           type = "lower",       # Display only lower triangle
           lab = TRUE,           # Display the correlation values in the heat map
           lab_size = 4,         # Adjust the label size
           colors = c("#FF0000", "#FFFFFF", "#0000FF"),  # Color gradient
           title = "Correlation Matrix Heatmap",
           ggtheme = theme_minimal())

ggsave("heatmap.png", plot = heatmap_plot, width = 5.55, height = 5.41, dpi = 300) # Save heatmap as image
# Inferential Statistics ------------------------------------------------------

# H2: Narcissism positively Predicts self.esteem
regr2 = lm(self.esteem ~ narcissism, data = dataset)
summary(regr2)

tab_model(regr2, show.std = TRUE)

flextable(regr2) %>%
  theme_vanilla() %>%
  save_as_docx(path = "Hypothesis12.docx")

# H3: Self-esteem and Narcissistic Admiration predict Dominance
regr1 = lm(dominance ~ self.esteem * narq_adm, data = dataset)
summary(regr1)

tab_model(regr1, show.std = TRUE)


# Citations -------------------------------------------------------------------
citation()
citation("tidyverse")
citation("readr") 
citation("psych") 
citation("apa.cor") 
citation("ggcorrplot") 
citation("sjPlot") 
citation("ggplot2") 
citation("flextable")