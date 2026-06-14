# RF and Antenna Measurement Laboratory

This repository presents MATLAB-based analysis scripts and measurement results from an Antennas and Propagation laboratory study focused on transmission, return loss, and S-parameter measurements.

The experiment includes analysis of RF/microwave components using measured data from a Keysight N9912A network analyzer. The main topics include insertion loss, return loss, antenna resonance, -10 dB bandwidth, filter behavior, multi-port S-parameter analysis, reciprocity, matching, and port isolation.

## Key Topics

* Insertion loss and return loss measurement
* S11 and S21 analysis
* Antenna resonance frequency detection
* -10 dB bandwidth calculation
* Low-pass filter characterization using S21
* 3-port S-parameter analysis
* Power divider/combiner behavior
* Reciprocity, matching, and isolation analysis
* MATLAB-based plotting and measurement visualization

## Measurement Summary

The antenna S11 measurement showed a resonance frequency around 2.41 GHz, where the reflection was minimum. The -10 dB bandwidth was calculated using the lower and upper cutoff frequencies, approximately 2.392 GHz and 2.432 GHz, resulting in a bandwidth of about 40 MHz.

A separate S21 analysis was used to characterize a filter response. The measured S21 values decreased as frequency increased, indicating a low-pass behavior with a cutoff frequency around 2.3175 GHz.

For the 3-port device, the measured S-parameters showed approximately equal power division between two output ports, with S21 and S31 values close to -3 dB. The output port isolation was observed around -20 dB to -25 dB, indicating that the device behaves as a 2-way 3 dB power divider/combiner.

## MATLAB Scripts

* `s11_resonance_bandwidth_analysis.m`: analyzes S11 magnitude and phase data, finds resonance frequency, and calculates -10 dB bandwidth.
* `s11_s21_filter_analysis.m`: analyzes S11 and S21 data for filter behavior and cutoff frequency.
* `three_port_sparameter_analysis.m`: analyzes multi-port S-parameter data and generates plots for S11, S21, S31, S12, and S32.

## Tools

* MATLAB
* Keysight N9912A Network Analyzer
* RF and microwave measurement setup
* S-parameter data analysis

## Note

The original laboratory report is not included in this repository to avoid sharing student numbers and personal information. This repository contains selected MATLAB scripts, measurement-based analysis, and summarized results.
