# Etapa 1: build del frontend con Node.js 18 en Alpine Linux para mantener la imagen ligera
FROM node:18-alpine AS build

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia package.json y package-lock.json primero para aprovechar la caché de Docker
COPY package*.json ./

# Instala las dependencias del proyecto. 'npm ci' asegura compilaciones reproducibles
RUN npm ci

# Copia el resto del código de la aplicación
COPY . .

# La variable NODE_OPTIONS se incluye para compatibilidad con Node.js 17+
ENV NODE_OPTIONS=--openssl-legacy-provider

# Genera los archivos estáticos de producción en el directorio /build
RUN npm run build

# Etapa 2: Servidor Nginx para servir los archivos estáticos generados por React
FROM nginx:alpine

# Copiar archivos generados en /build al root público de Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Reemplazar la configuración de Nginx para que funcione con React Router
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Establece el directorio de trabajo dentro del contenedor
EXPOSE 80

# Comando para iniciar Nginx en primer plano, lo que es necesario para que el contenedor se mantenga activo
CMD ["nginx", "-g", "daemon off;"]
