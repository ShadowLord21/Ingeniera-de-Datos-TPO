USE SQLTPO;

IF OBJECT_ID('dbo.DETALLE', 'U') IS NOT NULL DROP TABLE dbo.DETALLE;
IF OBJECT_ID('dbo.SOLICITUDSERVICIO', 'U') IS NOT NULL DROP TABLE dbo.SOLICITUDSERVICIO;
IF OBJECT_ID('dbo.PROVEEDOR_OFICIO', 'U') IS NOT NULL DROP TABLE dbo.PROVEEDOR_OFICIO;
IF OBJECT_ID('dbo.PROVEEDOR', 'U') IS NOT NULL DROP TABLE dbo.PROVEEDOR;
IF OBJECT_ID('dbo.OFICIO', 'U') IS NOT NULL DROP TABLE dbo.OFICIO;
IF OBJECT_ID('dbo.CLIENTE', 'U') IS NOT NULL DROP TABLE dbo.CLIENTE;
GO



CREATE TABLE Oficio(
IDOficio INT IDENTITY (1,1) PRIMARY KEY,
NombreOficio NVARCHAR (100) NOT NULL,
Descripcion NVARCHAR(200) NULL,
)

CREATE TABLE Cliente(
IDCliente INT IDENTITY (1,1) PRIMARY KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(15) NOT NULL,
Email NVARCHAR(100) NULL,
Telefono INT, 
FechaRegistro DATETIME DEFAULT SYSDATETIME(),
PromedioCalificacion DECIMAL (3,2) DEFAULT 0,


CONSTRAINT CIENTE_DNI UNIQUE (DNI),
CONSTRAINT CLIENTE_Email UNIQUE (Email),
)

CREATE TABLE Proveedor(
IDProveedor INT IDENTITY (1,1) PRIMARY  KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(15) NOT NULL,
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

    FechaSolicitud DATETIME NOT NULL DEFAULT SYSDATETIME(),
    DescripcionTarea NVARCHAR(1000) NOT NULL,
    Estado VARCHAR(15) NOT NULL DEFAULT ('Pendiente'),

    FechaInicio DATETIME NULL,
    FechaFin DATETIME NULL,

    CONSTRAINT FK_SOL_Cliente FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
    CONSTRAINT FK_SOL_Proveedor FOREIGN KEY (IDProveedor) REFERENCES Proveedor(IDProveedor),
    CONSTRAINT FK_SOL_Oficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio),

    CONSTRAINT CK_Solicitud_Fechas CHECK (
        (FechaInicio IS NULL OR FechaInicio >= FechaSolicitud)
        AND
        (FechaFin IS NULL OR FechaInicio IS NULL OR FechaFin >= FechaInicio)
    )
);

CREATE TABLE Detalle(
IDDetalle INT IDENTITY(1,1) PRIMARY KEY,
IDSolicitud INT NOT NULL,
Descripcion NVARCHAR(1000) NULL, 
FechaHora DATETIME DEFAULT SYSDATETIME(),
CalificacionCliente INT NULL, 
CalificacionProveedor INT NULL,

CONSTRAINT DETALLE_Solicitud UNIQUE (IDSolicitud),
CONSTRAINT FK_DETALLE_Solicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud),
CONSTRAINT DETALLE_CalCli CHECK (CalificacionCliente >= 1 and CalificacionCliente <=5),
CONSTRAINT DETALLE_CalProv CHECK (CalificacionProveedor >= 1 and CalificacionProveedor <=5),
)

-----------------------------------------------------------------------------------------------------------------------------

--                                                             TRIGGERS

-----------------------------------------------------------------------------------------------------------------------------


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



CREATE or ALTER TRIGGER automaticaFechaFin
ON SolicitudServicio
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE s
    SET s.FechaFin =
        CASE
            WHEN s.FechaInicio IS NOT NULL 
                 AND SYSDATETIME() < s.FechaInicio 
                THEN s.FechaInicio     -- evita romper el CHECK
            ELSE SYSDATETIME()         -- solo si no rompe nada
        END
    FROM SolicitudServicio s
    INNER JOIN inserted i ON s.IDSolicitud = i.IDSolicitud
    WHERE i.Estado = 'Finalizado'
      AND s.FechaFin IS NULL;
