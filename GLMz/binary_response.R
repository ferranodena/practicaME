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

AIC(m0, m0.1)
BIC(m0, m0.1)

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



#residus vs variables explicatives
par(mfrow = c(4, 4)) 
residualPlots(m0.1, 
              ~ Age_at_enrollment + Curricular_units_1st_sem_approved +
                Curricular_units_2nd_sem_enrolled + 
                Curricular_units_2nd_sem_approved + 
                Unemployment_rate,
               tests = TRUE)

#residus vs factors
residualPlots(m0.1,tests = TRUE)

#residus per les variables categòriques, tot i que tenen moltes categories 
# i per tant els boxplots poden ser difícils d'interpretar

# Residus del model
res <- resid(m0.1, type = "pearson")

# Variables categòriques a mirar 
cat_vars <- c("Course", "Application_mode", "Mother_s_qualification", 
              "Father_s_occupation", "Debtor", "Tuition_fees_up_to_date", 
              "Gender", "Scholarship_holder")

# Bucle per fer boxplots nets per cada categòrica
par(mfrow = c(3,3))  
for (v in cat_vars) {
  boxplot(res ~ base[[v]], 
          main = paste("Residuals vs", v),
          xlab = v, ylab = "Residuals",
          col = "lightblue", las = 2, cex.axis = 0.7)
  abline(h = 0, col = "red", lty = 2)
}
par(mfrow = c(1,1))  


#millora de la relació amb les variables numèriques mitjançant polinomis

df1 <- with(base, aggregate(
  x = cbind(ypos = target, yneg = 1 - target),
  by = list(units1 = Curricular_units_1st_sem_approved),
  FUN = sum
))
m1 <- glm(cbind(ypos, yneg) ~ units1, data = df1, family = binomial(link='logit'))
summary(m1)
residualPlots(m1)
df2 <- with(base, aggregate(
  x = cbind(ypos = target, yneg = 1 - target),
  by = list(units2e = Curricular_units_2nd_sem_enrolled),
  FUN = sum
))
m2 <- glm(cbind(ypos, yneg) ~ units2e, data = df2, family = binomial(link='logit'))
summary(m2)
residualPlots(m2)
df3 <- with(base, aggregate(
  x = cbind(ypos = target, yneg = 1 - target),
  by = list(units2a = Curricular_units_2nd_sem_approved),
  FUN = sum
))
m3 <- glm(cbind(ypos, yneg) ~ units2a, data = df3, family = binomial(link='logit'))
summary(m3)
residualPlots(m3)

#variable continua 1  Curricular_units_1st_sem_approved (df1 / units1)
m1.1 <- glm(cbind(ypos,yneg) ~ units1,           data = df1, family = binomial)
m1.2 <- glm(cbind(ypos,yneg) ~ poly(units1, 2),  data = df1, family = binomial)
m1.3 <- glm(cbind(ypos,yneg) ~ poly(units1, 3),  data = df1, family = binomial)
m1.4 <- glm(cbind(ypos,yneg) ~ poly(units1, 4),  data = df1, family = binomial)

#Deviance test
anova(m1.1, m1.2, test = "Chisq")
anova(m1.2, m1.3, test = "Chisq")
anova(m1.3, m1.4, test = "Chisq")

#AIC/BIC
cbind(AIC(m1.1, m1.2, m1.3, m1.4),
      BIC = BIC(m1.1, m1.2, m1.3, m1.4)[,2])


#variable continua 2 Curricular_units_2nd_sem_enrolled (df2 / units2e)

m2.1 <- glm(cbind(ypos,yneg) ~ units2e,          data = df2, family = binomial)
m2.2 <- glm(cbind(ypos,yneg) ~ poly(units2e, 2), data = df2, family = binomial)
m2.3 <- glm(cbind(ypos,yneg) ~ poly(units2e, 3), data = df2, family = binomial)
m2.4 <- glm(cbind(ypos,yneg) ~ poly(units2e, 4), data = df2, family = binomial)

#Deviance test
anova(m2.1, m2.2, test = "Chisq")
anova(m2.2, m2.3, test = "Chisq")
anova(m2.3, m2.4, test = "Chisq")

#AIC/BIC
cbind(AIC(m2.1, m2.2, m2.3, m2.4),
      BIC = BIC(m2.1, m2.2, m2.3, m2.4)[,2])

#variable continua 3  Curricular_units_2nd_sem_approved (df3 / units2a)
m3.1 <- glm(cbind(ypos,yneg) ~ units2a,          data = df3, family = binomial)
m3.2 <- glm(cbind(ypos,yneg) ~ poly(units2a, 2), data = df3, family = binomial)
m3.3 <- glm(cbind(ypos,yneg) ~ poly(units2a, 3), data = df3, family = binomial)
m3.4 <- glm(cbind(ypos,yneg) ~ poly(units2a, 4), data = df3, family = binomial)

