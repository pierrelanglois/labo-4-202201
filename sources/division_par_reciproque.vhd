-------------------------------------------------------------------------------
--
-- Division par r�ciproque
-- 2010/01/25 v. 1.0 : Tarek Ould Bachir, creation
-- 2010/05/13 v. 1.1 : Tarek Ould Bachir, modification de certains commentaires
-- 2011/01/13 v. 2.0 : Pierre Langlois, �limination de l'horloge, simplification g�n�rale, ajout de commentaires
-- 2022/02/22 v. 2.1 : Pierre Langlois, quelques mises � jour, r�duction de la taille de la ROM, etc.
--
-------------------------------------------------------------------------------
--
-- Fonctionnement du module
--
-- Les entr�es a et b sont des nombres entiers exprim�s sur Went bits.
--
-- La division f = a / b est effectu�e par la multiplication f = a * (1 / b),
-- o� les valeurs approximatives de (1 / b) sont pr�calcul�es et entrepos�es dans une m�moire ROM.
--
-- Le r�sultat final de la division est arrondi et exprim� sur :
--  - Went bits pour la partie enti�re
--  - Wfrac bits pour la partie fractionnaire.
--
-- Par exemple, pour Went = 3 et Wfrac = 2, on aurait:
--  00001 -> 000.01 = 0.25
--  01010 -> 010.10 = 2.50
--  11111 -> 111.11 = 7.75  
--
-- Le nombre de bits de pr�cision pour les r�ciproques entrepos�es dans la ROM est Went + Wfrac.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity division_par_reciproque is
    generic(
        Went : integer := 8; -- nombre de bits pour la partie enti�re
        Wfrac : integer := 4 -- nombre de bits pour la partie fractionnaire
    );
    port (
        num      : in  unsigned(Went - 1 downto 0);            -- num�rateur
        denom    : in  unsigned(Went - 1 downto 0);            -- d�nominateur
        quotient : out unsigned(Went + Wfrac - 1 downto 0);    -- approximation du quotient de num / denom
        erreur   : out std_logic                          -- '1' si b = 0
    );
end division_par_reciproque;

architecture arch of division_par_reciproque is

type ROM_reciproque_type is array(0 to 2 ** Went - 1) of unsigned(Went + Wfrac - 1 downto 0);

-- calcul des valeurs de la r�ciproque 1 / denom
function init_mem return ROM_reciproque_type is
variable reciproque : ROM_reciproque_type;
begin
    reciproque(0) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va g�n�rer une erreur de toute fa�on si on divise par 0
    reciproque(1) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va retourner a si on divise par 1
    for i in 2 to 2 ** Went - 1 loop
        reciproque(i) := to_unsigned(integer(round(real(2 ** (Went + Wfrac)) / real(i))), reciproque(0)'length);
    end loop;
    return reciproque;
end init_mem;

-- la m�moire ROM est initialis�e lors de l'instanciation du module par appel de la fonction
constant ROM_reciproque : ROM_reciproque_type := init_mem;

begin
    
    process(all)
    -- Le nombre de bits de la ROM, donc la repr�sentation de 1 / denom, est choisi arbitrairement comme Went + Wfrac,
    -- c'est toujours un nombre fractionnaire inf�rieur � 1.
    -- On n'entrepose par la valeur 1 / 1 dans la ROM, ce serait un bit gaspill�.
    -- Le nombre de bits pour repr�senter num est Went.
    -- La taille du produit d'une multiplication g�n�rale est �gale � la somme des taille des op�randes.
    -- Le produit de num * (1 / denom) s'exprime donc sur Went + Went + Wfrac bits.
    variable t : unsigned(Went + Went + Wfrac - 1 downto 0);

    begin
        t := num * ROM_reciproque(to_integer(denom)) + 2 ** (Went - 1); -- On arrondit en ajoutant un '1' � la position Went - 1.
        
        if denom = 1 then
            -- Si denom == 1, alors on retourne num directement, exprim� sur Went + Wfrac bits en le d�calant Wfrac positions vers la gauche.
            quotient <= num * 2 ** Wfrac;
        else
            -- Sinon, on retourne le produit de la multiplication en ne gardant que les Wfrac + Went bits les plus significatifs.
            quotient <= t(t'left downto Went);
        end if;
    end process;
    
    erreur <= '1' when denom = 0 else '0';

end arch;