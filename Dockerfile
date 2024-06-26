FROM node:18.18-alpine as node

WORKDIR /usr/app

COPY . .

RUN npm install

CMD npx prisma generate \
    && npx prisma migrate deploy \
    && npm run build \
    && npm run start:prod