END;
GO


DISABLE TRIGGER automaticaFechaFin ON SolicitudServicio;



---------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------

--                                                        EXECUTES

-----------------------------------------------------------------------------------------------------------------------------
--Se deben crear primero los procedure para poder realizar los inserts.
-------------------------------------------------------------------------------------------
--Execute de Oficio
-------------------------------------------------------------------------------------------

--Borrar un Oficio
EXEC BorrarOficio 2;

EXEC agregarOficio  'Peluquero', 'Mujer y hombre, uso de tintes y demas.';
EXEC agregarOficio 'Electricista', 'Me cago en todo';
EXEC agregarOficio 'Electricista', 'Instalaciones eléctricas domiciliarias y comerciales.';
EXEC agregarOficio 'Plomero', 'Reparaciones de cañerías, pérdidas y griferías.';
EXEC agregarOficio 'Pintor', 'Pintura de interiores, exteriores y fachadas.';
EXEC agregarOficio 'Carpintero', 'Fabricación y reparación de muebles de madera.';
EXEC agregarOficio 'Jardinero', 'Mantenimiento de jardines y espacios verdes.';
EXEC agregarOficio 'Cerrajero', 'Apertura de cerraduras y duplicado de llaves.';
EXEC agregarOficio 'Gasista', 'Instalaciones y mantenimiento de gas domiciliario.';
EXEC agregarOficio 'Albañil', 'Construcción y refacciones en hogares.';
EXEC agregarOficio 'Techista', 'Reparación de techos y filtraciones.';
EXEC agregarOficio 'Herrero', 'Portones, rejas y estructuras metálicas.';
EXEC agregarOficio 'Vidriero', 'Colocación y reemplazo de vidrios.';
EXEC agregarOficio 'Peluquero', 'Cortes y tratamientos capilares.';
EXEC agregarOficio 'Mecánico', 'Reparación de automóviles y motos.';
EXEC agregarOficio 'Paseador de Perros', 'Paseo y cuidado de mascotas.';
EXEC agregarOficio 'Informático', 'Soporte técnico y mantenimiento de PC.';
GO

-------------------------------------------------------------------------------------------
--Execute de Cliente
-------------------------------------------------------------------------------------------

--Actualizar Telefono
EXEC actualizarTelefono 1,1;

EXEC agregarCliente 'Facundo', 'Alvarez', '46871506', 'facundopijudo@gmail.com', 73628234;
EXEC agregarCliente 'Lucía', 'Gómez', '45123987', 'lucia.gomez@gmail.com', 1123456789;
EXEC agregarCliente 'Martín', 'Rivas', '40256890', 'martin.rivas@gmail.com', 1167891234;
EXEC agregarCliente 'Carla', 'Fernández', '38745123', 'carla.fernandez@hotmail.com', 1133345566;
EXEC agregarCliente 'Pablo', 'Suárez', '39845123', 'pablo.suarez@gmail.com', 1145671234;
EXEC agregarCliente 'Laura', 'Benítez', '41789234', 'laura.benitez@gmail.com', 117654321;
EXEC agregarCliente 'Emanuel', 'Roldán', '40567812', 'emanuel.roldan@gmail.com', 1165432198;
EXEC agregarCliente 'Camila', 'Díaz', '43678122', 'camila.diaz@gmail.com', 1187654309;
EXEC agregarCliente 'Pedro', 'Romero', '39456789', 'pedro.romero@gmail.com', 1122233344;
EXEC agregarCliente 'Sofía', 'Luna', '40123456', 'sofia.luna@gmail.com', 1134567890;
EXEC agregarCliente 'Lucas', 'Navarro', '43156789', 'lucas.navarro@gmail.com', 1198765432;
EXEC agregarCliente 'Julieta', 'Acosta', '41234567', 'julieta.acosta@gmail.com', 1143216547;
EXEC agregarCliente 'Tomás', 'Vega', '42345678', 'tomas.vega@gmail.com', 1156789342;
EXEC agregarCliente 'Milagros', 'Peralta', '40456789', 'milagros.peralta@gmail.com', 1178932156;
EXEC agregarCliente 'Nicolás', 'Rey', '39567812', 'nicolas.rey@gmail.com', 1134598765;
EXEC agregarCliente 'Daniela', 'Paz', '42233456', 'daniela.paz@gmail.com', 1167823451;
GO

