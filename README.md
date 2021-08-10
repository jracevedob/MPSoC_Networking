<p align="center">
<img alt="fast_Optics" src="https://github.com/jracevedob/MPSoC_Networking/blob/main/Logo/fast.png" width="800">
</p>

# MPSoC_Networking

[![MIT Licensed](https://img.shields.io/github/license/jracevedob/MPSoC_Networking)](https://github.com/jracevedob/MPSoC_Networking/blob/main/LICENSE)
[![Build Status](https://img.shields.io/github/checks-status/jracevedob/MPSoC_Networking/workflows/main.yml/badge.svg)](https://github.com//jracevedob/MPSoC_Networking/actions)
[![Documentation Status](https://readthedocs.org/projects/graphriccicurvature/badge/?version=latest)](https://github.com/jracevedob/MPSoC_Networking/wiki)
[![Github All Releases](https://img.shields.io/github/downloads/jracevedob/MPSoC_Networking/total.svg)]()


This repository contains the source code for implementing data exchange through the SFP+ Cages of the Xilinx's Multi-processor System-on-Chip (MPSoC)

## Overview

The communication between the ZCU102 board and the Optical chip is based on the implementation of a complete 1G/2.5G and an 10G Ethernet subsystem. This subsystem functionality is provided by LogiCORE IP, which provides the Processing System (PS) and Programmable Logic (PL) hardware blocks to enable the communication between the application and the kernel modules. 

The UltraScale+ ZCU102 board from Xilinx is composed of the PS and the PL as Figure 1 depicts. The PS uses four Gigabit Ethernet Managers (GEMs), also known as GEM0, GEM1, GEM2, and GEM3; to configure different Ethernet interfaces independently. In the default setup of the ZCU102, the controller for each GEM is based on the Reduced Gigabit Media Independent Interface (RGMII), which reduces the amount of pins in the PHY- MAC interface by multiplexing data and control signals using the rising and falling edge of the clock. The Multiplexed I/O (MIO) maps the RGMII data to the Ethernet RGMII PHY device, which is a gigabit Ethernet PHY transceiver. 


<p align="center">
<img alt="Ethernet_PLPS" src="https://github.com/jracevedob/MPSoC_Networking/blob/main/Images/PSPL.png" width="800">
</p>

## Table of Contents
## Quick Start

### Driver and Software Installation

### Examples

### Implementation


## Citations


## Contributing

This project exists thanks to all people who contribute.
The [list](./CONTRIBUTORS) of all contributors.


## Contact

* **Javier Acevedo** - *Contributor and Project Maintainer* javier.acevedo@tu-dresden.de


## License

This project is licensed under the [MIT license](./LICENSE).

## News

* **Hardware acceleration** - *Through RFSoC, we accelerate the Ethernet frame processing*
