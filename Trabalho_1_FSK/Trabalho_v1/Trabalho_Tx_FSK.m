clc;
clear all;
close all;
  
string = input('Digite a frase a ser transmitida: ','s');   % mensagem do usuário
bits = dec2bin(string,8)-'0';                               % conversão de string para bit string e depois para bit
bits = reshape(bits,1,[]);                                  % conversão de matriz para vetor

%trellis = poly2trellis(3, [5 7]);
%msg_encoded = convenc(bits,trellis);
msg_encoded = bits;

Tx = [];
Fs = 8000;      % taxa de amostragem
T = 0.25;       % período 
t = 0:1/Fs:T;

for bit = msg_encoded
    if bit == 0
        w = 2*pi*440;
    else
        w = 2*pi*660;
    end
    Tx = [Tx cos(w.*t)];
end

sound(Tx)
audiowrite('gravacao.wav',Tx,8000);

