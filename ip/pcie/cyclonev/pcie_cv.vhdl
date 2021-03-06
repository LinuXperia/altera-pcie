--
-- Copyright (C) 2014, 2017 Chris McClelland
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software
-- and associated documentation files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright  notice and this permission notice  shall be included in all copies or
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
-- BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- Try diffing with the pcie/testbench/pcie_tb/simulation/submodules/pcie.vhd you get from qsys-generate of a VHDL testbench:
--
-- mkdir try
-- cd try
-- cp ../pcie_cv.qsys .
-- $ALTERA/sopc_builder/bin/qsys-generate --family="Cyclone V" --testbench=STANDARD --testbench-simulation=VHDL --allow-mixed-language-testbench-simulation pcie_cv.qsys
-- $ALTERA/sopc_builder/bin/qsys-generate --family="Cyclone V" --synthesis=VHDL pcie_cv.qsys
-- meld pcie_cv/testbench/pcie_cv_tb/simulation/submodules/pcie_cv.vhd ../pcie_cv.vhdl
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library makestuff;

entity pcie_cv is
	port (
		-- Clock, resets, PCIe physical RX & TX
		pcieRefClk_in          : in  std_logic := '0';
		pcieNPOR_in            : in  std_logic := '0';
		pciePERST_in           : in  std_logic := '0';
		pcieRX_in              : in  std_logic_vector(3 downto 0) := (others => '0');
		pcieTX_out             : out std_logic_vector(3 downto 0);

		-- Application interface
		pcieClk_out            : out std_logic;
		cfgBusDev_out          : out std_logic_vector(12 downto 0);
		msiReq_in              : in  std_logic;
		msiAck_out             : out std_logic;

		rxData_out             : out std_logic_vector(63 downto 0);
		rxValid_out            : out std_logic;
		rxReady_in             : in  std_logic;
		rxSOP_out              : out std_logic;
		rxEOP_out              : out std_logic;

		txData_in              : in  std_logic_vector(63 downto 0);
		txValid_in             : in  std_logic;
		txReady_out            : out std_logic;
		txSOP_in               : in  std_logic;
		txEOP_in               : in  std_logic;
		
		-- Control & Pipe signals for simulation connection
		sim_test_in            : in  std_logic_vector(31 downto 0) :=
		                             x"00000" &  -- Reserved
		                             "0011" &    -- Pipe interface
		                             "1" &       -- Disable low power state
		                             "0" &       -- Disable compliance mode
		                             "1" &       -- Disable compliance mode
		                             "0" &       -- Reserved
		                             "0" &       -- FPGA Mode
		                             "0" &       -- Reserved
		                             "0" &       -- Reserved
		                             "0";        -- Simulation mode
		sim_simu_mode_pipe_in  : in  std_logic := '0';
		sim_ltssmstate_out     : out std_logic_vector(4 downto 0);
		sim_pipe_pclk_in       : in  std_logic := '0';
		sim_pipe_rate_out      : out std_logic_vector(1 downto 0);
		sim_eidleinfersel0_out : out std_logic_vector(2 downto 0);
		sim_eidleinfersel1_out : out std_logic_vector(2 downto 0);
		sim_eidleinfersel2_out : out std_logic_vector(2 downto 0);
		sim_eidleinfersel3_out : out std_logic_vector(2 downto 0);
		sim_phystatus0_in      : in  std_logic := '0';
		sim_phystatus1_in      : in  std_logic := '0';
		sim_phystatus2_in      : in  std_logic := '0';
		sim_phystatus3_in      : in  std_logic := '0';
		sim_powerdown0_out     : out std_logic_vector(1 downto 0);
		sim_powerdown1_out     : out std_logic_vector(1 downto 0);
		sim_powerdown2_out     : out std_logic_vector(1 downto 0);
		sim_powerdown3_out     : out std_logic_vector(1 downto 0);
		sim_rxdata0_in         : in  std_logic_vector(7 downto 0)  := (others => '0');
		sim_rxdata1_in         : in  std_logic_vector(7 downto 0)  := (others => '0');
		sim_rxdata2_in         : in  std_logic_vector(7 downto 0)  := (others => '0');
		sim_rxdata3_in         : in  std_logic_vector(7 downto 0)  := (others => '0');
		sim_rxdatak0_in        : in  std_logic := '0';
		sim_rxdatak1_in        : in  std_logic := '0';
		sim_rxdatak2_in        : in  std_logic := '0';
		sim_rxdatak3_in        : in  std_logic := '0';
		sim_rxelecidle0_in     : in  std_logic := '0';
		sim_rxelecidle1_in     : in  std_logic := '0';
		sim_rxelecidle2_in     : in  std_logic := '0';
		sim_rxelecidle3_in     : in  std_logic := '0';
		sim_rxpolarity0_out    : out std_logic;
		sim_rxpolarity1_out    : out std_logic;
		sim_rxpolarity2_out    : out std_logic;
		sim_rxpolarity3_out    : out std_logic;
		sim_rxstatus0_in       : in  std_logic_vector(2 downto 0)  := (others => '0');
		sim_rxstatus1_in       : in  std_logic_vector(2 downto 0)  := (others => '0');
		sim_rxstatus2_in       : in  std_logic_vector(2 downto 0)  := (others => '0');
		sim_rxstatus3_in       : in  std_logic_vector(2 downto 0)  := (others => '0');
		sim_rxvalid0_in        : in  std_logic := '0';
		sim_rxvalid1_in        : in  std_logic := '0';
		sim_rxvalid2_in        : in  std_logic := '0';
		sim_rxvalid3_in        : in  std_logic := '0';
		sim_txcompl0_out       : out std_logic;
		sim_txcompl1_out       : out std_logic;
		sim_txcompl2_out       : out std_logic;
		sim_txcompl3_out       : out std_logic;
		sim_txdata0_out        : out std_logic_vector(7 downto 0);
		sim_txdata1_out        : out std_logic_vector(7 downto 0);
		sim_txdata2_out        : out std_logic_vector(7 downto 0);
		sim_txdata3_out        : out std_logic_vector(7 downto 0);
		sim_txdatak0_out       : out std_logic;
		sim_txdatak1_out       : out std_logic;
		sim_txdatak2_out       : out std_logic;
		sim_txdatak3_out       : out std_logic;
		sim_txdeemph0_out      : out std_logic;
		sim_txdeemph1_out      : out std_logic;
		sim_txdeemph2_out      : out std_logic;
		sim_txdeemph3_out      : out std_logic;
		sim_txdetectrx0_out    : out std_logic;
		sim_txdetectrx1_out    : out std_logic;
		sim_txdetectrx2_out    : out std_logic;
		sim_txdetectrx3_out    : out std_logic;
		sim_txelecidle0_out    : out std_logic;
		sim_txelecidle1_out    : out std_logic;
		sim_txelecidle2_out    : out std_logic;
		sim_txelecidle3_out    : out std_logic;
		sim_txmargin0_out      : out std_logic_vector(2 downto 0);
		sim_txmargin1_out      : out std_logic_vector(2 downto 0);
		sim_txmargin2_out      : out std_logic_vector(2 downto 0);
		sim_txmargin3_out      : out std_logic_vector(2 downto 0);
		sim_txswing0_out       : out std_logic;
		sim_txswing1_out       : out std_logic;
		sim_txswing2_out       : out std_logic;
		sim_txswing3_out       : out std_logic
	);
end entity pcie_cv;

