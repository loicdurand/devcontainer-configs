#!/bin/sh

# Vérifier si mysqladmin est installé
if ! command -v mysqladmin > /dev/null; then
  echo "Erreur : mysqladmin n'est pas installé. Assurez-vous que mysql-client est inclus dans l'image."
  exit 1
fi

# Vérifier que les variables nécessaires sont définies
if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$LLDAP_DATABASE_URL" ]; then
  echo "Erreur : Variables d'environnement MYSQL_USER, MYSQL_PASSWORD ou LLDAP_DATABASE_URL manquantes."
  exit 1
fi

# Attendre que MySQL soit prêt avec un timeout (60 secondes)
echo "Attente de la disponibilité de MySQL..."
timeout=60
elapsed=0
while ! mysqladmin ping -h mysql -P 3306 -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  if [ $elapsed -ge $timeout ]; then
    echo "Erreur : Timeout atteint ($timeout secondes). MySQL n'est pas disponible."
    exit 1
  fi
  echo "MySQL n'est pas encore prêt, nouvelle tentative dans 2 secondes..."
  sleep 2
  elapsed=$((elapsed + 2))
done
echo "MySQL est prêt !"

# Exécuter create_schema
echo "Initialisation du schéma LLDAP dans MySQL..."
/app/lldap create_schema -d "$LLDAP_DATABASE_URL"

# Vérifier le code de retour
if [ $? -eq 0 ]; then
  echo "Schéma créé avec succès."
else
  echo "Avertissement : Erreur lors de la création du schéma (peut déjà exister). Continuons..."
fi

# Lancer le serveur LLDAP
echo "Démarrage du serveur LLDAP..."
exec /app/lldap run
