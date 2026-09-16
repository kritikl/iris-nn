import re
from pathlib import Path

def extract_utilization(file_path):
    if not Path(file_path).exists():
        return {'LUTs': 'N/A', 'DSPs': 'N/A', 'FFs': 'N/A'}
    
    text = Path(file_path).read_text(encoding='utf-8', errors='ignore')
    
    # Slice LUTs
    luts = re.search(r'Slice LUTs\*\s*\|\s*(\d+)', text)
    # DSPs
    dsps = re.search(r'DSPs?\s*\|\s*(\d+)', text)
    # Slice Registers / FFs
    ffs = re.search(r'Slice Registers\s*\|\s*(\d+)', text)
    
    return {
        'LUTs': int(luts.group(1)) if luts else 'N/A',
        'DSPs': int(dsps.group(1)) if dsps else 'N/A',
        'FFs' : int(ffs.group(1)) if ffs else 'N/A'
    }

print("\n=== FINAL SYNTHESIS COMPARISON ===\n")
print(f"{'Precision':<8} {'LUTs':>8} {'DSPs':>6} {'FFs':>8}")
print("-" * 45)

for name, suffix in [('Q4.4', 'q44'), ('Q8.8', 'q88'), ('Q16.16', 'q1616')]:
    data = extract_utilization(f"utilization_{suffix}.rpt")
    print(f"{name:<8} {data['LUTs']:>8} {data['DSPs']:>6} {data['FFs']:>8}")

print("-" * 45)
