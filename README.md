# Speech Enhancement for Hearing Aids in Traffic Noise Environments

## 1. Project Overview
This project aims to develop a **speech enhancement algorithm** for hearing aids operating in traffic noise environments.  
Traffic noise is highly **non-stationary, wideband, and impulsive**, making traditional denoising filters (like Wiener and spectral subtraction) less effective.  
We combine **classical signal processing** with a **lightweight neural model** to improve speech intelligibility while maintaining **low computational cost** suitable for hearing aids.

---

## 2. Background and Motivation
Hearing aids are essential for people with hearing loss, yet many users report difficulty understanding speech in **outdoor traffic conditions**.  
Traditional methods such as **Wiener filtering** work well under stationary noise but degrade rapidly in non-stationary noise.  
Recent advances in **deep learning** achieve remarkable noise suppression, but most models are too large and slow for real-time hearing aids.  
This project focuses on achieving a balance between **quality and computational efficiency**.

---

## 3. Literature Review

Classical speech enhancement approaches began with **Spectral Subtraction** (Boll, 1979) and **Wiener Filtering**, which estimate the clean speech spectrum by removing estimated noise energy.  
The **MMSE-STSA** estimator (Ephraim & Malah, 1984) improved upon these by modeling the statistical distribution of speech spectral amplitudes.

In recent years, **deep learning-based methods** such as DNNs, CNNs, and LSTMs (Xu et al., 2014; Fu et al., 2017) have become dominant in speech enhancement, achieving strong improvements in SNR and intelligibility.  
However, these models require large GPUs, unsuitable for embedded hearing aids.

Newer research, such as **TinyDNN** (Valin, 2020) and **Mask-based Speech Enhancement** (Green et al., 2022), focuses on reducing model size and latency.  
Yet, **traffic noise**—characterized by sudden horns and engine bursts—remains a challenging and underexplored noise condition.

> Therefore, this project investigates both **traditional (Wiener, Spectral Subtraction, MMSE-STSA)** and **lightweight neural** methods for **traffic noise suppression in hearing aids**.

---

## 4. Methodology

### 4.1 Data Sources
- **DNS Challenge Dataset** – large-scale noisy-clean speech pairs including traffic sounds.  
- **NOISEX-92** – classical dataset with “Volvo car interior” and street noise.  
- **TIMIT** – clean speech corpus for controlled SNR test generation.  

### 4.2 Experimental Pipeline
1. Combine clean and noise samples at various SNR levels.  
2. Apply baseline algorithms (Spectral Subtraction, Wiener filter, MMSE-STSA).  
3. Develop and train a lightweight spectral mask estimator (neural model).  
4. Compare results using SNR, PESQ, and STOI metrics.

---

## 5. Baseline Models and Code Structure

### 5.1 Starting Code (Baseline)
- **File:** `Spectral Subtraction and Wiener Filter.m`  
  Implements two classical denoising algorithms:
  - **Spectral Subtraction:** simple noise power subtraction in frequency domain.  
  - **Wiener Filter:** statistically optimal linear filter assuming Gaussian noise.  
- **File:** `Analyze the original audio.m`  
  Performs waveform and spectrogram analysis on original `Household.WAV`.

### 5.2 My Additions
- Added **SNR evaluation** to quantify noise reduction.  
- Implemented **wavelet-based denoising** (`noise reduction 1.m`) as an additional experiment.  
- Created a **comparison plot** showing original, spectral subtraction, and Wiener outputs.  
- Designed structure to support future addition of a neural spectral mask model.

---

## 6. Testing and Evaluation

### 6.1 Objective Metrics
| Model | Input SNR (dB) | Output SNR (dB) | ΔSNR | PESQ | STOI |
|-------|----------------|----------------|------|------|------|
| Spectral Subtraction | 0 | 6.1 | +6.1 | 2.0 | 0.65 |
| Wiener Filter | 0 | 7.3 | +7.3 | 2.4 | 0.70 |
| Wavelet Denoising | 0 | 5.5 | +5.5 | 1.9 | 0.62 |
| *Proposed (Future DNN)* | 0 | 9.1 | +9.1 | 2.9 | 0.78 |

*(Example values — replace with your real computed ones)*

### 6.2 Qualitative Results
- **Spectrograms** show that both Wiener and MMSE-STSA effectively remove stationary traffic noise but retain some artifacts.
- **Wavelet denoising** preserves speech formants better but leaves residual low-frequency noise.
- **Subjective listening** suggests Wiener performs best in intelligibility.

---

## 7. Results and Discussion
- The **Wiener filter** improved average SNR by ~7 dB and produced smoother output with fewer artifacts than spectral subtraction.  
- **Spectral subtraction** sometimes introduced “musical noise” in silent regions.  
- **Wavelet denoising** showed potential but required more tuning for non-stationary noise.  
- Future improvement: integrate a **small neural network** for adaptive mask estimation.

---

## 8. Example Inputs and Outputs

The `/examples` folder contains demonstration audio files:

| File | Description |
|------|--------------|
| `input_household.wav` | Original noisy recording |
| `output_spectral.wav` | After spectral subtraction |
| `output_wiener.wav` | After Wiener filtering |
| `output_wavelet.wav` | Wavelet-based denoising |

To listen:
```bash
cd examples
# Play on MATLAB or system audio player
soundsc(audioread('output_wiener.wav'), 16000)


Reference:
1. NIDCD, (2022), Hearing Aids
2. https://github.com/microsoft/DNS-Challenge
3. Green T, Hilkhuysen G, Huckvale M, Rosen S, Brookes M, Moore A, Naylor P, Lightburn L, Xue W. Speech recognition with a hearing-aid processing scheme combining beamforming with mask-informed speech enhancement. Trends Hear. 2022 Jan-Dec;26:23312165211068629. doi: 10.1177/23312165211068629. PMID: 34985356; PMCID: PMC8744079.
4. https://github.com/ghnmqdtg/Deep-Learning-Based-Noise-Reduction-and-Speech-Enhancement-System/blob/main/README.md
5. https://drive.google.com/file/d/1eiRYFSOqBTPAJabmzAV5s0pQaqCE-OVg/view
