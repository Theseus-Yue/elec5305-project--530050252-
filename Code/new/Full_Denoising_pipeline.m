% =====================================================================
% ELEC5305 Full Speech Denoising Pipeline
% Author: Yue (Theseus-Yue)
% Features:
%   ✔ Hybrid-MMSE denoising
%   ✔ Baseline: Noisy vs Enhanced vs Clean comparison
%   ✔ Three-way spectrogram comparison
%   ✔ Frame-wise SNR curves
%   ✔ Audio statistics table (RMS, ZCR, centroid, bandwidth)
% =====================================================================

clear; close all; clc;

%% ---------------------------------------------------------
% 0. Load clean + noise, synthesize noisy
% ---------------------------------------------------------
[clean, Fs] = audioread("clean.wav");  clean = clean(:,1);
[noise_test, Fs2] = audioread("household_appliance_test.wav"); noise_test = noise_test(:,1);
[noise_train, Fs3] = audioread("Household_Appliance_train.wav"); noise_train = noise_train(:,1);

if Fs2 ~= Fs, noise_test = resample(noise_test, Fs, Fs2); end
if Fs3 ~= Fs, noise_train = resample(noise_train, Fs, Fs3); end

L = min(length(clean), length(noise_test));
clean = clean(1:L);
noise_test = noise_test(1:L);

targetSNR = -5;
Ps = sum(clean.^2);
Pn = sum(noise_test.^2);
k = sqrt(Ps / (Pn * 10^(targetSNR/10)));

noisy = (clean + k*noise_test);
noisy = noisy / max(abs(noisy));
audiowrite("noisy_synthesized.wav", noisy, Fs);

fprintf("Synthesized noisy at %d dB\n", targetSNR);

%% ---------------------------------------------------------
% 1. Hybrid-MMSE Enhancement
% ---------------------------------------------------------
enhanced = hybrid_mmse(noisy, noise_train, Fs);

L2 = min([length(clean), length(enhanced)]);
clean = clean(1:L2); noisy = noisy(1:L2); enhanced = enhanced(1:L2);

%% ---------------------------------------------------------
% 2. Global SNR
% ---------------------------------------------------------
snr_in  = snr(clean, noisy - clean);
snr_out = snr(clean, enhanced - clean);

fprintf("\n===== Global SNR =====\n");
fprintf("Input  SNR : %.2f dB\n", snr_in);
fprintf("Output SNR : %.2f dB\n\n", snr_out);

%% ---------------------------------------------------------
% 3. Frame-wise SNR curve
% ---------------------------------------------------------
frameLen = 1024; hop = 512;
numFrames = floor((L2-frameLen)/hop)+1;
snr_frame_noisy = zeros(numFrames,1);
snr_frame_enh   = zeros(numFrames,1);

for i=1:numFrames
    idx = (i-1)*hop+1 : (i-1)*hop+frameLen;
    snr_frame_noisy(i) = snr(clean(idx), noisy(idx)-clean(idx));
    snr_frame_enh(i)   = snr(clean(idx), enhanced(idx)-clean(idx));
end

figure("Name","Frame-wise SNR");
plot(snr_frame_noisy,'r'); hold on;
plot(snr_frame_enh,'b');
legend("Noisy","Enhanced");
xlabel("Frame Index"); ylabel("Frame SNR (dB)");
title("Frame-wise SNR Comparison");

%% ---------------------------------------------------------
% 4. Waveform Comparison
% ---------------------------------------------------------
figure("Name","Waveform Comparison");
subplot(3,1,1); plot(noisy); title("Noisy");
subplot(3,1,2); plot(enhanced); title("Enhanced (Hybrid-MMSE)");
subplot(3,1,3); plot(clean); title("Clean");

%% ---------------------------------------------------------
% 5. Spectrogram Comparison (Noisy vs Enhanced vs Clean)
% ---------------------------------------------------------
figure("Name","Spectrogram Comparison");
subplot(3,1,1);
spectrogram(noisy, 256, 200, 512, Fs, "yaxis");
title("Noisy");

subplot(3,1,2);
spectrogram(enhanced, 256, 200, 512, Fs, "yaxis");
title("Enhanced (Hybrid-MMSE)");

