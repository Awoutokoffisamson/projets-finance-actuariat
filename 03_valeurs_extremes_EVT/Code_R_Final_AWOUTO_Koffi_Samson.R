###############################################################################
#  PROJET : MODÉLISATION DES VALEURS EXTRÊMES (EVT)
#  Thème   : Analyse des débits maximaux annuels du fleuve Sénégal à Bakel
#  
#  de  : Samson Koffi AWOUTO (ISE3)
#  
###############################################################################

# ── 0. PACKAGES ───────────────────────────────────────────────────────────────
libs <- c("readxl", "evd", "ggplot2", "gridExtra", "e1071", "knitr",
          "kableExtra", "car")
for (pkg in libs) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE))
    install.packages(pkg, quiet = TRUE)
  library(pkg, character.only = TRUE)
}

# ── 1. CHARGEMENT ET PRÉPARATION DES DONNÉES ──────────────────────────────────
if (!file.exists("Bakel_Debit_Max_Pluie_Annuel.xlsx"))
  stop("Fichier 'Bakel_Debit_Max_Pluie_Annuel.xlsx' introuvable.")

data <- read_excel("Bakel_Debit_Max_Pluie_Annuel.xlsx")
data$Pluie    <- as.numeric(gsub("[^0-9.]", "", gsub(",", ".",
                   as.character(data$Pluie))))
data$Pluie_std  <- as.numeric(scale(data$Pluie)[, 1])
data$Annee_std  <- as.numeric(scale(data$Annee)[, 1])
data$Periode    <- ifelse(data$Annee < 1976,
                     "1950-1975 (Humide)", "1976-2020 (Sèche)")

cat("Données chargées :", nrow(data), "observations,",
    ncol(data), "variables.\n")

# ── 2. STATISTIQUES DESCRIPTIVES (Table 1) ────────────────────────────────────
cat("\n====== TABLE 1 : STATISTIQUES DESCRIPTIVES ======\n")

resume_stats <- function(x) {
  c(
    Moyenne          = round(mean(x), 1),
    Mediane          = round(median(x), 1),
    Ecart_type       = round(sd(x), 1),
    Minimum          = round(min(x), 0),
    Maximum          = round(max(x), 0),
    "Q1 / Q3"        = paste0(round(quantile(x, .25), 0),
                               " / ", round(quantile(x, .75), 0)),
    "CV (%)"         = paste0(round(sd(x) / mean(x) * 100, 1)),
    Skewness         = round(e1071::skewness(x), 2),
    Kurtosis         = round(e1071::kurtosis(x), 2),
    "Shapiro-Wilk (p)" = round(shapiro.test(x)$p.value, 4)
  )
}

tab1 <- data.frame(
  Indicateur        = c("Moyenne", "Mediane", "Ecart-type", "Minimum",
                        "Maximum", "Q1 / Q3", "CV (%)", "Skewness",
                        "Kurtosis", "Shapiro-Wilk (p)"),
  "Debit max (m3/s)" = as.character(resume_stats(data$Debit_Max)),
  "Pluie (mm)"       = as.character(resume_stats(data$Pluie)),
  check.names        = FALSE
)
print(tab1, row.names = FALSE)

# ── 3. ÉVOLUTION TEMPORELLE (Figure 1) ────────────────────────────────────────
cat("\n====== FIGURE 1 : ÉVOLUTION TEMPORELLE ======\n")

p_debit <- ggplot(data, aes(x = Annee, y = Debit_Max, color = Periode)) +
  geom_line(color = "steelblue", linewidth = 0.8) +
  geom_point(aes(color = Periode), size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red",
              linetype = "dashed", linewidth = 0.8) +
  geom_vline(xintercept = 1976, linetype = "dotted",
             color = "darkred", linewidth = 0.8) +
  scale_color_manual(values = c("1950-1975 (Humide)" = "#2980B9",
                                "1976-2020 (Sèche)"  = "#E67E22")) +
  labs(x = "Année", y = "Débit max (m³/s)", color = "Période",
       title = "Débit maximal annuel") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 10))

