# Analyse de survie, cancer gastrique

**Auteur :** Samson Koffi AWOUTO, ISE3, ENSAE Dakar
**Données :** cohorte de patients atteints de cancer de l'estomac, ENSAE 2025-2026
**Méthodes :** estimateur de Kaplan-Meier, modèle de Cox à risques proportionnels

---

## Contexte

Le cancer de l'estomac est l'un des cancers les plus létaux, en particulier dans les pays où le diagnostic intervient tardivement. Ce projet applique les méthodes d'analyse de survie à une cohorte de patients pour estimer les fonctions de survie, identifier les facteurs pronostiques et comparer l'effet des différents traitements disponibles.

---

## Contenu du dossier

| Fichier | Description |
|---|---|
| `Rapport_Final.pdf` | Rapport complet de l'analyse |
| `code_survie.R` | Script R reproductible |
| `Base_Projet_DC_Ensae_25_26_OK.csv` | Base de données patients |
| `modele_survie.xlsx` | Tableaux de résultats |
| `page_de_garde.pdf` | Page de garde du projet |

---

## Structure des données

La base contient une observation par patient avec les variables suivantes :

| Variable | Description |
|---|---|
| `DureeSurvieJr` | Durée de suivi en jours |
| `DECES` | Indicateur de décès (1 = décédé, 0 = censuré) |
| `SEXE` | 1 = Homme, 2 = Femme |
| `Traitement` | 0 = sans traitement, 1 = chirurgie, 2 = radiothérapie, 3 = chimiothérapie |

Les données censurées correspondent aux patients encore en vie à la date de clôture du suivi ou perdus de vue. L'analyse de survie tient compte explicitement de cette censure.

---

## Démarche

### Estimation de Kaplan-Meier

L'estimateur de Kaplan-Meier est non-paramétrique. Il estime la probabilité de survie S(t) à chaque instant de décès observé, en tenant compte des censures :

```
S(t) = ∏_{ti ≤ t} (1 - di/ni)
```

où di est le nombre de décès à l'instant ti et ni le nombre de sujets à risque juste avant ti.

Les courbes sont tracées globalement puis stratifiées par sexe et par type de traitement. Les comparaisons entre groupes utilisent le test du log-rank.

### Modèle de Cox

Le modèle de Cox (1972) modélise le risque instantané de décès en fonction des covariables sans supposer une forme paramétrique pour le risque de base :

```
h(t|X) = h₀(t) × exp(β₁X₁ + β₂X₂ + ... + βₚXₚ)
```

Les hazard ratios exp(βk) quantifient l'effet multiplicatif de chaque covariable sur le risque. Un HR > 1 indique un risque accru, un HR < 1 un effet protecteur.

L'hypothèse de proportionnalité des risques est vérifiée par les résidus de Schoenfeld.

### Comparaison des traitements

Quatre modalités de traitement sont comparées : absence de traitement, chirurgie seule, radiothérapie, chimiothérapie. Le test du log-rank global teste l'égalité des fonctions de survie entre les quatre groupes. Les comparaisons deux à deux utilisent une correction de Bonferroni pour contrôler le taux d'erreur de type I.

---

## Résultats principaux

La médiane de survie globale est de 420 jours. Le taux de censure est de 32 %, ce qui indique un suivi incomplet pour un tiers des patients, traité correctement par les méthodes non-paramétriques.

Le sexe n'est pas un facteur pronostique significatif (p = 0,23 au test du log-rank). En revanche, le type de traitement a un effet fort sur la survie (p < 0,001). La chimiothérapie est associée au meilleur pronostic (HR = 0,42 par rapport au groupe sans traitement, IC 95 % : [0,28 ; 0,63]).

Le modèle de Cox confirme ces résultats après ajustement : l'âge au diagnostic est un facteur de risque indépendant (HR = 1,03 par année supplémentaire, p = 0,01).

---

## Reproductibilité

```r
# Packages requis
install.packages(c("survival", "survminer", "ggplot2"))

# Charger les données et exécuter
donnees <- read.csv("Base_Projet_DC_Ensae_25_26_OK.csv", sep = ";", header = TRUE)
source("code_survie.R")
```
