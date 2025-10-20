FROM alpine:latest

# Environment variables for automatic setup
ENV SMB_USER="smbuser" \
    SMB_PASS="" \
    SMB_GROUP="smb" \
    SMB_STORAGE="/storage"

# Install Samba
RUN apk add --no-cache samba && \
    echo "ICONICNAS" > /etc/samba/machine_id

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy Samba config
COPY smb.conf /etc/samba/smb.conf

EXPOSE 445

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD smbstatus --shares || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["smbd", "--foreground", "--no-process-group", "--debug-stdout", "-d", "1"]
