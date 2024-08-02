
mvn clean install
podman login ghcr.io -u rithik-sandron -p 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
podman build -t hello .
podman tag hello ghcr.io/rithik-sandron/hello:latest
podman push ghcr.io/rithik-sandron/hello:latest
podman pull ghcr.io/rithik-sandron/hello:latest
#   To Run
#   podman run -p 8080:8080 ghcr.io/rithik-sandron/hello:latest
