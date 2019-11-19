clc;
clear all;
close all;

recObj = audiorecorder;
recordblocking(recObj,24);
play(recObj);

%[Rx,Fs] = audioread('gravacao.wav');
Rx = getaudiodata(recObj);
Fs = 8000;

T = 0.25;
t = 0:1/Fs:T;
w0 = 2*pi*440;
w1 = 2*pi*660;

% convolução com o filtro casado, flip faz t ir para -t
yFILT0 = conv(Rx, flip(cos(w0.*t)));
yFILT0 = conv(abs(yFILT0),ones(1,round(length(cos(w0.*t))/2)));
yFILT0 = yFILT0/norm(yFILT0);

yFILT1 = conv(Rx, flip(cos(w1.*t)));
yFILT1 = conv(abs(yFILT1),ones(1,round(length(cos(w1.*t))/2)));
yFILT1 = yFILT1/norm(yFILT1);

% estimando
yEST = yFILT0(1:T*Fs:end)<yFILT1(1:T*Fs:end);

% Remove os dois bits do início e do fim do yEST pois eles são adicionados
% devido as convoluções com o filtro casado e com o filtro de média
yEST = yEST(2:end);
yEST(end) = [];

trellis = poly2trellis(3, [5 7]);
msg_decoded = vitdec(yEST,trellis,20,'trunc','hard');

char_Rx = bin2dec(reshape(char('0'+msg_decoded),ceil(length(msg_decoded)/8),[]));
string_Rx = [];
for x = char_Rx
    string_Rx = [string_Rx char(x)];
end
reshape(string_Rx,1,[])
