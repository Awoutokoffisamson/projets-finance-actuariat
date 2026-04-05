###############################################################################
#  PROJET : MODÉLISATION DES VALEURS EXTRÊMES (EVT)
#  Objet : Analyse des débits maximaux annuels du fleuve Sénégal à Bakel
#  Période : 1950 – 2020
#  Méthode : Loi GEV non-stationnaire avec covariable pluviométrique
#
#  Auteur : Samson Koffi AWOUTO
#  Qualité : Élève Ingénieur Statisticien (ISE3)
#  Date : Mars 2026
###############################################################################

# 1. PRÉPARATION DE L'ENVIRONNEMENT ET DES DONNÉES ---------------------------

# Chargement des bibliothèques nécessaires
list_packages <- c("readxl", "trend", "extRemes", "ggplot2", "car", "gridExtra", "e1071")
new_packages <- list_packages[!(list_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org/")

library(readxl)
library(trend)
library(extRemes)
library(ggplot2)
library(car)
library(gridExtra)
library(e1071)

# Lecture du fichier de données
# Assurez-vous que le fichier est présent dans le répertoire de travail
data <- read_excel("Bakel_Debit_Max_Pluie_Annuel.xlsx")

# Nettoyage et vérification de la variable Pluie
if (is.character(data$Pluie)) {
  data$Pluie <- as.numeric(gsub(",", ".", data$Pluie))
}

# 2. ANALYSE DESCRIPTIVE ET TESTS DE STATIONNARITÉ ---------------------------

# Statistiques descriptives globales
stats_debit <- summary(data$Debit_Max)
stats_pluie <- summary(data$Pluie)

print(stats_debit)
print(stats_pluie)

# Séries temporelles
data$Periode <- ifelse(data$Annee < 1976, "Humide (1950-1975)", "Sèche (1976-2020)")

p1 <- ggplot(data, aes(x = Annee, y = Debit_Max, color = Periode)) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 1976, color = "darkred", linetype = "dotted") +
  labs(title = "Évolution des débits maximaux à Bakel", y = "Débit (m3/s)", x = "Année") +
  theme_minimal()

p2 <- ggplot(data, aes(x = Annee, y = Pluie, color = Periode)) +
  geom_line() +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 1976, color = "darkred", linetype = "dotted") +
  labs(title = "Évolution de la pluviométrie à Bakel", y = "Pluie (mm)", x = "Année") +
  theme_minimal()

grid.arrange(p1, p2, ncol = 1)

# Tests de stationnarité (Mann-Kendall et Pettitt)
cat("\nTest de Mann-Kendall (Débit) :\n")
print(mk.test(data$Debit_Max))

cat("\nTest de Pettitt (Débit) :\n")
print(pettitt.test(data$Debit_Max))

# 3. ANALYSE BIVARIÉE : DÉBIT VS PLUIE ---------------------------------------

# Corrélation de Pearson
cor_test <- cor.test(data$Debit_Max, data$Pluie)
cat("\nCorrélation de Pearson (Débit vs Pluie) :", round(cor_test$estimate, 3), 
    "(p-value =", formatC(cor_test$p.value, format = "e", digits = 2), ")\n")

# Nuage de points
ggplot(data, aes(x = Pluie, y = Debit_Max)) +
  geom_point(aes(color = Periode)) +
  geom_smooth(method = "lm", color = "black") +
  labs(title = "Relation Débit / Pluie", x = "Pluie (mm)", y = "Débit (m3/s)") +
  theme_minimal()

# 4. MODÉLISATION PAR LA LOI GEV ---------------------------------------------

# Standardisation des covariables pour stabiliser l'estimation
data$Pluie_std <- as.numeric(scale(data$Pluie))
data$Annee_std <- as.numeric(scale(data$Annee))

# Modèle M0 : Stationnaire (Référence)
model0 <- fevd(data$Debit_Max, type = "GEV")

# Modèle M1 : Non-stationnaire sur mu (fonction de la pluie)
model1 <- fevd(data$Debit_Max, data = data, location.fun = ~ Pluie_std, type = "GEV")

# Modèle M2 : Non-stationnaire sur mu et sigma (fonction de la pluie)
model2 <- fevd(data$Debit_Max, data = data, location.fun = ~ Pluie_std, scale.fun = ~ Pluie_std, type = "GEV")

# Modèle M3 : Non-stationnaire sur mu (fonction du temps)
model3 <- fevd(data$Debit_Max, data = data, location.fun = ~ Annee_std, type = "GEV")

# Comparaison des modèles (AIC)
get_ll   <- function(m) -m$results$value
get_aic  <- function(m) 2 * length(m$results$par) - 2 * get_ll(m)
get_bic  <- function(m) length(m$results$par) * log(length(m$x)) - 2 * get_ll(m)

aic_results <- data.frame(
  Modele = c("M0 (Stat.)", "M1 (Mu~Pluie)", "M2 (Mu & Sigma~Pluie)", "M3 (Mu~Temps)"),
  AIC = c(get_aic(model0), get_aic(model1), get_aic(model2), get_aic(model3)),
  BIC = c(get_bic(model0), get_bic(model1), get_bic(model2), get_bic(model3)),
  LogLik = c(get_ll(model0), get_ll(model1), get_ll(model2), get_ll(model3))
)
print(aic_results)

# Test du Rapport de Vraisemblance (LRT) entre M0 et M1
cat("\nLRT : Modèle stationnaire (M0) vs Modèle avec pluie (M1)\n")
print(lr.test(model0, model1))

# Diagnostics du modèle sélectionné (M1)
par(mfrow = c(2, 2))
plot(model1)
par(mfrow = c(1, 1))

# 5. ESTIMATION DES NIVEAUX DE RETOUR ----------------------------------------

periods <- c(2, 10, 50, 100)

# Scénario moyen (Pluie moyenne historique)
rl_moy <- return.level(model1, return.period = periods)
cat("\nNiveaux de retour (m3/s) - Scénario moyen :\n")
print(round(rl_moy, 1))

# Scénario humide (90ème percentile de la pluie)
pluie_p90_std <- (quantile(data$Pluie, 0.90) - mean(data$Pluie)) / sd(data$Pluie)

# Extraction des paramètres pour le scénario spécifique
p <- model1$results$par
mu_cond    <- p["mu0"] + p["mu1"] * pluie_p90_std
sigma_cond <- p["scale"]
xi_cond    <- p["shape"]

cat("\nParamètres GEV conditionnels (Scénario Humide P90) :\n")
cat("Localisation (mu) :", round(mu_cond, 1), "\n")
cat("Échelle (sigma)   :", round(sigma_cond, 1), "\n")
cat("Forme (xi/gamma)  :", round(xi_cond, 4), "\n")

# Calcul manuel des niveaux de retour conditionnels
rl_humide <- sapply(periods, function(T) {
  prob <- 1 - 1/T
  mu_cond + (sigma_cond / xi_cond) * ((-log(prob))^(-xi_cond) - 1)
})
names(rl_humide) <- paste0("T=", periods)

cat("\nNiveaux de retour (m3/s) - Scénario Humide (P90) :\n")
print(round(rl_humide, 1))

# Graphique final des niveaux de retour
plot(model1, type = "rl", main = "Courbe des niveaux de retour (Modèle M1)")

###############################################################################
# FIN DU SCRIPT
###############################################################################
