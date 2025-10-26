#Carregar llibreries ----------------------------------------------------------------
library(effects)
library(car)           # funcio Anova
library(emmeans)       # funcio emmeans
library(multcomp)      # funcio cld
library(multcompView)  # funcio cld    
library(dplyr)         # manipulació de dades
library(forcats)
library(readr)
library(detectseparation)

#Llegir dades  -------------------------------------------------------------------
base <- read_csv("./clean-data.csv", col_types = cols(
  Marital_status = col_character(),
  Application_mode = col_character(),
  Application_order = col_integer(),
  Course = col_character(),
  Daytime_evening_attendance = col_character(),
  Previous_qualification = col_character(),
  Previous_qualification_grade = col_double(),
  Nacionality = col_character(),
  Mother_s_qualification = col_integer(),
  Father_s_qualification = col_integer(),
  Mother_s_occupation = col_character(),
  Father_s_occupation = col_character(),
  Admission_grade = col_double(),
  Displaced = col_integer(),
  Educational_special_needs = col_integer(),
  Debtor = col_integer(),
  Tuition_fees_up_to_date = col_integer(),
  Gender = col_integer(),
  Scholarship_holder = col_integer(),
  Age_at_enrollment = col_integer(),
  International = col_integer(),
  Curricular_units_1st_sem_credited = col_integer(),
  Curricular_units_1st_sem_enrolled = col_integer(),
  Curricular_units_1st_sem_evaluations = col_integer(),
  Curricular_units_1st_sem_approved = col_integer(),
  Curricular_units_1st_sem_grade = col_double(),
  Curricular_units_1st_sem_without_evaluations = col_integer(),
  Curricular_units_2nd_sem_credited = col_integer(),
  Curricular_units_2nd_sem_enrolled = col_integer(),
  Curricular_units_2nd_sem_evaluations = col_integer(),
  Curricular_units_2nd_sem_approved = col_integer(),
  Curricular_units_2nd_sem_grade = col_double(),
  Curricular_units_2nd_sem_without_evaluations = col_integer(),
  Unemployment_rate = col_double(),
  Inflation_rate = col_double(),
  GDP = col_double(),
  Target = col_character()
)
)
#Modifiquem la variable resposta a 0/1 -------------------------------------------

x <- tolower(as.character(base$Target))   # normalitza a minúscules
base$target <- ifelse(x == "dropout", 1L,
                             ifelse(x %in% c("enrolled","graduated"), 0L, 0L))

# Resum de la base de dades ------------------------------------------------------
summary(base)


# Exploració gràfica de les variables explicatives -----------------------------
# Seleccionem totes les variables excepte la resposta 'target'
vars <- setdiff(names(base), c("Target","target"))

par(mfrow = c(4,5), mar = c(3,3,3,1))
colors <- c(2,3)  # vermell i verd

for (v in vars) {
  xv <- base[[v]]
  if (is.numeric(xv)) {
    # Grup de boxplot ha de ser factor perquè etiqueti bé
    boxplot(xv ~ factor(base$target, levels=c(0,1), labels=c("stay","dropout")),
            main = v, col = colors, horizontal = TRUE)
  } else {
    # Converteix a factor i calcula proporcions per columna
    fac <- factor(xv)
    tab <- prop.table(table(base$target, fac), 2)
    barplot(tab, main = v, col = colors, legend = FALSE)
  }
}

#preprocessament previ al model complet
# Eliminem la variable Target per evitar problemes

if ("Target" %in% names(base)) base <- dplyr::select(base, -Target)

# Detecció i correcció de problemes de separació en el model
#--------------------------------------------------------------

# Abans de continuar amb l’ajust del model complet,
# comprovem si existeix separació completa o quasi completa,
# és a dir, si hi ha variables o categories que prediuen perfectament
# la resposta (probabilitat 0 o 1 de dropout).
# Això pot provocar l’advertiment: "fitted probabilities numerically 0 or 1 occurred"

# Construïm la matriu de disseny amb totes les variables explicatives
# (equivalent a les columnes de X del model lineal general)
X <- model.matrix(target ~ ., data = base)

# Extraiem la variable resposta (0 = no dropout, 1 = dropout)
y <- base$target

# Apliquem la funció detect_separation per comprovar si hi ha separació
det <- detect_separation(X, y, family = binomial())

# Mostrem el resultat principal
det

# Reagrupem categories amb poques observacions per reduir el risc de separació
# Utilitzem fct_lump_min() per unir nivells amb menys de 150 observacions
# en una sola categoria "Other". Això redueix la complexitat del model
# i evita que alguns nivells expliquin perfectament la resposta.
base <- base %>%
  mutate(
    Application_mode = fct_lump_min(Application_mode, min = 50, other_level = "Other"),
    Course = fct_lump_min(Course, min = 50, other_level = "Other"),
    Previous_qualification = fct_lump_min(Previous_qualification, min = 50, other_level = "Other"),
    Nacionality = fct_lump_min(Nacionality, min = 50, other_level = "Other"),
    Mother_s_occupation = fct_lump_min(Mother_s_occupation, min = 50, other_level = "Other"),
    Father_s_occupation = fct_lump_min(Father_s_occupation, min = 50, other_level = "Other")
  )

