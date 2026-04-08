# Analyse de survie, cancer gastrique

**Auteur :** Samson Koffi AWOUTO, ISE3, ENSAE Dakar
**Encadrant :** Dr Aba DIIOP, Université Alioune DIOP
**Données :** cohorte de 200 patients atteints de cancer de l'estomac, ENSAE 2025-2026
**Méthodes :** Kaplan-Meier, log-rank, modèle de Cox à risques proportionnels

---

## Pourquoi l'analyse de survie est centrale en actuariat

L'actuariat, dans sa fonction la plus fondamentale, répond à une question sur le temps : combien de temps un individu va-t-il vivre, travailler, ou rester en bonne santé ? L'analyse de survie est précisément la branche statistique construite pour répondre à ce type de question en présence de données censurées, c'est-à-dire lorsqu'on ne connaît pas l'issue finale pour tous les individus au moment de l'analyse.

Ses applications en actuariat sont directes et nombreuses.

**Tables de mortalité.** La table de mortalité, colonne vertébrale de tout produit d'assurance vie, est une estimation de la fonction de survie S(t) à chaque âge. L'estimateur de Kaplan-Meier en est la version non-paramétrique moderne, utilisée pour construire ou valider des tables d'expérience à partir de données réelles de portefeuille.

**Tarification vie et prévoyance.** La prime pure d'une assurance décès temporaire, d'une rente-survie ou d'un contrat d'invalidité se calcule comme une intégrale sur la courbe de survie pondérée par les prestations et actualisée. Mieux estimer S(t), c'est mieux tarifer.

**Provisions mathématiques.** Les réserves d'un portefeuille vie ou prévoyance dépendent des probabilités de survie projetées. Un modèle de Cox qui identifie des facteurs de risque (âge, comorbidités, traitement) permet de différencier les provisions par segment de risque, ce que font les assureurs pour les portefeuilles santé et dépendance.

**Risque de crédit.** En finance, le "temps jusqu'au défaut" d'un emprunteur se modélise exactement comme un temps de survie. Le modèle de Cox est utilisé en scoring de crédit, en pricing de CDS et dans les modèles de durée de l'Autorité bancaire européenne. Le hazard ratio devient un multiplicateur de risque de défaut.

**Assurance dépendance.** Modéliser le temps jusqu'à l'entrée en dépendance lourde, ou jusqu'au décès après entrée en dépendance, requiert des modèles multi-états qui généralisent directement l'analyse de survie. C'est l'un des défis actuariels majeurs des prochaines décennies en Afrique subsaharienne avec le vieillissement démographique.

Ce projet applique ces méthodes à un contexte médical concret où les enjeux de mortalité, de censure et d'hétérogénéité des risques se posent dans les mêmes termes qu'en actuariat de portefeuille.

---

## Contenu du dossier

| Fichier | Description |
|---|---|
| `Koffi_Samson_AWOUTO.pdf` | Rapport complet de l'analyse (31 pages) |
| `code_survie.R` | Script R reproductible |
| `Base_Projet_DC_Ensae_25_26_OK.csv` | Base de données patients (200 observations) |
| `modele_survie.xlsx` | Tableaux de résultats |

---

## Structure des données

La base contient une observation par patient avec les variables suivantes :

| Variable | Description |
|---|---|
| `DureeSurvieJr` | Durée de suivi en jours |
| `DECES` | Indicateur de décès (1 = décédé, 0 = censuré) |
| `SEXE` | 1 = Homme, 2 = Femme |
| `AGE` | Âge au diagnostic (moyenne 53,5 ans, étendue 26-82) |
| `Traitement` | 0 = sans traitement, 1 = chirurgie, 2 = radiothérapie, 3 = chimiothérapie |
| `AntPersoMed` | Antécédents médicaux personnels |
| `AntFamil` | Antécédents familiaux de cancer |
| `DuréeSymptomMois` | Délai diagnostic en mois depuis premiers symptômes |
| `Scan.Metastases` | Présence de métastases au scanner |

Sur 200 patients, 98 sont décédés (49 %) et 102 sont censurés (51 %). La censure correspond aux patients encore en vie à la clôture du suivi ou perdus de vue.

---

## Démarche

### Estimation de Kaplan-Meier

L'estimateur de Kaplan-Meier est non-paramétrique et traite la censure explicitement :

```
S(t) = ∏_{ti ≤ t} (1 - di/ni)
```

où di est le nombre de décès à l'instant ti et ni le nombre de sujets à risque juste avant ti.

Les courbes sont tracées globalement, par sexe et par traitement. La survie globale atteint un plateau autour de 55 % à dix ans, ce qui indique une sous-population de longs survivants, probablement parmi les patients ayant reçu un traitement actif.

### Tests du log-rank

