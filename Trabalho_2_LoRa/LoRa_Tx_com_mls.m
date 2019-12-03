clc;
clear all;
close all;
  
SF = 10;
Es = 2^SF;
k = 0:2^SF-1;
f = 500;
Fs = 8000;
Ts = 1; %Tempo de um símbolo apenas
t = [0:1/Fs:Ts-1/Fs];
symbols_Tx = [0 0 0 0 500 500 500 500 1023 1023 1023 1023];

W = zeros(2^SF,length(t));
for k = 0:2^SF-1
	W(k+1,:)=sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*t.*mod(linspace(k,k+2^SF,length(t)),2^SF));
end

Tx = [];
for symbol = symbols_Tx
    Tx = [Tx W(symbol+1,:)];
end

mls = mls(8,1);
Tx = [mls Tx mls];

t2 = [0:1/Fs:Ts*(length(Tx)-1)/Fs];
RF = exp(sqrt(-1).*2.*pi.*f.*t2);
Tx = Tx.*RF;

%sound(real(Tx),Fs);
audiowrite('gravacao_AGORAVAI.wav',real(Tx),Fs);


%% Rx

[Rx,Fs] = audioread('gravacao_AGORAVAI.wav');
Rx = reshape(Rx,1,[]);

t_Rx = [0:1/Fs:Ts*(length(Rx)-1)/Fs];
RF_Rx = exp(sqrt(-1).*2.*pi.*f.*t_Rx);
Rx = hilbert(Rx).*(1./RF_Rx);

correlation = xcorr(mls,Rx);
[value,index_mls] = findpeaks(abs(correlation),'Npeaks',2,'SortStr','descend');
%plot(real(correlation));
msg_size = abs(abs(index_mls(2)-index_mls(1))-length(mls));
msg_decoded = Rx(length(mls)+1:length(mls)+msg_size);

symbols_Rx = [];
for i = (1:Fs:length(msg_decoded))
     lora_block = msg_decoded(i:i-1+Fs);
     [a,b] = max(abs(sqrt(Es/2^SF)*lora_block*W'));
     symbols_Rx = [symbols_Rx b-1];
end
symbols_Rx

