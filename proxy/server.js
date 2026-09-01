const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL;
const FLUTTER_URL = process.env.FLUTTER_URL || 'http://localhost:8080';

if (!BACKEND_URL) {
  console.error("=====================================================");
  console.error("ERROR: Debes definir la variable de entorno BACKEND_URL");
  console.error("Ejemplo en Linux/Mac/Codespaces: export BACKEND_URL=https://tu-tunel.ngrok.app");
  console.error("Ejemplo en Windows PowerShell: $env:BACKEND_URL=\"https://tu-tunel.ngrok.app\"");
  console.error("=====================================================");
  process.exit(1);
}

// 1. Redirigir todas las peticiones que empiecen por /api al backend en Java
app.use('/api', createProxyMiddleware({
  target: BACKEND_URL,
  changeOrigin: true, // Requerido para túneles HTTPS como ngrok o Railway
  pathRewrite: {
    '^/Cafeteriatalleres': '', // Express ya retiró '/api'; aquí llega '/Cafeteriatalleres/...' → reenvía como '/Iniciar', '/ReservaUsuario', etc.
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[PROXY API] ${req.method} ${req.originalUrl} -> ${BACKEND_URL}${proxyReq.path}`);
  },
}));

// 2. Redirigir el resto del tráfico (interfaz de usuario) al servidor de desarrollo de Flutter
app.use('/', createProxyMiddleware({
  target: FLUTTER_URL,
  ws: true, // Necesario para que funcione el Hot Reload de Flutter (WebSockets)
  logLevel: 'error',
  onProxyReq: (proxyReq, req, res) => {
    // Solo logueamos las peticiones principales para no saturar la consola
    if (req.url === '/' || req.url.endsWith('.html')) {
      console.log(`[PROXY APP] Cargando Flutter desde ${FLUTTER_URL}`);
    }
  },
}));

app.listen(PORT, () => {
  console.log("=====================================================");
  console.log(`🚀 Proxy de desarrollo listo en: http://localhost:${PORT}`);
  console.log(`📡 Rutas /api redirigidas a:     ${BACKEND_URL}`);
  console.log(`💻 Tráfico web redirigido a:     ${FLUTTER_URL}`);
  console.log("=====================================================");
  console.log("Abre la URL del proxy en tu navegador para usar la app sin errores de CORS.");
});
