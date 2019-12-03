clc;
clear all;
close all;

sigma = 1;              % Vari�ncia do ru�do AWGN
No = 2*sigma^2;         % Densidade espectral da pot�ncia do ru�do
SNR_dB = [-30:-5];      % Rela��o sinal-ru�do em dB
size = 1e3;             % Quantas amostras ser�o analisadas para cada valor da SNR

for SF = [7:1:10]
    k = 0:2^SF-1;

    % Bases ortonormais que caracterizam o espa�o de sinais LoRa
    W = zeros(2^SF);
    for n = 0:2^SF-1
        W(n+1,:) = exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF);
    end
    
    H_SF = log(2^SF-1) + 1/(2*(2^SF-1)) + 0.57722;      % N�mero harm�nico Hm
    prob_bit_error = zeros(1,length(SNR_dB));
    prob_bit_error_teorica = zeros(1,length(SNR_dB));
    
    index = 1;
    for Es = No * 10.^(0.1*SNR_dB)
        
        % C�lculo da Pbit por simula��o
        bit_error = zeros(1,size);
        Tx = [];
        Rx = [];
        for i = 1:size
            symbol = randi(2^SF);                                                                   % S�mbolos tem distribui��o uniforme                                                                   
            Tx = sqrt(Es/2^SF).*W(symbol,:);
            noise = (sigma/sqrt(length(Tx)))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx)));    % Ru�do AWGN
            h = abs((1/sqrt(1.5))*(randn(1,length(Tx))+sqrt(-1)*randn(1,length(Tx))));              % Canal Rayleigh
            Rx = h.*Tx + noise;
            [a,b] = max(abs(sqrt(Es/2^SF)*Rx*W'));
            bit_error(i) = get_bit_error(symbol,b,SF);
        end
        prob_bit_error(index) = sum(bit_error)/(size*SF);
        
        % C�lculo da Pbit te�rica
        k1 = 2*H_SF;
        k2 = 2*(Es/No)*2^SF + 1;
        pbit = qfunc(-sqrt(k1)) - sqrt((k2-1)/k2)*exp(-k1/(2*k2))*qfunc(sqrt(k2/(k2-1))*(-sqrt(k1) + sqrt(k1)/k2));
        prob_bit_error_teorica(index) = 0.5*pbit;
        
        index = index + 1;
    end
    figure(1)
    semilogy(SNR_dB,prob_bit_error)
    hold on
    figure(2)
    semilogy(SNR_dB,prob_bit_error_teorica)
    hold on
    figure(3)
    semilogy(SNR_dB,prob_bit_error,'LineWidth',1)
    hold on
    semilogy(SNR_dB,prob_bit_error_teorica,':s')
    hold on
end

figure(1)
title('Probabilidade de Erro de Bit - Canal Rayleigh e ru�do AWGN');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7','SF = 8','SF = 9','SF = 10')

figure(2)
title('Probabilidade de Erro de Bit te�rica - Canal Rayleigh');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7 teoria','SF = 8 teoria','SF = 9 teoria','SF = 10 teoria');

figure(3)
title('Probabilidade de Erro de Bit, teoria X simula��o');
ylabel('Pbit');
xlabel('SNR [dB]');
legend('SF = 7','SF = 7 teoria','SF = 8','SF = 8 teoria', 'SF = 9','SF = 9 teoria','SF = 10','SF = 10 teoria');