p_pluie <- ggplot(data, aes(x = Annee, y = Pluie, color = Periode)) +
  geom_line(color = "darkgreen", linewidth = 0.8) +
  geom_point(aes(color = Periode), size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red",
              linetype = "dashed", linewidth = 0.8) +
  geom_vline(xintercept = 1976, linetype = "dotted",
             color = "darkred", linewidth = 0.8) +
  scale_color_manual(values = c("1950-1975 (Humide)" = "#2980B9",
                                "1976-2020 (Sèche)"  = "#E67E22")) +
  labs(x = "Année", y = "Pluie (mm)", color = "Période",
       title = "Cumul pluviométrique annuel") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 10))

grid.arrange(p_debit, p_pluie, ncol = 1)

# ── 4. TESTS DE STATIONNARITÉ (Table 2 + Figure 2) ────────────────────────────
cat("\n====== TABLE 2 : TESTS DE STATIONNARITÉ ======\n")

# Mann-Kendall maison (identique au Rmd)
mk_test <- function(x) {
  n <- length(x)
  S    <- sum(sapply(2:n, function(i) sum(sign(x[i] - x[1:(i - 1)]))))
  varS <- n * (n - 1) * (2 * n + 5) / 18
  Z    <- if (S > 0) (S - 1) / sqrt(varS) else if (S < 0) (S + 1) / sqrt(varS) else 0
  list(S = S, Z = Z, p.value = 2 * (1 - pnorm(abs(Z))))
}

# Pettitt maison (identique au Rmd)
pettitt <- function(x) {
  n <- length(x)
  U <- sapply(1:(n - 1), function(t)
    sum(sapply(1:t, function(i) sum(sign(x[i] - x[(t + 1):n])))))
  K      <- max(abs(U))
  t_star <- which.max(abs(U))
  list(statistic = K, estimate = t_star,
       p.value   = 2 * exp(-6 * K^2 / (n^3 + n^2)),
       estimates = U)
}

mk_d  <- mk_test(data$Debit_Max)
mk_p  <- mk_test(data$Pluie)
pet_d <- pettitt(data$Debit_Max)
pet_p <- pettitt(data$Pluie)

tab2 <- data.frame(
  Test       = c("Mann-Kendall", "Mann-Kendall", "Pettitt", "Pettitt"),
  Variable   = c("Débit max", "Pluie", "Débit max", "Pluie"),
  Statistique = c(
    paste0("S=", round(mk_d$S, 0), ", Z=", round(mk_d$Z, 2)),
    paste0("S=", round(mk_p$S, 0), ", Z=", round(mk_p$Z, 2)),
    paste0("K=", pet_d$statistic, ", t*=", data$Annee[pet_d$estimate]),
    paste0("K=", pet_p$statistic, ", t*=", data$Annee[pet_p$estimate])
  ),
  "p-value" = c(
    formatC(mk_d$p.value, format = "e", digits = 2),
    formatC(mk_p$p.value, format = "e", digits = 2),
    "< 0,0001", "< 0,0001"
  ),
  check.names = FALSE
)
print(tab2, row.names = FALSE)

# Moyennes par période
moy_humide <- mean(data$Debit_Max[data$Annee < 1976])
moy_seche  <- mean(data$Debit_Max[data$Annee >= 1976])
cat(sprintf("\nDébit moyen 1950-1975 (Humide) : %.0f m³/s\n", moy_humide))
cat(sprintf("Débit moyen 1976-2020 (Sèche)  : %.0f m³/s\n", moy_seche))
cat(sprintf("Baisse : %.0f %%\n", (moy_humide - moy_seche) / moy_humide * 100))

