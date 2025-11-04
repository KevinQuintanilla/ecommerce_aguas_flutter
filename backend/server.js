const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
// const bcrypt = require('bcryptjs'); // <-- ELIMINADO
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Configuración de la base de datos
const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'aguadelourdes_master_database_v2025',
  port: process.env.DB_PORT || 3306
});

// Conectar a la base de datos
connection.connect((err) => {
  if (err) {
    console.error('Error conectando a la BD:', err);
  } else {
    console.log('Conectado a MySQL - Agua de Lourdes');
  }
});

// --- RUTAS DE PEDIDOS ---
// (Todas tus rutas de Pedidos, Productos, Direcciones, etc. quedan igual)
// ...
// Ruta para crear un pedido
app.post('/api/pedidos', (req, res) => {
  const { cliente_id, direccion_envio_id, metodo_pago_id, metodo_envio_id, items, notas } = req.body;
  if (!cliente_id || !direccion_envio_id || !metodo_pago_id || !metodo_envio_id || !items || items.length === 0) {
    return res.status(400).json({ error: 'Datos incompletos para crear el pedido' });
  }
  let subtotal = 0;
  items.forEach(item => {
    subtotal += item.precio * item.cantidad;
  });
  const impuestos = subtotal * 0.16;
  const total = subtotal + impuestos;
  const codigoSeguimiento = 'PED-' + Date.now() + '-' + Math.random().toString(36).substr(2, 5).toUpperCase();
  connection.beginTransaction((err) => {
    if (err) {
      return res.status(500).json({ error: 'Error iniciando transacción' });
    }
    const insertPedidoQuery = `
      INSERT INTO pedidos (
        cliente_id, direccion_envio_id, metodo_pago_id, metodo_envio_id, 
        estado_pedido_id, subtotal, impuestos, total, codigo_seguimiento, notas
      ) VALUES (?, ?, ?, ?, 1, ?, ?, ?, ?, ?)
    `;
    connection.query(insertPedidoQuery, [
      cliente_id, direccion_envio_id, metodo_pago_id, metodo_envio_id,
      subtotal, impuestos, total, codigoSeguimiento, notas || ''
    ], (err, result) => {
      if (err) {
        connection.rollback();
        return res.status(500).json({ error: 'Error creando pedido: ' + err.message });
      }
      const pedidoId = result.insertId;
      const insertArticulosQuery = `
        INSERT INTO articulos_pedido (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
        VALUES ?
      `;
      const articulosValues = items.map(item => [
        pedidoId, item.producto_id, item.cantidad, item.precio, item.precio * item.cantidad
      ]);
      connection.query(insertArticulosQuery, [articulosValues], (err, result) => {
        if (err) {
          connection.rollback();
          return res.status(500).json({ error: 'Error agregando artículos: ' + err.message });
        }
        connection.commit((err) => {
          if (err) {
            connection.rollback();
            return res.status(500).json({ error: 'Error confirmando pedido' });
          }
          const getPedidoQuery = `
            SELECT p.*, 
              e.nombre as estado_nombre,
              mp.nombre as metodo_pago_nombre,
              me.nombre as metodo_envio_nombre,
              me.costo as costo_envio
            FROM pedidos p
            LEFT JOIN estados_pedido e ON p.estado_pedido_id = e.estado_pedido_id
            LEFT JOIN metodos_pago mp ON p.metodo_pago_id = mp.metodo_pago_id
            LEFT JOIN metodos_envio me ON p.metodo_envio_id = me.metodo_envio_id
            WHERE p.pedido_id = ?
          `;
          connection.query(getPedidoQuery, [pedidoId], (err, pedidoResult) => {
            if (err) {
              return res.status(500).json({ error: 'Error obteniendo pedido' });
            }
            const getArticulosQuery = `
              SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
              FROM articulos_pedido ap
              LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
              WHERE ap.pedido_id = ?
            `;
            connection.query(getArticulosQuery, [pedidoId], (err, articulosResult) => {
              if (err) {
                return res.status(500).json({ error: 'Error obteniendo artículos' });
              }
              res.json({
                success: true,
                pedido: {
                  ...pedidoResult[0],
                  articulos: articulosResult
                },
                message: 'Pedido creado exitosamente'
              });
            });
          });
        });
      });
    });
  });
});
app.get('/api/clientes/:clienteId/pedidos', (req, res) => {
  const clienteId = req.params.clienteId;
  const query = `
    SELECT 
      p.*,
      e.nombre as estado_nombre,
      mp.nombre as metodo_pago_nombre,
      me.nombre as metodo_envio_nombre
    FROM pedidos p
    LEFT JOIN estados_pedido e ON p.estado_pedido_id = e.estado_pedido_id
    LEFT JOIN metodos_pago mp ON p.metodo_pago_id = mp.metodo_pago_id
    LEFT JOIN metodos_envio me ON p.metodo_envio_id = me.metodo_envio_id
    WHERE p.cliente_id = ?
    ORDER BY p.fecha_pedido DESC
  `;
  connection.query(query, [clienteId], (err, results) => {
    if (err) {
      console.error('Error obteniendo pedidos:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    const pedidosConArticulos = results.map(pedido => {
      return new Promise((resolve, reject) => {
        const articulosQuery = `
          SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
          FROM articulos_pedido ap
          LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
          WHERE ap.pedido_id = ?
        `;
        connection.query(articulosQuery, [pedido.pedido_id], (err, articulos) => {
          if (err) reject(err);
          else resolve({ ...pedido, articulos });
        });
      });
    });
    Promise.all(pedidosConArticulos)
      .then(pedidosCompletos => {
        res.json(pedidosCompletos);
      })
      .catch(error => {
        res.status(500).json({ error: 'Error obteniendo artículos de pedidos' });
      });
  });
});
app.get('/api/pedidos/:pedidoId', (req, res) => {
  const pedidoId = req.params.pedidoId;
  const pedidoQuery = `
    SELECT 
      p.*,
      e.nombre as estado_nombre,
      mp.nombre as metodo_pago_nombre,
      me.nombre as metodo_envio_nombre,
      d.calle, d.numero_exterior, d.numero_interior, d.colonia, d.ciudad, d.estado, d.codigo_postal
    FROM pedidos p
    LEFT JOIN estados_pedido e ON p.estado_pedido_id = e.estado_pedido_id
    LEFT JOIN metodos_pago mp ON p.metodo_pago_id = mp.metodo_pago_id
    LEFT JOIN metodos_envio me ON p.metodo_envio_id = me.metodo_envio_id
    LEFT JOIN direcciones d ON p.direccion_envio_id = d.direccion_id
    WHERE p.pedido_id = ?
  `;
  connection.query(pedidoQuery, [pedidoId], (err, pedidoResults) => {
    if (err) {
      return res.status(500).json({ error: 'Error obteniendo pedido' });
    }
    if (pedidoResults.length === 0) {
      return res.status(404).json({ error: 'Pedido no encontrado' });
    }
    const articulosQuery = `
      SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
      FROM articulos_pedido ap
      LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
      WHERE ap.pedido_id = ?
    `;
    connection.query(articulosQuery, [pedidoId], (err, articulosResults) => {
      if (err) {
        return res.status(500).json({ error: 'Error obteniendo artículos del pedido' });
      }
      res.json({
        ...pedidoResults[0],
        articulos: articulosResults
      });
    });
  });
});
app.get('/api/metodos-envio', (req, res) => {
  const query = 'SELECT * FROM metodos_envio WHERE activo = 1';
  connection.query(query, (err, results) => {
    if (err) {
      console.error('Error obteniendo métodos de envío:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    res.json(results);
  });
});
app.get('/api/metodos-pago', (req, res) => {
  const query = 'SELECT * FROM metodos_pago WHERE activo = 1';
  connection.query(query, (err, results) => {
    if (err) {
      console.error('Error obteniendo métodos de pago:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    res.json(results);
  });
});
// ...

// --- RUTAS DE AUTENTICACIÓN (REVERTIDAS A TEXTO PLANO) ---

// Ruta para login de usuarios (SIN HASH)
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email y contraseña requeridos' });
  }

  // Obtenemos el teléfono también
  const query = `
    SELECT u.*, c.cliente_id, c.nombre, c.apellido, c.telefono 
    FROM usuarios u 
    LEFT JOIN clientes c ON u.usuario_id = c.usuario_id 
    WHERE u.email = ? AND u.activo = 1
  `;
  
  connection.query(query, [email], (err, results) => {
    if (err) {
      console.error('Error en login:', err);
      return res.status(500).json({ error: 'Error en el servidor' });
    }
    
    if (results.length === 0) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    const usuario = results[0];
    
    // --- REVERSIÓN ---
    // Volvemos a la comparación simple
    if (usuario.password_hash === password) {
      res.json({
        success: true,
        usuario: {
          usuario_id: usuario.usuario_id,
          email: usuario.email,
          nombre: usuario.nombre,
          apellido: usuario.apellido,
          telefono: usuario.telefono, // <-- (Incluido para tu fix de 'usuario.dart')
          tipo_usuario: usuario.tipo_usuario,
          cliente_id: usuario.cliente_id
        }
      });
    } else {
      res.status(401).json({ error: 'Contraseña incorrecta' });
    }
  });
});

// Ruta para registro de usuarios (SIN HASH)
app.post('/api/auth/register', (req, res) => { // <-- Se quita 'async'
  const { email, password, nombre, apellido, telefono } = req.body;

  // Validaciones básicas
  if (!email || !password || !nombre || !apellido) {
    return res.status(400).json({ error: 'Todos los campos son requeridos' });
  }

  // --- REVERSIÓN ---
  // Se quita el try/catch y el hasheo
  // -------------------

  // Verificar si el email ya existe
  const checkEmailQuery = 'SELECT usuario_id FROM usuarios WHERE email = ?';
  connection.query(checkEmailQuery, [email], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error en el servidor' });
    }
    
    if (results.length > 0) {
      return res.status(400).json({ error: 'El email ya está registrado' });
    }

    // Insertar nuevo usuario
    const insertUsuarioQuery = `
      INSERT INTO usuarios (email, password_hash, tipo_usuario, activo) 
      VALUES (?, ?, 'cliente', 1)
    `;
    
    // --- REVERSIÓN ---
    // Se vuelve a pasar 'password' directamente
    connection.query(insertUsuarioQuery, [email, password], (err, result) => {
      if (err) {
        return res.status(500).json({ error: 'Error creando usuario' });
      }

      const usuarioId = result.insertId;

      // Insertar cliente
      const insertClienteQuery = `
        INSERT INTO clientes (usuario_id, nombre, apellido, telefono) 
        VALUES (?, ?, ?, ?)
      `;
      
      connection.query(insertClienteQuery, [usuarioId, nombre, apellido, telefono], (err, result) => {
        if (err) {
          // Si falla, eliminar el usuario creado
          connection.query('DELETE FROM usuarios WHERE usuario_id = ?', [usuarioId]);
          return res.status(500).json({ error: 'Error creando perfil de cliente' });
        }

        res.json({
          success: true,
          message: 'Usuario registrado exitosamente',
          usuario: {
            usuario_id: usuarioId,
            email: email,
            nombre: nombre,
            apellido: apellido,
            tipo_usuario: 'cliente',
            cliente_id: result.insertId
          }
        });
      });
    });
  });
});

