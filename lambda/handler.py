"""
Lambda : conversion d'image en PDF.

Déclenchée par un événement S3 (ObjectCreated) sur le bucket source.
Pour chaque image uploadée :
  1. téléchargement depuis le bucket source ;
  2. conversion au format PDF (Pillow) ;
  3. renommage <nom>-<suffixe>.pdf ;
  4. dépôt dans le bucket de destination.
"""

import os
import uuid
from io import BytesIO
from urllib.parse import unquote_plus

import boto3
from PIL import Image

s3 = boto3.client("s3")

DESTINATION_BUCKET = os.environ["DESTINATION_BUCKET"]

# Extensions d'image prises en charge
SUPPORTED = (".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp")


def handler(event, context):
    for record in event.get("Records", []):  # Test pour Ansible
        src_bucket = record["s3"]["bucket"]["name"]
        # Les clés S3 sont url-encodées dans l'événement
        src_key = unquote_plus(record["s3"]["object"]["key"])

        ext = os.path.splitext(src_key)[1].lower()
        if ext not in SUPPORTED:
            print(f"Ignoré (extension non supportée) : {src_key}")
            continue

        # 1. Téléchargement de l'image source
        response = s3.get_object(Bucket=src_bucket, Key=src_key)
        image_bytes = response["Body"].read()

        # 2. Conversion en PDF
        image = Image.open(BytesIO(image_bytes))
        # PDF ne gère pas l'alpha ni la palette -> passage en RGB
        if image.mode in ("RGBA", "P", "LA"):
            image = image.convert("RGB")

        pdf_buffer = BytesIO()
        image.save(pdf_buffer, format="PDF")
        pdf_buffer.seek(0)

        # 3. Renommage : <nom-original>-<suffixe>.pdf
        base = os.path.splitext(os.path.basename(src_key))[0]
        new_key = f"{base}-{uuid.uuid4().hex[:8]}.pdf"

        # 4. Dépôt dans le bucket de destination
        s3.put_object(
            Bucket=DESTINATION_BUCKET,
            Key=new_key,
            Body=pdf_buffer.getvalue(),
            ContentType="application/pdf",
        )

        print(
            f"Converti : s3://{src_bucket}/{src_key} "
            f"-> s3://{DESTINATION_BUCKET}/{new_key}"
        )

    return {"status": "ok"}
