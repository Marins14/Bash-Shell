# ANOTAÇÕES GERAIS

- Para conseguir configurar dominios válidos no nextcloud, é necessário rodar o comando:
```bash
docker exec --user www-data nextcloud php occ config:system:set trusted_domains 1 --value=X.X.X.X
```
- Para validar a configuração, basta rodar o comando:
```bash
docker exec --user www-data nextcloud php occ config:system:get trusted_domains
```
- Para adicionar mais de um domínio, basta rodar o comando acima, incrementando o número do domínio, por exemplo:
```bash
docker exec --user www-data nextcloud php occ config:system:set trusted_domains 2 --value=dominio2.com
```
- Para remover um domínio, basta rodar o comando:
```bash
docker exec --user www-data nextcloud php occ config:system:delete trusted_domains 2
```

### COLOCAR ESTA CONFIG NO AVANÇADO DO PROXY 
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header Host $host;
