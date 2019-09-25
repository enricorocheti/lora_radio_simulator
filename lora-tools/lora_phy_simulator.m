function lora_phy_simulator
	
	% coding rate CR=1...4 for rate 4/(4+CR)
	CR = 3;
	
	% simulated bits for each loop (gets rounded to an integer number of
	% interleaving blocks)
	N_bits_raw = 160;
	N_bits = zeros(1,12);
	for SF = 6:12
		N_bits(SF) = ceil(N_bits_raw/(4*SF))*(4*SF);
	end
	
	% signal bandwidth
	BW = 125e3;

	% oversampling factor
	OSF = 8;
	
	% minimum and maximum SINR's to simulate
	SINR_dB_min = -30;
	SINR_dB_max = 5;
	SINR_dB_step = 1;
	SINR_dB = SINR_dB_min:SINR_dB_step:SINR_dB_max;
	
	% target BER and P(e) estimate params
    BER_target = 0.01;
	Pe_target = 0.01;
	rx_errors_threshold = 100;
	max_trials = 30000;
	seconds_budget = 7200;

	% minimum and maximum SF and SF_int
	SF_min = 6;
	SF_max = 12;
	SF_int_min = 6;
	SF_int_max = 12;
	
	% simulation params printout
	fprintf('N_bits(raw): %d(',N_bits_raw);
	fprintf(' %d',N_bits(SF_min:SF_max));
	fprintf(') CR: %d\nBW: %gkHz OSF: %d\n',...
		CR,BW*1e-3,OSF);

	fig = zeros(1,2+SF_max-SF_min);
	fig(1) = figure(1);
