TARGET=${1:x86_64}

ROM_DIR=$(nix eval --raw nixpkgs#qemu)/share/qemu
CODE_FD=$ROM_DIR/edk2-$TARGET-code.fd

# Build .iso first
bazel run //:geniso

qemu-system-$TARGET \
  -m 512M \
  -drive if=pflash,file=$CODE_FD,readonly=on \
  -serial stdio \
  -net none \
  -cdrom aletix.iso \

