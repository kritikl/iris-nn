# FPGA Iris Classifier – Fixed-Point Neural Network Accelerator

A parameterized fixed-point Multi-Layer Perceptron (MLP) accelerator for the Iris dataset, implemented in SystemVerilog and targeted at Xilinx 7-series FPGAs.

## Architecture

- **Topology**: 4 → 16 → 16 → 3
- **Activation**: ReLU
- **Output**: Argmax classification
- **Supported Precisions**:
  - **Q4.4** (8-bit)
  - **Q8.8** (16-bit) 
  - **Q16.16** (32-bit)

## Key Features

- Fully parameterized neuron and MAC units
- Layer-wise handshaking with proper FSM control
- Input normalization using `StandardScaler` parameters
- Clean separation of weights for each precision
- Synthesizable on Artix-7 (`xc7a100t`)

## Synthesis Results (Artix-7 xc7a100t)

| Precision | LUTs | DSPs | FFs | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Q4.4** | 4,132 | 0 | 1,871 | Zero DSP usage |
| **Q8.8** | **3,037** | **35** | **880** | **Best resource efficiency** |
| **Q16.16** | 9,579 | 140 | 4,037 | Highest numerical precision |

## Project Structure

```text
iris_vmac/
├── sources_1/new/
│   ├── iris.sv              # Main parameterized accelerator
│   ├── neuron.sv            # Parameterized neuron
│   ├── vmac.sv              # Vector MAC unit
│   ├── iris_q44.sv          # Q4.4 top
│   ├── iris_q88.sv          # Q8.8 top
│   └── iris_q1616.sv        # Q16.16 top
├── sim_1/new/
│   └── itb.sv               # Multi-precision testbench
├── network_weights.svh      # Generated weights + normalization
├── report.tcl               # Automated synthesis + report script
├── res.py                   # Python script to extract results
└── README.md
```

## How to Simulate

1. Set `iris_tb` as the simulation top.
2. Run **Behavioral Simulation**.
3. Observe the precision comparison output.

## How to Synthesize

### Manual Method

1. Set one of the top modules (`iris_q44_top`, `iris_q88_top`, or `iris_q1616_top`) as top.
2. Run **Synthesis**.
3. Save Utilization and Timing reports.

### Automated Method (Recommended)

Use the provided `report.tcl` script:

```tcl
source report.tcl
```

This script will:
- Set each precision module as top
- Run synthesis
- Generate `utilization_*.rpt` and `timing_*.rpt` files automatically

## Extracting Results (`res.py`)

After generating the utilization reports, run:

```bash
python3 res.py
```

This script parses the Vivado reports and outputs the comparison:

```text
=== FINAL SYNTHESIS COMPARISON ===

Precision     LUTs   DSPs      FFs
---------------------------------------------
Q4.4         4132      0     1871
Q8.8         3037     35      880
Q16.16       9579    140     4037
---------------------------------------------
```

## Key Learnings

- Impact of fixed-point precision on area and DSP usage
- Importance of consistent Q-format across layers
- Proper handshaking between sequential layers
- Trade-off between numerical accuracy and hardware cost

## Future Improvements

- Systolic array implementation
- AXI4-Stream interface for Zynq SoC integration
- Weight pruning / sparsity support
- Power analysis and clock gating