-------------------------------------------------------------------------------------------
--Execute de Proveedor
-------------------------------------------------------------------------------------------
EXEC actualizarEstadoProveedor 3, 'Inactivo';

EXEC agregarProveedor 'Ramon', 'Gutierrez', '36071822', 4, 'RamonCerraduras@gmail.com', 1122334455, '12-5-2000','soy un tipazo', 'Moron y alrededores', 8, '8 a 16', 'Activo';
EXEC agregarProveedor 'Juan', 'Pérez', '32145678', 1, 'juan.perez@gmail.com', 116666777, '1987-04-10', 'Electricista matriculado con más de 10 años de experiencia.', 'CABA y GBA', 10, 'Lunes a Viernes 9-18h', 'Activo';
EXEC agregarProveedor 'Sofía', 'Méndez', '36543210', 2, 'sofia.mendez@gmail.com', 117777888, '1990-08-15', 'Plomera especialista en gas y sanitarios.', 'Zona Sur', 8, 'Lunes a Sábado 8-17h', 'Activo';
EXEC agregarProveedor 'Carlos', 'Ramírez', '29876543', 3, 'carlos.ramirez@gmail.com', 115555666, '1985-03-22', 'Pintor profesional de interiores.', 'Zona Norte', 12, 'Lunes a Viernes 10-18h', 'Activo';
EXEC agregarProveedor 'Mariana', 'Lopez', '34567890', 4, 'mariana.lopez@gmail.com', 113334455, '1989-07-19', 'Carpintera artesanal.', 'CABA', 6, 'Lunes a Viernes 8-16h', 'Activo';
EXEC agregarProveedor 'Emanuel', 'Rodríguez', '37890123', 5, 'emanuel.rodriguez@gmail.com', 118888999, '1988-05-02', 'Jardinero con amplia experiencia.', 'Zona Oeste', 7, 'Lunes a Sábado 9-18h', 'Activo';
EXEC agregarProveedor 'Gonzalo', 'Prieto', '38214567', 6, 'gonzalo.prieto@gmail.com', 114567899, '1991-02-11', 'Cerrajero 24hs.', 'Toda CABA', 5, 'Full Time', 'Activo';
EXEC agregarProveedor 'Florencia', 'Campos', '35432167', 7, 'florencia.campos@gmail.com', 117894321, '1990-11-14', 'Gasista matriculada.', 'Zona Norte', 9, 'Lunes a Viernes 9-17h', 'Activo';
EXEC agregarProveedor 'Miguel', 'Álvarez', '35671234', 8, 'miguel.alvarez@gmail.com', 119003456, '1986-09-09', 'Albañil especializado en refacciones.', 'Zona Sur', 11, 'Lunes a Sábado 8-18h', 'Activo';
EXEC agregarProveedor 'Héctor', 'Ferreyra', '38901234', 9, 'hector.ferreyra@gmail.com', 117003221, '1984-12-21', 'Techista experto en impermeabilización.', 'CABA', 15, 'Full Time', 'Activo';
EXEC agregarProveedor 'Martina', 'Bianchi', '40123490', 10, 'martina.bianchi@gmail.com', 116547890, '1992-02-02', 'Herrera con trabajos personalizados.', 'Zona Oeste', 5, 'Lunes a Viernes 10-17h', 'Activo';
EXEC agregarProveedor 'Paula', 'Silva', '39567845', 11, 'paula.silva@gmail.com', 114567899, '1989-10-04', 'Vidriera profesional.', 'CABA', 6, 'Lunes a Viernes 9-16h', 'Activo';
EXEC agregarProveedor 'Nahuel', 'Torres', '37777888', 12, 'nahuel.torres@gmail.com', 117895432, '1993-06-03', 'Peluquero con 8 años de experiencia.', 'Palermo', 8, 'Martes a Domingo 10-20h', 'Activo';
EXEC agregarProveedor 'Lucía', 'Morales', '36234567', 13, 'lucia.morales@gmail.com', 118765432, '1994-03-01', 'Mecánica especializada en autos.', 'Avellaneda', 6, 'Lunes a Sábado 9-19h', 'Activo';
EXEC agregarProveedor 'Bruno', 'Acosta', '38678912', 14, 'bruno.acosta@gmail.com', 115673209, '1985-09-06', 'Paseador con experiencia en animales grandes.', 'Caballito', 9, 'Todos los días 8-20h', 'Activo';
EXEC agregarProveedor 'Cintia', 'Rey', '39456712', 15, 'cintia.rey@gmail.com', 114567892, '1992-05-27', 'Soporte técnico IT a domicilio.', 'CABA', 4, 'Lunes a Viernes 10-18h', 'Activo';
GO


