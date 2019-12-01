clc;
clear all;
close all;

SF = 8;
size = 5;
k_vec = [];
B = 125e3;  % banda 125 kHz
Tsample = 1/B;
Tsymbol = (2^SF)*Tsample;

n = [0:1:2^SF-1]
k = 0;
Es = 1;
W1 = sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*mod(k+n,2^SF).*n./2^SF);
figure(1)
plot(real(W1));

for i = 1:size
    k = randi(2^SF)-1;
    k_vec = [k_vec k];
    freq = [];
    
    freq_offset = B*k/2^SF;
    display(['k = ',num2str(k),'   fk = ',num2str(freq_offset)]);
    
    for n = 0:2^SF-1
        %freq = 2.*pi.*mod(k+n,2^SF).*n./2^SF;
        freq_inst = mod(k+n,2^SF).*(n./2^SF);
        freq = [freq mod(k+n,2^SF).*(n./2^SF)];
        %display(['k = ',num2str(k),'   n = ',num2str(n),'   Freq = 2pi* ',num2str(freq_inst)]);
    end
    figure(2)
    plot(freq);
    hold on
end

%n = 0:2^SF-1;
%title(['Simbolo k = ',num2str(k), '   Spreading Factor = ',num2str(SF)]);
legend(['k = ' num2str(k_vec(1))],['k = ' num2str(k_vec(2))],['k = ' num2str(k_vec(3))],['k = ' num2str(k_vec(4))],['k = ' num2str(k_vec(5))]);
xlabel('n = 0, 1, 2, ..., 2^{SF}^ ');
ylabel('Frequência em banda base [Hz]');