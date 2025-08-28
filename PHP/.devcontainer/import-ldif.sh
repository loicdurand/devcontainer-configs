#!/bin/bash
LLDAP_DATABASE_URL=mysql://admin:my_password@mysql:3306/lldap?serverVersion=8.0
      - LLDAP_LDAP_BASE_DN=dc=gendarmerie,dc=defense,dc=gouv,dc=fr
      - LLDAP_JWT_SECRET=a7d3d31065ee6c940ae196378397e16881f8c525d0e7606f768756f121372d4f
      - LLDAP_LDAP_USER_DN=admin
      - LLDAP_LDAP_USER_PASS=my_password
      - LLDAP_LOG_LEVEL=debug

LDIF_FILE=$1
LDAP_HOST="lldap"
LDAP_PORT=3890
LDAP_BIND_DN="uid=${LLDAP_LDAP_USER_DN},ou=people,${LLDAP_LDAP_BASE_DN}"
LDAP_BIND_PW="${LLDAP_LDAP_USER_PASS}"

if [ -z "$LDIF_FILE" ]; then
  echo "Erreur : Fournis un fichier LDIF en argument."
  exit 1
fi

ldapadd -x -H ldap://lldap:3890 -D "admin" -w "my_password" -f "$LDIF_FILE"

echo "LDIF importé avec succès !"