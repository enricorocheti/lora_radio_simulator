clc;
clear all;
close all;

sigma = 1;
No = 2*sigma^2;
%EsdB = [-25:0];
SNR_dB = [-30:25];
size = 1e4;

for SF = 7:1:7
    k = 0:2^SF-1;

    W = zeros(2^SF);
    for n = 0:2^SF-1
        W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF); % bases ortonormais que caracterizam o espaço de sinais LoRa
    end
    
    %pbit = zeros(1,length(EsdB));
    prob_symbol_error = [];
    prob_bit_error = [];
    Tx = [];
    Rx = [];
    %for Es = 10.^(0.1.*EsdB)
    for Es = No * 10.^(0.1*SNR_dB)
        symbol_error = zeros(1,size);
        bit_error = zeros(1,size);
        for i = 1:size
            symbol = randi(2^SF)-1; % símbolos tem distribuição uniforme     
            Tx = sqrt(Es/2^SF).*W(symbol,:);
            noise = (sigma/sqrt(length(Tx)))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));  % ruído tem distribuição gaussiana
            h = abs((1/sqrt(2))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)))); % canal Rayleigh
            Rx = h.*Tx + noise;    
            [a,b] = max(abs(sqrt(Es/2^SF)*Rx*W'));
            symbol_error(i) = (b~=symbol);
            bit_error(i) = get_bit_error(symbol,b,SF);
        end
        prob_symbol_error = [prob_symbol_error sum(symbol_error)/(size)];
        prob_bit_error = [prob_bit_error sum(bit_error)/(size*SF)];
    end
    figure(1)
    semilogy(SNR_dB,prob_symbol_error)
    hold on
    figure(2)
    semilogy(SNR_dB,prob_bit_error)
    hold on
end

figure(1)
title('Probabilidade de Erro de Símbolo - Canal Rayleigh');
ylabel('Psym');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');

figure(2)
title('Probabilidade de Erro de Bit - Canal Rayleigh');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');