FROM nginx:latest

# Supprime la configuration par défaut de Nginx
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copie votre propre fichier de configuration (ex: default.conf ou nginx.conf)
COPY nginx.conf /etc/nginx/conf.d/

EXPOSE 80
CMD ["ngnix", "-g", "daemon off"]