library(readr)
library(ggplot2)
library(dplyr)

# Llegir el fitxer CSV
data <- read_csv("./time-series/monthly-car-sales.csv")

# Convertir la columna Month a un objecte de tipus data
data <- data %>%
  mutate(Month = as.Date(paste0(Month, "-01")))

# Comprovar les primeres files
print(head(data))

# Crear el gràfic de sèrie temporal
ggplot(data, aes(x = Month, y = Sales)) +
  geom_line(color = "darkgrey", linewidth = 1) +
  labs(title = "Sèrie temporal de les vendes mensuals de cotxes",
       x = "Data",
       y = "Vendes de cotxes") +
  theme_minimal()


################################################################################
# Introducció a sèries temporals - Exemple amb dades de vendes de cotxes
################################################################################

library(readr)
library(forecast)
library(dplyr)
library(ggplot2)
#-------------------------------------------------------------------------------
# Llegir la base de dades
#-------------------------------------------------------------------------------
car_sales <- read_csv("./time-series/monthly-car-sales.csv", show_col_types = FALSE)

# Crear la sèrie temporal
Car_sales_ts <- ts(car_sales$Sales, start = c(1960, 1), frequency = 12)
plot(Car_sales_ts)
# Transformació logarítmica
Ln_sales <- log(car_sales_ts)
plot(Ln_sales)
# Descomposició de la sèrie
decomposada <- decompose(lnsales)

# Gràfic de la descomposició (sense 'main')
plot(decomposada)

# Transformació logarítmica per estabilitzar la variància
ln_sales <- log(car_sales_ts)
plot(ln_sales, main = "Log(Vendes mensuals de cotxes)", ylab = "Log(Vendes)", xlab = "Any")

# Diferenciació estacional (per eliminar estacionalitat)
d12_ln_sales <- diff(ln_sales, lag = 12)
plot(d12_ln_sales, main = "Diferenciació d'ordre 12", ylab = "Diferència lag 12", xlab = "Any")

# Diferenciació addicional (per eliminar tendència)
d1d12_ln_sales <- diff(d12_ln_sales, lag = 1)
plot(d1d12_ln_sales, main = "Diferenciació doble (lag 1 i 12)", ylab = "Diferència lag 1 i 12", xlab = "Any")

sales <- car_sales$Sales

# Fixa la mida del grup (per exemple, 12, per anys)
group_size <- 12
n <- length(sales)
num_groups <- floor(n / group_size)

# Calcula mitjana i variància per a cada grup
means <- numeric(num_groups)
vars <- numeric(num_groups)

for (i in 1:num_groups) {
  group <- sales[((i-1)*group_size + 1):(i*group_size)]
  means[i] <- mean(group)
  vars[i] <- var(group)
}

# Prepara data frame per plotar
df <- data.frame(mean = means, variance = vars)

# Plot de la variància contra la mitjana de cada grup
ggplot(df, aes(x = mean, y = variance)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linewidth = 1) +
  labs(title = "Mean-Variance plot",
       x = "Mitjana del grup",
       y = "Variància del grup") +
  theme_minimal()

# Associa cada valor a un grup de 12 observacions
group <- rep(1:floor(length(sales)/12), each = 12, length.out = length(sales))
df <- data.frame(sales = sales, group = as.factor(group))

# Crea el boxplot per grups
ggplot(df, aes(x = group, y = sales)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Boxplot de vendes de cotxes per períodes d’1 any",
       x = "Grup anual",
       y = "Vendes") +
  theme_minimal()


sales <- car_sales$Sales

# Estima el millor valor de lambda per Box-Cox
lambda <- BoxCox.lambda(sales)

# Aplica la transformació Box-Cox a la sèrie
sales_boxcox <- BoxCox(sales, lambda = lambda)

# Comprova
cat("Lambda òptim Box-Cox:", lambda, "\n")

# Si vols boxplots per comparativa:
group <- rep(1:floor(length(sales_boxcox)/12), each = 12, length.out = length(sales_boxcox))
df_boxcox <- data.frame(sales_boxcox = sales_boxcox, group = as.factor(group))

library(ggplot2)
ggplot(df_boxcox, aes(x = group, y = sales_boxcox)) +
  geom_boxplot(fill = "lightyellow") +
  labs(title = "Boxplot de Box-Cox(vendes) per períodes d’1 any",
       x = "Grup anual",
       y = "Box-Cox(vendes)") +
  theme_minimal()



