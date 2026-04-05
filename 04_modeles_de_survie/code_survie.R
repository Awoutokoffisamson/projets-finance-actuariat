################################################################################
#          PROJET ANALYSE DE SURVIE - M2 ENSAE 2025-2026                     #
#                  Cancer de l'estomac - CODE COMPLET                         #
################################################################################

# Installation et chargement des packages
install.packages(c("survival", "survminer", "ggplot2"), dependencies=TRUE)
library(survival)
library(survminer)
library(ggplot2)

# Configuration
options(scipen=999)
setwd("chemin/vers/votre/dossier")  # À MODIFIER

cat("\n================================================================================\n")
cat("      PROJET: ANALYSE DE SURVIE - CANCER DE L'ESTOMAC\n")
cat("================================================================================\n\n")

# CHARGEMENT DES DONNÉES
donnees <- read.csv("Base_Projet_DC_Ensae_25_26_OK.csv", sep=";", header=TRUE)
cat("✓ Données chargées:", nrow(donnees), "patients\n\n")

# Création des variables catégorielles
donnees$SEXE_label <- factor(donnees$SEXE, levels=c(1,2), 
                             labels=c("Homme","Femme"))
donnees$Traitement_label <- factor(donnees$Traitement, levels=c(0,1,2,3),
                                   labels=c("Sans traitement","Chirurgie",
                                            "Radiotherapie","Chimiotherapie"))

# Objet de survie
survie <- Surv(time=donnees$DureeSurvieJr, event=donnees$DECES)

# STATISTIQUES DESCRIPTIVES
cat("STATISTIQUES DESCRIPTIVES:\n")
cat("--------------------------\n")
cat("N total:", nrow(donnees), "\n")
cat("Décès:", sum(donnees$DECES), "(", round(mean(donnees$DECES)*100,1), "%)\n")
cat("Censures:", sum(donnees$DECES==0), "(", round(mean(donnees$DECES==0)*100,1), "%)\n")
cat("Durée moyenne:", round(mean(donnees$DureeSurvieJr),0), "jours\n")
cat("Durée médiane:", round(median(donnees$DureeSurvieJr),0), "jours\n\n")

################################################################################
# QUESTION 1: FONCTION DE SURVIE GLOBALE (KAPLAN-MEIER)
################################################################################

cat("================================================================================\n")
cat("QUESTION 1: ESTIMATION DE LA FONCTION DE SURVIE GLOBALE\n")
cat("================================================================================\n\n")

# Estimation
fit_global <- survfit(survie ~ 1, data=donnees, conf.type="log-log")
print(fit_global)
print(summary(fit_global))

# Graphique avec base R
png("Q1_Survie_Globale.png", width=1200, height=800, res=150)
plot(fit_global, col="blue", lwd=2, conf.int=TRUE,
     xlab="Temps de survie (jours)", 
     ylab="Probabilité de survie S(t)",
     main="Fonction de survie de Kaplan-Meier - Population globale")
abline(h=0.5, col="red", lty=2, lwd=1.5)
legend("topright", c("Courbe de survie","Médiane (50%)","IC 95%"),
       col=c("blue","red","lightblue"), lty=c(1,2,1), lwd=c(2,1.5,10))
dev.off()
cat("✓ Graphique sauvegardé: Q1_Survie_Globale.png\n\n")

# Graphique avec ggsurvplot (plus professionnel)
ggsurvplot(fit_global, data=donnees, conf.int=TRUE, 
           risk.table=TRUE, risk.table.height=0.25,
           xlab="Temps (jours)", ylab="S(t)",
           title="Fonction de survie de Kaplan-Meier",
           ggtheme=theme_minimal(), palette="blue")
ggsave("Q1_Survie_Globale_ggplot.png", width=12, height=8, dpi=300)

# Probabilités de survie à des temps spécifiques
temps_cles <- c(30, 90, 180, 365, 730, 1825, 3600)
cat("\nProbabilités de survie à des temps clés:\n")
for(t in temps_cles) {
  idx <- max(which(summary(fit_global)$time <= t))
  if(length(idx) > 0 && idx > 0) {
    prob <- summary(fit_global)$surv[idx]
    cat(sprintf("S(%4d jours) = %.4f\n", t, prob))
  }
}

################################################################################
# QUESTION 2: FONCTION DE SURVIE PAR SEXE
################################################################################

cat("\n================================================================================\n")
cat("QUESTION 2: ESTIMATION PAR SEXE (HOMMES vs FEMMES)\n")
cat("================================================================================\n\n")

# Estimation stratifiée
fit_sexe <- survfit(survie ~ SEXE_label, data=donnees, conf.type="log-log")
print(fit_sexe)

