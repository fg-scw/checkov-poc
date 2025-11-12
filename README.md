# CHECKOV — README

## Objectif
Mettre en place un **contrôle statique** de l’infra Terraform avec **Checkov**, plus un **mini-lab** (`checkov-lab/`) pour expérimenter :
- des **règles custom** dédiées à Scaleway (CKV_SCW_*),
- des **scans** locaux/CI,
- la **baseline** (accepter l’existant),
- des **exemples “bad configs”** qui déclenchent volontairement des erreurs.

---

## Prérequis
- Python 3 + `pip`
- Checkov (version récente recommandée) :
  ```bash
  pip install -U checkov
  ```
- (optionnel) pre-commit :
  ```bash
  pip install pre-commit
  ```

---

## Arborescence (extrait)
```
.
├── custom_checks/                # Règles Checkov personnalisées (YAML)
│   ├── CKV_SCW_1_no_public_ssh.yaml
│   ├── CKV_SCW_2_bucket_acl_not_public.yaml
│   ├── CKV_SCW_3_bucket_versioning_enabled.yaml
│   ├── CKV_SCW_4_rdb_encryption_at_rest.yaml
│   ├── CKV_SCW_5_rdb_backups_enabled.yaml
│   ├── CKV_SCW_6_rdb_private_network.yaml
│   ├── CKV_SCW_7_lb_https_requires_cert.yaml
│   ├── CKV_SCW_8_lb_cookie_name_when_cookie.yaml
│   ├── CKV_SCW_9_k8s_delete_additional_resources.yaml
│   └── CKV_SCW_10_sg_defaults_secure.yaml
├── Makefile                      # Cibles pratiques (scan, baseline, etc.)
├── .pre-commit-config.yaml       # Hook local (optionnel)
├── .github/workflows/checkov.yml # CI GitHub (optionnel)
└── checkov-lab/                  # Mini-lab pour tester
    ├── main.tf                   # Exemple “clean” modifiable
    └── tests/
        └── bad/                  # Exemples “volontairement mauvais”
            ├── sg_bad.tf        # SG : SSH 0.0.0.0/0, policies laxistes
            ├── storage_bad.tf   # Buckets : pas de versioning + ACL publique
            ├── lb_bad.tf        # LB : 443 sans cert, sticky cookie sans nom
            ├── rdb_bad.tf       # RDB : pas de backup/chiffrement/PN
            └── k8s_bad.tf       # K8s : delete_additional_resources=false
```

---

## Lancer un scan local (racine)
Avec les règles custom + variables évaluées :
```bash
make scan
```

Version compacte :
```bash
make scan-compact
```

Exports :
```bash
make scan-json    # results.json
make scan-sarif   # results.sarif
```

> Les cibles `make` utilisent `custom_checks/` automatiquement.

---

## Baseline (accepter l’existant)
Créer/mettre à jour une baseline :
```bash
make baseline
```

Ré-exécuter un scan en tenant compte de la baseline :
```bash
checkov -d . --baseline .checkov.baseline
```
La baseline masque les findings *déjà connus*, et remonte **uniquement les nouveaux** écarts.

---

## Mini-lab : déclencher volontairement des erreurs
Scanner les “bad configs” pour voir Checkov en action :
```bash
make scan-bad
```

