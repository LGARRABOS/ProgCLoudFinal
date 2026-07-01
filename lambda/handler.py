import json
import logging
import os
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import unquote_plus

import boto3
import img2pdf

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

DEST_BUCKET = os.environ["DEST_BUCKET"]
SUPPORTED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}


def handler(event, context):
    results = []

    for record in event.get("Records", []):
        source_bucket = record["s3"]["bucket"]["name"]
        object_key = unquote_plus(record["s3"]["object"]["key"])
        suffix = Path(object_key).suffix.lower()

        if suffix not in SUPPORTED_EXTENSIONS:
            logger.warning("Type de fichier non supporté : %s", object_key)
            continue

        stem = Path(object_key).stem
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        dest_key = f"{stem}_{timestamp}.pdf"

        logger.info(
            "Conversion %s/%s -> %s/%s",
            source_bucket,
            object_key,
            DEST_BUCKET,
            dest_key,
        )

        response = s3.get_object(Bucket=source_bucket, Key=object_key)
        image_bytes = response["Body"].read()
        pdf_bytes = img2pdf.convert(image_bytes)

        s3.put_object(
            Bucket=DEST_BUCKET,
            Key=dest_key,
            Body=pdf_bytes,
            ContentType="application/pdf",
        )

        results.append(
            {
                "source_bucket": source_bucket,
                "source_key": object_key,
                "dest_bucket": DEST_BUCKET,
                "dest_key": dest_key,
            }
        )
        logger.info("PDF déposé : s3://%s/%s", DEST_BUCKET, dest_key)

    return {
        "statusCode": 200,
        "body": json.dumps({"processed": len(results), "files": results}),
    }