# Statistiques par groupe
table_sexe <- table(donnees$SEXE_label, donnees$DECES)
cat("\nTableau de contingence Sexe × Décès:\n")
print(addmargins(table_sexe))

cat("\nTaux de décès:\n")
for(sexe in c("Homme","Femme")) {
  n <- sum(donnees$SEXE_label==sexe)
  deces <- sum(donnees$SEXE_label==sexe & donnees$DECES==1)
  cat(sprintf("%s: %d/%d (%.1f%%)\n", sexe, deces, n, (deces/n)*100))
}

# Graphique
png("Q2_Survie_par_Sexe.png", width=1200, height=800, res=150)
plot(fit_sexe, col=c("blue","red"), lwd=2, conf.int=TRUE,
     xlab="Temps (jours)", ylab="S(t)",
     main="Fonctions de survie de Kaplan-Meier par sexe")
legend("topright", c("Homme","Femme"), 
       col=c("blue","red"), lty=1, lwd=2, bty="n")
dev.off()
cat("\n✓ Graphique sauvegardé: Q2_Survie_par_Sexe.png\n")

ggsurvplot(fit_sexe, data=donnees, conf.int=TRUE, 
           risk.table=TRUE, legend.labs=c("Homme","Femme"),
           palette=c("blue","red"), ggtheme=theme_minimal())
ggsave("Q2_Survie_par_Sexe_ggplot.png", width=12, height=8, dpi=300)

################################################################################
# QUESTION 3: COMPARAISON STATISTIQUE (TEST DU LOG-RANK)
################################################################################

cat("\n================================================================================\n")
cat("QUESTION 3: COMPARAISON STATISTIQUE DES COURBES DE SURVIE\n")
cat("================================================================================\n\n")

# A) TEST DU LOG-RANK
cat("A) TEST DU LOG-RANK (MANTEL-HAENSZEL)\n")
cat("--------------------------------------\n\n")

test_logrank <- survdiff(survie ~ SEXE_label, data=donnees)
print(test_logrank)

# Calcul de la p-value
pvalue <- 1 - pchisq(test_logrank$chisq, df=1)
cat(sprintf("\nStatistique Chi-2: %.4f\n", test_logrank$chisq))
cat(sprintf("P-value: %.6f\n\n", pvalue))

# Interprétation
cat("INTERPRÉTATION:\n")
if(pvalue < 0.001) {
  cat("*** DIFFÉRENCE HAUTEMENT SIGNIFICATIVE (p < 0.001) ***\n")
  cat("Il existe une différence très significative entre les courbes.\n\n")
} else if(pvalue < 0.01) {
  cat("** DIFFÉRENCE TRÈS SIGNIFICATIVE (p < 0.01) **\n\n")
} else if(pvalue < 0.05) {
  cat("* DIFFÉRENCE SIGNIFICATIVE (p < 0.05) *\n")
  cat("On rejette H0 au seuil de 5%.\n\n")
} else {
  cat("PAS DE DIFFÉRENCE SIGNIFICATIVE (p >= 0.05)\n")
  cat("On ne rejette pas H0. Les différences peuvent être dues au hasard.\n\n")
}

# Analyse Observés vs Attendus
cat("Analyse Observés (O) vs Attendus (E):\n")
obs_exp <- data.frame(
  Groupe = c("Homme","Femme"),
  Observes = test_logrank$obs,
  Attendus = round(test_logrank$exp, 2),
  Ecart = round(test_logrank$obs - test_logrank$exp, 2)
)
print(obs_exp)

if(test_logrank$obs[1] > test_logrank$exp[1]) {
  cat("\n→ Les hommes ont PLUS de décès que prévu: MOINS BONNE survie\n")
} else {
  cat("\n→ Les hommes ont MOINS de décès que prévu: MEILLEURE survie\n")
}

# B) TEST DE WILCOXON
cat("\n\nB) TEST DE WILCOXON (GEHAN-BRESLOW)\n")
cat("------------------------------------\n")
cat("Ce test pondère davantage les événements précoces.\n\n")

test_wilcoxon <- survdiff(survie ~ SEXE_label, data=donnees, rho=1)
print(test_wilcoxon)
pvalue_w <- 1 - pchisq(test_wilcoxon$chisq, df=1)
cat(sprintf("\nP-value: %.6f\n", pvalue_w))

# C) GRAPHIQUE AVEC P-VALUE
ggsurvplot(fit_sexe, data=donnees, conf.int=TRUE,
           pval=TRUE, pval.method=TRUE,
           risk.table=TRUE, palette=c("blue","red"),
           title="Comparaison des courbes de survie par sexe",
           subtitle=sprintf("Test du Log-Rank: p = %.4f", pvalue),
           surv.median.line="hv", ggtheme=theme_minimal())
