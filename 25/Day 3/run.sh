#!/bin/zsh

zig build --release=fast
ret="$?"

if [[ "$ret" -ne 0 ]]; then
  exit 1
fi

TIMEFMT='%U user %S system %P cpu %*E total'

for f in zig-out/bin/*; do
  echo "Running $(basename "$f")"
  time "$f" input
done
