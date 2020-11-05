FROM php:8.0-rc-fpm-alpine

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH

# See http://label-schema.org/rc1/ and https://microbadger.com/labels
LABEL org.label-schema.name="PHP 8.0 RC - FastCGI Process Manager" \
    org.label-schema.description="PHP-FPM 8.0 RC (with some more extentions installed)" \
    org.label-schema.vendor="Cyconet" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE:-unknown}" \
    org.label-schema.version="${BUILD_VERSION:-unknown}" \
    org.label-schema.vcs-url="${VCS_URL:-unknown}" \
    org.label-schema.vcs-ref="${VCS_REF:-unknown}" \
    org.label-schema.vcs-branch="${VCS_BRANCH:-unknown}"

ENV EXT_DEPS \
  freetype \
  libpng \
  libjpeg-turbo \
  libwebp \
  freetype-dev \
  libpng-dev \
  libjpeg-turbo-dev \
  libwebp-dev \
  libzip-dev \
  imagemagick-dev \
  libtool

# hadolint ignore=SC2086,DL3017,DL3018
RUN set -xe; \
  apk --no-cache update && apk --no-cache upgrade \
  && apk add --no-cache ${EXT_DEPS} \
  && apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
  && docker-php-ext-configure bcmath \
  && docker-php-ext-configure exif \
  && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
  && NPROC="$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)" \
  && docker-php-ext-install "-j${NPROC}" bcmath exif gd mysqli \
# not ready yet: https://github.com/Imagick/imagick/issues/271 / https://github.com/FriendsOfPHP/pickle/issues/193
#  && docker-php-ext-install "-j${NPROC}" zip \
#  && curl -L -o /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/latest/download/pickle.phar \
#  && chmod +x /usr/local/bin/pickle \
#  && pickle install imagick \
#  && docker-php-ext-enable imagick \
#  && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
  && docker-php-ext-enable bcmath exif gd mysqli \
  # Cleanup build deps
  && apk del .build-deps \
  && rm -rf /tmp/* /var/cache/apk/*
