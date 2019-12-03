clc;
clear all;
SF=10;
Es=2^SF;
Fs=8000;

T = 1/1e2;
Ts = T*2^SF;
Ts=1; %Tempo de um símbolo apenas
t=[0:1/Fs:Ts];

%Criacao da Base W
W=zeros(2^SF,length(t));
for k=0:2^SF-1
    W(k+1,:)=sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*t.*mod(linspace(k,k+2^SF,length(t)),2^SF));
end

%% Tx
Tx = [];
for indice = [100]
    Tx=[Tx W(indice,:).*exp(sqrt(-1).*2.*pi.*t.*600)];
end

%sound(real(Tx),Fs)
audiowrite('gravacaoXX.wav',real(Tx),Fs);
%% RX

[Rx,Fs] = audioread('gravacaoXX.wav');
Rx = reshape(Rx,1,[]);

rx=hilbert(Rx).*exp(-sqrt(-1).*2.*pi.*t.*600);
[a,b]=max(abs(rx*W'));
%?ndice decodificado ?
b
%Note que b de deve ser igual a indice