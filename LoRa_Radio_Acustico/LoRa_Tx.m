clear all;
close all;
  
SF = 10;                    % Spreading Factor
Es = 2^SF;                  % Energia de símbolo LoRa
f = 600;                    % Freq. da portada
Fs = 8000;                  % Freq. de amostragem do áudio
Ts = 1;                     % Tempo de símbolo LoRa
B = 2^SF/Ts;                % Banda do sinal LoRa

t = [0:1/Fs:Ts-1/Fs];
k = 0:2^SF-1;               

% Mensagem do usuário
string = input('Digite a frase a ser transmitida: ','s'); 
symbols_Tx = double(string);

% Base ortonormal que define o espaço de sinais LoRa
W = zeros(2^SF,length(t));
for k = 0:2^SF-1
	W(k+1,:)=sqrt(Es/2^SF).*exp(sqrt(-1).*2.*pi.*t.*mod(linspace(k,k+2^SF,length(t)),2^SF));
end

% Formas de onda LoRa de acordo com os símbolos que desejam ser transmitidos
Tx = [];
for symbol = symbols_Tx
    Tx = [Tx W(symbol+1,:)];
end
lora_wave = Tx;
figure(1);
plot(real(lora_wave(1:5:end)));

% Adiciona a sequência de sincronismo no início e no fim da mensagem
mls_ = repelem(mls(8,1),5);
Tx = [mls_ Tx mls_];

% Passa o sinal para freq. audível de acordo com f defino no início do programa
t_Tx = [0:1/Fs:(length(Tx)-1)/Fs];
RF_Tx = exp(sqrt(-1).*2.*pi.*f.*t_Tx);
Tx = Tx.*RF_Tx;

% Transmite a mensagem em formato de som
sound(real(Tx),Fs);
audiowrite('mensagem.wav',real(Tx),Fs);