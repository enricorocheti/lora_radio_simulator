clc
close all
clear all

t = 0:1/1e4:2;
y = chirp(t,0,1,250);
x = chirp(t,250,1,0);

figure(1)
plot(t(1:4000),y(1:4000));
title('Up-chirp')

figure(2)
plot(t(6000:10000),x(6000:10000));
title('Down-chirp')
