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
CalificacionCliente INT NULL, --ACA LO HACEMOS QUE SEA OPCIONAL CALIFICAR AL CLIENTE?
CalificacionProveedor INT NOT NULL,--ACA LO HACEMOS QUE SEA OPCIONAL CALIFICAR AL PROVEEDOR?

CONSTRAINT DETALLE_Solicitud UNIQUE (IDSolicitud),
CONSTRAINT FK_DETALLE_Solicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud),
CONSTRAINT DETALLE_CalCli CHECK (CalificacionCliente >= 1 and CalificacionCliente <=5),
CONSTRAINT DETALLE_CalProv CHECK (CalificacionProveedor >= 1 and CalificacionProveedor <=5),
)

--UNOS INSERTS QUE LE PEDI AL CHATGPT PARA IR PROBANDO QUE ONDA
---------------------------------------------------------
-- OFICIO
---------------------------------------------------------
INSERT INTO Oficio (IDOficio, NombreOficio, Descripcion)
VALUES 
(1, 'Electricista', 'Instalaciones y reparaciones eléctricas.'),
(2, 'Plomero', 'Reparación de cañerías, griferías y sanitarios.'),
(3, 'Pintor', 'Pintura interior y exterior de viviendas.'),
(4, 'Carpintero', 'Muebles a medida y reparaciones de madera.'),
(5, 'Jardinero', 'Mantenimiento de jardines, césped y plantas.'),
(6, 'Cerrajero', 'Apertura de cerraduras y copias de llaves.'),
(7, 'Gasista', 'Instalaciones y revisiones de gas domiciliario.'),
(8, 'Herrero', 'Fabricación de estructuras metálicas y rejas.'),
(9, 'Albañil', 'Construcción, refacciones y trabajos de mampostería.'),
(10, 'Técnico PC', 'Reparación y mantenimiento de computadoras.'),
(11, 'Vidriero', 'Colocación y reparación de vidrios.'),
(12, 'Peluquero', 'Servicios de corte y color a domicilio.'),
(13, 'Tapicero', 'Tapizado y restauración de muebles.'),
(14, 'Pintor de autos', 'Pintura y pulido de carrocerías.'),
(15, 'Electricista industrial', 'Instalaciones eléctricas en fábricas y galpones.');

---------------------------------------------------------
-- CLIENTE
---------------------------------------------------------
INSERT INTO Cliente (IDCliente, Nombre, Apellido, DNI, Email, Telefono)
VALUES 
(1, 'Lucía', 'Gómez', '45123987', 'lucia.gomez@gmail.com', 1123456789),
(2, 'Martín', 'Rivas', '40256890', 'martin.rivas@gmail.com', 1167891234),
(3, 'Carla', 'Fernández', '38745123', 'carla.fernandez@hotmail.com', 1133345566),
(4, 'Pedro', 'Martínez', '41233456', 'pedro.martinez@gmail.com', 1145697823),
(5, 'Laura', 'Benítez', '40321789', 'laura.benitez@hotmail.com', 1176543210),
(6, 'Ezequiel', 'López', '42877654', 'eze.lopez@gmail.com', 1167788990),
(7, 'Camila', 'Peralta', '45678234', 'camila.peralta@gmail.com', 1190011223),
(8, 'Ramiro', 'Vega', '43321567', 'ramiro.vega@gmail.com', 1145623456),
(9, 'Valentina', 'Ortiz', '44678901', 'valen.ortiz@gmail.com', 1189987766),
(10, 'Diego', 'Suárez', '42123456', 'diego.suarez@gmail.com', 1133345567),
(11, 'Mauro', 'Quiroga', '43122987', 'mauro.quiroga@gmail.com', 1178965412),
(12, 'Rocío', 'Pérez', '43567987', 'rocio.perez@gmail.com', 1189912233),
(13, 'Federico', 'Santos', '44765432', 'fede.santos@gmail.com', 1198877665),
(14, 'Julieta', 'García', '42899123', 'julieta.garcia@gmail.com', 1177788990),
(15, 'Nicolás', 'Campos', '45233456', 'nico.campos@gmail.com', 1155544332);