subplot(3,1,3);
spectrogram(clean, 256, 200, 512, Fs, "yaxis");
title("Clean");

%% ---------------------------------------------------------
% 6. Audio Statistics Summary Table
% ---------------------------------------------------------
stats = @(sig) struct( ...
    'RMS', rms(sig), ...
    'Peak', max(abs(sig)), ...
    'ZCR', sum(abs(diff(sig>0)))/length(sig), ...
    'Centroid', spectral_centroid(sig, Fs), ...
    'Bandwidth', spectral_bandwidth(sig, Fs) ...
);

S_noisy = stats(noisy);
S_enh   = stats(enhanced);
S_clean = stats(clean);

fprintf("\n===== Audio Statistics =====\n");
T = struct2table(struct( ...
    'Metric', ["RMS";"Peak";"ZCR";"Centroid(Hz)";"Bandwidth(Hz)"], ...
    'Noisy', [S_noisy.RMS; S_noisy.Peak; S_noisy.ZCR; S_noisy.Centroid; S_noisy.Bandwidth], ...
    'Enhanced', [S_enh.RMS; S_enh.Peak; S_enh.ZCR; S_enh.Centroid; S_enh.Bandwidth], ...
    'Clean', [S_clean.RMS; S_clean.Peak; S_clean.ZCR; S_clean.Centroid; S_clean.Bandwidth] ...
));
disp(T)

%% ---------------------------------------------------------
% 7. Save enhanced audio
% ---------------------------------------------------------
% ==== ensure real-valued ====
enhanced = real(enhanced);
enhanced(~isfinite(enhanced)) = 0;

% ==== normalize ====
if max(abs(enhanced)) > 0
    enhanced = enhanced / max(abs(enhanced));
end

% ==== save ====
audiowrite("enhanced_output.wav", enhanced, Fs);


fprintf("\nDone! All results saved.\n");
fprintf("Play enhanced audio with soundsc(enhanced, Fs)\n");

% =====================================================================
% FUNCTION: Hybrid-MMSE
% =====================================================================
function y = hybrid_mmse(noisy, noise_train, Fs)
    nFFT = 1024; hop = 256;
    win = hann(nFFT,"periodic");
    [S,~,~]  = stft(noisy, Fs, "Window",win, ...
                   "OverlapLength",nFFT-hop, "FFTLength",nFFT);
    [Sn,~,~] = stft(noise_train, Fs, "Window",win, ...
                   "OverlapLength",nFFT-hop, "FFTLength",nFFT);
    Mag = abs(S); Phase = angle(S);
    noise_psd = mean(abs(Sn).^2,2);

    Mag_new = zeros(size(Mag));
    alpha = 0.96;  Gmin = 0.15;
    prev_xi = ones(size(noise_psd));

    for i=1:size(Mag,2)
        Y = Mag(:,i).^2;
        gamma = Y ./ (noise_psd+1e-12);

        if i==1
            xi = max(gamma-1,0);
        else
            xi = alpha*prev_xi + (1-alpha)*max(gamma-1,0);
        end
        xi = max(xi,1e-6);
        v = gamma.*xi./(1+xi);

        Ei = -exp(-v).*(log(v+eps)+0.5772);
        G = (xi./(1+xi)).*exp(0.5*Ei);
        G = max(min(real(G),1), Gmin);

        Mag_new(:,i) = G.*Mag(:,i);
        prev_xi = xi;
    end

    S_new = Mag_new .* exp(1i*Phase);
    y = istft(S_new, Fs, "Window",win, ...
              "OverlapLength",nFFT-hop, "FFTLength",nFFT);
    y = y / max(abs(y)+1e-8);
end

% =====================================================================
% Helper Functions
% =====================================================================

function c = spectral_centroid(x, Fs)
    X = abs(fft(x));
    f = linspace(0, Fs, length(X));
    c = sum(f'.*X) / sum(X);
end

function bw = spectral_bandwidth(x, Fs)
    X = abs(fft(x));
    f = linspace(0, Fs, length(X));
    c = sum(f'.*X) / sum(X);
    bw = sqrt(sum(((f'-c).^2).*X) / sum(X));
end
