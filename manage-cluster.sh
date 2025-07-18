#!/bin/bash

#=======================================#
# PandoraBox                            #
# Manage Cluster Script                 #
#=======================================#
# Created by: Matheus Marins            #
# Date: 17/07/2025                      #
#=======================================#
case $1 in
    start)
        echo "Starting PandoraBox services..."
        docker-compose up -d
        ;;
    stop)
        echo "Stopping PandoraBox services..."
        docker-compose down
        ;;
    restart)
        echo "Restarting PandoraBox services..."
        docker-compose restart
        ;;
    status)
        echo "Checking status of PandoraBox services..."
        docker-compose ps
        if docker-compose ps portainer | grep -q "Up"; then
            echo "Access the Portainer UI at https://localhost:9443"
        fi
        ;;
    logs)
        echo "Fetching logs for PandoraBox services..."
        if [ -z "$2" ]; then
          echo "No service specified. Fetching logs for all services."
          docker-compose logs -f
        else
          echo "Fetching logs for service: $2"
          docker-compose logs -f "$2"
        fi
        ;;
    update)
        echo "Updating PandoraBox services..."
        docker-compose pull
        docker-compose up -d
        ;;
    clean)
        echo "Cleaning up unused Docker resources..."
        docker-compose down --volumes --remove-orphans
        docker system prune -f
        ;;
    backup)
        echo "Backing up PandoraBox data..."
        BACKUP_DIR="./backup/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        docker run --rm \
          -v "$BACKUP_DIR:/backup" \
          -v "portainer_data:/data" \
          alpine \
          tar -cJf /backup/portainer_backup.tar.xz -C /data .
        docker run --rm \
            -v "$BACKUP_DIR:/backup" \
            -v "$(pwd)/StirlingPDF/trainingData:/usr/share/tessdata" \
            -v "$(pwd)/StirlingPDF/extraConfigs:/configs" \
            -v "$(pwd)/StirlingPDF/customFiles:/customFiles" \
            -v "$(pwd)/StirlingPDF/logs:/logs" \
            -v "$(pwd)/StirlingPDF/pipeline:/pipeline" \
            alpine \
            sh -c 'tar -cJf /backup/stirlingpdf_backup.tar.xz \
              -C /usr/share/tessdata . \
              -C /configs . \
              -C /customFiles . \
              -C /logs . \
              -C /pipeline .'
        echo "Backup completed at $BACKUP_DIR"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs [service]|update|clean|backup}"
        echo ""
        echo "Available services:"
        echo " start - Start all PandoraBox services"
        echo " stop - Stop all PandoraBox services"
        echo " restart - Restart all PandoraBox services"
        echo " status - Check status of all PandoraBox services"
        echo " logs [service] - Fetch logs for a specific service"
        echo " update - Update all PandoraBox services"
        echo " clean - Clean up unused Docker resources -- BE CAREFUL!"
        echo " backup - Backup PandoraBox data"
        exit 1
        ;;
esac
