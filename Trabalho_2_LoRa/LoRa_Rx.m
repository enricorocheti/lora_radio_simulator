
% recebe mensagem transmitida por �udio
recObj = audiorecorder(Fs, 24, 1);
disp('Iniciando grava��o do sinal de �udio');
recordblocking(recObj, round(length(msg_encoded).*T + 3));
disp('Grava��o finalizada');

Rx = getaudiodata(recObj)';     % sinal recebido

% filtragens para detectar o sinal FSK
yFILT1 = conv(Rx, flip(base1));
yFILT1 = conv(abs(yFILT1),ones(1,round(length(base1)/2)));
yFILT1 = yFILT1/norm(yFILT1);

yFILT2 = conv(Rx, flip(base2));
yFILT2 = conv(abs(yFILT2),ones(1,round(length(base2)/2)));
yFILT2 = yFILT2/norm(yFILT2);

yEST = 2.*(yFILT2(1:length(t):end)>yFILT1(1:length(t):end))-1;      % sinal recebido � transformado de bits para simbolos -1 e 1

inicio_msg = strfind(yEST, seq_treinamento);                        % encontra o in�cio da mensagem atrav�s da seq. de treinamento
yEST = yEST(inicio_msg(1):length(msg_encoded + inicio_msg(1)));     

% faz a correla��o da mensagem com a seq. de treinamento para estimar o tamanho da mensagem
correlacao = xcorr(seq_treinamento,yEST);
[value,index_mls] = findpeaks(correlacao,'Npeaks',2,'SortStr','descend');
plot(correlacao);
tamanho_msg = abs(abs(index_mls(2)-index_mls(1))-length(seq_treinamento));

msg_decoded = (yEST(length(seq_treinamento)+1:length(seq_treinamento)+tamanho_msg)+1)./2;
msg_decoded = vitdec(msg_decoded, trellis, 20, 'trunc', 'hard');    % remove o c�digo convolucional

% transforma a mensagem decodificada em caracteres e depois em string
char_Rx = bin2dec(reshape(char('0'+msg_decoded),length(msg_decoded)/8,[]));
string_Rx = [];
for x = char_Rx
    string_Rx = [string_Rx char(x)];
end
reshape(string_Rx,1,[])