cat("\n====== FIGURE 2 : STATISTIQUE DE PETTITT (Débit maximal) ======\n")

Uk       <- pet_d$estimates
annee_uk <- data$Annee[seq_along(Uk)]

par(mar = c(4, 4.5, 2.5, 1), cex.main = 0.95, cex.lab = 0.9, cex.axis = 0.85)
plot(annee_uk, Uk,
     type = "l", col = "steelblue", lwd = 2,
     xlab = "Année", ylab = expression(U[t]),
     main = "Statistique de rupture de Pettitt - Débit maximal")
abline(v = data$Annee[pet_d$estimate], col = "red", lty = 2, lwd = 1.5)
legend("topright",
       legend = paste0("Rupture : ", data$Annee[pet_d$estimate]),
       col = "red", lty = 2, cex = 0.8, bty = "n")

# ── 5. TEST D'INDÉPENDANCE (autocorrélation ordre 1) ──────────────────────────
cat("\n====== SECTION 2.5 : AUTOCORRÉLATIONS (ordre 1) ======\n")

acf_debit <- cor(data$Debit_Max[-1], data$Debit_Max[-nrow(data)])
acf_pluie <- cor(data$Pluie[-1],     data$Pluie[-nrow(data)])
cat(sprintf("Autocorrélation ordre 1 - Débit : r = %.2f\n", acf_debit))
cat(sprintf("Autocorrélation ordre 1 - Pluie : r = %.2f\n", acf_pluie))

# ── 6. ANALYSE BIVARIÉE (Figure 3 + Table 3) ──────────────────────────────────
cat("\n====== FIGURE 3 : DÉBIT vs PLUVIOMÉTRIE ======\n")

print(
  ggplot(data, aes(x = Pluie, y = Debit_Max, color = Periode)) +
    geom_point(size = 2, alpha = 0.85) +
    geom_smooth(method = "lm", se = TRUE, color = "black",
                fill = "grey80", linetype = "dashed", linewidth = 0.8) +
    scale_color_manual(values = c("1950-1975 (Humide)" = "#2980B9",
                                  "1976-2020 (Sèche)"  = "#E67E22")) +
    labs(x = "Pluviométrie annuelle (mm)", y = "Débit maximal (m³/s)",
         color = "Période",
         title = "Débit maximal en fonction de la pluviométrie") +
    theme_minimal(base_size = 10) +
    theme(legend.position = "bottom",
          plot.title = element_text(face = "bold", size = 10))
)

cat("\n====== TABLE 3 : CORRÉLATIONS ======\n")

r_pearson <- cor.test(data$Debit_Max, data$Pluie)
res_d     <- residuals(lm(Debit_Max ~ Annee, data = data))
res_p     <- residuals(lm(Pluie     ~ Annee, data = data))
r_partial <- cor.test(res_d, res_p)

tab3 <- data.frame(
  Mesure = c("Corrélation de Pearson", "Corrélation sur résidus détrended"),
  r      = round(c(r_pearson$estimate, r_partial$estimate), 3),
  "p-value" = c(formatC(r_pearson$p.value, format = "e", digits = 2),
                formatC(r_partial$p.value, format = "e", digits = 2)),
  Interpretation = c("Lien fort positif", "Lien robuste après retrait de tendance"),
  check.names = FALSE
)
print(tab3, row.names = FALSE)

# ── 7. MODÉLISATION GEV NON-STATIONNAIRE ──────────────────────────────────────
cat("\n====== MODÉLISATION GEV ======\n")

y <- data$Debit_Max
X <- data$Pluie_std
Z <- data$Annee_std
n <- length(y)

# Fonction quantile GEV (niveau de retour)
gev_rl <- function(T, mu, sig, xi) {
  p <- 1 - 1 / T
  if (abs(xi) < 1e-6) return(mu - sig * log(-log(p)))
  mu + (sig / xi) * ((-log(p))^(-xi) - 1)
}

