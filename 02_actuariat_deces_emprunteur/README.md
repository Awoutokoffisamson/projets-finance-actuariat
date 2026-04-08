# Note technique actuarielle, décès emprunteur sur plusieurs têtes

**Auteur :** Samson Koffi AWOUTO, ISE3, ENSAE Dakar
**Cadre réglementaire :** espace CIMA
**Tables de mortalité :** CIMA H (hommes) et CIMA F (femmes)
**Taux technique :** 3,5 % par an

---

## Ce que contient ce dépôt

Deux fichiers.

`note_technique_actuarielle.pdf` est la note technique complète. Elle couvre la tarification et le provisionnement du produit d'assurance décès emprunteur souscrit par deux co-emprunteurs, chacun couvert à hauteur d'une quotité contractuelle.

`simulateur_deces_emprunteur.xlsx` est le simulateur Excel associé. Il permet de calculer automatiquement les primes pures, les primes annuelles, les primes d'inventaire et commerciales, ainsi que les provisions mathématiques année par année, pour n'importe quelle combinaison d'âges, de durée de prêt et de quotités.

---

## Ce que traite la note

### Tarification

Le produit garantit le remboursement du capital restant dû au décès de l'un des co-emprunteurs, à hauteur de sa quotité. La note dérive chaque formule pas à pas, de la prime pure jusqu'à la prime commerciale facturée à l'emprunteur.

La chaîne de tarification suit quatre niveaux :

- prime pure, PP : valeur actuelle probable des prestations futures, sous hypothèse de décès en milieu d'année (UDD)
- prime annuelle nette, PA : obtenue par équivalence actuarielle avec la rente-due temporaire
- prime d'inventaire, PI : prime nette majorée des chargements de gestion
- prime commerciale, PC : prime d'inventaire divisée par (1 moins le taux de chargement commercial)

Toutes les formules sont exprimées en notation de commutation (fonctions D, C, M, N calculées sur les tables CIMA).

### Provisionnement

Quatre provisions sont couvertes : provision mathématique (méthode prospective), provision pour sinistres à payer, provision pour risques croissants et provision d'égalisation.

La provision mathématique est vérifiée par la récurrence de Fackler à chaque année. La provision pour risques croissants est construite à partir d'une table projetée avec un facteur de réduction annuel de 1 % sur les probabilités de décès.

### Limites du modèle

La note discute trois hypothèses qui méritent attention en pratique.

L'indépendance des durées de vie des deux co-emprunteurs est fausse pour des conjoints. La corrélation positive entre leurs mortalités peut majorer la prime globale de 2 à 5 %, selon les âges et la durée du prêt.

L'hypothèse UDD (décès en milieu d'année) surestime légèrement la prime par rapport à une hypothèse de décès en fin de période. L'écart est inférieur à 0,3 % pour des taux de mortalité faibles, soit la majorité des tranches d'âge couvertes.

Le taux technique réglementaire de 3,5 % est fixe. Si les rendements des actifs de la compagnie tombent durablement sous ce seuil, les provisions deviennent insuffisantes. Un scénario de stress à 2,5 % est utile pour mesurer la sensibilité.

---

## Illustration numérique

La note inclut un exemple complet sur deux assurés.

| Paramètre | Assuré 1 | Assuré 2 |
|---|---|---|
| Sexe | Masculin | Féminin |
| Âge | 40 ans | 38 ans |
| Table | CIMA H | CIMA F |
| Quotité | 70 % | 30 % |

Capital emprunté : 10 000 000 FCFA, durée 15 ans, taux débiteur 8 %.

| Composante | Assuré 1 | Assuré 2 | Total |
|---|---|---|---|
| Prime pure (FCFA) | 175 980 | 28 450 | 204 430 |
| Prime annuelle nette (FCFA/an) | 15 464 | 2 438 | 17 902 |
| Prime d'inventaire (FCFA/an) | 17 010 | 2 682 | 19 692 |
| Prime commerciale (FCFA/an) | 22 680 | 3 576 | 26 256 |
| Prime mensuelle (FCFA/mois) | 1 890 | 298 | 2 188 |

TAEA global : 0,263 %.

---

## Utiliser le simulateur Excel

Ouvrir `simulateur_deces_emprunteur.xlsx`. Les cellules d'entrée sont sur la première feuille. Renseigner :

- les âges des deux assurés à la souscription
- le sexe de chacun (pour le choix entre table CIMA H et CIMA F)
- la durée du prêt en années
- le capital initial
- le taux débiteur du prêt
- les quotités
- les taux de chargement d'inventaire et commercial

Les feuilles suivantes calculent automatiquement les fonctions de commutation, le tableau d'amortissement, les primes et les provisions.

---

## Références réglementaires

Code des assurances CIMA, livre II, titre IV : provisions techniques.
Tables de mortalité CIMA H et CIMA F, annexes réglementaires.
Taux technique maximum : article 338-7 du code CIMA.

---

## Importance pour la banque et l'assurance

La maîtrise technique démontrée dans cette note est vitale pour toute compagnie d'assurance-vie commercialisant des produits de prévoyance, ou pour toute banque proposant des crédits (via la bancassurance). Elle permet d'assurer :
- Une tarification juste, compétitive et prudente des garanties décès-invalidité sur un crédit pour limiter la sélection adverse.
- Une estimation précise des engagements (provisions mathématiques, sinistres à payer) conformément au code CIMA, garantissant l'équilibre de la compagnie.
- La capacité à modéliser finement le risque lié à des assurés multiples sur un même contrat (co-emprunteurs, conjoints), une complexité fréquente en assurance de crédit.
