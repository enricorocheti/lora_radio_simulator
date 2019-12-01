clc;
clear all;
close all;
  
SF = 10;
Es = 2^SF;
k = 0:2^SF-1;
f = 600;
Fs = 8000;
Ts = 0.1; % Tempo de um símbolo apenas
t = [0:1/Fs:Ts-1/Fs];
symbols_Tx = [50 100 150 200];

W = zeros(2^SF,length(t));
for k = 0:2^SF-1
	W(k+1,:)=sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*t.*mod(linspace(k,k+2^SF,length(t)),2^SF));
end

Tx = [];
for symbol = symbols_Tx
    Tx = [Tx W(symbol+1,:)];
end

mls_ = repelem(mls(8,1),5);
Tx_AUX = Tx;
Tx = [mls_ Tx mls_];

t2 = [0:1/Fs:(length(Tx)-1)/Fs];
RF = exp(sqrt(-1).*2.*pi.*f.*t2);
Tx = Tx.*RF;

sound(real(Tx),Fs);
audiowrite('gravacao_AGORAVAI.wav',real(Tx),Fs);