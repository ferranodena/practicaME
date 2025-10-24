#Carregar llibreries ----------------------------------------------------------------
library(effects)
library(car)           # funcio Anova
library(emmeans)       # funcio emmeans
library(multcomp)      # funcio cld
library(multcompView)  # funcio cld    
library(dplyr)         # manipulació de dades
library(forcats)


#Llegir dades  -------------------------------------------------------------------
base <- read.csv("clean-data.csv", stringsAsFactors = FALSE)
base <- base %>%
  dplyr::mutate(
    dplyr::across(
      c(Marital_status, Application_mode, Course, Daytime_evening_attendance,
        Previous_qualification, Nacionality, Mother_s_occupation, Father_s_occupation,
        Displaced, Educational_special_needs, Debtor, Tuition_fees_up_to_date,
        Gender, Scholarship_holder, International,
        Curricular_units_1st_sem_credited, Curricular_units_1st_sem_without_evaluations,
        Curricular_units_2nd_sem_credited, Curricular_units_2nd_sem_without_evaluations),
      as.factor
    )
  )

#Modifiquem la variable resposta a 0/1 -------------------------------------------

base <- base %>%
  dplyr::mutate(
    target = dplyr::case_when(
      Target %in% c("dropout", "Dropout", "DROPOUT") ~ 1L,
      Target %in% c("enrolled", "graduated", "Enrolled", "Graduated") ~ 0L,
      TRUE ~ 0L
    )
  )

# Resum de la base de dades ------------------------------------------------------
summary(base)


# Exploració gràfica de les variables explicatives -----------------------------
# Seleccionem totes les variables excepte la resposta 'target'
vars <- setdiff(colnames(base), c("Target","target"))

par(mfrow=c(4,5), mar=c(3,3,3,1)) # finestra 4x5, marges
colors <- c(2,3)                  # colors: vermell i verd

# Boxplot si numèrica, barplot si factor
for (v in vars){
  if (!is.factor(base[[v]])){
    form <- as.formula(paste0(v," ~ target"))
    boxplot(form, base, main = v, col = colors, horizontal = TRUE)
  } else {
    tab <- prop.table(table(base$target, base[[v]]), 2)
    barplot(tab, main = v, col = colors, legend = FALSE)
  }
}

#preprocessament previ al model complet
# Eliminem la variable Target per evitar problemes

if ("Target" %in% names(base)) base <- dplyr::select(base, -Target)

# Abans del model, després d’haver eliminat Target
base <- base %>%
  mutate(across(where(is.factor), ~ fct_lump_min(.x, min = 50, other_level = "Other")))

# Ara el full model
m0 <- glm(target ~ ., data = base, family = binomial(link = "logit"))
summary(m0)
# Anova del model complet amb car
anova(m0, test = "Chisq")

# Contribució de cada variable al model complet
Anova(m0, test.statistic = "LR")


#creem un model reduït amb les variables significatives, *** ** i *
m0.1 <- glm(target ~ Course + Application_mode + Mother_s_qualification + 
                      Father_s_occupation + Debtor + Tuition_fees_up_to_date + 
                      Gender + Scholarship_holder + Age_at_enrollment + 
                      Curricular_units_1st_sem_approved + 
                      Curricular_units_2nd_sem_enrolled + 
                      Curricular_units_2nd_sem_approved + 
                      Unemployment_rate,
            data = base, family = binomial(link = "logit"))



summary(m0.1)

#Comparem AIC/BIC amb el model complet (m0) per veure si ha empitjorat molt i
#cal recuperar alguna variable

AmIC(m0, m0.1)
BIC(0, m0.1)

#Contribució de cada variable al model reduït
Anova(m0.1, test.statistic = 'LR')  

#Fem una selecció automàtica cap endavant i cap enrere a partir del model complet
#utilitzant el criteri BIC
m0.2 <- step(m0, direction = "both", 
             k = log(nrow(base)), 
             trace = FALSE)

summary(m0.2)

#m0 (complet): 72 df, AIC = 1484.7, BIC = 1905.0

#m0.1 (reduït manual): 42 df, AIC = 1468.4, BIC = 1713.6

#m0.2 (reduït automàtic): 9 df, AIC = 1490.9, BIC = 1534.9

#Mirem si les variables adicionales del model m0.1 aporten informació addicional
#en comparació amb el model m0.2
anova(m0.2, m0.1, test = "Chisq")

#el p-valor és molt baix, per tant les variables addicionals del model m0.1 aporten
#informació addicional i és preferible utilitzar aquest model en comptes del m0.2


#Diagnòstic del model final ------------------------------------------------------
par(mfrow = c(1, 1)) # finestra 1x1
residualPlots(m0.1, ~ 1, type = "pearson") #residus vs ajustats

residualPlots(m0.1, layout = c(4,4), ask = FALSE, tests = FALSE) #residus vs cada variable explicativa
