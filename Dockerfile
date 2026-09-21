# App image built by the pipeline's "Build & Push Image" stage.
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