# --- M0 : stationnaire via evd::fgev ---
m0ev   <- fgev(y)
mu0_s  <- m0ev$estimate["loc"]
sig0_s <- m0ev$estimate["scale"]
xi0_s  <- m0ev$estimate["shape"]
logL0  <- -m0ev$deviance / 2
aic0   <-  m0ev$deviance + 2 * 3
bic0   <-  m0ev$deviance + 3 * log(n)

# --- M1 : mu ~ Pluie* ---
nll_m1 <- function(p) {
  mu <- p[1] + p[2] * X
  s  <- exp(p[3]); xi <- p[4]
  z  <- 1 + xi * (y - mu) / s
  if (any(z <= 0) || s <= 0) return(1e10)
  n * log(s) + sum(z^(-1 / xi)) + (1 / xi + 1) * sum(log(z))
}
opt1   <- optim(c(mu0_s, 300, log(sig0_s), xi0_s), nll_m1,
                method = "BFGS", control = list(maxit = 5000, reltol = 1e-12))
mu0_1  <- opt1$par[1]; mu1_1  <- opt1$par[2]
sig0_1 <- exp(opt1$par[3]); xi1 <- opt1$par[4]
logL1  <- -opt1$value
aic1   <- -2 * logL1 + 2 * 4
bic1   <- -2 * logL1 + 4 * log(n)

# --- M2 : mu + log(sigma) ~ Pluie* ---
nll_m2 <- function(p) {
  mu <- p[1] + p[2] * X
  s  <- exp(p[3] + p[4] * X); xi <- p[5]
  z  <- 1 + xi * (y - mu) / s
  if (any(z <= 0) || any(s <= 0)) return(1e10)
  sum(log(s)) + sum(z^(-1 / xi)) + (1 / xi + 1) * sum(log(z))
}
opt2   <- optim(c(mu0_1, mu1_1, log(sig0_1), 0, xi1), nll_m2,
                method = "BFGS", control = list(maxit = 5000, reltol = 1e-12))
mu0_2  <- opt2$par[1]; mu1_2 <- opt2$par[2]
s0_2   <- exp(opt2$par[3]); s1_2 <- opt2$par[4]; xi2 <- opt2$par[5]
logL2  <- -opt2$value
aic2   <- -2 * logL2 + 2 * 5
bic2   <- -2 * logL2 + 5 * log(n)

# --- M3 : mu ~ Annee* ---
nll_m3 <- function(p) {
  mu <- p[1] + p[2] * Z
  s  <- exp(p[3]); xi <- p[4]
  z  <- 1 + xi * (y - mu) / s
  if (any(z <= 0) || s <= 0) return(1e10)
  n * log(s) + sum(z^(-1 / xi)) + (1 / xi + 1) * sum(log(z))
}
opt3   <- optim(c(mu0_s, 200, log(sig0_s), xi0_s), nll_m3,
                method = "BFGS", control = list(maxit = 5000, reltol = 1e-12))
mu0_3  <- opt3$par[1]; mu1_3 <- opt3$par[2]
sig0_3 <- exp(opt3$par[3]); xi3 <- opt3$par[4]
logL3  <- -opt3$value
aic3   <- -2 * logL3 + 2 * 4
bic3   <- -2 * logL3 + 4 * log(n)

# ── 8. TABLE 5 : PARAMÈTRES DES MODÈLES ───────────────────────────────────────
cat("\n====== TABLE 5 : PARAMÈTRES ESTIMÉS ET CRITÈRES ======\n")

fmt <- function(x, d) if (is.na(x) || is.nan(x)) "--" else as.character(round(x, d))

