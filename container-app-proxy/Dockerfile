FROM docker.io/golang:1.25-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/container-app-proxy .

FROM docker.io/alpine:3.22

RUN apk add --no-cache ca-certificates

COPY --from=build /out/container-app-proxy /usr/local/bin/container-app-proxy

ENTRYPOINT ["/usr/local/bin/container-app-proxy"]