ggsave("Q3_Comparaison_avec_pvalue.png", width=12, height=8, dpi=300)
cat("\n✓ Graphique sauvegardé: Q3_Comparaison_avec_pvalue.png\n")

# D) COURBES LOG-MINUS-LOG (vérification proportionnalité)
png("Q3_Log_Minus_Log.png", width=1200, height=800, res=150)
plot(fit_sexe, fun="cloglog", col=c("blue","red"), lwd=2,
     xlab="log(Temps)", ylab="log(-log(S(t)))",
     main="Courbes Log-Minus-Log\nTest de proportionnalité des risques")
legend("bottomright", c("Homme","Femme"), 
       col=c("blue","red"), lty=1, lwd=2)
abline(h=0, col="gray", lty=2)
dev.off()
cat("✓ Graphique sauvegardé: Q3_Log_Minus_Log.png\n")
cat("  (Si les courbes sont parallèles → hypothèse de proportionnalité OK)\n")

################################################################################
# QUESTION 4: FONCTION DE SURVIE PAR TRAITEMENT
################################################################################

cat("\n================================================================================\n")
cat("QUESTION 4: ESTIMATION PAR TYPE DE TRAITEMENT\n")
cat("================================================================================\n\n")

# Estimation stratifiée
fit_trait <- survfit(survie ~ Traitement_label, data=donnees, conf.type="log-log")
print(fit_trait)

# Statistiques
table_trait <- table(donnees$Traitement_label, donnees$DECES)
cat("\nTableau de contingence Traitement × Décès:\n")
print(addmargins(table_trait))

cat("\nTaux de décès par traitement:\n")
for(trait in levels(donnees$Traitement_label)) {
  n <- sum(donnees$Traitement_label==trait)
  deces <- sum(donnees$Traitement_label==trait & donnees$DECES==1)
  cat(sprintf("%-20s: %3d/%3d (%.1f%%)\n", trait, deces, n, (deces/n)*100))
}

# Graphique
png("Q4_Survie_par_Traitement.png", width=1400, height=900, res=150)
plot(fit_trait, col=c("gray30","blue","green","red"), lwd=2,
     xlab="Temps (jours)", ylab="S(t)",
     main="Fonctions de survie par type de traitement")
legend("topright", levels(donnees$Traitement_label),
       col=c("gray30","blue","green","red"), lty=1, lwd=2, cex=0.8)
dev.off()
cat("\n✓ Graphique sauvegardé: Q4_Survie_par_Traitement.png\n")

ggsurvplot(fit_trait, data=donnees, conf.int=FALSE, pval=TRUE,
           risk.table=TRUE, palette=c("gray30","blue","green","red"),
           title="Fonctions de survie par traitement",
           surv.median.line="hv", ggtheme=theme_minimal())
ggsave("Q4_Survie_par_Traitement_ggplot.png", width=14, height=9, dpi=300)

# TEST GLOBAL
cat("\nTEST DU LOG-RANK GLOBAL (4 TRAITEMENTS):\n")
cat("------------------------------------------\n\n")

test_trait <- survdiff(survie ~ Traitement_label, data=donnees)
print(test_trait)

pvalue_trait <- 1 - pchisq(test_trait$chisq, df=3)
cat(sprintf("\nStatistique Chi-2: %.4f\n", test_trait$chisq))
cat(sprintf("P-value: %.6f\n\n", pvalue_trait))

if(pvalue_trait < 0.05) {
  cat("*** DIFFÉRENCE SIGNIFICATIVE ENTRE LES TRAITEMENTS ***\n")
  cat("Au moins un traitement a une efficacité différente.\n\n")
} else {
  cat("PAS DE DIFFÉRENCE SIGNIFICATIVE\n")
  cat("Les différences observées peuvent être dues au hasard.\n\n")
}

# COMPARAISONS DEUX À DEUX
cat("COMPARAISONS DEUX À DEUX (TESTS POST-HOC):\n")
cat("-------------------------------------------\n\n")

traitements <- levels(donnees$Traitement_label)
comparaisons <- combn(traitements, 2)

for(i in 1:ncol(comparaisons)) {
  trait1 <- comparaisons[1,i]
  trait2 <- comparaisons[2,i]
  
  donnees_comp <- donnees[donnees$Traitement_label %in% c(trait1,trait2), ]
  survie_comp <- Surv(donnees_comp$DureeSurvieJr, donnees_comp$DECES)
  
  test_comp <- survdiff(survie_comp ~ Traitement_label, data=donnees_comp)
  pval_comp <- 1 - pchisq(test_comp$chisq, df=1)
  
  cat(sprintf("%s vs %s:\n", trait1, trait2))
  cat(sprintf("  Chi-2 = %.4f, p = %.6f", test_comp$chisq, pval_comp))
  
  if(pval_comp < 0.05) cat(" ***\n") 
  else cat(" (NS)\n")
}