// --- RUTAS DE PRODUCTOS Y CATEGORÍAS ---
// (Estas rutas están perfectas, no se tocan)
app.get('/api', (req, res) => {
  res.json({ 
    message: 'API Agua de Lourdes funcionando!',
    version: '1.0.0',
    database: 'MySQL'
  });
});
app.get('/api/productos', (req, res) => {
  const { categoria_id } = req.query;
  let query = `
    SELECT p.*, c.nombre as categoria_nombre 
    FROM productos p 
    LEFT JOIN categorias c ON p.categoria_id = c.categoria_id 
    WHERE p.activo = 1
  `;
  const queryParams = [];
  if (categoria_id) {
    query += `
      AND p.categoria_id IN (
        SELECT c1.categoria_id FROM categorias c1 WHERE c1.categoria_id = ?
        UNION
        SELECT c2.categoria_id FROM categorias c2 WHERE c2.categoria_padre_id = ?
        UNION
        SELECT c3.categoria_id FROM categorias c3 
          INNER JOIN categorias c2 ON c3.categoria_padre_id = c2.categoria_id 
          WHERE c2.categoria_padre_id = ?
      )
    `;
    queryParams.push(categoria_id, categoria_id, categoria_id);
  }
  query += ' LIMIT 50';
  connection.query(query, queryParams, (err, results) => {
    if (err) {
      console.error('Error obteniendo productos:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    res.json(results);
  });
});
app.get('/api/productos/:id', (req, res) => {
  const productId = req.params.id;
  const productQuery = 'SELECT * FROM productos WHERE producto_id = ? AND activo = 1';
  connection.query(productQuery, [productId], (err, productResults) => {
    if (err) {
      console.error('Error obteniendo producto:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    if (productResults.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }
    const producto = productResults[0];
    const reseñasQuery = `
      SELECT r.*, c.nombre as cliente_nombre 
      FROM reseñas r
      JOIN clientes c ON r.cliente_id = c.cliente_id
      WHERE r.producto_id = ? AND r.aprobado = 1 AND r.activo = 1
      ORDER BY r.fecha_reseña DESC
    `;
    connection.query(reseñasQuery, [productId], (err, reseñasResults) => {
      if (err) {
        console.error('Error obteniendo reseñas:', err);
        return res.status(500).json({ error: 'Error obteniendo reseñas' });
      }
      res.json({
        ...producto,
        resenas: reseñasResults
      });
    });
  });
});
app.get('/api/categorias', (req, res) => {
  const query = 'SELECT * FROM categorias WHERE activa = 1';
  connection.query(query, (err, results) => {
    if (err) {
      console.error('Error obteniendo categorías:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    res.json(results);
  });
});

// --- RUTAS DE DIRECCIONES ---
app.get('/api/clientes/:clienteId/direcciones', (req, res) => {
  const { clienteId } = req.params;
  const query = 'SELECT * FROM direcciones WHERE cliente_id = ?';
  connection.query(query, [clienteId], (err, results) => {
    if (err) {
      console.error('Error obteniendo direcciones:', err);
      return res.status(500).json({ error: 'Error en la base de datos' });
    }
    res.json(results);
  });
});
app.post('/api/direcciones', (req, res) => {
  const { 
    cliente_id, tipo, calle, numero_exterior, numero_interior, 
    colonia, ciudad, estado, codigo_postal, pais, referencias 
  } = req.body;
  if (!cliente_id || !calle || !ciudad || !estado || !codigo_postal) {
    return res.status(400).json({ error: 'Datos incompletos' });
  }
  const query = `
    INSERT INTO direcciones (
      cliente_id, tipo, calle, numero_exterior, numero_interior, 
      colonia, ciudad, estado, codigo_postal, pais, referencias
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  connection.query(query, [
    cliente_id, tipo || 'envío', calle, numero_exterior, numero_interior, 
    colonia, ciudad, estado, codigo_postal, pais || 'México', referencias
  ], (err, result) => {
    if (err) {
      console.error('Error creando dirección:', err);
      return res.status(500).json({ error: 'Error al guardar la dirección' });
    }
    const newDireccionId = result.insertId;
    connection.query('SELECT * FROM direcciones WHERE direccion_id = ?', [newDireccionId], (err, newDireccion) => {
      if (err) {
        return res.status(500).json({ error: 'Dirección creada, pero no se pudo recuperar' });
      }
      res.status(201).json(newDireccion[0]);
    });
  });
});
app.put('/api/direcciones/:id', (req, res) => {
  const { id } = req.params;
  const { 
    calle, numero_exterior, numero_interior, 
    colonia, ciudad, estado, codigo_postal, pais, referencias, tipo
  } = req.body;
  const query = `
    UPDATE direcciones SET 
      calle = ?, numero_exterior = ?, numero_interior = ?, colonia = ?, 
      ciudad = ?, estado = ?, codigo_postal = ?, pais = ?, referencias = ?, tipo = ?
    WHERE direccion_id = ?
  `;
  connection.query(query, [
    calle, numero_exterior, numero_interior, colonia, 
    ciudad, estado, codigo_postal, pais || 'México', referencias, tipo || 'envío',
    id
  ], (err, result) => {
    if (err) {
      console.error('Error actualizando dirección:', err);
      return res.status(500).json({ error: 'Error al actualizar la dirección' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Dirección no encontrada' });
    }
    res.json({ success: true, message: 'Dirección actualizada' });
  });
});
app.delete('/api/direcciones/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM direcciones WHERE direccion_id = ?';
  connection.query(query, [id], (err, result) => {
    if (err) {
      console.error('Error eliminando dirección:', err);
      return res.status(500).json({ error: 'Error al eliminar la dirección' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Dirección no encontrada' });
    }
    res.json({ success: true, message: 'Dirección eliminada' });
  });
});

// --- RUTA PARA CREAR RESEÑAS ---
app.post('/api/resenas', (req, res) => {
  const { 
    producto_id, 
    cliente_id, 
    pedido_id, 
    puntuacion, 
    comentario 
  } = req.body;

  // Validación simple
  if (!producto_id || !cliente_id || !pedido_id || !puntuacion) {
    return res.status(400).json({ error: 'Datos incompletos para la reseña' });
  }

  // (Opcional: podrías añadir una lógica para evitar reseñas duplicadas)
  
  const query = `
    INSERT INTO reseñas 
      (producto_id, cliente_id, pedido_id, puntuacion, comentario, aprobado, activo)
    VALUES 
      (?, ?, ?, ?, ?, 1, 1) 
    -- (La ponemos como 'aprobado = 1' automáticamente por simplicidad)
  `;
  
  connection.query(query, 
    [producto_id, cliente_id, pedido_id, puntuacion, comentario || ''], 
    (err, result) => {
      if (err) {
        console.error('Error al guardar la reseña:', err);
        return res.status(500).json({ error: 'Error al guardar la reseña' });
      }
      res.status(201).json({ success: true, message: 'Reseña guardada exitosamente' });
    }
  );
});

// --- RUTAS DE CONFIGURACIÓN DE PERFIL ---

// 1. Actualizar datos personales (Nombre, Apellido, Teléfono)
app.put('/api/clientes/:id', (req, res) => {
  const { id } = req.params;
  const { nombre, apellido, telefono } = req.body;

  if (!nombre || !apellido) {
    return res.status(400).json({ error: 'Nombre y apellido son requeridos' });
  }

  const query = `
    UPDATE clientes 
    SET nombre = ?, apellido = ?, telefono = ?
    WHERE cliente_id = ?
  `;
  
  connection.query(query, [nombre, apellido, telefono, id], (err, result) => {
    if (err) {
      return res.status(500).json({ error: 'Error al actualizar el perfil' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Cliente no encontrado' });
    }
    
    // Devolvemos los datos actualizados del usuario/cliente
    const getUserQuery = `
      SELECT u.*, c.cliente_id, c.nombre, c.apellido, c.telefono 
      FROM usuarios u 
      LEFT JOIN clientes c ON u.usuario_id = c.usuario_id 
      WHERE c.cliente_id = ?
    `;
    connection.query(getUserQuery, [id], (err, users) => {
      if (err || users.length === 0) {
        return res.status(500).json({ error: 'Perfil actualizado, pero no se pudo recuperar el usuario' });
      }
      // Devolvemos el mismo objeto de usuario que en el login
      res.json({
        success: true,
        message: 'Perfil actualizado exitosamente',
        usuario: users[0] 
      });
    });
  });
});

// 2. Cambiar la contraseña 
app.put('/api/usuarios/:id/password', (req, res) => { 
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: 'Todos los campos son requeridos' });
  }

  //  Obtener la contraseña actual del usuario
  const getPassQuery = 'SELECT password_hash FROM usuarios WHERE usuario_id = ?';
  connection.query(getPassQuery, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Error del servidor' });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const currentSavedPassword = results[0].password_hash;

    // Verificar si la contraseña actual es correcta
    if (currentPassword !== currentSavedPassword) {
      // Si la comparación falla, enviamos el error
      return res.status(401).json({ error: 'La contraseña actual es incorrecta' });
    }

    // Actualizar la contraseña en la BD 
    const updateQuery = 'UPDATE usuarios SET password_hash = ? WHERE usuario_id = ?';
    connection.query(updateQuery, [newPassword, id], (err, result) => {
      if (err) {
        return res.status(500).json({ error: 'Error al guardar la nueva contraseña' });
      }
      res.json({ success: true, message: 'Contraseña actualizada exitosamente' });
    });
  });
});


// --- Iniciar servidor ---
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
  console.log(`Base de datos: ${process.env.DB_NAME}`);
});