architecture rtl of pcie_cv is
	-- Declare the actual PCIe IP block
	component altpcie_cv_hip_ast_hwtcl is
		generic (
			ACDS_VERSION_HWTCL                        : string  := "16.1";
			lane_mask_hwtcl                           : string  := "x4";
			gen12_lane_rate_mode_hwtcl                : string  := "Gen1 (2.5 Gbps)";
			pcie_spec_version_hwtcl                   : string  := "2.1";
			ast_width_hwtcl                           : string  := "Avalon-ST 64-bit";
			pll_refclk_freq_hwtcl                     : string  := "100 MHz";
			set_pld_clk_x1_625MHz_hwtcl               : integer := 0;
			in_cvp_mode_hwtcl                         : integer := 0;
			hip_reconfig_hwtcl                        : integer := 0;
			num_of_func_hwtcl                         : integer := 1;
			use_crc_forwarding_hwtcl                  : integer := 0;
			port_link_number_hwtcl                    : integer := 1;
			slotclkcfg_hwtcl                          : integer := 1;
			enable_slot_register_hwtcl                : integer := 0;
			vsec_id_hwtcl                             : integer := 4466;
			vsec_rev_hwtcl                            : integer := 0;
			user_id_hwtcl                             : integer := 0;
			porttype_func0_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_0_hwtcl                    : integer := 28;
			bar0_io_space_0_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_0_hwtcl              : string  := "Enabled";
			bar0_prefetchable_0_hwtcl                 : string  := "Enabled";
			bar1_size_mask_0_hwtcl                    : integer := 0;
			bar1_io_space_0_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_0_hwtcl                 : string  := "Disabled";
			bar2_size_mask_0_hwtcl                    : integer := 0;
			bar2_io_space_0_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_0_hwtcl              : string  := "Disabled";
			bar2_prefetchable_0_hwtcl                 : string  := "Disabled";
			bar3_size_mask_0_hwtcl                    : integer := 0;
			bar3_io_space_0_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_0_hwtcl                 : string  := "Disabled";
			bar4_size_mask_0_hwtcl                    : integer := 0;
			bar4_io_space_0_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_0_hwtcl              : string  := "Disabled";
			bar4_prefetchable_0_hwtcl                 : string  := "Disabled";
			bar5_size_mask_0_hwtcl                    : integer := 0;
			bar5_io_space_0_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_0_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_0_hwtcl   : integer := 0;
			io_window_addr_width_hwtcl                : integer := 0;
			prefetchable_mem_window_addr_width_hwtcl  : integer := 0;
			vendor_id_0_hwtcl                         : integer := 0;
			device_id_0_hwtcl                         : integer := 1;
			revision_id_0_hwtcl                       : integer := 1;
			class_code_0_hwtcl                        : integer := 0;
			subsystem_vendor_id_0_hwtcl               : integer := 0;
			subsystem_device_id_0_hwtcl               : integer := 0;
			max_payload_size_0_hwtcl                  : integer := 128;
			extend_tag_field_0_hwtcl                  : string  := "32";
			completion_timeout_0_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_0_hwtcl : integer := 1;
			flr_capability_0_hwtcl                    : integer := 0;
			use_aer_0_hwtcl                           : integer := 0;
			ecrc_check_capable_0_hwtcl                : integer := 0;
			ecrc_gen_capable_0_hwtcl                  : integer := 0;
			dll_active_report_support_0_hwtcl         : integer := 0;
			surprise_down_error_support_0_hwtcl       : integer := 0;
			msi_multi_message_capable_0_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_0_hwtcl      : string  := "true";
			msi_masking_capable_0_hwtcl               : string  := "false";
			msi_support_0_hwtcl                       : string  := "true";
			enable_function_msix_support_0_hwtcl      : integer := 0;
			msix_table_size_0_hwtcl                   : integer := 0;
			msix_table_offset_0_hwtcl                 : string  := "0";
			msix_table_bir_0_hwtcl                    : integer := 0;
			msix_pba_offset_0_hwtcl                   : string  := "0";
			msix_pba_bir_0_hwtcl                      : integer := 0;
			interrupt_pin_0_hwtcl                     : string  := "inta";
			slot_power_scale_0_hwtcl                  : integer := 0;
			slot_power_limit_0_hwtcl                  : integer := 0;
			slot_number_0_hwtcl                       : integer := 0;
			rx_ei_l0s_0_hwtcl                         : integer := 0;
			endpoint_l0_latency_0_hwtcl               : integer := 0;
			endpoint_l1_latency_0_hwtcl               : integer := 0;
			reconfig_to_xcvr_width                    : integer := 10;
			hip_hard_reset_hwtcl                      : integer := 0;
			reconfig_from_xcvr_width                  : integer := 10;
			single_rx_detect_hwtcl                    : integer := 0;
			enable_l0s_aspm_hwtcl                     : string  := "false";
			aspm_optionality_hwtcl                    : string  := "false";
			enable_adapter_half_rate_mode_hwtcl       : string  := "false";
			millisecond_cycle_count_hwtcl             : integer := 248500;
			credit_buffer_allocation_aux_hwtcl        : string  := "balanced";
			vc0_rx_flow_ctrl_posted_header_hwtcl      : integer := 50;
			vc0_rx_flow_ctrl_posted_data_hwtcl        : integer := 360;
			vc0_rx_flow_ctrl_nonposted_header_hwtcl   : integer := 54;
			vc0_rx_flow_ctrl_nonposted_data_hwtcl     : integer := 0;
			vc0_rx_flow_ctrl_compl_header_hwtcl       : integer := 112;
			vc0_rx_flow_ctrl_compl_data_hwtcl         : integer := 448;
			cpl_spc_header_hwtcl                      : integer := 112;
			cpl_spc_data_hwtcl                        : integer := 448;
			port_width_data_hwtcl                     : integer := 64;
			bypass_clk_switch_hwtcl                   : string  := "disable";
			cvp_rate_sel_hwtcl                        : string  := "full_rate";
			cvp_data_compressed_hwtcl                 : string  := "false";
			cvp_data_encrypted_hwtcl                  : string  := "false";
			cvp_mode_reset_hwtcl                      : string  := "false";
			cvp_clk_reset_hwtcl                       : string  := "false";
			core_clk_sel_hwtcl                        : string  := "pld_clk";
			enable_rx_buffer_checking_hwtcl           : string  := "false";
			disable_link_x2_support_hwtcl             : string  := "false";
			device_number_hwtcl                       : integer := 0;
			pipex1_debug_sel_hwtcl                    : string  := "disable";
			pclk_out_sel_hwtcl                        : string  := "pclk";
			no_soft_reset_hwtcl                       : string  := "false";
			d1_support_hwtcl                          : string  := "false";
			d2_support_hwtcl                          : string  := "false";
			d0_pme_hwtcl                              : string  := "false";
			d1_pme_hwtcl                              : string  := "false";
			d2_pme_hwtcl                              : string  := "false";
			d3_hot_pme_hwtcl                          : string  := "false";
			d3_cold_pme_hwtcl                         : string  := "false";
			low_priority_vc_hwtcl                     : string  := "single_vc";
			enable_l1_aspm_hwtcl                      : string  := "false";
			l1_exit_latency_sameclock_hwtcl           : integer := 0;
			l1_exit_latency_diffclock_hwtcl           : integer := 0;
			hot_plug_support_hwtcl                    : integer := 0;
			no_command_completed_hwtcl                : string  := "false";
			eie_before_nfts_count_hwtcl               : integer := 4;
			gen2_diffclock_nfts_count_hwtcl           : integer := 255;
			gen2_sameclock_nfts_count_hwtcl           : integer := 255;
			deemphasis_enable_hwtcl                   : string  := "false";
			l0_exit_latency_sameclock_hwtcl           : integer := 6;
			l0_exit_latency_diffclock_hwtcl           : integer := 6;
			vc0_clk_enable_hwtcl                      : string  := "true";
			register_pipe_signals_hwtcl               : string  := "true";
			tx_cdc_almost_empty_hwtcl                 : integer := 5;
			rx_l0s_count_idl_hwtcl                    : integer := 0;
			cdc_dummy_insert_limit_hwtcl              : integer := 11;
			ei_delay_powerdown_count_hwtcl            : integer := 10;
			skp_os_schedule_count_hwtcl               : integer := 0;
			fc_init_timer_hwtcl                       : integer := 1024;
			l01_entry_latency_hwtcl                   : integer := 31;
			flow_control_update_count_hwtcl           : integer := 30;
			flow_control_timeout_count_hwtcl          : integer := 200;
			retry_buffer_last_active_address_hwtcl    : integer := 255;
			reserved_debug_hwtcl                      : integer := 0;
			use_tl_cfg_sync_hwtcl                     : integer := 1;
			diffclock_nfts_count_hwtcl                : integer := 255;
			sameclock_nfts_count_hwtcl                : integer := 255;
			l2_async_logic_hwtcl                      : string  := "disable";
			rx_cdc_almost_full_hwtcl                  : integer := 12;
			tx_cdc_almost_full_hwtcl                  : integer := 11;
			indicator_hwtcl                           : integer := 0;
			maximum_current_0_hwtcl                   : integer := 0;
			disable_snoop_packet_0_hwtcl              : string  := "false";
			bridge_port_vga_enable_0_hwtcl            : string  := "false";
			bridge_port_ssid_support_0_hwtcl          : string  := "false";
			ssvid_0_hwtcl                             : integer := 0;
			ssid_0_hwtcl                              : integer := 0;
			porttype_func1_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_1_hwtcl                    : integer := 28;
			bar0_io_space_1_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_1_hwtcl              : string  := "Enabled";
			bar0_prefetchable_1_hwtcl                 : string  := "Enabled";
			bar1_size_mask_1_hwtcl                    : integer := 0;
			bar1_io_space_1_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_1_hwtcl                 : string  := "Disabled";
			bar2_size_mask_1_hwtcl                    : integer := 0;
			bar2_io_space_1_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_1_hwtcl              : string  := "Disabled";
			bar2_prefetchable_1_hwtcl                 : string  := "Disabled";
			bar3_size_mask_1_hwtcl                    : integer := 0;
			bar3_io_space_1_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_1_hwtcl                 : string  := "Disabled";
			bar4_size_mask_1_hwtcl                    : integer := 0;
			bar4_io_space_1_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_1_hwtcl              : string  := "Disabled";
			bar4_prefetchable_1_hwtcl                 : string  := "Disabled";
			bar5_size_mask_1_hwtcl                    : integer := 0;
			bar5_io_space_1_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_1_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_1_hwtcl   : integer := 0;
			vendor_id_1_hwtcl                         : integer := 0;
			device_id_1_hwtcl                         : integer := 1;
			revision_id_1_hwtcl                       : integer := 1;
			class_code_1_hwtcl                        : integer := 0;
			subsystem_vendor_id_1_hwtcl               : integer := 0;
			subsystem_device_id_1_hwtcl               : integer := 0;
			max_payload_size_1_hwtcl                  : integer := 128;
			extend_tag_field_1_hwtcl                  : string  := "32";
			completion_timeout_1_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_1_hwtcl : integer := 1;
			flr_capability_1_hwtcl                    : integer := 0;
			use_aer_1_hwtcl                           : integer := 0;
			ecrc_check_capable_1_hwtcl                : integer := 0;
			ecrc_gen_capable_1_hwtcl                  : integer := 0;
			dll_active_report_support_1_hwtcl         : integer := 0;
			surprise_down_error_support_1_hwtcl       : integer := 0;
			msi_multi_message_capable_1_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_1_hwtcl      : string  := "true";
			msi_masking_capable_1_hwtcl               : string  := "false";
			msi_support_1_hwtcl                       : string  := "true";
			enable_function_msix_support_1_hwtcl      : integer := 0;
			msix_table_size_1_hwtcl                   : integer := 0;
			msix_table_offset_1_hwtcl                 : string  := "0";
			msix_table_bir_1_hwtcl                    : integer := 0;
			msix_pba_offset_1_hwtcl                   : string  := "0";
			msix_pba_bir_1_hwtcl                      : integer := 0;
			interrupt_pin_1_hwtcl                     : string  := "inta";
			slot_power_scale_1_hwtcl                  : integer := 0;
			slot_power_limit_1_hwtcl                  : integer := 0;
			slot_number_1_hwtcl                       : integer := 0;
			rx_ei_l0s_1_hwtcl                         : integer := 0;
			endpoint_l0_latency_1_hwtcl               : integer := 0;
			endpoint_l1_latency_1_hwtcl               : integer := 0;
			maximum_current_1_hwtcl                   : integer := 0;
			disable_snoop_packet_1_hwtcl              : string  := "false";
			bridge_port_vga_enable_1_hwtcl            : string  := "false";
			bridge_port_ssid_support_1_hwtcl          : string  := "false";
			ssvid_1_hwtcl                             : integer := 0;
			ssid_1_hwtcl                              : integer := 0;
			porttype_func2_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_2_hwtcl                    : integer := 28;
			bar0_io_space_2_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_2_hwtcl              : string  := "Enabled";
			bar0_prefetchable_2_hwtcl                 : string  := "Enabled";
			bar1_size_mask_2_hwtcl                    : integer := 0;
			bar1_io_space_2_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_2_hwtcl                 : string  := "Disabled";
			bar2_size_mask_2_hwtcl                    : integer := 0;
			bar2_io_space_2_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_2_hwtcl              : string  := "Disabled";
			bar2_prefetchable_2_hwtcl                 : string  := "Disabled";
			bar3_size_mask_2_hwtcl                    : integer := 0;
			bar3_io_space_2_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_2_hwtcl                 : string  := "Disabled";
			bar4_size_mask_2_hwtcl                    : integer := 0;
			bar4_io_space_2_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_2_hwtcl              : string  := "Disabled";
			bar4_prefetchable_2_hwtcl                 : string  := "Disabled";
			bar5_size_mask_2_hwtcl                    : integer := 0;
			bar5_io_space_2_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_2_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_2_hwtcl   : integer := 0;
			vendor_id_2_hwtcl                         : integer := 0;
			device_id_2_hwtcl                         : integer := 1;
			revision_id_2_hwtcl                       : integer := 1;
			class_code_2_hwtcl                        : integer := 0;
			subsystem_vendor_id_2_hwtcl               : integer := 0;
			subsystem_device_id_2_hwtcl               : integer := 0;
			max_payload_size_2_hwtcl                  : integer := 128;
			extend_tag_field_2_hwtcl                  : string  := "32";
			completion_timeout_2_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_2_hwtcl : integer := 1;
			flr_capability_2_hwtcl                    : integer := 0;
			use_aer_2_hwtcl                           : integer := 0;
			ecrc_check_capable_2_hwtcl                : integer := 0;
			ecrc_gen_capable_2_hwtcl                  : integer := 0;
			dll_active_report_support_2_hwtcl         : integer := 0;
			surprise_down_error_support_2_hwtcl       : integer := 0;
			msi_multi_message_capable_2_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_2_hwtcl      : string  := "true";
			msi_masking_capable_2_hwtcl               : string  := "false";
			msi_support_2_hwtcl                       : string  := "true";
			enable_function_msix_support_2_hwtcl      : integer := 0;
			msix_table_size_2_hwtcl                   : integer := 0;
			msix_table_offset_2_hwtcl                 : string  := "0";
			msix_table_bir_2_hwtcl                    : integer := 0;
			msix_pba_offset_2_hwtcl                   : string  := "0";
			msix_pba_bir_2_hwtcl                      : integer := 0;
			interrupt_pin_2_hwtcl                     : string  := "inta";
			slot_power_scale_2_hwtcl                  : integer := 0;
			slot_power_limit_2_hwtcl                  : integer := 0;
			slot_number_2_hwtcl                       : integer := 0;
			rx_ei_l0s_2_hwtcl                         : integer := 0;
			endpoint_l0_latency_2_hwtcl               : integer := 0;
			endpoint_l1_latency_2_hwtcl               : integer := 0;
			maximum_current_2_hwtcl                   : integer := 0;
			disable_snoop_packet_2_hwtcl              : string  := "false";
			bridge_port_vga_enable_2_hwtcl            : string  := "false";
			bridge_port_ssid_support_2_hwtcl          : string  := "false";
			ssvid_2_hwtcl                             : integer := 0;
			ssid_2_hwtcl                              : integer := 0;
			porttype_func3_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_3_hwtcl                    : integer := 28;
			bar0_io_space_3_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_3_hwtcl              : string  := "Enabled";
			bar0_prefetchable_3_hwtcl                 : string  := "Enabled";
			bar1_size_mask_3_hwtcl                    : integer := 0;
			bar1_io_space_3_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_3_hwtcl                 : string  := "Disabled";
			bar2_size_mask_3_hwtcl                    : integer := 0;
			bar2_io_space_3_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_3_hwtcl              : string  := "Disabled";
			bar2_prefetchable_3_hwtcl                 : string  := "Disabled";
			bar3_size_mask_3_hwtcl                    : integer := 0;
			bar3_io_space_3_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_3_hwtcl                 : string  := "Disabled";
			bar4_size_mask_3_hwtcl                    : integer := 0;
			bar4_io_space_3_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_3_hwtcl              : string  := "Disabled";
			bar4_prefetchable_3_hwtcl                 : string  := "Disabled";
			bar5_size_mask_3_hwtcl                    : integer := 0;
			bar5_io_space_3_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_3_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_3_hwtcl   : integer := 0;
			vendor_id_3_hwtcl                         : integer := 0;
			device_id_3_hwtcl                         : integer := 1;
			revision_id_3_hwtcl                       : integer := 1;
			class_code_3_hwtcl                        : integer := 0;
			subsystem_vendor_id_3_hwtcl               : integer := 0;
			subsystem_device_id_3_hwtcl               : integer := 0;
			max_payload_size_3_hwtcl                  : integer := 128;
			extend_tag_field_3_hwtcl                  : string  := "32";
			completion_timeout_3_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_3_hwtcl : integer := 1;
			flr_capability_3_hwtcl                    : integer := 0;
			use_aer_3_hwtcl                           : integer := 0;
			ecrc_check_capable_3_hwtcl                : integer := 0;
			ecrc_gen_capable_3_hwtcl                  : integer := 0;
			dll_active_report_support_3_hwtcl         : integer := 0;
			surprise_down_error_support_3_hwtcl       : integer := 0;
			msi_multi_message_capable_3_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_3_hwtcl      : string  := "true";
			msi_masking_capable_3_hwtcl               : string  := "false";
			msi_support_3_hwtcl                       : string  := "true";
			enable_function_msix_support_3_hwtcl      : integer := 0;
			msix_table_size_3_hwtcl                   : integer := 0;
			msix_table_offset_3_hwtcl                 : string  := "0";
			msix_table_bir_3_hwtcl                    : integer := 0;
			msix_pba_offset_3_hwtcl                   : string  := "0";
			msix_pba_bir_3_hwtcl                      : integer := 0;
			interrupt_pin_3_hwtcl                     : string  := "inta";
			slot_power_scale_3_hwtcl                  : integer := 0;
			slot_power_limit_3_hwtcl                  : integer := 0;
			slot_number_3_hwtcl                       : integer := 0;
			rx_ei_l0s_3_hwtcl                         : integer := 0;
			endpoint_l0_latency_3_hwtcl               : integer := 0;
			endpoint_l1_latency_3_hwtcl               : integer := 0;
			maximum_current_3_hwtcl                   : integer := 0;
			disable_snoop_packet_3_hwtcl              : string  := "false";
			bridge_port_vga_enable_3_hwtcl            : string  := "false";
			bridge_port_ssid_support_3_hwtcl          : string  := "false";
			ssvid_3_hwtcl                             : integer := 0;
			ssid_3_hwtcl                              : integer := 0;
			porttype_func4_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_4_hwtcl                    : integer := 28;
			bar0_io_space_4_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_4_hwtcl              : string  := "Enabled";
			bar0_prefetchable_4_hwtcl                 : string  := "Enabled";
			bar1_size_mask_4_hwtcl                    : integer := 0;
			bar1_io_space_4_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_4_hwtcl                 : string  := "Disabled";
			bar2_size_mask_4_hwtcl                    : integer := 0;
			bar2_io_space_4_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_4_hwtcl              : string  := "Disabled";
			bar2_prefetchable_4_hwtcl                 : string  := "Disabled";
			bar3_size_mask_4_hwtcl                    : integer := 0;
			bar3_io_space_4_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_4_hwtcl                 : string  := "Disabled";
			bar4_size_mask_4_hwtcl                    : integer := 0;
			bar4_io_space_4_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_4_hwtcl              : string  := "Disabled";
			bar4_prefetchable_4_hwtcl                 : string  := "Disabled";
			bar5_size_mask_4_hwtcl                    : integer := 0;
			bar5_io_space_4_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_4_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_4_hwtcl   : integer := 0;
			vendor_id_4_hwtcl                         : integer := 0;
			device_id_4_hwtcl                         : integer := 1;
			revision_id_4_hwtcl                       : integer := 1;
			class_code_4_hwtcl                        : integer := 0;
			subsystem_vendor_id_4_hwtcl               : integer := 0;
			subsystem_device_id_4_hwtcl               : integer := 0;
			max_payload_size_4_hwtcl                  : integer := 128;
			extend_tag_field_4_hwtcl                  : string  := "32";
			completion_timeout_4_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_4_hwtcl : integer := 1;
			flr_capability_4_hwtcl                    : integer := 0;
			use_aer_4_hwtcl                           : integer := 0;
			ecrc_check_capable_4_hwtcl                : integer := 0;
			ecrc_gen_capable_4_hwtcl                  : integer := 0;
			dll_active_report_support_4_hwtcl         : integer := 0;
			surprise_down_error_support_4_hwtcl       : integer := 0;
			msi_multi_message_capable_4_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_4_hwtcl      : string  := "true";
			msi_masking_capable_4_hwtcl               : string  := "false";
			msi_support_4_hwtcl                       : string  := "true";
			enable_function_msix_support_4_hwtcl      : integer := 0;
			msix_table_size_4_hwtcl                   : integer := 0;
			msix_table_offset_4_hwtcl                 : string  := "0";
			msix_table_bir_4_hwtcl                    : integer := 0;
			msix_pba_offset_4_hwtcl                   : string  := "0";
			msix_pba_bir_4_hwtcl                      : integer := 0;
			interrupt_pin_4_hwtcl                     : string  := "inta";
			slot_power_scale_4_hwtcl                  : integer := 0;
			slot_power_limit_4_hwtcl                  : integer := 0;
			slot_number_4_hwtcl                       : integer := 0;
			rx_ei_l0s_4_hwtcl                         : integer := 0;
			endpoint_l0_latency_4_hwtcl               : integer := 0;
			endpoint_l1_latency_4_hwtcl               : integer := 0;
			maximum_current_4_hwtcl                   : integer := 0;
			disable_snoop_packet_4_hwtcl              : string  := "false";
			bridge_port_vga_enable_4_hwtcl            : string  := "false";
			bridge_port_ssid_support_4_hwtcl          : string  := "false";
			ssvid_4_hwtcl                             : integer := 0;
			ssid_4_hwtcl                              : integer := 0;
			porttype_func5_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_5_hwtcl                    : integer := 28;
			bar0_io_space_5_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_5_hwtcl              : string  := "Enabled";
			bar0_prefetchable_5_hwtcl                 : string  := "Enabled";
			bar1_size_mask_5_hwtcl                    : integer := 0;
			bar1_io_space_5_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_5_hwtcl                 : string  := "Disabled";
			bar2_size_mask_5_hwtcl                    : integer := 0;
			bar2_io_space_5_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_5_hwtcl              : string  := "Disabled";
			bar2_prefetchable_5_hwtcl                 : string  := "Disabled";
			bar3_size_mask_5_hwtcl                    : integer := 0;
			bar3_io_space_5_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_5_hwtcl                 : string  := "Disabled";
			bar4_size_mask_5_hwtcl                    : integer := 0;
			bar4_io_space_5_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_5_hwtcl              : string  := "Disabled";
			bar4_prefetchable_5_hwtcl                 : string  := "Disabled";
			bar5_size_mask_5_hwtcl                    : integer := 0;
			bar5_io_space_5_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_5_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_5_hwtcl   : integer := 0;
			vendor_id_5_hwtcl                         : integer := 0;
			device_id_5_hwtcl                         : integer := 1;
			revision_id_5_hwtcl                       : integer := 1;
			class_code_5_hwtcl                        : integer := 0;
			subsystem_vendor_id_5_hwtcl               : integer := 0;
			subsystem_device_id_5_hwtcl               : integer := 0;
			max_payload_size_5_hwtcl                  : integer := 128;
			extend_tag_field_5_hwtcl                  : string  := "32";
			completion_timeout_5_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_5_hwtcl : integer := 1;
			flr_capability_5_hwtcl                    : integer := 0;
			use_aer_5_hwtcl                           : integer := 0;
			ecrc_check_capable_5_hwtcl                : integer := 0;
			ecrc_gen_capable_5_hwtcl                  : integer := 0;
			dll_active_report_support_5_hwtcl         : integer := 0;
			surprise_down_error_support_5_hwtcl       : integer := 0;
			msi_multi_message_capable_5_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_5_hwtcl      : string  := "true";
			msi_masking_capable_5_hwtcl               : string  := "false";
			msi_support_5_hwtcl                       : string  := "true";
			enable_function_msix_support_5_hwtcl      : integer := 0;
			msix_table_size_5_hwtcl                   : integer := 0;
			msix_table_offset_5_hwtcl                 : string  := "0";
			msix_table_bir_5_hwtcl                    : integer := 0;
			msix_pba_offset_5_hwtcl                   : string  := "0";
			msix_pba_bir_5_hwtcl                      : integer := 0;
			interrupt_pin_5_hwtcl                     : string  := "inta";
			slot_power_scale_5_hwtcl                  : integer := 0;
			slot_power_limit_5_hwtcl                  : integer := 0;
			slot_number_5_hwtcl                       : integer := 0;
			rx_ei_l0s_5_hwtcl                         : integer := 0;
			endpoint_l0_latency_5_hwtcl               : integer := 0;
			endpoint_l1_latency_5_hwtcl               : integer := 0;
			maximum_current_5_hwtcl                   : integer := 0;
			disable_snoop_packet_5_hwtcl              : string  := "false";
			bridge_port_vga_enable_5_hwtcl            : string  := "false";
			bridge_port_ssid_support_5_hwtcl          : string  := "false";
			ssvid_5_hwtcl                             : integer := 0;
			ssid_5_hwtcl                              : integer := 0;
			porttype_func6_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_6_hwtcl                    : integer := 28;
			bar0_io_space_6_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_6_hwtcl              : string  := "Enabled";
			bar0_prefetchable_6_hwtcl                 : string  := "Enabled";
			bar1_size_mask_6_hwtcl                    : integer := 0;
			bar1_io_space_6_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_6_hwtcl                 : string  := "Disabled";
			bar2_size_mask_6_hwtcl                    : integer := 0;
			bar2_io_space_6_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_6_hwtcl              : string  := "Disabled";
			bar2_prefetchable_6_hwtcl                 : string  := "Disabled";
			bar3_size_mask_6_hwtcl                    : integer := 0;
			bar3_io_space_6_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_6_hwtcl                 : string  := "Disabled";
			bar4_size_mask_6_hwtcl                    : integer := 0;
			bar4_io_space_6_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_6_hwtcl              : string  := "Disabled";
			bar4_prefetchable_6_hwtcl                 : string  := "Disabled";
			bar5_size_mask_6_hwtcl                    : integer := 0;
			bar5_io_space_6_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_6_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_6_hwtcl   : integer := 0;
			vendor_id_6_hwtcl                         : integer := 0;
			device_id_6_hwtcl                         : integer := 1;
			revision_id_6_hwtcl                       : integer := 1;
			class_code_6_hwtcl                        : integer := 0;
			subsystem_vendor_id_6_hwtcl               : integer := 0;
			subsystem_device_id_6_hwtcl               : integer := 0;
			max_payload_size_6_hwtcl                  : integer := 128;
			extend_tag_field_6_hwtcl                  : string  := "32";
			completion_timeout_6_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_6_hwtcl : integer := 1;
			flr_capability_6_hwtcl                    : integer := 0;
			use_aer_6_hwtcl                           : integer := 0;
			ecrc_check_capable_6_hwtcl                : integer := 0;
			ecrc_gen_capable_6_hwtcl                  : integer := 0;
			dll_active_report_support_6_hwtcl         : integer := 0;
			surprise_down_error_support_6_hwtcl       : integer := 0;
			msi_multi_message_capable_6_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_6_hwtcl      : string  := "true";
			msi_masking_capable_6_hwtcl               : string  := "false";
			msi_support_6_hwtcl                       : string  := "true";
			enable_function_msix_support_6_hwtcl      : integer := 0;
			msix_table_size_6_hwtcl                   : integer := 0;
			msix_table_offset_6_hwtcl                 : string  := "0";
			msix_table_bir_6_hwtcl                    : integer := 0;
			msix_pba_offset_6_hwtcl                   : string  := "0";
			msix_pba_bir_6_hwtcl                      : integer := 0;
			interrupt_pin_6_hwtcl                     : string  := "inta";
			slot_power_scale_6_hwtcl                  : integer := 0;
			slot_power_limit_6_hwtcl                  : integer := 0;
			slot_number_6_hwtcl                       : integer := 0;
			rx_ei_l0s_6_hwtcl                         : integer := 0;
			endpoint_l0_latency_6_hwtcl               : integer := 0;
			endpoint_l1_latency_6_hwtcl               : integer := 0;
			maximum_current_6_hwtcl                   : integer := 0;
			disable_snoop_packet_6_hwtcl              : string  := "false";
			bridge_port_vga_enable_6_hwtcl            : string  := "false";
			bridge_port_ssid_support_6_hwtcl          : string  := "false";
			ssvid_6_hwtcl                             : integer := 0;
			ssid_6_hwtcl                              : integer := 0;
			porttype_func7_hwtcl                      : string  := "Native endpoint";
			bar0_size_mask_7_hwtcl                    : integer := 28;
			bar0_io_space_7_hwtcl                     : string  := "Disabled";
			bar0_64bit_mem_space_7_hwtcl              : string  := "Enabled";
			bar0_prefetchable_7_hwtcl                 : string  := "Enabled";
			bar1_size_mask_7_hwtcl                    : integer := 0;
			bar1_io_space_7_hwtcl                     : string  := "Disabled";
			bar1_prefetchable_7_hwtcl                 : string  := "Disabled";
			bar2_size_mask_7_hwtcl                    : integer := 0;
			bar2_io_space_7_hwtcl                     : string  := "Disabled";
			bar2_64bit_mem_space_7_hwtcl              : string  := "Disabled";
			bar2_prefetchable_7_hwtcl                 : string  := "Disabled";
			bar3_size_mask_7_hwtcl                    : integer := 0;
			bar3_io_space_7_hwtcl                     : string  := "Disabled";
			bar3_prefetchable_7_hwtcl                 : string  := "Disabled";
			bar4_size_mask_7_hwtcl                    : integer := 0;
			bar4_io_space_7_hwtcl                     : string  := "Disabled";
			bar4_64bit_mem_space_7_hwtcl              : string  := "Disabled";
			bar4_prefetchable_7_hwtcl                 : string  := "Disabled";
			bar5_size_mask_7_hwtcl                    : integer := 0;
			bar5_io_space_7_hwtcl                     : string  := "Disabled";
			bar5_prefetchable_7_hwtcl                 : string  := "Disabled";
			expansion_base_address_register_7_hwtcl   : integer := 0;
			vendor_id_7_hwtcl                         : integer := 0;
			device_id_7_hwtcl                         : integer := 1;
			revision_id_7_hwtcl                       : integer := 1;
			class_code_7_hwtcl                        : integer := 0;
			subsystem_vendor_id_7_hwtcl               : integer := 0;
			subsystem_device_id_7_hwtcl               : integer := 0;
			max_payload_size_7_hwtcl                  : integer := 128;
			extend_tag_field_7_hwtcl                  : string  := "32";
			completion_timeout_7_hwtcl                : string  := "ABCD";
			enable_completion_timeout_disable_7_hwtcl : integer := 1;
			flr_capability_7_hwtcl                    : integer := 0;
			use_aer_7_hwtcl                           : integer := 0;
			ecrc_check_capable_7_hwtcl                : integer := 0;
			ecrc_gen_capable_7_hwtcl                  : integer := 0;
			dll_active_report_support_7_hwtcl         : integer := 0;
			surprise_down_error_support_7_hwtcl       : integer := 0;
			msi_multi_message_capable_7_hwtcl         : string  := "4";
			msi_64bit_addressing_capable_7_hwtcl      : string  := "true";
			msi_masking_capable_7_hwtcl               : string  := "false";
			msi_support_7_hwtcl                       : string  := "true";
			enable_function_msix_support_7_hwtcl      : integer := 0;
			msix_table_size_7_hwtcl                   : integer := 0;
			msix_table_offset_7_hwtcl                 : string  := "0";
			msix_table_bir_7_hwtcl                    : integer := 0;
			msix_pba_offset_7_hwtcl                   : string  := "0";
			msix_pba_bir_7_hwtcl                      : integer := 0;
			interrupt_pin_7_hwtcl                     : string  := "inta";
			slot_power_scale_7_hwtcl                  : integer := 0;
			slot_power_limit_7_hwtcl                  : integer := 0;
			slot_number_7_hwtcl                       : integer := 0;
			rx_ei_l0s_7_hwtcl                         : integer := 0;
			endpoint_l0_latency_7_hwtcl               : integer := 0;
			endpoint_l1_latency_7_hwtcl               : integer := 0;
			maximum_current_7_hwtcl                   : integer := 0;
			disable_snoop_packet_7_hwtcl              : string  := "false";
			bridge_port_vga_enable_7_hwtcl            : string  := "false";
			bridge_port_ssid_support_7_hwtcl          : string  := "false";
			ssvid_7_hwtcl                             : integer := 0;
			ssid_7_hwtcl                              : integer := 0;
			rpre_emph_a_val_hwtcl                     : integer := 11;
			rpre_emph_b_val_hwtcl                     : integer := 0;
			rpre_emph_c_val_hwtcl                     : integer := 22;
			rpre_emph_d_val_hwtcl                     : integer := 12;
			rpre_emph_e_val_hwtcl                     : integer := 21;
			rvod_sel_a_val_hwtcl                      : integer := 50;
			rvod_sel_b_val_hwtcl                      : integer := 34;
			rvod_sel_c_val_hwtcl                      : integer := 50;
			rvod_sel_d_val_hwtcl                      : integer := 50;
			rvod_sel_e_val_hwtcl                      : integer := 9
		);
		port (
			npor                   : in  std_logic                      := 'X';             -- npor
			pin_perst              : in  std_logic                      := 'X';             -- pin_perst
			test_in                : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- test_in
			simu_mode_pipe         : in  std_logic                      := 'X';             -- simu_mode_pipe
			pld_clk                : in  std_logic                      := 'X';             -- clk
			coreclkout             : out std_logic;                                         -- clk
			refclk                 : in  std_logic                      := 'X';             -- clk
			rx_in0                 : in  std_logic                      := 'X';             -- rx_in0
			rx_in1                 : in  std_logic                      := 'X';             -- rx_in1
			rx_in2                 : in  std_logic                      := 'X';             -- rx_in2
			rx_in3                 : in  std_logic                      := 'X';             -- rx_in3
			tx_out0                : out std_logic;                                         -- tx_out0
			tx_out1                : out std_logic;                                         -- tx_out1
			tx_out2                : out std_logic;                                         -- tx_out2
			tx_out3                : out std_logic;                                         -- tx_out3
			rx_st_valid            : out std_logic;                                         -- valid
			rx_st_sop              : out std_logic;                                         -- startofpacket
			rx_st_eop              : out std_logic;                                         -- endofpacket
			rx_st_ready            : in  std_logic                      := 'X';             -- ready
			rx_st_err              : out std_logic;                                         -- error
			rx_st_data             : out std_logic_vector(63 downto 0);                     -- data
			rx_st_bar              : out std_logic_vector(7 downto 0);                      -- rx_st_bar
			rx_st_be               : out std_logic_vector(7 downto 0);                      -- rx_st_be
			rx_st_mask             : in  std_logic                      := 'X';             -- rx_st_mask
			tx_st_valid            : in  std_logic                      := 'X';             -- valid
			tx_st_sop              : in  std_logic                      := 'X';             -- startofpacket
			tx_st_eop              : in  std_logic                      := 'X';             -- endofpacket
			tx_st_ready            : out std_logic;                                         -- ready
			tx_st_err              : in  std_logic                      := 'X';             -- error
			tx_st_data             : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- data
			tx_fifo_empty          : out std_logic;                                         -- fifo_empty
			tx_cred_datafccp       : out std_logic_vector(11 downto 0);                     -- tx_cred_datafccp
			tx_cred_datafcnp       : out std_logic_vector(11 downto 0);                     -- tx_cred_datafcnp
			tx_cred_datafcp        : out std_logic_vector(11 downto 0);                     -- tx_cred_datafcp
			tx_cred_fchipcons      : out std_logic_vector(5 downto 0);                      -- tx_cred_fchipcons
			tx_cred_fcinfinite     : out std_logic_vector(5 downto 0);                      -- tx_cred_fcinfinite
			tx_cred_hdrfccp        : out std_logic_vector(7 downto 0);                      -- tx_cred_hdrfccp
			tx_cred_hdrfcnp        : out std_logic_vector(7 downto 0);                      -- tx_cred_hdrfcnp
			tx_cred_hdrfcp         : out std_logic_vector(7 downto 0);                      -- tx_cred_hdrfcp
			sim_pipe_pclk_in       : in  std_logic                      := 'X';             -- sim_pipe_pclk_in
			sim_pipe_rate          : out std_logic_vector(1 downto 0);                      -- sim_pipe_rate
			sim_ltssmstate         : out std_logic_vector(4 downto 0);                      -- sim_ltssmstate
			eidleinfersel0         : out std_logic_vector(2 downto 0);                      -- eidleinfersel0
			eidleinfersel1         : out std_logic_vector(2 downto 0);                      -- eidleinfersel1
			eidleinfersel2         : out std_logic_vector(2 downto 0);                      -- eidleinfersel2
			eidleinfersel3         : out std_logic_vector(2 downto 0);                      -- eidleinfersel3
			powerdown0             : out std_logic_vector(1 downto 0);                      -- powerdown0
			powerdown1             : out std_logic_vector(1 downto 0);                      -- powerdown1
			powerdown2             : out std_logic_vector(1 downto 0);                      -- powerdown2
			powerdown3             : out std_logic_vector(1 downto 0);                      -- powerdown3
			rxpolarity0            : out std_logic;                                         -- rxpolarity0
			rxpolarity1            : out std_logic;                                         -- rxpolarity1
			rxpolarity2            : out std_logic;                                         -- rxpolarity2
			rxpolarity3            : out std_logic;                                         -- rxpolarity3
			txcompl0               : out std_logic;                                         -- txcompl0
			txcompl1               : out std_logic;                                         -- txcompl1
			txcompl2               : out std_logic;                                         -- txcompl2
			txcompl3               : out std_logic;                                         -- txcompl3
			txdata0                : out std_logic_vector(7 downto 0);                      -- txdata0
			txdata1                : out std_logic_vector(7 downto 0);                      -- txdata1
			txdata2                : out std_logic_vector(7 downto 0);                      -- txdata2
			txdata3                : out std_logic_vector(7 downto 0);                      -- txdata3
			txdatak0               : out std_logic;                                         -- txdatak0
			txdatak1               : out std_logic;                                         -- txdatak1
			txdatak2               : out std_logic;                                         -- txdatak2
			txdatak3               : out std_logic;                                         -- txdatak3
			txdetectrx0            : out std_logic;                                         -- txdetectrx0
			txdetectrx1            : out std_logic;                                         -- txdetectrx1
			txdetectrx2            : out std_logic;                                         -- txdetectrx2
			txdetectrx3            : out std_logic;                                         -- txdetectrx3
			txelecidle0            : out std_logic;                                         -- txelecidle0
			txelecidle1            : out std_logic;                                         -- txelecidle1
			txelecidle2            : out std_logic;                                         -- txelecidle2
			txelecidle3            : out std_logic;                                         -- txelecidle3
			txswing0               : out std_logic;                                         -- txswing0
			txswing1               : out std_logic;                                         -- txswing1
			txswing2               : out std_logic;                                         -- txswing2
			txswing3               : out std_logic;                                         -- txswing3
			txmargin0              : out std_logic_vector(2 downto 0);                      -- txmargin0
			txmargin1              : out std_logic_vector(2 downto 0);                      -- txmargin1
			txmargin2              : out std_logic_vector(2 downto 0);                      -- txmargin2
			txmargin3              : out std_logic_vector(2 downto 0);                      -- txmargin3
			txdeemph0              : out std_logic;                                         -- txdeemph0
			txdeemph1              : out std_logic;                                         -- txdeemph1
			txdeemph2              : out std_logic;                                         -- txdeemph2
			txdeemph3              : out std_logic;                                         -- txdeemph3
			phystatus0             : in  std_logic                      := 'X';             -- phystatus0
			phystatus1             : in  std_logic                      := 'X';             -- phystatus1
			phystatus2             : in  std_logic                      := 'X';             -- phystatus2
			phystatus3             : in  std_logic                      := 'X';             -- phystatus3
			rxdata0                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata0
			rxdata1                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata1
			rxdata2                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata2
			rxdata3                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata3
			rxdatak0               : in  std_logic                      := 'X';             -- rxdatak0
			rxdatak1               : in  std_logic                      := 'X';             -- rxdatak1
			rxdatak2               : in  std_logic                      := 'X';             -- rxdatak2
			rxdatak3               : in  std_logic                      := 'X';             -- rxdatak3
			rxelecidle0            : in  std_logic                      := 'X';             -- rxelecidle0
			rxelecidle1            : in  std_logic                      := 'X';             -- rxelecidle1
			rxelecidle2            : in  std_logic                      := 'X';             -- rxelecidle2
			rxelecidle3            : in  std_logic                      := 'X';             -- rxelecidle3
			rxstatus0              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus0
			rxstatus1              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus1
			rxstatus2              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus2
			rxstatus3              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus3
			rxvalid0               : in  std_logic                      := 'X';             -- rxvalid0
			rxvalid1               : in  std_logic                      := 'X';             -- rxvalid1
			rxvalid2               : in  std_logic                      := 'X';             -- rxvalid2
			rxvalid3               : in  std_logic                      := 'X';             -- rxvalid3
			reset_status           : out std_logic;                                         -- reset_status
			serdes_pll_locked      : out std_logic;                                         -- serdes_pll_locked
			pld_clk_inuse          : out std_logic;                                         -- pld_clk_inuse
			pld_core_ready         : in  std_logic                      := 'X';             -- pld_core_ready
			testin_zero            : out std_logic;                                         -- testin_zero
			lmi_addr               : in  std_logic_vector(11 downto 0)  := (others => 'X'); -- lmi_addr
			lmi_din                : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- lmi_din
			lmi_rden               : in  std_logic                      := 'X';             -- lmi_rden
			lmi_wren               : in  std_logic                      := 'X';             -- lmi_wren
			lmi_ack                : out std_logic;                                         -- lmi_ack
			lmi_dout               : out std_logic_vector(31 downto 0);                     -- lmi_dout
			pm_auxpwr              : in  std_logic                      := 'X';             -- pm_auxpwr
			pm_data                : in  std_logic_vector(9 downto 0)   := (others => 'X'); -- pm_data
			pme_to_cr              : in  std_logic                      := 'X';             -- pme_to_cr
			pm_event               : in  std_logic                      := 'X';             -- pm_event
			pme_to_sr              : out std_logic;                                         -- pme_to_sr
			reconfig_to_xcvr       : in  std_logic_vector(349 downto 0) := (others => 'X'); -- reconfig_to_xcvr
			reconfig_from_xcvr     : out std_logic_vector(229 downto 0);                    -- reconfig_from_xcvr
			app_msi_num            : in  std_logic_vector(4 downto 0)   := (others => 'X'); -- app_msi_num
			app_msi_req            : in  std_logic                      := 'X';             -- app_msi_req
			app_msi_tc             : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- app_msi_tc
			app_msi_ack            : out std_logic;                                         -- app_msi_ack
			app_int_sts_vec        : in  std_logic                      := 'X';             -- app_int_sts
			tl_hpg_ctrl_er         : in  std_logic_vector(4 downto 0)   := (others => 'X'); -- hpg_ctrler
			tl_cfg_ctl             : out std_logic_vector(31 downto 0);                     -- tl_cfg_ctl
			cpl_err                : in  std_logic_vector(6 downto 0)   := (others => 'X'); -- cpl_err
			tl_cfg_add             : out std_logic_vector(3 downto 0);                      -- tl_cfg_add
			tl_cfg_ctl_wr          : out std_logic;                                         -- tl_cfg_ctl_wr
			tl_cfg_sts_wr          : out std_logic;                                         -- tl_cfg_sts_wr
			tl_cfg_sts             : out std_logic_vector(52 downto 0);                     -- tl_cfg_sts
			cpl_pending            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- cpl_pending
			derr_cor_ext_rcv0      : out std_logic;                                         -- derr_cor_ext_rcv
			derr_cor_ext_rpl       : out std_logic;                                         -- derr_cor_ext_rpl
			derr_rpl               : out std_logic;                                         -- derr_rpl
			dlup_exit              : out std_logic;                                         -- dlup_exit
			dl_ltssm               : out std_logic_vector(4 downto 0);                      -- ltssmstate
			ev128ns                : out std_logic;                                         -- ev128ns
			ev1us                  : out std_logic;                                         -- ev1us
			hotrst_exit            : out std_logic;                                         -- hotrst_exit
			int_status             : out std_logic_vector(3 downto 0);                      -- int_status
			l2_exit                : out std_logic;                                         -- l2_exit
			lane_act               : out std_logic_vector(3 downto 0);                      -- lane_act
			ko_cpl_spc_header      : out std_logic_vector(7 downto 0);                      -- ko_cpl_spc_header
			ko_cpl_spc_data        : out std_logic_vector(11 downto 0);                     -- ko_cpl_spc_data
			dl_current_speed       : out std_logic_vector(1 downto 0);                      -- currentspeed
			rx_in4                 : in  std_logic                      := 'X';             -- rx_in4
			rx_in5                 : in  std_logic                      := 'X';             -- rx_in5
			rx_in6                 : in  std_logic                      := 'X';             -- rx_in6
			rx_in7                 : in  std_logic                      := 'X';             -- rx_in7
			tx_out4                : out std_logic;                                         -- tx_out4
			tx_out5                : out std_logic;                                         -- tx_out5
			tx_out6                : out std_logic;                                         -- tx_out6
			tx_out7                : out std_logic;                                         -- tx_out7
			rx_st_empty            : out std_logic;                                         -- rx_st_empty
			rx_fifo_empty          : out std_logic;                                         -- rx_fifo_empty
			rx_fifo_full           : out std_logic;                                         -- rx_fifo_full
			rx_bar_dec_func_num    : out std_logic_vector(2 downto 0);                      -- rx_bar_dec_func_num
			tx_st_empty            : in  std_logic                      := 'X';             -- tx_st_empty
			tx_fifo_full           : out std_logic;                                         -- tx_fifo_full
			tx_fifo_rdp            : out std_logic_vector(3 downto 0);                      -- tx_fifo_rdp
			tx_fifo_wrp            : out std_logic_vector(3 downto 0);                      -- tx_fifo_wrp
			eidleinfersel4         : out std_logic_vector(2 downto 0);                      -- eidleinfersel4
			eidleinfersel5         : out std_logic_vector(2 downto 0);                      -- eidleinfersel5
			eidleinfersel6         : out std_logic_vector(2 downto 0);                      -- eidleinfersel6
			eidleinfersel7         : out std_logic_vector(2 downto 0);                      -- eidleinfersel7
			powerdown4             : out std_logic_vector(1 downto 0);                      -- powerdown4
			powerdown5             : out std_logic_vector(1 downto 0);                      -- powerdown5
			powerdown6             : out std_logic_vector(1 downto 0);                      -- powerdown6
			powerdown7             : out std_logic_vector(1 downto 0);                      -- powerdown7
			rxpolarity4            : out std_logic;                                         -- rxpolarity4
			rxpolarity5            : out std_logic;                                         -- rxpolarity5
			rxpolarity6            : out std_logic;                                         -- rxpolarity6
			rxpolarity7            : out std_logic;                                         -- rxpolarity7
			txcompl4               : out std_logic;                                         -- txcompl4
			txcompl5               : out std_logic;                                         -- txcompl5
			txcompl6               : out std_logic;                                         -- txcompl6
			txcompl7               : out std_logic;                                         -- txcompl7
			txdata4                : out std_logic_vector(7 downto 0);                      -- txdata4
			txdata5                : out std_logic_vector(7 downto 0);                      -- txdata5
			txdata6                : out std_logic_vector(7 downto 0);                      -- txdata6
			txdata7                : out std_logic_vector(7 downto 0);                      -- txdata7
			txdatak4               : out std_logic;                                         -- txdatak4
			txdatak5               : out std_logic;                                         -- txdatak5
			txdatak6               : out std_logic;                                         -- txdatak6
			txdatak7               : out std_logic;                                         -- txdatak7
			txdetectrx4            : out std_logic;                                         -- txdetectrx4
			txdetectrx5            : out std_logic;                                         -- txdetectrx5
			txdetectrx6            : out std_logic;                                         -- txdetectrx6
			txdetectrx7            : out std_logic;                                         -- txdetectrx7
			txelecidle4            : out std_logic;                                         -- txelecidle4
			txelecidle5            : out std_logic;                                         -- txelecidle5
			txelecidle6            : out std_logic;                                         -- txelecidle6
			txelecidle7            : out std_logic;                                         -- txelecidle7
			txswing4               : out std_logic;                                         -- txswing4
			txswing5               : out std_logic;                                         -- txswing5
			txswing6               : out std_logic;                                         -- txswing6
			txswing7               : out std_logic;                                         -- txswing7
			txmargin4              : out std_logic_vector(2 downto 0);                      -- txmargin4
			txmargin5              : out std_logic_vector(2 downto 0);                      -- txmargin5
			txmargin6              : out std_logic_vector(2 downto 0);                      -- txmargin6
			txmargin7              : out std_logic_vector(2 downto 0);                      -- txmargin7
			txdeemph4              : out std_logic;                                         -- txdeemph4
			txdeemph5              : out std_logic;                                         -- txdeemph5
			txdeemph6              : out std_logic;                                         -- txdeemph6
			txdeemph7              : out std_logic;                                         -- txdeemph7
			phystatus4             : in  std_logic                      := 'X';             -- phystatus4
			phystatus5             : in  std_logic                      := 'X';             -- phystatus5
			phystatus6             : in  std_logic                      := 'X';             -- phystatus6
			phystatus7             : in  std_logic                      := 'X';             -- phystatus7
			rxdata4                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata4
			rxdata5                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata5
			rxdata6                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata6
			rxdata7                : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- rxdata7
			rxdatak4               : in  std_logic                      := 'X';             -- rxdatak4
			rxdatak5               : in  std_logic                      := 'X';             -- rxdatak5
			rxdatak6               : in  std_logic                      := 'X';             -- rxdatak6
			rxdatak7               : in  std_logic                      := 'X';             -- rxdatak7
			rxelecidle4            : in  std_logic                      := 'X';             -- rxelecidle4
			rxelecidle5            : in  std_logic                      := 'X';             -- rxelecidle5
			rxelecidle6            : in  std_logic                      := 'X';             -- rxelecidle6
			rxelecidle7            : in  std_logic                      := 'X';             -- rxelecidle7
			rxstatus4              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus4
			rxstatus5              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus5
			rxstatus6              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus6
			rxstatus7              : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- rxstatus7
			rxvalid4               : in  std_logic                      := 'X';             -- rxvalid4
			rxvalid5               : in  std_logic                      := 'X';             -- rxvalid5
			rxvalid6               : in  std_logic                      := 'X';             -- rxvalid6
			rxvalid7               : in  std_logic                      := 'X';             -- rxvalid7
			sim_pipe_pclk_out      : out std_logic;                                         -- sim_pipe_pclk_out
			pm_event_func          : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- pm_event_func
			hip_reconfig_clk       : in  std_logic                      := 'X';             -- hip_reconfig_clk
			hip_reconfig_rst_n     : in  std_logic                      := 'X';             -- hip_reconfig_rst_n
			hip_reconfig_address   : in  std_logic_vector(9 downto 0)   := (others => 'X'); -- hip_reconfig_address
			hip_reconfig_byte_en   : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- hip_reconfig_byte_en
			hip_reconfig_read      : in  std_logic                      := 'X';             -- hip_reconfig_read
			hip_reconfig_readdata  : out std_logic_vector(15 downto 0);                     -- hip_reconfig_readdata
			hip_reconfig_write     : in  std_logic                      := 'X';             -- hip_reconfig_write
			hip_reconfig_writedata : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- hip_reconfig_writedata
			ser_shift_load         : in  std_logic                      := 'X';             -- ser_shift_load
			interface_sel          : in  std_logic                      := 'X';             -- interface_sel
			app_msi_func           : in  std_logic_vector(2 downto 0)   := (others => 'X'); -- app_msi_func
			serr_out               : out std_logic;                                         -- serr_out
			aer_msi_num            : in  std_logic_vector(4 downto 0)   := (others => 'X'); -- aer_msi_num
			pex_msi_num            : in  std_logic_vector(4 downto 0)   := (others => 'X'); -- pex_msi_num
			cpl_err_func           : in  std_logic_vector(2 downto 0)   := (others => 'X')  -- cpl_err_func
		);
	end component altpcie_cv_hip_ast_hwtcl;

	-- Declare the config demultiplexer.
	--
	component altpcierd_tl_cfg_sample is
		port (
			pld_clk           : in  std_logic;
			rstn              : in  std_logic;
			tl_cfg_add        : in  std_logic_vector(3 downto 0);
			tl_cfg_ctl        : in  std_logic_vector(31 downto 0);
			tl_cfg_ctl_wr     : in  std_logic;
			tl_cfg_sts        : in  std_logic_vector(52 downto 0);
			tl_cfg_sts_wr     : in  std_logic;
			cfg_busdev        : out std_logic_vector(12 downto 0);
			cfg_devcsr        : out std_logic_vector(31 downto 0);
			cfg_linkcsr       : out std_logic_vector(31 downto 0);
			cfg_prmcsr        : out std_logic_vector(31 downto 0);
			cfg_io_bas        : out std_logic_vector(19 downto 0);
			cfg_io_lim        : out std_logic_vector(19 downto 0);
			cfg_np_bas        : out std_logic_vector(11 downto 0);
			cfg_np_lim        : out std_logic_vector(11 downto 0);
			cfg_pr_bas        : out std_logic_vector(43 downto 0);
			cfg_pr_lim        : out std_logic_vector(43 downto 0);
			cfg_tcvcmap       : out std_logic_vector(23 downto 0);
			cfg_msicsr        : out std_logic_vector(15 downto 0)
		);
	end component;

	-- Internal signals
	signal pcieClk            : std_logic;
	signal pllLocked          : std_logic;
	signal tl_cfg_add         : std_logic_vector(3 downto 0);
	signal tl_cfg_ctl         : std_logic_vector(31 downto 0);
	signal tl_cfg_ctl_wr      : std_logic;
	signal fiData             : std_logic_vector(65 downto 0);
	signal fiValid            : std_logic;
	signal foData             : std_logic_vector(65 downto 0);
	signal foValid            : std_logic;
	signal foReady            : std_logic;