-------------------------------------------------------------------------------------------
--Execute de SolicitudServicio
-------------------------------------------------------------------------------------------

EXEC actualizarEstadoSolicitud 5, 'Finalizado';

EXEC agregarSolicitud 1, 1, 1, 'Instalar luces LED en cocina y living.', 'Finalizado', '2026-02-04', NULL;
EXEC agregarSolicitud 2, 2, 2, 'Reparar pérdida de agua en baño.', 'Finalizado', '2026-02-05', '2026-02-06';
EXEC agregarSolicitud 3, 3, 3, 'Pintar dormitorio principal.', 'En Progreso', '2026-02-10', NULL;
EXEC agregarSolicitud 1, 4, 4, 'Construir estante de madera.', 'Pendiente', NULL, NULL;
EXEC agregarSolicitud 4, 5, 5, 'Podar árboles del jardín.', 'Finalizado', '2026-02-15', '2026-02-16';
EXEC agregarSolicitud 5, 6, 6, 'Abrir cerradura trabada.', 'Finalizado', '2026-02-18', '2026-02-18';
EXEC agregarSolicitud 6, 7, 7, 'Revisión de instalación de gas.', 'Finalizado', '2026-02-20', '2026-02-21';
EXEC agregarSolicitud 7, 8, 8, 'Colocar cerámicos en baño.', 'En Progreso', '2026-02-25', NULL;
EXEC agregarSolicitud 8, 9, 9, 'Reparar filtración en techo.', 'Pendiente', NULL, NULL;
EXEC agregarSolicitud 9, 10, 10, 'Soldar portón de entrada.', 'Finalizado', '2026-02-28', '2026-03-01';
EXEC agregarSolicitud 10, 11, 11, 'Reemplazar vidrio de ventana.', 'Finalizado', '2026-03-02', '2026-03-03';
EXEC agregarSolicitud 1, 12, 12, 'Corte y color completo.', 'Finalizado', '2026-03-04', '2026-03-04';
EXEC agregarSolicitud 12, 13, 13, 'Cambio de bujías y aceite.', 'Finalizado', '2026-03-05', '2026-03-06';
EXEC agregarSolicitud 13, 14, 14, 'Pasear perro 2 horas.', 'Finalizado', '2026-03-07', '2026-03-07';
EXEC agregarSolicitud 14, 15, 15, 'Revisión de notebook.', 'Pendiente', NULL, NULL;
EXEC agregarSolicitud 1, 1, 1, 'Revisar instalación eléctrica completa.', 'Finalizado', '2026-03-09', '2026-03-10';
EXEC agregarSolicitud 2, 2, 2, 'Instalar nuevo termotanque.', 'Finalizado', '2026-03-11', '2026-03-12';
EXEC agregarSolicitud 1, 3, 3, 'Pintar cocina y pasillo.', 'En Progreso', '2026-03-15', NULL;
EXEC agregarSolicitud 1, 9, 9, 'Reparar gotera en techo.', 'Finalizado', '2026-03-20', '2026-03-21';
EXEC agregarSolicitud 3, 4, 4, 'Armar mueble modular.', 'Pendiente', NULL, NULL;

