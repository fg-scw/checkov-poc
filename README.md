# checkov-poc
CHECKOV — README
Objectif
Mettre en place un contrôle statique de l’infra Terraform avec Checkov, plus un mini-lab (checkov-lab/) pour expérimenter :


des règles custom dédiées à Scaleway (CKV_SCW_*),


des scans locaux/CI,


la baseline (accepter l’existant),


des exemples “bad configs” qui déclenchent volontairement des erreurs.



Prérequis


Python 3 + pip


Checkov (version récente recommandée) :
pip install -U checkov



(optionnel) pre-commit :
pip install pre-commit




Arborescence (extrait)
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
    ├── main.tf                   # Exemple “clean” ou modifiable
    └── tests/
        └── bad/                  # Exemples “volontairement mauvais”
            ├── sg_bad.tf        # SG : SSH 0.0.0.0/0, policies laxistes
            ├── storage_bad.tf   # Buckets : pas de versioning + ACL publique
            ├── lb_bad.tf        # LB : 443 sans cert, sticky cookie sans nom
            ├── rdb_bad.tf       # RDB : pas de backup/chiffrement/PN
            └── k8s_bad.tf       # K8s : delete_additional_resources=false


Lancer un scan local (racine)
Avec les règles custom + variables évaluées :
make scan

Version compacte :
make scan-compact

Exports :
make scan-json    # results.json
make scan-sarif   # results.sarif


Les cibles make utilisent custom_checks/ automatiquement.


Baseline (accepter l’existant)
Créer/mettre à jour une baseline :
make baseline

Ré-exécuter un scan en tenant compte de la baseline :
checkov -d . --baseline .checkov.baseline

La baseline masque les findings déjà connus, et remonte uniquement les nouveaux écarts.

Mini-lab : déclencher volontairement des erreurs
Scanner les “bad configs” pour voir Checkov en action :
make scan-bad

Ce dossier contient des exemples qui échouent explicitement nos règles :


CKV_SCW_1 : SSH ouvert au monde (0.0.0.0/0) dans un SG.


CKV_SCW_2 : ACL de bucket publique.


CKV_SCW_3 : versioning de bucket désactivé.


CKV_SCW_4 : RDB sans chiffrement au repos.


CKV_SCW_5 : RDB avec backups désactivés.


CKV_SCW_6 : RDB non attaché à un Private Network.


CKV_SCW_7 : LB sur 443 sans certificat.


CKV_SCW_8 : LB sticky cookie sans sticky_sessions_cookie_name.


CKV_SCW_9 : K8s sans delete_additional_resources.


CKV_SCW_10 : SG avec politiques inbound laxistes et stateful=false.



Idéal pour démontrer l’utilité de Checkov (ce que le scan détecte, comment le corriger, etc.).


CI GitHub (optionnel)
Un workflow minimal est fourni : .github/workflows/checkov.yml


Scanne le repo, produit un SARIF, et l’upload dans “Code scanning alerts”.


Ajoute external-checks-dir: custom_checks pour nos règles YAML.



Pre-commit (optionnel)
Active le hook local pour prévenir les régressions avant le commit :
make precommit-install
pre-commit run --all-files


Bonnes pratiques


Ne versionne pas .terraform/, les tfstate, ni terraform.tfvars → .gitignore fourni.


Utilise --soft-fail si tu ne veux pas casser la CI dès le départ.


Aligne les règles custom avec tes politiques internes (prod vs. dev).



Dépannage rapide


not_in non supporté : certaines versions de Checkov n’acceptent pas l’opérateur YAML not_in → utiliser des not_equals en série.


--evaluate-variables : selon la version, passe true/false explicitement.


Conflits d’ID : une seule définition par ID (ex : CKV_SCW_1 ne doit exister qu’une fois).



But du lab


Montrer rapidement ce que Checkov apporte sur de l’infra Terraform : découverte, prévention, gardiens de conformité.


Offrir un terrain de jeu pour écrire/itérer des règles adaptées à Scaleway.


Illustrer la baseline et l’intégration CI/PR (fail/pass contrôlé).


