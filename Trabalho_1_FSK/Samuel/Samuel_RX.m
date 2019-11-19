% Receptor ouve a mensagem:

myVoice = audiorecorder(Fs,24,1);

disp('ESCUTANDO A MENSAGEM...');
recordblocking(myVoice, round(length(msg_seq).*bp + 3));
disp('Fim de gravação');

r = getaudiodata(myVoice)';

vecRx=r;
% vecRx=audioread('aulaie533.wav')';
% vecRx=audioread('DECOM.m4a');

% 1 - DETECTOR FSK
yFILT1 = conv(vecRx, flip(psi1));
yFILT1 = conv(abs(yFILT1), ones(1, round(length(psi1)/2)));
yFILT1 = yFILT1/norm(yFILT1);

yFILT2 = conv(vecRx, flip(psi2));
yFILT2 = conv(abs(yFILT2), ones(1,round(length(psi2)/2)));
yFILT2 = yFILT2/norm(yFILT2);

yEST = 2.*(yFILT2(1:length(t):end)>yFILT1(1:length(t):end))-1;


% 2 - Correlação da mensagem com sincronismo para encontrar o inicio
% 3 - Descarte a sequência de sincronismo

% Achando o inicio da informação
start = strfind(yEST, MLS);
start = start(1);
yEST = yEST(start:length(msg_seq)+start);

corr = xcorr(MLS, yEST);
figure;plot(corr)

[pks,loc] = findpeaks(corr, 'SortStr', 'descend');
headers = sort(loc(1:N),'ascend');
msg_length = abs(abs(headers(2)-headers(1))-length(MLS)); % Comprimento informação

% 4 - Faça mapeamento de símbolos em bits
bits_rx = (yEST(length(MLS)+1:length(MLS)+msg_length)+1)./2;

% 5 - Decodificador convolucional para recuperar mensagem original
msgDEC = vitdec(bits_rx,trellis,20,'trunc','hard');

% 6 - Display mensagem de texto
str2 = char(bin2dec(reshape(char(msgDEC+'0'), 8,[]).'));
disp(str2')
