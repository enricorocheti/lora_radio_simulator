clc;
clear all;
close all;
  
SF = 12;
Es = 2^SF;
symbols_Tx = [10 50 100];
k = 0:2^SF-1;

B = 500;
%T = 1/B;
T = 0.1;
Fs = 8000;

Ts = (2^SF)*T;
fk = B.*k/2^SF;

W = zeros(2^SF);
for n = 0:2^SF-1
	W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF); % bases ortonormais que caracterizam o espaço de sinais LoRa
end

Tx = [];
for symbol = symbols_Tx
    Tx1 = sqrt(Es/2^SF).*W(symbol,:);
    %plot(fft(Tx1));
    Tx = [Tx Tx1];
end

figure(1)
plot(real(Tx))
hold on
figure(2)
plot(imag(Tx))
hold on

Fsample = 100;
mls = mls(6,1);
Tx = [mls Tx mls];
%Tx = upsample(Tx, Fsample);

t = 0:1/Fs:length(Tx)/Fs-1/Fs;
f = 400;
RF = exp(sqrt(-1).*2.*pi.*f.*t);

Tx_RF = Tx.*RF;

%figure(2)
%plot(real(Tx_RF))

%sound(real(Tx_RF))
audiowrite('gravacao.wav',Tx_RF,Fs);

%% Rx

[Rx_RF,Fs] = audioread('gravacao.wav');
sound(Rx_RF)
Rx_RF = reshape(Rx_RF,1,[]);
%Rx = Rx_RF.*RF.*exp(-1);
%Rx = kron(Rx_RF,1./RF);
Rx = hilbert(Rx_RF).*(1./RF);

%figure(3)
%yFILT1 = conv(Rx_RF,(1./RF));
%yFILT1 = conv(abs(yFILT1),ones(1,round(length(1./RF)/2)));
%yFILT1 = yFILT1/norm(yFILT1);
%plot(real(yFILT1));

%Rx_RF = [zeros(1,1000) Tx_RF zeros(1,1000)];
%Rx_RF = Tx_RF;
%Rx = Rx_RF.*RF;

% figure(3)
% plot(real(Tx))
% hold on
% plot(real(Rx))
% figure(4)
% plot(imag(Tx))
% hold on
% plot(imag(Rx))

%mlsUpSample = upsample(mls, Fsample);
%correlation = xcorr(mlsUpSample,Rx);
correlation = xcorr(mls,Rx);
[value,index_mls] = findpeaks(abs(correlation),'Npeaks',2,'SortStr','descend');
figure(3)
plot(real(correlation));

msg_size = abs(abs(index_mls(2)-index_mls(1))-length(mls));
msg_decoded = Rx(length(mls)+1:length(mls)+msg_size);
%msg_decoded = msg_decoded(1:Fsample:end);

figure(1)
plot(real(Rx),'--');
figure(2)
plot(imag(Rx),'--');

symbols_Rx = [];
for i = (1:2^SF:length(msg_decoded))
    lora_block = msg_decoded(i:i-1+2^SF);
    [a,b] = max(abs(sqrt(Es/2^SF)*lora_block*W'));
    symbols_Rx = [symbols_Rx b];
end
symbols_Rx


