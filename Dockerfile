# 1. Dùng máy tính có cài sẵn Java 17 và Maven
FROM maven:3.8.5-openjdk-17

# 2. Tạo thư mục làm việc trong máy đó
WORKDIR /app

# 3. Copy toàn bộ code của bạn vào máy đó
COPY . .

# 4. Mở cổng 8080
EXPOSE 8080

# 5. Lệnh chạy web (Y hệt lệnh bạn hay gõ)
CMD ["mvn", "clean", "compile", "jetty:run"]