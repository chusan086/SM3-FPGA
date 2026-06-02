# SM3-FPGA

**FPGA implementation of SM3 cryptographic hash algorithm (GB/T 32905)**

> SM3 is the Chinese national standard for cryptographic hash, producing a 256-bit digest. This project implements the SM3 compression function and message expansion on FPGA.

## Target Board

| Board | Chip |
|-------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## Repository Structure

```
SM3-FPGA/
├── rtl/         # RTL implementation (SystemVerilog)
├── sim/         # Simulation testbenches
├── ip/          # Vivado IP configurations
├── constr/      # Timing and pin constraints
├── scripts/     # Project creation Tcl
├── LICENSE      # MIT License
└── README.md
```

## Current Progress

### Implemented

- [x] SM3 compression function (core compress)
- [x] SM3 message expansion (word extend)
- [x] SM3 core top module

### TODO

- [ ] Complete SM3 padding and message scheduling
- [ ] AXI interface
- [ ] Zynq PS-PL demo
