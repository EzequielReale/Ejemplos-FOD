{12. La empresa de software ‘X’ posee un servidor web donde se encuentra alojado el sitio de
la organización. En dicho servidor, se almacenan en un archivo todos los accesos que se
realizan al sitio.
La información que se almacena en el archivo es la siguiente: año, mes, dia, idUsuario y
tiempo de acceso al sitio de la organización. El archivo se encuentra ordenado por los
siguientes criterios: año, mes, dia e idUsuario.
Se debe realizar un procedimiento que genere un informe en pantalla, para ello se indicará
el año calendario sobre el cual debe realizar el informe. El mismo debe respetar el formato
mostrado a continuación:
* 
* Se deberá tener en cuenta las siguientes aclaraciones:
- El año sobre el cual realizará el informe de accesos debe leerse desde teclado.
- El año puede no existir en el archivo, en tal caso, debe informarse en pantalla “año
no encontrado”.
- Debe definir las estructuras de datos necesarias.
- El recorrido del archivo debe realizarse una única vez procesando sólo la información
necesaria.
* }

program ejercicio12;

const
    VALOR_ALTO = 9999;

type
    date = record
        anio: integer;
        mes: integer;
        dia: integer;
    end;
    
    acceso = record
        fecha: date;
        idUsuario: integer;
        tiempo: real;
    end;

    archivo = file of acceso;

procedure leer(var arch: archivo; var reg: acceso);
begin
    if (not eof(arch)) then
        read(arch, reg)
    else
        reg.fecha.anio := VALOR_ALTO;
end;

procedure informe(var arch: archivo);
var
    actDate: date;
    totalUsuario, totalDia, totalMes, totalAnio: real;
    idAct: integer;
    reg: acceso;
begin
    write('Ingrese el año sobre el cual desea realizar el informe: ');
    readln(anio);

    reset(arch);
    leer(arch, reg);

    while (reg.fecha.anio <> VALOR_ALTO) and (reg.fecha.anio <= anio) do leer(arch, reg); // Busco el año pedido

    if (reg.fecha.anio <> VALOR_ALTO) then begin // Si no llegue al final del archivo
        totalAnio := 0;
        while (reg.fecha.anio = anio) do begin // Mientras siga en el año pedido
            totalMes := 0;
            actDate.mes := reg.fecha.mes;
            writeln('Mes: ', actDate.mes);
            while (reg.fecha.anio = anio) and (reg.fecha.mes = actDate.mes) do begin // Mientras siga en el mes actual del mismo año
                totalDia := 0;
                actDate.dia := reg.fecha.dia;
                writeln('Dia: ', actDate.dia);
                while (reg.fecha.anio = anio) and (reg.fecha.mes = actDate.mes) and (reg.fecha.dia = actDate.dia) do begin // Mientras siga en el mismo dia del mismo mes y año
                    totalUsuario := 0;
                    idAct := reg.idUsuario;
                    writeln('Usuario: ', idAct);
                    while (reg.fecha.anio = anio) and (reg.fecha.mes = actDate.mes) and (reg.fecha.dia = actDate.dia) and (reg.idUsuario = idAct) do begin // Mientras siga en el mismo usuario del mismo dia, mes y año
                        totalUsuario += reg.tiempo; // Sumo el tiempo del usuario
                        leer(arch, reg); // Avanzo
                    end;
                    writeln('Tiempo total del usuario: ', totalUsuario:4:2);
                    totalDia += totalUsuario; // Sumo el tiempo del usuario al total del dia
                end;
                writeln('Tiempo total del dia: ', totalDia:4:2);
                totalMes += totalDia; // Sumo el tiempo del dia al total del mes
            end;
            writeln('Tiempo total del mes: ', totalMes:4:2);
            totalAnio += totalMes; // Sumo el tiempo del mes al total del año
        end;
        writeln('Tiempo total del año: ', totalAnio:4:2);
    end
    else writeln('Año no encontrado');    

    close(arch);
end;

var
    arch: archivo;
begin
    assign(arch, 'archivo');
    informe(arch);
end.
