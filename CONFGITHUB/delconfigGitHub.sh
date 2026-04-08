echo -e "${ROJO}🗑️ Borrando configuración global de Git...${NC}"
    
    # 1. Borrar el archivo de configuración global (donde están nombre, email y helper)
    rm -f ~/.gitconfig
    
    # 2. Borrar el archivo físico donde se guardan las llaves (Tokens)
    rm -f ~/.git-credentials
    
    # 3. Limpiar la caché de credenciales de la sesión actual
    git credential-cache exit 2>/dev/null
    
    echo -e "${VERDE}✨ Sistema limpio. Ahora puedes probar tu script como si fuera la primera vez.${NC}"
