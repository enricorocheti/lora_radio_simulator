clc;
clear all;
close all;

SNR_dB = [-30:25];
size = 1e4;

for SF = [7 12]
    
    H_SF = log(2^SF-1) + 1/(2*(2^SF-1)) + 0.57722;
    
    prob_bit_error = [];
    
    for SNR = 10.^(0.1*SNR_dB)
        k1 = 2*H_SF;
        k2 = SNR*2^SF + 1;
        
        %pbit = qfunc(-sqrt(k1)) - sqrt((k2-1)/k2)*exp(-k1/(2*k2))*qfunc(sqrt(k2/(k2-1))*(-sqrt(k1) + sqrt(k1)/k2));
        termo1 = qfunc(-sqrt(k1));
        termo2 = qfunc( (sqrt(k2/(k2-1)) ) * ( -sqrt(k1) + (sqrt(k1)/k2) ) );
        termo3 = -sqrt( (k2-1)/k2 ) * exp(-k1/(2*k2));
        pbit = 0.5*(termo1 + termo3*termo2);
        prob_bit_error = [prob_bit_error pbit];
    end
    
    figure(1)
    semilogy(SNR_dB,prob_bit_error)
    hold on
end

figure(1)
title('Probabilidade de Erro de bit - Canal Rayleigh');
ylabel('Psym');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');
xlim([-30 25])