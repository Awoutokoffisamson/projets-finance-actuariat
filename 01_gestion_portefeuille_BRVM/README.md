# Modélisation et optimisation de portefeuille actions en zone UEMOA

**Projet de Gestion de Portefeuille, ENSAE Dakar, ISE3 (2025-2026)**
**Auteur :** Samson Koffi AWOUTO
**Encadrant :** P. A. KONTE

---

## Présentation

Ce projet applique trois approches quantitatives à la Bourse Régionale des Valeurs Mobilières (BRVM), marché boursier intégré de l'UEMOA. Les données couvrent 47 titres sur 7 pays, de mars 2019 à février 2026 (84 cours de clôture mensuels par titre).

Les cours ont été collectés via le package R [BRVM](https://github.com/Koffi-Fredysessie/BRVM) de Koffi Fredy Sessie, complété par scraping pour les données fondamentales manquantes.

---

## Structure du projet

```
BRVM/
├── Dossier_Gestion_Portefeuille_ISE3_2026.pdf   # Rapport PDF final
├── brvm.xlsx                                     # Base de données (8 feuilles)
├── page de garde.pdf                             # Page de garde
└── README.md
```

---

## Les trois exercices

### Exercice 1 : Théorie de Markowitz

Sélection de 12 actions BRVM sur 6 secteurs. Construction de la frontière efficiente par simulation Monte Carlo (10 000 portefeuilles). Identification du portefeuille tangent (Sharpe maximum) et du portefeuille de variance minimale. La Capital Market Line utilise un taux sans risque de 6,30 % (bons du Trésor sénégalais, janvier 2026).

| Portefeuille | Rendement ann. | Volatilité ann. | Sharpe |
|---|---|---|---|
| Tangent (Sharpe max) | 26,82 % | 21,53 % | 0,953 |
| Variance minimale | 8,70 % | 15,25 % | 0,157 |
| Equipondéré 1/N | 13,22 % | 21,59 % | 0,321 |

### Exercice 2 : Analyse fondamentale

Scoring composite sur 3 critères (PER 35 %, ROE 40 %, DY 25 %) pour 10 titres retenus. Pondération proportionnelle au score. Backtesting sur 12 mois (mars 2025 à février 2026) avec comparaison au BRVM Composite en Buy et Hold.

Approche inspirée de Damodaran (2012) pour le ROE et de la *Magic Formula* de Greenblatt (2006) pour la combinaison PER/ROE.

### Exercice 3 : Analyse technique

Construction de 4 indicateurs sur le BRVM Composite reconstruit (SMA 7/20 mois, RSI 6 mois, Bandes de Bollinger, MACD). Backtesting comparatif de 4 stratégies sur 12 mois.

| Stratégie | Performance | Sharpe |
|---|---|---|
| Buy et Hold | 104,51 % | 4,447 |
| SMA Golden/Death Cross | 94,35 % | 3,888 |
| RSI pur (30/70) | 0,00 % | n.d. |
| SMA + RSI combiné | proche SMA | n.d. |

---

## Données

Le fichier `brvm.xlsx` contient 8 feuilles.

| Feuille | Contenu |
|---|---|
| Données Complètes | Panel complet (cours, fondamentaux, 47 titres, 84 mois) |
| Résumé par Ticker | Secteur et pays par ticker |
| Cours Mensuels | Cours de clôture mensuels (47 titres) |
| PER Mensuel | PER mensuel par ticker |
| ROE Annuel | ROE annuel par ticker |
| Fondamentaux Annuels | PER, ROE, DY, Dette/EBITDA par année |
| exo2_scoring | Scores composites et poids du portefeuille fondamental |
| Traçabilité_Scraping | Documentation des valeurs collectées par scraping |

---

## Reproductibilité

```r
# Packages requis
library(readxl)
library(tidyverse)
library(quadprog)
library(kableExtra)
library(BRVM)

# Compiler le rapport
rmarkdown::render("Dossier_Gestion_Portefeuille_ISE3_2026.Rmd",
                  output_file = "Dossier_Gestion_Portefeuille_ISE3_2026.pdf")
```

**Moteur LaTeX :** XeLaTeX (MiKTeX 25.3)
**R :** 4.4.2

---

## Références

- Markowitz, H. (1952). Portfolio Selection. *Journal of Finance*, 7(1), 77-91.
- Sharpe, W.F. (1966). Mutual Fund Performance. *Journal of Business*, 39(1), 119-138.
- Wilder, J.W. (1978). *New Concepts in Technical Trading Systems*. Trend Research.
- Damodaran, A. (2012). *Investment Valuation* (3e éd.). Wiley Finance.
- Greenblatt, J. (2006). *The Little Book That Still Beats the Market*. Wiley.
- Sessie, K.F. (2024). Package R BRVM. [github.com/Koffi-Fredysessie/BRVM](https://github.com/Koffi-Fredysessie/BRVM)
- BCEAO (2026). Résultats des adjudications de bons du Trésor. UMOA-Titres.
