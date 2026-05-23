# PROMETHEUS-GRAFANA

## Description

This project is designed to .... and the main features are ...

## Getting Started

### Prerequisites

List all dependencies and their version needed to run the project as :

|Role|Tool|Version|
|:--|:--|:--|
|VCS|Git SCM|[2.54 or higher](https://git-scm.com/install/)|
|IDE|VS Code|[1.118 or higher](https://code.visualstudio.com/thank-you?dv=linux64_deb)|
|Docker Host|Debian|[13.5.0 or higher](https://www.debian.org/download)|

### Hardware Requirements

We deliver here your dev and stage requirements. Feel you free to adapt it.

In our solution we host on the same Debian Host the Docker Engine, without K8s. The clients monitored are in the same subnets.

To see the details or get more info for prod environnement, read this [article](https://github.com/CPNV-ES-MON1/prometheus-grafana/wiki/Configuration-mat%C3%A9rielle-du-server)

* Docker Host

|Criteria|Decision|
|:--|:--|
|OS|Debian 13|
|vCPU|2|
|vRam|4Go|
|OS Storage - SSD|8 Go|
|Data Storage - SSD|20 Go|

Prerequisits
|Criteria|Decision|
|:--|:--|
|Docker|v29|

On AWS, we deploy the docker engine on a [t3.medium instance](https://aws.amazon.com/ec2/instance-types/t3/).

---

#### Prod

Read carefully this [article](https://massedcompute.com/faq-answers/?question=What%20are%20the%20system%20requirements%20for%20running%20Prometheus%20and%20Grafana%20in%20a%20Kubernetes%20cluster?.)


### Configuration

* Copy the .env.example for your environment

```bash
    cp .env.example dev.env
```

## Deployment

We assume that your infra (IaaS) is already managed by another projet (Terraform).

First of all, you need to deploy the docker engine.

* To format, mount the volume as well as setup the Docker engine, run this script:

```bash
    ./scripts/install_deps.sh
```

### On dev environment

* Deploy the docker compose

```
    docker compose --env-file dev.env up -d
```

### On stage environment

* Deploy the docker compose

```
    docker compose --env-file stage.env up -d
```

## Directory structure

Here you are a sample of project structure. It's must be adapted to your stack.

```shell
project-root/
├── README.md
├── .env.example              # environment variables template

├── config/                   # configuration (per environment)
│   ├── dev.env
│   ├── staging.env
│   └── prod.env

├── bin/                      # entrypoints (what you actually run)
│   ├── deploy.sh
│   ├── destroy.sh
│   └── status.sh

├── lib/                      # shared logic (like "modules")
│   ├── log.sh
│   ├── utils.sh
│   ├── checks.sh             # preflight checks
│   └── state.sh              # poor man's state management

├── services/                 # components of your stack
│   ├── network/
│   │   ├── create.sh
│   │   └── destroy.sh
│   │
│   ├── compute/
│   │   ├── create.sh
│   │   └── destroy.sh
│   │
│   ├── monitoring/
│   │   ├── prometheus.sh
│   │   ├── grafana.sh
│   │   └── alertmanager.sh
│   │
│   └── security/
│       ├── iam.sh
│       └── secrets.sh

├── state/                    # local state tracking
│   └── deployed.json

├── scripts/                  # helpers (optional)
│   ├── install_deps.sh
│   └── lint.sh

└── logs/
    └── deploy.log
```

## Collaborate

* How to propose a new feature (issue, pull request)
* [How to commit](https://www.conventionalcommits.org/en/v1.0.0/)
* [How to use your workflow](https://nvie.com/posts/a-successful-git-branching-model/)

## License

* [Choose the license adapted to your project](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository).

## Contact

* How to get in contact with you? Discord, Trello, Issue?
