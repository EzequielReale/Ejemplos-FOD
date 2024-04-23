{4. Dada la siguiente estructura:
type
reg_flor = record
nombre: String[45];
codigo:integer;
tArchFlores = file of reg_flor;
Las bajas se realizan apilando registros borrados y las altas reutilizando registros
borrados. El registro 0 se usa como cabecera de la pila de registros borrados: el
número 0 en el campo código implica que no hay registros borrados y -N indica que el
próximo registro a reutilizar es el N, siendo éste un número relativo de registro válido.
a. Implemente el siguiente módulo: (Abre el archivo y agrega una flor, recibida como parámetro
manteniendo la política descripta anteriormente)
procedure agregarFlor (var a: tArchFlores ; nombre: string; codigo:integer);
b. Implemente el siguiente módulo: (Recibe el archivo de flores y elimina la flor cuyo código
es igual al recibido como parámetro)
procedure eliminarFlor (var a: tArchFlores ; codigo:integer);
c. Liste el contenido del archivo omitiendo las flores eliminadas. Modifique lo que
considere necesario para obtener el listado}

program ejercicio4;

type
    reg_flor = record
        nombre: String[45];
        codigo:integer;
    end;

    tArchFlores = file of reg_flor;

procedure agregarFlor (var a: tArchFlores ; nombre: string; codigo:integer);
var
    r, aux: reg_flor;
begin
    reset(a);
    cargarFlor(r); // Supongamos que existe
    read(a, aux); // Leo la cabecera

    if r.codigo = 0 then // No hay espacio que recuperar
    begin
        seek(a, filesize(a)); // Me posiciono al final del archivo
        write(a, r); // Escribo el registro
    end
    else begin // Hay espacio que recuperar
        seek(a, r.codigo * -1); // Me posiciono en el espacio libre, pasandolo a positivo
        read(a, aux); // Leo el registro
        seek(a, filepos(a) - 1); // Vuelvo atrás
        write(a, r); // Escribo la flor nueva
        seek(a, 0); // Voy a la cabecera
        write(a, aux); // Escribo la nueva cabecera con el valor del anterior borrado
    end;
    
    close(a);
end;

procedure eliminarFlor (var a: tArchFlores; codigo:integer);
var
    r, aux: reg_flor;
begin
    reset(a);
    read(a, aux);

    while not eof(a) and r.codigo <> codigo do read(a, r);
    if r.codigo = codigo then begin
        seek(a, filepos(a) - 1); // Vuelvo atrás
        r.codigo := filepos(a) * -1; // Me guardo la posición en negativo
        write(a, aux); // Escribo el valor de la cabecera en la pocisión a borrar
        seek(a, 0); // Voy a la cabecera
        write(a, r); // Escribo la nueva cabecera con el valor del borrado
    end;


    close(a);
end;

procedure listarFlor (var a: tArchFlores);
var
    r: reg_flor;
begin
    reset(a);
    while not eof(a) do begin
        read(a, r);
        if r.codigo > 0 then writeln('Nombre: ', r.nombre, ' Codigo: ', r.codigo); // Solo imprimo si el codigo no crresponde a un registro borrado
    end;
    close(a);
end;

var
    a: tArchFlores;
    cabecera: reg_flor;
begin
    assign(a, 'flores.dat');
    cabecera.codigo := 0;
    rewrite(a);
    write(a, cabecera); // La primera posición de la cabecera se crea arbitrariamente, y empieza en 0
    close(a);

    agregarFlor(a, 'Rosa', 1);
    agregarFlor(a, 'Margarita', 2);
    agregarFlor(a, 'Girasol', 3);
    agregarFlor(a, 'Tulipan', 4);

    eliminarFlor(a, 2);

    listarFlor(a);
end.
