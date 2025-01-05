-- PROCESO ALMACENADA PARA INSERTAR O ACTUALIZAR LAS ACCIONES DEL USUARIO
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_accion_usuario(i_json_data jsonb, i_usuario_accion integer) 
LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_acciones_usuario seguridad.tbl_acciones_usuarios;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_accion_usuario')::integer, 0); 
    v_id_accion_perfil integer := (i_json_data->>'id_accion_perfil')::integer;
    v_id_usuario integer := (i_json_data->>'id_usuario')::integer;
    v_id_estado integer := COALESCE((i_json_data->>'id_estado')::integer, v_estado_activo);
BEGIN

    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_acciones_perfiles WHERE id_accion_perfil = v_id_accion_perfil) THEN
        RAISE EXCEPTION '{"statusCode":400, "message": "No se ha encontrado la acción %"}', v_id_accion_perfil;
    END IF;

    v_id := (SELECT id_accion_usuario FROM seguridad.tbl_acciones_usuarios WHERE id_accion_perfil = v_id_accion_perfil AND id_usuario = v_id_usuario);
    
        IF v_id IS NULL THEN
            INSERT INTO seguridad.tbl_acciones_usuarios (id_accion_perfil, id_usuario, id_estado, fecha_crea, usuario_crea)
            VALUES (v_id_accion_perfil, v_id_usuario, v_id_estado, now(), i_usuario_accion)
            RETURNING * INTO v_tbl_acciones_usuario;
        ELSE
            UPDATE seguridad.tbl_acciones_usuarios
            SET id_estado = v_id_estado, usuario_actua=i_usuario_accion, fecha_actua=now()
            WHERE id_accion_usuario = v_id
            RETURNING * INTO v_tbl_acciones_usuario;
        END IF;

        IF v_tbl_acciones_usuario.id_accion_usuario IS NULL THEN
            RAISE EXCEPTION '{"statusCode":500, "message": "No se ha podido insertar la acción % del usuario"}', v_id_accion_perfil;
        END IF;
    
END
$$;