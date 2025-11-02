CREATE TABLE Oficio(
IDOficio INT IDENTITY (1,1) PRIMARY KEY,
NombreOficio NVARCHAR (100) NOT NULL,
Descripcion NVARCHAR(200) NULL,
)

CREATE TABLE Cliente(
IDCliente INT IDENTITY (1,1) PRIMARY KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(10) NOT NULL,
Email NVARCHAR(100) NULL,
Telefono INT, 
FechaRegistro DATETIME DEFAULT GETDATE(),
PromedioCalificacion DECIMAL (3,2) DEFAULT 0,


CONSTRAINT CIENTE_DNI UNIQUE (DNI),
CONSTRAINT CLIENTE_Email UNIQUE (Email),
)

CREATE TABLE Proveedor(
IDProveedor INT IDENTITY (1,1) PRIMARY  KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(10) NOT NULL,
IDOficio INT,
Email NVARCHAR(255)  NOT NULL,
Telefono INT NOT NULL,
FechaNacimiento DATE NOT NULL,
DescripcionPersonal NVARCHAR(500)  NULL,
ZonaCobertura NVARCHAR(100)  NULL,
ExperienciaAnios INT NOT NULL DEFAULT (0),
DisponibilidadHoraria NVARCHAR(100)  NULL,
PromedioCalificacion DECIMAL(3,2) DEFAULT 0, 
Estado VARCHAR(10) NULL DEFAULT ('Activo'),

CONSTRAINT FK_PROVEEDOR_Oficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio),

CONSTRAINT PROVEEDOR_DNI     UNIQUE (DNI),
CONSTRAINT PROVEEDOR_Email   UNIQUE (Email),
CONSTRAINT PROVEEDOR_Estado  CHECK (Estado IN ('Activo','Inactivo')),
CONSTRAINT PROVEEDOR_Exp     CHECK (ExperienciaAnios >= 0)
)

CREATE TABLE SolicitudServicio(
IDSolicitud INT IDENTITY(1,1) PRIMARY KEY, 
IDCliente INT NOT NULL,
IDProveedor INT NOT NULL,
IDOficio INT NOT NULL,
FechaSolicitud DATETIME DEFAULT GETDATE(),
DescripcionTarea NVARCHAR(1000) NOT NULL,
Estado VARCHAR(15) NOT NULL DEFAULT ('Pendiente'),
FechaInicio DATETIME NULL, 
FechaFin DATETIME NULL,

CONSTRAINT FK_SOL_Cliente FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
CONSTRAINT FK_SOL_Proveedor FOREIGN KEY (IDProveedor) REFERENCES Proveedor(IDProveedor),
CONSTRAINT FK_SOL_Oficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio),

CONSTRAINT SOLICITUD_Fechas CHECK (FechaFin IS NULL OR (FechaInicio IS NULL AND FechaFin >= FechaSolicitud) 
OR
(FechaInicio IS NOT NULL AND FechaFin >= FechaInicio)), 

CONSTRAINT SOL_FechaSol CHECK (
    (FechaInicio IS NULL OR FechaSolicitud <= FechaInicio)
    AND (FechaFin IS NULL OR FechaSolicitud <= FechaFin)
)
)

CREATE TABLE Detalle(
IDDetalle INT IDENTITY(1,1) PRIMARY KEY,
IDSolicitud INT NOT NULL,
Descripcion NVARCHAR(1000) NULL, 
FechaHora DATETIME DEFAULT GETDATE(),
CalificacionCliente INT NULL, 
CalificacionProveedor INT NULL,

CONSTRAINT DETALLE_Solicitud UNIQUE (IDSolicitud),
CONSTRAINT FK_DETALLE_Solicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud),
CONSTRAINT DETALLE_CalCli CHECK (CalificacionCliente >= 1 and CalificacionCliente <=5),
CONSTRAINT DETALLE_CalProv CHECK (CalificacionProveedor >= 1 and CalificacionProveedor <=5),
--- CONSTRAINT Calificacion CHECK (CalificacionCliente = ISNULL(NULL, 'Sin califacion') AND CalificacionProveedor = ISNULL(NULL, 0.00)),
--- CONSULTAR PROFE porque si yo le saco el null, el trigger va a dejar de funcionar, porque pregunta si en la califacion hay NULL
--- pero queda mal en la subconsulta poner NULL, preguntar si prefiere que no lo cambiemos a 0
--- APARTE, 0 tampoco puede quedar por el constraint que tienen que ser de 1 a 5. 
--- TALVEZ sea mejor ponerle un string y modificar el trigger para que no tome en cuenta los strings, que de igual manera no lo toma en cuenta.
)


