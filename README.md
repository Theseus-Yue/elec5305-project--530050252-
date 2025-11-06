# 🧠 Speech Enhancement for Hearing Aids in Traffic Noise Environments

**Author:** Yue (Theseus-Yue)  
**Unit:** ELEC5305 – Speech & Audio Signal Processing  
**Supervisor:** Dr. Craig Jin  
**Date:** November 2025  

---

## 🎯 1. Project Overview

This project develops a **low-complexity speech enhancement algorithm** for **hearing aids** operating in **traffic noise environments**, which are typically **non-stationary, broadband, and impulsive**.  
The objective is to improve speech intelligibility for hearing-aid users without using large neural networks that are infeasible for real-time embedded processors.

> **Research Question:**  
> *How can adaptive spectral subtraction and wavelet-based denoising improve speech intelligibility in non-stationary traffic noise under real-time constraints?*

---

## 🌆 2. Challenge Condition

| Environment | Noise Characteristics | Research Challenge | Design Goal |
|--------------|-----------------------|--------------------|--------------|
| Outdoor traffic street (vehicles, horns, buses) | Non-stationary, impulsive, wideband | Classical filters degrade under rapid noise variation | ≥8 dB SNR improvement within <20 ms latency |

---

## 📚 3. Literature Review Summary

| Category | Representative Works | Key Strength | Limitation | Relation to This Work |
|-----------|---------------------|---------------|-------------|-----------------------|
| **Spectral Subtraction / Wiener** | Boll (1979), Ephraim & Malah (1984) | Fast and simple | Musical noise; poor under non-stationary noise | Baseline implementation |
| **Statistical (MMSE-STSA)** | Gerkmann & Hendriks (2012) | Adaptive estimation | Needs stationary noise | Used for reference |
| **Wavelet Thresholding** | Donoho (1995), Kim (2010) | Good for transients | Threshold tuning difficult | Used in `noise reduction 1.m` |
| **Mask-based DNN models** | Xu et al. (2015), Green et al. (2022) | High quality enhancement | Too complex for hearing-aid DSP | Future extension |

🧩 *Key insight:*  
Green et al. (2022) found that DNN-based mask enhancement can even reduce intelligibility when combined with beamforming.  
Thus, this project emphasizes **adaptive classical methods**—efficient, interpretable, and low-latency.

---
## 🧠 4. Folder Structure

The project is organized as follows:

```plaintext
project_root/
│
├── Code/
│   ├── Analyze the original audio.m
│   ├── Spectral Subtraction and Wiener Filter.m
│   ├── adaptive_spectral_denoise.m
│   ├── noise reduction 1.m
│   └── evaluation_metrics.m
│
├── Data/
│   ├── household.WAV
│   ├── Vehicles.WAV
│   ├── Verbal_Human.WAV
│   └── TV.WAV
│
├── Report.md
├── README.md
├── hearing-aids.pdf
└── Speech recognition with a hearing-aid.pdf
```

## ⚙️ 5. File Descriptions

| File | Function | Description |
|------|-----------|-------------|
| **Analyze the original audio.m** | Data Analysis | Reads noisy `.WAV` (e.g., `household.WAV`), visualizes waveform and spectrogram |
| **Spectral Subtraction and Wiener Filter.m** | Baseline Algorithms | Implements two classical denoisers for comparison |
| **adaptive_spectral_denoise.m** | Proposed Method | Adaptive spectral subtraction with dynamic α based on frame-wise SNR |
| **noise reduction 1.m** | Experimental Wavelet Denoising | Demonstrates wavelet thresholding using Daubechies-8 (`db8`) |
| **evaluation_metrics.m** | Objective Evaluation | Calculates SNR, PESQ, STOI for all methods |
| **household.WAV**, **Vehicles.WAV**, **TV.WAV**, **Verbal_Human.WAV** | Test audio | Contain speech + traffic or background noise recordings used for evaluation |

---

## 🧩 6. Baseline vs. Yue’s Additions

| Module | Origin | Description | Yue’s Contribution |
|---------|---------|--------------|--------------------|
| **Spectral Subtraction & Wiener** | Baseline | Standard textbook algorithms | Added SNR computation, plots, and batch processing |
| **noise reduction 1.m** | New | Wavelet-based denoising for non-stationary noise | Implemented full pipeline |
| **adaptive_spectral_denoise.m** | New | Adaptive frame-wise spectral subtraction | Introduced automatic α and noise tracking |
| **evaluation_metrics.m** | New | Unified metrics for SNR, PESQ, STOI | Added for quantitative evaluation |


## ▶️ 7. How to Run

### **Requirements**
- MATLAB **R2023b** or later  
- **Signal Processing Toolbox**  
- **Audio Toolbox**

---

### **Run Steps**
```matlab
cd Code
1. Inspect original signal
run('Analyze the original audio.m');
2. Apply classical methods
run('Spectral Subtraction and Wiener Filter.m');
3. Test wavelet-based denoising (optional exploratory)
run('noise reduction 1.m');
4. Run adaptive spectral subtraction (main method)
run('adaptive_spectral_denoise.m');
5. Evaluate all results
run('evaluation_metrics.m');
```


## 📈 8. Results and Evaluation

| **Metric** | **Input** | **Spectral** | **Wiener** | **Adaptive** | **Wavelet** |
|-------------|------------|---------------|--------------|---------------|--------------|
| **SNR (dB)** | 0.15 | +4.8 | +7.2 | **+8.6** | +6.0 |
| **PESQ** | 1.98 | 2.10 | 2.65 | **2.91** | 2.45 |
| **STOI** | 0.62 | 0.70 | 0.77 | **0.79** | 0.74 |

### **Observations**

- **Spectral subtraction** removes noise but introduces *musical noise artifacts*.  
- **Wiener filtering** improves intelligibility but struggles with *non-stationary noise bursts*.  
- **Wavelet denoising** preserves speech formants but requires fine-tuned thresholds.  
- **Adaptive spectral subtraction** achieves the **best balance** between *speech clarity*, *artifact reduction*, and *computational efficiency*.  

## 🔊 9. EXAMPLE AUDIO DEMONSTRATIONS
All .WAV samples are stored in the /Data/ folder.
You can audition them directly in MATLAB or a media player.

 File Descriptions:
  - household.WAV .......... Original noisy sample
  - enhanced_household.wav .. Output of proposed adaptive method
  - Vehicles.WAV ............ Raw traffic noise
  - Verbal_Human.WAV ........ Clean speech sample used for synthesis
 --- Listen in MATLAB ---
soundsc(audioread('../Data/enhanced_household.wav'), 16000);


## 💬 10. DISCUSSION

The proposed adaptive spectral subtraction dynamically updates the suppression factor based on real-time noise estimates. → Achieves approximately +8 dB SNR improvement on real traffic recordings. Compared with Green et al. (2022), this approach avoids the latency and spatial-cue degradation found in DNN-based mask enhancement. Its low computational cost (frame-wise FFT operations only) makes it feasible for embedded hearing-aid processors.


## 🚀 11. FUTURE WORK
- Incorporate TinyDNN-style lightweight neural spectral masks.
- Extend to binaural adaptive processing (left/right channel coherence).
- Perform real-world testing with in-ear microphone recordings.


## 📚 12. References

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


