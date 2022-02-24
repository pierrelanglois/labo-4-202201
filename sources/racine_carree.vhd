---------------------------------------------------------------------------------------------------
-- 
-- racine_carree.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-23 laboratoire #4 INF3500
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree is
    generic (
        N : positive := 16;                     -- nombre de bits de A
        M : positive := 8;                      -- nombre de bits de X
        J : positive := 10;                     -- nombre d'it�rations � faire
		Went : integer := 8;                    -- nombre de bits pour la partie enti�re de la r�ciproque
		Wfrac : integer := 4                    -- nombre de bits pour la partie fractionnaire de la r�ciproque
    );
    port (
        reset, clk : in std_logic;
        A : in unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carr�e
        go : in std_logic;                      -- commande pour d�buter les calculs
        X : out unsigned(M - 1 downto 0);       -- la racine carr�e de A, telle que X * X = A
        fini : out std_logic                    -- '1' quand les calculs sont termin�s ==> la valeur de X est stable et correcte
    );
end racine_carree;

architecture newton of racine_carree is
    
-- votre code ici
    
begin
    
--    diviseur : entity division_par_reciproque(arch)
--        generic map (Went, Wfrac)
--        port map (un-nm�rateur-ici, un-denominateur-ici, un-quotient-ici, un-signal-d-erreur-ici);

    -- votre code ici
    
    -- code bidon � remplacer
    X <= to_unsigned(0, X'length);
    fini <= '1';
    
end newton;
