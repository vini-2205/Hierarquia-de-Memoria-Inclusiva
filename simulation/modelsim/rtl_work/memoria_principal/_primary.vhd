library verilog;
use verilog.vl_types.all;
entity memoria_principal is
    port(
        address         : in     vl_logic_vector(4 downto 0);
        clock           : in     vl_logic;
        data            : in     vl_logic_vector(2 downto 0);
        wren            : in     vl_logic;
        q               : out    vl_logic_vector(2 downto 0)
    );
end memoria_principal;
