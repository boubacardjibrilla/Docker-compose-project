# 🚀 Multi-Container Microservices Architecture with Nginx Reverse Proxy & Docker Compose on AWS EC2

Ce projet met en œuvre une architecture **microservices multi-conteneurs** basée sur **Python/Flask**, **Docker**, **Docker Compose** et **Nginx Reverse Proxy**, déployée sur une instance **AWS EC2 Amazon Linux 2023**.

L'objectif est de mettre en pratique :

* La conteneurisation d'applications Python
* La communication entre conteneurs Docker
* L'orchestration avec Docker Compose
* Le reverse proxy avec Nginx
* La séparation des services
* Le déploiement d'une architecture multi-conteneurs sur AWS EC2

---

# 📐 Architecture du système

L'architecture repose sur un point d'entrée unique : **Nginx**.

Les utilisateurs accèdent à l'application via :

```text
http://<EC2-PUBLIC-IP>/
```

Nginx écoute sur le port **80** et route les requêtes vers les différents services Flask en fonction du chemin demandé.

```text
                         Internet
                            │
                            │ HTTP :80
                            ▼
                  ┌───────────────────┐
                  │     AWS EC2       │
                  │  Amazon Linux 2023│
                  │                   │
                  │   Docker Host     │
                  └─────────┬─────────┘
                            │
                            ▼
                  ┌───────────────────┐
                  │       Nginx       │
                  │  Reverse Proxy    │
                  │      :80          │
                  └─────────┬─────────┘
                            │
            ┌───────────────┼────────────────┐
            │               │                │
            ▼               ▼                ▼
     /api/backend1   /api/backend2   /api/backend3
            │               │                │
            ▼               ▼                ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │  Backend 1 │  │  Backend 2 │  │  Backend 3 │
     │ Python     │  │ Python     │  │ Python     │
     │ Flask      │  │ Flask      │  │ Flask      │
     │ :5000      │  │ :5001      │  │ :5002      │
     └────────────┘  └────────────┘  └────────────┘
            │               │                │
            └───────────────┴────────────────┘
                         Docker Network
```

---

# 🔄 Fonctionnement

Lorsqu'un utilisateur envoie une requête HTTP, Nginx analyse l'URL et la transmet au service correspondant.

### Backend 1

```text
GET /api/backend1/
        │
        ▼
     Nginx
        │
        ▼
backend1:5000
```

### Backend 2

```text
GET /api/backend2/
        │
        ▼
     Nginx
        │
        ▼
backend2:5001
```

### Backend 3

```text
GET /api/backend3/
        │
        ▼
     Nginx
        │
        ▼
backend3:5002
```

Les trois applications Flask sont isolées dans leurs propres conteneurs.

---

# 🛠️ Stack technique

| Catégorie        | Technologie       | Rôle                         |
| ---------------- | ----------------- | ---------------------------- |
| Cloud            | AWS EC2           | Infrastructure d'exécution   |
| OS               | Amazon Linux 2023 | Système hôte                 |
| Containerization | Docker            | Conteneurisation             |
| Orchestration    | Docker Compose    | Gestion des conteneurs       |
| Reverse Proxy    | Nginx             | Routage HTTP                 |
| Backend          | Python            | Langage applicatif           |
| Framework        | Flask             | API / services backend       |
| Networking       | Docker Network    | Communication entre services |
| SCM              | Git / GitHub      | Gestion du code              |

---

# 📁 Structure du projet

```text
Docker-compose-project/
│
├── architecture.png
│
├── Dockerfile
│
├── docker-compose.yml
│
├── nginx.conf
│
├── App-running.png
│
└── docker-compose-build.png
```

---

# 🐳 Architecture Docker Compose

Docker Compose permet de définir et gérer les différents services de l'application à partir d'un seul fichier :

```text
docker-compose.yml
```

L'environnement contient :

```text
Docker Compose
│
├── nginx
│
├── backend1
│
├── backend2
│
└── backend3
```

Les conteneurs communiquent entre eux grâce au **réseau Docker Compose**.

Nginx peut ainsi utiliser les noms des services comme noms DNS :

```text
backend1:5000
backend2:5001
backend3:5002
```

---

# 🌐 Configuration Nginx

Exemple de configuration du reverse proxy :

```nginx
http {

    upstream backend1 {
        server backend1:5000;
    }

    upstream backend2 {
        server backend2:5001;
    }

    upstream backend3 {
        server backend3:5002;
    }

    server {

        listen 80;

        location /api/backend1/ {
            proxy_pass http://backend1;
        }

        location /api/backend2/ {
            proxy_pass http://backend2;
        }

        location /api/backend3/ {
            proxy_pass http://backend3;
        }
    }
}
```

### Rôle de Nginx

Nginx fournit un **point d'entrée unique** à l'application.

Les utilisateurs n'ont donc pas besoin d'accéder directement aux ports :

```text
5000
5001
5002
```

Seul le port HTTP :

```text
80
```

est exposé publiquement.

---

# 🔐 Communication réseau

L'architecture sépare les responsabilités entre l'accès public et les communications internes.

```text
Internet
   │
   │ Port 80
   ▼
 Nginx
   │
   │ Docker Network
   ├──────────► backend1:5000
   ├──────────► backend2:5001
   └──────────► backend3:5002
```

