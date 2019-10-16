clc;
clear all;
close all;

tam = 2^16;
EadB = [-10:20];
sigma = 0.1;
alfa = 0.5;
h = [1 alfa];
mi = 1; % tamanho do CP é 1
n = sigma*randn(1,tam+mi) + sqrt(-1)*sigma*randn(1,tam+mi); 
% tam + 1 devido ao CP adicionar uma dimensão nos símbolos transmitidos
                                                            
prob_simulada = zeros(1,length(EadB));
prob_teorica = zeros(1,length(EadB));
xest = zeros(1,tam);

i = 1;
for Ea = 10.^(EadB./10)
    c = sqrt(Ea);
    x = randsrc(1,tam,[-c c]);
    s = ifft(x);
    s = horzcat(s(end),s);      % adiciona CP
    
    Tx = conv(s,h,'same');      % efeito do canal
    Rx = Tx + n;                % efeito do ruído
    
    Rx(1) = [];                 % remove o CP
    y = fft(Rx);                
    H = fft(h,tam)./tam;
    %y = y./H;
   
    % estima o valor do símbolo
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