begin
	dut : component altpcie_cv_hip_ast_hwtcl
		generic map (
			ACDS_VERSION_HWTCL                        => "14.0",
			lane_mask_hwtcl                           => "x4",
			gen12_lane_rate_mode_hwtcl                => "Gen1 (2.5 Gbps)",
			pcie_spec_version_hwtcl                   => "2.1",
			ast_width_hwtcl                           => "Avalon-ST 64-bit",
			pll_refclk_freq_hwtcl                     => "100 MHz",
			set_pld_clk_x1_625MHz_hwtcl               => 0,
			in_cvp_mode_hwtcl                         => 0,
			hip_reconfig_hwtcl                        => 0,
			num_of_func_hwtcl                         => 1,
			use_crc_forwarding_hwtcl                  => 0,
			port_link_number_hwtcl                    => 1,
			slotclkcfg_hwtcl                          => 1,
			enable_slot_register_hwtcl                => 0,
			vsec_id_hwtcl                             => 4466,
			vsec_rev_hwtcl                            => 0,
			user_id_hwtcl                             => 0,
			porttype_func0_hwtcl                      => "Native endpoint",
			bar0_size_mask_0_hwtcl                    => 12,
			bar0_io_space_0_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_0_hwtcl              => "Disabled",
			bar0_prefetchable_0_hwtcl                 => "Disabled",
			bar1_size_mask_0_hwtcl                    => 0,
			bar1_io_space_0_hwtcl                     => "Disabled",
			bar1_prefetchable_0_hwtcl                 => "Disabled",
			bar2_size_mask_0_hwtcl                    => 0,
			bar2_io_space_0_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_0_hwtcl              => "Disabled",
			bar2_prefetchable_0_hwtcl                 => "Disabled",
			bar3_size_mask_0_hwtcl                    => 0,
			bar3_io_space_0_hwtcl                     => "Disabled",
			bar3_prefetchable_0_hwtcl                 => "Disabled",
			bar4_size_mask_0_hwtcl                    => 0,
			bar4_io_space_0_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_0_hwtcl              => "Disabled",
			bar4_prefetchable_0_hwtcl                 => "Disabled",
			bar5_size_mask_0_hwtcl                    => 0,
			bar5_io_space_0_hwtcl                     => "Disabled",
			bar5_prefetchable_0_hwtcl                 => "Disabled",
			expansion_base_address_register_0_hwtcl   => 0,
			io_window_addr_width_hwtcl                => 0,
			prefetchable_mem_window_addr_width_hwtcl  => 0,
			vendor_id_0_hwtcl                         => 4466,
			device_id_0_hwtcl                         => 57345,
			revision_id_0_hwtcl                       => 1,
			class_code_0_hwtcl                        => 16711680,
			subsystem_vendor_id_0_hwtcl               => 0,
			subsystem_device_id_0_hwtcl               => 0,
			max_payload_size_0_hwtcl                  => 256,
			extend_tag_field_0_hwtcl                  => "32",
			completion_timeout_0_hwtcl                => "ABCD",
			enable_completion_timeout_disable_0_hwtcl => 1,
			flr_capability_0_hwtcl                    => 0,
			use_aer_0_hwtcl                           => 0,
			ecrc_check_capable_0_hwtcl                => 0,
			ecrc_gen_capable_0_hwtcl                  => 0,
			dll_active_report_support_0_hwtcl         => 0,
			surprise_down_error_support_0_hwtcl       => 0,
			msi_multi_message_capable_0_hwtcl         => "4",
			msi_64bit_addressing_capable_0_hwtcl      => "true",
			msi_masking_capable_0_hwtcl               => "false",
			msi_support_0_hwtcl                       => "true",
			enable_function_msix_support_0_hwtcl      => 0,
			msix_table_size_0_hwtcl                   => 0,
			msix_table_offset_0_hwtcl                 => "0",
			msix_table_bir_0_hwtcl                    => 0,
			msix_pba_offset_0_hwtcl                   => "0",
			msix_pba_bir_0_hwtcl                      => 0,
			interrupt_pin_0_hwtcl                     => "inta",
			slot_power_scale_0_hwtcl                  => 0,
			slot_power_limit_0_hwtcl                  => 0,
			slot_number_0_hwtcl                       => 0,
			rx_ei_l0s_0_hwtcl                         => 0,
			endpoint_l0_latency_0_hwtcl               => 0,
			endpoint_l1_latency_0_hwtcl               => 0,
			reconfig_to_xcvr_width                    => 350,
			hip_hard_reset_hwtcl                      => 1,
			reconfig_from_xcvr_width                  => 230,
			single_rx_detect_hwtcl                    => 4,
			enable_l0s_aspm_hwtcl                     => "false",
			aspm_optionality_hwtcl                    => "true",
			enable_adapter_half_rate_mode_hwtcl       => "false",
			millisecond_cycle_count_hwtcl             => 124250,
			credit_buffer_allocation_aux_hwtcl        => "absolute",
			vc0_rx_flow_ctrl_posted_header_hwtcl      => 16,
			vc0_rx_flow_ctrl_posted_data_hwtcl        => 16,
			vc0_rx_flow_ctrl_nonposted_header_hwtcl   => 16,
			vc0_rx_flow_ctrl_nonposted_data_hwtcl     => 0,
			vc0_rx_flow_ctrl_compl_header_hwtcl       => 0,
			vc0_rx_flow_ctrl_compl_data_hwtcl         => 0,
			cpl_spc_header_hwtcl                      => 67,
			cpl_spc_data_hwtcl                        => 269,
			port_width_data_hwtcl                     => 64,
			bypass_clk_switch_hwtcl                   => "disable",
			cvp_rate_sel_hwtcl                        => "full_rate",
			cvp_data_compressed_hwtcl                 => "false",
			cvp_data_encrypted_hwtcl                  => "false",
			cvp_mode_reset_hwtcl                      => "false",
			cvp_clk_reset_hwtcl                       => "false",
			core_clk_sel_hwtcl                        => "pld_clk",
			enable_rx_buffer_checking_hwtcl           => "false",
			disable_link_x2_support_hwtcl             => "false",
			device_number_hwtcl                       => 0,
			pipex1_debug_sel_hwtcl                    => "disable",
			pclk_out_sel_hwtcl                        => "pclk",
			no_soft_reset_hwtcl                       => "false",
			d1_support_hwtcl                          => "false",
			d2_support_hwtcl                          => "false",
			d0_pme_hwtcl                              => "false",
			d1_pme_hwtcl                              => "false",
			d2_pme_hwtcl                              => "false",
			d3_hot_pme_hwtcl                          => "false",
			d3_cold_pme_hwtcl                         => "false",
			low_priority_vc_hwtcl                     => "single_vc",
			enable_l1_aspm_hwtcl                      => "false",
			l1_exit_latency_sameclock_hwtcl           => 0,
			l1_exit_latency_diffclock_hwtcl           => 0,
			hot_plug_support_hwtcl                    => 0,
			no_command_completed_hwtcl                => "false",
			eie_before_nfts_count_hwtcl               => 4,
			gen2_diffclock_nfts_count_hwtcl           => 255,
			gen2_sameclock_nfts_count_hwtcl           => 255,
			deemphasis_enable_hwtcl                   => "false",
			l0_exit_latency_sameclock_hwtcl           => 6,
			l0_exit_latency_diffclock_hwtcl           => 6,
			vc0_clk_enable_hwtcl                      => "true",
			register_pipe_signals_hwtcl               => "true",
			tx_cdc_almost_empty_hwtcl                 => 5,
			rx_l0s_count_idl_hwtcl                    => 0,
			cdc_dummy_insert_limit_hwtcl              => 11,
			ei_delay_powerdown_count_hwtcl            => 10,
			skp_os_schedule_count_hwtcl               => 0,
			fc_init_timer_hwtcl                       => 1024,
			l01_entry_latency_hwtcl                   => 31,
			flow_control_update_count_hwtcl           => 30,
			flow_control_timeout_count_hwtcl          => 200,
			retry_buffer_last_active_address_hwtcl    => 255,
			reserved_debug_hwtcl                      => 0,
			use_tl_cfg_sync_hwtcl                     => 1,
			diffclock_nfts_count_hwtcl                => 255,
			sameclock_nfts_count_hwtcl                => 255,
			l2_async_logic_hwtcl                      => "disable",
			rx_cdc_almost_full_hwtcl                  => 12,
			tx_cdc_almost_full_hwtcl                  => 11,
			indicator_hwtcl                           => 0,
			maximum_current_0_hwtcl                   => 0,
			disable_snoop_packet_0_hwtcl              => "false",
			bridge_port_vga_enable_0_hwtcl            => "false",
			bridge_port_ssid_support_0_hwtcl          => "false",
			ssvid_0_hwtcl                             => 0,
			ssid_0_hwtcl                              => 0,
			porttype_func1_hwtcl                      => "Native endpoint",
			bar0_size_mask_1_hwtcl                    => 28,
			bar0_io_space_1_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_1_hwtcl              => "Enabled",
			bar0_prefetchable_1_hwtcl                 => "Enabled",
			bar1_size_mask_1_hwtcl                    => 0,
			bar1_io_space_1_hwtcl                     => "Disabled",
			bar1_prefetchable_1_hwtcl                 => "Disabled",
			bar2_size_mask_1_hwtcl                    => 10,
			bar2_io_space_1_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_1_hwtcl              => "Disabled",
			bar2_prefetchable_1_hwtcl                 => "Disabled",
			bar3_size_mask_1_hwtcl                    => 0,
			bar3_io_space_1_hwtcl                     => "Disabled",
			bar3_prefetchable_1_hwtcl                 => "Disabled",
			bar4_size_mask_1_hwtcl                    => 0,
			bar4_io_space_1_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_1_hwtcl              => "Disabled",
			bar4_prefetchable_1_hwtcl                 => "Disabled",
			bar5_size_mask_1_hwtcl                    => 0,
			bar5_io_space_1_hwtcl                     => "Disabled",
			bar5_prefetchable_1_hwtcl                 => "Disabled",
			expansion_base_address_register_1_hwtcl   => 0,
			vendor_id_1_hwtcl                         => 0,
			device_id_1_hwtcl                         => 1,
			revision_id_1_hwtcl                       => 1,
			class_code_1_hwtcl                        => 0,
			subsystem_vendor_id_1_hwtcl               => 0,
			subsystem_device_id_1_hwtcl               => 0,
			max_payload_size_1_hwtcl                  => 256,
			extend_tag_field_1_hwtcl                  => "32",
			completion_timeout_1_hwtcl                => "ABCD",
			enable_completion_timeout_disable_1_hwtcl => 1,
			flr_capability_1_hwtcl                    => 0,
			use_aer_1_hwtcl                           => 0,
			ecrc_check_capable_1_hwtcl                => 0,
			ecrc_gen_capable_1_hwtcl                  => 0,
			dll_active_report_support_1_hwtcl         => 0,
			surprise_down_error_support_1_hwtcl       => 0,
			msi_multi_message_capable_1_hwtcl         => "4",
			msi_64bit_addressing_capable_1_hwtcl      => "true",
			msi_masking_capable_1_hwtcl               => "false",
			msi_support_1_hwtcl                       => "true",
			enable_function_msix_support_1_hwtcl      => 0,
			msix_table_size_1_hwtcl                   => 0,
			msix_table_offset_1_hwtcl                 => "0",
			msix_table_bir_1_hwtcl                    => 0,
			msix_pba_offset_1_hwtcl                   => "0",
			msix_pba_bir_1_hwtcl                      => 0,
			interrupt_pin_1_hwtcl                     => "inta",
			slot_power_scale_1_hwtcl                  => 0,
			slot_power_limit_1_hwtcl                  => 0,
			slot_number_1_hwtcl                       => 0,
			rx_ei_l0s_1_hwtcl                         => 0,
			endpoint_l0_latency_1_hwtcl               => 0,
			endpoint_l1_latency_1_hwtcl               => 0,
			maximum_current_1_hwtcl                   => 0,
			disable_snoop_packet_1_hwtcl              => "false",
			bridge_port_vga_enable_1_hwtcl            => "false",
			bridge_port_ssid_support_1_hwtcl          => "false",
			ssvid_1_hwtcl                             => 0,
			ssid_1_hwtcl                              => 0,
			porttype_func2_hwtcl                      => "Native endpoint",
			bar0_size_mask_2_hwtcl                    => 28,
			bar0_io_space_2_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_2_hwtcl              => "Enabled",
			bar0_prefetchable_2_hwtcl                 => "Enabled",
			bar1_size_mask_2_hwtcl                    => 0,
			bar1_io_space_2_hwtcl                     => "Disabled",
			bar1_prefetchable_2_hwtcl                 => "Disabled",
			bar2_size_mask_2_hwtcl                    => 10,
			bar2_io_space_2_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_2_hwtcl              => "Disabled",
			bar2_prefetchable_2_hwtcl                 => "Disabled",
			bar3_size_mask_2_hwtcl                    => 0,
			bar3_io_space_2_hwtcl                     => "Disabled",
			bar3_prefetchable_2_hwtcl                 => "Disabled",
			bar4_size_mask_2_hwtcl                    => 0,
			bar4_io_space_2_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_2_hwtcl              => "Disabled",
			bar4_prefetchable_2_hwtcl                 => "Disabled",
			bar5_size_mask_2_hwtcl                    => 0,
			bar5_io_space_2_hwtcl                     => "Disabled",
			bar5_prefetchable_2_hwtcl                 => "Disabled",
			expansion_base_address_register_2_hwtcl   => 0,
			vendor_id_2_hwtcl                         => 0,
			device_id_2_hwtcl                         => 1,
			revision_id_2_hwtcl                       => 1,
			class_code_2_hwtcl                        => 0,
			subsystem_vendor_id_2_hwtcl               => 0,
			subsystem_device_id_2_hwtcl               => 0,
			max_payload_size_2_hwtcl                  => 256,
			extend_tag_field_2_hwtcl                  => "32",
			completion_timeout_2_hwtcl                => "ABCD",
			enable_completion_timeout_disable_2_hwtcl => 1,
			flr_capability_2_hwtcl                    => 0,
			use_aer_2_hwtcl                           => 0,
			ecrc_check_capable_2_hwtcl                => 0,
			ecrc_gen_capable_2_hwtcl                  => 0,
			dll_active_report_support_2_hwtcl         => 0,
			surprise_down_error_support_2_hwtcl       => 0,
			msi_multi_message_capable_2_hwtcl         => "4",
			msi_64bit_addressing_capable_2_hwtcl      => "true",
			msi_masking_capable_2_hwtcl               => "false",
			msi_support_2_hwtcl                       => "true",
			enable_function_msix_support_2_hwtcl      => 0,
			msix_table_size_2_hwtcl                   => 0,
			msix_table_offset_2_hwtcl                 => "0",
			msix_table_bir_2_hwtcl                    => 0,
			msix_pba_offset_2_hwtcl                   => "0",
			msix_pba_bir_2_hwtcl                      => 0,
			interrupt_pin_2_hwtcl                     => "inta",
			slot_power_scale_2_hwtcl                  => 0,
			slot_power_limit_2_hwtcl                  => 0,
			slot_number_2_hwtcl                       => 0,
			rx_ei_l0s_2_hwtcl                         => 0,
			endpoint_l0_latency_2_hwtcl               => 0,
			endpoint_l1_latency_2_hwtcl               => 0,
			maximum_current_2_hwtcl                   => 0,
			disable_snoop_packet_2_hwtcl              => "false",
			bridge_port_vga_enable_2_hwtcl            => "false",
			bridge_port_ssid_support_2_hwtcl          => "false",
			ssvid_2_hwtcl                             => 0,
			ssid_2_hwtcl                              => 0,
			porttype_func3_hwtcl                      => "Native endpoint",
			bar0_size_mask_3_hwtcl                    => 28,
			bar0_io_space_3_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_3_hwtcl              => "Enabled",
			bar0_prefetchable_3_hwtcl                 => "Enabled",
			bar1_size_mask_3_hwtcl                    => 0,
			bar1_io_space_3_hwtcl                     => "Disabled",
			bar1_prefetchable_3_hwtcl                 => "Disabled",
			bar2_size_mask_3_hwtcl                    => 10,
			bar2_io_space_3_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_3_hwtcl              => "Disabled",
			bar2_prefetchable_3_hwtcl                 => "Disabled",
			bar3_size_mask_3_hwtcl                    => 0,
			bar3_io_space_3_hwtcl                     => "Disabled",
			bar3_prefetchable_3_hwtcl                 => "Disabled",
			bar4_size_mask_3_hwtcl                    => 0,
			bar4_io_space_3_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_3_hwtcl              => "Disabled",
			bar4_prefetchable_3_hwtcl                 => "Disabled",
			bar5_size_mask_3_hwtcl                    => 0,
			bar5_io_space_3_hwtcl                     => "Disabled",
			bar5_prefetchable_3_hwtcl                 => "Disabled",
			expansion_base_address_register_3_hwtcl   => 0,
			vendor_id_3_hwtcl                         => 0,
			device_id_3_hwtcl                         => 1,
			revision_id_3_hwtcl                       => 1,
			class_code_3_hwtcl                        => 0,
			subsystem_vendor_id_3_hwtcl               => 0,
			subsystem_device_id_3_hwtcl               => 0,
			max_payload_size_3_hwtcl                  => 256,
			extend_tag_field_3_hwtcl                  => "32",
			completion_timeout_3_hwtcl                => "ABCD",
			enable_completion_timeout_disable_3_hwtcl => 1,
			flr_capability_3_hwtcl                    => 0,
			use_aer_3_hwtcl                           => 0,
			ecrc_check_capable_3_hwtcl                => 0,
			ecrc_gen_capable_3_hwtcl                  => 0,
			dll_active_report_support_3_hwtcl         => 0,
			surprise_down_error_support_3_hwtcl       => 0,
			msi_multi_message_capable_3_hwtcl         => "4",
			msi_64bit_addressing_capable_3_hwtcl      => "true",
			msi_masking_capable_3_hwtcl               => "false",
			msi_support_3_hwtcl                       => "true",
			enable_function_msix_support_3_hwtcl      => 0,
			msix_table_size_3_hwtcl                   => 0,
			msix_table_offset_3_hwtcl                 => "0",
			msix_table_bir_3_hwtcl                    => 0,
			msix_pba_offset_3_hwtcl                   => "0",
			msix_pba_bir_3_hwtcl                      => 0,
			interrupt_pin_3_hwtcl                     => "inta",
			slot_power_scale_3_hwtcl                  => 0,
			slot_power_limit_3_hwtcl                  => 0,
			slot_number_3_hwtcl                       => 0,
			rx_ei_l0s_3_hwtcl                         => 0,
			endpoint_l0_latency_3_hwtcl               => 0,
			endpoint_l1_latency_3_hwtcl               => 0,
			maximum_current_3_hwtcl                   => 0,
			disable_snoop_packet_3_hwtcl              => "false",
			bridge_port_vga_enable_3_hwtcl            => "false",
			bridge_port_ssid_support_3_hwtcl          => "false",
			ssvid_3_hwtcl                             => 0,
			ssid_3_hwtcl                              => 0,
			porttype_func4_hwtcl                      => "Native endpoint",
			bar0_size_mask_4_hwtcl                    => 28,
			bar0_io_space_4_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_4_hwtcl              => "Enabled",
			bar0_prefetchable_4_hwtcl                 => "Enabled",
			bar1_size_mask_4_hwtcl                    => 0,
			bar1_io_space_4_hwtcl                     => "Disabled",
			bar1_prefetchable_4_hwtcl                 => "Disabled",
			bar2_size_mask_4_hwtcl                    => 10,
			bar2_io_space_4_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_4_hwtcl              => "Disabled",
			bar2_prefetchable_4_hwtcl                 => "Disabled",
			bar3_size_mask_4_hwtcl                    => 0,
			bar3_io_space_4_hwtcl                     => "Disabled",
			bar3_prefetchable_4_hwtcl                 => "Disabled",
			bar4_size_mask_4_hwtcl                    => 0,
			bar4_io_space_4_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_4_hwtcl              => "Disabled",
			bar4_prefetchable_4_hwtcl                 => "Disabled",
			bar5_size_mask_4_hwtcl                    => 0,
			bar5_io_space_4_hwtcl                     => "Disabled",
			bar5_prefetchable_4_hwtcl                 => "Disabled",
			expansion_base_address_register_4_hwtcl   => 0,
			vendor_id_4_hwtcl                         => 0,
			device_id_4_hwtcl                         => 1,
			revision_id_4_hwtcl                       => 1,
			class_code_4_hwtcl                        => 0,
			subsystem_vendor_id_4_hwtcl               => 0,
			subsystem_device_id_4_hwtcl               => 0,
			max_payload_size_4_hwtcl                  => 256,
			extend_tag_field_4_hwtcl                  => "32",
			completion_timeout_4_hwtcl                => "ABCD",
			enable_completion_timeout_disable_4_hwtcl => 1,
			flr_capability_4_hwtcl                    => 0,
			use_aer_4_hwtcl                           => 0,
			ecrc_check_capable_4_hwtcl                => 0,
			ecrc_gen_capable_4_hwtcl                  => 0,
			dll_active_report_support_4_hwtcl         => 0,
			surprise_down_error_support_4_hwtcl       => 0,
			msi_multi_message_capable_4_hwtcl         => "4",
			msi_64bit_addressing_capable_4_hwtcl      => "true",
			msi_masking_capable_4_hwtcl               => "false",
			msi_support_4_hwtcl                       => "true",
			enable_function_msix_support_4_hwtcl      => 0,
			msix_table_size_4_hwtcl                   => 0,
			msix_table_offset_4_hwtcl                 => "0",
			msix_table_bir_4_hwtcl                    => 0,
			msix_pba_offset_4_hwtcl                   => "0",
			msix_pba_bir_4_hwtcl                      => 0,
			interrupt_pin_4_hwtcl                     => "inta",
			slot_power_scale_4_hwtcl                  => 0,
			slot_power_limit_4_hwtcl                  => 0,
			slot_number_4_hwtcl                       => 0,
			rx_ei_l0s_4_hwtcl                         => 0,
			endpoint_l0_latency_4_hwtcl               => 0,
			endpoint_l1_latency_4_hwtcl               => 0,
			maximum_current_4_hwtcl                   => 0,
			disable_snoop_packet_4_hwtcl              => "false",
			bridge_port_vga_enable_4_hwtcl            => "false",
			bridge_port_ssid_support_4_hwtcl          => "false",
			ssvid_4_hwtcl                             => 0,
			ssid_4_hwtcl                              => 0,
			porttype_func5_hwtcl                      => "Native endpoint",
			bar0_size_mask_5_hwtcl                    => 28,
			bar0_io_space_5_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_5_hwtcl              => "Enabled",
			bar0_prefetchable_5_hwtcl                 => "Enabled",
			bar1_size_mask_5_hwtcl                    => 0,
			bar1_io_space_5_hwtcl                     => "Disabled",
			bar1_prefetchable_5_hwtcl                 => "Disabled",
			bar2_size_mask_5_hwtcl                    => 10,
			bar2_io_space_5_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_5_hwtcl              => "Disabled",
			bar2_prefetchable_5_hwtcl                 => "Disabled",
			bar3_size_mask_5_hwtcl                    => 0,
			bar3_io_space_5_hwtcl                     => "Disabled",
			bar3_prefetchable_5_hwtcl                 => "Disabled",
			bar4_size_mask_5_hwtcl                    => 0,
			bar4_io_space_5_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_5_hwtcl              => "Disabled",
			bar4_prefetchable_5_hwtcl                 => "Disabled",
			bar5_size_mask_5_hwtcl                    => 0,
			bar5_io_space_5_hwtcl                     => "Disabled",
			bar5_prefetchable_5_hwtcl                 => "Disabled",
			expansion_base_address_register_5_hwtcl   => 0,
			vendor_id_5_hwtcl                         => 0,
			device_id_5_hwtcl                         => 1,
			revision_id_5_hwtcl                       => 1,
			class_code_5_hwtcl                        => 0,
			subsystem_vendor_id_5_hwtcl               => 0,
			subsystem_device_id_5_hwtcl               => 0,
			max_payload_size_5_hwtcl                  => 256,
			extend_tag_field_5_hwtcl                  => "32",
			completion_timeout_5_hwtcl                => "ABCD",
			enable_completion_timeout_disable_5_hwtcl => 1,
			flr_capability_5_hwtcl                    => 0,
			use_aer_5_hwtcl                           => 0,
			ecrc_check_capable_5_hwtcl                => 0,
			ecrc_gen_capable_5_hwtcl                  => 0,
			dll_active_report_support_5_hwtcl         => 0,
			surprise_down_error_support_5_hwtcl       => 0,
			msi_multi_message_capable_5_hwtcl         => "4",
			msi_64bit_addressing_capable_5_hwtcl      => "true",
			msi_masking_capable_5_hwtcl               => "false",
			msi_support_5_hwtcl                       => "true",
			enable_function_msix_support_5_hwtcl      => 0,
			msix_table_size_5_hwtcl                   => 0,
			msix_table_offset_5_hwtcl                 => "0",
			msix_table_bir_5_hwtcl                    => 0,
			msix_pba_offset_5_hwtcl                   => "0",
			msix_pba_bir_5_hwtcl                      => 0,
			interrupt_pin_5_hwtcl                     => "inta",
			slot_power_scale_5_hwtcl                  => 0,
			slot_power_limit_5_hwtcl                  => 0,
			slot_number_5_hwtcl                       => 0,
			rx_ei_l0s_5_hwtcl                         => 0,
			endpoint_l0_latency_5_hwtcl               => 0,
			endpoint_l1_latency_5_hwtcl               => 0,
			maximum_current_5_hwtcl                   => 0,
			disable_snoop_packet_5_hwtcl              => "false",
			bridge_port_vga_enable_5_hwtcl            => "false",
			bridge_port_ssid_support_5_hwtcl          => "false",
			ssvid_5_hwtcl                             => 0,
			ssid_5_hwtcl                              => 0,
			porttype_func6_hwtcl                      => "Native endpoint",
			bar0_size_mask_6_hwtcl                    => 28,
			bar0_io_space_6_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_6_hwtcl              => "Enabled",
			bar0_prefetchable_6_hwtcl                 => "Enabled",
			bar1_size_mask_6_hwtcl                    => 0,
			bar1_io_space_6_hwtcl                     => "Disabled",
			bar1_prefetchable_6_hwtcl                 => "Disabled",
			bar2_size_mask_6_hwtcl                    => 10,
			bar2_io_space_6_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_6_hwtcl              => "Disabled",
			bar2_prefetchable_6_hwtcl                 => "Disabled",
			bar3_size_mask_6_hwtcl                    => 0,
			bar3_io_space_6_hwtcl                     => "Disabled",
			bar3_prefetchable_6_hwtcl                 => "Disabled",
			bar4_size_mask_6_hwtcl                    => 0,
			bar4_io_space_6_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_6_hwtcl              => "Disabled",
			bar4_prefetchable_6_hwtcl                 => "Disabled",
			bar5_size_mask_6_hwtcl                    => 0,
			bar5_io_space_6_hwtcl                     => "Disabled",
			bar5_prefetchable_6_hwtcl                 => "Disabled",
			expansion_base_address_register_6_hwtcl   => 0,
			vendor_id_6_hwtcl                         => 0,
			device_id_6_hwtcl                         => 1,
			revision_id_6_hwtcl                       => 1,
			class_code_6_hwtcl                        => 0,
			subsystem_vendor_id_6_hwtcl               => 0,
			subsystem_device_id_6_hwtcl               => 0,
			max_payload_size_6_hwtcl                  => 256,
			extend_tag_field_6_hwtcl                  => "32",
			completion_timeout_6_hwtcl                => "ABCD",
			enable_completion_timeout_disable_6_hwtcl => 1,
			flr_capability_6_hwtcl                    => 0,
			use_aer_6_hwtcl                           => 0,
			ecrc_check_capable_6_hwtcl                => 0,
			ecrc_gen_capable_6_hwtcl                  => 0,
			dll_active_report_support_6_hwtcl         => 0,
			surprise_down_error_support_6_hwtcl       => 0,
			msi_multi_message_capable_6_hwtcl         => "4",
			msi_64bit_addressing_capable_6_hwtcl      => "true",
			msi_masking_capable_6_hwtcl               => "false",
			msi_support_6_hwtcl                       => "true",
			enable_function_msix_support_6_hwtcl      => 0,
			msix_table_size_6_hwtcl                   => 0,
			msix_table_offset_6_hwtcl                 => "0",
			msix_table_bir_6_hwtcl                    => 0,
			msix_pba_offset_6_hwtcl                   => "0",
			msix_pba_bir_6_hwtcl                      => 0,
			interrupt_pin_6_hwtcl                     => "inta",
			slot_power_scale_6_hwtcl                  => 0,
			slot_power_limit_6_hwtcl                  => 0,
			slot_number_6_hwtcl                       => 0,
			rx_ei_l0s_6_hwtcl                         => 0,
			endpoint_l0_latency_6_hwtcl               => 0,
			endpoint_l1_latency_6_hwtcl               => 0,
			maximum_current_6_hwtcl                   => 0,
			disable_snoop_packet_6_hwtcl              => "false",
			bridge_port_vga_enable_6_hwtcl            => "false",
			bridge_port_ssid_support_6_hwtcl          => "false",
			ssvid_6_hwtcl                             => 0,
			ssid_6_hwtcl                              => 0,
			porttype_func7_hwtcl                      => "Native endpoint",
			bar0_size_mask_7_hwtcl                    => 28,
			bar0_io_space_7_hwtcl                     => "Disabled",
			bar0_64bit_mem_space_7_hwtcl              => "Enabled",
			bar0_prefetchable_7_hwtcl                 => "Enabled",
			bar1_size_mask_7_hwtcl                    => 0,
			bar1_io_space_7_hwtcl                     => "Disabled",
			bar1_prefetchable_7_hwtcl                 => "Disabled",
			bar2_size_mask_7_hwtcl                    => 10,
			bar2_io_space_7_hwtcl                     => "Disabled",
			bar2_64bit_mem_space_7_hwtcl              => "Disabled",
			bar2_prefetchable_7_hwtcl                 => "Disabled",
			bar3_size_mask_7_hwtcl                    => 0,
			bar3_io_space_7_hwtcl                     => "Disabled",
			bar3_prefetchable_7_hwtcl                 => "Disabled",
			bar4_size_mask_7_hwtcl                    => 0,
			bar4_io_space_7_hwtcl                     => "Disabled",
			bar4_64bit_mem_space_7_hwtcl              => "Disabled",
			bar4_prefetchable_7_hwtcl                 => "Disabled",
			bar5_size_mask_7_hwtcl                    => 0,
			bar5_io_space_7_hwtcl                     => "Disabled",
			bar5_prefetchable_7_hwtcl                 => "Disabled",
			expansion_base_address_register_7_hwtcl   => 0,
			vendor_id_7_hwtcl                         => 0,
			device_id_7_hwtcl                         => 1,
			revision_id_7_hwtcl                       => 1,
			class_code_7_hwtcl                        => 0,
			subsystem_vendor_id_7_hwtcl               => 0,
			subsystem_device_id_7_hwtcl               => 0,
			max_payload_size_7_hwtcl                  => 256,
			extend_tag_field_7_hwtcl                  => "32",
			completion_timeout_7_hwtcl                => "ABCD",
			enable_completion_timeout_disable_7_hwtcl => 1,
			flr_capability_7_hwtcl                    => 0,
			use_aer_7_hwtcl                           => 0,
			ecrc_check_capable_7_hwtcl                => 0,
			ecrc_gen_capable_7_hwtcl                  => 0,
			dll_active_report_support_7_hwtcl         => 0,
			surprise_down_error_support_7_hwtcl       => 0,
			msi_multi_message_capable_7_hwtcl         => "4",
			msi_64bit_addressing_capable_7_hwtcl      => "true",
			msi_masking_capable_7_hwtcl               => "false",
			msi_support_7_hwtcl                       => "true",
			enable_function_msix_support_7_hwtcl      => 0,
			msix_table_size_7_hwtcl                   => 0,
			msix_table_offset_7_hwtcl                 => "0",
			msix_table_bir_7_hwtcl                    => 0,
			msix_pba_offset_7_hwtcl                   => "0",
			msix_pba_bir_7_hwtcl                      => 0,
			interrupt_pin_7_hwtcl                     => "inta",
			slot_power_scale_7_hwtcl                  => 0,
			slot_power_limit_7_hwtcl                  => 0,
			slot_number_7_hwtcl                       => 0,
			rx_ei_l0s_7_hwtcl                         => 0,
			endpoint_l0_latency_7_hwtcl               => 0,
			endpoint_l1_latency_7_hwtcl               => 0,
			maximum_current_7_hwtcl                   => 0,
			disable_snoop_packet_7_hwtcl              => "false",
			bridge_port_vga_enable_7_hwtcl            => "false",
			bridge_port_ssid_support_7_hwtcl          => "false",
			ssvid_7_hwtcl                             => 0,
			ssid_7_hwtcl                              => 0,
			rpre_emph_a_val_hwtcl                     => 11,
			rpre_emph_b_val_hwtcl                     => 0,
			rpre_emph_c_val_hwtcl                     => 22,
			rpre_emph_d_val_hwtcl                     => 12,
			rpre_emph_e_val_hwtcl                     => 21,
			rvod_sel_a_val_hwtcl                      => 50,
			rvod_sel_b_val_hwtcl                      => 34,
			rvod_sel_c_val_hwtcl                      => 50,
			rvod_sel_d_val_hwtcl                      => 50,
			rvod_sel_e_val_hwtcl                      => 9
		)
		port map (
			-- -------------------------------------------------------------------------------------
			-- Connections to the external world (in this case, to the RP testbench)
			-- -------------------------------------------------------------------------------------

			-- Clock, resets, PCIe RX & TX
			refclk                 => pcieRefClk_in,
			npor                   => pcieNPOR_in,
			pin_perst              => pciePERST_in,
			rx_in0                 => pcieRX_in(0),
			rx_in1                 => pcieRX_in(1),
			rx_in2                 => pcieRX_in(2),
			rx_in3                 => pcieRX_in(3),
			tx_out0                => pcieTX_out(0),
			tx_out1                => pcieTX_out(1),
			tx_out2                => pcieTX_out(2),
			tx_out3                => pcieTX_out(3),

			-- Control & Pipe signals for simulation connection
			test_in                => sim_test_in,
			simu_mode_pipe         => sim_simu_mode_pipe_in,
			sim_pipe_pclk_in       => sim_pipe_pclk_in,
			sim_pipe_rate          => sim_pipe_rate_out,
			sim_ltssmstate         => sim_ltssmstate_out,
			eidleinfersel0         => sim_eidleinfersel0_out,
			eidleinfersel1         => sim_eidleinfersel1_out,
			eidleinfersel2         => sim_eidleinfersel2_out,
			eidleinfersel3         => sim_eidleinfersel3_out,
			powerdown0             => sim_powerdown0_out,
			powerdown1             => sim_powerdown1_out,
			powerdown2             => sim_powerdown2_out,
			powerdown3             => sim_powerdown3_out,
			rxpolarity0            => sim_rxpolarity0_out,
			rxpolarity1            => sim_rxpolarity1_out,
			rxpolarity2            => sim_rxpolarity2_out,
			rxpolarity3            => sim_rxpolarity3_out,
			txcompl0               => sim_txcompl0_out,
			txcompl1               => sim_txcompl1_out,
			txcompl2               => sim_txcompl2_out,
			txcompl3               => sim_txcompl3_out,
			txdata0                => sim_txdata0_out,
			txdata1                => sim_txdata1_out,
			txdata2                => sim_txdata2_out,
			txdata3                => sim_txdata3_out,
			txdatak0               => sim_txdatak0_out,
			txdatak1               => sim_txdatak1_out,
			txdatak2               => sim_txdatak2_out,
			txdatak3               => sim_txdatak3_out,
			txdetectrx0            => sim_txdetectrx0_out,
			txdetectrx1            => sim_txdetectrx1_out,
			txdetectrx2            => sim_txdetectrx2_out,
			txdetectrx3            => sim_txdetectrx3_out,
			txelecidle0            => sim_txelecidle0_out,
			txelecidle1            => sim_txelecidle1_out,
			txelecidle2            => sim_txelecidle2_out,
			txelecidle3            => sim_txelecidle3_out,
			txswing0               => sim_txswing0_out,
			txswing1               => sim_txswing1_out,
			txswing2               => sim_txswing2_out,
			txswing3               => sim_txswing3_out,
			txmargin0              => sim_txmargin0_out,
			txmargin1              => sim_txmargin1_out,
			txmargin2              => sim_txmargin2_out,
			txmargin3              => sim_txmargin3_out,
			txdeemph0              => sim_txdeemph0_out,
			txdeemph1              => sim_txdeemph1_out,
			txdeemph2              => sim_txdeemph2_out,
			txdeemph3              => sim_txdeemph3_out,
			phystatus0             => sim_phystatus0_in,
			phystatus1             => sim_phystatus1_in,
			phystatus2             => sim_phystatus2_in,
			phystatus3             => sim_phystatus3_in,
			rxdata0                => sim_rxdata0_in,
			rxdata1                => sim_rxdata1_in,
			rxdata2                => sim_rxdata2_in,
			rxdata3                => sim_rxdata3_in,
			rxdatak0               => sim_rxdatak0_in,
			rxdatak1               => sim_rxdatak1_in,
			rxdatak2               => sim_rxdatak2_in,
			rxdatak3               => sim_rxdatak3_in,
			rxelecidle0            => sim_rxelecidle0_in,
			rxelecidle1            => sim_rxelecidle1_in,
			rxelecidle2            => sim_rxelecidle2_in,
			rxelecidle3            => sim_rxelecidle3_in,
			rxstatus0              => sim_rxstatus0_in,
			rxstatus1              => sim_rxstatus1_in,
			rxstatus2              => sim_rxstatus2_in,
			rxstatus3              => sim_rxstatus3_in,
			rxvalid0               => sim_rxvalid0_in,
			rxvalid1               => sim_rxvalid1_in,
			rxvalid2               => sim_rxvalid2_in,
			rxvalid3               => sim_rxvalid3_in,

			-- -------------------------------------------------------------------------------------
			-- Connections to the application
			-- -------------------------------------------------------------------------------------

			-- Application connects these...
			pld_clk                => pcieClk,
			coreclkout             => pcieClk,

			-- And these...
			serdes_pll_locked      => pllLocked,
			pld_core_ready         => pllLocked,

			-- RX signals
			rx_st_bar              => open,
			rx_st_be               => open,
			rx_st_data             => fiData(63 downto 0),
			rx_st_valid            => fiValid,
			rx_st_ready            => foReady,
			rx_st_sop              => fiData(64),
			rx_st_eop              => fiData(65),
			rx_st_err              => open,
			rx_st_mask             => '0',

			-- TX signals
			tx_st_data             => txData_in,
			tx_st_valid            => txValid_in,
			tx_st_ready            => txReady_out,
			tx_st_sop              => txSOP_in,
			tx_st_eop              => txEOP_in,
			tx_st_err              => '0',

			-- Config-space
			tl_cfg_add             => tl_cfg_add,
			tl_cfg_ctl             => tl_cfg_ctl,
			tl_cfg_ctl_wr          => tl_cfg_ctl_wr,
			tl_cfg_sts             => open,
			tl_cfg_sts_wr          => open,

			-- MSI interrupts
			app_msi_req            => msiReq_in,
			app_msi_num            => (others => '0'),
			app_msi_tc             => (others => '0'),
			app_msi_ack            => msiAck_out,

			-- Everything else
			tx_fifo_empty          => open,
			tx_cred_datafccp       => open,
			tx_cred_datafcnp       => open,
			tx_cred_datafcp        => open,
			tx_cred_fchipcons      => open,
			tx_cred_fcinfinite     => open,
			tx_cred_hdrfccp        => open,
			tx_cred_hdrfcnp        => open,
			tx_cred_hdrfcp         => open,
			reset_status           => open,
			pld_clk_inuse          => open,
			testin_zero            => open,
			lmi_addr               => (others => '0'),
			lmi_din                => (others => '0'),
			lmi_rden               => '0',
			lmi_wren               => '0',
			lmi_ack                => open,
			lmi_dout               => open,
			pm_auxpwr              => '0',
			pm_data                => (others => '0'),
			pme_to_cr              => '0',
			pm_event               => '0',
			pme_to_sr              => open,
			reconfig_to_xcvr       => open,
			reconfig_from_xcvr     => open,
			app_int_sts_vec        => '0',
			tl_hpg_ctrl_er         => (others => '0'),
			cpl_err                => (others => '0'),
			cpl_pending(0)         => '0',
			derr_cor_ext_rcv0      => open,
			derr_cor_ext_rpl       => open,
			derr_rpl               => open,
			dlup_exit              => open,
			dl_ltssm               => open,
			ev128ns                => open,
			ev1us                  => open,
			hotrst_exit            => open,
			int_status             => open,
			l2_exit                => open,
			lane_act               => open,
			ko_cpl_spc_header      => open,
			ko_cpl_spc_data        => open,
			dl_current_speed       => open,                             --   hip_currentspeed.currentspeed
			rx_in4                 => '0',                              --        (terminated)
			rx_in5                 => '0',                              --        (terminated)
			rx_in6                 => '0',                              --        (terminated)
			rx_in7                 => '0',                              --        (terminated)
			tx_out4                => open,                             --        (terminated)
			tx_out5                => open,                             --        (terminated)
			tx_out6                => open,                             --        (terminated)
			tx_out7                => open,                             --        (terminated)
			rx_st_empty            => open,                             --        (terminated)
			rx_fifo_empty          => open,                             --        (terminated)
			rx_fifo_full           => open,                             --        (terminated)
			rx_bar_dec_func_num    => open,                             --        (terminated)
			tx_st_empty            => '0',                              --        (terminated)
			tx_fifo_full           => open,                             --        (terminated)
			tx_fifo_rdp            => open,                             --        (terminated)
			tx_fifo_wrp            => open,                             --        (terminated)
			eidleinfersel4         => open,                             --        (terminated)
			eidleinfersel5         => open,                             --        (terminated)
			eidleinfersel6         => open,                             --        (terminated)
			eidleinfersel7         => open,                             --        (terminated)
			powerdown4             => open,                             --        (terminated)
			powerdown5             => open,                             --        (terminated)
			powerdown6             => open,                             --        (terminated)
			powerdown7             => open,                             --        (terminated)
			rxpolarity4            => open,                             --        (terminated)
			rxpolarity5            => open,                             --        (terminated)
			rxpolarity6            => open,                             --        (terminated)
			rxpolarity7            => open,                             --        (terminated)
			txcompl4               => open,                             --        (terminated)
			txcompl5               => open,                             --        (terminated)
			txcompl6               => open,                             --        (terminated)
			txcompl7               => open,                             --        (terminated)
			txdata4                => open,                             --        (terminated)
			txdata5                => open,                             --        (terminated)
			txdata6                => open,                             --        (terminated)
			txdata7                => open,                             --        (terminated)
			txdatak4               => open,                             --        (terminated)
			txdatak5               => open,                             --        (terminated)
			txdatak6               => open,                             --        (terminated)
			txdatak7               => open,                             --        (terminated)
			txdetectrx4            => open,                             --        (terminated)
			txdetectrx5            => open,                             --        (terminated)
			txdetectrx6            => open,                             --        (terminated)
			txdetectrx7            => open,                             --        (terminated)
			txelecidle4            => open,                             --        (terminated)
			txelecidle5            => open,                             --        (terminated)
			txelecidle6            => open,                             --        (terminated)
			txelecidle7            => open,                             --        (terminated)
			txswing4               => open,                             --        (terminated)
			txswing5               => open,                             --        (terminated)
			txswing6               => open,                             --        (terminated)
			txswing7               => open,                             --        (terminated)
			txmargin4              => open,                             --        (terminated)
			txmargin5              => open,                             --        (terminated)
			txmargin6              => open,                             --        (terminated)
			txmargin7              => open,                             --        (terminated)
			txdeemph4              => open,                             --        (terminated)
			txdeemph5              => open,                             --        (terminated)
			txdeemph6              => open,                             --        (terminated)
			txdeemph7              => open,                             --        (terminated)
			phystatus4             => '0',                              --        (terminated)
			phystatus5             => '0',                              --        (terminated)
			phystatus6             => '0',                              --        (terminated)
			phystatus7             => '0',                              --        (terminated)
			rxdata4                => "00000000",                       --        (terminated)
			rxdata5                => "00000000",                       --        (terminated)
			rxdata6                => "00000000",                       --        (terminated)
			rxdata7                => "00000000",                       --        (terminated)
			rxdatak4               => '0',                              --        (terminated)
			rxdatak5               => '0',                              --        (terminated)
			rxdatak6               => '0',                              --        (terminated)
			rxdatak7               => '0',                              --        (terminated)
			rxelecidle4            => '0',                              --        (terminated)
			rxelecidle5            => '0',                              --        (terminated)
			rxelecidle6            => '0',                              --        (terminated)
			rxelecidle7            => '0',                              --        (terminated)
			rxstatus4              => "000",                            --        (terminated)
			rxstatus5              => "000",                            --        (terminated)
			rxstatus6              => "000",                            --        (terminated)
			rxstatus7              => "000",                            --        (terminated)
			rxvalid4               => '0',                              --        (terminated)
			rxvalid5               => '0',                              --        (terminated)
			rxvalid6               => '0',                              --        (terminated)
			rxvalid7               => '0',                              --        (terminated)
			sim_pipe_pclk_out      => open,                             --        (terminated)
			pm_event_func          => "000",                            --        (terminated)
			hip_reconfig_clk       => '0',                              --        (terminated)
			hip_reconfig_rst_n     => '0',                              --        (terminated)
			hip_reconfig_address   => "0000000000",                     --        (terminated)
			hip_reconfig_byte_en   => "00",                             --        (terminated)
			hip_reconfig_read      => '0',                              --        (terminated)
			hip_reconfig_readdata  => open,                             --        (terminated)
			hip_reconfig_write     => '0',                              --        (terminated)
			hip_reconfig_writedata => "0000000000000000",               --        (terminated)
			ser_shift_load         => '0',                              --        (terminated)
			interface_sel          => '0',                              --        (terminated)
			app_msi_func           => "000",                            --        (terminated)
			serr_out               => open,                             --        (terminated)
			aer_msi_num            => "00000",                          --        (terminated)
			pex_msi_num            => "00000",                          --        (terminated)
			cpl_err_func           => "000"                             --        (terminated)
		);

	-- Instantiate the Verilog config-region sampler unit provided by Altera
	sampler : component altpcierd_tl_cfg_sample
		port map (
			pld_clk          => pcieClk,
			rstn             => '1',
			tl_cfg_add       => tl_cfg_add,
			tl_cfg_ctl       => tl_cfg_ctl,
			tl_cfg_ctl_wr    => tl_cfg_ctl_wr,
			tl_cfg_sts       => (others => '0'),
			tl_cfg_sts_wr    => '0',
			cfg_busdev       => cfgBusDev_out  -- 13-bit device ID assigned to the FPGA on enumeration
		);

	-- Small FIFO to avoid rxData being lost because of the two-clock latency from the PCIe IP.
	recv_fifo : entity makestuff.buffer_fifo
		generic map (
			WIDTH            => 66,    -- space for 64-bit data word and the SOP & EOP flags
			DEPTH            => 2,     -- space for four entries
			BLOCK_RAM        => "OFF"  -- just use regular registers
		)
		port map (
			clk_in           => pcieClk,
			depth_out        => open,

			-- Production end
			iData_in         => fiData,
			iValid_in        => fiValid,
			iReady_out       => open,

			-- Consumption end
			oData_out        => foData,
			oValid_out       => foValid,
			oReady_in        => foReady
		);

	-- Drive pcieClk externally
	pcieClk_out <= pcieClk;

	-- External connection to FIFO output
	foReady <= rxReady_in;
	rxValid_out <= foValid;
	rxData_out <= foData(63 downto 0);  -- when foValid = '1' and rxReady_in = '1' else (others => 'X');
	rxSOP_out <= foData(64);            -- when foValid = '1' and rxReady_in = '1' else '0';
	rxEOP_out <= foData(65);            -- when foValid = '1' and rxReady_in = '1' else '0';

end architecture rtl; -- of pcie