---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------
-- OFICIO
---------------------------------------------------------
INSERT INTO Oficio (NombreOficio, Descripcion) VALUES
('Electricista', 'Instalaciones eléctricas domiciliarias y comerciales.'),
('Plomero', 'Reparaciones de cañerías, pérdidas y griferías.'),
('Pintor', 'Pintura de interiores, exteriores y fachadas.'),
('Carpintero', 'Fabricación y reparación de muebles de madera.'),
('Jardinero', 'Mantenimiento de jardines y espacios verdes.'),
('Cerrajero', 'Apertura de cerraduras y duplicado de llaves.'),
('Gasista', 'Instalaciones y mantenimiento de gas domiciliario.'),
('Albañil', 'Construcción y refacciones en hogares.'),
('Techista', 'Reparación de techos y filtraciones.'),
('Herrero', 'Portones, rejas y estructuras metálicas.'),
('Vidriero', 'Colocación y reemplazo de vidrios.'),
('Peluquero', 'Cortes y tratamientos capilares.'),
('Mecánico', 'Reparación de automóviles y motos.'),
('Paseador de Perros', 'Paseo y cuidado de mascotas.'),
('Informático', 'Soporte técnico y mantenimiento de PC.');

---------------------------------------------------------
-- CLIENTE
---------------------------------------------------------
INSERT INTO Cliente (Nombre, Apellido, DNI, Email, Telefono)
VALUES
('Lucía', 'Gómez', '45123987', 'lucia.gomez@gmail.com', 1123456789),
('Martín', 'Rivas', '40256890', 'martin.rivas@gmail.com', 1167891234),
('Carla', 'Fernández', '38745123', 'carla.fernandez@hotmail.com', 1133345566),
('Pablo', 'Suárez', '39845123', 'pablo.suarez@gmail.com', 1145671234),
('Laura', 'Benítez', '41789234', 'laura.benitez@gmail.com', 1176543210),
('Emanuel', 'Roldán', '40567812', 'emanuel.roldan@gmail.com', 1165432198),
('Camila', 'Díaz', '43678122', 'camila.diaz@gmail.com', 1187654309),
('Pedro', 'Romero', '39456789', 'pedro.romero@gmail.com', 1122233344),
('Sofía', 'Luna', '40123456', 'sofia.luna@gmail.com', 1134567890),
('Lucas', 'Navarro', '43156789', 'lucas.navarro@gmail.com', 1198765432),
('Julieta', 'Acosta', '41234567', 'julieta.acosta@gmail.com', 1143216547),
('Tomás', 'Vega', '42345678', 'tomas.vega@gmail.com', 1156789342),
('Milagros', 'Peralta', '40456789', 'milagros.peralta@gmail.com', 1178932156),
('Nicolás', 'Rey', '39567812', 'nicolas.rey@gmail.com', 1134598765),
('Daniela', 'Paz', '42233456', 'daniela.paz@gmail.com', 1167823451);