---------------------------------------------------------
-- PROVEEDOR
---------------------------------------------------------
INSERT INTO Proveedor (IDProveedor, Nombre, Apellido, DNI, IDOficio, Email, Telefono, FechaNacimiento, DescripcionPersonal, ZonaCobertura, ExperienciaAnios, DisponibilidadHoraria, PromedioCalificacion, Estado)
VALUES
(1,'Juan', 'Pérez', '32145678', 1, 'juan.perez@gmail.com', '1166667777', '1987-04-10', 'Electricista matriculado con 10 años de experiencia.', 'CABA y GBA', 10, 'Lunes a Viernes 9-18h', 4.8, 'Activo'),
(2,'Sofía', 'Méndez', '36543210', 2, 'sofia.mendez@gmail.com', '1177778888', '1990-08-15', 'Plomera con experiencia en gas domiciliario.', 'Zona Sur', 8, 'Lunes a Sábado 8-17h', 4.5, 'Activo'),
(3,'Carlos', 'Ramírez', '29876543', 3, 'carlos.ramirez@gmail.com', '1155556666', '1985-03-22', 'Pintor profesional de interiores y exteriores.', 'Zona Norte', 12, 'Lunes a Viernes 10-18h', 4.9, 'Activo'),
(4,'Lucía', 'Torres', '33456789', 4, 'lucia.torres@gmail.com', '1145678901', '1992-06-20', 'Carpintera especializada en muebles rústicos.', 'Zona Oeste', 7, 'Lunes a Viernes 10-18h', 4.6, 'Activo'),
(5,'Emanuel', 'Rodríguez', '35487965', 5, 'emanuel.rod@gmail.com', '1144456677', '1991-11-05', 'Jardinero con experiencia en diseño de jardines.', 'CABA', 6, 'Lunes a Sábado 8-16h', 4.7, 'Activo'),
(6,'Gabriela', 'Morales', '37221543', 6, 'gaby.morales@gmail.com', '1166655544', '1989-02-28', 'Cerrajera con servicio de urgencias 24hs.', 'Zona Norte', 10, 'Full time', 4.8, 'Activo'),
(7,'Tomás', 'Pardo', '39654432', 7, 'tomas.pardo@gmail.com', '1133322211', '1990-12-17', 'Gasista matriculado en hogares y edificios.', 'Zona Sur', 9, 'Lunes a Viernes 9-17h', 4.9, 'Activo'),
(8,'Santiago', 'Quiroga', '38547721', 8, 'santi.quiroga@gmail.com', '1144455566', '1988-09-08', 'Herrero especializado en estructuras y portones.', 'Zona Oeste', 8, 'Lunes a Sábado 9-18h', 4.5, 'Activo'),
(9,'Micaela', 'Luna', '40326754', 9, 'mica.luna@gmail.com', '1177788899', '1993-04-14', 'Albañila con 5 años de experiencia en refacciones.', 'CABA', 5, 'Lunes a Viernes 8-16h', 4.4, 'Activo'),
(10,'Franco', 'Giménez', '42765234', 10, 'franco.gimenez@gmail.com', '1155544433', '1995-07-11', 'Técnico en reparación de PCs y notebooks.', 'Zona Norte', 4, 'Lunes a Sábado 10-19h', 4.3, 'Activo'),
(11,'Roxana', 'Delgado', '41234567', 11, 'roxana.delgado@gmail.com', '1167799001', '1991-02-05', 'Vidriera profesional en locales comerciales.', 'CABA', 6, 'Lunes a Viernes 9-18h', 4.7, 'Activo'),
(12,'Luis', 'Moreno', '39221765', 12, 'luis.moreno@gmail.com', '1189901122', '1984-09-23', 'Peluquero a domicilio, especializado en cortes modernos.', 'Zona Sur', 14, 'Lunes a Sábado 10-20h', 4.9, 'Activo'),
(13,'Daniel', 'Funes', '37655342', 13, 'daniel.funes@gmail.com', '1178899900', '1987-12-19', 'Tapicero con taller propio.', 'Zona Oeste', 11, 'Lunes a Viernes 9-17h', 4.8, 'Activo'),
(14,'Clara', 'Silva', '38432111', 14, 'clara.silva@gmail.com', '1133322455', '1988-11-25', 'Pintora de autos y restauradora de carrocerías.', 'Zona Norte', 9, 'Lunes a Viernes 9-18h', 4.6, 'Activo'),
(15,'Oscar', 'Paz', '39876543', 15, 'oscar.paz@gmail.com', '1177765544', '1985-10-05', 'Electricista industrial en galpones.', 'GBA', 13, 'Full time', 4.9, 'Activo');

