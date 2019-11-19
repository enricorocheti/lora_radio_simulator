clc;
clear all;
close all;
% 1 - Gere uma frase
msg = 'Aula IE5333';

% 2 - Passe o texto para uma sequ�ncia bin�ria
dados_bin = reshape(dec2bin(msg, 8).'-'0',1,[]);

% 3 - Use um c�digo convolucional para proteger os dados
trellis = poly2trellis(3, [5 7]);
msgENC = convenc(dados_bin,trellis);
% msgENC = dados_bin;

% 4 - Transforme esta sequ�ncia bin�ria em s�mbolos BFSK
msgENC = 2.*(msgENC)-1;

% 5 - Anexe na mensagem a sequ�ncia de treinamento com a fun��o mls(8,1)
MLS = mls(8,1);
MLS = MLS(1:round(end/4));

% 6 - Forme um vetor em que a mensagem seja repetida n vezes
N = 2;
msg_seq = [MLS msgENC];
msg_seq = repmat(msg_seq, 1, N);

% 8 - Modula��o BFSK
Fs = 8000;
bp = 0.1; % Periodo de bit
t = [0:1/Fs:bp-1/Fs];
psi1 = cos(2.*pi.*440.*t);
psi2 = cos(2.*pi.*660.*t);
vecTx = kron((round(msg_seq+1)./2),psi2);
vecTx = vecTx + kron((round(msg_seq-1)./2),psi1);

figure(1)
plot(vecTx)
title('Sinal modulado (10 primeiros bits)')
axis([0 length(t)*10 -1.5 1.5])

audiowrite('aulaie533.wav', vecTx, Fs);
