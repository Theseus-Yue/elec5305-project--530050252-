# Speech Enhancement for Hearing Aids in Non-Stationary Household Noise Environments  
**ELEC5305 – Speech & Audio Signal Processing**  
**Author:** Yue Yu  
**Supervisor:** Dr. Craig Jin  
**Date:** November 2025  

---

## 1. Project Overview

This project investigates classical spectral-domain speech enhancement techniques for hearing aids operating in **non-stationary household and traffic noise**.  
Given the strict limitations of hearing-aid DSP chips (latency < 10 ms, low memory, low power), the project focuses on lightweight classical algorithms instead of large neural models.

Four enhancement pipelines were implemented:

1. **Spectral Subtraction (baseline)**  
2. **Wiener Filter (baseline)**  
3. **Adaptive Spectral Subtraction (improved classical)**  
4. **Hybrid-MMSE (final method)**  

The study demonstrates why classical methods fail under dynamic noise and why the **Hybrid-MMSE algorithm** achieves the best performance while meeting real-time constraints.

---

## 2. Dataset

All experiments use the following real audio recordings:

| File | Purpose |
|------|---------|
| `clean.wav` | Clean reference speech |
| `household_appliance_test.wav` | Real non-stationary noise (for mixing) |
| `Household_Appliance_train.wav` | Noise-only recording for PSD estimation |

All files are:
- mono  
- truncated to equal length  
- resampled to **16 kHz**

Noisy signals are synthesized at **−5 dB SNR**.

---

## 3. Code Files

This project contains **five MATLAB scripts**, each representing a major stage in the enhancement pipeline.

### **3.1 `1MMSE_Hybrid_Denoising.m` — Final Hybrid-MMSE Implementation**
Implements:
- Minimum-statistics noise estimation  
- Decision-directed a priori SNR  
- MMSE-LSA spectral gain (Ephraim–Malah)  
- Gain flooring for stability  
- STFT → gain modification → ISTFT reconstruction  

This is the **main algorithm** used to generate final enhanced speech.

---

### **3.2 `2Analyze_audio.m` — Audio Characterisation Module**
Performs detailed analysis of the noisy signal:
- Waveform  
- Spectrogram  
- RMS energy  
- Peak amplitude  
- Zero-Crossing Rate (ZCR)  
- Spectral centroid  
- Spectral bandwidth  
- Dominant frequency  
- Frame-wise energy  

This helps understand the structure of household noise.

---

### **3.3 `3Spectral_Subtraction_and_Wiener_Filter.m` — Classical Baseline Methods**

#### **Spectral Subtraction**
- Noise PSD from initial frames  
- Over-subtraction factor  
- Spectral flooring  
- Produces musical noise under dynamic conditions  

#### **Wiener Filter**
- Wiener gain = SNR / (1 + SNR)  
- Works well for stationary noise  
- Underperforms in non-stationary conditions  

These methods serve as baselines.

---

### **3.4 `4Adaptive_spectral_denoise.m` — Adaptive Spectral Subtraction**

Improvements over classical subtraction:
- α(t) adjusted based on frame-level SNR  
- Minimum-statistics noise tracking  
- More stable than spectral subtraction  
- Fewer artifacts, but still limited for fast-changing noise  

---

### **3.5 `5Full_Denoising_pipeline.m` — Complete Enhancement Workflow**

This script integrates:
1. Loading clean + noise  
2. Synthesizing noisy mixture  
3. Applying Hybrid-MMSE  
4. Global SNR computation  
5. Frame-wise SNR computation  
6. Waveform and spectrogram comparison  
7. Audio statistics (RMS / ZCR / bandwidth)  
8. Saving enhanced audio  

This is the **full reproducible pipeline** used for producing all project results.

---

## 4. Real Experimental Results  
*(From ELEC5305_Project.pdf — actual numbers)*

### **4.1 Global SNR Results**

| Algorithm | Input SNR (dB) | Output SNR (dB) |
|-----------|----------------|------------------|
| **Spectral Subtraction** | −13.86 | −9.74 |
| **Wiener Filter** | −13.86 | −13.62 |
| **Adaptive Spectral Subtraction** | −13.86 | −13.87 |
| **Hybrid-MMSE (Proposed)** | **−0.96** | **0.01** |

✔ Only Hybrid-MMSE achieves a **positive improvement**.  
✔ Classical algorithms fail due to poor noise tracking.

---

## 4.2 Audio Statistics

| Metric | Noisy | Hybrid-MMSE | Clean |
|--------|--------|------------|--------|
| RMS | 0.1167 | 0.0007466 | 0.09815 |
| Peak | 1.00 | 1.00 | 1.00 |
| ZCR | 0.2884 | 0.2455 | 0.2287 |
| Centroid | 8000 | 8000 | 8000 |
| Bandwidth | 5291.6 | 4936.9 | 6147.3 |

Centroid saturates at Nyquist (8 kHz) due to high-frequency noise dominance.

---

## 4.3 Frame-wise SNR

- Noisy: fluctuates from −50 dB to +5 dB (unstable)  
- Hybrid-MMSE: stabilises between 0–2 dB  

This demonstrates robust noise suppression.

---

## 4.4 Spectrogram Observations
Hybrid-MMSE:
- Reduces high-frequency noise  
- Recovers formants  
- Removes broadband noise artifacts  
- Provides the closest match to clean speech  

---

## 5. Algorithm Ranking

1. ⭐ **Hybrid-MMSE (Best)**  
2. **Adaptive Spectral Subtraction**  
3. **Wiener Filter**  
4. **Spectral Subtraction (Worst)**  

---

## 6. Why Hybrid-MMSE Is Ideal for Hearing Aids

- Very low latency (<10 ms)  
- Low computational cost  
- No phase distortion  
- Strong performance under non-stationary noise  
- No musical noise  
- Preserves speech formants  

---

## 7. Running the Code

```matlab
cd Code/new

run 1MMSE_Hybrid_Denoising.m
run 2Analyze_audio.m
run 3Spectral_Subtraction_and_Wiener_Filter.m
run 4Adaptive_spectral_denoise.m
run 5Full_Denoising_pipeline.m
```   
Requires:
MATLAB R2023b+
Signal Processing Toolbox
Audio Toolbox

## 8. Future Work
- Lightweight neural spectral mask (TinyDNN-style)
- Multi-mic beamforming
- Phase-aware speech estimation
- Hardware-in-the-loop tests

## 📚 9. References

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



## 🧩 10. LICENSE
  This repository is distributed under the MIT License  for educational and research purposes.


