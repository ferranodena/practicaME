# Predicció de dropouts en estudiants universitaris mitjançant modelització estadística

## Descripció

Aquest repositori conté la pràctica de **Modelització estadística** desenvolupada com a part dels estudis universitaris. El projecte implementa anàlisis estadístiques utilitzant models lineals generalitzats (GLM) i tècniques de preprocessament de dades en R, amb un enfocament en la validació de models i la visualització de resultats[attached_file:1].

## Estructura del Repositori

El projecte està organitzat en les següents carpetes i arxius:

- ``GLMz/``, que conté els models models lineals generalitzats
  - ``binary_response.Rmd``, script per a la modelització amb resposta binària
  - ``numerical_response.Rmd``, script per a la modelització amb resposta numèrica
- ``images/``, conté les imatges usades a l'informe
- ``preprocessing/`` # conté els scripts i resultats del preprocessament de dades
  - ``preprocessing.Rmd``
  - ``informe_inicial.html``
  - ``clean-data.csv``
- ``time-series/``
  - ``monthly-car-sales.csv``, dataset de sèries temporals
  - ``time-series.Rmd``, script per a l'anàlisi de sèries temporals
- ``informe.md``
- ``informe.pdf``, informe del projecte
- ``llibreries_a_installar.R``, script per instal·lar les dependències
- ``metadata_dataset.xlsx``
- ``raw-data.csv``
- ``README.md``

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