---------------------------------------------------------
-- SOLICITUD SERVICIO
---------------------------------------------------------
INSERT INTO SolicitudServicio (IDCliente, IDProveedor, IDOficio, DescripcionTarea, Estado, FechaInicio, FechaFin)
VALUES
(1, 1, 1, 'Instalar nuevas luces LED en el living.', 'Finalizado', '2025-10-10', '2025-10-12'),
(2, 3, 3, 'Pintar dormitorio principal color blanco.', 'En Progreso', '2025-10-15', NULL),
(3, 2, 2, 'Reparar pérdida de agua en cocina.', 'Pendiente', NULL, NULL),
(4, 5, 5, 'Podar y ordenar jardín delantero.', 'Finalizado', '2025-09-15', '2025-09-16'),
(5, 4, 4, 'Reparar puerta del placard.', 'Finalizado', '2025-09-20', '2025-09-21'),
(6, 9, 9, 'Reparar pared con humedad en baño.', 'Pendiente', NULL, NULL),
(7, 8, 8, 'Construir parrilla metálica para el patio.', 'En Progreso', '2025-10-05', NULL),
(8, 6, 6, 'Cambio de cerradura de puerta principal.', 'Finalizado', '2025-10-01', '2025-10-02'),
(9, 7, 7, 'Revisión de instalación de gas.', 'Finalizado', '2025-09-25', '2025-09-26'),
(10, 10, 10, 'Revisión de notebook que no enciende.', 'Pendiente', NULL, NULL),
(11, 11, 1, 'Instalación de cableado nuevo en oficina.', 'Finalizado', '2025-09-10', '2025-09-11'),
(12, 13, 13, 'Tapizado completo de sofá.', 'En Progreso', '2025-09-18', NULL),
(13, 14, 14, 'Pintura exterior de automóvil.', 'Finalizado', '2025-09-12', '2025-09-14'),
(14, 15, 15, 'Instalación eléctrica en galpón industrial.', 'Finalizado', '2025-09-25', '2025-09-28'),
(15, 12, 12, 'Corte y peinado a domicilio.', 'Pendiente', NULL, NULL);

INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor)
VALUES
(1, 'Excelente servicio, trabajo rápido y prolijo.', 5, 5),
(2, 'Buena atención, aún en proceso.', 4, 4),
(3, 'Pendiente de ejecución.', NULL, 3),
(4, 'Muy profesional y puntual.', 5, 5),
(5, 'Esperando fecha de inicio.', 4, 2),
(6, 'Trabajo impecable en madera.', 5, 5),
(7, 'En espera de contacto.', NULL, 4),
(8, 'Servicio rápido y confiable.', 5, 5),
(9, 'A mitad de obra, buen trato.', 4, 3),
(10, 'Excelente diagnóstico del técnico.', 5, 5),
(11, 'Vidrio colocado correctamente.', 5, 5),
(12, 'Muy conforme con el resultado.', 5, 5),
(13, 'Aún no comenzó el trabajo.', NULL, 5),
(14, 'Buen avance en pintura, falta pulido.', 4, 5),
(15, 'Instalación eléctrica completa y segura.', 5, 5);


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
