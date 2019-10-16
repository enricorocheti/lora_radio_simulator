clc;
clear all;
close all;

sigma = 1;
EsdB = [-25:0];
size = 1e3;

for SF = [7:1:10]
    k = [0:2^SF-1];

    W = zeros(2^SF);
    for n=0:2^SF-1
        W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF);
    end

    prob_symbol_error = [];
    prob_bit_error = [];
    %pbit = zeros(1,length(EsdB));
    Tx = [];
    Rx = [];
    for Es=10.^(0.1.*EsdB)
        symbol_error = zeros(1,size);
        bit_error = zeros(1,size);
        for i=1:size
            symbol = randi(2^SF-1);
            Tx = sqrt(Es/2^SF).*W(symbol,:);    
            noise = sigma/sqrt(length(Tx))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));    
            %h = abs(1/sqrt(2)*(randn(1,2^SF)+sqrt(-1)*randn(1,2^SF)));
            %h = [x] onde x é variável aleatória rayleigh
            Rx = Tx + noise;    
            %Rx = h.*Tx + noise;    
            [a,b] = max(abs(sqrt(Es/2^SF)*Rx*W'));
            symbol_error(i) = (b~=symbol);
            bit_error(i) = get_bit_error(symbol,b,SF);
        end
        prob_symbol_error = [prob_symbol_error sum(symbol_error)/(size)];
        prob_bit_error = [prob_bit_error sum(bit_error)/(size*SF)];
    end
    figure(1)
    semilogy(EsdB,prob_symbol_error)
    hold on
    figure(2)
    semilogy(EsdB,prob_bit_error)
    hold on
end

figure(1)
title('Probabilidade de Erro de Símbolo');
ylabel('Psym');
xlabel('Es [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');

figure(2)
title('Probabilidade de Erro de Bit');
ylabel('Pbit');
xlabel('Es [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10');