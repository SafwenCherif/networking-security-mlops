#!/bin/bash
# Run on a fresh Ubuntu EC2 instance (as ubuntu user with sudo).
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/SafwenCherif/networking-security-mlops}"
RUNNER_NAME="${RUNNER_NAME:-networksecurity-ec2-runner}"
RUNNER_VERSION="${RUNNER_VERSION:-2.321.0}"

if [ -z "${RUNNER_TOKEN:-}" ]; then
  echo "ERROR: Set RUNNER_TOKEN before running this script."
  echo "Generate one from GitHub: Settings -> Actions -> Runners -> New self-hosted runner"
  echo "Or: gh api repos/SafwenCherif/networking-security-mlops/actions/runners/registration-token -X POST"
  exit 1
fi

echo "=== Installing AWS CLI ==="
sudo apt-get install -y awscli

echo "=== Installing Docker ==="
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker "$USER"
rm -f get-docker.sh

echo "=== Installing GitHub Actions runner ==="
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
tar xzf "./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"

./config.sh \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "self-hosted,Linux,X64,networksecurity" \
  --unattended \
  --replace

sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status

echo "=== Runner installed ==="
echo "Verify in GitHub: Settings -> Actions -> Runners"
