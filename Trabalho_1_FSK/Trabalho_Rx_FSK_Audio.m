clc;
clear all;
close all;

Fs = 8000;
recObj = audiorecorder(Fs,24,1);
recordblocking(recObj,10);
play(recObj);

%[Rx,Fs] = audioread('gravacao.wav');
Rx = getaudiodata(recObj);

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
%yEST = yFILT0(1:T*Fs:end)<yFILT1(1:T*Fs:end);
yEST = yFILT0(1:end)<yFILT1(1:end);

% Remove os dois bits do início e do fim do yEST pois eles são adicionados
% devido as convoluções com o filtro casado e com o filtro de média
%yEST = yEST(2:end);
%yEST(end) = [];

msg_decoded = yEST;
%trellis = poly2trellis(3, [5 7]);
%msg_decoded = vitdec(yEST,trellis,20,'trunc','hard');
mls_index = strfind(msg_decoded', ceil(mls(3,1)/2));
msg_decoded = msg_decoded(mls_index(1)+length(mls(5,1)):mls_index(2)-1);

char_Rx = bin2dec(reshape(char('0'+msg_decoded),length(msg_decoded)/8,[]));
string_Rx = [];
for x = char_Rx
    string_Rx = [string_Rx char(x)];
end
reshape(string_Rx,1,[])
