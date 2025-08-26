FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Копируем файлы зависимостей
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Копируем весь код
COPY . .

# Аргумент для API URL
ARG API_URL

# Собираем web приложение
RUN BUILD_VERSION=$(date +%Y%m%d-%H%M) && \
    flutter build web ${API_URL:+"--dart-define=API_URL=$API_URL"} && \
    sed -i "s/{{flutter_service_worker_version}}/$BUILD_VERSION/" /app/build/web/index.html && \
    sed -i "s/main.dart.js/main.dart.js?v=$BUILD_VERSION/" /app/build/web/index.html && \
    echo "<script>window.buildVersion = '$BUILD_VERSION';</script>" >> /app/build/web/index.html

# Production образ
FROM nginx:alpine

ARG PORT=80
EXPOSE $PORT

# Настройка nginx для non-root пользователя
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx/ /etc/nginx/conf.d /usr/share/nginx/html /var/run/nginx.pid /var/log/nginx && \
    sed -i "s/listen  .*/listen $PORT;/g" /etc/nginx/conf.d/default.conf

# Копируем собранное приложение
COPY --from=build --chown=nginx:nginx /app/build/web/ /usr/share/nginx/html/

USER nginx

CMD ["nginx", "-g", "daemon off;"]
