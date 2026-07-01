#!/usr/bin/env bash
#
# Construit le package de déploiement de la Lambda.
# Pillow contient des binaires natifs : on force la plateforme Amazon Linux
# (manylinux2014_x86_64) et Python 3.11 pour rester compatible avec le runtime.
#
# À exécuter AVANT `terraform plan/apply` (Terraform lit le zip au moment du plan).
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT/build"
PKG_DIR="$BUILD_DIR/package"
ZIP_PATH="$BUILD_DIR/lambda_package.zip"

rm -rf "$BUILD_DIR"
mkdir -p "$PKG_DIR"

echo ">> Installation des dépendances (compatibles Lambda)..."
pip install \
  --platform manylinux2014_x86_64 \
  --implementation cp \
  --python-version 3.11 \
  --only-binary=:all: \
  --target "$PKG_DIR" \
  -r "$ROOT/lambda/requirements.txt"

echo ">> Ajout du handler applicatif..."
cp "$ROOT/lambda/handler.py" "$PKG_DIR/"

echo ">> Création de l'archive..."
(cd "$PKG_DIR" && zip -r9 "$ZIP_PATH" . >/dev/null)

echo ">> Package prêt : $ZIP_PATH"