---------------------------------------------------------
-- PROVEEDOR
---------------------------------------------------------
INSERT INTO Proveedor (Nombre, Apellido, DNI, IDOficio, Email, Telefono, FechaNacimiento, DescripcionPersonal, ZonaCobertura, ExperienciaAnios, DisponibilidadHoraria, Estado)
VALUES
('Juan', 'Pérez', '32145678', 1, 'juan.perez@gmail.com', 116666777, '1987-04-10', 'Electricista matriculado con más de 10 años de experiencia.', 'CABA y GBA', 10, 'Lunes a Viernes 9-18h', 'Activo'),
('Sofía', 'Méndez', '36543210', 2, 'sofia.mendez@gmail.com', 117777888, '1990-08-15', 'Plomera especialista en gas y sanitarios.', 'Zona Sur', 8, 'Lunes a Sábado 8-17h', 'Activo'),
('Carlos', 'Ramírez', '29876543', 3, 'carlos.ramirez@gmail.com', 115555666, '1985-03-22', 'Pintor profesional de interiores.', 'Zona Norte', 12, 'Lunes a Viernes 10-18h', 'Activo'),
('Mariana', 'Lopez', '34567890', 4, 'mariana.lopez@gmail.com', 113334455, '1989-07-19', 'Carpintera artesanal.', 'CABA', 6, 'Lunes a Viernes 8-16h', 'Activo'),
('Emanuel', 'Rodríguez', '37890123', 5, 'emanuel.rodriguez@gmail.com', 118888999, '1988-05-02', 'Jardinero con amplia experiencia.', 'Zona Oeste', 7, 'Lunes a Sábado 9-18h', 'Activo'),
('Gonzalo', 'Prieto', '38214567', 6, 'gonzalo.prieto@gmail.com', 114567899, '1991-02-11', 'Cerrajero 24hs.', 'Toda CABA', 5, 'Full Time', 'Activo'),
('Florencia', 'Campos', '35432167', 7, 'florencia.campos@gmail.com', 117894321, '1990-11-14', 'Gasista matriculada.', 'Zona Norte', 9, 'Lunes a Viernes 9-17h', 'Activo'),
('Miguel', 'Álvarez', '35671234', 8, 'miguel.alvarez@gmail.com', 119003456, '1986-09-09', 'Albañil especializado en refacciones.', 'Zona Sur', 11, 'Lunes a Sábado 8-18h', 'Activo'),
('Héctor', 'Ferreyra', '38901234', 9, 'hector.ferreyra@gmail.com', 117003221, '1984-12-21', 'Techista experto en impermeabilización.', 'CABA', 15, 'Full Time', 'Activo'),
('Martina', 'Bianchi', '40123490', 10, 'martina.bianchi@gmail.com', 116547890, '1992-02-02', 'Herrera con trabajos personalizados.', 'Zona Oeste', 5, 'Lunes a Viernes 10-17h', 'Activo'),
('Paula', 'Silva', '39567845', 11, 'paula.silva@gmail.com', 114567899, '1989-10-04', 'Vidriera profesional.', 'CABA', 6, 'Lunes a Viernes 9-16h', 'Activo'),
('Nahuel', 'Torres', '37777888', 12, 'nahuel.torres@gmail.com', 117895432, '1993-06-03', 'Peluquero con 8 años de experiencia.', 'Palermo', 8, 'Martes a Domingo 10-20h', 'Activo'),
('Lucía', 'Morales', '36234567', 13, 'lucia.morales@gmail.com', 118765432, '1994-03-01', 'Mecánica especializada en autos.', 'Avellaneda', 6, 'Lunes a Sábado 9-19h', 'Activo'),
('Bruno', 'Acosta', '38678912', 14, 'bruno.acosta@gmail.com', 115673209, '1985-09-06', 'Paseador con experiencia en animales grandes.', 'Caballito', 9, 'Todos los días 8-20h', 'Activo'),
('Cintia', 'Rey', '39456712', 15, 'cintia.rey@gmail.com', 114567892, '1992-05-27', 'Soporte técnico IT a domicilio.', 'CABA', 4, 'Lunes a Viernes 10-18h', 'Activo');

