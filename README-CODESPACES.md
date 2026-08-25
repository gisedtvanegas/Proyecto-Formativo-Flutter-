# Configuración de Entorno en Codespaces (Proxy CORS hacia Railway)

Para poder ejecutar la aplicación Flutter Web en Codespaces y que se conecte al backend Java alojado en Railway sin errores de CORS, sigue estos pasos:

### 1. Iniciar Flutter Web (en Codespaces)
Abre una terminal en Codespaces y ejecuta:
```bash
flutter run -d web-server --web-port 8080
```

### 2. Iniciar el Proxy (en Codespaces)
Abre **otra** terminal en Codespaces dentro de la carpeta raíz del proyecto, configura la variable de entorno con la URL pública de Railway y arranca el proxy:

```bash
cd proxy

# Configura la URL pública de Railway
export BACKEND_URL="https://casa-jardin-vivero-cafe-production-45e9.up.railway.app"

# (Opcional) Si en el paso 1 usaste un puerto distinto al 8080 para Flutter, configúralo:
# export FLUTTER_URL="http://localhost:PUERTO"

# Instalar dependencias del proxy (solo la primera vez)
npm install

# Arrancar el proxy
npm start
```

### 3. Abrir la Aplicación
Una vez que el proxy esté corriendo (por defecto en el puerto `3000`), abre en tu navegador la URL que te ofrece Codespaces para el puerto **3000** (NO el `8080`).

Toda la aplicación de Flutter cargará desde ese puerto, y las peticiones al backend (que empiezan con `/api/Cafeteriatalleres/...`) serán redirigidas automáticamente a la raíz de Railway (`/Iniciar`, `/ReservaUsuario`), saltándose las protecciones de CORS y conservando correctamente la sesión `JSESSIONID`.