GO



-------------------------------------------------------------------------------------------
--Execute de Detalle
-------------------------------------------------------------------------------------------
EXEC actualizarDetalleCalificacion 6, 5;

EXEC agregarDetalle 5, 'Mal servicio Excelente trabajo prolijo y rápido', 5, 5, '2024-02-05';
EXEC agregarDetalle 2, 'Muy buena atención, resolvió rápido.', 4, 5, '2024-02-07';
EXEC agregarDetalle 3, 'Buen avance, aún falta terminar.', 4, NULL, '2024-02-11';
EXEC agregarDetalle 4, 'Pendiente de realización.', NULL, NULL, '2024-02-10';
EXEC agregarDetalle 5, 'Muy conforme con el resultado.', 5, 5, '2024-02-16';
EXEC agregarDetalle 6, 'Llegó rápido y resolvió el problema.', 5, 5, '2024-02-18';
EXEC agregarDetalle 7, 'Excelente gasista, muy profesional.', 5, 5, '2024-02-21';
EXEC agregarDetalle 8, 'Va bien el trabajo.', 4, 4, '2024-02-26';
EXEC agregarDetalle 9, 'Aún no vino.', NULL, NULL, '2024-02-26';
EXEC agregarDetalle 10, 'Trabajo impecable.', 5, 5, '2024-03-01';
EXEC agregarDetalle 11, 'Buen servicio y puntual.', 5, 5, '2024-03-02';
EXEC agregarDetalle 12, 'Excelente atención y resultado.', 5, 5, '2024-03-03';
EXEC agregarDetalle 13, 'Muy responsable.', 5, 5, '2024-03-05';
EXEC agregarDetalle 14, 'Pendiente.', NULL, NULL, '2024-03-06';
EXEC agregarDetalle 15, 'Revisión completa, sin inconvenientes.', 5, 5, '2024-03-09';
EXEC agregarDetalle 16, 'Muy buena instalación eléctrica.', 5, 5, '2024-03-09';
EXEC agregarDetalle 17, 'Buen trabajo, algo caro.', 4, 4, '2024-03-11';
EXEC agregarDetalle 18, 'Excelente pintor.', 5, 5, '2024-03-15';
EXEC agregarDetalle 19, 'Reparación rápida y efectiva.', 5, 5, '2024-03-21';
EXEC agregarDetalle 20, 'Aún sin realizar.', NULL, NULL, '2024-03-21';
GO

SELECT * FROM SolicitudServicio;
SELECT * FROM Detalle;
------------------------------------------------------------------------------------------------------------------------------

--														CRUD

------------------------------------------------------------------------------------------------------------------------------
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


CREATE or ALTER PROCEDURE agregarCliente
	@Nombre NVARCHAR(100),
	@Apellido NVARCHAR(100),
	@DNI VARCHAR(100),
	@Email NVARCHAR(100),
	@Telefono INT
AS
BEGIN
	INSERT INTO Cliente (Nombre, Apellido, DNI, Email, Telefono)
	VALUES (@Nombre, @Apellido, @DNI, @Email, @Telefono)
END;


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



CREATE OR ALTER PROCEDURE agregarSolicitud
    @IDCliente INT,
    @IDProveedor INT,
    @IDOficio INT,
    @DescripcionTarea NVARCHAR(1000),
    @Estado VARCHAR(15),
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    INSERT INTO SolicitudServicio 
    (
        IDCliente, 
        IDProveedor, 
        IDOficio,
        FechaSolicitud,
        DescripcionTarea,
        Estado,
        FechaInicio,
        FechaFin
    )
    VALUES 
    (
        @IDCliente, 
        @IDProveedor, 
        @IDOficio,
        SYSDATETIME(),
        @DescripcionTarea, 
        @Estado, 
        @FechaInicio, 
        @FechaFin
    );
END;
GO



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


