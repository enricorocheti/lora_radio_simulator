This archive includes 10 total files, including this README file.

- The Matlab file lora_phy_simulator.m is a simulation tool for testing the performance of a LoRa link in case of collision between LoRa packets modulated
  with different spreading factors. You can use it for obtaining the results presented in Table 1 of our paper.
  The output is the packet, symbol and bit error rate (PER, SER and BER respectively) for each spreading factor,
  interfered with any other possible spreading factor. In particular, Figure 1 is the current experiment, while Figures 2-8
  are the resulting BER curves for spreading factors 7 to 12 (as shown in Fig. 3 in the paper).

  Editing the script you can change the following parameters:
  - Min reference SF		 (SF_min=6 default)
  - Max reference SF		 (SF_max=12 default)
  - Min interference SF		 (SF_int_min=6 default)
  - Max interference SF		 (SF_int_max=12 default)
  - Min SIR	 		 (SINR_dB_min-30 default)
  - Max SIR 			 (SINR_dB_max=5 default)
  - Coding Rate 		 (CR=3 default)
  - Bandwidth 			 (BW=125e3 default)
  - Payload bits		 (N_bits_raw=160 default)
  - SIR step 			 (SINR_dB_step=1 default)
  - Target BER 			 (BER_target=0.01 default)
  - Errors budget per step 	 (rx_errors_threshold=100 default) 
  - Max trials per step		 (max_trials=30000 default)
  - Max duration per SFref/SFint (seconds_budget=7200 default)
        

- Six binary files with .raw extension contain I/Q samples of LoRa packets synthetized by our LoRa sinthesizer.
  Each packet is modulated and coded with the following features:
   - spreading factor from 7 to 12;
   - bandwidth 125 KHz;
   - over sampling factor 8;
   - sampling rate 1 Msps;
   - code rate 4/7;
   - destination address 12;
   - payload CRC;
   - explicit header mode;
   - private network (sync word = 0x12)

- You can use the lora_tx_1_flow.grc file (and gnuradio-companion) for sending LoRa packets over the air and receiving them with a LoRa commercial device.
  Just select one of the six files with the SF of your choice through the File Source block and play.

- You can use the lora_tx_2_flows.grc file for testing the imperfect orthogonality of LoRa SFs. Just select two SFs (among the six availables) of your choice and
  the SIR level desidered.


We tested this setup with a Semtech SX1272 low cost transceiver and with a iC880A multi-spreading factor gateway. In both cases the address of the receiver MUST
be 12.
