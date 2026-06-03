FROM node:18-alpine

# Set working directory di dalam container
WORKDIR /usr/src/app

# Copy package.json dan package-lock.json terlebih dahulu untuk memanfaatkan cache docker
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy seluruh source code
COPY . .

# Expose port yang digunakan
EXPOSE 3000

# Perintah untuk menjalankan aplikasi
CMD ["npm", "start"]
