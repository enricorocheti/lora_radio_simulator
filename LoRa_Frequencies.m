clc;
clear all;
close all;

SF = 7;
k = randi(2^SF)-1; %k = 0:2^SF-1;
freq = [];

for n = 0:2^SF-1
    %freq = 2.*pi.*mod(k+n,2^SF).*n./2^SF;
    freq_inst = mod(k+n,2^SF).*(n./2^SF);
    freq = [freq mod(k+n,2^SF).*(n./2^SF)];
    display(['k = ',num2str(k),'   n = ',num2str(n),'   Freq = 2pi* ',num2str(freq_inst)]);
end

n = 0:2^SF-1;
plot(freq);
title(['Simbolo k = ',num2str(k), '   Spreading Factor = ',num2str(SF)]);
xlabel('n = 0, 1, 2, ..., 2^{SF}^ ');

ylabel('Frequência em banda base [Hz]');