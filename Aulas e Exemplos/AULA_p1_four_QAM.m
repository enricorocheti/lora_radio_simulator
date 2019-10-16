clc;
clear all;
close all;

tam = 1e5;
EadB = [0:15];
sigma = 1;

n = sigma*randn(1,tam) + sqrt(-1)*sigma*randn(1,tam);
prob_sim = zeros(1,length(EadB));
prob_teo_aprox = zeros(1,length(EadB));
prob_teo_exato = zeros(1,length(EadB));
xest = zeros(1,tam);

i = 1;
for Ea = 10.^(EadB./10)
    c = sqrt(Ea/2);
    x = randsrc(1,tam,[(c+sqrt(-1)*c) (c-sqrt(-1)*c) (-c+sqrt(-1)*c) (-c-sqrt(-1)*c)]);
    z = x + n;
    
    xest(find(and(real(z)>0,imag(z)>0))) = c + sqrt(-1)*c;
    xest(find(and(real(z)>0,imag(z)<0))) = c - sqrt(-1)*c;
    xest(find(and(real(z)<0,imag(z)>0))) = -c + sqrt(-1)*c;
    xest(find(and(real(z)<0,imag(z)<0))) = -c - sqrt(-1)*c;
        
    prob_sim(i) = sum(x~=xest)/tam;
    prob_teo_aprox(i) = 2*qfunc(c./sigma);
    prob_teo_exato(i) = 2*qfunc(c./sigma) - (qfunc(c./sigma))^2;
    
    i = i + 1;
end

semilogy(EadB,prob_sim,'*');
hold on
semilogy(EadB,prob_teo_aprox);
hold on
semilogy(EadB,prob_teo_exato,'g');
grid on;
title(['Modulação 4-QAM com ruído gaussiano de variância \sigma =',num2str(sigma)]);
ylabel('Probabilidade de erro de símbolo');
xlabel('SNR [dB]');
legend('Simulação','Teoria Aprox.','Teoria Exata');
