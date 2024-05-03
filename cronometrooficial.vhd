-- Declaración de la biblioteca IEEE y paquetes utilizados
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.std_logic_unsigned.all;

-- Definición de la entidad cronometro
entity cronometro is
 port (
    -- Entradas
    init_pause: in std_logic; -- Inicia o pausa el cronómetro
    stop: in std_logic; -- Detiene el cronómetro
    clk: in std_logic; -- Reloj del sistema
    rst: in std_logic; -- Reset del sistema
    -- Salidas
    q: out std_logic_vector (1 downto 0) -- Estado actual del cronómetro (00: inicial, 01: pausa, 10: activo)
 ) ;
end cronometro ; 

-- Definición de la arquitectura del cronómetro
architecture archcronometro of cronometro is
 -- Definición de los tipos de estado
 type state_type is (initial, pause, active);
 -- Señales internas para el estado actual y el siguiente estado
 signal state, next_state: state_type;
begin
 -- Proceso sincronizado con el reloj y el reset
 process( clk,rst)
 begin
    -- Si hay un reset, el cronómetro vuelve al estado inicial
    if rst= '1' then state<= initial;
    -- Si hay un flanco ascendente del reloj, el cronómetro cambia al siguiente estado
    elsif clk'event and clk='1' then 
      state<= next_state;
    end if;
 end process ; -- Fin del proceso de sincronización

 -- Proceso que determina el siguiente estado basado en el estado actual y las señales de entrada
 process( state, init_pause, stop )
 begin
    -- Caso por defecto para el siguiente estado
    next_state <= initial;
    -- Determinación del siguiente estado basado en el estado actual
    case (state) is
      when initial =>
        -- Si se recibe la señal de inicio o pausa, el cronómetro pasa al estado activo
        if init_pause ='1' then
          next_state <= active ;
        else
          next_state <= initial;
        end if;
      when active =>
        -- Si se recibe la señal de inicio o pausa, el cronómetro pasa al estado de pausa
        -- Si se recibe la señal de stop, el cronómetro vuelve al estado inicial
        if init_pause= '1' then 
          next_state <= pause;
        elsif stop='1' then
          next_state<= initial;
        else
          next_state<= active;
        end if;
      when pause=>
        -- Si se recibe la señal de inicio o pausa, el cronómetro pasa al estado activo
        -- Si se recibe la señal de stop, el cronómetro vuelve al estado inicial
        if init_pause ='1' then
          next_state <= active;
        elsif stop ='1' then
          next_state <= initial;
        else
          next_state <= pause;
        end if;
      when others =>
        -- Para cualquier otro estado, el cronómetro vuelve al estado inicial
        next_state <= initial;
    end case;
 end process;

 -- Asignación de las salidas basadas en el estado actual
 q(0)<= '1' when state= active else '0';
 q(1)<= '1' when state= pause else '0';
end archcronometro;
