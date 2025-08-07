# Mes devcontainers

Mon environnement de travail, quasiment prêt à l'emploi.
Celui-ci contient des sous-module *git* privés.
Ne l'utilisez pas tel quel, mais forkez-le librement et adaptez-le à vos besoins.

## Points à adapter

### Sous-modules

- Un fichier **.gitmodule** à la racine de ce répo est présent. Remplacez les chemins et noms des sous-modules selon votre arborescence.

### Utilisateur

- Les fichiers **Dockerfile** de chaque sous-projet, rangés respectivement dans *<mon_sous_projet>/.devcontainer*, utilisent un utilisateur nommé *loic*. Il va de soi qu'il vous appartient de modifier ce nom d'utilisateur selon votre préférence, **uniquement en remplaçant la valeur de la variable $USERNAME**. 

### Dépendances

- J'ai souvent tendance à ajouter plus de bibliothèques que nécessaire. Si vous souhaitez que vos conteneurs se construisent rapidement, vérifiez les applications installées dans chaque **Dockerfile**

- Vérifiez le contenu des fichiers *post-create.sh*. Lorsque mon conteneur est construit, j'apprécie que les commandes d'initialisation aient déjà été exécutées (`npm install`, `composer install`, etc...).

## Mes commandes utiles

**Ajout d'un sous-module:** 

`git submodule add http://github.com/loicdurand/<mon_repo>.git PHP/mon_repo`

**Init d'un sous-module:** 
```bash
cd PHP/mon_repo
git submodule init
git submodule update 
```