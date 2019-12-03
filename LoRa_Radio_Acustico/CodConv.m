clc;
%Tx
trellis = poly2trellis(3, [5 7]);
tam=30;
msg=randsrc(1,tam,[0 1]);
msgENC = convenc(msg,trellis);
msgDEC = vitdec(msgENC,trellis,20,'trunc','hard');
sum(msg(2:end)~=msgDEC(2:end))