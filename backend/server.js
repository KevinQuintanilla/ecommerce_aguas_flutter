require("dotenv").config();
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");
const fs = require("fs");
const multer = require("multer");
const path = require("path");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());

// MODIFICADO: Middleware de JSON condicional para el Webhook
app.use((req, res, next) => {
  if (req.path === "/api/webhooks/stripe") {
    // Usamos raw body solo para el webhook de Stripe
    express.raw({ type: "application/json" })(req, res, next);
  } else {
    // Usamos JSON para todo lo demás
    express.json()(req, res, next);
  }
});

app.use(express.static("public"));

// Configuración de la base de datos
const connection = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "aguadelourdes_master_database_v2025",
  port: process.env.DB_PORT || 3306,
});

// Definimos dónde se guardarán los archivos
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // La carpeta 'public' ya existe en tu proyecto
    // Si el archivo viene en el campo 'imagen', lo guardamos temporalmente en 'uploads'
    cb(null, "public/images/uploads");
  },
  filename: (req, file, cb) => {
    // Crea un nombre de archivo único con la fecha y la extensión original
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

// Conectar a la base de datos
connection.connect((err) => {
  if (err) {
    console.error("Error conectando a la BD:", err);
  } else {
    console.log("Conectado a MySQL - Agua de Lourdes");
  }
});

// ======================================================
// --- RUTAS DE STRIPE (NUEVAS) ---
// ======================================================

// ENDPOINT 2: Crear la sesión de pago de Stripe
app.post("/api/pagos/crear-sesion-stripe", async (req, res) => {
  const { pedido_id } = req.body;

  if (!pedido_id) {
    return res.status(400).json({ error: "Falta pedido_id" });
  }

  try {
    // 1. Obtener los datos del pedido y los artículos de la BD
    const pedidoQuery = `
      SELECT p.total, u.email as customer_email
      FROM pedidos p
      JOIN clientes c ON p.cliente_id = c.cliente_id
      JOIN usuarios u ON c.usuario_id = u.usuario_id
      WHERE p.pedido_id = ?
    `;
    // Usamos .promise() para poder usar async/await
    const [pedidoRows] = await connection
      .promise()
      .query(pedidoQuery, [pedido_id]);

    if (pedidoRows.length === 0) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }
    const pedido = pedidoRows[0];

    const articulosQuery = `
      SELECT ap.cantidad, ap.precio_unitario, pr.nombre
      FROM articulos_pedido ap
      JOIN productos pr ON ap.producto_id = pr.producto_id
      WHERE ap.pedido_id = ?
    `;
    const [articulosRows] = await connection
      .promise()
      .query(articulosQuery, [pedido_id]);

    // 2. Formatear los artículos para Stripe
    const line_items = articulosRows.map((item) => ({
      price_data: {
        currency: "mxn", // Asumo pesos mexicanos
        product_data: {
          name: item.nombre,
        },
        unit_amount: Math.round(item.precio_unitario * 100), // Stripe usa centavos
      },
      quantity: item.cantidad,
    }));

    // 3. (Opcional) Si hay costo de envío, añadirlo como un line_item
    // ... aquí podrías añadir la lógica para el costo de envío si no está incluido ...
    // Nota: El 'total' del pedido ya incluye impuestos. Stripe recalculará el total.

    // 4. Crear la sesión de Checkout en Stripe
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: line_items,
      mode: "payment",
      customer_email: pedido.customer_email,
      // ¡MUY IMPORTANTE! Guardamos nuestro ID del pedido
      client_reference_id: pedido_id.toString(),
      // URLs a las que Stripe redirigirá (cámbialas por tus URLs de producción)
      success_url: 'http://localhost:3000/pago-exitoso.html',
      cancel_url: 'http://localhost:3000/pago-cancelado.html',
    });

    // 5. Devolver la URL de pago a Flutter
    res.json({ url: session.url });
  } catch (error) {
    console.error("Error creando sesión de Stripe:", error);
    res
      .status(500)
      .json({ error: "Error al crear la sesión de pago: " + error.message });
  }
});

