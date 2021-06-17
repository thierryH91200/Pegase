# Coding Guidelines

Les valeurs de codage d'Evergreen sont, dans l'ordre:

* Aucune perte de données
* Pas d'accidents
* Pas d'autres bugs
* Performance rapide
* Productivité du développeur

Ils ne s'opposent pas: ils travaillent ensemble.

Le dernier devrait être d'un intérêt particulier: le travail se passe souvent en petites rafales, et tout le monde devrait pouvoir progresser sur quelque chose en 15 minutes.

Bien qu'il soit plus important d'avoir une application géniale que d'être productif, être productif est une partie extrêmement importante - souvent sous-estimée - de la création d'une application géniale.

### Problem solving

Vous avez vu comment, dans Auto Layout, il y a une priorité de résistance à la compression du contenu et une priorité d'étreinte du contenu?

C'est ainsi que nous pensons aux problèmes: le problème de la priorité de la résistance à la compression est au maximum, et la priorité de l'étreinte du problème est également au maximum.

En d'autres termes: résoudre le problème. Pas moins que le problème, mais pas plus que le problème - ne pas trop généraliser.

De même: travaillez toujours au plus haut niveau possible, mais pas plus haut et certainement pas plus bas.

### Language

Ecrire le nouveau code en Swift 5.

La seule exception à cette règle concerne les API C, qui sont souvent plus faciles à gérer dans Objective-C que dans Swift. Pourtant, c'est rare, et il est beaucoup plus probable qu'il soit nécessaire dans un framework de niveau inférieur tel que RSParser - cela ne devrait pas arriver au niveau de l'application.

Le code Swift doit être du "pur" Swift autant que possible: évitez `@ objc` sauf si nécessaire pour travailler avec AppKit et d'autres API.

Les fonctions devraient avoir tendance à être petites. Les doublures sont correctes, surtout lorsque le nom de la fonction explique l'intention plus clairement que cette ligne.

Nous évitons surtout les génériques Swift, puisque les génériques sont une fonctionnalité avancée qui peut être relativement difficile à comprendre. Nous * les * utilisons cependant, le cas échéant.

Nous utilisons des assertions et des conditions préalables (les assertions ne sont frappées que lors de l'exécution d'une construction de débogage, les conditions préalables font planter une version release). Nous autorisons également le déballage forcé des options en tant que raccourci pour une défaillance conditionnelle, bien que celles-ci doivent être utilisées avec parcimonie.

Des extensions, y compris des extensions privées, sont utilisées - bien que nous prenions soin de ne pas trop étendre les objets Foundation et AppKit, de peur que nous ne finissions avec notre propre dialecte Cocoa.

Les choses devraient être marquées privées aussi souvent que possible. Les API devraient être exactement ce qui est nécessaire et pas plus.

Lorsque `@ importing`, importer` AppKit` plutôt que `Cocoa`. Si vous voyez un cas où il s'agit de `Cocoa`, remplacez-le par` AppKit`.

#### Organisation du code

Les propriétés vont en haut, puis les fonctions.

Puis extensions pour les conformances de protocole. Puis une extension privée pour toutes les fonctions privées.

Utilisez `// MARK:` selon le cas.

### Composition

#### Pas de sous-classes

Le sous-classement est inévitable - il n'y a aucun moyen de sortir des sous-classes comme NSView et NSViewController, car c'est ainsi que fonctionne AppKit.

Mais dans tout le reste, les frameworks inclus, vous auriez du mal à trouver une classe qui a été conçue pour être sous-classée. Il est assez rare qu'il faille chercher assez loin pour trouver un exemple, s'il y en a un.

Considérez ceci comme une règle stricte: toutes les classes Swift doivent être marquées comme «final», et toutes les classes Objective-C doivent être traitées comme si elles étaient ainsi marquées.

#### Protocoles et délégués

Les protocoles et les délégués (qui sont également conformes au protocole) sont préférés.

Les implémentations par défaut dans les protocoles sont autorisées mais elles sont rarement découragées. Vous trouverez plusieurs instances dans le code, mais cela est fait avec soin - nous ne voulons pas que ce soit juste une autre forme d'héritage, où vous trouvez que vous devez rebondir entre les fichiers pour comprendre ce qui se passe sur.

Il y a un cas regrettable à propos des protocoles à noter: dans Swift, vous ne pouvez pas créer un ensemble d'objets conformes au protocole, et nous utilisons fréquemment des ensembles. Dans ces situations, une autre solution - comme un objet fin avec un délégué - pourrait être meilleure.


#### Petits objets

Les objets géants avec des milliers de lignes de code doivent être évités. Préférez plusieurs petits objets. Il est plus facile de se concentrer sur un petit problème, et les petits objets sont plus faciles à entretenir et à composer avec d'autres objets.

Cela dit, ne cassez pas arbitrairement un objet plus grand juste parce qu'il est grand. C'est peut-être la réponse honnête (et peut-être pas). Il devrait y avoir une logique et une raison aux objets plus petits.

#### Répétition de code

