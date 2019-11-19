
% recebe mensagem transmitida por áudio
recObj = audiorecorder(Fs, 24, 1);
disp('ESCUTANDO A MENSAGEM...');
recordblocking(recObj, round(length(msg_encoded).*T + 3));
disp('Fim de gravação');

Rx = getaudiodata(recObj);

w0 = 2*pi*440;
w1 = 2*pi*660;

% convolução com o filtro casado, flip faz t ir para -t
%yFILT0 = conv(Rx, flip(cos(w0.*t)),'same');
%yFILT0 = conv(abs(yFILT0),ones(1,round(length(cos(w0.*t))/2)),'same');
yFILT0 = conv(Rx, flip(cos(w0.*t)));
yFILT0 = conv(abs(yFILT0),ones(1,round(length(cos(w0.*t))/2)));
yFILT0 = yFILT0/norm(yFILT0);

yFILT1 = conv(Rx, flip(cos(w1.*t)));
yFILT1 = conv(abs(yFILT1),ones(1,round(length(cos(w1.*t))/2)));
yFILT1 = yFILT1/norm(yFILT1);

yEST = 2.*(yFILT1(1:length(t):end)>yFILT0(1:length(t):end))-1;
yEST = yEST';

inicio = strfind(yEST, mls(6,1));
yEST = yEST(inicio(1):length(msg_encoded+inicio(1)));

correlacao = xcorr(mls(6,1),yEST);
plot(correlacao);
[value,index_mls] = findpeaks(correlacao,'Npeaks',2,'SortStr','descend');
headers = sort(index_mls(1:2),'ascend');
msg_length = abs(abs(headers(2)-headers(1))-length(mls(6,1)));

bits_rx = (yEST(length(mls(6,1))+1:length(mls(6,1))+msg_length)+1)./2;
msg_decoded = vitdec(bits_rx, trellis, 20, 'trunc', 'hard');
string_Rx = char(bin2dec(reshape(char(msg_decoded+'0'), 8,[]).'))
