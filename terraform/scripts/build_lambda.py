#!/usr/bin/env python3
"""Build Lambda deployment package with Linux-compatible wheels."""

import shutil
import subprocess
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: build_lambda.py <source_dir> <output_dir>", file=sys.stderr)
        sys.exit(1)

    source_dir = Path(sys.argv[1]).resolve()
    output_dir = Path(sys.argv[2]).resolve()

    if output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True)

    subprocess.run(
        [
            sys.executable,
            "-m",
            "pip",
            "install",
            "-r",
            str(source_dir / "requirements.txt"),
            "-t",
            str(output_dir),
            "--platform",
            "manylinux2014_x86_64",
            "--python-version",
            "3.11",
            "--implementation",
            "cp",
            "--only-binary=:all:",
            "--upgrade",
            "--quiet",
        ],
        check=True,
    )

    shutil.copy(source_dir / "handler.py", output_dir / "handler.py")
    print(f"Package Lambda prêt dans {output_dir}")


if __name__ == "__main__":
    main()
