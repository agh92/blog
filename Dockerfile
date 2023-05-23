
FROM node:latest AS ui-build
WORKDIR /usr/src/app
COPY ./blog/ ./blog/
RUN cd blog && npm install @angular/cli && npm install && npm run build

FROM node:latest AS server-build
WORKDIR /root/
COPY --from=ui-build /usr/src/app/blog/dist/blog/ ./blog/dist
COPY ./server/package*.json ./
RUN npm install
COPY ./server/index.js .

EXPOSE 3080

CMD ["node", "index.js"]