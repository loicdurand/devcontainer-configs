FROM bitnami/openldap:2

# Copie le fichier LDIF dans le container
COPY ldap/ldif/*.ldif /container/service/slapd/assets/

# Exécute la commande d'importation au démarrage (pas dans le build, voir RUN vs CMD)
CMD ["/container/tool/run", "--copy-service", "--loglevel=debug"]