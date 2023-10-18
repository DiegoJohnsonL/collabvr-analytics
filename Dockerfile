FROM node:18 as build

WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
COPY prisma ./prisma/

RUN npm install

COPY . .

RUN npx prisma generate
RUN npm run build

FROM node:18-slim

RUN apt update && apt install libssl-dev dumb-init -y --no-install-recommends

WORKDIR /usr/src/app

COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/.env .env
COPY --chown=node:node --from=build /usr/src/app/package.json .
COPY --chown=node:node --from=build /usr/src/app/package-lock.json .
COPY --chown=node:node --from=build /usr/src/app/prisma ./prisma

RUN npm install --omit=dev

COPY --chown=node:node --from=build /usr/src/app/node_modules/.prisma/client  ./node_modules/.prisma/client

ENV NODE_ENV production
EXPOSE 3300 

CMD ["npm", "run", "start:migrate:prod"]