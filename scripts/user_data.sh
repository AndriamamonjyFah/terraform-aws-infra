
set -euo pipefail

#  Logging 
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Démarrage du provisioning..."

#  Mise a jour système 
apt-get update -y
apt-get upgrade -y

# Installation Nginx 
apt-get install -y nginx curl

#  Activer et demarrer Nginx 
systemctl enable nginx
systemctl start nginx

#  Page d'accueil 
HOSTNAME=$(hostname)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "N/A")
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "N/A")

cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${project_name} — ${environment}</title>
  <style>
    body { font-family: sans-serif; max-width: 700px; margin: 60px auto; padding: 0 20px; }
    h1   { color: #232f3e; }
    .env { display: inline-block; padding: 4px 12px; border-radius: 4px;
           background: #ff9900; color: white; font-weight: bold; font-size: 14px; }
    .grid{ display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 24px; }
    .box { background: #f4f4f4; border-radius: 8px; padding: 16px; }
    .lbl { font-size: 12px; color: #666; text-transform: uppercase; }
    .val { font-size: 16px; font-weight: 500; margin-top: 4px; }
    footer { margin-top: 40px; font-size: 12px; color: #999; }
  </style>
</head>
<body>
  <h1>Infrastructure Terraform AWS</h1>
  <p>Déploiement reussi — environnement <span class="env">${environment}</span></p>
  <div class="grid">
    <div class="box"><div class="lbl">Projet</div><div class="val">${project_name}</div></div>
    <div class="box"><div class="lbl">Environnement</div><div class="val">${environment}</div></div>
    <div class="box"><div class="lbl">Hostname</div><div class="val">$HOSTNAME</div></div>
    <div class="box"><div class="lbl">IP publique</div><div class="val">$PUBLIC_IP</div></div>
    <div class="box"><div class="lbl">Instance ID</div><div class="val">$INSTANCE_ID</div></div>
    <div class="box"><div class="lbl">Serveur</div><div class="val">Nginx</div></div>
  </div>
  <footer>Gere par Terraform · github.com/AndriamamonjyFah/terraform-aws-infra</footer>
</body>
</html>
HTML

#  Health check 
sleep 2
if systemctl is-active --quiet nginx; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nginx actif — provisioning terminé avec succès."
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERREUR : Nginx n'a pas démarré."
  exit 1
fi
