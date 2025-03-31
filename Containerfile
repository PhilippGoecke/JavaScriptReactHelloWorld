FROM docker.io/node:lts-bookworm-slim as build

WORKDIR /react-app

RUN node -v
RUN npm -v
RUN npx -v

RUN npm init react-app /react-app \
  && npm install --save-dev web-vitals \
  && npm view react version

RUN sed -i "s%  return (%  const searchParams = new URLSearchParams(window.location.search);\n  console.log(searchParams.get('username'))\n\n  return (%g" /react-app/src/App.js
RUN sed -i "s%Edit <code>src/App.js</code> and save to reload.%Hello {searchParams.get('username')}!%g" /react-app/src/App.js
RUN sed -i "s%import './App.css';%import React from 'react';\nimport './App.css';%g" /react-app/src/App.js
RUN sed -i "s%Learn React%Learn React!<br />Version: {React.version}%g" /react-app/src/App.js

RUN yarn run build

FROM docker.io/nginx:stable-bookworm

EXPOSE 80

COPY --from=build /react-app/build /usr/share/nginx/html