Cette politique de non-sous-classes peut conduire à une répétition de code, ou presque-répétition. À petite dose, c'est bien, et c'est mieux que les alternatives - qui ont tendance à se complexifier.

Mais à des doses plus importantes, une refonte est nécessaire. Souvent, le fait de diviser le problème en objets plus petits (voir ci-dessus) peut résoudre le problème de répétition.

### Objets de modèle

Les objets modèles sont des objets anciens. Nous n'utilisons pas les données de base ou tout autre système nécessitant une sous-classification.

Les structures Swift immuables sont fortement préférées. Ils valent un peu de se tenir debout sur la tête pour les obtenir - mais seulement un peu. Sinon, utilisez un objet mutable struct ou reference-type, selon les besoins.

### Cadres

#### Intégré

Ne combattez pas les frameworks intégrés et n'essayez pas de les cacher. N'écrivons pas notre propre dialecte Cocoa.

#### Les notres

Evergreen est en couches dans des cadres. Il y a un niveau d'application et un tas de frameworks en dessous. Chaque cadre a sa propre raison d'être. Les dépendances entre les frameworks doivent être aussi minimes que possible, mais ces dépendances existent.

Certains frameworks ne sont pas autorisés à ajouter des dépendances et doivent être traités comme en bas du gâteau: RSCore, RSWeb, RSDatabase, RSParser, RSTree et DB5. Cela simplifie les choses pour nous, et il est plus facile pour nous et d'autres personnes d'utiliser ces cadres dans d'autres applications.


### Interface utilisateur

S'en tenir à des éléments de stock, car cela tend à éliminer les insectes et la future baratte. Ce n'est pas toujours possible, bien sûr, mais tout travail personnalisé devrait être le minimum possible. Nous sommes là pour le long terme.

Les storyboards sont préférés aux xibs - sauf lorsque le problème est de taille xib.

Utilisez DB5 où les paramètres (tailles, couleurs, etc.) sont nécessaires.

La mise en page automatique est utilisée partout sauf dans les cellules de vue de tableau et de contour, où la performance est critique.

Les vues de pile ne sont pas autorisées dans les cellules de vue de tableau et de contour, mais elles peuvent être utiles ailleurs. Cependant, il faut veiller à ce que les performances (du redimensionnement des fenêtres, par exemple) ne soient pas affectées. Quand c'est le cas, n'utilisez pas une vue de pile.

Utilisez des actions nulles et ciblées et la chaîne de réponse le cas échéant.

Utilisez les liaisons Cocoa extrêmement rarement - pour une case à cocher dans une fenêtre de préférences, par exemple.

### Notifications et liaisons

L'observation de la valeur-clé (KVO) est entièrement interdite. Le KVO est l'endroit où vivent les bogues qui se brisent. (La seule exception possible est quand une API Apple nécessite KVO, ce qui est rare.)

`NSArrayController` et similaires ne sont jamais utilisés. La liaison via le code n'est pas non plus effectuée.

Au lieu de cela, nous utilisons les notifications de NotificationCenter, et nous utilisons la méthode `didSet` de Swift sur les accesseurs.

Toutes les notifications doivent être affichées dans la file d'attente principale.

### Enfilage

Tout se passe sur le fil principal. Période.

Eh bien, non, pas exactement. * Presque * tout se passe sur le fil principal.

Les exceptions sont des choses qui peuvent être parfaitement isolées, telles que l'analyse d'un flux RSS ou l'extraction à partir de la base de données. Nous utilisons `DispatchQueue` pour les exécuter en arrière-plan, souvent dans une file d'attente série.

Ces choses doivent fonctionner sans verrous - les verrous sont presque complètement inutilisés dans Evergreen.

Chaque fois qu'une tâche d'arrière-plan avec un rappel est terminée, elle doit rappeler dans la file d'attente principale (sauf pour les cas complètement privés, et il doit ensuite être noté dans le code).

Si cette politique conduit à un design qui bloque le thread principal de façon inacceptable, alors ce design doit être repensé. Demander de l'aide si nécessaire.

### Propreté

Aucun code qui déclenche des erreurs de compilation ou même des avertissements peut être archivé.

Aucun code qui écrit dans la console ne peut être enregistré - console spew n'est pas autorisé.

### Profilage

Utilisez des instruments pour rechercher des fuites et effectuer le profilage. Les instruments sont excellents pour trouver où les problèmes sont réellement, par opposition à où vous pensez qu'ils sont.

Aucune version d'expédition n'est libérée sans rechercher des fuites de mémoire.

### Test

Écrire des tests unitaires, en particulier dans les frameworks de bas niveau, et en particulier lors de la correction d'un bug.

Il n'y a jamais assez de couverture de test. Il devrait toujours y avoir plus de tests.

### Contrôle de version

Chaque message de validation doit commencer par un verbe au présent.

### Dernière chose

Ne pas montrer. Si votre code ressemble au code de la maternelle, alors _good_.

Des points sont accordés pour ne pas essayer d'accumuler des points.
