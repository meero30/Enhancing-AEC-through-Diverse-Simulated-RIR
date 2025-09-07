# Enhancing Acoustic Echo Cancellation through Diverse Simulated Room Impulse Responses

A research project focused on improving Acoustic Echo Cancellation (AEC) performance by generating diverse synthetic Room Impulse Response (RIR) datasets that better represent real-world acoustic conditions.

## Overview

This project addresses limitations in existing AEC datasets by developing a comprehensive synthetic dataset generation methodology. Using Parameterized Random Sampling and MATLAB's RIR generation tools, we create diverse room configurations and reverberation scenarios that reflect a broader spectrum of real-world environments.

## Problem Statement

Current AEC models like DCA-Net show promise with advanced attention mechanisms, but their effectiveness is constrained by limited diversity and variability in training datasets. Most existing datasets don't adequately cover the wide range of acoustic conditions encountered in real-world applications.

## Research Objectives

- Enhance synthetic dataset generation for Room Impulse Responses (RIR)
- Develop diverse and realistic synthetic datasets through configurable room parameters
- Utilize Parameterized Random Sampling to analyze distributions in existing RIR datasets
- Establish improved dataset pipeline standards for AEC research

## Methodology

### Dataset Generation Process

1. **Parameter Analysis**: Extract realistic ranges from the Aachen Impulse Response (AIR) Database
2. **Parameterized Random Sampling**: Generate bounded, realistic RIR parameters including:
   - Reverberation time (RT60): 0.11 to 8.78 seconds
   - Room dimensions: 2-30 meters
   - Source and microphone positions
3. **RIR Synthesis**: Use MATLAB's built-in tools to simulate reflections and reverberation
4. **Signal Processing**: Apply generated RIRs to clean far-end speech signals
5. **Environment Simulation**: Combine echoed signals with near-end speech and background noise

### Key Parameters

The RIR generation function utilizes the following randomized arguments:
- `fs`: Sampling frequency
- `mic`: Microphone position
- `n`: Room dimensions
- `r`: Reverberation parameters
- `rm`: Room material properties  
- `src`: Source position

All parameters are bounded by realistic values derived from the AIR Database.

## Technology Stack

- **Primary Tool**: MATLAB
- **RIR Generation**: `audioExample.RoomImpulseResponse`
- **Dataset Source**: Microsoft AEC Dataset (near-end/far-end signals)
- **Reference Database**: Aachen Impulse Response (AIR) Database
- **Analysis Tools**: Spectrogram visualization, time-domain analysis

## Results

### Key Findings

- Successfully generated synthetic datasets with controlled acoustic variability
- Achieved RT60 range spanning from small booths to large halls
- Demonstrated clear acoustic effects through spectrogram analysis
- Created reproducible, parameterized acoustic scenarios for systematic testing

### Visualizations Generated

1. **Room Configuration**: 3D visualization of source/receiver positions
2. **Signal Analysis**: Time-domain plots of original, echoed, and combined signals
3. **Spectrograms**: Frequency-domain comparison showing acoustic effects
4. **RIR Characteristics**: Impulse response patterns with echo visualization

## Expected Impact

### Immediate Benefits
- More comprehensive RIR dataset standards for AEC research
- Improved model generalization across different acoustic environments
- Enhanced communication system performance
- Better audio quality in voice-activated devices

### Future Applications
- Audio signal processing research advancement
- Communication technology improvements
- Benchmark establishment for AEC system testing
- Educational tool for acoustic signal processing

## Limitations and Future Work

### Current Limitations
- Frequency-dependent behavior could be enhanced for better real-world matching
- Noise implementation lacks structured environmental patterns
- Limited real-time parameter adjustment capabilities

### Recommended Improvements
- Enhance cross-dataset synthetic data generation
- Incorporate structured real-world noise patterns
- Develop real-time acoustic parameter visualization
- Expand dataset augmentation methodologies


## Authors

**De La Salle University - DSIGPRO EQ2 Group 7**

- Benitez, Renz Jericho A.
- Hernandez, Miro Manuel L.
- Molo, Carlos Sebastian V.
- Wijangco, Deian Angelo R.
- Yu, Dominic P.

## References

This project builds upon research from ICASSP 2023 Acoustic Echo Cancellation Challenge and incorporates methodologies from recent neural network-based AEC approaches. Key references include work on hybrid AEC models, dataset augmentation techniques, and advanced neural architectures for echo cancellation.

## Data Sources

- **Aachen Impulse Response (AIR) Database**: RWTH Aachen University
- **Microsoft AEC Dataset**: Source signals for near-end and far-end audio
- **MATLAB RIR Tools**: Built-in room acoustics simulation functions

## Getting Started

### Prerequisites
- MATLAB with Signal Processing Toolbox
- Access to Microsoft AEC Dataset
- Sufficient storage for generated synthetic data

### Usage
1. Configure room parameter ranges in `parameter_sampling.m`
2. Run `rir_generation.m` to generate synthetic RIRs
3. Execute signal mixing and combination processes
4. Analyze results using provided visualization tools

