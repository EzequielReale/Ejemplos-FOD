// Se desea modelar la información necesaria para un sistema de recuentos de casos de
// covid para el ministerio de salud de la provincia de buenos aires.
// Diariamente se reciben archivos provenientes de los distintos municipios, la información
// contenida en los mismos es la siguiente: código de localidad, código cepa, cantidad casos
// activos, cantidad de casos nuevos, cantidad de casos recuperados, cantidad de casos fallecidos.
// El ministerio cuenta con un archivo maestro con la siguiente información: código localidad,
// nombre localidad, código cepa, nombre cepa, cantidad casos activos, cantidad casos
// nuevos, cantidad recuperados y cantidad de fallecidos.
// Se debe realizar el procedimiento que permita actualizar el maestro con los detalles
// recibidos, se reciben 10 detalles. Todos los archivos están ordenados por código de
// localidad y código de cepa.
// Para la actualización se debe proceder de la siguiente manera:
//      1. Al número de fallecidos se le suman el valor de fallecidos recibido del detalle.
//      2. Idem anterior para los recuperados.
//      3. Los casos activos se actualizan con el valor recibido en el detalle.
//      4. Idem anterior para los casos nuevos hallados.
// Realice las declaraciones necesarias, el programa principal y los procedimientos que
// requiera para la actualización solicitada e informe cantidad de localidades con más de 50
// casos activos (las localidades pueden o no haber sido actualizadas).

program ejer6;

const
    VALOR_ALTO = 9999;
    CANT_DETALLES = 10;

type
    municipio = record
        codLocalidad: integer;
        nombreLocalidad: string;
        codCepa: integer;
        nombreCepa: string;
        cantCasosActivos: integer;
        cantCasosNuevos: integer;
        cantRecuperados: integer;
        cantFallecidos: integer;
    end;

    archivo = file of municipio;

    vMunicipios = array[1..CANT_DETALLES] of municipio;
    vDetalles = array[1..CANT_DETALLES] of archivo;


procedure resetearDetalles(var vd: vDetalles, var vm: vMunicipios);
var
    i: integer;
begin
    for i := 1 to CANT_DETALLES do begin
        reset(vd[i]);
        leer(vd[i], vm[i]);
    end;
end;

procedure cerrarDetalles(var vd: vDetalles);
var
    i: integer;
begin
    for i := 1 to CANT_DETALLES do close(vd[i]);
end;

procedure leer(var archivo: archivo; var reg: municipio);
begin
    if (not eof(archivo)) then read(archivo, reg)
    else reg.codLocalidad := VALOR_ALTO;
end;

procedure minimo(var vd: vDetalles; var vm: vMunicipios; var min: municipio);
var
    i, posMin: integer;
begin
    min.codLocalidad := VALOR_ALTO;
    for i := 1 to CANT_DETALLES begin
        if (vm[i].codLocalidad < min.codLocalidad) or ((vm[i].codLocalidad = min.codLocalidad) and (vm[i].codCepa < min.codCepa)) then begin
            min := vm[i];
            posMin := i;
        end;
    end;
    if (min.codLocalidad <> VALOR_ALTO) then leer(vd[posMin], vm[posMin]); // Solo avanzo si no es el final del archivo
end;

procedure actualizarMaestro(var maestro: archivo; var vd: vDetalles; var vm: vMunicipios);
var
    regM, min, aux: municipio;
begin
    reset(maestro);
    resetearDetalles(vd, vm);
    minimo(vd, vm, min); // Inicializo el minimo
    while (min.codLocalidad <> VALOR_ALTO) do begin // Mientras no sea el final del archivo
        aux.codLocalidad := min.codLocalidad;
        aux.codCepa := min.codCepa;
        while (aux.codLocalidad = min.codLocalidad) and (aux.codCepa = min.codCepa) do begin // Mientras sea la misma localidad y cepa, acumulo
            aux.cantFallecidos := aux.cantFallecidos + min.cantFallecidos;
            aux.cantRecuperados := aux.cantRecuperados + min.cantRecuperados;
            aux.cantCasosActivos := min.cantCasosActivos;
            aux.cantCasosNuevos := min.cantCasosNuevos;
            minimo(vd, vm, min); // Avanzo
        end;

        read(maestro, regM); // Nótese que no puede ser EOF porque ya para cada reg-detalle hay un reg-maestro
        while ((regM.codLocalidad <> aux.codLocalidad) or (regM.codCepa <> aux.codCepa)) do read(maestro, regM); // or (y no and) porque pregunto por la negativa
        // En fin, sumas y asignaciones varias...
        regM.cantFallecidos := regM.cantFallecidos + aux.cantFallecidos;
        regM.cantRecuperados := regM.cantRecuperados + aux.cantRecuperados;
        regM.cantCasosActivos := aux.cantCasosActivos;
        regM.cantCasosNuevos := aux.cantCasosNuevos;
        seek(maestro, filepos(maestro) - 1);
        write(maestro, aux); // Actualizo el maestro
    end;
    cerrarDetalles(vd);
    close(maestro); // Importante cerrar todo, porque estoy realizando modificaciones
end;

procedure imprimirLocalidadesConMasDe50CasosActivos(var maestro: archivo);
var
    regM: municipio;
    cantLocalidades, cod_act, cant_tot: integer;
begin
    reset(maestro);
    cantLocalidades := 0;
    leer(maestro, regM);
    while (not eof(maestro)) do begin
        cod_act := regM.codLocalidad;
        while (regM.codLocalidad = regM.codLocalidad) do begin
            cant_tot := cant_tot + regM.cantCasosActivos;
            leer(maestro, regM);
        end;
        if (cant_tot > 50) then cantLocalidades := cantLocalidades + 1;
    end;
    writeln('La cantidad de localidades con mas de 50 casos activos es: ', cantLocalidades);
    close(maestro);
end;

var
    maestro: archivo;
    vd: vDetalles;
    vm: vMunicipios;
begin
    assign(maestro, 'maestro');
    // Supongamos que se disponen el asignar detalles y cargar maestro/detalles
    actualizarMaestro(maestro, vd, vm);
    imprimirLocalidadesConMasDe50CasosActivos(maestro);
end.
