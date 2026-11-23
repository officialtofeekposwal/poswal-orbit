import os
import subprocess
import sys

# Script to subset bundled TTF fonts to optimized woff2
fonts_dir = r"D:\Desktop\Poswal\assets\fonts"
out_dir = r"D:\Desktop\Poswal\website\assets\fonts"

# Latin basic + supplement + punctuation
unicodes_latin = "U+0020-007F,U+00A0-00FF,U+2010-2027,U+2030-205E"

# Devanagari block + basic Latin numbers/symbols
unicodes_devanagari = "U+0020-007F,U+0900-097F,U+200C-200D,U+2010-2027"

# Arabic / Urdu Nastaliq block + basic Latin
unicodes_urdu = "U+0020-007F,U+0600-06FF,U+0750-077F,U+FB50-FDFF,U+FE70-FEFF,U+200C-200F"

configs = [
    ("PlusJakartaSans-Bold.ttf", "PlusJakartaSans-Bold.woff2", unicodes_latin),
    ("PlusJakartaSans-SemiBold.ttf", "PlusJakartaSans-SemiBold.woff2", unicodes_latin),
    ("PlusJakartaSans-Regular.ttf", "PlusJakartaSans-Regular.woff2", unicodes_latin),
    ("Inter-Regular.ttf", "Inter-Regular.woff2", unicodes_latin),
    ("NotoSansDevanagari-Regular.ttf", "NotoSansDevanagari-Regular.woff2", unicodes_devanagari),
    ("NotoNastaliqUrdu-Regular.ttf", "NotoNastaliqUrdu-Regular.woff2", unicodes_urdu),
]

for src_name, dst_name, unicodes in configs:
    src_path = os.path.join(fonts_dir, src_name)
    dst_path = os.path.join(out_dir, dst_name)
    cmd = [
        sys.executable,
        "-m", "fontTools.subset",
        src_path,
        f"--output-file={dst_path}",
        "--flavor=woff2",
        f"--unicodes={unicodes}",
        "--layout-features=*",
        "--desubroutinize",
    ]
    print(f"Subsetting {src_name} -> {dst_name}...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"Error subsetting {src_name}: {res.stderr}")
    else:
        size = os.path.getsize(dst_path)
        print(f"Done: {dst_name} ({size} bytes, {size/1024:.2f} KB)")