---------------------------------------------------------
-- SOLICITUD SERVICIO
---------------------------------------------------------
INSERT INTO SolicitudServicio (IDCliente, IDProveedor, IDOficio, DescripcionTarea, Estado, FechaInicio, FechaFin, FechaSolicitud)
VALUES
(1, 1, 1, 'Instalar luces LED en cocina y living.', 'Finalizado', '2024-02-02', '2024-02-04', '2024-02-01'),
(2, 2, 2, 'Reparar pérdida de agua en baño.', 'Finalizado', '2024-02-05', '2024-02-06', '2024-02-04'),
(3, 3, 3, 'Pintar dormitorio principal.', 'En Progreso', '2024-02-10', NULL, '2024-02-09'),
(1, 4, 4, 'Construir estante de madera.', 'Pendiente', NULL, NULL, '2024-02-10'),
(4, 5, 5, 'Podar árboles del jardín.', 'Finalizado', '2024-02-15', '2024-02-16', '2024-02-14'),
(5, 6, 6, 'Abrir cerradura trabada.', 'Finalizado', '2024-02-18', '2024-02-18', '2024-02-17'),
(6, 7, 7, 'Revisión de instalación de gas.', 'Finalizado', '2024-02-20', '2024-02-21', '2024-02-19'),
(7, 8, 8, 'Colocar cerámicos en baño.', 'En Progreso', '2024-02-25', NULL, '2024-02-24'),
(8, 9, 9, 'Reparar filtración en techo.', 'Pendiente', NULL, NULL, '2024-02-26'),
(9, 10, 10, 'Soldar portón de entrada.', 'Finalizado', '2024-02-28', '2024-02-29', '2024-02-27'),
(10, 11, 11, 'Reemplazar vidrio de ventana.', 'Finalizado', '2024-03-01', '2024-03-02', '2024-02-29'),
(11, 12, 12, 'Corte y color completo.', 'Finalizado', '2024-03-03', '2024-03-03', '2024-03-02'),
(12, 13, 13, 'Cambio de bujías y aceite.', 'Finalizado', '2024-03-04', '2024-03-05', '2024-03-03'),
(13, 14, 14, 'Pasear perro 2 horas.', 'Finalizado', '2024-03-06', '2024-03-06', '2024-03-05'),
(14, 15, 15, 'Revisión de notebook.', 'Pendiente', NULL, NULL, '2024-03-06'),
(1, 1, 1, 'Revisar instalación eléctrica completa.', 'Finalizado', '2024-03-08', '2024-03-09', '2024-03-07'),
(2, 2, 2, 'Instalar nuevo termotanque.', 'Finalizado', '2024-03-10', '2024-03-11', '2024-03-09'),
(1, 3, 3, 'Pintar cocina y pasillo.', 'En Progreso', '2024-03-15', NULL, '2024-03-14'),
(1, 9, 9, 'Reparar gotera en techo.', 'Finalizado', '2024-03-20', '2024-03-21', '2024-03-19'),
(3, 4, 4, 'Armar mueble modular.', 'Pendiente', NULL, NULL, '2024-03-21');

---------------------------------------------------------
-- DETALLE
---------------------------------------------------------
INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor, FechaHora)
VALUES
(1, 'Excelente trabajo, prolijo y rápido.', 5, 5, '2024-02-05'),
(2, 'Muy buena atención, resolvió rápido.', 4, 5, '2024-02-07'),
(3, 'Buen avance, aún falta terminar.', 4, NULL, '2024-02-11'),
(4, 'Pendiente de realización.', NULL, NULL, '2024-02-10'),
(5, 'Muy conforme con el resultado.', 5, 5, '2024-02-16'),
(6, 'Llegó rápido y resolvió el problema.', 5, 5, '2024-02-18'),
(7, 'Excelente gasista, muy profesional.', 5, 5, '2024-02-21'),
(8, 'Va bien el trabajo.', 4, 4, '2024-02-26'),
(9, 'Aún no vino.', NULL, NULL, '2024-02-26'),
(10, 'Trabajo impecable.', 5, 5, '2024-03-01'),
(11, 'Buen servicio y puntual.', 5, 5, '2024-03-02'),
(12, 'Excelente atención y resultado.', 5, 5, '2024-03-03'),
(13, 'Muy responsable.', 5, 5, '2024-03-05'),
(14, 'Pendiente.', NULL, NULL, '2024-03-06'),
(15, 'Revisión completa, sin inconvenientes.', 5, 5, '2024-03-09'),
(16, 'Muy buena instalación eléctrica.', 5, 5, '2024-03-09'),
(17, 'Buen trabajo, algo caro.', 4, 4, '2024-03-11'),
(18, 'Excelente pintor.', 5, 5, '2024-03-15'),
(19, 'Reparación rápida y efectiva.', 5, 5, '2024-03-21'),
(20, 'Aún sin realizar.', NULL, NULL, '2024-03-21');


