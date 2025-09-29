CREATE DATABASE VeterinariaDB;
USE VeterinariaDB;

CREATE TABLE Usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    rol ENUM('cliente','admin') DEFAULT 'cliente',
    password VARCHAR(255) NOT NULL
);

CREATE TABLE Veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Mascotas (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50),
    raza VARCHAR(50),
    edad INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);


CREATE TABLE Citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_veterinario INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    motivo VARCHAR(200),
    estado ENUM('pendiente','completada','cancelada') DEFAULT 'pendiente',
    FOREIGN KEY (id_mascota) REFERENCES Mascotas(id_mascota),
    FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario)
);

CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL
);


CREATE TABLE Ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    fecha DATE NOT NULL,
    total DECIMAL(10,2),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Detalle_Venta (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES Ventas(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
); 


INSERT INTO Usuarios (nombre, email, telefono, direccion, rol, password)
VALUES 
('Juan Pérez', 'juanperez@mail.com', '3001234567', 'Calle 123 #45-67', 'cliente', '1234'),
('Ana Gómez', 'anagomez@mail.com', '3109876543', 'Cra 12 #34-56', 'cliente', '1234'),
('Carlos Torres', 'carlost@mail.com', '3206549871', 'Av 45 #12-34', 'cliente', '1234'),
('Administrador', 'admin@vet.com', '3115551234', 'Sede Central', 'admin', 'admin123');


INSERT INTO Veterinarios (nombre, especialidad, telefono, email)
VALUES
('Dra. Laura Martínez', 'Medicina General', '3001112233', 'laura@vet.com'),
('Dr. Pedro Ramírez', 'Cirugía', '3014445566', 'pedro@vet.com'),
('Dra. Sofía López', 'Dermatología', '3027778899', 'sofia@vet.com');


INSERT INTO Mascotas (id_usuario, nombre, especie, raza, edad)
VALUES
(1, 'Firulais', 'Perro', 'Labrador', 5),
(1, 'Michi', 'Gato', 'Siames', 3),
(2, 'Rocky', 'Perro', 'Bulldog', 4),
(3, 'Nala', 'Gato', 'Persa', 2);


INSERT INTO Citas (id_mascota, id_veterinario, fecha, hora, motivo, estado)
VALUES
(1, 1, '2025-09-30', '10:00:00', 'Consulta general', 'pendiente'),
(2, 3, '2025-09-30', '11:30:00', 'Caída de pelo', 'pendiente'),
(3, 2, '2025-10-01', '09:00:00', 'Cirugía programada', 'pendiente'),
(4, 1, '2025-10-02', '14:00:00', 'Vacunación', 'pendiente');


INSERT INTO Productos (nombre, descripcion, precio, stock)
VALUES
('Vacuna Antirrábica', 'Protección contra la rabia', 45000, 50),
('Desparasitante', 'Tabletas antiparasitarias', 25000, 100),
('Concentrado Premium Perros', 'Alimento balanceado 10kg', 120000, 30),
('Shampoo Medicado', 'Control de pulgas y garrapatas', 35000, 40);


INSERT INTO Ventas (id_usuario, fecha, total)
VALUES
(1, '2025-09-23', 145000),
(2, '2025-09-24', 25000),
(3, '2025-09-24', 155000);


INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_unitario)
VALUES
(1, 1, 2, 45000),   -- Juan compra 2 vacunas antirrábicas
(1, 4, 1, 35000),   -- Juan compra 1 shampoo medicado
(2, 2, 1, 25000),   -- Ana compra 1 desparasitante
(3, 3, 1, 120000),  -- Carlos compra 1 bulto de concentrado
(3, 2, 1, 25000);   -- Carlos compra 1 desparasitante


DELIMITER //
CREATE PROCEDURE ActualizarCitasPerdida()
BEGIN
    UPDATE Citas
    SET estado = 'perdida'
    WHERE estado = 'pendiente'
      AND fecha = CURDATE()
      AND hora = DATE_FORMAT(NOW(), '%H:%i:%s');
END//
DELIMITER ;


-- 1. Sign up (Registro de usuario)
DELIMITER //
CREATE PROCEDURE SignUp(
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(200),
    IN p_password VARCHAR(255),
    IN p_rol ENUM('cliente','admin')
)
BEGIN
    INSERT INTO Usuarios (nombre, email, telefono, direccion, password, rol)
    VALUES (p_nombre, p_email, p_telefono, p_direccion, p_password, p_rol);
END//
DELIMITER ;

-- 2. Login (Validación de usuario)
DELIMITER //
CREATE FUNCTION Login(p_email VARCHAR(100), p_password VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_id INT;
    SELECT id_usuario INTO v_id
    FROM Usuarios
    WHERE email = p_email AND password = p_password;
    RETURN IFNULL(v_id, -1); -- devuelve -1 si no existe
END//
DELIMITER ;

-- 3. Inventario (Consultar stock de productos)
DELIMITER //
CREATE PROCEDURE VerInventario()
BEGIN
    SELECT id_producto, nombre, descripcion, precio, stock
    FROM Productos;
END//
DELIMITER ;

-- 4.Actualizacion stock
DELIMITER //
CREATE PROCEDURE ActualizarStock(
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    UPDATE Productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;
END//
DELIMITER ;

-- 5.Manejo de citas
DELIMITER //
CREATE PROCEDURE VerCitasCliente(IN p_id_usuario INT)
BEGIN
    SELECT c.id_cita, m.nombre AS mascota, v.nombre AS veterinario, c.fecha, c.hora, c.motivo, c.estado
    FROM Citas c
    JOIN Mascotas m ON c.id_mascota = m.id_mascota
    JOIN Veterinarios v ON c.id_veterinario = v.id_veterinario
    WHERE m.id_usuario = p_id_usuario;
END//
DELIMITER ;

-- 6. Compras (Registrar una venta)
DELIMITER //
CREATE PROCEDURE RegistrarCompra(
    IN p_id_usuario INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);

    -- obtener precio del producto
    SELECT precio INTO v_precio
    FROM Productos
    WHERE id_producto = p_id_producto;

    SET v_total = v_precio * p_cantidad;

    -- insertar venta
    INSERT INTO Ventas (id_usuario, fecha, total)
    VALUES (p_id_usuario, CURDATE(), v_total);

    -- obtener el id de la venta recién creada
    SET @id_venta = LAST_INSERT_ID();

    -- insertar detalle
    INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta, p_id_producto, p_cantidad, v_precio);

    -- actualizar stock
    UPDATE Productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;
END//
DELIMITER ;

-- 7.Cancelación de citas
DELIMITER //
CREATE PROCEDURE CancelarCita(IN p_id_cita INT)
BEGIN
    UPDATE Citas
    SET estado = 'cancelada'
    WHERE id_cita = p_id_cita AND estado = 'pendiente';
END//
DELIMITER ;


-- 8.Reprogramación de citas
DELIMITER //
CREATE PROCEDURE ReprogramarCita(
    IN p_id_cita INT,
    IN p_nueva_fecha DATE,
    IN p_nueva_hora TIME
)
BEGIN
    UPDATE Citas
    SET fecha = p_nueva_fecha,
        hora = p_nueva_hora,
        estado = 'pendiente'
    WHERE id_cita = p_id_cita AND estado <> 'completada';
END//
DELIMITER ;
