FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build argument for backend WebSocket URL
ARG VITE_BACKEND_WS_URL=ws://localhost:3001
ENV VITE_BACKEND_WS_URL=$VITE_BACKEND_WS_URL

RUN npm run build

# Production stage with nginx
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
