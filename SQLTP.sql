USE TP;

CREATE TABLE Cliente(
IDCliente INT IDENTITY(1,1) PRIMARY KEY,
Nombre VARCHAR(50) NOT NULL,
Apellido VARCHAR(50) NOT NULL,
DNI INT NOT NULL UNIQUE,
Email NVARCHAR(30) NOT NULL, 
Telefono NVARCHAR(20) NOT NULL,
Direccion NVARCHAR(100) NOT NULL,
FechaRegistro DATE NOT NULL,
Estado BIT NOT NULL DEFAULT 1,--0(INACTIVO), 1(ACTIV0)

CONSTRAINT CfechaRegistro CHECK (FechaRegistro >= CAST(GETDATE() as date))); 

CREATE TABLE Oficio(
IDOficio INT IDENTITY(1,1) PRIMARY KEY,
NombreOficio NVARCHAR(100) NOT NULL,
Descripcion NVARCHAR(300) NOT NULL);

CREATE TABLE Proveedor(
IDProveedor INT IDENTITY(1,1) PRIMARY KEY,
Nombre VARCHAR(50) NOT NULL,
Apellido VARCHAR(50) NOT NULL,
DNI INT NOT NULL UNIQUE,
Email NVARCHAR(100) NOT NULL,
Telefono NVARCHAR(20)NOT NULL,
Direccion NVARCHAR(100) NOT NULL,
IDOficio INT,
DescripcionPersonal NVARCHAR(300) NOT NULL,
ZonaCobertura NVARCHAR(70) NOT NULL,
PrecioEstimado INT NOT NULL,
ExperienciaAños INT NOT NULL,
DisponibilidadHorario NVARCHAR(50) NOT NULL,
PromedioCalificacion DECIMAL(3, 2) NOT NULL, -- (3,2) -- 3 SIGNIFICA 3 DIGITOS EN TOTAL Y 2 SON DECIMALES
Estado BIT DEFAULT 1,

CONSTRAINT fkOficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio));--0(inactivo), 1(activo)

CREATE TABLE SolicitudServicio(
IDSolicitud INT IDENTITY(1,1) PRIMARY KEY,
IDCliente INT ,
IDProveedor INT,
IDOficio INT,
FechaSolicitud DATE NOT NULL,
DescripcionTarea NVARCHAR(300) NOT NULL, --SACAR
Estado NVARCHAR(60) NOT NULL CHECK (Estado IN ('Pendiente', 'Aceptado', 'En Progreso', 'Finalizado', 'Cancelado')),
FechaInicio DATE NOT NULL,
FechaFin DATE NOT NULL,

CONSTRAINT Cfechafin CHECK (FechaFin >= FechaInicio),
CONSTRAINT CfechaInicio CHECK (FechaInicio >= FechaSolicitud),
CONSTRAINT CfechaSolicitud CHECK (FechaSolicitud >= CAST(GETDATE() as date)),

CONSTRAINT fkIDCliente FOREIGN KEY (IDCliente) REFERENCES Cliente(IDCliente),
CONSTRAINT fkIDOficio FOREIGN KEY (IDOficio) REFERENCES Oficio(IDOficio),
CONSTRAINT fkIDProveedor FOREIGN KEY (IDProveedor) REFERENCES Proveedor(IDProveedor));

CREATE TABLE Calificacion(
IDCalificacion INT IDENTITY(1,1) PRIMARY KEY,
IDSolicitud INT,
Puntuacion INT CHECK (Puntuacion >= 1 and Puntuacion <= 5),
Comentario NVARCHAR(300) NOT NULL,
FechaCalificacion DATE NOT NULL,

CONSTRAINT fkI1DSolicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud));

CREATE TABLE Mensaje(
IDMensaje INT IDENTITY(1,1) PRIMARY KEY,
IDSolicitud INT,
Emisor NVARCHAR(100) NOT NULL,
TextoMensaje NVARCHAR(1000) NOT NULL,
FechaHora DATETIME NOT NULL,

CONSTRAINT fkIDSolicitud FOREIGN KEY (IDSolicitud) REFERENCES SolicitudServicio(IDSolicitud));

DROP TABLE Calificacion;
DROP TABLE Cliente;
DROP TABLE Oficio;
DROP TABLE Proveedor;
DROP TABLE SolicitudServicio;


	
