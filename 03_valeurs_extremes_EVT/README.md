# Modélisation des valeurs extrêmes, débits du fleuve Sénégal à Bakel

**Auteur :** Samson Koffi AWOUTO, ISE3, ENSAE Dakar
**Période couverte :** 1950 à 2020 (71 ans)
**Méthode principale :** GEV non-stationnaire avec covariable pluviométrique

---

## Contexte

Le fleuve Sénégal à Bakel est un point de mesure hydrologique de référence pour l'Afrique de l'Ouest. Les débits maximaux annuels enregistrés à cette station présentent une rupture visible autour de 1976, qui coïncide avec le début de la grande sécheresse sahélienne. Ce projet analyse cette série sur 71 ans en appliquant la théorie des valeurs extrêmes (EVT) pour modéliser et quantifier les risques de crues.

---

## Contenu du dossier

| Fichier | Description |
|---|---|
| `Rapport_Final_AWOUTO_Koffi_Samson.pdf` | Rapport complet de l'analyse |
| `Code_R_Final_AWOUTO_Koffi_Samson.R` | Script R reproductible |
| `Bakel_Debit_Max_Pluie_Annuel.xlsx` | Données brutes (débits m³/s et pluies mm, 1950-2020) |

---

## Démarche

### Analyse préliminaire

Avant toute modélisation, deux tests de stationnarité sont appliqués sur la série des débits maximaux annuels.

Le test de Mann-Kendall détecte une tendance monotone significative à la baisse (p < 0,01). Le test de Pettitt identifie un point de rupture en 1976, qui délimite une période humide (1950-1975) et une période sèche (1976-2020).

La corrélation entre débit maximal et pluviométrie annuelle est forte (r > 0,70, p < 0,001), ce qui justifie d'introduire la pluie comme covariable dans le modèle.

### Modélisation GEV stationnaire

On ajuste d'abord une loi GEV (Generalized Extreme Value) stationnaire sur l'ensemble de la série. La loi GEV regroupe les trois types de distributions limites des maxima (Gumbel, Fréchet, Weibull) selon le signe du paramètre de forme ξ :

- ξ = 0 : Gumbel (queues exponentielles)
- ξ > 0 : Fréchet (queues lourdes)
- ξ < 0 : Weibull (queue bornée)

Les paramètres μ (localisation), σ (échelle) et ξ (forme) sont estimés par maximum de vraisemblance via le package `evd`.

### Modélisation GEV non-stationnaire

Le modèle non-stationnaire intègre la pluviométrie annuelle comme covariable sur le paramètre de localisation μ :

```
μ(t) = μ₀ + μ₁ × Pluie(t)
```

Ce modèle capture l'effet de la variabilité climatique interannuelle sur les débits extrêmes. La comparaison avec le modèle stationnaire se fait par test du rapport de vraisemblance et critère AIC.

### Niveaux de retour

Les quantiles de période de retour T = 10, 50 et 100 ans sont estimés avec intervalles de confiance à 95 % par bootstrap paramétrique. Ces niveaux de retour alimentent directement les décisions d'ingénierie (dimensionnement des ouvrages hydrauliques, seuils d'alerte).

---

## Résultats principaux

La rupture de 1976 est confirmée statistiquement. Le débit moyen maximal annuel passe de 4 200 m³/s sur la période humide à 2 600 m³/s sur la période sèche, soit une baisse de 38 %.

Le modèle GEV non-stationnaire est significativement meilleur que le modèle stationnaire (ΔAIC > 4). Le paramètre μ₁ est positif et significatif : une hausse de 100 mm de pluie annuelle est associée à une hausse du débit centennal de l'ordre de 800 m³/s.

---

## Reproductibilité

```r
# Packages requis
install.packages(c("readxl", "evd", "ggplot2", "gridExtra", "e1071",
                   "knitr", "kableExtra", "car"))

# Exécuter le script (données dans le même répertoire)
source("Code_R_Final_AWOUTO_Koffi_Samson.R")
```

Les données sont dans `Bakel_Debit_Max_Pluie_Annuel.xlsx`, à placer dans le même répertoire que le script.
