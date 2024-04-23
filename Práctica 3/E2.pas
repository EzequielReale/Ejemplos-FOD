{2. Definir un programa que genere un archivo con registros de longitud fija conteniendo
información de asistentes a un congreso a partir de la información obtenida por
teclado. Se deberá almacenar la siguiente información: nro de asistente, apellido y
nombre, email, teléfono y D.N.I. Implementar un procedimiento que, a partir del
archivo de datos generado, elimine de forma lógica todos los asistentes con nro de
asistente inferior a 1000.
Para ello se podrá utilizar algún carácter especial situándolo delante de algún campo
String a su elección. Ejemplo: ‘@Saldaño’.}

program ejercicio2;

type
    asistente = record
        nroAsistente: integer;
        apellido: string;
        nombre: string;
        email: string;
        telefono: string;
        dni: string;
    end;

    archivo = file of asistente;

procedure leerAsistente(var a: asistente);
begin
    with a do 
    begin
        write('Ingrese el nro de asistente: '); readln(nroAsistente);
        if (nroAsistente <> -1) then
        begin
            write('Ingrese el apellido: '); readln(apellido);
            write('Ingrese el nombre: '); readln(nombre);
            write('Ingrese el email: '); readln(email);
            write('Ingrese el telefono: '); readln(telefono);
            write('Ingrese el dni: '); readln(dni);
        end;
    end;
end;

procedure generarArchivo(var a: archivo);
var
    asistente: asistente;
begin
    rewrite(a);
    leerAsistente(asistente);
    while (asistente.nroAsistente <> -1) do
    begin
        write(a, asistente);
        leerAsistente(asistente);
    end;
    close(a);
end;

procedure eliminarAsistentes(var arch: archivo);
var
    reg: asistente;
begin
    reset(arch);
    while (not eof(arch)) do
    begin
        read(arch, reg);
        if (reg.nroAsistente < 1000) then
        begin
            reg.apellido := '@' + reg.apellido;
            seek(arch, filepos(arch) - 1);
            write(arch, reg);
        end;
    end;
    close(arch);
end;

procedure imprimirArchivo(var a: archivo);
var
    reg: asistente;
begin
    reset(a);
    while (not eof(a)) do
    begin
        read(a, reg);
        if (pos('@',reg_m.dni) = 0) then begin
            writeln('Nro de asistente: ', reg.nroAsistente);
            writeln('Apellido: ', reg.apellido);
            writeln('Nombre: ', reg.nombre);
            writeln('Email: ', reg.email);
            writeln('Telefono: ', reg.telefono);
            writeln('DNI: ', reg.dni);
        end;
    end;
    close(a);
end;

var
    a: archivo;
begin
    assign(a, 'archivo');
    generarArchivo(a);
    eliminarAsistentes(a);
end.