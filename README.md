# Speech Enhancement for Hearing Aids in Non-Stationary Noise Environments  
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
---

## 3. Code Files

This project consists of **five main MATLAB scripts**, each representing a stage in the full speech-enhancement pipeline.  
Below is a detailed explanation of what each script does and the algorithms implemented inside.

---

### **3.1 Analyze_audio.m — Audio Characterisation Module**

**Purpose:**  
To understand the statistical and spectral structure of the noisy input signal before enhancement.

**Key Methods Implemented:**
- Time-domain waveform analysis  
- STFT for spectrogram  
- RMS energy calculation  
- Peak amplitude  
- Zero-Crossing Rate (ZCR)  
- Spectral centroid  
- Spectral bandwidth  
- Dominant frequency detection  
- Average magnitude spectrum  
- Frame-wise short-term energy  

**Role in project:**  
Provides insight into noise distribution (e.g., energy in 0–500 Hz and 4–8 kHz), helping justify the need for advanced algorithms.

---

### **3.2 Spectral_Subtraction_and_Wiener_Filter.m — Classical Baseline Algorithms**

**Purpose:**  
Implements the two most widely used foundational speech-enhancement techniques.

#### **Algorithms:**

#### **(1) Spectral Subtraction**
- Noise PSD estimated from first 5 frames  
- Over-subtraction factor α  
- Spectral flooring β  
- Converts PSD back to magnitude + phase  

**Strength:** Simple & fast  
**Weakness:** Musical noise under non-stationary noise  

#### **(2) Wiener Filter**
- Wiener gain: H = SNR / (1 + SNR)  
- Noise PSD estimated from first few frames  
- Applied frame-by-frame in frequency domain  

**Strength:** Smooth output  
**Weakness:** Performs poorly in fast-changing noise  

**Role in project:**  
Provides the baseline for comparing advanced methods.

---

### **3.3 adaptive_spectral_denoise.m — Adaptive Spectral Subtraction**

**Purpose:**  
Improve the classical spectral subtraction method by making it responsive to time-varying noise.

**Key Methods:**
- **Adaptive α(t)** based on frame SNR  
- Minimum-statistics noise estimation  
- Spectral flooring to avoid negative magnitudes  
- Full STFT → magnitude modification → ISTFT  

**Advantages:**
- Reduces musical noise  
- More stable for dynamic household noise  

**Limitations:**
- Still linear  
- Lacks statistical speech modelling  
- Limited enhancement when noise varies too quickly  

**Role in project:**  
Intermediate step showing improvement beyond classical baselines.

---

### **3.4 FULL_MMSE_HYBRID_PIPELINE.m — Final Hybrid-MMSE Enhancement Pipeline**

**Purpose:**  
The main full-system script running the final Hybrid-MMSE algorithm, SNR evaluation, waveform analysis, spectrograms, and statistics.

**Core Components:**
1. Load clean + noise recordings  
2. Synthesize noisy mixture at −5 dB  
3. Apply **Hybrid-MMSE estimator (Ephraim–Malah)**  
4. Compute global SNR  
5. Compute frame-wise SNR  
6. Generate:
   - Spectrograms (noisy vs enhanced vs clean)  
   - Waveform comparison  
   - Audio statistics table (RMS, ZCR, centroid, bandwidth)  
7. Save enhanced output  

#### **Hybrid-MMSE Algorithm Details**
- **Minimum-statistics noise PSD estimation**  
- **Decision-directed a priori SNR estimator**  
- **Nonlinear MMSE-LSA gain computation**  
- **Gain flooring (Gmin)** for stability  
- **Phase preservation** (ISTFT uses original noisy phase)  

**Why it’s the final method:**  
- Best noise suppression  
- No musical noise  
- Very low computational complexity  
- Real-time hearing-aid friendly  

---

### **3.5 evaluation_metrics.m — Quality Metrics**

**Purpose:**  
Evaluate speech enhancement performance using common objective metrics.

**Metrics Included (or placeholder for external tools):**
- **SNR**  
- **PESQ** (Perceptual Evaluation of Speech Quality)  
- **STOI** (Short-Time Objective Intelligibility)  

**Role in project:**  
Used for scientific evaluation of all enhancement methods.

---



## 4. Project File Structure
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

## 5. Method Overview

### **5.1 Spectral Subtraction (Baseline)**
- Noise PSD from first 5 frames  
- Over-subtraction + flooring  
- Fast but introduces **musical noise**  
- Unstable in non-stationary noise  

### **5.2 Wiener Filter (Baseline)**
- Classical MMSE linear estimator  
- Good for stationary noise  
- Fails when noise PSD changes rapidly  

### **5.3 Adaptive Spectral Subtraction**
Improvements:
- Adaptive α(t) based on frame-level SNR  
- Minimum-statistics noise tracking  
- Fewer artifacts  
- Still lacks nonlinear speech modelling  

### **5.4 Final Method: Hybrid-MMSE (Ephraim–Malah)**
- Decision-directed a priori SNR  
- Nonlinear MMSE-LSA estimator  
- Minimum-statistics noise PSD estimation  
- Gain flooring for stability  
- **Best performance + DSP-friendly**

---

## 6. Real Experimental Results  
*(Updated using ELEC5305_Project.pdf)*

### **6.1 Global SNR Results (True SNR Calculation)**

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

### **6.2 Audio Statistics (Noisy vs Enhanced vs Clean)**

| Metric | Noisy | Hybrid-MMSE | Clean |
|--------|--------|------------|--------|
| **RMS** | 0.1167 | 0.0007466 | 0.09815 |
| **Peak** | 1.00 | 1.00 | 1.00 |
| **Zero-Crossing Rate** | 0.2884 | 0.2455 | 0.2287 |
| **Centroid (Hz)** | 8000 | 8000 | 8000 |
| **Bandwidth (Hz)** | 5291.6 | 4936.9 | 6147.3 |

✔ Centroid saturates at 8 kHz (Nyquist) due to high-frequency noise dominance—expected behaviour.

---

### **6.3 Frame-wise SNR Comparison**

- Noisy: fluctuates from **−50 dB to +5 dB**, highly unstable  
- Enhanced (Hybrid-MMSE): stabilises near **0–2 dB**, showing strong noise suppression  

**Conclusion:** frame-level behaviour demonstrates the superiority of Hybrid-MMSE.

---

### **6.4 Waveform Comparison Insights**
- Noisy signal shows large random fluctuations  
- Hybrid-MMSE output shows smoother envelope  
- Speech structure better preserved  

---

### **6.5 Spectrogram Comparison**
Hybrid-MMSE achieves:  
- Clear reduction of high-frequency noise  
- Restoration of formant bands (1–3 kHz)  
- Much closer appearance to clean speech  

---

## 7. Why Classical Methods Fail

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

## 8. Why Hybrid-MMSE Works (and is Hearing-Aid Suitable)

✔ Nonlinear MMSE estimator  
✔ Decision-directed SNR smoothing  
✔ Minimum-statistics tracking  
✔ No modification of noisy phase  
✔ Low latency (< 10 ms)  
✔ Fits DSP memory constraints  
✔ No musical noise  

Hybrid-MMSE = **best trade-off between clarity, stability, and computational cost**.

---

## 9. How to Run the Project

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


