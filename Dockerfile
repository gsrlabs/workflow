# ---- Стадия сборки ----
FROM golang:1.25 AS builder

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем зависимости
COPY go.mod go.sum ./
RUN go mod download

# Копируем весь проект
COPY . .

# Сборка бинарника
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o post

# ---- Стадия выполнения ----
FROM alpine:3.22

WORKDIR /app

# Копируем бинарник и базу данных 
COPY --from=builder /app/post .
COPY --from=builder /app/tracker.db .

# Запускаем приложение
CMD ["./post"]
