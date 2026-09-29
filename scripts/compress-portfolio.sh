#!/bin/zsh
# Compresses a photo folder into public/portfolio (originals untouched).
# Usage: ./scripts/compress-portfolio.sh [source folder]   (default: ~/Documents/portfolio edited)
# Long edge capped at 2400px, JPEG quality 82. If that saves under 10%, the original is copied as-is.
SRC="${1:-$HOME/Documents/portfolio edited}"
OUT="${0:A:h}/../public/portfolio"
rm -rf "$OUT" && mkdir -p "$OUT"
i=1
for f in "$SRC"/*.(jpg|JPG|jpeg|JPEG|ARW)(N); do
  name=$(printf "%02d.jpg" $i)
  dims=($(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk "/pixel/{print \$2}"))
  resize=(); (( dims[1] > 2400 || dims[2] > 2400 )) && resize=(-Z 2400)  # only shrink, never enlarge
  if sips -s format jpeg -s formatOptions 82 $resize "$f" --out "$OUT/$name" >/dev/null 2>&1; then
    orig=$(stat -f%z "$f"); new=$(stat -f%z "$OUT/$name")
    if [[ ${f:e:l} != arw ]] && (( new * 10 > orig * 9 )); then
      cp "$f" "$OUT/$name" && echo "$name <- ${f:t} (kept original)"
    else
      echo "$name <- ${f:t}"
    fi
  else
    echo "FAILED: ${f:t}"
  fi
  i=$((i+1))
done
