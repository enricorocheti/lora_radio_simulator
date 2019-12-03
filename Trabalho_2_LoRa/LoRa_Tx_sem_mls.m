clc;
clear all;
close all;
  
SF = 10;
Es = 2^SF;
symbols_Tx = [0 100 999];
k = 0:2^SF-1;

Fs=8000;
Ts=1; %Tempo de um símbolo apenas
t=[0:1/Fs:Ts-1/Fs];

%B = 500;
%T = 1/B;
%T = 0.1;

W = zeros(2^SF,length(t));
for k = 0:2^SF-1
	W(k+1,:)=sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*t.*mod(linspace(k,k+2^SF,length(t)),2^SF));
end

Tx = [];
for symbol = symbols_Tx
    Tx = [Tx W(symbol+1,:)];
end


t2 = [0:1/Fs:Ts*length(symbols_Tx)-1/Fs];
RF = exp(sqrt(-1).*2.*pi.*600.*t2);
Tx = Tx.*RF;

%sound(real(Tx),Fs);
mls = mls(6,1);
%Tx = [mls Tx mls];
audiowrite('gravacao3.wav',real(Tx),Fs);



%% Rx

[Rx,Fs] = audioread('gravacao3.wav');
Rx = reshape(Rx,1,[]);
Rx = hilbert(Rx).*(1./RF);

symbols_Rx = [];
for i = (1:Fs:length(Rx))
    lora_block = Rx(i:i-1+Fs);
    [a,b] = max(abs(sqrt(Es/2^SF)*lora_block*W'));
    symbols_Rx = [symbols_Rx b-1];
end
symbols_Rx

figure(1)
plot(real(Tx(23500:end)))
hold on
plot(real(Rx(23500:end)))

% plot(real(Rx))
figure(4)
plot(imag(Tx))
hold on
plot(imag(Rx))