Les ports des applications Flask peuvent rester accessibles uniquement à l'intérieur du réseau Docker.

Cela permet de réduire la surface d'exposition de l'application.

---

# ☁️ Infrastructure AWS

Le projet est déployé sur une instance :

```text
AWS EC2
│
├── Amazon Linux 2023
│
├── Docker
│
├── Docker Compose
│
├── Nginx Container
│
├── Backend 1 Container
├── Backend 2 Container
└── Backend 3 Container
```

Le **Security Group AWS** doit autoriser :

```text
Inbound
│
└── TCP :80
```

Pour l'administration distante, SSH peut également être autorisé depuis une adresse IP d'administration.

---

# 🚀 Déploiement

## 1. Prérequis

Vous devez disposer de :

* Un compte AWS
* Une instance EC2
* Amazon Linux 2023
* Docker
* Docker Compose
* Git
* Un Security Group autorisant HTTP sur le port 80

---

# 2. Installer Docker

Vérifier Docker :

```bash
docker --version
```

Vérifier Docker Compose :

```bash
docker compose version
```

---

# 3. Cloner le projet

```bash
git clone https://github.com/<USERNAME>/Docker-compose-project.git
```

Puis :

```bash
cd Docker-compose-project
```

---

# 4. Construire et démarrer les conteneurs

```bash
docker compose up -d --build
```

Cette commande :

1. Construit les images Docker
2. Crée le réseau Docker
3. Crée les conteneurs
4. Démarre les services en arrière-plan

---

# 5. Vérifier les conteneurs

```bash
docker compose ps
```

Exemple :

```text
NAME        STATUS       PORTS
nginx       Up           0.0.0.0:80->80/tcp
backend1    Up
backend2    Up
backend3    Up
```

---

# 6. Vérifier les logs

Pour Nginx :

```bash
docker compose logs nginx
```

Pour Backend 1 :

```bash
docker compose logs backend1
```

Pour tous les services :

```bash
docker compose logs
```

---

# 7. Tester l'application

Depuis un navigateur :

```text
http://<EC2-PUBLIC-IP>/api/backend1/
```

Puis :

```text
http://<EC2-PUBLIC-IP>/api/backend2/
```

Et :

```text
http://<EC2-PUBLIC-IP>/api/backend3/
```

Les requêtes sont automatiquement routées par Nginx vers les conteneurs correspondants.

---

# 🧪 Tests de fonctionnement

Vous pouvez également tester avec `curl` :

```bash
curl http://<EC2-PUBLIC-IP>/api/backend1/
```

```bash
curl http://<EC2-PUBLIC-IP>/api/backend2/
```

```bash
curl http://<EC2-PUBLIC-IP>/api/backend3/
```

Vérifier également le réseau Docker :

```bash
docker network ls
```

Puis :

```bash
docker network inspect <NETWORK_NAME>
```

---

# 🛑 Arrêter l'application

```bash
docker compose down
```

Pour reconstruire complètement les services :

```bash
docker compose down
docker compose up -d --build
```

---

# 📸 Preuves du projet

## 1. Architecture

Le schéma présente l'architecture globale de l'application.

```text
architecture.png
```

---

## 2. Construction Docker Compose

Cette capture montre la construction et le démarrage des différents services.

```text
docker-compose-build.png
```

---

## 3. Application en fonctionnement

Cette capture montre l'application accessible via Nginx.

```text
App-running.png
```

---

# 🎯 Concepts DevOps démontrés

Ce projet permet de mettre en pratique plusieurs concepts importants :

### Docker

* Images
* Containers
* Dockerfile
* Docker Network
* Container isolation
* Port mapping

### Docker Compose

* Multi-container applications
* Service orchestration
* Environment configuration
* Service dependencies
* Network management

### Nginx

* Reverse Proxy
* HTTP routing
* Upstream services
* Single entry point

### AWS

* EC2
* Security Groups
* Linux administration
* Cloud deployment

### Microservices

Chaque backend constitue un service indépendant :

```text
backend1
backend2
backend3
```

Chaque service peut potentiellement être développé, construit et déployé indépendamment.

---

# 📊 Architecture actuelle vs architecture évolutive

Cette architecture constitue une bonne base pour évoluer vers une plateforme de conteneurs plus avancée.

### Architecture actuelle

```text
AWS EC2
   │
Docker Compose
   │
   ├── Nginx
   ├── Backend 1
   ├── Backend 2
   └── Backend 3
```

### Évolution possible

```text
                    AWS
                     │
              Load Balancer
                     │
                     ▼
                Kubernetes
                     │
          ┌──────────┼──────────┐
          │          │          │
       Service    Service    Service
          │          │          │
       Backend1   Backend2   Backend3
```

Une évolution naturelle de ce projet serait donc de migrer l'architecture **Docker Compose → Kubernetes**, puis d'ajouter éventuellement :

* Amazon EKS
* Helm
* Argo CD
* Prometheus
* Grafana
* CI/CD Jenkins ou GitHub Actions

---

# 👨‍💻 Author

**Boubacar Djibrilla**

Software Engineering | AWS | DevOps | Cloud

GitHub: `boubacardjibrilla`
