clc;
clear all;
close all;

sigma = 1;
No = 2*sigma^2;
SNR_dB = [-28:-3];
size = 1e3;

for SF = 7:1:10
    k = 0:2^SF-1;

    W = zeros(2^SF);
    for n = 0:2^SF-1
        W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF); % bases ortonormais que caracterizam o espaço de sinais LoRa
    end
    
    H_SF = log(2^SF) + 1/(2*(2^SF)) + 0.57722;
    %prob_symbol_error = zeros(1,length(SNR_dB));
    prob_bit_error = zeros(1,length(SNR_dB));
    prob_bit_error2 = zeros(1,length(SNR_dB));
    prob_bit_error_teorica = zeros(1,length(SNR_dB));
    
    Tx = [];
    Rx = [];
    index = 1;
    for Es = No * 10.^(0.1*SNR_dB)
        %symbol_error = zeros(1,size);
        bit_error = zeros(1,size);
        for i = 1:size
            symbol = randi(2^SF); % símbolos tem distribuição uniforme
            Tx = sqrt(Es/2^SF).*W(symbol,:);
            noise = (sigma/sqrt(length(Tx)))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));  % ruído tem distribuição gaussiana
            h = abs((1/sqrt(2))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx))));
            %h = abs((randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)))); % canal Rayleigh
            Rx = h.*Tx + noise;
            [a,b] = max(abs(sqrt(Es/2^SF)*Rx*W'));
            %symbol_error(i) = (b~=symbol);
            bit_error(i) = get_bit_error(symbol,b,SF);
        end
        
        %prob_symbol_error(index) = sum(symbol_error)/(size);
        prob_bit_error(index) = sum(bit_error)/(size*SF);
        
        k1 = 2*H_SF - 1;
        k2 = (Es/No)*2^SF + 1;
        pbit = qfunc(-sqrt(k1)) - sqrt((k2-1)/k2)*exp(-k1/(2*k2))*qfunc(sqrt(k2/(k2-1))*(-sqrt(k1) + sqrt(k1)/k2));
        prob_bit_error_teorica(index) = 0.5*pbit;
        
        index = index + 1;
    end
    figure(1)
    semilogy(SNR_dB,prob_bit_error)
    hold on
    %semilogy(SNR_dB,prob_bit_error_teorica)
    %hold on
    %figure(2)
    %semilogy(SNR_dB,prob_symbol_error)
    %hold on
end

figure(1)
title('Probabilidade de Erro de Bit - Canal Rayleigh');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');
xlim([-28 -3])

%figure(2)
%title('Probabilidade de Erro de Símbolo - Canal Rayleigh');
%ylabel('Psym');
%xlabel('SNR [dB]');
%legend('SF = 7','SF = 8','SF = 9','SF = 10');
%xlim([-28 -3])

