<p align="center">
<img alt="fast_Optics" src="https://github.com/jracevedob/MPSoC_Networking/blob/main/Logo/fast.png" width="800">
</p>

# Xilinx's ZCU102 MPSoC Networking

[![MIT Licensed](https://img.shields.io/github/license/jracevedob/MPSoC_Networking)](https://github.com/jracevedob/MPSoC_Networking/blob/main/LICENSE)
[![Build Status](https://github.com//jracevedob/MPSoC_Networking/actions/workflows/build.yml/badge.svg)](https://github.com//jracevedob/MPSoC_Networking/actions)
[![Documentation Status](https://readthedocs.org/projects/graphriccicurvature/badge/?version=latest)](https://github.com/jracevedob/MPSoC_Networking/wiki)
[![Github All Releases](https://img.shields.io/github/downloads/jracevedob/MPSoC_Networking/total.svg)]()


This repository contains the source code for implementing data exchange through the SFP+ Cages of the Xilinx's Multi-processor System-on-Chip (MPSoC). We validate this implementation using an optical atenautor, connected to a DC voltage source.

## Overview

The communication between the ZCU102 board and the fastOptics' optical chip is based on the implementation of a complete 1G/2.5G and an 10G Ethernet subsystem. This subsystem functionality is provided by LogiCORE IP, which provides the Processing System (PS) and Programmable Logic (PL) hardware blocks to enable the communication between the application and the kernel modules. 

The Xilinx's UltraScale+ ZCU102 board is composed of the PS and the PL, as Figure 1 depicts. The PS uses four Gigabit Ethernet Managers (GEMs), also known as GEM0, GEM1, GEM2, and GEM3; to configure different Ethernet interfaces independently. In the default setup of the ZCU102, the controller for each GEM is based on the Reduced Gigabit Media Independent Interface (RGMII), which reduces the amount of pins in the PHY- MAC interface by multiplexing data and control signals using the rising and falling edge of the clock. The Multiplexed I/O (MIO) maps the RGMII data to the Ethernet RGMII PHY device, which is a gigabit Ethernet PHY transceiver. 


<p align="center">
<img alt="Ethernet_PLPS" src="https://github.com/jracevedob/MPSoC_Networking/blob/main/Figures/PLPS.png" width="800">
</p>

## Table of Contents
## Quick Start

### Hardware 

### Software

### Driver integration

### Results

## Citations

Currently, we are working in the writing of a publication where we are going to condense all the results and findings of this project. The ethernet communication is under development following this reference:

```
@INPROCEEDINGS{acevedo2022,
  AUTHOR="Javier Acevedo and Shahryar Sabouri and Shiwei Shen and Christoph Keller and Joerg Hopfe and Stefan Reichmuth and Patrick Hobi and  Marco Dietrich and Kambiz Jamshidi and Frank H. P. Fitzek",
  TITLE="High Bandwidth and Ultra Low-Latency Near IR Communication Network for CMOS-compatible Integrated Photonics Chips",
  BOOKTITLE="VDE ITG Fachtagung Photonische Netze 2022 ",
  ADDRESS="",
  DAYS="19-20",
  MONTH="may",
  YEAR="2022",
  ABSTRACT="Photonic Integrated Circuit (PIC) have outperformed its electrical counterpart in terms of on-chip processing
and power consumption by transmitting and computing optical signals at ultra-high speed, using less energy. However, fully
functional optical transceivers are still rare. This work introduces the design and implementation of a tunable transceiver and an
optical communication network on top of an external laser source, functioning in the near-Infrared (IR) range. The transceiver
is composed of the integrated circuit of an optical chip, a hardware acceleration interface, and a customized Digital-toAnalog Converter (DAC) at the transmitter and receiver side. The
photonic chip was designed and fabricated on CMOS compatible and represents an integrated Optical Phased Array (OPA),
which modulates light for multi-channel beam control. The twodimensional beam steering relies on an array of waveguide
grating couplers, which ensures high accuracy and directionality during the narrow beam radiation. In the longitudinal direction,
the beam is steered by a wavelength tuning mechanism, while for the lateral direction, the lobe is controlled by a network of
thermo-optical phase shifters. The hardware accelerator, a Multiprocessor System-on-Chip (MPSoC), computes the source data
with random coefficient in Galois Fields (GF) to generate coded packets, which flow throughout the optical beams. Additionally,
the accelerator is also responsible for the selection of the input voltage within the DACs to control the optical chip. To ensure
successful packet transmission when the transmitter and receiver are in motion, a dynamic sliding window protocol based on
Random Linear Network Coding (RLNC) was designed and implemented at the MAC layer. Extensive simulation demonstrates
that our implementation results in an average packet success rate of 93.58 % with reduction in average delay.",
  KEYWORDS="Integrated Photonics Chip, Gilbert-Elliot (GE) Channels, MPSoC, IR Communication, RLNC, Dynamic Sliding Window (DSW), VCSEL.",
  URL=""
 }
```

```
@Article{Acevedo2022,
AUTHOR = {Acevedo, Javier and Sabouri, Shahryar and Shen, Shiwei and Dietrich, Marco and Kambiz, Jamshidi and Fitzek, Frank H. P. },
TITLE = {Blink: Ultrafast Optical Ethernet Communication using Multi-processor System-on-Chip},
JOURNAL = {Electronics},
VOLUME = {},
YEAR = {2021},
NUMBER = {},
ARTICLE-NUMBER = {180},
URL = {},
ISSN = {},
ABSTRACT = {}
}
```

## Contributing

This project exists thanks to all people who contribute.
The [list](./CONTRIBUTORS) of all contributors.

Please refer to the following [Link](https://de.fast-zwanzig20.de/) to get access to more detailed information about the project.

## Contact

* **Javier Acevedo** - *Contributor and Project Maintainer* javier.acevedo@tu-dresden.de

## License

This project is licensed under the [MIT license](./LICENSE).

## Documentation

### Networking
Vendor documentation [Link](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/862912682/Networking+in+QEMU)

### Hardware-Software Codesign

### Driver integration

## News

* **12.04.2021** - *Our paper called "High Bandwidth and Ultra Low-Latency Near IR Communication Network for CMOS-compatible Integrated Photonics Chips" has been accepted for its publication at the DE ITG Fachtagung Photonische Netze 2022 Confernce*
* **10.02.2022** - *Migration to a private repository for testing*
* **14.08.2021** - *Hardware-Software integration*
* **10.08.2021** - *Benchmarking of C++ implementation*
* **09.08.2021** - *First release of the Randon Linear Network Coding in Multi-Processor System-on-Chip repository*

## Acknowledgement

We are really grateful to the TU Dresden and Prof. Frank H. P. Fitzek for their support in the realization of this initiative.

The project underlying this publication was supported by the Federal Ministry of Education and Research of Germany (BMBF) within the programme “Zwanzig20 – Partnership for Innovation” as part of the project consortium “fast” (funding reference number 03ZZ0532D).
