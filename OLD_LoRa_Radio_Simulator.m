clc;
clear all;
close all;

%function wi = ortho_basis_func(x)
%    wi = x;
%end

Es = 0.5;
SF = 7;
size = 50;
symbols = randsrc(1,size,[0:1:(2^SF)-1]);

sigma = 1/SF;
gauss_noise = sigma*(randn(size,2^SF) + sqrt(-1)*randn(size,2^SF));

% cada s�mbolo � composto por SF bits, sk = k
% cada s�mbolo sk � composto por wk(nT) formas de onda

% c�lculo da base w(i,n) [wi*(nT)] para i = 0, 1..., 2^SF - 1
i = 1;
for k = 0:1:(2^SF-1)
    j = 1;
    for n = [0:1:(2^SF-1)]
        wi(i,j) = conj(sqrt(1/(2^SF))*exp((sqrt(-1).*2.*pi.*mod((k+n),2^SF).*(n/2^SF))));
        j = j + 1;
    end
    i = i + 1;
end

% c�lculo de W(k,n) [Wk(nT)] para cada s�mbolo k, Wk � a forma de onda que corresponde ao s�mbolo sk
i = 1;
for k = [symbols]
    j = 1;
    for n = [0:1:(2^SF-1)]
        wk(i,j) = sqrt(1/(2^SF))*exp((sqrt(-1).*2.*pi.*mod((k+n),2^SF).*(n/2^SF)));
        Wk(i,j) = sqrt(Es)*wk(i,j);
        j = j + 1;
    end
    %display(['wk(k = ',num2str(k),', i = ',num2str(i),') preenchido ']);
    i = i + 1;
end

% rk [rk(nT)] � o sinal recebido no demodulador
rk = Wk + gauss_noise;

symbol_error = 0;
symbol_ok = 0;

% demodula��o
i = 1;
for k = [symbols]
    m = 1;
    max_demod_sum = 0;
    for k2 = [0:1:2^SF-1]
        demod_sum = 0;
        j = 1;
        for n = [0:1:2^SF-1]
            demod_sum = demod_sum + rk(i,j)*wi(m,j);
            j = j + 1;
        end
        m = m + 1;
        demod_sum = abs(demod_sum);
        if demod_sum > max_demod_sum
            max_demod_sum = demod_sum;
            %display(['Decodifica��o Wk(k = ',num2str(k),') * wi(i = ',num2str(k2),') vale ',num2str(max_demod_sum)]);
            k_est = k2;
        end
    end
    %display(['Decodifica��o de Wk(k = ',num2str(k),') resultou em sk(estimado) = ',num2str(k_est)]);
    if k ~= k_est
        symbol_error = symbol_error + 1;
    else
        symbol_ok = symbol_ok + 1;
    end
    i = i + 1;
end
display(' ');
display(['S�mbolos enviados: ',num2str(size)]);
display(['S�mbolos decodificados com erro: ',num2str(symbol_error)]);
display(['S�mbolos decodificados sem erro: ',num2str(symbol_ok)]);

