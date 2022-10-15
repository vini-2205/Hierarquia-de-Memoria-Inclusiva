library verilog;
use verilog.vl_types.all;
entity Pratica1Parte3 is
    port(
        address         : in     vl_logic_vector(4 downto 0);
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(2 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(2 downto 0);
        hit_saida       : out    vl_logic;
        data_writeback_mem: out    vl_logic_vector(2 downto 0);
        address_writeback_mem: out    vl_logic_vector(4 downto 0);
        saida_via1      : out    vl_logic_vector(8 downto 0);
        saida_via2      : out    vl_logic_vector(8 downto 0)
    );
end Pratica1Parte3;
