# Modélisation ARCH(1) - Simulation et application Bitcoin

Ce projet porte sur la modélisation de la volatilité des actifs financiers en utilisant le modèle ARCH(1) (Autoregressive Conditional Heteroskedasticity). L'étude combine des développements théoriques, des simulations intensives et une application concrète sur les rendements du Bitcoin.

## Contenu du projet

Le travail est structuré en quatre grandes parties :

1. **Simulation du processus ARCH(1) :** Mise en œuvre de la récursion de variance pour générer des trajectoires sous hypothèses gaussienne et de Student (loi t). Analyse des propriétés statistiques (regroupement de volatilité, leptokurticité).
2. **Estimation QMLE "from scratch" :** Développement d'un moteur d'optimisation par Quasi-Maximum de Vraisemblance sans utiliser de packages spécialisés. Utilisation d'un gradient analytique pour garantir la précision des résultats.
3. **Étude de Monte-Carlo :** Analyse de la performance de l'estimateur sur des échantillons répétés. Validation de la convergence asymptotique en $\sqrt{n}$ et des taux de couverture des intervalles de confiance.
4. **Application empirique au Bitcoin :** Analyse des log-rendements quotidiens sur les 5 dernières années. Identification des crises de volatilité et comparaison des modèles ARCH(1) et GARCH(1,1) par critère d'information (AIC).

## Résultats principaux

- **Convergence :** L'estimateur QMLE retrouve les paramètres de simulation avec une erreur décroissante suivant strictement la théorie asymptotique.
- **Bitcoin :** Le modèle ARCH(1) parvient à capter l'essentiel de la structure de variance, bien qu'un modèle GARCH(1,1) offre une meilleure persistance pour cet actif.
- **Volatilité :** Identification précise des chocs de marché (pandémie 2020, chutes crypto 2022).

## Fichiers disponibles

- `Rapport_ARCH_Bitcoin.pdf` : Rapport complet mis en page sous LaTeX via R Markdown.
- `Rapport_ARCH_Bitcoin.Rmd` : Code source R Markdown incluant l'intégralité des algorithmes développés.
- `page de garde.pdf` : Couverture officielle du rapport.

**Outils utilisés :** R, R Markdown (XeLaTeX), ggplot2, kableExtra, quantmod.