---------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------
-- CRUD OFICIO
-----------------------------------------------------------
CREATE PROCEDURE agregarOficio
-- Estos son los parametros que vamos a llamar al hacer la funcion, es decir, que valores no pide la funcion y que le vamos a escribir.
    @NombreOficio NVARCHAR(100),
    @Descripcion NVARCHAR(200)
AS
BEGIN
    INSERT INTO Oficio (NombreOficio, Descripcion)
    VALUES (@NombreOficio, @Descripcion);
END;

DROP PROCEDURE agregarOficio;

-- El execute tiene que estar, el profe igual despues va a probar con otras cosas.

EXEC agregarOficio Peluquero, 'Mujer y hombre, uso de tintes y demas.'; 
SELECT * FROM Oficio;


CREATE PROCEDURE BorrarOficio
-- lo mismo que antes
    @IDOficio INT
AS
BEGIN
--Aca tuve que ir borrando todos los cosos de todas las tablas porque estan asociadas por un foreign key y tira error sino.
    -- Eliminamos los detalles de las solicitudes que tengan este oficio
    DELETE Detalle
    FROM Detalle detalle
    JOIN SolicitudServicio solicitud ON detalle.IDSolicitud = solicitud.IDSolicitud
    WHERE solicitud.IDOficio = @IDOficio;

    -- Eliminamos las solicitudes asociadas a este oficio
    DELETE FROM SolicitudServicio
    WHERE IDOficio = @IDOficio;

    -- Eliminamos los proveedores que tienen ese oficio
    DELETE FROM Proveedor
    WHERE IDOficio = @IDOficio;

    -- Eliminamos el oficio
    DELETE FROM Oficio
    WHERE IDOficio = @IDOficio;
END;


EXEC BorrarOficio 2;
DROP PROCEDURE BorrarOficio;
SELECT * FROM SolicitudServicio;


-----------------------------------------------------------
-- CRUD CLIENTE
-----------------------------------------------------------
CREATE PROCEDURE actualizarTelefono
	@IDCliente INT,
	@Telefono INT
AS 
BEGIN
	UPDATE Cliente
	SET Telefono = @Telefono --La columna telefono va a tomar el valor que nosotros le ingresemos 1=@Telefono --> Telefono = 1
	WHERE IDCliente = @IDCliente; --Lo mismo solo que este es para buscar en vez de reemplazar.
END;

EXEC actualizarTelefono 1,1;

SELECT * FROM SolicitudServicio;

CREATE PROCEDURE agregarCliente
	@Nombre NVARCHAR(100),
	@Apellido NVARCHAR(100),
	@Email NVARCHAR(100),
	@DNI VARCHAR(100),
	@Telefono INT
AS
BEGIN
	INSERT INTO Cliente (Nombre, Apellido, Email, DNI, Telefono)
	VALUES (@Nombre, @Apellido, @Email, @DNI, @Telefono)
END;

EXEC agregarCliente  'Facundo', 'Alvarez', 'facundopijudo@gmail.com', 46871506, 73628234;  

DROP PROCEDURE agregarCliente;

SELECT * FROM Cliente;


-----------------------------------------------------------
-- CRUD PROVEEDOR
-----------------------------------------------------------


CREATE PROCEDURE actualizarEstadoProveedor
    @IDProveedor INT,
    @Estado VARCHAR(10)
AS
BEGIN
    UPDATE Proveedor
    SET Estado = @Estado
    WHERE IDProveedor = @IDProveedor;