CREATE or ALTER PROCEDURE agregarDetalle
    @IDSolicitud INT,
    @Descripcion NVARCHAR(1000),
    @CalificacionCliente INT = NULL,
    @CalificacionProveedor INT = NULL,
	@FechaHora DATETIME
AS
BEGIN
    INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor, FechaHora)
    VALUES (@IDSolicitud, @Descripcion, @CalificacionCliente, @CalificacionProveedor, @FechaHora);
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



------------------------------------------------------------------------------------------------------------------------------

--													  FUNCION

------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION TotalDiasTrabajadosProveedor(@idProveedor INT)
RETURNS INT
AS
BEGIN
    DECLARE @totalDias INT;

    SELECT @totalDias = SUM(
        CASE
            WHEN FechaInicio IS NOT NULL AND FechaFin IS NOT NULL
                 AND FechaFin >= FechaInicio
            THEN DATEDIFF(DAY, FechaInicio, FechaFin)
            ELSE 0 -- servicios sin terminar o sin datos válidos
        END
    )
    FROM SolicitudServicio
    WHERE IDProveedor = @idProveedor
      AND Estado = 'Finalizado';

    IF @totalDias IS NULL
        SET @totalDias = 0;

    RETURN @totalDias;
END;
GO

SELECT dbo.TotalDiasTrabajadosProveedor(7) AS DiasTrabajados;


------------------------------------------------------------------------------------------------------------------------------

--													SUBCONSULTAS

------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------
-- SELECT Ver todas las solicitudes con cliente y proveedor
------------------------------------------------------------


SELECT s.IDSolicitud, c.Nombre AS Cliente, p.Nombre AS Proveedor, o.NombreOficio, s.Estado, s.FechaSolicitud
FROM SolicitudServicio s
JOIN Cliente c ON s.IDCliente = c.IDCliente
JOIN Proveedor p ON s.IDProveedor = p.IDProveedor
JOIN Oficio o ON s.IDOficio = o.IDOficio;


-----------------------------------------------------------
-- Ver los detalles con calificaciones
-----------------------------------------------------------


SELECT d.IDDetalle, c.Nombre + ' ' + c.Apellido AS Cliente, 
       p.Nombre + ' ' + p.Apellido AS Proveedor,
       d.CalificacionCliente, d.CalificacionProveedor, d.Descripcion
FROM Detalle d
JOIN SolicitudServicio s ON d.IDSolicitud = s.IDSolicitud
JOIN Cliente c ON s.IDCliente = c.IDCliente
JOIN Proveedor p ON s.IDProveedor = p.IDProveedor;


----------------------------------------------------------
-- Ver solo los proveedores con su promedio calificacion
----------------------------------------------------------


Select p.nombre + ' ' + p.apellido as Proveedor, o.nombreoficio as oficio, p.promediocalificacion from Proveedor p 
JOIN oficio o on p.IDOficio = o.IDOficio; 


------------------------------------------------------------------
--Ver las reseñas que le dejaron a Carlos Ramirez en sus trabajos
------------------------------------------------------------------


Select	c.Nombre + ' ' + c.Apellido as Cliente, d.descripcion as reseñas, p.nombre + ' ' + p.apellido as Proveedor from Proveedor p
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Detalle d on d.IDSolicitud = s.IDSolicitud
JOIN Cliente c on c.IDCliente = s.IDCliente
where p.nombre = 'Carlos' and p.apellido = 'Ramírez';


-----------------------------------------------------------------
--Ver las solicitudes que estan pendientes
-----------------------------------------------------------------
Select c.Nombre + ' ' + c.Apellido as Cliente, s.Estado , p.nombre + ' ' + p.apellido as Proveedor, s.DescripcionTarea from Proveedor p
JOIN SolicitudServicio s on s.IDProveedor = p.IDProveedor 
JOIN Cliente c on c.IDCliente = s.IDCliente
WHERE s.Estado = 'Pendiente';


---------------------------------------------------------------------------------------------------------------------------------------------
--Devolver el proveedor mas solicitado el top 1, en caso que haya muchos con igual cantidad obtiene el de mayor promedio de calificacion
---------------------------------------------------------------------------------------------------------------------------------------------


