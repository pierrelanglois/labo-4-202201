-------------------------------------------------------------------------------
--
-- Division par réciproque
-- 2010/01/25 v. 1.0 : Tarek Ould Bachir, creation
-- 2010/05/13 v. 1.1 : Tarek Ould Bachir, modification de certains commentaires
-- 2011/01/13 v. 2.0 : Pierre Langlois, élimination de l'horloge, simplification générale, ajout de commentaires
-- 2022/02/22 v. 2.1 : Pierre Langlois, quelques mises à jour, réduction de la taille de la ROM, etc.
--
-------------------------------------------------------------------------------
--
-- Fonctionnement du module
--
-- Les entrées a et b sont des nombres entiers exprimés sur Went bits.
--
-- La division f = a / b est effectuée par la multiplication f = a * (1 / b),
-- où les valeurs approximatives de (1 / b) sont précalculées et entreposées dans une mémoire ROM.
--
-- Le résultat final de la division est arrondi et exprimé sur :
--  - Went bits pour la partie entière
--  - Wfrac bits pour la partie fractionnaire.
--
-- Par exemple, pour Went = 3 et Wfrac = 2, on aurait:
--  00001 -> 000.01 = 0.25
--  01010 -> 010.10 = 2.50
--  11111 -> 111.11 = 7.75  
--
-- Le nombre de bits de précision pour les réciproques entreposées dans la ROM est Went + Wfrac.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity division_par_reciproque is
    generic(
        Went : integer := 8; -- nombre de bits pour la partie entière
        Wfrac : integer := 4 -- nombre de bits pour la partie fractionnaire
    );
    port (
        num      : in  unsigned(Went - 1 downto 0);            -- numérateur
        denom    : in  unsigned(Went - 1 downto 0);            -- dénominateur
        quotient : out unsigned(Went + Wfrac - 1 downto 0);    -- approximation du quotient de num / denom
        erreur   : out std_logic                          -- '1' si b = 0
    );
end division_par_reciproque;

architecture arch of division_par_reciproque is

type ROM_reciproque_type is array(0 to 2 ** Went - 1) of unsigned(Went + Wfrac - 1 downto 0);

-- calcul des valeurs de la réciproque 1 / denom
function init_mem return ROM_reciproque_type is
variable reciproque : ROM_reciproque_type;
begin
    reciproque(0) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va générer une erreur de toute façon si on divise par 0
    reciproque(1) := to_unsigned(0, reciproque(0)'length); -- valeur bidon, on va retourner a si on divise par 1
    for i in 2 to 2 ** Went - 1 loop
        reciproque(i) := to_unsigned(integer(round(real(2 ** (Went + Wfrac)) / real(i))), reciproque(0)'length);
    end loop;
    return reciproque;
end init_mem;

-- la mémoire ROM est initialisée lors de l'instanciation du module par appel de la fonction
constant ROM_reciproque : ROM_reciproque_type := init_mem;

begin
    
    process(all)
    -- Le nombre de bits de la ROM, donc la représentation de 1 / denom, est choisi arbitrairement comme Went + Wfrac,
    -- c'est toujours un nombre fractionnaire inférieur à 1.
    -- On n'entrepose par la valeur 1 / 1 dans la ROM, ce serait un bit gaspillé.
    -- Le nombre de bits pour représenter num est Went.
    -- La taille du produit d'une multiplication générale est égale à la somme des taille des opérandes.
    -- Le produit de num * (1 / denom) s'exprime donc sur Went + Went + Wfrac bits.
    variable t : unsigned(Went + Went + Wfrac - 1 downto 0);

    begin
        t := num * ROM_reciproque(to_integer(denom)) + 2 ** (Went - 1); -- On arrondit en ajoutant un '1' à la position Went - 1.
        
        if denom = 1 then
            -- Si denom == 1, alors on retourne num directement, exprimé sur Went + Wfrac bits en le décalant Wfrac positions vers la gauche.
            quotient <= num * 2 ** Wfrac;
        else
            -- Sinon, on retourne le produit de la multiplication en ne gardant que les Wfrac + Went bits les plus significatifs.
            quotient <= t(t'left downto Went);
        end if;
    end process;
    
    erreur <= '1' when denom = 0 else '0';

end arch;