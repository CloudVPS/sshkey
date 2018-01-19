# SSH Key script

[![N|Solid](https://www.cloudvps.nl/sites/default/files/logo-cloudvps.jpg)](https://github.com/cloudvps/sshkey)

Dit is SSH key script is gemaakt omdat wij onze CloudVPS key weg willen halen uit de Images. Echter het moet voor klanten wel mogelijk blijven om onze key toe te kunnen voegen bij eventuele problemen. Ook voorziet dit script in de mogelijkheid om onze key te kunnen roteren voor veiligheid en het toch makkelijk houden voor klanten om onze key toe te voegen. 

# De Functies

  - Checked of er curl of wget is
  - Checked of de map en bestand onze de user waar het script onder draait aanwezig is (en maakt deze aan als deze ontbreken)
  - Controle of de opgehaalde key geldig is
  - Maakt een backup van authorized keys als de key geldig is en geplaatst gaat worden
  - Voegt onze key toe aan bestaande authorized_keys 
  - Voegt een comment toe zodat een klant kan zien wanneer dit voor het laatst was gebeurt
  - Maakt een at of cronjob aan welke de key weer weghaalt na 24 uur (of 1 week bij de cronjob)

### Installatie

Voor het gebruik van dit script is curl of Wget nodig. 

#### curl 

```sh
$ curl -s -L https://l.cloudvps.nl/sshkey | bash
```
#### wget  

```sh
$ wget --quiet -O - https://l.cloudvps.nl/sshkey | bash
```

### Verder

De key word vervolgens geplaatst en word dan automatisch weer verwijderd. De backup van authorized_keys blijft wel staan. 
