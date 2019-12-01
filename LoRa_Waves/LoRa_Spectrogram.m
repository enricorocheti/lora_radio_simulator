clc
clear all
close all

B = 2*125e3;
T = 1/B;
Fsample = 2000;

%% SF = 10

SF = 10;
Ts = T*2^SF;
t = 0:Ts/Fsample:Ts;
y = chirp(t,0,Ts,B);

figure(1)
spectrogram(y,128,120,128,B,'onesided','yaxis');

%% SF variando

SF = 7:10
signal = [];
signal2 = [];
for Tsym = T.*2.^SF
    t = 0:Ts/Fsample:Ts/2^(10-log2(Tsym/T));
    signal = [signal chirp(t,0,Tsym,B)];
    signal2 = [signal chirp(t,-B/2,Tsym,B/2)];
end

figure(2)
spectrogram(signal,kaiser(128,18),120,128,B,'onesided','yaxis');

NFFT = 128;
f_vec = [-floor(NFFT/2) : ceil(NFFT/2)-1] * B/NFFT;
figure(4)
spectrogram(signal2,128,120,f_vec,B,'yaxis');

%% Símbolos

SF = 10;
Tsym = T.*2.^SF;
t = 0:Tsym/Fsample:Tsym;
t = t(1:end-1);
    
wk = [];
for k = [250 600 900 400]
    f_offset = k*B/(2*2^SF)
    Tsym_1 = t(round(length(t)-length(t)*k/2^SF));
    Tsym_2 = t(round(length(t)*k/2^SF));
    t1 = t(1:length(t)-length(t)*k/2^SF);
    t2 = t(1:length(t)*k/2^SF);
    wk = [wk chirp(t1,2*f_offset,Tsym_1,B)];
    wk = [wk chirp(t2,0,Tsym_2,2*f_offset)];
end

figure(3)
spectrogram(wk,kaiser(128,18),120,128,B,'onesided','yaxis');