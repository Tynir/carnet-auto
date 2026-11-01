# Carnet auto

Carnet d'entretien de tes véhicules : interventions, coûts par année, rappels au kilométrage et à la date.
Même principe que Nos photos : une web app installable, hébergée sur GitHub Pages, avec les données dans
**le même projet Supabase** (mêmes comptes, même connexion).

Chaque personne ne voit que ses propres véhicules : ta copine peut avoir son propre carnet, vous ne verrez pas celui de l'autre.

## Installation (environ 10 minutes)

1. **Supabase**, projet `nos-photos` : **SQL Editor**, nouvelle requête, colle tout `schema-carnet.sql`, puis **Run**.
2. **config.js** : colle la même clé publique que dans le config.js de Nos photos (l'URL est déjà remplie).
3. **GitHub** : nouveau dépôt **public** `carnet-auto`, puis **Upload files** avec tout le contenu du dossier
   (index.html, config.js, manifest.json, sw.js, icons/, schema-carnet.sql), puis **Commit**.
4. **Settings → Pages** : **Deploy from a branch**, branche `main`, dossier `/ (root)`, puis **Save**.
   L'adresse sera `https://tynir.github.io/carnet-auto/`.
5. **Téléphone** : ouvre l'adresse, puis **Ajouter à l'écran d'accueil**. Connexion avec le même e-mail et le même mot de passe que Nos photos.

## Utilisation

- **Ajouter un véhicule** : nom, modèle, immatriculation (facultative), kilométrage actuel.
- **Ajouter une intervention** : type, date, kilométrage, coût, garage, notes.
  Le champ **À refaire dans** crée le rappel : par exemple 15 000 km ou 12 mois pour une vidange.
  Pour la vidange et le contrôle technique, l'appli propose des valeurs par défaut (15 000 km / 12 mois, et 24 mois),
  à ajuster selon ton carnet constructeur.
- **Mettre à jour** le kilométrage de temps en temps : les rappels au kilométrage s'appuient dessus.
  Saisir une intervention avec un kilométrage plus élevé met aussi le compteur à jour.
- **Cote** : le bouton **Coter** ouvre la cote gratuite de La Centrale. Fais l'estimation, puis **Ajouter la cote**
  pour reporter le montant (avec la date et le kilométrage). L'historique montre la valeur qui baisse au fil du temps.
- **Réparation / valeur** : en saisissant le coût d'une intervention, l'appli indique ce qu'il représente par rapport à la cote.
  Vert sous 25 %, orange jusqu'à 50 %, rouge au-delà : à ce stade, ça vaut le coup de comparer avec un remplacement.
- **Coût réel** : renseigne le prix et la date d'achat (Modifier le véhicule). L'appli calcule achat + entretien − cote actuelle,
  et le coût par mois.
- **Rappels** : pour chaque type, c'est la dernière intervention qui compte. Orange à moins de 1 000 km ou 30 jours, rouge si c'est dépassé.