# Correction de Bonferroni
seuil_bonf <- 0.05 / ncol(comparaisons)
cat(sprintf("\nSeuil de Bonferroni: %.4f\n", seuil_bonf))
cat("(Pour ajuster le risque d'erreur de type I)\n\n")

################################################################################
# SAUVEGARDE DES TABLEAUX RÉCAPITULATIFS
################################################################################

cat("================================================================================\n")
cat("SAUVEGARDE DES TABLEAUX RÉCAPITULATIFS\n")
cat("================================================================================\n\n")

# Tableau Q1
write.csv(data.frame(
  N_total = nrow(donnees),
  N_deces = sum(donnees$DECES),
  N_censures = sum(donnees$DECES==0),
  Taux_censure_pct = round(mean(donnees$DECES==0)*100, 2)
), "Tableau_Q1_Survie_Globale.csv", row.names=FALSE)
cat("✓ Tableau_Q1_Survie_Globale.csv\n")

# Tableau Q2-Q3
write.csv(data.frame(
  Sexe = c("Homme","Femme"),
  N_patients = as.numeric(table(donnees$SEXE_label)),
  N_deces = as.numeric(table(donnees$SEXE_label, donnees$DECES)[,"1"]),
  Taux_deces_pct = round(as.numeric(table(donnees$SEXE_label, donnees$DECES)[,"1"] / 
                                      table(donnees$SEXE_label))*100, 2),
  Test_LogRank_pvalue = pvalue
), "Tableau_Q2_Q3_Comparaison_Sexe.csv", row.names=FALSE)
cat("✓ Tableau_Q2_Q3_Comparaison_Sexe.csv\n")

# Tableau Q4
write.csv(data.frame(
  Traitement = levels(donnees$Traitement_label),
  N_patients = as.numeric(table(donnees$Traitement_label)),
  N_deces = as.numeric(table(donnees$Traitement_label, donnees$DECES)[,"1"]),
  Taux_deces_pct = round(as.numeric(table(donnees$Traitement_label, donnees$DECES)[,"1"] / 
                                      table(donnees$Traitement_label))*100, 2),
  Test_LogRank_pvalue = pvalue_trait
), "Tableau_Q4_Comparaison_Traitement.csv", row.names=FALSE)
cat("✓ Tableau_Q4_Comparaison_Traitement.csv\n")

################################################################################
# SYNTHÈSE FINALE
################################################################################

cat("\n================================================================================\n")
cat("SYNTHÈSE FINALE\n")
cat("================================================================================\n\n")

cat("FICHIERS GÉNÉRÉS:\n")
cat("-----------------\n")
cat("Graphiques:\n")
cat("  • Q1_Survie_Globale.png\n")
cat("  • Q1_Survie_Globale_ggplot.png\n")
cat("  • Q2_Survie_par_Sexe.png\n")
cat("  • Q2_Survie_par_Sexe_ggplot.png\n")
cat("  • Q3_Comparaison_avec_pvalue.png\n")
cat("  • Q3_Log_Minus_Log.png\n")
cat("  • Q4_Survie_par_Traitement.png\n")
cat("  • Q4_Survie_par_Traitement_ggplot.png\n\n")

cat("Tableaux CSV:\n")
cat("  • Tableau_Q1_Survie_Globale.csv\n")
cat("  • Tableau_Q2_Q3_Comparaison_Sexe.csv\n")
cat("  • Tableau_Q4_Comparaison_Traitement.csv\n\n")

cat("RÉSUMÉ DES RÉSULTATS PRINCIPAUX:\n")
cat("---------------------------------\n")
cat(sprintf("1. Survie globale: %d patients, %d décès (%.1f%%)\n",
            nrow(donnees), sum(donnees$DECES), mean(donnees$DECES)*100))
cat(sprintf("2. Comparaison par sexe: p = %.4f (%s)\n",
            pvalue, ifelse(pvalue<0.05,"SIGNIFICATIF","NON SIGNIFICATIF")))
cat(sprintf("3. Comparaison par traitement: p = %.4f (%s)\n\n",
            pvalue_trait, ifelse(pvalue_trait<0.05,"SIGNIFICATIF","NON SIGNIFICATIF")))

cat("================================================================================\n")
cat("ANALYSE TERMINÉE AVEC SUCCÈS!\n")
cat(sprintf("Date: %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat("================================================================================\n\n")

################################################################################
#                           FIN DU SCRIPT                                      #
################################################################################
