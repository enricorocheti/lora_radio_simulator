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
    
    prob_bit_error = zeros(1,length(SNR_dB));
    
    Tx = [];
    Rx = [];
    index = 1;
    for Es = No * 10.^(0.1*SNR_dB)
        bit_error = zeros(1,size);
        for i = 1:size
            symbol = randi(2^SF); % símbolos tem distribuição uniforme
            Tx = sqrt(Es/2^SF).*W(symbol,:);
            noise = (sigma/sqrt(length(Tx)))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));  % ruído tem distribuição gaussiana
            h = abs((sigma/sqrt(length(Tx)))*(randn(1,length(Tx)))); % canal AWGN
            Rx = h.*Tx + noise;    
            [a,b] = max(abs(sqrt(Es/2^SF)*Rx*W'));
            bit_error(i) = get_bit_error(symbol,b,SF);
        end
        prob_bit_error(index) = sum(bit_error)/(size*SF);
        
        index = index + 1;
    end
    figure(1)
    semilogy(SNR_dB,prob_bit_error)
    hold on
end

figure(1)
title('Probabilidade de Erro de Bit - Canal AWGN');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');
xlim([-28 -3])

