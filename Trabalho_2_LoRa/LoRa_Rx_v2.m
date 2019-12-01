recObj = audiorecorder(Fs, 24, 1);
disp('Iniciando gravação do sinal de áudio');
recordblocking(recObj, round(length(symbols_Tx).*Ts + 2));
disp('Gravação finalizada');
Rx = getaudiodata(recObj)';

% [Rx,Fs] = audioread('gravacao_AGORAVAI.wav');
% Rx = reshape(Rx,1,[]);

t_Rx = [0:1/Fs:(length(Rx)-1)/Fs];
RF_Rx = exp(sqrt(-1).*2.*pi.*f.*t_Rx);
Rx = hilbert(Rx).*(1./RF_Rx);

correlation = xcorr(mls_,Rx);
[value,index_mls] = findpeaks(abs(correlation),'Npeaks',2,'SortStr','descend');
%plot(real(correlation));
%msg_size = abs(abs(index_mls(2)-index_mls(1))-length(mls_));
msg_size = Fs*length(symbols_Tx)*Ts;

for i = 1:round(length(Rx)/2)
    msg_decoded = Rx(i:i+msg_size-1);
    symbols_Rx = [];
    for j = (1:Fs*Ts:length(msg_decoded))
         lora_block = msg_decoded(j:(j-1+Fs*Ts));
         [a,b] = max(abs(sqrt(Es/2^SF)*lora_block*W'));
         symbols_Rx = [symbols_Rx b-1];
    end
    
    if symbols_Rx == symbols_Tx
        mls_RX = Rx(i-length(mls_):i-1);
        sound(real(msg_decoded));
        symbols_Rx
        break
    end
end 

%% Quando eu encontrar o inicio da mensagem, utilizar este código

% msg_decoded = Rx(inicio_msg:inicio_msg+msg_size);
% symbols_Rx = [];
% for i = (1:Fs*Ts:length(msg_decoded))
%      lora_block = msg_decoded(i:(i-1+Fs*Ts));
%      [a,b] = max(abs(sqrt(Es/2^SF)*lora_block*W'));
%      symbols_Rx = [symbols_Rx b-1];
% end
% symbols_Rx