#Deviance test
anova(m3.1, m3.2, test = "Chisq")
anova(m3.2, m3.3, test = "Chisq")
anova(m3.3, m3.4, test = "Chisq")

#AIC/BIC
cbind(AIC(m3.1, m3.2, m3.3, m3.4),
      BIC = BIC(m3.1, m3.2, m3.3, m3.4)[,2])


residualPlots(m1.4, layout = c(1, 2))
residualPlots(m2.3, layout = c(1, 2))
residualPlots(m3.3, layout = c(1, 2))






#Actualitzem el model m0.1 amb els polinomis adequats
m0.3 <- glm(target ~ Course + Application_mode + Mother_s_qualification + 
                      Father_s_occupation + Debtor + Tuition_fees_up_to_date +
                      Gender + Scholarship_holder + Age_at_enrollment + 
                      poly(Curricular_units_1st_sem_approved, 4) + 
                      Curricular_units_2nd_sem_enrolled + 
                      poly(Curricular_units_2nd_sem_approved, 3) + 
                      Unemployment_rate,
            data = base, family = binomial(link = "logit"))

summary(m0.3)
#Diagnòstic del model final amb polinomis ------------------------------------------------------
par(mfrow = c(1, 1)) # finestra 1x1
residualPlots(m0.3, ~ 1, type = "pearson") #residus vs ajustats

#residus vs variables explicatives
par(mfrow = c(4, 4))
residualPlots(m0.3, layout = c(4,4), ask = FALSE, tests = FALSE) #residus vs cada variable explicativa
#residus vs factors
residualPlot(m0.3, id.n = 0)
#residus per les variables categòriques, tot i que tenen moltes categories
# i per tant els boxplots poden ser difícils d'interpretar
# Residus del model
res <- resid(m0.3, type = "pearson")
# Variables categòriques a mirar
cat_vars <- c("Course", "Application_mode", "Mother_s_qualification",
              "Father_s_occupation", "Debtor", "Tuition_fees_up_to_date",
              "Gender", "Scholarship_holder")
# Bucle per fer boxplots nets per cada categòrica 
par(mfrow = c(3,3))
for (v in cat_vars) {
   boxplot(res ~ base[[v]],
          main = paste("Residuals vs", v),
          xlab = v, ylab = "Residuals",
          col = "lightblue", las = 2, cex.axis = 0.7)
  abline(h = 0, col = "red", lty = 2)
}
par(mfrow = c(1,1))
#Comparació dels models m0.1 i m0.3
anova(m0.1, m0.3, test = "Chisq")
AIC(m0.1, m0.3)
BIC(m0.1, m0.3)


#Millora de la relació amb les variables numèriques mitjançant interaccions
base$Iunits1 <- as.factor(ifelse(base$Curricular_units_1st_sem_approved <= 5, 0, 1)) 
base$Iunits2a <- as.factor(ifelse(base$Curricular_units_2nd_sem_approved <= 4, 0, 1))
summary(base$Iunits1) 
summary(base$Iunits2a)
m0.5 <- glm( target ~ Course + Application_mode + Mother_s_qualification + Father_s_occupation + Debtor + Tuition_fees_up_to_date + Gender + Scholarship_holder + Age_at_enrollment + poly(Curricular_units_1st_sem_approved, 4) * Iunits1 + poly(Curricular_units_2nd_sem_approved, 3) * Iunits2a + Unemployment_rate, data = base, family = binomial(link = "logit"))
summary(m0.5) 
anova(m0.3, m0.5, test = "Chisq") 
BIC(m0.1, m0.3, m0.5) 
AIC(m0.1, m0.3, m0.5)



# Comparació de diferent link
m_logit  <- glm(target ~ Course + Application_mode + Mother_s_qualification + 
                  Father_s_occupation + Debtor + Tuition_fees_up_to_date +
                  Gender + Scholarship_holder + Age_at_enrollment + 
                  Curricular_units_1st_sem_approved + 
                  Curricular_units_2nd_sem_enrolled + 
                  Curricular_units_2nd_sem_approved + 
                  Unemployment_rate,
                data = base, family = binomial(link = "logit"))

m_probit <- glm(target ~ Course + Application_mode + Mother_s_qualification + 
                  Father_s_occupation + Debtor + Tuition_fees_up_to_date +
                  Gender + Scholarship_holder + Age_at_enrollment + 
                  Curricular_units_1st_sem_approved + 
                  Curricular_units_2nd_sem_enrolled + 
                  Curricular_units_2nd_sem_approved + 
                  Unemployment_rate,
                data = base, family = binomial(link = "probit"))

# Comparació AIC/BIC
AIC(m_logit, m_probit)
BIC(m_logit, m_probit)
