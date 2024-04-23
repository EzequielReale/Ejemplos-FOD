{7. Se cuenta con un archivo que almacena información sobre especies de aves en
vía de extinción, para ello se almacena: código, nombre de la especie, familia de ave,
descripción y zona geográfica. El archivo no está ordenado por ningún criterio. Realice
un programa que elimine especies de aves, para ello se recibe por teclado las especies a
eliminar. Deberá realizar todas las declaraciones necesarias, implementar todos los
procedimientos que requiera y una alternativa para borrar los registros. Para ello deberá
implementar dos procedimientos, uno que marque los registros a borrar y posteriormente
otro procedimiento que compacte el archivo, quitando los registros marcados. Para
quitar los registros se deberá copiar el último registro del archivo en la posición del registro
a borrar y luego eliminar del archivo el último registro de forma tal de evitar registros
duplicados.
Nota: Las bajas deben finalizar al recibir el código 500000
}

program ejercicio7;

const
    valor_fin = 500000;
type
    str30 = string[30];
    ave = record
        cod: LongInt;
        nombre,familia_ave ,zona_geografica : str30;
        descripcion: string;
    end;

    archivo_aves = file of ave;

procedure crear_archivo_aves(var a: archivo_aves);
    procedure leer_ave(var a: ave);
    begin
        with a do begin
            write('Ingresar codigo de especie: ');
            readln(cod);
            if(cod <> -1)then begin
                write('Ingresar nombre de especie: ');
                readln(nombre);
                write('Ingresar familia de ave: ');
                readln(familia_ave);
                write('Ingresar descripcion del ave: ');
                readln(descripcion);
                write('Ingresar zona geografica de la especie: ');
                readln(zona_geografica);
            end;
        end;
    end;
var
    r: ave;
begin
    rewrite(a);
    leer_ave(r);
    while(r.cod <> -1)do begin
        write(a, r);    
        leer_ave(r);
    end;
    close(a);
end;

procedure eliminar_aves(var a: archivo_aves); // Solo borro lógicamente
var
    r: ave;
    cod: LongInt;
begin
    reset(a);
    writeln('Ingrese codigo de ave a eliminar: '); readln(cod);
    while(cod <> valor_fin) do begin
        ok:= false;
        read(a, r);
        while (not(EOF(a)) and (r.cod <> cod)) do read(a, r);
        if r.cod = cod then begin
            seek(a, filePos(a) - 1);
            r.nombre:= '@' + r.nombre; // Marca de baja
            write(a, r);
            writeln('Eliminado con exito');
        end
        else writeln('Codigo de ave inexistente');

        writeln('Ingrese codigo de ave a eliminar: '); readln(cod);
    end;
    close(a);
end;

procedure compactar_archivo(var a:archivo_aves); // Forma más eficiente de hacerlo
    procedure borrar(var a: archivo_aves; pos: integer; var cont: integer);
    var
        regm : ave;
        ult: integer;
    begin
        ult:= fileSize(a) - 1; // Posición del último registro	
        seek(a, ult - cont); // Posiciono el puntero en el último registro no borrado
        read(a, regm);
        seek(a, pos); // Posiciono el puntero en el registro a borrar
        write(a, regm); // Lo sobreescribo
        cont:= cont + 1; // Aumento el contador
    end;
var
    cont: integer;
    regm: ave;
begin
    reset(a);
    cont:= 0;
    while (filePos(a) <> fileSize(a) - cont) do begin // Mientras queden registros sin borrar
        read(a, regm); // Avanzo
        if (pos('@', regm.nombre) <> 0) then begin // Si está marcado para borrar
            borrar(a, filePos(a) - 1, cont); // Llamo al procedimiento enviándole la posición del registro a borrar
            seek(a, filePos(a) - 1); // Volvemos a leer el anterior, por si también estaba marcado para borrar
        end;
    end;
    seek(a, fileSize(a) - cont); // Me paro en el final del "nuevo archivo" que nos quedó
    truncate(a); // Pongo el EOF

    close(a);
end;

// Alternativa bastante rústica de hacerlo. Simplemente busca por el nombre, lo manda al final y trunca hasta terminar. Pero el truncate es una operación costosa y conviene no hacerla tanto
procedure compactar_archivo(var a:archivo_aves); 
var
    pos_act: integer;
    regm: ave;
begin
    reset(a);

    while not(EOF(a)) do begin
        read(a, regm);
        while (not(EOF(a)) and (pos('@', regm.nombre) = 0)) do read(a, regm);
        if not(EOF(a)) then begin
            pos_act:= filePos(a) - 1;
            seek(a, fileSize(a) - 1);
            read(a, regm);
            seek(a, filePos(a) - 1);
            truncate(a);
            seek(a, pos_act);
            write(a, regm);
        end;
    end;

    close(a);
end;

procedure imprimir(var archivo: archivo_aves);
var
    regm: ave;
begin
    reset(archivo);

    while(not eof(archivo))do begin
        read(archivo, regm);
        writeln('Codigo: ', regm.cod, '; Nombre: ', regm.nombre);
    end;

    close(archivo);
end;

var
    m : archivo_aves;
begin
    assign(m, 'archivo_aves');
    crear_archivo_aves(m);

    eliminar_aves(m);
    compactar_archivo(m);

    imprimir(m);
end.