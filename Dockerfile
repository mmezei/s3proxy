# Multistage - Builder
FROM maven:3.6.3-jdk-11-slim as s3proxy-builder
LABEL maintainer="Andrew Gaul <andrew@gaul.org>"

COPY . /opt/s3proxy/
WORKDIR /opt/s3proxy
RUN  mvn package -DskipTests

# Multistage - Image
FROM openjdk:11-jre-slim
LABEL maintainer="Andrew Gaul <andrew@gaul.org>"

WORKDIR /opt/s3proxy

COPY \
    --from=s3proxy-builder \
    /opt/s3proxy/target/s3proxy \
    /opt/s3proxy/src/main/resources/run-docker-container.sh \
    /opt/s3proxy/

ENV \
    LOG_LEVEL="info" \
    S3PROXY_AUTHORIZATION="aws-v2-or-v4" \
    S3PROXY_ENDPOINT="http://0.0.0.0:80" \
    S3PROXY_IDENTITY="local-identity" \
    S3PROXY_CREDENTIAL="local-credential" \
    S3PROXY_VIRTUALHOST="" \
    S3PROXY_CORS_ALLOW_ALL="true" \
    S3PROXY_CORS_ALLOW_ORIGINS="*" \
    S3PROXY_CORS_ALLOW_METHODS="*" \
    S3PROXY_CORS_ALLOW_HEADERS="*" \
    S3PROXY_IGNORE_UNKNOWN_HEADERS="false" \
    S3PROXY_MAXIMUM_TIMESKEW="" \
    # SPROXY_MAX_SINGLE_PART_OBJECT_SIZE is the maximum content length allowed...
    S3PROXY_MAX_SINGLE_PART_OBJECT_SIZE="" \
    # SPROXY_V4_MAX_NON_CHUNKED_REQUEST_SIZE is used as the maximum part size of multipart messages for v4...
    S3PROXY_V4_MAX_NON_CHUNKED_REQUEST_SIZE="" \
    S3PROXY_OVERLAY_BLOBSTORE="false" \
    S3PROXY_OVERLAY_BLOBSTORE_MASK_SUFFIX="__deleted" \
    S3PROXY_OVERLAY_BLOBSTORE_PATH="/tmp" \
    JCLOUDS_PROVIDER="filesystem" \
    JCLOUDS_ENDPOINT="" \
    JCLOUDS_REGION="" \
    JCLOUDS_REGIONS="us-east-1" \
    JCLOUDS_IDENTITY="remote-identity" \
    JCLOUDS_CREDENTIAL="remote-credential" \
    JCLOUDS_KEYSTONE_VERSION="" \
    JCLOUDS_KEYSTONE_SCOPE="" \
    JCLOUDS_KEYSTONE_PROJECT_DOMAIN_NAME="" \
    JCLOUDS_FILESYSTEM_BASEDIR="/data"

EXPOSE 80
ENTRYPOINT ["/opt/s3proxy/run-docker-container.sh"]