END;


EXEC actualizarEstadoProveedor 3, 'Inactivo';
SELECT * FROM Proveedor;


CREATE PROCEDURE agregarProveedor
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @DNI VARCHAR(10),
    @IDOficio INT,
    @Email NVARCHAR(255),
    @Telefono INT,
    @FechaNacimiento DATE,
    @DescripcionPersonal NVARCHAR(500),
    @ZonaCobertura NVARCHAR(100),
    @ExperienciaAnios INT,
    @DisponibilidadHoraria NVARCHAR(100),
    @Estado VARCHAR(10)
AS
BEGIN
    INSERT INTO Proveedor (Nombre, Apellido, DNI, IDOficio, Email, Telefono, FechaNacimiento, DescripcionPersonal, ZonaCobertura, ExperienciaAnios, DisponibilidadHoraria, Estado)
    VALUES (@Nombre, @Apellido, @DNI, @IDOficio, @Email, @Telefono, @FechaNacimiento, @DescripcionPersonal, @ZonaCobertura, @ExperienciaAnios, @DisponibilidadHoraria, @Estado);
END;


EXEC agregarProveedor 'Ramon', 'Gutierrez', '36071822', 4, 'RamonCerraduras@gmail.com', 1122334455, '12-5-2000','soy un tipazo', 'Moron y alrededores', 8, '8 a 16', 'Activo';
SELECT * FROM Proveedor;

-----------------------------------------------------------
-- CRUD SOLICITUDSERVICIO
-----------------------------------------------------------
CREATE PROCEDURE actualizarEstadoSolicitud
    @IDSolicitud INT,
    @Estado VARCHAR(15)
AS
BEGIN
    UPDATE SolicitudServicio
    SET Estado = @Estado
    WHERE IDSolicitud = @IDSolicitud;
END;


EXEC actualizarEstadoSolicitud 5, 'Finalizado';
SELECT * FROM SolicitudServicio;

CREATE PROCEDURE agregarSolicitud
    @IDCliente INT,
    @IDProveedor INT,
    @IDOficio INT,
    @DescripcionTarea NVARCHAR(1000),
    @Estado VARCHAR(15),
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    INSERT INTO SolicitudServicio (IDCliente, IDProveedor, IDOficio, DescripcionTarea, Estado, FechaInicio, FechaFin)
    VALUES (@IDCliente, @IDProveedor, @IDOficio, @DescripcionTarea, @Estado, @FechaInicio, @FechaFin);
END;


EXEC agregarSolicitud 3, 5, 5, 'Fabricar un escritorio de madera', 'Finalizado', '15-10-2025', '17-10-2025';
SELECT * FROM SolicitudServicio;

-------------------------------------------------
--CRUD DETALLE
-------------------------------------------------


CREATE PROCEDURE actualizarDetalleCalificacion
    @IDDetalle INT,
    @CalificacionCliente INT
AS
BEGIN
    UPDATE Detalle
    SET CalificacionCliente = @CalificacionCliente
    WHERE IDDetalle = @IDDetalle;
END;

EXEC actualizarDetalleCalificacion 6, 5;
SELECT * FROM Detalle;

CREATE PROCEDURE agregarDetalle
    @IDSolicitud INT,
    @Descripcion NVARCHAR(1000),
    @CalificacionCliente INT = NULL,
    @CalificacionProveedor INT = NULL
AS
BEGIN
    INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor)
    VALUES (@IDSolicitud, @Descripcion, @CalificacionCliente, @CalificacionProveedor);
END;


EXEC agregarDetalle 5, 'Mal servicio', 3,1;
SELECT * FROM Detalle;


-------------------------------------------------
--TRIGGERS
-------------------------------------------------


