clc;
clear all;
close all;

tam = 2^10;
EadB = [-10:20];
sigma = 0.1;

n = sigma*randn(1,tam) + sqrt(-1)*sigma*randn(1,tam);
prob_simulada = zeros(1,length(EadB));
prob_teorica = zeros(1,length(EadB));
xest = zeros(1,tam);

i = 1;
for Ea = 10.^(EadB./10)
    c = sqrt(Ea);
    x = randsrc(1,tam,[-c c]);
    Tx = ifft(x);
    
    Rx = Tx + n;
    y = fft(Rx);
    
    xest(find(real(y) > 0)) = c;
    xest(find(real(y) < 0)) = -c;
        
    prob_simulada(i) = sum(x~=xest)/tam;
    prob_teorica(i) = qfunc(c./(sigma*sqrt(tam)));
    
    i = i + 1;
end

semilogy(EadB,prob_simulada,'*');
hold on
semilogy(EadB,prob_teorica);
title(['Ruído gaussiano de variância \sigma =',num2str(sigma)]);
ylabel('Probabilidade de erro de símbolo');
xlabel('SNR [dB]');
legend('Simulação','Teoria');