```bash
checkov-lab git:(main) ✗ make scan-bad
checkov -d tests/bad --framework terraform \
                --external-checks-dir custom_checks \
                --evaluate-variables true --var-file=terraform.tfvars
[ terraform framework ]: 100%|████████████████████|[5/5], Current File Scanned=tests/bad/storage_bad.tf


       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By Prisma Cloud | version: 3.2.490 

terraform scan results:

Passed checks: 1, Failed checks: 9, Skipped checks: 0

Check: CKV_SCW_1: "Interdire SSH public (0.0.0.0/0) dans scaleway_instance_security_group"
        PASSED for resource: scaleway_instance_security_group.bad_sg
        File: /sg_bad.tf:1-14
Check: CKV_SCW_3: "Activer le versioning sur les buckets"
        FAILED for resource: scaleway_object_bucket.public_assets
        File: /storage_bad.tf:1-4

                1 | resource "scaleway_object_bucket" "public_assets" {
                2 |   name   = "demo-public-assets-ckv-bad"
                3 |   region = "fr-par"
                4 | }

Check: CKV_SCW_7: "LB frontend 443: certificat requis (certificate_ids non vide)"
        FAILED for resource: scaleway_lb_frontend.https
        File: /lb_bad.tf:15-20

                15 | resource "scaleway_lb_frontend" "https" {
                16 |   lb_id        = scaleway_lb.web.id
                17 |   name         = "https"
                18 |   inbound_port = 443
                19 |   backend_id   = scaleway_lb_backend.web_be.id
                20 | }

Check: CKV_SCW_6: "RDB: doit être rattaché à un Private Network"
        FAILED for resource: scaleway_rdb_instance.pg
        File: /rdb_bad.tf:1-11

                1  | resource "scaleway_rdb_instance" "pg" {
                2  |   name                = "bad-pg"
                3  |   engine              = "PostgreSQL-15"
                4  |   node_type           = "DB-DEV-S"
                5  |   is_ha_cluster       = false
                6  |   user_name           = "app"
                7  |   password            = "Ch@ngeMe-123"
                8  | 
                9  |   encryption_at_rest  = false
                10 |   disable_backup      = true
                11 | }

Check: CKV_SCW_4: "RDB: chiffrement au repos obligatoire"
        FAILED for resource: scaleway_rdb_instance.pg
        File: /rdb_bad.tf:1-11

                1  | resource "scaleway_rdb_instance" "pg" {
                2  |   name                = "bad-pg"
                3  |   engine              = "PostgreSQL-15"
                4  |   node_type           = "DB-DEV-S"
                5  |   is_ha_cluster       = false
                6  |   user_name           = "app"
                7  |   password            = "Ch@ngeMe-123"
                8  | 
                9  |   encryption_at_rest  = false
                10 |   disable_backup      = true
                11 | }

Check: CKV_SCW_5: "RDB: backups activés (disable_backup=false)"
        FAILED for resource: scaleway_rdb_instance.pg
        File: /rdb_bad.tf:1-11

                1  | resource "scaleway_rdb_instance" "pg" {
                2  |   name                = "bad-pg"
                3  |   engine              = "PostgreSQL-15"
                4  |   node_type           = "DB-DEV-S"
                5  |   is_ha_cluster       = false
                6  |   user_name           = "app"
                7  |   password            = "Ch@ngeMe-123"
                8  | 
                9  |   encryption_at_rest  = false
                10 |   disable_backup      = true
                11 | }

Check: CKV_SCW_2: "Interdire les ACL publiques sur les buckets (public-read/public-read-write)"
        FAILED for resource: scaleway_object_bucket_acl.public_assets_acl
        File: /storage_bad.tf:6-10

                6  | resource "scaleway_object_bucket_acl" "public_assets_acl" {
                7  |   bucket = scaleway_object_bucket.public_assets.name
                8  |   region = "fr-par"
                9  |   acl    = "public-read"
                10 | }

Check: CKV_SCW_10: "SG: inbound_default_policy=drop et stateful=true"
        FAILED for resource: scaleway_instance_security_group.bad_sg
        File: /sg_bad.tf:1-14

                1  | resource "scaleway_instance_security_group" "bad_sg" {
                2  |   name                    = "bad-sg"
                3  |   zone                    = "fr-par-1"
                4  |   inbound_default_policy  = "accept"
                5  |   outbound_default_policy = "accept"
                6  |   stateful                = false
                7  | 
                8  |   inbound_rule {
                9  |     action   = "accept"
                10 |     protocol = "TCP"
                11 |     port     = 22
                12 |     ip_range = "0.0.0.0/0"
                13 |   }
                14 | }

Check: CKV_SCW_8: "LB backend: sticky_sessions=cookie → sticky_sessions_cookie_name requis"
        FAILED for resource: scaleway_lb_backend.web_be
        File: /lb_bad.tf:7-13

                7  | resource "scaleway_lb_backend" "web_be" {
                8  |   lb_id            = scaleway_lb.web.id
                9  |   name             = "web-be"
                10 |   forward_protocol = "http"
                11 |   forward_port     = 80
                12 |   sticky_sessions  = "cookie"
                13 | }

Check: CKV_SCW_9: "K8s: delete_additional_resources activé (nettoyage automatique des ressources associées)"
        FAILED for resource: scaleway_k8s_cluster.bad
        File: /k8s_bad.tf:1-6

                1 | resource "scaleway_k8s_cluster" "bad" {
                2 |   name                        = "k8s-bad"
                3 |   version                     = "1.32.3"
                4 |   cni                         = "calico"
                5 |   delete_additional_resources = false
                6 | }


make: *** [scan-bad] Error 1
```


Ce dossier contient des exemples qui **échouent** explicitement nos règles :
- **CKV_SCW_1** : SSH ouvert au monde (0.0.0.0/0) dans un SG.
- **CKV_SCW_2** : ACL de bucket publique.
- **CKV_SCW_3** : versioning de bucket désactivé.
- **CKV_SCW_4** : RDB sans chiffrement au repos.
- **CKV_SCW_5** : RDB avec backups désactivés.
- **CKV_SCW_6** : RDB non attaché à un Private Network.
- **CKV_SCW_7** : LB sur 443 sans certificat.
- **CKV_SCW_8** : LB sticky cookie sans `sticky_sessions_cookie_name`.
- **CKV_SCW_9** : K8s sans `delete_additional_resources`.
- **CKV_SCW_10** : SG avec politiques inbound laxistes et `stateful=false`.

> Idéal pour **démontrer l’utilité** de Checkov (ce que le scan détecte, comment le corriger, etc.).

---

## CI GitHub (optionnel)
Un workflow minimal est fourni : `.github/workflows/checkov.yml`  
- Scanne le repo, produit un **SARIF**, et l’upload dans “Code scanning alerts”.
- Ajoute `external-checks-dir: custom_checks` pour nos règles YAML.

---

## Pre-commit (optionnel)
Active le hook local pour prévenir les régressions **avant** le commit :
```bash
make precommit-install
pre-commit run --all-files
```

---

## Bonnes pratiques
- **Ne versionne pas** `.terraform/`, les **tfstate**, ni `terraform.tfvars` → `.gitignore` fourni.
- Utilise `--soft-fail` si tu ne veux pas casser la CI dès le départ.
- Aligne les règles custom avec tes **politiques internes** (prod vs. dev).

---

## Dépannage rapide
- `not_in non supporté` : certaines versions de Checkov n’acceptent pas l’opérateur YAML `not_in` → utiliser des `not_equals` en série.
- `--evaluate-variables` : selon la version, passe `true/false` explicitement.
- Conflits d’ID : une seule définition par ID (ex : **CKV_SCW_1** ne doit exister qu’une fois).

---

## But du lab
- Montrer *rapidement* ce que Checkov apporte sur de l’infra Terraform : **découverte**, **prévention**, **gardiens** de conformité.
- Offrir un terrain de jeu pour **écrire/itérer des règles** adaptées à **Scaleway**.
- Illustrer la **baseline** et l’intégration **CI/PR** (fail/pass contrôlé).
