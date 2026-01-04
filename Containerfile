FROM debian:trixie-slim as build

ARG DEBIAN_FRONTEND=noninteractive

#SHELL ["/bin/bash", "-c"]
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

# install dependencies
RUN apt update && apt upgrade -y \
  && apt install -y --no-install-recommends --no-install-suggests ca-certificates git curl libssl-dev zlib1g-dev \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

# install Node.js
ENV NODE_VERSION=24.12.0
ENV HOME="/root"
ENV PATH="$HOME/.nvm/versions/node/v$NODE_VERSION/bin/:$PATH"
RUN git clone --depth 1 https://github.com/nvm-sh/nvm.git ~/.nvm \
  && source $HOME/.nvm/nvm.sh \
  #&& echo "\nexport NVM_DIR=\"$HOME/.nvm\"\n[ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\"\n[ -s \"$NVM_DIR/bash_completion\" ] && \. \"$NVM_DIR/bash_completion\"" >> ~/.bash_rc \
  && nvm --version \
  && nvm install $NODE_VERSION \
  && which node \
  && node --version \
  && npm --version \
  && npm install --global yarn \
  && which yarn \
  && yarn --version \
  && npm update -g npm

WORKDIR /react-app

RUN node -v
RUN npm -v
RUN npx -v

RUN npm init react-app /react-app \
  && npm install --save-dev web-vitals \
  && npm view react version

RUN sed -i "s% return (% const searchParams = new URLSearchParams(window.location.search);\n console.log(searchParams.get('username'))\n\n return (%g" /react-app/src/App.js
RUN sed -i "s%Edit <code>src/App.js</code> and save to reload.%Hello {searchParams.get('username')}!%g" /react-app/src/App.js
RUN sed -i "s%import './App.css';%import React from 'react';\nimport './App.css';%g" /react-app/src/App.js
RUN sed -i "s%Learn React%Learn React!<br />Version: {React.version}%g" /react-app/src/App.js

RUN yarn run build

FROM docker.io/nginx:stable-trixie

EXPOSE 80

COPY --from=build /react-app/build /usr/share/nginx/html
