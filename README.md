# Predicció de dropouts en estudiants universitaris mitjançant Models Estadístics

## Descripció

Aquest repositori conté la pràctica de **Models Estadístics** desenvolupada com a part dels estudis universitaris. El projecte implementa anàlisis estadístiques utilitzant models lineals generalitzats (GLM) i tècniques de preprocessament de dades en R, amb un enfocament en la validació de models i la visualització de resultats[attached_file:1].

## Estructura del Repositori

El projecte està organitzat en les següents carpetes i arxius:

```text
├─ GLMz/ # conté els models models lineals generalitzats
│  ├─ binary_response.Rmd
│  └─ numerical_response.Rmd
├─ images/ # conté les imatges utilitzades en l'informe
├─ preprocessing/ # conté els scripts i resultats del preprocessament de dades
│  ├─ preprocessing.Rmd
│  ├─ informe_inicial.html
│  └─ clean-data.csv
├─ time-series/
├─ informe.md
├─ informe.pdf
├─ llibreries_a_installar.R
├─ metadata_dataset.xlsx
├─ raw-data.csv
└─ README.md
```

## Dependències

Aquest projecte requereix R i els paquets següents:

- DataExplorer
- SmartEDA
- ROCR
- detectseparation
- forecast
- dplyr
- ggplot2

### Instal·lació de paquets

Pots instal·lar totes les dependències amb l'arxiu `lliberires_a_installar.R` proporcionat en aquest repositori.
