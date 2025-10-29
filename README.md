# Predicció de dropouts en estudiants universitaris mitjançant modelització estadística

## Descripció

Aquest repositori conté la pràctica de **Modelització estadística** desenvolupada com a part dels estudis universitaris. El projecte implementa anàlisis estadístiques utilitzant models lineals generalitzats (GLM) i tècniques de preprocessament de dades en R, amb un enfocament en la validació de models i la visualització de resultats.

En aquest projecte, hem decidit treballar amb la base de dades Predict Students’ Dropout and Academic Success, perquè volem aprofundir en l’abandonament i l’èxit acadèmic a la universitat, un tema que considerem d’especial interès, no només pel fet que ens toca de ben a prop, sinó també, perquè tenint en compte les pautes d’aquest projecte, aconseguirem un model que ens pugui predir, de manera força fiable, quin perfil d’estudiant hauria de deixar o acabar una carrera universitària. Aquest aspecte del treball és el que més ens ha motivat a escollir aquest perfil de dataset.

En concret, aquest dataset està format per més de 4000 registres d’estudiants universitaris i prop de quaranta variables demogràfiques, socials i acadèmiques. Totes aquestes variables són les que ens permeten poder portar a terme el projecte que tenim al cap, ja que és cert que el tema ens interessa, però també havíem de trobar un dataset que seguís els requisits necessaris per poder fer aquest treball.

Ens interessa especialment la riquesa de la informació disponible, pel fet que tenim accés a dades que a priori poden semblar molt poc rellevant, però que potser, posteriorment acabem trobant una correlació molt més forta de la que ens esperaríem inicialment. Això és un aspecte molt positiu sobre les variables que ens hi podem trobar en el dataset. L’altra cara de la moneda podria ser que ens podem trobar en una situació que ens passi just el contrari. Donem per fet que la importància de certs factors alhora d’un bon rendiment acadèmic, com per exemple les hores de son diàries d’un estudiant, però realment podem dir per estadística que aquest és el cas? Doncs aquestes qüestions són les que creiem que podem resoldre en aquest treball.

## Estructura del Repositori

El projecte està organitzat en les següents carpetes i arxius:

- ``GLMz/``, que conté els models models lineals generalitzats
  - ``binary_response.Rmd``, script per a la modelització amb resposta binària
  - ``numerical_response.Rmd``, script per a la modelització amb resposta numèrica
- ``images/``, conté les imatges usades a l'informe
- ``preprocessing/`` conté els scripts i resultats del preprocessament de dades
  - ``preprocessing.Rmd``, script per al preprocessament de dades
  - ``informe_inicial.html``, informe del preprocessament inicial, generat per la llibreria `SmartEDA`
  - ``clean-data.csv``, dataset netejat després del preprocessament
- ``time-series/`` conté l'anàlisi de sèries temporals
  - ``monthly-car-sales.csv``, dataset de sèries temporals
  - ``time-series.Rmd``, script per a l'anàlisi de sèries temporals
- ``informe.md``, informe del projecte en format markdown
- ``informe.pdf``, informe del projecte
- ``llibreries_a_installar.R``, script per instal·lar les dependències
- ``metadata_dataset.xlsx`` conté la descripció de les variables del dataset
- ``raw-data.csv``, dataset original sense preprocessar
- ``README.md``

## Dependències

Aquest projecte requereix R i els paquets següents:

- ``DataExplorer``
- ``SmartEDA``
- ``ROCR``
- ``detectseparation``
- ``forecast``
- ``dplyr``
- ``ggplot2``

### Instal·lació de paquets

Pots instal·lar totes les dependències amb l'arxiu `lliberires_a_installar.R` proporcionat en aquest repositori.

## Autors

Els autors d'aquest projecte són:

- Pau Aboal
- Ferran Òdena (project manager)
- Carlos Palazón
- Guillem Piany
- Pol Riera
  