tab5 <- data.frame(
  Parametre = c("mu0 (localisation)", "mu1", "sigma0 (echelle)", "sigma1",
                "gamma (forme)", "Log-vraisemblance", "AIC", "BIC"),
  M0 = c(fmt(mu0_s, 0),  "--",           fmt(sig0_s, 0), "--",
         fmt(xi0_s, 4),  fmt(logL0, 1),  fmt(aic0, 1),   fmt(bic0, 1)),
  M1 = c(fmt(mu0_1, 0),  fmt(mu1_1, 0),  fmt(sig0_1, 0), "--",
         fmt(xi1, 4),    fmt(logL1, 1),  fmt(aic1, 1),   fmt(bic1, 1)),
  M2 = c(fmt(mu0_2, 0),  fmt(mu1_2, 0),  fmt(s0_2, 0),   fmt(s1_2, 3),
         fmt(xi2, 4),    fmt(logL2, 1),  fmt(aic2, 1),   fmt(bic2, 1)),
  M3 = c(fmt(mu0_3, 0),  fmt(mu1_3, 0),  fmt(sig0_3, 0), "--",
         fmt(xi3, 4),    fmt(logL3, 1),  fmt(aic3, 1),   fmt(bic3, 1)),
  check.names = FALSE
)
print(tab5, row.names = FALSE)

# ── 9. TABLE 6 : TESTS LRT ────────────────────────────────────────────────────
cat("\n====== TABLE 6 : TESTS DU RAPPORT DE VRAISEMBLANCE ======\n")

lrt_pval <- function(L_s, L_c, dk) pchisq(2 * (L_c - L_s), df = dk, lower.tail = FALSE)

tab6 <- data.frame(
  Comparaison = c("M0 vs M1", "M1 vs M2", "M0 vs M3"),
  dlogL = c(round(logL1 - logL0, 1), round(logL2 - logL1, 1),
            round(logL3 - logL0, 1)),
  D = c(round(2 * (logL1 - logL0), 1), round(2 * (logL2 - logL1), 1),
        round(2 * (logL3 - logL0), 1)),
  dk = c(1, 1, 1),
  pvalue = c(
    formatC(lrt_pval(logL0, logL1, 1), format = "e", digits = 2),
    formatC(lrt_pval(logL1, logL2, 1), format = "e", digits = 2),
    formatC(lrt_pval(logL0, logL3, 1), format = "e", digits = 2)
  ),
  Decision = c("M1 préféré", "M2 légèrement préféré", "M3 préféré vs M0"),
  check.names = FALSE
)
print(tab6, row.names = FALSE)

# ── 10. FIGURE 4 : DIAGNOSTICS DU MODÈLE M1 ──────────────────────────────────
cat("\n====== FIGURE 4 : DIAGNOSTICS MODÈLE M1 ======\n")

mu_fit   <- mu0_1 + mu1_1 * X
z_std    <- log(1 + xi1 * (y - mu_fit) / sig0_1) / xi1
n_obs    <- length(y)
prob_emp  <- (rank(z_std) - 0.5) / n_obs
prob_theo <- exp(-exp(-z_std))
Ts_d      <- c(2, 5, 10, 20, 50, 100, 200)
rls_d     <- sapply(Ts_d, function(T) gev_rl(T, mu0_1, sig0_1, xi1))

par(mfrow = c(2, 2), mar = c(4, 4, 2.5, 1),
    cex.main = 0.9, cex.lab = 0.85, cex.axis = 0.8)

# PP-plot
plot(sort(prob_theo), sort(prob_emp),
     pch = 1, cex = 0.7,
     xlab = "Probabilités théoriques", ylab = "Probabilités empiriques",
     main = "PP-plot")
abline(0, 1, col = "red", lwd = 1.5)

# QQ-plot
qqplot(qgumbel(ppoints(n_obs)), sort(z_std),
       pch = 1, cex = 0.7,
       xlab = "Quantiles Gumbel théoriques", ylab = "Quantiles observés",
       main = "QQ-plot")
abline(0, 1, col = "red", lwd = 1.5)

