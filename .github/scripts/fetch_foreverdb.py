#!/usr/bin/env python3
"""Download the ForeverDB addon and its current quest data files.

ForeverDB's manifest (https://foreverdb.net/downloads/addon-manifest.json)
lists the addon zip, which holds the licence files, and the data files it
has updated since that zip was built. Every download is checked against the
SHA-256 in the manifest.

  python3 fetch_foreverdb.py --out DIR   ->  DIR/ForeverDB/
"""
import argparse
import hashlib
import io
import json
import os
import sys
import urllib.request
import zipfile

SITE = "https://foreverdb.net/"
MANIFEST = SITE + "downloads/addon-manifest.json"
DATA_FILES = ("Data/Meta.lua", "Data/QuestClassic.lua", "Data/QuestForever.lua")
FOLDER = "ForeverDB"


def fail(message):
    print("fetch_foreverdb: " + message, file=sys.stderr)
    sys.exit(1)


def get(url):
    request = urllib.request.Request(url, headers={"User-Agent": "addon-data-build"})
    with urllib.request.urlopen(request, timeout=120) as response:
        return response.read()


def checked(entry):
    body = get(SITE + entry["url"])
    if hashlib.sha256(body).hexdigest() != entry["sha256"]:
        fail("SHA-256 of %s doesn't match the manifest" % entry["url"])
    return body


def main():
    ap = argparse.ArgumentParser(description="Download the ForeverDB addon and its current quest data files.")
    ap.add_argument("--out", required=True, help="folder to write ForeverDB/ into")
    args = ap.parse_args()

    manifest = json.loads(get(MANIFEST))
    root = os.path.realpath(os.path.join(args.out, FOLDER))
    with zipfile.ZipFile(io.BytesIO(checked(manifest["addon"]))) as archive:
        # the zip also holds other addons: take only the ForeverDB folder
        wanted = []
        for info in archive.infolist():
            if not info.filename.startswith(FOLDER + "/"):
                continue
            target = os.path.realpath(os.path.join(args.out, info.filename))
            if target != root and not target.startswith(root + os.sep):
                fail("unexpected path in the addon zip: " + info.filename)
            wanted.append(info)
        if not wanted:
            fail("no %s folder in the addon zip" % FOLDER)
        archive.extractall(args.out, members=wanted)

    newer = {entry["path"]: entry for entry in manifest["data"]["files"]}
    for path in DATA_FILES:
        if path not in newer:
            fail("the manifest no longer lists " + path)
        with open(os.path.join(root, *path.split("/")), "wb") as f:
            f.write(checked(newer[path]))
    print("ForeverDB addon %s, data %s" % (manifest["addon"]["version"], manifest["data"]["version"]))


if __name__ == "__main__":
    main()
