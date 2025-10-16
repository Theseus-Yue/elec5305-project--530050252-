#  Title: Speech Enhancement for Hearing Aids in Traffic Noise Environments

1. Project Overview

The goal of this project is to develop a speech enhancement algorithm tailored for hearing aids operating in traffic noise environments. Hearing-impaired users frequently struggle to understand speech in urban outdoor scenarios where noise from cars, buses, motorcycles, and horns creates strong interference. Unlike stationary background noise, traffic noise is highly non-stationary, wideband, and often impulsive, making traditional filtering methods less effective.

This project will implement and evaluate real-time speech enhancement methods that are both effective and computationally efficient for hearing aids. Baseline methods such as Wiener filtering and MMSE-STSA (Minimum Mean Square Error Short-Time Spectral Amplitude estimation) will be implemented. In addition, a lightweight deep learning model will be explored to enhance robustness in complex noise while maintaining low latency suitable for hearing aid applications.

2. Background and Motivation

Hearing aids are essential for improving the quality of life of individuals with hearing loss, yet many users report difficulty understanding speech in noisy outdoor conditions. Traditional speech enhancement algorithms such as Wiener filtering have been widely studied, but their performance degrades significantly in non-stationary noise such as traffic.

Recent advances in deep learning have achieved state-of-the-art performance in speech enhancement tasks. However, most neural models are computationally heavy, making them unsuitable for the limited processing power and latency constraints of hearing aids. Traffic noise presents an important real-world challenge condition that has been less studied compared to stationary or babble noise.

By focusing specifically on speech enhancement in traffic noise environments, this project addresses a well-defined and practical problem that combines both traditional signal processing and modern machine learning techniques.

3. Proposed Methodology
   
Data Sources:
DNS Challenge Dataset: A large-scale dataset containing real and synthetic noisy-clean speech pairs, including traffic noise recordings.
NOISEX-92 Dataset: A classical noise dataset with “Volvo car interior” and other environmental noise types.
TIMIT Dataset: Clean speech corpus to be mixed with traffic noise samples to generate test data at controlled SNR levels.

Baseline Algorithms:
Wiener Filtering – A classic spectral-domain algorithm for noise reduction.
MMSE-STSA (Ephraim & Malah, 1984) – A statistically optimal method widely used in speech enhancement research.

Proposed Approach:
Step 1: Baseline Implementation
        Implement Wiener filtering and MMSE-STSA on noisy speech (speech + traffic noise at different SNR levels).
Step 2: Lightweight Neural Network
        Train a small spectral mask estimation network (inspired by DNS Challenge baselines) to handle non-stationary traffic noise.
Step 3: Evaluation
        Evaluate both baseline and neural models using objective speech quality and intelligibility metrics.



How to prepare the dataset?
NC: Please check NC's repo.
DDAE: Download our pre-prepared dataset from Google Drive and unzip it to the root directory of the repo. Then run the prepare_data.py

Reference:
1. NIDCD, (2022), Hearing Aids
2. https://github.com/microsoft/DNS-Challenge
3. Green T, Hilkhuysen G, Huckvale M, Rosen S, Brookes M, Moore A, Naylor P, Lightburn L, Xue W. Speech recognition with a hearing-aid processing scheme combining beamforming with mask-informed speech enhancement. Trends Hear. 2022 Jan-Dec;26:23312165211068629. doi: 10.1177/23312165211068629. PMID: 34985356; PMCID: PMC8744079.
4. https://github.com/ghnmqdtg/Deep-Learning-Based-Noise-Reduction-and-Speech-Enhancement-System/blob/main/README.md
5. https://drive.google.com/file/d/1eiRYFSOqBTPAJabmzAV5s0pQaqCE-OVg/view
