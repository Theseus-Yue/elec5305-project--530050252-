% ==========================================================
% ELEC5305 — Denoising Demo (FINAL, MATCHES YOUR FILES)
%
% clean.wav                     → pure speech
% household_appliance_test.wav  → noise for mixing noisy
% Household_Appliance_train.wav → noise for estimating PSD
%
% Outputs:
%   noisy_synthesized.wav
%   enhanced_output.wav
%   waveform and spectrogram figures
% ==========================================================

clear; close all; clc;

%% =========================================================
% 1. Load clean and noise files
% =========================================================
[clean, Fs1] = audioread("clean.wav");
clean = clean(:,1);

[noise_test, Fs2] = audioread("household_appliance_test.wav");   % 用来合成 noisy
noise_test = noise_test(:,1);

[noise_train, Fs3] = audioread("Household_Appliance_train.wav"); % 用来估计噪声 PSD
noise_train = noise_train(:,1);

% unify sampling rate (use clean.wav rate)
Fs = Fs1;
if Fs2 ~= Fs
    noise_test = resample(noise_test, Fs, Fs2);
end
if Fs3 ~= Fs
    noise_train = resample(noise_train, Fs, Fs3);
end

% Align lengths
L = min(length(clean), length(noise_test));
clean = clean(1:L);
noise_test = noise_test(1:L);

fprintf("Loaded clean + noise: %.2f sec, Fs = %d Hz\n", L/Fs);

%% =========================================================
% 2. Synthesize noisy at target SNR
% =========================================================
targetSNR = -5;  % change this to -10, -5, 0, 5 for demo

Ps = sum(clean.^2);
Pn = sum(noise_test.^2);
k = sqrt(Ps / (Pn * 10^(targetSNR/10)));

noise_scaled = k * noise_test;
noisy = clean + noise_scaled;

audiowrite("noisy_synthesized.wav", noisy, Fs);

fprintf("\nSynthesized noisy at %d dB\n", targetSNR);

%% =========================================================
% 3. Compute TRUE Input SNR
% =========================================================
noise_in = noisy - clean;
snr_input = snr(clean, noise_in);

fprintf("Input SNR : %.2f dB\n", snr_input);

%% =========================================================
% 4. Run enhancement (Hybrid-MMSE)
% =========================================================
enhanced = hybrid_mmse(noisy, noise_train, Fs);

% Align
L2 = min([length(clean), length(enhanced)]);
clean = clean(1:L2);
noisy = noisy(1:L2);
enhanced = enhanced(1:L2);

%% =========================================================
% 5. TRUE Output SNR
% =========================================================
noise_out = enhanced - clean;
snr_output = snr(clean, noise_out);

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
subplot(3,1,2); plot(t, noisy); title("Synthesized Noisy Speech");
subplot(3,1,3); plot(t, enhanced); title("Enhanced (Hybrid-MMSE)");

%% =========================================================
% 7. Spectrogram comparison (BEST VISUAL RESULT)
% =========================================================
figure;
subplot(3,1,1); spectrogram(noisy, 256, 200, 512, Fs, 'yaxis'); title("Noisy Spectrogram");
subplot(3,1,2); spectrogram(enhanced, 256, 200, 512, Fs, 'yaxis'); title("Enhanced Spectrogram");
subplot(3,1,3); spectrogram(clean, 256, 200, 512, Fs, 'yaxis'); title("Clean Spectrogram");


%% =========================================================
% === Local Function: Hybrid-MMSE Enhancement ===============
% =========================================================
function y = hybrid_mmse(noisy, noise_train, Fs)

    nFFT = 1024; hop = 256; win = hann(nFFT,"periodic");

    [S,~,~]  = stft(noisy, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength", nFFT);
    [Sn,~,~] = stft(noise_train, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength", nFFT);

    Mag = abs(S);
    Phase = angle(S);

    noise_psd = mean(abs(Sn).^2, 2);  % PSD from train noise

    Mag_new = zeros(size(Mag));
    Gmin = 0.1;

    for i = 1:size(Mag,2)
        Y = Mag(:,i).^2;

        gamma = Y ./ (noise_psd + 1e-12);
        gamma = max(gamma, 1e-6);

        xi = 0.9*gamma + 0.1*max(gamma-1, 0);
        xi = max(xi, 1e-6);

        v = gamma .* xi ./ (1+xi);
        G = (xi./(1+xi)) .* exp(0.5*expint(v));

        G = max(min(real(G),1), Gmin);

        Mag_new(:,i) = G .* Mag(:,i);
    end

    S_new = Mag_new .* exp(1i*Phase);

    y = istft(S_new, Fs, "Window",win, "OverlapLength",nFFT-hop, "FFTLength",nFFT);
    y = real(y(:));
    y = y / max(abs(y)+1e-8);
end
