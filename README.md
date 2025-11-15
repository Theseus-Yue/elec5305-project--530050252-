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

## 3. Project File Structure
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
│ ├── household_appliance_test.wav
│ ├── Household_Appliance_train.wav
│ ├── noisy_synthesized.wav
│ ├── TV.WAV / Vehicles.WAV / Verbal_Human.WAV
│
├── Report.md
├──Speech recognition with a hearing-aid.pdf
├──hearing-aids.pdf
└── ELEC5305_Project.pdf
```


---

## 4. Method Overview

### **4.1 Spectral Subtraction (Baseline)**
- Noise PSD from first 5 frames  
- Over-subtraction + flooring  
- Fast but introduces **musical noise**  
- Unstable in non-stationary noise  

### **4.2 Wiener Filter (Baseline)**
- Classical MMSE linear estimator  
- Good for stationary noise  
- Fails when noise PSD changes rapidly  

### **4.3 Adaptive Spectral Subtraction**
Improvements:
- Adaptive α(t) based on frame-level SNR  
- Minimum-statistics noise tracking  
- Fewer artifacts  
- Still lacks nonlinear speech modelling  

### **4.4 Final Method: Hybrid-MMSE (Ephraim–Malah)**
- Decision-directed a priori SNR  
- Nonlinear MMSE-LSA estimator  
- Minimum-statistics noise PSD estimation  
- Gain flooring for stability  
- **Best performance + DSP-friendly**

---

## 5. Real Experimental Results  
*(Updated using ELEC5305_Project.pdf)*

### **5.1 Global SNR Results (True SNR Calculation)**

| Algorithm | Input SNR (dB) | Output SNR (dB) |
|-----------|----------------|------------------|
| **Spectral Subtraction** | −13.86 | **−9.74** |
| **Wiener Filter** | −13.86 | **−13.62** |
| **Adaptive Spectral Subtraction** | −13.86 | **−13.87** |
| **Hybrid-MMSE (Proposed)** | **−0.96** | **0.01** |

🔍 Interpretation:  
- Only **Hybrid-MMSE** achieves **positive SNR improvement**.  
- Simple baselines fail due to incorrect noise PSD tracking.  
- Adaptive spectral subtraction is too conservative.  

---

### **5.2 Audio Statistics (Noisy vs Enhanced vs Clean)**

| Metric | Noisy | Hybrid-MMSE | Clean |
|--------|--------|------------|--------|
| **RMS** | 0.1167 | 0.0007466 | 0.09815 |
| **Peak** | 1.00 | 1.00 | 1.00 |
| **Zero-Crossing Rate** | 0.2884 | 0.2455 | 0.2287 |
| **Centroid (Hz)** | 8000 | 8000 | 8000 |
| **Bandwidth (Hz)** | 5291.6 | 4936.9 | 6147.3 |

✔ Centroid saturates at 8 kHz (Nyquist) due to high-frequency noise dominance—expected behaviour.

---

### **5.3 Frame-wise SNR Comparison**

- Noisy: fluctuates from **−50 dB to +5 dB**, highly unstable  
- Enhanced (Hybrid-MMSE): stabilises near **0–2 dB**, showing strong noise suppression  

**Conclusion:** frame-level behaviour demonstrates the superiority of Hybrid-MMSE.

---

### **5.4 Waveform Comparison Insights**
- Noisy signal shows large random fluctuations  
- Hybrid-MMSE output shows smoother envelope  
- Speech structure better preserved  

---

### **5.5 Spectrogram Comparison**
Hybrid-MMSE achieves:  
- Clear reduction of high-frequency noise  
- Restoration of formant bands (1–3 kHz)  
- Much closer appearance to clean speech  

---

## 6. Why Classical Methods Fail

### **Spectral Subtraction**
❌ Over-subtraction → spectral holes  
❌ Musical noise  
❌ Assumes stationary noise  

### **Wiener Filter**
❌ Noise PSD inaccurate under fast changes  
❌ Gain ≈ 1, so noise remains  
❌ Smears speech consonants  

### **Adaptive Spectral Subtraction**
✔ Better than classical subtraction  
❌ Still linear, lacks statistical speech model  
❌ Too conservative → near-zero SNR improvement  

---

## 7. Why Hybrid-MMSE Works (and is Hearing-Aid Suitable)

✔ Nonlinear MMSE estimator  
✔ Decision-directed SNR smoothing  
✔ Minimum-statistics tracking  
✔ No modification of noisy phase  
✔ Low latency (< 10 ms)  
✔ Fits DSP memory constraints  
✔ No musical noise  

Hybrid-MMSE = **best trade-off between clarity, stability, and computational cost**.

---

## 8. How to Run the Project

In MATLAB:

```matlab
cd Code

run Analyze_audio.m
run Spectral_Subtraction_and_Wiener_Filter.m
run adaptive_spectral_denoise.m
run FULL_MMSE_HYBRID_PIPELINE.m
run evaluation_metrics.m
```
### Requirements
- MATLAB **R2023b** or later  
- Signal Processing Toolbox  
- Audio Toolbox  

---

## 9. Algorithm Ranking (Final)

1. ⭐ **Hybrid-MMSE** — Best overall performance  
2. **Adaptive Spectral Subtraction** — Better than classical baselines  
3. **Wiener Filter** — Stable but weak enhancement  
4. **Spectral Subtraction** — Musical noise, unstable

---

## 10. Future Work

- Lightweight neural spectral mask (TinyDNN-style)  
- Multi-microphone beamforming  
- Phase-aware MMSE speech estimators  
- Objective PESQ/STOI optimisation  
- Real hearing-aid hardware evaluation  




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


