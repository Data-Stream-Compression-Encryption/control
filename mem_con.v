


// //////////// SDRAM //////////
// output		    [12:0]		DRAM_ADDR;
// output		     [1:0]		DRAM_BA;
// output		          		DRAM_CAS_N;
// output		          		DRAM_CKE;
// output		          		DRAM_CLK;
// output		          		DRAM_CS_N;
// inout 		    [31:0]		DRAM_DQ;
// output		     [3:0]		DRAM_DQM;
// output		          		DRAM_RAS_N;
// output		          		DRAM_WE_N;


module mem_con(clk,dram_addr, dram_ba, dram_cas_n, dram_cke, dram_clk, dram_cs_n, dram_dq, dram_dqm, dram_ras_n, dram_we_n, rdy,  in_valid, data_in, data_out, out_valid, out_rcvd);
	
	input clk;

	// DRAM control signals
	output		    [12:0]		dram_addr;
	output		     [1:0]		dram_ba;
	output		          		dram_cas_n;
	output		          		dram_cke;
	output		          		dram_clk;
	output		          		dram_cs_n;
	inout 		    [31:0]		dram_dq;
	output		     [3:0]		dram_dqm;
	output		          		dram_ras_n;
	output		          		dram_we_n;
	
	// DSEC interface
	input								rdy;
	output							in_valid;
	output			 [63:0]     data_in;
	input				 [63:0]		data_out;
	input								out_valid;
	output							out_rcvd;
	
	
	// 
	
	assign dram_cke = 1'b1;
	assign dram_cs_n = 1'b0;
	assign dram_ras_n = 1'b1;
	assign dram_cas_n = 1'b0;
	assign dram_clk = clk;



	// Write test
	assign dram_we_n = 1'b0;
	assign dram_ba = 2'b00;
	assign dram_addr = 13'b0;
	assign dram_dqm = 4'b0;
	
	assign dram_dq = 32'habcdef01;
	
	
	
	
	
	
endmodule