# Return level plot
plot(log10(Ts_d), rls_d,
     type = "b", pch = 16, cex = 0.8, col = "steelblue",
     xlab = expression(log[10](T)), ylab = "Niveau de retour (m³/s)",
     main = "Niveaux de retour (scénario moyen)")

# Densité ajustée
hist(y, freq = FALSE, col = "grey92", border = "grey60",
     xlab = "Débit maximal (m³/s)", main = "Densité ajustée vs observations")
curve(dgev(x, loc = mu0_1, scale = sig0_1, shape = xi1),
      add = TRUE, col = "steelblue", lwd = 2)
legend("topright", legend = "Densité M1", col = "steelblue",
       lwd = 2, cex = 0.75, bty = "n")

par(mfrow = c(1, 1))

# ── 11. TABLE 7 : NIVEAUX DE RETOUR ───────────────────────────────────────────
cat("\n====== TABLE 7 : NIVEAUX DE RETOUR (m³/s) ======\n")

periodes <- c(2, 10, 50)
rl_m0    <- sapply(periodes, function(T) gev_rl(T, mu0_s, sig0_s, xi0_s))
rl_m1_moy <- sapply(periodes, function(T) gev_rl(T, mu0_1, sig0_1, xi1))

p90s     <- (quantile(data$Pluie, .90) - mean(data$Pluie)) / sd(data$Pluie)
mu_hum   <- mu0_1 + mu1_1 * p90s
rl_m1_hum <- sapply(periodes, function(T) gev_rl(T, mu_hum, sig0_1, xi1))

tab7 <- data.frame(
  "Période T"           = paste0("T = ", periodes, " ans"),
  "M0 (stationnaire)"   = paste(format(round(rl_m0,    0), big.mark = " "), "m³/s"),
  "M1 - scénario moyen" = paste(format(round(rl_m1_moy,0), big.mark = " "), "m³/s"),
  "M1 - scénario humide"= paste(format(round(rl_m1_hum,0), big.mark = " "), "m³/s"),
  check.names = FALSE
)
print(tab7, row.names = FALSE)

# ── 12. FIGURE 5 : COURBES DE RETOUR M0 + M1 DEUX SCÉNARIOS ──────────────────
cat("\n====== FIGURE 5 : COURBES DES NIVEAUX DE RETOUR ======\n")

Ts_plot <- c(2, 5, 10, 20, 50, 100, 200, 500)
rl_moy  <- sapply(Ts_plot, function(T) gev_rl(T, mu0_1, sig0_1, xi1))
rl_hum  <- sapply(Ts_plot, function(T) gev_rl(T, mu_hum, sig0_1, xi1))
rl_M0   <- sapply(Ts_plot, function(T) gev_rl(T, mu0_s, sig0_s, xi0_s))

par(mar = c(4, 4.5, 2, 1), cex.main = 0.9, cex.lab = 0.85)
plot(log10(Ts_plot), rl_M0,
     type = "b", pch = 0, lty = 2, col = "grey50", lwd = 1.5,
     ylim = range(c(rl_M0, rl_moy, rl_hum), na.rm = TRUE) * c(0.88, 1.12),
     xlab = expression(log[10](T ~ "(années)")),
     ylab = "Niveau de retour (m³/s)",
     main = "Niveaux de retour - M0 et M1 sous deux scénarios")
lines(log10(Ts_plot), rl_moy, type = "b", pch = 16, lty = 1,
      col = "steelblue", lwd = 1.5)
lines(log10(Ts_plot), rl_hum, type = "b", pch = 17, lty = 1,
      col = "darkgreen", lwd = 1.5)
legend("topleft",
       legend = c("M0 stationnaire", "M1 scénario moyen",
                  "M1 scénario humide (P90)"),
       col  = c("grey50", "steelblue", "darkgreen"),
       lty  = c(2, 1, 1), pch = c(0, 16, 17), lwd = 1.5,
       cex  = 0.78, bty = "n")

