
set -euo pipefail

BUCKET_NAME="${1:-}"
REGION="${2:-eu-west-3}"
DYNAMO_TABLE="terraform-state-lock"
PROFILE="terraform-project"

#  Validation 
if [[ -z "$BUCKET_NAME" ]]; then
  echo "Usage : $0 <nom-unique-bucket> [region]"
  echo "Exemple : $0 jean-terraform-state eu-west-3"
  exit 1
fi

echo "======================================================"
echo " Bootstrap Remote State Terraform"
echo "======================================================"
echo " Bucket S3     : $BUCKET_NAME"
echo " Région        : $REGION"
echo " Table DynamoDB: $DYNAMO_TABLE"
echo " Profil AWS    : $PROFILE"
echo "======================================================"
read -rp "Continuer ? (oui/non) : " CONFIRM
[[ "$CONFIRM" != "oui" ]] && echo "Annulé." && exit 0

#  Créer le bucket S3 
echo ""
echo "[1/4] Création du bucket S3"
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  --profile "$PROFILE"
echo "       Bucket crée : $BUCKET_NAME"

#  Activer le versioning 
echo "[2/4] Activation du versioning S3"
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  --profile "$PROFILE"
echo "       Versioning active"

#  Bloquer l'accès public 
echo "[3/4] Blocage de l'accès public S3"
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --profile "$PROFILE"
echo "       Accès public bloqué"

#  Créer la table DynamoDB 
echo "[4/4] Création de la table DynamoDB"
aws dynamodb create-table \
  --table-name "$DYNAMO_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  --profile "$PROFILE"
echo "       Table DynamoDB créée : $DYNAMO_TABLE"

echo ""
echo "  Bootstrap terminé avec succès !"
echo ""
echo " Prochaine étape — mettre à jour les backends.tf :"
echo "   Remplacer TON_BUCKET_NAME par : $BUCKET_NAME"
echo ""
echo " Fichiers a modifier :"
echo "   environments/dev/backend.tf"
echo "   environments/staging/backend.tf"
echo "   environments/prod/backend.tf"
echo ""
