#!/bin/bash

# Utilisation : ./import-ldif.sh chemin/vers/ton/fichier.ldif

LDIF_FILE=$1
LDAP_HOST="ldap"
LDAP_PORT=1389
LDAP_BIND_DN="cn=admin,dc=example,dc=org"
LDAP_BIND_PW="admin"

if [ -z "$LDIF_FILE" ]; then
  echo "Erreur : Fournis un fichier LDIF en argument."
  exit 1
fi

ldapadd -x -H ldap://$LDAP_HOST:$LDAP_PORT -D "$LDAP_BIND_DN" -w "$LDAP_BIND_PW" -f "$LDIF_FILE"

echo "LDIF importé avec succès !"