Select top 1 p.nombre + ' ' + p.apellido as ElProveedorMasSolicitado, COUNT(s.IDcliente) AS CantidadSolicitudes, p.PromedioCalificacion 
From Proveedor p
JOIN SolicitudServicio s on s.IDProveedor = p.IDProveedor 
group by p.promediocalificacion, p.nombre, p.Apellido 
ORDER by COUNT(s.IDCliente) DESC, p.promediocalificacion DESC;


--------------------------------------------------------------------
--Devolver las solicitudes finalizadas en el mes septiembre de 2025
--------------------------------------------------------------------


Select c.Nombre + ' ' + c.Apellido as Cliente, s.Estado , p.nombre + ' ' + p.apellido as Proveedor, s.DescripcionTarea, s.fechaInicio, s.Fechafin
From Proveedor p 
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Cliente c on c.IDCliente = s.IDCliente
Where s.Estado = 'Finalizado' AND s.FechaFin BETWEEN '2026-03-01' AND '2026-03-31';


----------------------------------------------------------
--Devolver proveedores con menos de 7años de experiencia
----------------------------------------------------------


Select p.nombre + ' ' + p.apellido as Proveedor, ExperienciaAnios, o.nombreoficio as Oficio From Proveedor p
JOIN Oficio o on p.IDOficio = o.IDOficio
Where ExperienciaAnios < 7;


----------------------------------------------------------
--Devolver todos los plomeros que trabajen full time
----------------------------------------------------------


Select p.nombre + ' ' + p.apellido as Proveedor, o.NombreOficio as Oficio, p.disponibilidadhoraria
From Proveedor p  
JOIN Oficio o on o.IDOficio = p.IDOficio
where DisponibilidadHoraria = 'Full time';


-------------------------------------------------------------
--Devolver la cantidad de solicitudes que hizo cada cliente
-------------------------------------------------------------


Select c.Nombre + ' ' + c.Apellido as Cliente, COUNT(S.IDCLIENTE) as CantidadSolicitudes
From cliente c 
JOIN SolicitudServicio s on c.IDCliente = s.IDCliente
Group by c.nombre, c.Apellido;


------------------------------------------------------
-- VISTAS
------------------------------------------------------

--Vista para mostrar los Plomeros con mejor calificacion (mayor a 3)

CREATE VIEW OficioPremium as
SELECT Proveedor.Nombre, Proveedor.Apellido, Proveedor.DescripcionPersonal, Proveedor.Email , Proveedor.DisponibilidadHoraria
FROM Proveedor
JOIN Oficio on Oficio.IDOficio = Proveedor.IDOficio
WHERE Oficio.NombreOficio = 'Plomero' and Proveedor.PromedioCalificacion > 3; 

Select * from OficioPremium;

--Vista para mostrar los oficios con mayor demanda (los primeros 3 que tengas mas solicitudes de servicio)

CREATE VIEW OficioConMayorDemanda AS
SELECT TOP 3
    o.IDOficio,
    o.NombreOficio,
    COUNT(s.IDOficio) AS cantidadSolicitudes
FROM Oficio o
JOIN SolicitudServicio s ON o.IDOficio = s.IDOficio
GROUP BY o.IDOficio, o.NombreOficio
ORDER BY cantidadSolicitudes DESC;

Select * from OficioConMayorDemanda;


--Vista para mostrar a los clientes mas calificados (premium) los proveedores mejores calificados

CREATE VIEW ClientesPremium AS
SELECT P.IDProveedor, P.Nombre, P.Apellido, P.DNI, P.IDOficio, P.Email, P.Telefono, P.FechaNacimiento,
P.DescripcionPersonal, P.ZonaCobertura, P.ExperienciaAnios, P.DisponibilidadHoraria, P.PromedioCalificacion, P.Estado FROM Proveedor P
JOIN Cliente C ON P.PromedioCalificacion = C.PromedioCalificacion
WHERE C.PromedioCalificacion > 3 AND P.PromedioCalificacion > 3; 


SELECT * FROM ClientesPremium;

