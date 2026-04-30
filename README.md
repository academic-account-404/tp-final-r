# Analyse de la régularité des trains Intercités

Projet de R - DO3 - 2025/2026  
**Bassier Eliott, Lahya Nadia, Latmi Jessy, Lewis Charlotte**

## Description

Ce projet analyse la corrélation entre la **fréquentation des gares** et la **régularité des liaisons Intercités** en France.  
Question : *Y a-t-il un lien entre le nombre de voyageurs au départ et la ponctualité des trains ?*

## Prérequis

```r
install.packages(c("shiny", "bslib", "tidyverse", "ggplot2", "plotly", "janitor", "stringi", "scales", "rmarkdown", "kableExtra", "broom"))
```

## Démarrage

### Lancer l'application Shiny (dashboard interactif)

```r
shiny::runApp("app.R")
```

### Générer le rapport HTML

```r
rmarkdown::render("analyse.Rmd")
```

## Données

Sources : [data.sncf.com](https://data.sncf.com) 
