USE TPGrupo1;

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
-- 🧱 OFICIO
---------------------------------------------------------
INSERT INTO Oficio (IDOficio, NombreOficio, Descripcion)
VALUES 
(1, 'Electricista', 'Instalaciones eléctricas y mantenimiento.'),
(2, 'Plomero', 'Reparaciones de cañerías, griferías y sanitarios.'),
(3, 'Pintor', 'Pintura interior y exterior.'),
(4, 'Cerrajero', 'Instalación y apertura de cerraduras.'),
(5, 'Carpintero', 'Fabricación y reparación de muebles.'),
(6, 'Jardinero', 'Mantenimiento de jardines y césped.'),
(7, 'Gasista', 'Instalaciones de gas domiciliarias.'),
(8, 'Albañil', 'Refacciones y obras menores.'),
(9, 'Técnico PC', 'Reparación y mantenimiento de computadoras.'),
(10, 'Herrero', 'Fabricación de estructuras metálicas.');

---------------------------------------------------------
-- 👥 CLIENTE
---------------------------------------------------------
INSERT INTO Cliente (IDCliente, Nombre, Apellido, DNI, Email, Telefono)
VALUES 
(1, 'Lucía', 'Gómez', '45123987', 'lucia.gomez@gmail.com', 1123456789),
(2, 'Martín', 'Rivas', '40256890', 'martin.rivas@gmail.com', 1167891234),
(3, 'Carla', 'Fernández', '38745123', 'carla.fernandez@hotmail.com', 1133345566),
(4, 'Pedro', 'Martínez', '41233456', 'pedro.martinez@gmail.com', 1145697823),
(5, 'Laura', 'Benítez', '40321789', 'laura.benitez@hotmail.com', 1176543210),
(6, 'Camila', 'Peralta', '45678234', 'camila.peralta@gmail.com', 1190011223),
(7, 'Ezequiel', 'López', '42877654', 'eze.lopez@gmail.com', 1167788990),
(8, 'Ramiro', 'Vega', '43321567', 'ramiro.vega@gmail.com', 1145623456),
(9, 'Valentina', 'Ortiz', '44678901', 'valen.ortiz@gmail.com', 1189987766),
(10, 'Diego', 'Suárez', '42123456', 'diego.suarez@gmail.com', 1133345567);

---------------------------------------------------------
-- 🔧 PROVEEDOR
---------------------------------------------------------
INSERT INTO Proveedor (IDProveedor, Nombre, Apellido, DNI, IDOficio, Email, Telefono, FechaNacimiento, DescripcionPersonal, ZonaCobertura, ExperienciaAnios, DisponibilidadHoraria, Estado)
VALUES
(1,'Juan', 'Pérez', '32145678', 1, 'juan.perez@gmail.com', '1166667777', '1987-04-10', 'Electricista matriculado con 10 años de experiencia.', 'CABA', 10, 'Lunes a Viernes 9-18h', 'Activo'),
(2,'Sofía', 'Méndez', '36543210', 2, 'sofia.mendez@gmail.com', '1177778888', '1990-08-15', 'Especialista en plomería y gas.', 'Zona Sur', 8, 'Lunes a Sábado 8-17h', 'Activo'),
(3,'Carlos', 'Ramírez', '29876543', 3, 'carlos.ramirez@gmail.com', '1155556666', '1985-03-22', 'Pintor de interiores y exteriores.', 'Zona Norte', 12, 'Lunes a Viernes 10-18h', 'Activo'),
(4,'Lucía', 'Torres', '33456789', 4, 'lucia.torres@gmail.com', '1145678901', '1992-06-20', 'Cerrajera con servicio de urgencias.', 'Zona Oeste', 7, 'Full time', 'Activo'),
(5,'Emanuel', 'Rodríguez', '35487965', 5, 'emanuel.rod@gmail.com', '1144456677', '1991-11-05', 'Carpintero con experiencia en muebles.', 'CABA', 6, 'Lunes a Sábado 8-16h', 'Activo'),
(6,'Gabriela', 'Morales', '37221543', 6, 'gaby.morales@gmail.com', '1166655544', '1989-02-28', 'Jardinera paisajista.', 'Zona Norte', 10, 'Full time', 'Activo'),
(7,'Tomás', 'Pardo', '39654432', 7, 'tomas.pardo@gmail.com', '1133322211', '1990-12-17', 'Gasista matriculado.', 'Zona Sur', 9, 'Lunes a Viernes 9-17h', 'Activo'),
(8,'Santiago', 'Quiroga', '38547721', 8, 'santi.quiroga@gmail.com', '1144455566', '1988-09-08', 'Albañil profesional en remodelaciones.', 'Zona Oeste', 8, 'Lunes a Sábado 9-18h', 'Activo'),
(9,'Franco', 'Giménez', '42765234', 9, 'franco.gimenez@gmail.com', '1155544433', '1995-07-11', 'Técnico de PC y redes.', 'Zona Norte', 4, 'Lunes a Sábado 10-19h', 'Activo'),
(10,'Micaela', 'Luna', '40326754', 10, 'mica.luna@gmail.com', '1177788899', '1993-04-14', 'Herrera especializada en portones.', 'CABA', 5, 'Lunes a Viernes 8-16h', 'Activo');

