# HAProxy Lua event framework demo

This project demonstrates how to use the events framework in an HAProxy Lua module.

# Setup

To use it with Docker Compose:

1. Install [Docker Desktop](https://docs.docker.com/desktop/).
2. Go to `https://webhook.site/` to get a unique `webhook.site` URL.
3. Edit the file `docker-compose.yml` and change the `DEMO_WEBHOOK_URL` variable to be your `webhook.site` URL.
4. Call the `docker compose up` command to create the container environment:

   ```
   $ docker compose up
   ```

5. On your host machine, install `socat` (or use another tool like Netcat) to  send commands to the HAProxy Runtime API, which listens at port 9999.

   Below, we disable the two web servers, which triggers the `SERVER_DOWN` event in Lua, sending a web request to your `webhook.site` URL.

   ```
   $ echo "set server test/webserver1 health down" | socat stdio tcp4-connect:127.0.0.1:9999

   $ echo "set server test/webserver2 state maint" | socat stdio tcp4-connect:127.0.0.1:9999
   ```

6. Check `webhook.site` to see the request displayed.

7. Stop and clean up the containerized environment with `docker compose down`:

   ```
   $ docker compose down
   ```