CREATE OR ALTER TRIGGER actualizarPromedios
ON Detalle --Le paso la tabla la cual va afectar al trigger
AFTER INSERT, UPDATE
AS
BEGIN
    -- Promedio PROVEEDOR
    UPDATE Proveedor
    SET PromedioCalificacion = ISNULL(( --El ISNULL hace que si el primero es null lo reemplaze por otro ISNULL(NULL, 0,00) si tiene un valor devuelve ese valor ISNULL(4.3, 0.00) devuvle 4,3
        SELECT AVG(D.CalificacionCliente)
        FROM Detalle D
        JOIN SolicitudServicio S ON D.IDSolicitud = S.IDSolicitud --Este para que una el detalle con la solicitud
        WHERE S.IDProveedor = P.IDProveedor -- Con el join de antes podemos saber que proveedor esta anidado a que detalle
          AND D.CalificacionCliente IS NOT NULL --Para que no cuente las calificaciones con NULL
    ), 0.00)
    FROM Proveedor P
    WHERE P.IDProveedor IN ( --Va a usar solo los proveedores que fueron afectados por el insert, update. No va a trabajar con todos las filas
        SELECT S.IDProveedor
        FROM SolicitudServicio S
        JOIN inserted i ON S.IDSolicitud = i.IDSolicitud --Inserted es una tabla virtual, que tiene solo las filas afectadas de antes.
    );	--Este where solo devuelve el idproveedor afectado, no el de todos.

    -- Promedio CLIENTE
    UPDATE Cliente
    SET PromedioCalificacion = ISNULL(( --El ISNULL hace que si el primero es null lo reemplaze por otro ISNULL(NULL, 0,00)
        SELECT AVG(D.CalificacionProveedor)
        FROM Detalle D
        JOIN SolicitudServicio S ON D.IDSolicitud = S.IDSolicitud
        WHERE S.IDCliente = C.IDCliente
          AND D.CalificacionProveedor IS NOT NULL --Para que no cuenta las calificaciones con NULL
    ), 0.00)
    FROM Cliente C
    WHERE C.IDCliente IN (
        SELECT S.IDCliente
        FROM SolicitudServicio S
        JOIN inserted i ON S.IDSolicitud = i.IDSolicitud
    );
END;

DROP TRIGGER actualizarPromedios;

SELECT IDProveedor, PromedioCalificacion FROM Proveedor;



CREATE TRIGGER automaticaFechaFin
ON SolicitudServicio
AFTER UPDATE
AS
BEGIN
    -- Actualiza la FechaFin cuando el estado pasa a 'Finalizado' y aún está vacía
    UPDATE s
    SET s.FechaFin = GETDATE()
    FROM SolicitudServicio s
    INNER JOIN inserted i ON s.IDSolicitud = i.IDSolicitud
    WHERE i.Estado = 'Finalizado'
      AND s.FechaFin IS NULL;
END;



-------------------------------------------------
--DEFINICION DE PROCEDIMIENTO ALMACENADO GENERAL
-------------------------------------------------

CREATE PROCEDURE solicitudesPorCliente
    @IDCliente INT
AS
BEGIN
    SELECT S.IDSolicitud, O.NombreOficio, S.Estado, S.FechaSolicitud, S.DescripcionTarea
    FROM SolicitudServicio S
    JOIN Oficio O ON S.IDOficio = O.IDOficio
    WHERE S.IDCliente = @IDCliente;
END;


EXEC solicitudesPorCliente 5;


-------------------------------------------------
--Proveedor
-------------------------------------------------
--FUNCION EJEMPLO -- Funcion booleana, preguntar si existe algun proveedor inactivo.






------------------------------------------------------
-- SUBCONSULTAS
------------------------------------------------------
-- Ver todas las solicitudes con cliente y proveedor
SELECT s.IDSolicitud, c.Nombre AS Cliente, p.Nombre AS Proveedor, o.NombreOficio, s.Estado, s.FechaSolicitud
FROM SolicitudServicio s
JOIN Cliente c ON s.IDCliente = c.IDCliente
JOIN Proveedor p ON s.IDProveedor = p.IDProveedor
JOIN Oficio o ON s.IDOficio = o.IDOficio;

