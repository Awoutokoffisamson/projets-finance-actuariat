# Projet : Analyse et Tarification en Assurance Auto

## Description
Ce dossier contient le projet réalisé par **AWOUTO Samson** et **GADO Giovanni** dans le cadre du cursus ISE3. 

Il s'agit d'une étude actuarielle complète portant sur la tarification en assurance automobile, basée sur l'approche classique fréquence-sévérité. Le projet s'appuie sur la base de données du *3rd Pricing Game* (100 000 polices d'assurance) et couvre toute la chaîne de modélisation :
- **Analyse exploratoire :** nettoyage des données, traitement des valeurs aberrantes par winsorisation, étude des corrélations et profilage des risques (véhicules, conducteurs).
- **Modélisation de la fréquence :** ajustement et comparaison de modèles de comptage (Poisson, Binomial Négatif, ZIP, ZINB). Le modèle de Poisson a été retenu après sélection par AIC (backward step).
- **Modélisation de la sévérité :** évaluation des modèles Gamma, Log-normal et Inverse Gaussien pour le coût des sinistres. Le modèle Log-normal a présenté les meilleures performances.
- **Tarification :** estimation de la prime pure (fréquence espérée × sévérité espérée) sur une base de validation, puis application d'une marge de sécurité de 15 % pour obtenir la prime commerciale.

## Application Interactive
Dans le cadre de ce projet, une application Shiny a été développée pour rendre le modèle opérationnel. Elle offre un outil de simulation de primes interactif se basant sur les caractéristiques de risque saisies par l'utilisateur.

🔗 **Découvrir l'application :** [Lys Assurance Auto](https://mesapplications.shinyapps.io/lys-assurance-auto/)

## Contenu du Dossier
- `Code_Tarification_Assurance_Auto.Rmd` : Code source RMarkdown contenant les analyses, la modélisation et la génération du rapport.
- `Rapport_Tarification_Assurance_Auto.pdf` : Rapport final détaillé de l'étude.
- `Data/` : Répertoire contenant les jeux de données utilisés pour l'analyse (bases d'apprentissage et de validation).
- `Sorties/` : Répertoire contenant les modèles sauvegardés (`.RData`) et les différents outputs générés (ex: `TARIFPUR.csv`).