% 	fig(2) = figure(2);
	for SF=SF_min:SF_max
		fig(2+SF-SF_min) = figure(2+SF-SF_min);
	end
	fig2_update_delay=5;
	
	% loop over the desired signal spreading factors
	for SF = SF_min:SF_max

		% build the base upchirp
		mu = +1;
		fc = 0;
		phi0 = 2*pi*rand;
		c = lora_chirp(fc, mu, BW, SF, 0, 0, OSF);
		% c(1+k,:)=conj(exp(1i*phi0)*c(1,1+k*OSF))*c(1,1+mod(-k*OSF+(0:2^SF*OSF-1),2^SF*OSF));
		
		% dec2bin lookup table
		de2bi_SF = dec2bin(0:2^SF-1)-'0';
		
		% round to a whole number of interleaving blocks
		N_bits = ceil(N_bits_raw/(4*SF))*(4*SF);
		
		% gray mapping LUT
		x = de2bi_SF;
		bin2dec_SF = 2.^(SF-1:-1:0).';
		g = mod(x+[zeros(2^SF,1),x(:,1:end-1)],2)*bin2dec_SF;
		ig = zeros(2^SF,1);
		ig(1+g) = 0:2^SF-1;
		
		switch CR
			case 1
				% simple parity check
				P = ones(4,1);
				G = [eye(4),P];
				H = [P;1];
			case 2
				% shortened Hamming
				temp = dec2bin(0:7)-'0';
				P = temp(sum(temp,2)>=2,:);
				P = P(:,[1 2]);
				G = [eye(4),P];
				H = [P;eye(2)];
			case 3
				% Hamming(7,4)
				temp = dec2bin(0:7)-'0';
				P = temp(sum(temp,2)>=2,:);
				G = [eye(4),P];
				H = [P;eye(3)];
			case 4
				% Extended Hamming(8,4)
				temp = dec2bin(0:7)-'0';
				P = temp(sum(temp,2)>=2,:);
				P = [P,mod(1+sum(P,2),2)];
				G = [eye(4),P];
				H = [P;eye(4)];
		end
		
		% coset leaders LUT
		cl = zeros(2^CR,4+CR);
		cl_found = zeros(2^CR-1,1);
		for i = 1:4+CR
			syn = H(i,:) * (2.^(CR-1:-1:0).');
			if ~cl_found(syn)
				cl(syn,i)=1;
				cl_found(syn) = 1;
			else
				cl_found(syn) = 2;
			end
		end
		if any(cl_found==0)
			for i1 = 1:4+CR-1
				for i2 = i1+1:4+CR
					syn = mod(H(i1,:)+H(i2,:),2) * (2.^(CR-1:-1:0).');
					if ~cl_found(syn)
						cl(syn,[i1,i2])=1;
						cl_found(syn) = 1;
					else
						cl_found(syn) = 2;
					end
				end
			end
		end
		
		% loop over interfering signal SF_int
		for SF_int = SF_int_min:SF_int_max
			BW_int = 125e3;
			
			% oversampling factor
			OSF_int = OSF*BW/BW_int;

			% base upchirp
			mu = +1;
			fc_int = 0;
			phi0_int = 2*pi*rand;
			c_int = lora_chirp(fc_int, mu, BW_int, SF_int, 0, phi0_int, OSF_int);
			
			% figure
			x_axis = zeros(1,numel(SINR_dB));
			y_axis_Pe = zeros(1,numel(SINR_dB));
			y_axis_SER = zeros(1,numel(SINR_dB));
			y_axis_BER = zeros(1,numel(SINR_dB));
			
			% SINR loop
			SINR_idx = 1;
			seconds=0;tic;
			fig2_last_update=-1;
			while SINR_idx<=numel(SINR_dB) && seconds+toc<=seconds_budget
				
				% SINR aplitude ratio
				alpha = sqrt(10^(-SINR_dB(SINR_idx)/10));
				
				rx_errors_tot = 0;
				sym_errors_tot = 0;
				bit_errors_tot = 0;
				trials = 0;
				
				while rx_errors_tot < rx_errors_threshold ...
						&& seconds+toc<seconds_budget && trials<max_trials
                    
                    rx_errors_tot
                    
					% random source
					bits = floor(2*rand(1,N_bits));
					
					% Hamming encoding
					N_codewords = N_bits/4;
					N_codedbits = N_codewords*(4+CR);
					C = zeros(N_codewords,4+CR);
					for i = 1:N_codewords
						C(i,:) = mod(bits((i-1)*4+(1:4))*G,2);
					end
					
					% interleaving (from the LoRa PHY patent)
					interleaver_size = (4+CR)*SF;
					N_blocks = N_codedbits/interleaver_size;
					N_syms = N_codedbits/SF;
					S = zeros(N_syms,SF);
					for i = 0:N_blocks-1
						for k = 0:4+CR-1
							for m = 0:SF-1
								S(1+(4+CR)*i+k,1+m) = ...
									C(1+SF*i+mod(m-k,SF),1+k);
							end
						end
					end
					
					% number of samples for a chirp
					sym_len = 2^SF*OSF;
					
					% chirped spread spectrum modulation
					Ns = N_syms*sym_len;
					s = zeros(1,Ns);
					for sym = 1:N_syms
						% (inverse) Gray mapping
						k = ig(1+S(sym,:)*bin2dec_SF);
						s((sym-1)*sym_len+(1:sym_len)) = ...
							conj(exp(1i*phi0)*c(1+k*OSF))*...
							c(1+mod(-k*OSF+(0:2^SF*OSF-1),2^SF*OSF));
					end
					
					% interfering signal
					sym_len_int = 2^SF_int*OSF_int;
					N_syms_int = ceil(sym_len*N_syms/sym_len_int);
					N_bits_int = N_syms_int*SF_int;
					bits_int = floor(2*rand(1,N_bits_int));
					s_int = zeros(1,Ns);
					for sym = 1:N_syms_int
						k = 2.^(0:SF_int-1)*bits_int((sym-1)*SF_int+(1:SF_int))';
						s_int((sym-1)*sym_len_int+(1:sym_len_int)) = ...
							conj(exp(1i*phi0_int)*c_int(1+k*OSF_int))*...
							c_int(1+mod(-k*OSF_int+(0:2^SF_int*OSF_int-1),2^SF_int*OSF_int));
					end
					
					% add interfering signal with a random time shift
					r = s + alpha * ...
						s_int(1+mod((0:Ns-1)+floor(sym_len_int*rand),Ns));
					
					% fft based demodulation (assumes perfect
					% synchronization)
					S_est = zeros(N_syms,SF);
					down_chirp = lora_chirp(fc, -1, BW, SF, 0, 0, OSF);
					for sym = 1:N_syms
						temp = down_chirp.*r((sym-1)*sym_len+(1:sym_len));
						z = ifft(temp(1:OSF:end));
						[max1,pos] = max(abs(z));
						
						if toc-fig2_last_update>fig2_update_delay
% 							set(0,'CurrentFigure',fig(2))
% 							plot(abs(fftshift(fft(temp))))
% 							drawnow
							fig2_last_update=toc;
						end
						
						S_est(sym,:) = de2bi_SF(1+g(pos),:);
					end
					
					% deinterleaving
					C_est = zeros(N_codewords,4+CR);
					for i = 0:N_blocks-1
						for k = 0:4+CR-1
							for m = 0:SF-1
								C_est(1+SF*i+mod(m-k,SF),1+k) = ...
									S_est(1+(4+CR)*i+k,1+m);
							end
						end
					end
					
					% Hamming decoder
					bits_est = zeros(1,N_bits);
					for i = 1:N_codewords
						temp = C_est(i,:);
						if CR>2
							syn = mod(temp*H,2)*(2.^(CR-1:-1:0)');
							if syn~=0 && cl_found(syn)==1
								temp = mod(temp+cl(syn,:),2);
							end
						end
						bits_est((i-1)*4+(1:4)) = temp(1:4);
					end
					
					trials = trials + 1;
					
					sym_err = sum(S~=S_est,2);
					sym_errors = sum(sym_err~=0);
					
					bit_errors = sum(bits(:) ~= bits_est(:));
					
					if bit_errors
						rx_errors_tot = rx_errors_tot + 1;
						sym_errors_tot = sym_errors_tot + sym_errors;
						bit_errors_tot = bit_errors_tot + bit_errors;
					end
					
				end
				
				Pe = rx_errors_tot/trials;
				SER = sym_errors_tot/(trials*N_syms);
				BER = bit_errors_tot/(trials*N_bits);
				x_axis(SINR_idx) = SINR_dB(SINR_idx);
				y_axis_Pe(SINR_idx) = Pe;
				y_axis_SER(SINR_idx) = SER;
				y_axis_BER(SINR_idx) = BER;
				
                rx_errors_tot
                Pe
                
% 				fprintf('SINR: %g [dB] P(e): %g SER: %g BER: %g (trials:%g)\n',...
% 					SINR_dB(SINR_idx),Pe,SER,BER,trials)
				
				set(0,'CurrentFigure',fig(1));
				hold off
				semilogy(x_axis,y_axis_Pe);
				hold on
				semilogy(x_axis,y_axis_SER);
				semilogy(x_axis,y_axis_BER);
				grid on
				set(gca,'XLim',[SINR_dB_min,SINR_dB_max])
				xlabel('SINR [dB]');
				ylabel('Packet, Symbol, Bit Error Rates');
                legend('PER','SER','BER','Location','Best');
				drawnow
				
				SINR_idx = SINR_idx+1;
				seconds=seconds+toc;tic;
				fig2_last_update = -1;
				if BER <= BER_target
					seconds = seconds_budget;
				end
			end
			
			set(0,'CurrentFigure',fig(2+SF-SF_min));
			if SF_int==SF_int_min
				hold off
			end
			semilogy(x_axis,y_axis_BER);
			set(gca,'XLim',[SINR_dB_min,SINR_dB_max])
			hold on
			grid on
			for i = 1:SINR_idx
				if y_axis_BER(i)>BER_target && y_axis_BER(i+1)<BER_target
					fprintf('SF_ref:%d SF_int:%d SIR for BER=%g: %g [dB]\n',...
						SF,SF_int,BER_target,x_axis(i)+(x_axis(i+1)-x_axis(i)) ...
						/(log10(y_axis_BER(i+1))-log10(y_axis_BER(i))) ...
						*(log10(BER_target)-log10(y_axis_BER(i))));
				end
			end
		end
		
		xlabel(['SIR (SF=',num2str(SF),')']);
		ylabel('Bit Error Rate')
		l_entries = cell(1,SF_int_max-SF_int_min+1);
		for SF_int = SF_int_min:SF_int_max
			l_entries{SF_int-SF_int_min+1} = ['SF_{int}=',num2str(SF_int)];
		end
		legend(l_entries)
		ylim([BER_target,1])
		
	end
end
function [ s, t ] = lora_chirp(fc, mu, BW, SF, k, phi0, OSF)
	N = 2^SF*OSF;
	fs = BW*OSF;
	Ts = 1/fs;
	T = N*Ts;
	t = (-N/2:N/2-1)*Ts;
	k = floor(k);
	phi=zeros(1,N);
	t1 = t(1:k*OSF);
	t2 = t((k*OSF+1):N);
	if k>0
		phi(1:k*OSF) = -k*mu/2+3*BW*T*mu/8+BW*mu*t1-k*mu*t1/T+BW*mu*t1.^2/(2*T);
	end
	phi((k*OSF+1):N) = +k*mu/2-BW*T*mu/8-k*mu*t2/T+BW*mu*t2.^2/(2*T);
	s=exp(1i*(phi0+2*pi*phi));
	t = t+T/2;
end
