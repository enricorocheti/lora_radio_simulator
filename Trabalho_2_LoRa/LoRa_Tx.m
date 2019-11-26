clc;
clear all;
close all;
  
Es = 1;
SF = 8;
symbols = [10 40 15];

k = 0:2^SF-1;
W = zeros(2^SF);
for n = 0:2^SF-1
	W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF); % bases ortonormais que caracterizam o espaço de sinais LoRa
end

Tx = [];
for symbol = symbols
    Tx1 = sqrt(Es/2^SF).*W(symbol,:);
    Tx = [Tx Tx1];
end

figure(1)
plot(real(Tx))
%Tx = upsample(Tx,50);
%B = 1e3;
%T = 1/B;
%t = 0:T:(T*2^SF);

Fs = 8000;              % taxa de amostragem
T = 0.1;                % período 
t = 0:1/Fs:T-1/Fs;      % vetor tempo
