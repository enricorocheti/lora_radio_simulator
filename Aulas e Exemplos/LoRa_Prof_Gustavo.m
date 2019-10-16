clc;
clear all;
close all;
SF=8;
k=[0:2^SF-1];


W=zeros(2^SF);
for n=0:2^SF-1
    W(n+1,:)=exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF);
end
sigma=1;
EsdB=[-15:-15];
tam=1e3;
pbit=[];
for Es=10.^(0.1.*EsdB)
    vecerro=zeros(1,tam);
    for i=1:tam
    indice=randi(2^SF-1);
    Tx=sqrt(Es/2^SF).*W(indice,:);    
    ruido=sigma/sqrt(length(Tx))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));    
    h=abs(1/sqrt(2)*(randn(1,2^SF)+sqrt(-1)*randn(1,2^SF)));
    Rx=Tx+ruido;    
    %Rx=h.*Tx+ruido;    
    [a,b]=max(abs(sqrt(Es/2^SF)*Rx*W'));
    vecerro(i)=(b~=indice);
    end
    pbit=[pbit sum(vecerro)/(tam)]
end
semilogy(EsdB,pbit)