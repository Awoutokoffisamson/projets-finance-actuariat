# Application Shiny interactive, subdivisions du Burkina Faso

**Auteur :** Samson Koffi AWOUTO, ISE3, ENSAE Dakar
**Technologies :** R, Shiny, Leaflet, sf
**Application en ligne :** [mesapplications.shinyapps.io/Burkina_Faso_Subdivisions_2025](https://mesapplications.shinyapps.io/Burkina_Faso_Subdivisions_2025/)
**Dépôt :** [github.com/Awoutokoffisamson/burkina_application_shiny](https://github.com/Awoutokoffisamson/burkina_application_shiny)

---

## Description

Application Shiny pour explorer les subdivisions administratives du Burkina Faso selon la réforme de 2025. Elle couvre les trois niveaux : 17 régions, 47 provinces et 351 communes.

Les données de population proviennent du Recensement Général de la Population et de l'Habitat (RGPH 2019), avec une population totale de 20 505 155 habitants sur une superficie de 274 220 km².

---

## Fonctionnalités

- Carte interactive avec zoom et survol des zones
- Tableaux filtrables par région et province
- Graphiques de population et de densité par unité administrative
- Navigation fluide entre les trois niveaux administratifs

---

## Architecture

| Fichier | Contenu |
|---|---|
| `app.R` | Interface utilisateur et serveur Shiny |
| `global.R` | Chargement et préparation des données |
| `data/` | Shapefiles et données de population |
| `www/styles.css` | Styles CSS |

---

## Déploiement

L'application est déployée sur shinyapps.io. Pour la relancer localement :

```r
install.packages(c("shiny", "leaflet", "sf", "plotly", "DT"))
shiny::runApp(".")
```

---

## Licence

CC BY-NC-SA 4.0. Toute utilisation commerciale est interdite sans autorisation de l'auteur.
