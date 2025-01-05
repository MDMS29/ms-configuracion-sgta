-- PROCESO ALMACENADO PARA INSERTAR O ACTUALIZAR LOS PERFILES DEL USUARIO
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_perfiles_usuario(i_json_data jsonb, i_usuario_accion integer) 
LANGUAGE plpgsql AS $$
DECLARE
    v_tbl_perfiles_usuario seguridad.tbl_perfiles_usuarios;
    v_estado_activo integer := 1;

    v_id integer := COALESCE((i_json_data->>'id_perfil_usuario')::integer, 0); 
    v_id_perfil integer := (i_json_data->>'id_perfil')::integer;
    v_id_usuario integer := (i_json_data->>'id_usuario')::integer;
    v_id_estado integer := COALESCE((i_json_data->>'id_estado')::integer, v_estado_activo);


BEGIN

    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_perfiles WHERE id_perfil = v_id_perfil AND id_estado = v_estado_activo) THEN
        RAISE EXCEPTION '{"statusCode":400, "message": "No se ha encontrado el perfil %"}', v_id_perfil;
    END IF;

    v_id := (SELECT id_perfil_usuario FROM seguridad.tbl_perfiles_usuarios WHERE id_perfil = v_id_perfil AND id_usuario = v_id_usuario);
    
    IF v_id IS NULL THEN
        INSERT INTO seguridad.tbl_perfiles_usuarios (id_perfil, id_usuario, id_estado, fecha_crea, usuario_crea)
        VALUES (v_id_perfil, v_id_usuario, v_id_estado, now(), i_usuario_accion)
        RETURNING * INTO v_tbl_perfiles_usuario;
    ELSE
        UPDATE seguridad.tbl_perfiles_usuarios
        SET id_estado = v_id_estado, usuario_actua = i_usuario_accion, fecha_actua = now()
        WHERE id_perfil_usuario = v_id
        RETURNING * INTO v_tbl_perfiles_usuario;
    END IF;

    IF v_tbl_perfiles_usuario.id_perfil_usuario IS NULL THEN
        RAISE EXCEPTION '{"statusCode":500, "message": "No se ha podido insertar el perfil % del usuario"}', v_id_perfil;
    END IF;

END
$$;