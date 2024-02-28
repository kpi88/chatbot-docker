###
#
# Chatbot-UI Dockerfile
#
###

# Build stage
# From docker.io/debian:sid-slim AS builder

# Runtime stage
FROM docker.io/node:21.5.0-bookworm
LABEL app.name="chatbot-ui"
ARG BUILD_DATE
ARG COMMIT
ARG VERSION=main
ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG SUPABASE_SERVICE_ROLE_KEY

WORKDIR /usr/src

RUN git clone --branch="${VERSION}" --depth=1 https://github.com/mckaywrigley/chatbot-ui "${PWD}" && \
    mkdir /app && \
    cp package*.json /app

WORKDIR /app

# set up .env.local - strip examples and re-add with newline
RUN sed '1,7d' /usr/src/.env.local.example > ./.env.local && \
    echo -e "\nNEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}" >> .env.local && \
    echo "NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}" >> .env.local && \
    echo "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}" >> .env.local

RUN npm cache clean -f
RUN npm install
RUN cp -r /usr/src/* /app
RUN npm run build

ENV NODE_ENV production

EXPOSE 3000
CMD ["npm", "run", "start"]