// ENDPOINT 3: Webhook de Stripe (La "Verdad Absoluta")
app.post("/api/webhooks/stripe", (req, res) => {
  const sig = req.headers["stripe-signature"];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    // 1. Verificar la firma (asegura que la llamada viene de Stripe)
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    console.log("Error en firma de Webhook:", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // 2. Manejar el evento
  switch (event.type) {
    case "checkout.session.completed":
      const session = event.data.object;

      // ¡Aquí está la magia!
      const pedidoId = session.client_reference_id;
      const stripeTransactionId = session.payment_intent;

      console.log(`Webhook: Pago completado para Pedido ID: ${pedidoId}`);

      // 3. Actualizar nuestra base de datos
      // Marcamos el pedido como 'Confirmado' (ID 2)
      const pedidoQuery =
        "UPDATE pedidos SET estado_pedido_id = 2 WHERE pedido_id = ?";
      connection.query(pedidoQuery, [pedidoId], (err, result) => {
        if (err) {
          console.error(
            `Webhook: Error al actualizar pedido ${pedidoId}:`,
            err
          );
        } else {
          console.log(`Webhook: Pedido ${pedidoId} actualizado a 'Confirmado'`);
        }
      });

      // Actualizamos nuestro registro de pago
      const pagoQuery = `
        UPDATE pagos 
        SET estado = 'completado', id_transaccion = ?, datos_transaccion = ? 
        WHERE pedido_id = ? AND estado = 'pendiente'
      `;
      connection.query(
        pagoQuery,
        [
          stripeTransactionId,
          JSON.stringify(session), // Guardamos toda la respuesta de Stripe
          pedidoId,
        ],
        (err, result) => {
          if (err) {
            console.error(
              `Webhook: Error al actualizar pago ${pedidoId}:`,
              err
            );
          } else {
            console.log(`Webhook: Pago ${pedidoId} actualizado a 'Completado'`);
          }
        }
      );

      break;

    // ... manejar otros eventos si es necesario
    // case 'payment_intent.succeeded':
    //   break;

    default:
      console.log(`Webhook: Evento no manejado: ${event.type}`);
  }

  // 4. Responder a Stripe con un 200 OK
  res.status(200).send();
});

// --- RUTAS DE PEDIDOS (CLIENTE) ---

// MODIFICADO: Ahora crea el pedido como "Pendiente" (estado 6)
app.post("/api/pedidos", (req, res) => {
  const {
    cliente_id,
    direccion_envio_id,
    metodo_pago_id,
    metodo_envio_id,
    items,
    notas,
  } = req.body;

  if (
    !cliente_id ||
    !direccion_envio_id ||
    !metodo_pago_id ||
    !metodo_envio_id ||
    !items ||
    items.length === 0
  ) {
    return res
      .status(400)
      .json({ error: "Datos incompletos para crear el pedido" });
  }

  let subtotal = 0;
  items.forEach((item) => {
    subtotal += item.precio * item.cantidad;
  });

  const impuestos = subtotal * 0.16;
  // OJO: Este total aún no incluye el costo de envío, tu lógica original lo manejaba así.
  // Si necesitas incluir el envío, tendrías que obtener el costo de envío aquí.
  const total = subtotal + impuestos;
  const codigoSeguimiento =
    "PED-" +
    Date.now() +
    "-" +
    Math.random().toString(36).substr(2, 5).toUpperCase();

  connection.beginTransaction((err) => {
    if (err) {
      return res.status(500).json({ error: "Error iniciando transacción" });
    }

    // --- CAMBIO 1: Estado cambiado a 6 (Pendiente de Pago) ---
    const insertPedidoQuery = `
      INSERT INTO pedidos (
        cliente_id, direccion_envio_id, metodo_pago_id, metodo_envio_id, 
        estado_pedido_id, subtotal, impuestos, total, codigo_seguimiento, notas
      ) VALUES (?, ?, ?, ?, 6, ?, ?, ?, ?, ?)
    `;

    connection.query(
      insertPedidoQuery,
      [
        cliente_id,
        direccion_envio_id,
        metodo_pago_id,
        metodo_envio_id,
        subtotal,
        impuestos,
        total,
        codigoSeguimiento,
        notas || "",
      ],
      (err, result) => {
        if (err) {
          connection.rollback();
          return res
            .status(500)
            .json({ error: "Error creando pedido: " + err.message });
        }

        const pedidoId = result.insertId;

        // --- CAMBIO 2: Insertar en 'pagos' y anidar el resto ---
        const insertPagoQuery = `
        INSERT INTO pagos (pedido_id, metodo_pago_id, monto, estado)
        VALUES (?, ?, ?, 'pendiente')
      `;

        // Pasamos el 'total' que calculamos
        connection.query(
          insertPagoQuery,
          [pedidoId, metodo_pago_id, total],
          (errPago, resultPago) => {
            if (errPago) {
              connection.rollback();
              return res
                .status(500)
                .json({
                  error: "Error creando registro de pago: " + errPago.message,
                });
            }

            // --- Código original (ahora anidado) ---
            const insertArticulosQuery = `
          INSERT INTO articulos_pedido (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
          VALUES ?
        `;
            const articulosValues = items.map((item) => [
              pedidoId,
              item.producto_id,
              item.cantidad,
              item.precio,
              item.precio * item.cantidad,
            ]);

            connection.query(
              insertArticulosQuery,
              [articulosValues],
              (err, result) => {
                if (err) {
                  connection.rollback();
                  return res
                    .status(500)
                    .json({
                      error: "Error agregando artículos: " + err.message,
                    });
                }

                connection.commit((err) => {
                  if (err) {
                    connection.rollback();
                    return res
                      .status(500)
                      .json({ error: "Error confirmando pedido" });
                  }

                  // El resto del código que recupera el pedido es idéntico
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
                  connection.query(
                    getPedidoQuery,
                    [pedidoId],
                    (err, pedidoResult) => {
                      if (err) {
                        // Aunque el commit fue exitoso, fallamos al recuperar, pero el pedido se creó
                        return res
                          .status(500)
                          .json({ error: "Error obteniendo pedido" });
                      }
                      const getArticulosQuery = `
                SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
                FROM articulos_pedido ap
                LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
                WHERE ap.pedido_id = ?
              `;
                      connection.query(
                        getArticulosQuery,
                        [pedidoId],
                        (err, articulosResult) => {
                          if (err) {
                            return res
                              .status(500)
                              .json({ error: "Error obteniendo artículos" });
                          }
                          res.json({
                            success: true,
                            pedido: {
                              ...pedidoResult[0],
                              articulos: articulosResult,
                            },
                            message: "Pedido creado exitosamente",
                          });
                        }
                      );
                    }
                  );
                });
              }
            );
            // --- Fin del código original anidado ---
          }
        );
        // --- Fin de CAMBIO 2 ---
      }
    );
  });
});

//
// --- EL RESTO DE TUS RUTAS ORIGINALES VAN AQUÍ ---
// (No las modificamos, así que las pego tal cual)
//

app.get("/api/clientes/:clienteId/pedidos", (req, res) => {
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
      console.error("Error obteniendo pedidos:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    const pedidosConArticulos = results.map((pedido) => {
      return new Promise((resolve, reject) => {
        const articulosQuery = `
          SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
          FROM articulos_pedido ap
          LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
          WHERE ap.pedido_id = ?
        `;
        connection.query(
          articulosQuery,
          [pedido.pedido_id],
          (err, articulos) => {
            if (err) reject(err);
            else resolve({ ...pedido, articulos });
          }
        );
      });
    });
    Promise.all(pedidosConArticulos)
      .then((pedidosCompletos) => {
        res.json(pedidosCompletos);
      })
      .catch((error) => {
        res
          .status(500)
          .json({ error: "Error obteniendo artículos de pedidos" });
      });
  });
});
app.get("/api/metodos-envio", (req, res) => {
  const query = "SELECT * FROM metodos_envio WHERE activo = 1";
  connection.query(query, (err, results) => {
    if (err) {
      console.error("Error obteniendo métodos de envío:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});
app.get("/api/metodos-pago", (req, res) => {
  const query = "SELECT * FROM metodos_pago WHERE activo = 1";
  connection.query(query, (err, results) => {
    if (err) {
      console.error("Error obteniendo métodos de pago:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});

// ======================================================
// --- RUTAS DE ADMIN ---
// ======================================================

// 1. Obtener TODOS los pedidos (para el panel de admin)
app.get("/api/pedidos/todos", (req, res) => {
  const query = `
    SELECT 
      p.*,
      e.nombre as estado_nombre,
      c.nombre as cliente_nombre,
      c.apellido as cliente_apellido,
      d.calle, d.numero_exterior, d.numero_interior, d.colonia, d.ciudad, d.estado, d.codigo_postal, d.pais, d.referencias
    FROM pedidos p
    LEFT JOIN estados_pedido e ON p.estado_pedido_id = e.estado_pedido_id
    LEFT JOIN clientes c ON p.cliente_id = c.cliente_id
    LEFT JOIN direcciones d ON p.direccion_envio_id = d.direccion_id
    ORDER BY p.fecha_pedido DESC
    LIMIT 100
  `;
  connection.query(query, (err, results) => {
    if (err) {
      console.error("Error obteniendo todos los pedidos:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    const pedidosConArticulos = results.map((pedido) => {
      return new Promise((resolve, reject) => {
        const articulosQuery = `
          SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
          FROM articulos_pedido ap
          LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
          WHERE ap.pedido_id = ?
        `;
        connection.query(
          articulosQuery,
          [pedido.pedido_id],
          (err, articulos) => {
            if (err) reject(err);
            else resolve({ ...pedido, articulos }); // Añade los artículos al objeto pedido
          }
        );
      });
    });

    // 3. Esperamos que todas las consultas de artículos terminen
    Promise.all(pedidosConArticulos)
      .then((pedidosCompletos) => {
        res.json(pedidosCompletos); // Enviamos el JSON completo
      })
      .catch((error) => {
        res
          .status(500)
          .json({ error: "Error obteniendo artículos de pedidos" });
      });
  });
});

// 2. Actualizar el estado de un pedido
app.put("/api/pedidos/:id/estado", (req, res) => {
  const { id } = req.params;
  const { estado_id } = req.body;

  if (!estado_id) {
    return res.status(400).json({ error: "Se requiere el estado_id" });
  }

  const query = "UPDATE pedidos SET estado_pedido_id = ? WHERE pedido_id = ?";

  connection.query(query, [estado_id, id], (err, result) => {
    if (err) {
      console.error("Error actualizando estado del pedido:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }
    res.json({ success: true, message: "Estado del pedido actualizado" });
  });
});

// --- RUTA DE CLIENTE ---
app.get("/api/pedidos/:pedidoId", (req, res) => {
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
      return res.status(500).json({ error: "Error obteniendo pedido" });
    }
    if (pedidoResults.length === 0) {
      return res.status(404).json({ error: "Pedido no encontrado" });
    }
    const articulosQuery = `
      SELECT ap.*, pr.nombre as producto_nombre, pr.imagen_url
      FROM articulos_pedido ap
      LEFT JOIN productos pr ON ap.producto_id = pr.producto_id
      WHERE ap.pedido_id = ?
    `;
    connection.query(articulosQuery, [pedidoId], (err, articulosResults) => {
      if (err) {
        return res
          .status(500)
          .json({ error: "Error obteniendo artículos del pedido" });
      }
      res.json({
        ...pedidoResults[0],
        articulos: articulosResults,
      });
    });
  });
});

// --- RUTAS DE AUTENTICACIÓN ---
app.post("/api/auth/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email y contraseña requeridos" });
  }

  const query = `
    SELECT u.*, c.cliente_id, c.nombre, c.apellido, c.telefono 
    FROM usuarios u 
    LEFT JOIN clientes c ON u.usuario_id = c.usuario_id 
    WHERE u.email = ? AND u.activo = 1
  `;

  connection.query(query, [email], (err, results) => {
    if (err) {
      console.error("Error en login:", err);
      return res.status(500).json({ error: "Error en el servidor" });
    }

    if (results.length === 0) {
      return res
        .status(401)
        .json({ error: "Usuario o contraseña incorrectos" });
    }

    const usuario = results[0];

    if (usuario.password_hash === password) {
      res.json({
        success: true,
        usuario: {
          usuario_id: usuario.usuario_id,
          email: usuario.email,
          nombre: usuario.nombre,
          apellido: usuario.apellido,
          telefono: usuario.telefono,
          tipo_usuario: usuario.tipo_usuario,
          cliente_id: usuario.cliente_id,
        },
      });
    } else {
      res.status(401).json({ error: "Contraseña incorrecta" });
    }
  });
});
app.post("/api/auth/register", (req, res) => {
  const { email, password, nombre, apellido, telefono } = req.body;

  if (!email || !password || !nombre || !apellido) {
    return res.status(400).json({ error: "Todos los campos son requeridos" });
  }

  const checkEmailQuery = "SELECT usuario_id FROM usuarios WHERE email = ?";
  connection.query(checkEmailQuery, [email], (err, results) => {
    if (err) {
      return res.status(500).json({ error: "Error en el servidor" });
    }

    if (results.length > 0) {
      return res.status(400).json({ error: "El email ya está registrado" });
    }

    const insertUsuarioQuery = `
      INSERT INTO usuarios (email, password_hash, tipo_usuario, activo) 
      VALUES (?, ?, 'cliente', 1)
    `;

    connection.query(insertUsuarioQuery, [email, password], (err, result) => {
      if (err) {
        return res.status(500).json({ error: "Error creando usuario" });
      }

      const usuarioId = result.insertId;

      const insertClienteQuery = `
        INSERT INTO clientes (usuario_id, nombre, apellido, telefono) 
        VALUES (?, ?, ?, ?)
      `;

      connection.query(
        insertClienteQuery,
        [usuarioId, nombre, apellido, telefono],
        (err, result) => {
          if (err) {
            connection.query("DELETE FROM usuarios WHERE usuario_id = ?", [
              usuarioId,
            ]);
            return res
              .status(500)
              .json({ error: "Error creando perfil de cliente" });
          }

          res.json({
            success: true,
            message: "Usuario registrado exitosamente",
            usuario: {
              usuario_id: usuarioId,
              email: email,
              nombre: nombre,
              apellido: apellido,
              tipo_usuario: "cliente",
              cliente_id: result.insertId,
            },
          });
        }
      );
    });
  });
});

// --- RUTAS DE PRODUCTOS Y CATEGORÍAS ---
app.get("/api", (req, res) => {
  res.json({
    message: "API Agua de Lourdes funcionando!",
    version: "1.0.0",
    database: "MySQL",
  });
});

// Ruta para la página "Tienda" (Catálogo)
app.get("/api/productos", (req, res) => {
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
  query += " LIMIT 50";
  connection.query(query, queryParams, (err, results) => {
    if (err) {
      console.error("Error obteniendo productos:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});

// Ruta para "Productos Destacados" (Home screen)
app.get("/api/productos/destacados", (req, res) => {
  const query = `
    SELECT 
      p.*, 
      c.nombre as categoria_nombre,
      COALESCE(AVG(r.puntuacion), 0) as avg_rating
    FROM productos p
    LEFT JOIN categorias c ON p.categoria_id = c.categoria_id
    LEFT JOIN reseñas r ON p.producto_id = r.producto_id
    WHERE p.activo = 1
    GROUP BY p.producto_id
    ORDER BY avg_rating DESC
    LIMIT 3
  `;
  connection.query(query, (err, results) => {
    if (err) {
      console.error("Error obteniendo productos destacados:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});

// Ruta para "Detalle de Producto"
app.get("/api/productos/:id", (req, res) => {
  const productId = req.params.id;
  const productQuery =
    "SELECT * FROM productos WHERE producto_id = ? AND activo = 1";
  connection.query(productQuery, [productId], (err, productResults) => {
    if (err) {
      console.error("Error obteniendo producto:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    if (productResults.length === 0) {
      return res.status(404).json({ error: "Producto no encontrado" });
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
        console.error("Error obteniendo reseñas:", err);
        return res.status(500).json({ error: "Error obteniendo reseñas" });
      }
      res.json({
        ...producto,
        resenas: reseñasResults, // (usamos "resenas" con 'n' que arreglamos antes)
      });
    });
  });
});

// 3. Añadir un nuevo producto (ADMIN)
app.post("/api/productos/nuevo", upload.single("imagen"), (req, res) => {
  // req.file contiene la información de la imagen subida por Multer (guardada temporalmente)
  const { categoria_id, nombre, descripcion, precio_actual, sku } = req.body;

  // El frontend enviará un campo extra 'tipo_categoria' ('agua' o 'merch')
  const tipoCategoria = req.body.tipo_categoria;

  // Validamos datos básicos
  if (
    !categoria_id ||
    !nombre ||
    !precio_actual ||
    !req.file ||
    !tipoCategoria
  ) {
    // Si hay un error, intentamos eliminar el archivo temporal
    if (req.file) {
      const fs = require("fs");
      fs.unlinkSync(req.file.path);
    }
    return res
      .status(400)
      .json({
        error:
          "Faltan datos requeridos (nombre, precio, categoría, tipo_categoria o imagen)",
      });
  }

  // Determinamos la subcarpeta final
  let subfolder;
  if (tipoCategoria.toLowerCase() === "agua") {
    subfolder = "agua";
  } else if (tipoCategoria.toLowerCase() === "merch") {
    subfolder = "merch";
  } else {
    subfolder = "other";
  }

  const finalImagePath = `public/images/${subfolder}/${req.file.filename}`;
  const publicUrl = `/images/${subfolder}/${req.file.filename}`;

  // Movemos el archivo temporal (de 'uploads') a la carpeta final (agua o merch)
  const fs = require("fs");
  try {
    fs.renameSync(req.file.path, finalImagePath);
  } catch (moveErr) {
    console.error("Error moviendo el archivo:", moveErr);
    return res
      .status(500)
      .json({ error: "Error interno al guardar la imagen." });
  }

  // Insertamos el producto en la BD
  const query = `
        INSERT INTO productos 
        (categoria_id, nombre, descripcion, precio_actual, sku, imagen_url, activo, fecha_creacion, fecha_actualizacion)
        VALUES (?, ?, ?, ?, ?, ?, 1, NOW(), NOW())
    `;

  connection.query(
    query,
    [
      categoria_id,
      nombre,
      descripcion || null,
      precio_actual,
      sku || null,
      publicUrl, // Usamos la URL pública
    ],
    (err, result) => {
      if (err) {
        // Si la BD falla, intentamos eliminar el archivo que ya movimos
        fs.unlinkSync(finalImagePath);
        console.error("Error creando producto en BD:", err);
        return res
          .status(500)
          .json({ error: "Error en la base de datos al crear el producto." });
      }

      // Devolvemos el producto recién creado
      const newProductId = result.insertId;
      res.status(201).json({
        success: true,
        producto_id: newProductId,
        message: "Producto creado exitosamente",
        imagen_url: publicUrl,
      });
    }
  );
});

app.get("/api/categorias", (req, res) => {
  const query = "SELECT * FROM categorias WHERE activa = 1";
  connection.query(query, (err, results) => {
    if (err) {
      console.error("Error obteniendo categorías:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});

// --- RUTAS DE DIRECCIONES ---
app.get("/api/clientes/:clienteId/direcciones", (req, res) => {
  const { clienteId } = req.params;
  const query = "SELECT * FROM direcciones WHERE cliente_id = ?";
  connection.query(query, [clienteId], (err, results) => {
    if (err) {
      console.error("Error obteniendo direcciones:", err);
      return res.status(500).json({ error: "Error en la base de datos" });
    }
    res.json(results);
  });
});
app.post("/api/direcciones", (req, res) => {
  const {
    cliente_id,
    tipo,
    calle,
    numero_exterior,
    numero_interior,
    colonia,
    ciudad,
    estado,
    codigo_postal,
    pais,
    referencias,
  } = req.body;
  if (!cliente_id || !calle || !ciudad || !estado || !codigo_postal) {
    return res.status(400).json({ error: "Datos incompletos" });
  }
  const query = `
    INSERT INTO direcciones (
      cliente_id, tipo, calle, numero_exterior, numero_interior, 
      colonia, ciudad, estado, codigo_postal, pais, referencias
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  connection.query(
    query,
    [
      cliente_id,
      tipo || "envío",
      calle,
      numero_exterior,
      numero_interior,
      colonia,
      ciudad,
      estado,
      codigo_postal,
      pais || "México",
      referencias,
    ],
    (err, result) => {
      if (err) {
        console.error("Error creando dirección:", err);
        return res.status(500).json({ error: "Error al guardar la dirección" });
      }
      const newDireccionId = result.insertId;
      connection.query(
        "SELECT * FROM direcciones WHERE direccion_id = ?",
        [newDireccionId],
        (err, newDireccion) => {
          if (err) {
            return res
              .status(500)
              .json({ error: "Dirección creada, pero no se pudo recuperar" });
          }
          res.status(201).json(newDireccion[0]);
        }
      );
    }
  );
});
app.put("/api/direcciones/:id", (req, res) => {
  const { id } = req.params;
  const {
    calle,
    numero_exterior,
    numero_interior,
    colonia,
    ciudad,
    estado,
    codigo_postal,
    pais,
    referencias,
    tipo,
  } = req.body;
  const query = `
    UPDATE direcciones SET 
      calle = ?, numero_exterior = ?, numero_interior = ?, colonia = ?, 
      ciudad = ?, estado = ?, codigo_postal = ?, pais = ?, referencias = ?, tipo = ?
    WHERE direccion_id = ?
  `;
  connection.query(
    query,
    [
      calle,
      numero_exterior,
      numero_interior,
      colonia,
      ciudad,
      estado,
      codigo_postal,
      pais || "México",
      referencias,
      tipo || "envío",
      id,
    ],
    (err, result) => {
      if (err) {
        console.error("Error actualizando dirección:", err);
        return res
          .status(500)
          .json({ error: "Error al actualizar la dirección" });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Dirección no encontrada" });
      }
      res.json({ success: true, message: "Dirección actualizada" });
    }
  );
});
app.delete("/api/direcciones/:id", (req, res) => {
  const { id } = req.params;
  const query = "DELETE FROM direcciones WHERE direccion_id = ?";
  connection.query(query, [id], (err, result) => {
    if (err) {
      console.error("Error eliminando dirección:", err);
      return res.status(500).json({ error: "Error al eliminar la dirección" });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Dirección no encontrada" });
    }
    res.json({ success: true, message: "Dirección eliminada" });
  });
});

// --- RUTA PARA CREAR RESEÑAS ---
app.post("/api/resenas", (req, res) => {
  const { producto_id, cliente_id, pedido_id, puntuacion, comentario } =
    req.body;

  if (!producto_id || !cliente_id || !pedido_id || !puntuacion) {
    return res.status(400).json({ error: "Datos incompletos para la reseña" });
  }

  const query = `
    INSERT INTO reseñas 
      (producto_id, cliente_id, pedido_id, puntuacion, comentario, aprobado, activo)
    VALUES 
      (?, ?, ?, ?, ?, 1, 1) 
  `;

  connection.query(
    query,
    [producto_id, cliente_id, pedido_id, puntuacion, comentario || ""],
    (err, result) => {
      if (err) {
        console.error("Error al guardar la reseña:", err);
        return res.status(500).json({ error: "Error al guardar la reseña" });
      }
      res
        .status(201)
        .json({ success: true, message: "Reseña guardada exitosamente" });
    }
  );
});

// --- RUTAS DE CONFIGURACIÓN DE PERFIL ---
app.put("/api/clientes/:id", (req, res) => {
  const { id } = req.params;
  const { nombre, apellido, telefono } = req.body;

  if (!nombre || !apellido) {
    return res.status(400).json({ error: "Nombre y apellido son requeridos" });
  }

  const query = `
    UPDATE clientes 
    SET nombre = ?, apellido = ?, telefono = ?
    WHERE cliente_id = ?
  `;

  connection.query(query, [nombre, apellido, telefono, id], (err, result) => {
    if (err) {
      return res.status(500).json({ error: "Error al actualizar el perfil" });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Cliente no encontrado" });
    }

    const getUserQuery = `
      SELECT u.*, c.cliente_id, c.nombre, c.apellido, c.telefono 
      FROM usuarios u 
      LEFT JOIN clientes c ON u.usuario_id = c.usuario_id 
      WHERE c.cliente_id = ?
    `;
    connection.query(getUserQuery, [id], (err, users) => {
      if (err || users.length === 0) {
        return res
          .status(500)
          .json({
            error: "Perfil actualizado, pero no se pudo recuperar el usuario",
          });
      }
      res.json({
        success: true,
        message: "Perfil actualizado exitosamente",
        usuario: users[0],
      });
    });
  });
});
app.put("/api/usuarios/:id/password", (req, res) => {
  const { id } = req.params;
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: "Todos los campos son requeridos" });
  }

  const getPassQuery =
    "SELECT password_hash FROM usuarios WHERE usuario_id = ?";
  connection.query(getPassQuery, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: "Error del servidor" });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: "Usuario no encontrado" });
    }

    const currentSavedPassword = results[0].password_hash;

    if (currentPassword !== currentSavedPassword) {
      return res
        .status(401)
        .json({ error: "La contraseña actual es incorrecta" });
    }

    const updateQuery =
      "UPDATE usuarios SET password_hash = ? WHERE usuario_id = ?";
    connection.query(updateQuery, [newPassword, id], (err, result) => {
      if (err) {
        return res
          .status(500)
          .json({ error: "Error al guardar la nueva contraseña" });
      }
      res.json({
        success: true,
        message: "Contraseña actualizada exitosamente",
      });
    });
  });
});

// --- Iniciar servidor ---
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
  console.log(`Base de datos: ${process.env.DB_NAME}`);
});
