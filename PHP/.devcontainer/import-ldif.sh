#!/bin/bash

source .env

# Débogage : Afficher les variables d'environnement LLDAP
echo "LLDAP_LDAP_BASE_DN=$LLDAP_LDAP_BASE_DN"
echo "LLDAP_LDAP_USER_DN=$LLDAP_LDAP_USER_DN"
echo "LLDAP_LDAP_USER_PASS=$LLDAP_LDAP_USER_PASS"

LDIF_FILE=$1
LDAP_HOST="lldap"
LDAP_PORT=3890
LDAP_BIND_DN="uid=${LLDAP_LDAP_USER_DN},ou=people,${LLDAP_LDAP_BASE_DN}"
LDAP_BIND_PW="${LLDAP_LDAP_USER_PASS}"

if [ -z "$LDIF_FILE" ]; then
  echo "Erreur : Fournis un fichier LDIF en argument."
  exit 1
fi

if [ -z "$LLDAP_LDAP_USER_DN" ] || [ -z "$LLDAP_LDAP_USER_PASS" ] || [ -z "$LLDAP_LDAP_BASE_DN" ]; then
  echo "Erreur : Variables d'environnement LLDAP manquantes."
  echo "LLDAP_LDAP_USER_DN=$LLDAP_LDAP_USER_DN"
  echo "LLDAP_LDAP_USER_PASS=$LLDAP_LDAP_USER_PASS"
  echo "LLDAP_LDAP_BASE_DN=$LLDAP_LDAP_BASE_DN"
  echo "Vérifie le fichier .env ou la configuration du conteneur."
  exit 1
fi

ldapadd -x -H ldap://$LDAP_HOST:$LDAP_PORT -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$LDIF_FILE"

echo "LDIF importé avec succès !"