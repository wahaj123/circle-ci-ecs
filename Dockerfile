FROM nginx:latest
ARG BUILD
RUN  echo "BUILD NUMBER IS $BUILD" > /usr/share/nginx/html/index.html