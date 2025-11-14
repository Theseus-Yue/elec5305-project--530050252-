# Speech Enhancement for Hearing Aids in Traffic Noise Environments

**Author:** Yue Yu  
**Unit:** ELEC5305 – Speech & Audio Signal Processing  
**Supervisor:** Dr. Craig Jin  
**Date:** November 2025  

---

## 1. Project Overview

This project develops a low-complexity speech enhancement algorithm designed for hearing aids operating in real-world traffic noise environments.  
Traffic noise is typically non-stationary, broadband, and impulsive, which makes classical speech denoising methods unstable unless properly adapted.

The goal is to improve speech intelligibility while satisfying the strict latency (<20 ms) and computational constraints of hearing-aid DSP hardware.

**Research Question:**  
*How can adaptive classical spectral enhancement improve intelligibility in non-stationary traffic noise while remaining lightweight enough for real-time hearing aids?*

---

## 2. Challenge Conditions

Traffic noise properties:
- Rapid spectral variation  
- Broadband engine/motor/horn noise  
- High-energy transient impulses  
- Dominant low-frequency (0–500 Hz) and high-frequency (4–8 kHz) components  

Hearing aids require:
- Extremely low latency  
- Low computational load  
- Minimal speech distortion  

This motivates interpretable, adaptive, classical enhancement methods instead of neural networks.

---

## 3. Methods Implemented

### Baseline Methods
- Spectral Subtraction  
- Wiener Filtering  

### Adaptive Method
- Adaptive Spectral Subtraction  
  - Frame-wise SNR estimation  
  - Dynamic over-subtraction α  
  - Minimum-statistics noise tracking  

### Final Method
- Hybrid-MMSE (Ephraim–Malah inspired)
  - Decision-directed a priori SNR  
  - MMSE spectral amplitude estimator  
  - Gain flooring for stability  

### Analysis Tools
- STFT / ISTFT  
- RMS, Peak, Zero-Crossing Rate (ZCR)  
- Spectral centroid and bandwidth  
- Time-frequency energy distribution  
- Frame-wise SNR visualization  

---

## 4. Folder Structure
```
project_root/
│
├── Code/
│ ├── Analyze_audio.m
│ ├── Spectral_Subtraction_and_Wiener_Filter.m
│ ├── adaptive_spectral_denoise.m
│ ├── FULL_MMSE_HYBRID_PIPELINE.m
│ └── evaluation_metrics.m
│
├── Data/
│ ├── clean.wav
│ ├── noisy_synthesized.wav
│ ├── household_appliance_test.wav
│ ├── Household_Appliance_train.wav
│ └── Vehicles/TV/Verbal_Human recordings
│
├── Report.md
├── README.md
├── hearing-aids.pdf
└── Speech recognition with a hearing-aid.pdf
```
---

## 5. File Descriptions

| File | Description |
|------|-------------|
| `Analyze_audio.m` | Waveform, spectrogram, RMS/ZCR/centroid/bandwidth, energy analysis |
| `Spectral_Subtraction_and_Wiener_Filter.m` | Classical baseline denoising methods |
| `adaptive_spectral_denoise.m` | Improved spectral subtraction with adaptive α |
| `FULL_MMSE_HYBRID_PIPELINE.m` | Final Hybrid-MMSE processing pipeline |
| `evaluation_metrics.m` | Computes SNR, PESQ, STOI |

Audio files:
- `clean.wav` – reference clean speech  
- `noisy_synthesized.wav` – generated noisy mixture  
- `household_appliance_test.wav`, `Household_Appliance_train.wav` – noise data  

---

## 6. Method Evolution

### Step 1 — Classical Baselines
**Spectral Subtraction**
- Simple, fast  
- Fails under non-stationary noise  
- Produces musical noise  

**Wiener Filter**
- Smooth results  
- Assumes stationary noise → weak for traffic  

### Step 2 — Adaptive Spectral Subtraction
- α changes with frame SNR  
- Noise PSD updated using minimum-statistics  
- Reduces artifacts and improves stability  

### Step 3 — Audio Analysis Module
Findings:
- Noise energy concentrated in 0–500 Hz and 4–8 kHz  
- High zero-crossing rate  
- Rapidly varying STFT energy  

These motivate a statistical estimator.

### Step 4 — Final Hybrid-MMSE Method
- Uses decision-directed SNR  
- MMSE spectral amplitude estimation  
- Gain flooring for robustness  
- Best enhancement quality overall  

---

## 7. How to Run

Requirements:
- MATLAB R2023b or later  
- Signal Processing Toolbox  
- Audio Toolbox  

