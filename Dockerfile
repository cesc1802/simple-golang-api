# Stage 1: Build the application
FROM golang:1.21-alpine AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code
COPY . .

# Build the Go app
# CGO_ENABLED=0 builds a statically-linked binary
# -ldflags="-w -s" reduces the size of the binary by removing debug information
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-w -s" -o /main .

# Stage 2: Create the final, lightweight image
FROM alpine:latest

# Add a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Switch to the non-root user
USER appuser

# Copy the built binary from the builder stage
COPY --from=builder /main /main

# Expose port 3000 to the outside world
EXPOSE 3000

# Command to run the executable
CMD ["/main"]
