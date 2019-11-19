clc;
clear all;
close all;
  
string = input('Digite a frase a ser transmitida: ','s');   % mensagem do usu�rio
bits = dec2bin(string,8)-'0';                               % convers�o de string para bit string e depois para bit
bits = reshape(bits,1,[]);                                  % convers�o de matriz para vetor

trellis = poly2trellis(3, [5 7]);
msg_encoded = convenc(bits,trellis);            % c�digo convolucional
msg_encoded = 2.*msg_encoded-1;                 % transforma de bit para s�mbolos -1 e 1

seq_treinamento = mls(6,1);
msg_encoded = [seq_treinamento msg_encoded];    % sequ�ncia de treinamento
msg_encoded = repmat(msg_encoded, 1, 2);        % repete a mensagem duas vezes

Tx = [];
Fs = 8000;              % taxa de amostragem
T = 0.1;                % per�odo 
t = 0:1/Fs:T-1/Fs;      % vetor tempo

base1 = cos(2.*pi.*440.*t);
base2 = cos(2.*pi.*660.*t);
Tx = kron((round(msg_encoded+1)./2),base2);         % bit 1, 660 Hz
Tx = Tx + kron((round(msg_encoded-1)./2),base1);    % bit 0, 440 Hz

%sound(Tx)                          % emite a mensagem em frequ�ncia aud�vel
audiowrite('gravacao.wav',Tx,Fs);   % grava a mensagem em um arquivo ".wav"

