FROM ubuntu:24.04

RUN apt-get update && apt-get install -y wget tar

WORKDIR /app

# Download & extract coreminer
RUN mkdir -p /app/miner && \
    cd /app/miner && \
    wget -q https://github.com/catchthatrabbit/coreminer/releases/download/v0.19.89/coreminer-linux-x86_64.tar.gz -O miner.tar.gz && \
    tar xzf miner.tar.gz && \
    rm miner.tar.gz && \
    find . -name "coreminer" -type f -exec chmod +x {} \;

# Bikin run script: loop 1 jam mining, 2 menit idle
RUN cat > /run-miner.sh << 'SCRIPT'
#!/bin/bash
BIN=$(find /app/miner -name "coreminer" -type f | head -1)
POOL="stratum1+tcp://cb192fddfc1c24f6b7a27df5ceb903c03479bafde9d5.jasjus1@us.catchthatrabbit.com:8008"
C=0
echo "[*] coreminer ready — 10 threads — 60m ON / 2m OFF"
while true; do
    C=$((C+1))
    echo "[Cycle $C] ▶ MINING 60m | $(date '+%H:%M:%S')"
    $BIN --noeval --hard-aes -P "$POOL" -t 10 &
    MPID=$!
    sleep 3600
    kill $MPID 2>/dev/null
    wait $MPID 2>/dev/null
    echo "[Cycle $C] ⏸ IDLE 2m | $(date '+%H:%M:%S')"
    sleep 120
done
SCRIPT
RUN chmod +x /run-miner.sh

CMD ["/bin/bash", "/run-miner.sh"]
