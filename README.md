# SM3-FPGA

**FPGA implementation of SM3 cryptographic hash algorithm (GB/T 32905)**

> SM3 is the Chinese national standard for cryptographic hash, producing a 256-bit digest. This project implements the SM3 compression function and message expansion on FPGA.

## Target Board

| Board | Chip |
|-------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## Repository Structure

`
SM3-FPGA/
├── rtl/         # RTL implementation (SystemVerilog)
├── sim/         # Simulation testbenches
├── ip/          # Vivado IP configurations
├── constr/      # Timing & pin constraints
├── scripts/     # Project creation Tcl
├── LICENSE      # MIT
└── README.md
`

## Current Progress

### Implemented

- [x] SM3 compression function (核心压缩)
- [x] SM3 message expansion (消息扩展)
- [x] SM3 core top module

### TODO

- [ ] Complete SM3 padding & message scheduling
- [ ] AXI interface
- [ ] Zynq PS-PL demo

--- (中文) ---

**SM3 密码杂凑算法 FPGA 实现 (GB/T 32905)**

## 目标平台

| 开发板 | 芯片 |
|--------|------|
| RK-ZYNQ7100-F | XC7Z100-FFG900-2 |

## 当前进度

### 已完成
- [x] SM3 压缩函数
- [x] SM3 消息扩展
- [x] SM3 顶层模块

### 待实现
- [ ] 完整的消息填充与调度
- [ ] AXI 接口
- [ ] Zynq PS-PL 演示