FROM python:3-alpine3.11
LABEL maintainer="pradeepkumartammali@gmail.com"
WORKDIR /cloud-console-server
COPY src .
RUN apk update \
    && apk add --no-cache python3-dev libffi-dev gcc musl-dev make \
    && pip3 install --upgrade pip \
    && pip install -r requirements.txt \
    && chmod -R 755 . \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EXPOSE 5000
USER daemon
ENTRYPOINT ["python"]
CMD ["app.py"]
