import os
import glob

files = sorted(glob.glob('nautilus_gold_scalper/src/**/*.py', recursive=True))
for f in files:
    if '__init__' not in f:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                lines = len(file.readlines())
                print(f"{f}: {lines}")
        except:
            print(f"{f}: ERROR")
