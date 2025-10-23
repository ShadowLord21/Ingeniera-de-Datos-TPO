CREATE TABLE Oficio(
IDOficio INT PRIMARY KEY,
NombreOficio NVARCHAR (100) NOT NULL,
Descripcion NVARCHAR(200) NULL,
)

CREATE TABLE Cliente(
IDCliente INT PRIMARY KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(10) NOT NULL,
Email NVARCHAR(100) NOT NULL,
Telefono INT, 
FechaRegistro DATETIME DEFAULT GETDATE(),
CONSTRAINT CIENTE_DNI UNIQUE (DNI),
CONSTRAINT CLIENTE_Email UNIQUE (Email)
)

CREATE TABLE Proveedor(
IDProveedor INT PRIMARY KEY,
Nombre NVARCHAR(100) NOT NULL,
Apellido NVARCHAR(100) NOT NULL,
DNI VARCHAR(10) NOT NULL,
IDOficio INT,
Email NVARCHAR(255)  NOT NULL,
Telefono NVARCHAR(20)   NOT NULL,
FechaNacimiento DATE NOT NULL,
DescripcionPersonal NVARCHAR(500)  NULL,
ZonaCobertura NVARCHAR(100)  NULL,
ExperienciaAnios INT NOT NULL DEFAULT (0),
DisponibilidadHoraria NVARCHAR(100)  NULL,
PromedioCalificacion DECIMAL(3,2) NOT NULL,
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
FechaInicio DATETIME NULL, --NO SE QUE HACER ACA 
FechaFin DATETIME NULL, --LO MISMO

CONSTRAINT FK_SOL_Cliente FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
CONSTRAINT FK_SOL_Proveedor FOREIGN KEY (IDProveedor) REFERENCES Proveedor(IDProveedor),
CONSTRAINT FK_SOL_Oficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio),

CONSTRAINT SOLICITUD_Fechas CHECK (FechaFin IS NULL OR (FechaInicio IS NULL AND FechaFin >= FechaSolicitud) 
OR
(FechaInicio IS NOT NULL AND FechaFin >= FechaInicio)), --NO TENGO IDEA QUE ACABO DE HACER ACA, HICE MIL Y ESTA FUE LA QUE MAS ME CONVENCIO

CONSTRAINT SOL_FechaSol CHECK (FechaSolicitud >= FechaInicio and FechaSolicitud >= FechaFin), 
)

CREATE TABLE Detalle(
IDDetalle INT IDENTITY(1,1) PRIMARY KEY,
IDSolicitud INT NOT NULL,
Descripcion NVARCHAR(1000) NULL, 
FechaHora DATETIME DEFAULT GETDATE(),
CalificacionCliente INT, --ACA LO HACEMOS QUE SEA OPCIONAL CALIFICAR AL CLIENTE?
CalificacionProveedor INT,--ACA LO HACEMOS QUE SEA OPCIONAL CALIFICAR AL PROVEEDOR?

CONSTRAINT DETALLE_Solicitud UNIQUE (IDSolicitud),
CONSTRAINT FK_DETALLE_Solicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud),
CONSTRAINT DETALLE_CalCli CHECK (CalificacionCliente >= 1 and CalificacionCliente <=5),
CONSTRAINT DETALLE_CalProv CHECK (CalificacionProveedor >= 1 and CalificacionProveedor <=5),
)

--UNOS INSERTS QUE LE PEDI AL CHATGPT PARA IR PROBANDO QUE ONDA
INSERT INTO Oficio (IDOficio, NombreOficio, Descripcion)
VALUES 
(1, 'Electricista', 'Instalaciones y reparaciones eléctricas.'),
(2, 'Plomero', 'Reparación de cañerías, griferías y sanitarios.'),
(3, 'Pintor', 'Pintura interior y exterior de viviendas.'),
(4, 'Carpintero', 'Muebles a medida y reparaciones de madera.');

INSERT INTO Cliente (IDCliente, Nombre, Apellido, DNI, Email, Telefono)
VALUES 
(1, 'Lucía', 'Gómez', '45123987', 'lucia.gomez@gmail.com', 1123456789),
(2, 'Martín', 'Rivas', '40256890', 'martin.rivas@gmail.com', 1167891234),
(3, 'Carla', 'Fernández', '38745123', 'carla.fernandez@hotmail.com', 1133345566);

INSERT INTO Proveedor (IDProveedor, Nombre, Apellido, DNI, IDOficio, Email, Telefono, FechaNacimiento, DescripcionPersonal, ZonaCobertura, ExperienciaAnios, DisponibilidadHoraria, PromedioCalificacion, Estado)
VALUES
(1,'Juan', 'Pérez', '32145678', 1, 'juan.perez@gmail.com', '1166667777', '1987-04-10', 'Electricista matriculado con 10 años de experiencia.', 'CABA y GBA', 10, 'Lunes a Viernes 9-18h', 4.8, 'Activo'),
(2,'Sofía', 'Méndez', '36543210', 2, 'sofia.mendez@gmail.com', '1177778888', '1990-08-15', 'Especialista en plomería y gas domiciliario.', 'Zona Sur', 8, 'Lunes a Sábado 8-17h', 4.5, 'Activo'),
(3,'Carlos', 'Ramírez', '29876543', 3, 'carlos.ramirez@gmail.com', '1155556666', '1985-03-22', 'Pintor profesional de interiores y exteriores.', 'Zona Norte', 12, 'Lunes a Viernes 10-18h', 4.9, 'Activo');

INSERT INTO SolicitudServicio (IDCliente, IDProveedor, IDOficio, DescripcionTarea, Estado, FechaInicio, FechaFin)
VALUES
(1, 1, 1, 'Instalar nuevas luces LED en el living y cocina.', 'Finalizado', '2025-10-10', '2025-10-12'),
(2, 2, 2, 'Reparar una pérdida de agua en el baño.', 'En Progreso', '2025-10-20', NULL),
(3, 3, 3, 'Pintar dormitorio principal color blanco.', 'Pendiente', NULL, NULL);

INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor)
VALUES
(1, 'Trabajo excelente, rápido y prolijo.', 5, 5),
(2, 'Buena atención, falta terminar el trabajo.', 4, NULL);
-- El tercer pedido no tiene detalle porque sigue pendiente

--UNAS CONSULTAS PARA VER QUE ONDA TMB

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
