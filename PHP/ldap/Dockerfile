FROM osixia/openldap:1.5.0

# Crée le dossier cible pour les fichiers LDIF
RUN mkdir -p /container/run/service/slapd/assets/config/bootstrap/ldif/custom
# Copie le fichier LDIF dans le container
#COPY ldap/ldif/*.ldif /container/service/slapd/assets/

# Exécute la commande d'importation au démarrage (pas dans le build, voir RUN vs CMD)
CMD ["/container/tool/run", "--copy-service", "--loglevel=debug"]