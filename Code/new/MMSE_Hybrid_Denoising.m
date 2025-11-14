% ==========================================================
% ELEC5305 — Denoising Demo (FINAL FIXED VERSION)
% Fully runnable – expint removed, clipping removed
% ==========================================================

clear; close all; clc;

%% =========================================================
% 1. Load clean and noise files
% =========================================================
[clean, Fs1] = audioread("clean.wav");      clean = clean(:,1);
[noise_test, Fs2] = audioread("household_appliance_test.wav");  noise_test = noise_test(:,1);
[noise_train, Fs3] = audioread("Household_Appliance_train.wav"); noise_train = noise_train(:,1);

Fs = Fs1;
if Fs2 ~= Fs, noise_test = resample(noise_test, Fs, Fs2); end
if Fs3 ~= Fs, noise_train = resample(noise_train, Fs, Fs3); end

L = min(length(clean), length(noise_test));
clean = clean(1:L);
noise_test = noise_test(1:L);

fprintf("Loaded clean + noise: %.2f sec, Fs = %d Hz\n", L/Fs, Fs);

%% =========================================================
% 2. Synthesize noisy at target SNR
% =========================================================
targetSNR = -5;

Ps = sum(clean.^2);
Pn = sum(noise_test.^2);
k = sqrt(Ps / (Pn * 10^(targetSNR/10)));

noise_scaled = k * noise_test;
noisy = clean + noise_scaled;

% Avoid clipping
noisy = noisy / max(abs(noisy)+1e-8);

audiowrite("noisy_synthesized.wav", noisy, Fs);

fprintf("\nSynthesized noisy at %d dB SNR\n", targetSNR);

%% =========================================================
% 3. TRUE Input SNR
% =========================================================
snr_input = snr(clean, noisy - clean);
fprintf("Input SNR : %.2f dB\n", snr_input);

%% =========================================================
% 4. Enhancement (Hybrid-MMSE)
% =========================================================
enhanced = hybrid_mmse(noisy, noise_train, Fs);

L2 = min([length(clean), length(enhanced)]);
clean = clean(1:L2);
noisy = noisy(1:L2);
enhanced = enhanced(1:L2);

%% =========================================================
% 5. TRUE Output SNR
% =========================================================
snr_output = snr(clean, enhanced - clean);

fprintf("\n===== TRUE OUTPUT SNR =====\n");
fprintf("Output SNR : %.2f dB\n", snr_output);
fprintf("Improvement: %.2f dB\n", snr_output - snr_input);

audiowrite("enhanced_output.wav", enhanced, Fs);

%% =========================================================
% 6. Waveform plots
% =========================================================
t = (0:L2-1)/Fs;

figure;
subplot(3,1,1); plot(t, clean); title("Clean Speech");
subplot(3,1,2); plot(t, noisy); title("Synthesized Noisy");
subplot(3,1,3); plot(t, enhanced); title("Enhanced (Hybrid-MMSE)");

%% =========================================================
% 7. Spectrogram comparison
% =========================================================
figure;
subplot(3,1,1); spectrogram(noisy,256,200,512,Fs,'yaxis'); title("Noisy");
subplot(3,1,2); spectrogram(enhanced,256,200,512,Fs,'yaxis'); title("Enhanced");
subplot(3,1,3); spectrogram(clean,256,200,512,Fs,'yaxis'); title("Clean");

%% =========================================================
% === Hybrid-MMSE Function (NO expint needed!) ============
% =========================================================
function y = hybrid_mmse(noisy, noise_train, Fs)

    nFFT = 1024; hop = 256; win = hann(nFFT,"periodic");

    [S,~,~]  = stft(noisy, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength", nFFT);
    [Sn,~,~] = stft(noise_train, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength", nFFT);

    Mag = abs(S);
    Phase = angle(S);

    noise_psd = mean(abs(Sn).^2, 2);

    Mag_new = zeros(size(Mag));
    Gmin = 0.1;

    for i = 1:size(Mag,2)

        Y = Mag(:,i).^2;

        gamma = Y ./ (noise_psd + 1e-12);
        xi = max(gamma - 1, 0);     % decision-directed approx

        % --- Replace expint(v) using stable numerical approximation ----
        v = gamma .* xi ./ (1 + xi);
        Ei = -exp(-v) .* (log(v + eps) + 0.5772156649);  % Euler's constant
        G = (xi./(1+xi)) .* exp(0.5 * Ei);

        % Stabilize gain
        G = real(G);
        G = max(min(G,1), Gmin);

        Mag_new(:,i) = G .* Mag(:,i);
    end

    S_new = Mag_new .* exp(1i*Phase);

    y = istft(S_new, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength",nFFT);
    y = real(y(:));
    y = y / max(abs(y)+1e-8);
end
