-- PROCESO ALMACENADO PARA CREAR Y ACTUALIZAR ACCIONES DE PERFILES
CREATE OR REPLACE PROCEDURE seguridad.prc_insertar_actualizar_accion_perfil(i_json_data jsonb, i_perfil_id integer, i_usuario_accion integer)
LANGUAGE 'plpgsql'
AS $$
DECLARE
    v_tbl_acciones_perfiles seguridad.tbl_acciones_perfiles;
    v_estado_activo integer := 1;

    -- v_id integer := COALESCE((i_json_data->>'id_accion_perfil')::integer, 0); 
    v_id_accion_menu integer := (i_json_data->>'id_accion_menu')::integer;
    v_id_estado integer := (i_json_data->>'id_estado')::integer;

    v_accion_perfil integer := (SELECT id_accion_perfil FROM seguridad.tbl_acciones_perfiles WHERE id_accion_menu = v_id_accion_menu AND id_perfil = i_perfil_id); 
BEGIN
    -- VERIFICAR QUE LA ACCION EXISTA
    IF NOT EXISTS (SELECT 1 FROM seguridad.tbl_acciones_menus WHERE id_accion_menu = v_id_accion_menu) THEN
        RAISE EXCEPTION '{"statusCode": 400, "message": "La acción no existe - %"}', v_id_accion_menu;
    END IF;

    BEGIN
        IF v_accion_perfil IS NULL THEN
            -- INSERTAR
            INSERT INTO seguridad.tbl_acciones_perfiles
            (id_estado, usuario_crea, fecha_crea, id_accion_menu, id_perfil)
            VALUES(v_estado_activo, i_usuario_accion, now(), v_id_accion_menu, i_perfil_id)
            RETURNING * INTO v_tbl_acciones_perfiles;
        ELSE
            -- ACTUALIZAR
            UPDATE seguridad.tbl_acciones_perfiles
            SET id_estado = v_id_estado, usuario_actua = i_usuario_accion, fecha_actua = now()
            WHERE id_accion_perfil = v_accion_perfil
            RETURNING * INTO v_tbl_acciones_perfiles;
        END IF;

        IF v_tbl_acciones_perfiles.id_accion_perfil IS NULL THEN
            RAISE EXCEPTION '{"statusCode": 400, "message": "Error al insertar o actualizar la acción de perfil"}';
        END IF;
    END;
END
$$;


