clc;
clear all;
close all;

T = 100;
size = 10;
t = [1:size*T];

a = zeros(1,size*T);
symbols = randsrc(1,size,[-3 -1 1 3]);

a(1:T:size*T) = symbols;
stem(a)

g = sinc(pi*t/T);
plot(g)

s = conv(a,g);
plot(s)


