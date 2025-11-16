#!/bin/bash

#####################################################################
# Server Project | Service Monitor                                  #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 15/11/2025                                                  #
# Version: 1.0                                                      #
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################
# Here a Let my sugestion to use in your logrotate                  #
#/opt/matheus/pandora/*.log {
#        daily
#        missingok
#        rotate 7
#        compress
#        delaycompress
#        notifempty
#        copytruncate
#        dateext
#        create 0640 user group
#} 


log_file="/opt/pandora/status_service.log"

cooldown_dir="/tmp/cooldown_services"

if [ ! -d $cooldown_dir ];then
    mkdir $cooldown_dir
fi

log(){
    local msg="$1"
    local level="$2"
    local dt=$(date +"%Y-%M-%d %H:%M:%S")

    echo "$dt [$level]: $msg" >> $log_file

}

if ! source /usr/local/sbin/cfg/webhook.cfg; then
    log "The configuration files could not be loaded." "ERROR"
    exit 1
fi

webhook="${WEBHOOK_URL}"
cooldown_time=600 

services=(
    "docker"
    "openvpn-server@server"
    "jellyfin"
    "prometheus"
)

#Send the webhook
send_webhook() {
    local service_name="$1"
    local status="$2"   # DOWN ou UP
    local now=$(date +%s)

    local state_file="${cooldown_dir}/${service_name}.state"
    local cooldown_file="${cooldown_dir}/${service_name}.time"

    # Se estado atual é o mesmo estado salvo, não manda nada
    if [[ -f "$state_file" ]]; then
        local last_state=$(< "$state_file")
        if [[ "$last_state" == "$status" ]]; then
            return
        fi
    fi

    # Se status é DOWN → aplica cooldown
    if [[ "$status" == "DOWN" ]]; then
        if [[ -f "$cooldown_file" ]]; then
            local last_time=$(< "$cooldown_file")
            local diff=$((now - last_time))

            if (( diff < cooldown_time )); then
                local remaining=$((cooldown_time - diff))
                log "Cooldown active for $service_name. Skipping webhook. Remaining: ${remaining}s" "INFO"
                echo "$status" > "$state_file"
                return
            fi
        fi
    fi

    # --------------------------
    #   EMBED DO DISCORD
    # --------------------------

    if [[ "$status" == "DOWN" ]]; then
        local title="🚨 ALERTA: Serviço offline"
        local description="O serviço **\`${service_name}\`** está **offline** no servidor!"
        local color=15158332  # vermelho
    else
        local title="🟢 RECOVERY: Serviço restaurado"
        local description="O serviço **\`${service_name}\`** voltou a ficar **online**!"
        local color=3066993   # verde
    fi

    local footer="Pandora Service Monitor"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    JSON=$(jq -n \
        --arg title "$title" \
        --arg desc "$description" \
        --arg footer "$footer" \
        --arg timestamp "$timestamp" \
        --argjson color "$color" \
        '{
            embeds: [
                {
                    title: $title,
                    description: $desc,
                    color: $color,
                    footer: { text: $footer },
                    timestamp: $timestamp
                }
            ]
        }'
    )

    log "Sending webhook ($status) for $service_name" "INFO"

    response=$(curl -s -o /tmp/webhook_response.txt -w "%{http_code}" \
        -X POST "$webhook" \
        -H "Content-Type: application/json" \
        -d "$JSON")

    if [[ "$response" == "204" ]]; then
        log "Webhook ($status) sent successfully for $service_name" "INFO"
        echo "$now" > "$cooldown_file"
        echo "$status" > "$state_file"
    else
        log "Webhook failed for $service_name. HTTP code: $response" "ERROR"
    fi
}

pull_up() {
    local service="$1"

    log "Attempting to restart service $service" "INFO"
    systemctl start "$service"

    sleep 3

    if systemctl is-active --quiet "$service"; then
        log "Service $service successfully restarted" "INFO"
        
        # Envia webhook de RECOVERY imediato
        send_webhook "$service" "UP"
    else
        log "FAILED to restart service $service" "ERROR"

        # Envia webhook de falha ao restaurar
        send_webhook "$service" "DOWN"

        # Salva log completo do systemctl
        systemctl status "$service" &> "$cooldown_dir/${service}_error.log"

        log "Systemctl status saved to ${cooldown_dir}/${service}_error.log" "ERROR"
    fi
}




#Check de health of services
for i in "${services[@]}"; do
    if systemctl is-active --quiet "$i"; then
        log "Service $i OK" "INFO"
        send_webhook "$i" "UP"
    else
        log "Service $i is DOWN" "WARNING"
        send_webhook "$i" "DOWN"
        pull_up "$i"
    fi
done

