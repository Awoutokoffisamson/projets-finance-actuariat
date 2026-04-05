# Projets en finance et actuariat

**Auteur :** Samson Koffi AWOUTO
**Formation :** ISE3, ENSAE Dakar
**Année :** 2025-2026

Ce dépôt regroupe les travaux réalisés dans le cadre des cours de gestion de portefeuille et de méthodes actuarielles. Chaque projet est autonome, avec ses données, ses résultats et sa documentation.

---

## Projets

### [01 — Gestion de portefeuille sur la BRVM](./01_gestion_portefeuille_BRVM/)

Construction et optimisation d'un portefeuille d'actions coté sur la Bourse Régionale des Valeurs Mobilières (BRVM), marché de l'UEMOA.

Le travail couvre trois exercices :

**Analyse fondamentale et technique.** Scoring des 47 titres du marché sur trois critères fondamentaux (PER, ROE, rendement du dividende) et trois indicateurs techniques (SMA, RSI, bandes de Bollinger). Sélection des 10 meilleures valeurs selon un score composite pondéré.

**Optimisation Markowitz.** Construction de la frontière efficiente sur 84 mois de cours de clôture mensuels (2017-2024). Identification du portefeuille à variance minimale et du portefeuille tangent (maximum de Sharpe). Ratio de Sharpe du portefeuille optimal : 0,61 (contre 0,29 pour le marché).

**Backtesting de stratégies de trading.** Comparaison de quatre stratégies sur 7 ans : Buy et Hold, croisement de moyennes mobiles (SMA 7/20 mois), RSI (seuils 30/70), et combinaison SMA+RSI. La stratégie combinée surperforme toutes les autres avec un rendement cumulé de 312 % et un drawdown maximal de 18 %.

Données extraites via le package R `BRVM` (API sikafinance.com), complétées par scraping des pages de cotation.

| Stratégie | Rendement cumulé | Sharpe | Drawdown max |
|---|---|---|---|
| Buy et Hold | 187 % | 0,29 | 31 % |
| SMA | 241 % | 0,44 | 22 % |
| RSI | 198 % | 0,33 | 28 % |
| SMA + RSI | 312 % | 0,61 | 18 % |

**Outils :** R, R Markdown, knitr, ggplot2, PerformanceAnalytics, quadprog

---

### [02 — Note technique actuarielle, décès emprunteur sur plusieurs têtes](./02_actuariat_deces_emprunteur/)

Proposition de note technique pour un produit d'assurance décès emprunteur souscrit par deux co-emprunteurs dans le cadre réglementaire CIMA.

Le produit garantit le remboursement du capital restant dû au décès de l'un des assurés, à hauteur de sa quotité contractuelle.

La note couvre la chaîne complète de tarification et le provisionnement :

- prime pure, construite comme valeur actuelle probable des prestations futures sous hypothèse UDD
- prime annuelle nette, par équivalence actuarielle avec la rente-due temporaire
- prime d'inventaire et prime commerciale, avec les chargements correspondants
- provisions mathématiques (méthode prospective), vérifiées par la récurrence de Fackler
- provision pour risques croissants, avec construction explicite de la table projetée
- provision pour sinistres à payer, avec calibration du coefficient de revalorisation

Toutes les formules sont dérivées pas à pas, de l'expression générale jusqu'à la solution numérique. Les tables CIMA H et CIMA F sont utilisées avec un taux technique de 3,5 %.

Le simulateur Excel joint recalcule automatiquement primes et provisions pour n'importe quelle combinaison d'âges, de durée de prêt et de quotités.

**Illustration numérique :** deux assurés, 40 ans (homme, quotité 70 %) et 38 ans (femme, quotité 30 %), crédit de 10 000 000 FCFA sur 15 ans à 8 %.

| Composante | Total |
|---|---|
| Prime pure (FCFA) | 204 430 |
| Prime annuelle nette (FCFA/an) | 17 902 |
| Prime commerciale (FCFA/an) | 26 256 |
| Prime mensuelle (FCFA/mois) | 2 188 |
| TAEA | 0,263 % |

**Outils :** LaTeX, Excel

---

## Structure du dépôt

```
projets-finance-actuariat/
├── 01_gestion_portefeuille_BRVM/
│   ├── Dossier_Gestion_Portefeuille_ISE3_2026.pdf
│   ├── brvm.xlsx
│   ├── page_de_garde.pdf
│   └── README.md
└── 02_actuariat_deces_emprunteur/
    ├── note_technique_actuarielle.pdf
    ├── simulateur_deces_emprunteur.xlsx
    └── README.md
```

Les fichiers sources (.Rmd, .tex) ne sont pas versionnés dans ce dépôt.

---

## Contact

Samson Koffi AWOUTO
ENSAE Dakar, ISE3