Le test du log-rank compare les fonctions de survie entre groupes sans hypothèse paramétrique. Le sexe n'est pas un facteur pronostique discriminant (p = 0,49). Le type de traitement, en revanche, est extrêmement significatif (p = 3×10⁻¹¹). Le Traitement 0 (absence de traitement, 9 patients) affiche une médiane de survie de 19 jours. Les patients sous chirurgie ou chimiothérapie atteignent des médianes non atteintes à l'horizon d'observation.

L'âge en classes tertiles (Jeunes [26-48], Moyens [48-57], Agés [57-82]) ne produit pas de différence significative au log-rank global (p = 0,22), bien que la classe jeune présente paradoxalement la survie médiane la plus courte, ce qui suggère des formes plus agressives chez les patients diagnostiqués jeunes.

### Modèle de Cox

Le modèle de Cox modélise le risque instantané de décès sans supposer une forme paramétrique pour le risque de base :

```
h(t|X) = h₀(t) × exp(β₁X₁ + β₂X₂ + ... + βₚXₚ)
```

Un modèle complet à 17 variables est estimé, puis réduit par sélection descendante selon le critère AIC (`stepAIC`). Le modèle final retient 11 variables avec un indice de concordance de 0,811.

### Résultats du modèle final

| Variable | HR | IC 95 % | p |
|---|---|---|---|
| AGE (par an) | 1,053 | [1,033 ; 1,074] | < 0,001 |
| Antécédents personnels | 7,026 | [4,299 ; 11,481] | < 0,001 |
| Antécédents familiaux | 2,966 | [1,575 ; 5,587] | 0,001 |
| Mode de vie | 1,733 | [1,078 ; 2,787] | 0,023 |
| Comorbidités | 1,622 | [1,015 ; 2,590] | 0,043 |
| Épigastralgies | 0,213 | [0,124 ; 0,368] | < 0,001 |
| Délai diagnostic (mois) | 1,094 | [1,058 ; 1,131] | < 0,001 |
| Métastases | 0,401 | [0,227 ; 0,706] | 0,002 |
| Traitement 0 vs 1 | 3,822 | [1,395 ; 10,469] | 0,009 |
| Traitement 2 vs 1 | 9,880 | [1,171 ; 83,347] | 0,035 |
| Traitement 3 vs 1 | 1,051 | [0,644 ; 1,714] | 0,843 |

Le facteur de risque dominant est la présence d'antécédents médicaux personnels (HR = 7,03). L'âge augmente le risque de 5,3 % par année supplémentaire. Une fois ajusté sur les comorbidités et le profil clinique, la chimiothérapie (Traitement 3) n'est plus statistiquement distinguable de la chirurgie (Traitement 1) comme référence, ce qui illustre l'importance du contrôle des facteurs confondants dans l'évaluation comparative des traitements.

### Tests d'interaction et validation

Deux interactions significatives sont confirmées par test du rapport de vraisemblance : Age × Sexe (p = 0,008) et Traitement × Age (p = 0,012), indiquant que l'efficacité relative des traitements varie selon l'âge du patient. Cette hétérogénéité d'effet est une information utile pour la segmentation tarifaire en assurance maladie ou dépendance.

Le test global de Schoenfeld rejette l'hypothèse de proportionnalité des risques (p = 3,3×10⁻¹¹). Un modèle stratifié sur la variable Épigastralgies est proposé comme alternative, avec des coefficients très proches du modèle principal, ce qui confirme que les conclusions tiennent sous une spécification alternative.

Les résidus de martingale ne montrent pas de non-linéarité flagrante pour les variables continues.

---

## Reproductibilité

```r
# Packages requis
install.packages(c("survival", "survminer", "ggplot2", "knitr",
                   "kableExtra", "muhaz", "forestmodel", "MASS"))

# Charger les données et exécuter
df <- read.csv("Base_Projet_DC_Ensae_25_26_OK.csv",
               sep = ";", header = TRUE,
               stringsAsFactors = FALSE,
               fileEncoding = "latin1",
               check.names = FALSE)
source("code_survie.R")
```

---

## Importance pour la banque et l'assurance

Comme détaillé dans l'introduction de ce projet, les modèles de survie sont au cœur de la tarification et de l'évaluation des risques en assurance (modèles multi-états, assurance santé, dépendance et prévoyance). En banque, les mêmes modèles sont appliqués pour le risque de crédit. La maîtrise de ces outils pointus permet :
- De tarifer dynamiquement les produits de rentes, retraite ou santé en introduisant des caractéristiques complexes des assurés (covariables).
- De provisionner de façon différenciée suivant le profil de l'assuré en prenant en compte la censure d'une durée d'observation.
- D'appliquer ces modèles de survie algorithmique à l'analyse du délai avant défaut de crédit pour une banque, anticipant ainsi le risque financier.
