# Start with the pgAdmin's image supported on their website.
FROM dpage/pgadmin4 as build

# Get rid of postfix, which should never have been included.
RUN \
	apk del postfix && \
	rm -r /var/cache/apk/* && \
	sed -ie '/[Pp]ostfix/d' /entrypoint.sh

# Remove all the superfluous versions of the Postgres tools.
RUN \
	for i in 9 10 11; do \
		rm -rf /usr/local/pgsql-"$i"*; \
	done

# Remove static libraries that are worthless in a container.
RUN \
	find /usr/local -iname "*.a" -exec rm {} ';'

# Squash our changes otherwise we get no space savings.
FROM scratch
COPY --from=build / /

# Expose the http port.
EXPOSE 80

# Export the pgadmin volume.
VOLUME /var/lib/pgadmin

# Point to the original entrypoint.
ENTRYPOINT ["/entrypoint.sh"]

# Check every once in a while to see if the server is still running.
HEALTHCHECK --interval=30m \
  CMD wget --spider http://localhost/