---------------------------------------------------------
-- 📄 SOLICITUD SERVICIO
---------------------------------------------------------
INSERT INTO SolicitudServicio (IDCliente, IDProveedor, IDOficio, DescripcionTarea, Estado, FechaInicio, FechaFin)
VALUES
(1, 1, 1, 'Instalar luces LED en cocina.', 'Finalizado', '2025-10-10', '2025-10-12'),
(1, 2, 2, 'Reparar pérdida de agua en baño.', 'Finalizado', '2025-10-13', '2025-10-14'),
(1, 3, 3, 'Pintar living.', 'Pendiente', NULL, NULL),
(1, 4, 4, 'Cambiar cerradura del dormitorio.', 'Finalizado', '2025-10-18', '2025-10-18'),

(2, 5, 5, 'Fabricar mueble a medida.', 'Finalizado', '2025-09-15', '2025-09-20'),
(2, 6, 6, 'Poda de jardín trasero.', 'En Progreso', '2025-10-05', NULL),
(2, 7, 7, 'Revisión de instalación de gas.', 'Finalizado', '2025-09-25', '2025-09-26'),
(2, 8, 8, 'Refacción de baño pequeño.', 'Finalizado', '2025-09-30', '2025-10-02'),

(3, 9, 9, 'Revisión de PC que no enciende.', 'Finalizado', '2025-09-10', '2025-09-10'),
(3, 10, 10, 'Soldadura de estructura metálica.', 'Pendiente', NULL, NULL),
(4, 1, 1, 'Revisión de instalación eléctrica general.', 'Finalizado', '2025-09-25', '2025-09-26'),
(5, 3, 3, 'Pintura de dormitorio.', 'Finalizado', '2025-09-20', '2025-09-21'),
(6, 2, 2, 'Cambio de caño en cocina.', 'Finalizado', '2025-10-01', '2025-10-02'),
(7, 8, 8, 'Reparación de muro del patio.', 'En Progreso', '2025-10-15', NULL),
(8, 6, 6, 'Mantenimiento general del jardín.', 'Pendiente', NULL, NULL);

---------------------------------------------------------
-- 🧾 DETALLE
---------------------------------------------------------
INSERT INTO Detalle (IDSolicitud, Descripcion, CalificacionCliente, CalificacionProveedor)
VALUES
(16, 'Excelente trabajo, muy prolijo.', 5, 5),
(2, 'Muy buena atención, resolvió rápido.', 4, 4),
(3, 'Pendiente de ejecución.', NULL, NULL),
(4, 'Puntual y prolija.', 5, 5),

(5, 'Trabajo excelente, mueble perfecto.', 5, 5),
(6, 'Aún en progreso.', NULL, NULL),
(7, 'Trabajo completo y seguro.', 4, 4),
(8, 'Muy conforme, refacción impecable.', 5, 5),

(9, 'Diagnóstico rápido y solución inmediata.', 5, 5),
(10, 'Pendiente de soldadura.', NULL, NULL),
(11, 'Servicio eléctrico correcto.', 4, 4),
(12, 'Buena pintura, prolija.', 5, 5),	
(13, 'Plomería resuelta correctamente.', 4, 4),
(14, 'En proceso de reparación.', NULL, NULL),
(15, 'Buen trato y compromiso.', 5, 5);

BEGIN TRAN;

DELETE FROM Detalle;           -- hija (suele referenciar Solicitud/Proveedor)
DELETE FROM SolicitudServicio; -- hija (suele referenciar Cliente/Proveedor/Oficio)
DELETE FROM Proveedor;         -- padre
DELETE FROM Oficio;            -- padre
DELETE FROM Cliente;           -- padre

COMMIT;

ALTER TABLE Proveedor
ALTER COLUMN PromedioCalificacion DECIMAL(3,2) NULL;

ALTER TABLE Detalle
ALTER COLUMN CalificacionProveedor INT NULL;

select * from Detalle;

select * from SolicitudServicio;

select * from Proveedor;

select * from Oficio;

select * from Cliente;

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


-- Ver solo los proveedores con su promedio calificacion
Select p.nombre + ' ' + p.apellido as Proveedor, o.nombreoficio as oficio, p.promediocalificacion from Proveedor p 
JOIN oficio o on p.IDOficio = o.IDOficio;


--Ver las reseñas que le dejaron a Carlos Ramirez en sus trabajos
Select	c.Nombre + ' ' + c.Apellido as Cliente, d.descripcion as reseñas, p.nombre + ' ' + p.apellido as Proveedor from Proveedor p
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Detalle d on d.IDSolicitud = s.IDSolicitud
JOIN Cliente c on c.IDCliente = s.IDCliente
where p.nombre = 'Carlos';

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

--Devolver las solicitudes finalizadas en el mes septiembre de 2025
Select c.Nombre + ' ' + c.Apellido as Cliente, s.Estado , p.nombre + ' ' + p.apellido as Proveedor, s.DescripcionTarea, s.fechaInicio, s.Fechafin
From Proveedor p 
JOIN SolicitudServicio s on p.IDProveedor = s.IDProveedor 
JOIN Cliente c on c.IDCliente = s.IDCliente
Where s.Estado = 'Finalizado' AND s.FechaFin BETWEEN '2025-09-01' AND '2025-09-30';

--Devolver proveedores con menos de 7años de experiencia
Select nombre + ' ' + apellido as Proveedor, ExperienciaAnios from Proveedor 
Where ExperienciaAnios <= 7;


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




