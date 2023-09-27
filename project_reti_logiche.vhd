LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

entity project_reti_logiche is
Port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_w : in std_logic;
    
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    o_done : out std_logic;
    
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in std_logic_vector(7 downto 0);
    o_mem_we : out std_logic;
    o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component MemAnalizer is
Port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_w : in std_logic;
    
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in std_logic_vector(7 downto 0);

    ---------
    set0 : in std_logic;
    z_load : in std_logic;
    zp_load : in std_logic;
    w_load : in std_logic;
    w_send : in std_logic
    );
    
end component;
--Segnali Macchina a stati
signal set0 : std_logic; --Segnale inizio nuovo ciclo
signal z_load : std_logic; --Segnale aggiornamento uscite
signal zp_load : std_logic; --Segnale aggiornamento registri uscite
signal w_load :  std_logic; --Segnale lettura bit0 ID uscita
signal w_send : std_logic; --Segnale invio indirizzo a mem

type S is (S0,S1,S2,S3,S4,S5,S6,S01,RST);
signal cur_state, next_state : S;
begin
MemAnalizer0: MemAnalizer port map(
    i_clk,
    i_rst,
    i_start,
    i_w,
    
    o_z0,
    o_z1,
    o_z2,
    o_z3,
    
    o_mem_addr,
    i_mem_data,
    --
    set0,
    z_load,
    zp_load,
    w_load,
    w_send
);

process(i_clk, i_rst)--Passaggio di stato
    begin
        if(i_rst = '1') then
            cur_state <= RST;
        elsif i_clk'event and rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
process(cur_state, i_start) --Sequenza stati
    begin
        next_state <= cur_state;
        case cur_state is
            when RST =>
                next_state <= S0; 

            when S0 =>
                if (i_start = '1') then
                    next_state <= S01;             
                end if;
            when S01=>
                if (i_start = '1') then
                    next_state <= S1;
                else next_state <= S2;
                end if;
            when S1 =>
                if (i_start = '1') then
                    next_state <= S1;
                else next_state <= S2; 
                end if;

            when S2 =>
                next_state <= S3;
                
            when S3 =>
                next_state <=S4;
                
            when S4 =>
                next_state <=S5;
                
            when S5 =>
                next_state <=S6;
                
            when S6 =>
                next_state<=S0;         
        end case;
end process;
    
process(cur_state) --Invio segnali
    begin
        w_send <='0';
        w_load <='0';
        z_load <='0';
        zp_load<='0';

        o_mem_en <= '0';
        o_mem_we <= '0';
        o_done<='0';
        
        set0<='0';
        
        case cur_state is
            when RST => --RESET
                --report "RST";
                
            when S0 => --Nuova lettura, attesa Start
                --report "S0";
                set0 <= '1';
                
            when S01=>
                w_load <= '1';
                
            when S1 => --Lettura input
                
                
            when S2 => --Invio indirizzo a mem
                --report "S2";
                w_send <='1';     
                
            when S3 => --Avvio comunicazione con mem
                --report"S3";                
                o_mem_en<='1';
        
            when S4 => --Lettura dati da mem
                --report"S4";
                zp_load<='1';
                
            when S5 => -- Aggiornamento Uscite
                --report "S5";
                z_load <= '1';
               
            when S6 => --Fine elaborazione
                --report "S6";
                o_done <= '1';
                set0 <= '1';


        end case;
end process;
end Behavioral;

-------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

entity MemAnalizer is
    Port(
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_w : in std_logic;
    
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in std_logic_vector(7 downto 0);
    
    ---------
    set0 : in std_logic; 
    z_load : in std_logic;
    zp_load : in std_logic; 
    w_load : in std_logic; 
    w_send : in std_logic 
    );
    
end MemAnalizer;

architecture Behavorial of MemAnalizer is
--Segnali MemAnalizer
signal    zx0 :  std_logic; --Bit0 ID uscita
signal    zx1 :  std_logic; --Bit1 ID uscita
signal    raddr :  std_logic_vector(15 downto 0); --Registro indirizzo di mem
    
signal    z0prec :  std_logic_vector(7 downto 0); --Registro uscita z0
signal    z1prec :  std_logic_vector(7 downto 0); --Registro uscita z1
signal    z2prec :  std_logic_vector(7 downto 0); --Registro uscita z2
signal    z3prec :  std_logic_vector(7 downto 0); --Registro uscita z3

begin     

process(i_clk,i_RST,i_start,set0,z_load) --S0 Nuova lettura/ S5 Aggiornamento uscite
    begin
    if(rising_edge(i_clk)) then
        if(i_RST='1' OR set0='1') then
            --report "S0ok";
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000"; 
            zx1 <= 'U';
            
            if(i_start='1') then
                zx1 <= i_w;
            end if;
             
        elsif(z_load='1')then
            --report "S5ok";
            o_z0 <= z0prec;
            o_z1 <= z1prec;
            o_z2 <= z2prec;
            o_z3 <= z3prec;
        end if;
    end if;
end process;

process(i_clk,i_RST,i_start,set0,w_load) --S01/S1 lettura input
    begin
    if(rising_edge(i_clk)) then
        if(i_RST='1' OR set0='1') then 
            zx0 <= 'U';
            raddr <= "0000000000000000";
                       
        elsif(i_start='1')then
            --report "S1ok";
            if(w_load='1') then
                zx0 <= i_w;
            else
                for j in 15 downto 1 loop --Shift sx
                    raddr(j) <= raddr(j-1);
                end loop;
                raddr(0) <= i_w;
            end if;
        end if;
    end if;
end process;

process(i_clk,i_RST,w_send,set0) --S2 Invio indirizzo a mem
    begin
    if(rising_edge(i_clk)) then
        if(i_RST='1' OR set0='1') then
            o_mem_addr<="0000000000000000";
                        
        elsif(w_send='1')then
            --report "S2ok";
            o_mem_addr <= raddr;
            
        end if; 
    end if;    
end process;

process(i_clk,i_RST,zp_load) --S4 Lettura dati da mem
    begin
    if(rising_edge(i_clk)) then
        if(i_RST='1') then
            z0prec <= "00000000";
            z1prec <= "00000000";
            z2prec <= "00000000";
            z3prec <= "00000000";
            
        elsif(zp_load ='1')then
            --report "S4ok";
            if(zx1='0')then
                if(zx0='0')then 
                    --report "zx=00";
                    z0prec <= i_mem_data;
                elsif(zx0='1')then
                    --report "zx=01";
                    z1prec <=i_mem_data;
                end if;
             elsif(zx1='1')then
                if(zx0='0')then 
                    --report "zx=10";
                    z2prec <= i_mem_data;
                elsif(zx0='1')then 
                    --report "zx=11";
                    z3prec <= i_mem_data;
                end if;
            end if;  
        end if; 
    end if;    
end process;


end Behavorial;