sales <- car_sales$Sales

# 2. (Opcional: transformació Box-Cox per estabilitzar variància)
lambda <- BoxCox.lambda(sales)
sales_boxcox <- BoxCox(sales, lambda = lambda)
cat("Lambda òptim Box-Cox:", lambda, "\n")

# 3. Crear sèrie temporal, mensual (freq = 12)
sales_ts <- ts(sales_boxcox, start = c(1960,1), frequency = 12)

# 4. Visibilitzar patró estacional a la sèrie original
plot(sales_ts, main = "Sèrie temporal Box-Cox(vendes)", ylab = "Box-Cox(vendes)", xlab = "Any")

# 5. Eliminar patró estacional amb diferència d’ordre 12
sales_d12 <- diff(sales_ts, lag = 12)
plot(sales_d12, main = "Diferenciació estacional (lag 12)", ylab = "Diferència lag 12", xlab = "Any")

# 6. Comprovar amb ACF/PACF si s’ha eliminat el patró estacional
# Dibuixa ACF i PACF amb límits Y entre -1 i 1
par(mfrow = c(1, 2))
acf(sales_d12, ylim = c(-1, 1), lag.max = (40), main = "ACF diferència estacional")
pacf(sales_d12, ylim = c(-1, 1), lag.max = (40), main = "PACF diferència estacional")
par(mfrow = c(1, 1))

# 3. Diferència regular d'ordre 1 per eliminar tendència
diff1 <- diff(sales_ts, lag = 1)
plot(diff1, main = "Diferència regular (ordre 1)")

# 4. Si la mitjana encara no és constant, pots fer una segona diferenciació (normalment no cal):
# diff2 <- diff(diff1, lag = 1)
# plot(diff2, main = "Diferència regular (ordre 2)")

# 5. Comprova si la variància ha augmentat (sobrediferenciació):
var(diff1) # compara amb la variància de sales_ts

# Si la variància puja molt, no cal més diferenciació.

################################################################################
#
# ME - GIA. Introducció a serie temporals (2)
#
#----------------------------------------------------------
# Dades reals: vendes de cotxes mensuals
#----------------------------------------------------------

library(readr)
library(forecast)

# Carrega de la sèrie real
car_sales <- read_csv("C:/Users/polri/Desktop/Uni/2n/1r Quatrimestre/ME/Lab/monthly-car-sales.csv", show_col_types = FALSE)
ser <- ts(car_sales$Sales, start = c(1960,1), frequency = 12)
plot(ser, main = "Sèrie real: vendes mensuals de cotxes")

# Transformació Box-Cox (si es vol)
lambda <- BoxCox.lambda(ser)
ser_boxcox <- BoxCox(ser, lambda)
plot(ser_boxcox, main = "Sèrie Box-Cox transformada")

#--------------------------- ARMA - Mostral ------------------------------

par(mfrow = c(1,2))
acf(ser_boxcox, lag.max = 40, ylim = c(-1,1), main = "ACF mostra vendes cotxes")
pacf(ser_boxcox, lag.max = 40, ylim = c(-1,1), main = "PACF mostra vendes cotxes")
par(mfrow = c(1,1))

#--------------------------- Diferenciació i ACF/PACF --------------------

# Diferència regular i estacional
diff12 <- diff(ser_boxcox, lag = 12)
diff1 <- diff(ser_boxcox, lag = 1)
diff1_12 <- diff(diff(ser_boxcox, lag = 12), lag = 1)

# ACF/PACF de la sèrie diferenciada (per a model ARMA/ARIMA)
par(mfrow = c(1,2))
acf(diff1_12, lag.max = 40, ylim = c(-1,1), main = "ACF dif (1,12)")
pacf(diff1_12, lag.max = 40, ylim = c(-1,1), main = "PACF dif (1,12)")
par(mfrow = c(1,1))

#--------------------------- Anàlisi de dependència -------------------------

# Polinomi característic de l'AR estimat (exemple AR(1) sobre dades reals)
ar_model <- ar(diff1_12)
ar_coefs <- ar_model$ar
Mod(polyroot(c(1, -ar_coefs))) # Arrels del polinomi AR estimat

# (Opcional: model ARIMA automàtic per ajustar el model òptim)
# fit_arima <- auto.arima(ser_boxcox)
# summary(fit_arima)