# Ara el full model
m0 <- glm(target ~ ., data = base, family = binomial(link = "logit"))
summary(m0)
# Anova del model complet amb car
anova(m0, test = "Chisq")

# Contribució de cada variable al model complet
Anova(m0, test.statistic = "LR")

# Model 0.1 amb les variables significatives del model 0.0.1 segons LR
m0.1 <- glm(target ~ 
                 Course + 
                 Application_mode + 
                 Mother_s_qualification + 
                 Father_s_occupation + 
                 Debtor + 
                 Tuition_fees_up_to_date + 
                 Scholarship_holder + 
                 Age_at_enrollment + 
                 Curricular_units_1st_sem_approved + 
                 Curricular_units_2nd_sem_enrolled + 
                 Curricular_units_2nd_sem_approved + 
                 Unemployment_rate,
               data = base,
               family = binomial(link = "logit"))

#Fem una selecció automàtica cap endavant i cap enrere a partir del model complet
#utilitzant el criteri BIC
m0.2 <- step(m0, direction = "both", 
             k = log(nrow(base)), 
             trace = FALSE)

summary(m0.2)
AIC(m0, m0.1, m0.2)
BIC(m0, m0.1, m0.2)


#Mirem si les variables adicionales del model m0.1 aporten informació addicional
#en comparació amb el model m0.2
anova(m0.2, m0.1, test = "Chisq")

#el p-valor és molt baix, per tant les variables addicionals del model m0.1 aporten
#informació addicional i és preferible utilitzar aquest model en comptes del m0.2


#Diagnòstic del model final ------------------------------------------------------
par(mfrow = c(1, 1)) # finestra 1x1
residualPlots(m0.1, ~ 1, type = "pearson") #residus vs ajustats

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
par(mfrow = c(1,1))  
for (v in cat_vars) {
  boxplot(res ~ base[[v]], 
          main = paste("Residuals vs", v),
          xlab = v, ylab = "Residuals",
          col = "lightblue", las = 2, cex.axis = 0.7)
  abline(h = 0, col = "red", lty = 2)
}


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


par(mfrow = c(4, 4)) 
residualPlot(m1.4, term = "units1", type = "pearson",
             id.n = 0, ylim = c(-3, 3))

residualPlot(m2.3, term = "units1", type = "pearson",
             id.n = 0, ylim = c(-3, 3))

residualPlot(m3.3, term = "units1", type = "pearson",
             id.n = 0, ylim = c(-3, 3))

#Actualitzem el model m0.1 amb els polinomis adequats
m0.3 <- glm(target ~ 
              Course + 
              Mother_s_qualification + 
              Father_s_occupation + 
              Debtor + 
              Tuition_fees_up_to_date + 
              Scholarship_holder + 
              Age_at_enrollment + 
              poly(Curricular_units_1st_sem_approved, 4) + 
              Curricular_units_2nd_sem_enrolled + 
              poly(Curricular_units_2nd_sem_approved, 3) + 
              Unemployment_rate,
            data = base,
            family = binomial(link = "logit"))


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
m0.5 <- glm( target ~ Course + Mother_s_qualification + Father_s_occupation + Debtor + Tuition_fees_up_to_date + Scholarship_holder + Age_at_enrollment + poly(Curricular_units_1st_sem_approved, 4) * Iunits1 + poly(Curricular_units_2nd_sem_approved, 3) * Iunits2a + Unemployment_rate, data = base, family = binomial(link = "logit"))
summary(m0.5) 
anova(m0.3, m0.5, test = "Chisq") 
BIC(m0.1, m0.3, m0.5) 
AIC(m0.1, m0.3, m0.5)

# Comparació de diferent link
m_logit  <- glm(target ~ Course + Mother_s_qualification + 
                  Father_s_occupation + Debtor + Tuition_fees_up_to_date 
                   + Scholarship_holder + Age_at_enrollment + 
                  Curricular_units_1st_sem_approved + 
                  Curricular_units_2nd_sem_enrolled + 
                  Curricular_units_2nd_sem_approved + 
                  Unemployment_rate,
                data = base, family = binomial(link = "logit"))

m_probit <- glm(target ~ Course  + Mother_s_qualification + 
                  Father_s_occupation + Debtor + Tuition_fees_up_to_date +
                  Scholarship_holder + Age_at_enrollment + 
                  Curricular_units_1st_sem_approved + 
                  Curricular_units_2nd_sem_enrolled + 
                  Curricular_units_2nd_sem_approved + 
                  Unemployment_rate,
                data = base, family = binomial(link = "probit"))

# Comparació AIC/BIC
AIC(m_logit, m_probit)
BIC(m_logit, m_probit)