Run the full pipeline:

```matlab
cd Code
run('Analyze_audio.m')
run('Spectral_Subtraction_and_Wiener_Filter.m')
run('adaptive_spectral_denoise.m')
run('FULL_MMSE_HYBRID_PIPELINE.m')
run('evaluation_metrics.m')
```

## 8. Results Summary

| Method                | Notes                                                      |
|-----------------------|------------------------------------------------------------|
| Spectral Subtraction  | Removes noise but introduces musical artifacts             |
| Wiener Filter         | More stable but weak for non-stationary noise              |
| Adaptive Subtraction  | Better suppression with fewer artifacts                    |
| Hybrid-MMSE           | Best balance of clarity, stability, and noise suppression  |

---

## 9. Audio Files

| File                       | Description                          |
|---------------------------|--------------------------------------|
| `noisy_synthesized.wav`   | Generated noisy input                |
| `enhanced_household.wav`  | Output of adaptive subtraction       |
| `enhanced_output.wav`     | Final Hybrid-MMSE output             |

**Listen in MATLAB:**

```matlab
soundsc(audioread('enhanced_output.wav'), 16000)
```

## 10. Discussion

The adaptive spectral subtraction and Hybrid-MMSE algorithms demonstrate strong improvements under real traffic noise while maintaining low computational cost.

Compared with deep neural network (DNN) enhancement methods such as **Green et al. (2022)**, the proposed classical approaches:

- avoid spatial-cue distortion,
- avoid excessive latency,
- avoid high computational load,
- maintain consistent enhancement even under non-stationary noise,

making them **suitable for real-time processing on hearing-aid DSP hardware**.

The Hybrid-MMSE method shows the best trade-off, offering:

- stable noise suppression,
- reduced musical noise,
- preserved speech formants and consonant edges,
- and robust tracking of rapidly changing noise.

These results reinforce the importance of adaptive, low-complexity spectral methods for practical hearing-aid applications.



## 📚 11. References

1. **Boll, S. F.** (1979). *Suppression of acoustic noise in speech using spectral subtraction.* IEEE Trans. Acoustics, Speech, and Signal Processing, **27(2)**.  
2. **Ephraim, Y.**, & **Malah, D.** (1984). *Speech enhancement using a minimum mean-square error short-time spectral amplitude estimator.* IEEE Trans. ASSP.  
3. **Gerkmann, T.**, & **Hendriks, R. C.** (2012). *Unbiased MMSE-based noise power estimation with low complexity and low tracking delay.* IEEE/ACM Trans. Audio, Speech, and Language Processing.  
4. **Donoho, D.** (1995). *De-noising by soft-thresholding.* IEEE Transactions on Information Theory, **41(3)**, 613–627.  
5. **Xu, Y.**, **Du, J.**, **Dai, L.-R.**, & **Lee, C.-H.** (2015). *A regression approach to speech enhancement based on deep neural networks.* IEEE/ACM Trans. Audio, Speech, and Language Processing, **23(1)**, 7–19.  
6. **Green, T.**, **Hilkhuysen, G.**, **Huckvale, M.**, **Rosen, S.**, **Brookes, M.**, **Moore, A.**, **Naylor, P.**, **Lightburn, L.**, & **Xue, W.** (2022). *Speech recognition with a hearing-aid processing scheme combining beamforming with mask-informed speech enhancement.* *Trends in Hearing*, **26**, 23312165211068629. doi:[10.1177/23312165211068629](https://doi.org/10.1177/23312165211068629). PMID: 34985356; PMCID: PMC8744079.  
7. **NIDCD** (2022). *Hearing Aids – Fact Sheet.* National Institute on Deafness and Other Communication Disorders (U.S. Department of Health & Human Services). [Link](https://www.nidcd.nih.gov/health/over-counter-hearing-aids)  
8. [**Microsoft DNS Challenge** – Deep Noise Suppression Dataset](https://github.com/microsoft/DNS-Challenge)  
9. [**Deep-Learning-Based Noise Reduction and Speech Enhancement System** (Open-Source Implementation)](https://github.com/ghnmqdtg/Deep-Learning-Based-Noise-Reduction-and-Speech-Enhancement-System/blob/main/README.md)  
10. [**Hearing Aid Processing Study (Trends in Hearing, 2022)** – Dataset Reference](https://drive.google.com/file/d/1eiRYFSOqBTPAJabmzAV5s0pQaqCE-OVg/view)



## 🧩 13. LICENSE
  This repository is distributed under the MIT License  for educational and research purposes.