-- Ver los detalles con calificaciones
SELECT d.IDDetalle, c.Nombre + ' ' + c.Apellido AS Cliente, 
       p.Nombre + ' ' + p.Apellido AS Proveedor,
       d.CalificacionCliente, d.CalificacionProveedor, d.Descripcion
FROM Detalle d
JOIN SolicitudServicio s ON d.IDSolicitud = s.IDSolicitud
JOIN Cliente c ON s.IDCliente = c.IDCliente
JOIN Proveedor p ON s.IDProveedor = p.IDProveedor;


-- Ver solo los proveedores con su promedio calificacion
Select p.nombre + ' ' + p.apellido as Proveedor, o.nombreoficio as oficio, p.promediocalificacion from Proveedor p 
JOIN oficio o on p.IDOficio = o.IDOficio; 

--Ver las reseñas que le dejaron a Carlos Ramirez en sus trabajos
Select	c.Nombre + ' ' + c.Apellido as Cliente, d.descripcion as reseñas, p.nombre + ' ' + p.apellido as Proveedor from Proveedor p
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Detalle d on d.IDSolicitud = s.IDSolicitud
JOIN Cliente c on c.IDCliente = s.IDCliente
where p.nombre = 'Carlos' and p.apellido = 'Ramírez';

--Ver las solicitudes que estan pendientes
Select c.Nombre + ' ' + c.Apellido as Cliente, s.Estado , p.nombre + ' ' + p.apellido as Proveedor, s.DescripcionTarea from Proveedor p
JOIN SolicitudServicio s on s.IDProveedor = p.IDProveedor 
JOIN Cliente c on c.IDCliente = s.IDCliente
WHERE s.Estado = 'Pendiente';

--Devolver el proveedor mas solicitado el top 1, en caso que haya muchos con igual cantidad obtiene el de mayor promedio de calificacion
Select top 1 p.nombre + ' ' + p.apellido as ElProveedorMasSolicitado, COUNT(s.IDcliente) AS CantidadSolicitudes, p.PromedioCalificacion 
From Proveedor p
JOIN SolicitudServicio s on s.IDProveedor = p.IDProveedor 
group by p.promediocalificacion, p.nombre, p.Apellido 
ORDER by COUNT(s.IDCliente) DESC, COUNT(p.promediocalificacion);
--- CREO QUE ESTA ESTA MAL, EL CALCULO DE PROMEDIOCALIFICACION. MARIANA LOPEZ TIENE 0, y vi un par que tienen misma cant soli, pero + prom

--Devolver las solicitudes finalizadas en el mes septiembre de 2025
Select c.Nombre + ' ' + c.Apellido as Cliente, s.Estado , p.nombre + ' ' + p.apellido as Proveedor, s.DescripcionTarea, s.fechaInicio, s.Fechafin
From Proveedor p 
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Cliente c on c.IDCliente = s.IDCliente
Where s.Estado = 'Finalizado' AND s.FechaFin BETWEEN '2025-09-01' AND '2025-09-30';
--- REVISAR SUBCONSULTA, DEBE HACER UN PROBLEMA CON EL TEMA FECHAS DEL INSERT Y TABLA

--Devolver proveedores con menos de 7años de experiencia
Select p.nombre + ' ' + p.apellido as Proveedor, ExperienciaAnios, o.nombreoficio as Oficio From Proveedor p
JOIN Oficio o on p.IDOficio = o.IDOficio
Where ExperienciaAnios < 7;

--Devolver todos los plomeros que trabajen full time
Select p.nombre + ' ' + p.apellido as Proveedor, o.NombreOficio as Oficio, p.disponibilidadhoraria
From Proveedor p  
JOIN Oficio o on o.IDOficio = p.IDOficio
where DisponibilidadHoraria = 'Full time';


--Devolver la cantidad de solicitudes que hizo cada cliente
Select c.Nombre + ' ' + c.Apellido as Cliente, COUNT(S.IDCLIENTE) as CantidadSolicitudes
From cliente c 
JOIN SolicitudServicio s on c.IDCliente = s.IDCliente
Group by c.nombre, c.Apellido;


