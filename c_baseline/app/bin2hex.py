#!/usr/bin/env python3
import argparse
import sys

NOP = 0x00000013  # addi x0, x0, 0

def read_file(path: str) -> bytes:
    with open(path, "rb") as f:
        return f.read()

def main():
    ap = argparse.ArgumentParser(description="Convert raw binary to inst.hex (one 32-bit word per line, little-endian).")
    ap.add_argument("input_bin", help="input raw binary (e.g., baseline.bin)")
    ap.add_argument("output_hex", help="output hex file (e.g., inst.hex)")
    ap.add_argument("--at", action="store_true", help="emit @00000000 header (for some $readmemh formats)")
    ap.add_argument("--pad-words", type=int, default=1024,
                    help="pad output to this many 32-bit words with NOP. 0 disables padding. (default: 1024)")
    ap.add_argument("--pad-with-zero", action="store_true",
                    help="pad with 0x00000000 instead of NOP (NOT recommended unless your IMEM treats 0 as NOP)")
    args = ap.parse_args()

    data = read_file(args.input_bin)

    # pad binary length to 4 bytes
    if len(data) % 4 != 0:
        data += b"\x00" * (4 - (len(data) % 4))

    words = []
    for i in range(0, len(data), 4):
        w = data[i] | (data[i+1] << 8) | (data[i+2] << 16) | (data[i+3] << 24)
        words.append(w & 0xFFFFFFFF)

    # pad to fixed IMEM depth (in words)
    if args.pad_words and len(words) < args.pad_words:
        pad_val = 0x00000000 if args.pad_with_zero else NOP
        words.extend([pad_val] * (args.pad_words - len(words)))

    with open(args.output_hex, "w") as f:
        if args.at:
            f.write("@00000000\n")
        for w in words:
            f.write(f"{w:08x}\n")

    print(f"Wrote {len(words)} words to {args.output_hex}", file=sys.stderr)

if __name__ == "__main__":
    main()
