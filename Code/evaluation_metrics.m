% ==========================================================
% File: evaluation_metrics.m  (Final Extended Version)
% Purpose: Compare denoising results (SNR + PESQ + STOI + Ratio Mask)
% ----------------------------------------------------------
% This script loads noisy, Wiener, Adaptive, and Mask-based signals
% and computes SNR, PESQ, and STOI metrics.
% ==========================================================

clear; close all; clc;

fprintf('--- Evaluating Speech Enhancement Performance ---\n');

%% -----------------------------------------------------------
% 0. Load audio files
% -----------------------------------------------------------
x_noisy = audioread('household.WAV');
x_wiener = audioread('household_wiener.wav');
x_adaptive = audioread('enhanced_household.wav');

%% Check if Ratio Mask file exists (if not, generate it here)
mask_file = 'enhanced_mask.wav';
if ~isfile(mask_file)
    fprintf('Ratio Mask result not found. Generating enhanced_mask.wav ...\n');

    % Run quick Ratio Mask enhancement
    x_in = mean(x_noisy,2);
    win = hann(1024,'periodic');
    [S, f, t] = stft(x_in, 44100, "Window", win, "OverlapLength", 512);

    noise_psd = mean(abs(S(:,1:5)).^2,2);
    mask = abs(S).^2 ./ (abs(S).^2 + repmat(noise_psd,1,size(S,2)));

    S_clean = S .* mask;
    y_mask = istft(S_clean, 44100, "Window", win, "OverlapLength", 512);

    audiowrite(mask_file, y_mask, 44100);
end

x_mask = audioread(mask_file);

%% Optional clean reference
if isfile('input_clean.wav')
    x_clean = audioread('input_clean.wav');
    fprintf('Using clean reference: input_clean.wav\n');
else
    warning('No clean reference available. Using Wiener output as pseudo-clean reference.');
    x_clean = x_wiener;
end

%% Make equal length
min_len = min([length(x_noisy), length(x_wiener), length(x_adaptive), length(x_mask), length(x_clean)]);
x_noisy = x_noisy(1:min_len);
x_wiener = x_wiener(1:min_len);
x_adaptive = x_adaptive(1:min_len);
x_mask = x_mask(1:min_len);
x_clean = x_clean(1:min_len);

%% -----------------------------------------------------------
% 1. Compute SNR
% -----------------------------------------------------------
snr_noisy = snr(x_clean, x_noisy - x_clean);
snr_wiener = snr(x_clean, x_wiener - x_clean);
snr_adaptive = snr(x_clean, x_adaptive - x_clean);
snr_mask = snr(x_clean, x_mask - x_clean);

fprintf('\nSNR (dB):\n');
fprintf('Noisy Input         : %.2f dB\n', snr_noisy);
fprintf('Wiener Filter       : %.2f dB\n', snr_wiener);
fprintf('Adaptive Subtraction: %.2f dB\n', snr_adaptive);
fprintf('Ratio Mask          : %.2f dB\n', snr_mask);
fprintf('----------------------------------------------\n');

%% -----------------------------------------------------------
% 2. PESQ & STOI (if toolbox available)
% -----------------------------------------------------------
fprintf('\nChecking PESQ / STOI availability...\n');

hasAudioTB = license('test','Audio_Toolbox');

if hasAudioTB
    fprintf('Audio Toolbox detected. Running PESQ/STOI...\n');

    Fs = 44100;

    % PESQ
    pesq_wien = pesq(x_clean, x_wiener, Fs);
    pesq_adapt = pesq(x_clean, x_adaptive, Fs);
    pesq_mask = pesq(x_clean, x_mask, Fs);

    % STOI
    stoi_wien = stoi(x_clean, x_wiener, Fs);
    stoi_adapt = stoi(x_clean, x_adaptive, Fs);
    stoi_mask = stoi(x_clean, x_mask, Fs);

    fprintf('\nPESQ Scores:\n');
    fprintf('Wiener Filter       : %.3f\n', pesq_wien);
    fprintf('Adaptive Subtraction: %.3f\n', pesq_adapt);
    fprintf('Ratio Mask          : %.3f\n', pesq_mask);

    fprintf('\nSTOI Scores:\n');
    fprintf('Wiener Filter       : %.3f\n', stoi_wien);
    fprintf('Adaptive Subtraction: %.3f\n', stoi_adapt);
    fprintf('Ratio Mask          : %.3f\n', stoi_mask);

else
    fprintf('Audio Toolbox NOT available — PESQ/STOI skipped.\n');
end

%% -----------------------------------------------------------
% 3. Visualization (SNR)
% -----------------------------------------------------------
figure('Name','SNR Comparison Across Methods');
bar([snr_noisy, snr_wiener, snr_adaptive, snr_mask]);
set(gca,'XTickLabel',{'Noisy','Wiener','Adaptive','Mask'});
ylabel('SNR (dB)');
title('SNR Comparison Across Denoising Methods');
grid on;

